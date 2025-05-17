import { 
  RTCPeerConnection, 
  RTCSessionDescription, 
  RTCIceCandidate, 
  mediaDevices,
  MediaStream // Import MediaStream here
} from 'react-native-webrtc';
import { EventEmitter } from 'events';

class WebRTCSystem {
  constructor() {
    this.socket = null;
    this.peerConnection = null;
    this.localStream = null;
    this.remoteStream = null;
    this.currentCallId = null;
    this.incomingCallRequests = [];
    this.pendingIceCandidates = [];
    this.isCallActive = false;
    this.eventEmitter = new EventEmitter();
    this.clientId = null;
    
    // Configuration for ICE servers
    this.peerConnectionConfig = {
      iceServers: [
        { urls: 'stun:stun.l.google.com:19302' },
        { urls: 'stun:stun1.l.google.com:19302' },
      ]
    };
  }

  // Initialize connection to the signaling server
  initialize(serverUrl) {
    try {
      this.socket = new WebSocket(serverUrl);
      
      this.socket.onopen = () => {
        console.log('Connected to signaling server');
        this.eventEmitter.emit('connectionStateChanged', true);
      };
      
      this.socket.onmessage = (event) => {
        const data = JSON.parse(event.data);
        this.handleSignalingMessage(data);
      };
      
      this.socket.onclose = () => {
        console.log('Disconnected from signaling server');
        this.eventEmitter.emit('connectionStateChanged', false);
        // Try to reconnect after delay
        setTimeout(() => {
          if (!this.socket || this.socket.readyState === WebSocket.CLOSED) {
            this.initialize(serverUrl);
          }
        }, 3000);
      };
      
      this.socket.onerror = (error) => {
        console.error('WebSocket error:', error);
      };
    } catch (error) {
      console.error('Failed to connect to signaling server:', error);
    }
  }

  // Handle incoming messages from signaling server
  handleSignalingMessage(data) {
    if (data.client_id) {
      this.clientId = data.client_id;
      console.log('Received client ID:', this.clientId);
      return;
    }
    
    if (data.type === 'new_call') {
      // New incoming call offer
      const callRequest = {
        callId: data.call_id,
        offer: data.offer,
        timestamp: Date.now()
      };
      
      // Check if we already have this call in our list
      const existingIndex = this.incomingCallRequests.findIndex(req => req.callId === data.call_id);
      if (existingIndex !== -1) {
        this.incomingCallRequests[existingIndex] = callRequest;
      } else {
        this.incomingCallRequests.push(callRequest);
      }
      
      // Notify listeners about new incoming call
      this.eventEmitter.emit('incomingCallReceived', this.incomingCallRequests);
    }
    else if (data.type === 'call_answered' && data.call_id === this.currentCallId) {
      // Someone answered our call
      console.log('Call answered, setting remote description');
      this.handleCallAnswered(data.answer);
    }
    else if (data.type === 'ice_candidate' && data.call_id === this.currentCallId) {
      // Received ICE candidate from the other peer
      this.handleRemoteIceCandidate(data.candidate);
    }
    else if (data.type === 'call_ended' && data.call_id === this.currentCallId) {
      // The call was ended by the other peer
      this.handleCallEnded();
    }
    else if (data.type === 'call_taken' && data.call_id) {
      // Remove call from incoming list since someone else took it
      this.incomingCallRequests = this.incomingCallRequests.filter(
        call => call.callId !== data.call_id
      );
      this.eventEmitter.emit('incomingCallReceived', this.incomingCallRequests);
    }
  }

  // Create and send an offer to initiate a call
  async startCall() {
    if (this.isCallActive) {
      console.warn('Call already in progress');
      return false;
    }
    
    try {
      // Get local media stream
      this.localStream = await this.getLocalStream();
      
      // Create a new RTCPeerConnection
      this.createPeerConnection();
      
      // Add local tracks to the peer connection
      this.localStream.getTracks().forEach(track => {
        this.peerConnection.addTrack(track, this.localStream);
      });
      
      // Create and set local description (offer)
      const offer = await this.peerConnection.createOffer();
      await this.peerConnection.setLocalDescription(offer);
      
      // Generate a unique call ID using current timestamp
      this.currentCallId = Math.floor(Date.now() / 1000).toString();
      
      // Send the offer to the signaling server
      this.socket.send(JSON.stringify({
        call_id: this.currentCallId,
        offer: this.peerConnection.localDescription
      }));
      
      console.log('Call offer sent, waiting for answer...');
      return true;
    } catch (error) {
      console.error('Error starting call:', error);
      this.cleanupCall();
      return false;
    }
  }

  // Answer an incoming call
  async answerCall(callId, offer) {
    if (this.isCallActive) {
      console.warn('Cannot answer - call already in progress');
      return false;
    }
    
    try {
      // Set current call ID
      this.currentCallId = callId;
      
      // Get local media stream
      this.localStream = await this.getLocalStream();
      
      // Create a new RTCPeerConnection
      this.createPeerConnection();
      
      // Add local tracks to the peer connection
      this.localStream.getTracks().forEach(track => {
        this.peerConnection.addTrack(track, this.localStream);
      });
      
      // Set remote description from the offer
      await this.peerConnection.setRemoteDescription(new RTCSessionDescription(offer));
      
      // Process any pending ICE candidates
      this.processPendingIceCandidates();
      
      // Create and set local description (answer)
      const answer = await this.peerConnection.createAnswer();
      await this.peerConnection.setLocalDescription(answer);
      
      // Send the answer back to the signaling server
      this.socket.send(JSON.stringify({
        call_id: this.currentCallId,
        answer: this.peerConnection.localDescription
      }));
      
      console.log('Call answered, waiting for connection...');
      
      // Remove this call from the incoming calls list
      this.incomingCallRequests = this.incomingCallRequests.filter(
        call => call.callId !== callId
      );
      this.eventEmitter.emit('incomingCallReceived', this.incomingCallRequests);
      
      return true;
    } catch (error) {
      console.error('Error answering call:', error);
      this.cleanupCall();
      return false;
    }
  }

  // Handle when a call is answered by the remote peer
  async handleCallAnswered(answer) {
    try {
      await this.peerConnection.setRemoteDescription(new RTCSessionDescription(answer));
      console.log('Remote description set successfully');
      
      // Process any pending ICE candidates
      this.processPendingIceCandidates();
    } catch (error) {
      console.error('Error setting remote description:', error);
    }
  }

  // Create the peer connection with all necessary event handlers
  createPeerConnection() {
    this.peerConnection = new RTCPeerConnection(this.peerConnectionConfig);
    
    // Handle ICE candidate events
    this.peerConnection.onicecandidate = (event) => {
      if (event.candidate) {
        this.socket.send(JSON.stringify({
          call_id: this.currentCallId,
          candidate: event.candidate
        }));
      }
    };
    
    // Handle connection state changes
    this.peerConnection.onconnectionstatechange = () => {
      // Safely check connection state - peerConnection might be null
      if (this.peerConnection) {
        console.log('Connection state:', this.peerConnection.connectionState);
        if (this.peerConnection.connectionState === 'connected') {
          this.isCallActive = true;
          this.eventEmitter.emit('callConnected');
        } else if (['disconnected', 'failed', 'closed'].includes(this.peerConnection.connectionState)) {
          if (this.isCallActive) {
            this.handleCallEnded();
          }
        }
      }
    };
    
    // Handle incoming tracks from remote peer
    this.peerConnection.ontrack = (event) => {
      console.log('Received remote track');
      if (!this.remoteStream) {
        // Use the imported MediaStream constructor
        this.remoteStream = new MediaStream();
      }
      
      // Add all tracks from the event streams
      if (event.streams && event.streams[0]) {
        event.streams[0].getTracks().forEach(track => {
          this.remoteStream.addTrack(track);
        });
        this.eventEmitter.emit('remoteStreamUpdated', this.remoteStream);
      } else if (event.track) {
        // Fallback if no streams are available but track is
        this.remoteStream.addTrack(event.track);
        this.eventEmitter.emit('remoteStreamUpdated', this.remoteStream);
      }
    };
  }

  // Handle incoming ICE candidates from remote peer
  handleRemoteIceCandidate(candidateData) {
    const candidate = new RTCIceCandidate(candidateData);
    
    if (this.peerConnection && this.peerConnection.remoteDescription) {
      // If we have the remote description, add the candidate directly
      this.peerConnection.addIceCandidate(candidate)
        .catch(error => console.error('Error adding received ICE candidate:', error));
    } else {
      // Otherwise, store it for later
      console.log('Queuing ICE candidate');
      this.pendingIceCandidates.push(candidate);
    }
  }

  // Process any stored ICE candidates after remote description is set
  processPendingIceCandidates() {
    if (this.peerConnection && this.peerConnection.remoteDescription) {
      console.log(`Processing ${this.pendingIceCandidates.length} pending ICE candidates`);
      
      this.pendingIceCandidates.forEach(candidate => {
        this.peerConnection.addIceCandidate(candidate)
          .catch(error => console.error('Error adding ICE candidate:', error));
      });
      
      this.pendingIceCandidates = [];
    }
  }

  // Get local media stream (camera and microphone)
  async getLocalStream() {
    try {
      const stream = await mediaDevices.getUserMedia({
        audio: true,
        video: {
          facingMode: 'user',
          width: 640,
          height: 480
        }
      });
      this.eventEmitter.emit('localStreamUpdated', stream);
      return stream;
    } catch (error) {
      console.error('Error accessing media devices:', error);
      throw error;
    }
  }

  // End the current call
  endCall() {
    if (!this.currentCallId) {
      return;
    }
    
    // First, send the end call message before cleaning up resources
    try {
      if (this.socket && this.socket.readyState === WebSocket.OPEN) {
        this.socket.send(JSON.stringify({
          call_id: this.currentCallId,
          type: 'end_call'
        }));
      }
    } catch (error) {
      console.error('Error sending end call message:', error);
    }
    
    // Then clean up local resources
    this.handleCallEnded();
  }

  // Handle call ended event (either from local or remote side)
  handleCallEnded() {
    console.log('Call ended');
    this.eventEmitter.emit('callEnded');
    this.cleanupCall();
  }

  // Clean up resources when call ends
  cleanupCall() {
    this.isCallActive = false;
    
    // Keep a reference to currentCallId for logging then clear it
    const endedCallId = this.currentCallId;
    this.currentCallId = null;
    
    // Stop all local tracks
    if (this.localStream) {
      this.localStream.getTracks().forEach(track => {
        try {
          track.stop();
        } catch (error) {
          console.error('Error stopping track:', error);
        }
      });
      this.localStream = null;
    }
    
    // Clear remote stream
    this.remoteStream = null;
    
    // Close peer connection - do this last to prevent null reference errors
    if (this.peerConnection) {
      try {
        this.peerConnection.close();
      } catch (error) {
        console.error('Error closing peer connection:', error);
      }
      this.peerConnection = null;
    }
    
    // Clear pending candidates
    this.pendingIceCandidates = [];
    
    // Notify listeners
    this.eventEmitter.emit('localStreamUpdated', null);
    this.eventEmitter.emit('remoteStreamUpdated', null);
    
    console.log(`Call cleanup completed for call: ${endedCallId}`);
  }

  // Subscribe to events
  on(eventName, callback) {
    this.eventEmitter.on(eventName, callback);
  }

  // Unsubscribe from events
  off(eventName, callback) {
    this.eventEmitter.off(eventName, callback);
  }
}

// Create a default instance
export const defaultWebRTCSystem = new WebRTCSystem();

// Export both the class and the default instance
export default WebRTCSystem;