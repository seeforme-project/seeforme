// WebRTC Test to check if data can be exchanged between 2 peers. - IT WORKS
import React, { useState, useRef, useEffect } from 'react';
import {
  View,
  StyleSheet,
  Text,
  TouchableOpacity,
  SafeAreaView,
  StatusBar,
} from 'react-native';
import {
  RTCPeerConnection,
  RTCIceCandidate,
  RTCSessionDescription,
  mediaDevices,
  RTCView,
} from 'react-native-webrtc';

// Basic STUN servers for NAT traversal
const configuration = {
  iceServers: [
    { urls: 'stun:stun.l.google.com:19302' },
    { urls: 'stun:stun1.l.google.com:19302' },
  ],
};

const WebRTCPage = () => {
  
  // State management
  const [localStream, setLocalStream] = useState(null);
  const [remoteStream, setRemoteStream] = useState(null);
  const [callStarted, setCallStarted] = useState(false);
  const [connecting, setConnecting] = useState(false);
  const [status, setStatus] = useState('Ready to connect');
  
  // References for peer connections
  const peer1 = useRef(null);
  const peer2 = useRef(null);

  // Initialize camera on component mount
  useEffect(() => {
    const initializeCamera = async () => {
      try {
        const constraints = {
          audio: true,
          video: {
            facingMode: 'user',
          },
        };
        
        const stream = await mediaDevices.getUserMedia(constraints);
        setLocalStream(stream);
        setStatus('Camera initialized. Press Connect to start call.');
      } catch (err) {
        setStatus(`Error accessing media: ${err.message}`);
        console.error('Error accessing media:', err);
      }
    };
    
    initializeCamera();
    
    // Clean up when component unmounts
    return () => {
      if (localStream) {
        localStream.getTracks().forEach(track => track.stop());
      }
      endCall();
    };
  }, []);

  // Start WebRTC connection between peers
  const startCall = async () => {
    if (!localStream) {
      setStatus('Local stream not available. Please allow camera access.');
      return;
    }

    setConnecting(true);
    setStatus('Initiating call...');

    console.log('Starting call...');

    try {
      // Create peer connections
      peer1.current = new RTCPeerConnection(configuration);
      peer2.current = new RTCPeerConnection(configuration);

      // Add local stream to peer1 (caller)
      localStream.getTracks().forEach(track => {
        peer1.current.addTrack(track, localStream);
      });

      // Handle ICE candidates exchange - peer1 to peer2
      peer1.current.onicecandidate = ({ candidate }) => {
        if (candidate) {
          console.log('Peer1 ICE candidate:', candidate);
          peer2.current.addIceCandidate(new RTCIceCandidate(candidate));
        }
      };

      // Handle ICE candidates exchange - peer2 to peer1
      peer2.current.onicecandidate = ({ candidate }) => {
        if (candidate) {
          console.log('Peer2 ICE candidate:', candidate);
          peer1.current.addIceCandidate(new RTCIceCandidate(candidate));
        }
      };

      // Handle incoming stream on peer2 (receiver)
      peer2.current.ontrack = (event) => {
        console.log('Received track from peer1');
        if (event.streams && event.streams[0]) {
          setRemoteStream(event.streams[0]);
        } else {
          // If event.streams is not available, create a new MediaStream
          const newStream = new MediaStream();
          newStream.addTrack(event.track);
          setRemoteStream(newStream);
        }
      };

      // Create offer from peer1 (caller)
      const offer = await peer1.current.createOffer();
      await peer1.current.setLocalDescription(offer);
      
      setStatus('Offer created, sending to peer2...');

      // Set remote description on peer2 (receiver)
      await peer2.current.setRemoteDescription(new RTCSessionDescription(peer1.current.localDescription));
      
      // Create answer from peer2 (receiver)
      const answer = await peer2.current.createAnswer();
      await peer2.current.setLocalDescription(answer);
      
      setStatus('Answer created, finalizing connection...');

      // Complete the connection by setting peer2's answer as peer1's remote description
      await peer1.current.setRemoteDescription(new RTCSessionDescription(peer2.current.localDescription));
      
      setStatus('Call connected!');
      setCallStarted(true);
      setConnecting(false);
    } catch (err) {
      setStatus(`Call failed: ${err.message}`);
      console.error('Error establishing call:', err);
      setConnecting(false);
    }
  };

  // End WebRTC connection
  const endCall = () => {
    if (peer1.current) {
      peer1.current.close();
      peer1.current = null;
    }
    if (peer2.current) {
      peer2.current.close();
      peer2.current = null;
    }
    
    setRemoteStream(null);
    setCallStarted(false);
    setStatus('Call ended');
  };

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="light-content" />
      
      <View style={styles.statusContainer}>
        <Text style={styles.statusText}>Status: {status}</Text>
      </View>
      
      <View style={styles.videoContainer}>
        {/* Peer 1 (Top) - Local stream */}
        <View style={styles.videoWrapper}>
          <Text style={styles.peerLabel}>Peer 1 (Local)</Text>
          {localStream ? (
            <RTCView
              streamURL={localStream.toURL()}
              style={styles.video}
              objectFit="cover"
              mirror={true}
            />
          ) : (
            <View style={[styles.video, styles.noVideo]}>
              <Text style={styles.noVideoText}>Camera initializing...</Text>
            </View>
          )}
        </View>

        {/* Peer 2 (Bottom) - Remote stream */}
        <View style={styles.videoWrapper}>
          <Text style={styles.peerLabel}>Peer 2 (Remote)</Text>
          {remoteStream ? (
            <RTCView
              streamURL={remoteStream.toURL()}
              style={styles.video}
              objectFit="cover"
            />
          ) : (
            <View style={[styles.video, styles.noVideo]}>
              <Text style={styles.noVideoText}>
                {callStarted ? 'Connecting...' : 'Not connected'}
              </Text>
            </View>
          )}
        </View>
      </View>

      <View style={styles.controlsContainer}>
        {!callStarted ? (
          <TouchableOpacity
            style={[styles.button, connecting && styles.buttonDisabled]}
            onPress={startCall}
            disabled={connecting || !localStream}
          >
            <Text style={styles.buttonText}>
              {connecting ? 'Connecting...' : 'Connect Peers'}
            </Text>
          </TouchableOpacity>
        ) : (
          <TouchableOpacity style={[styles.button, styles.endButton]} onPress={endCall}>
            <Text style={styles.buttonText}>End Call</Text>
          </TouchableOpacity>
        )}
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#1a1a1a',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 15,
    backgroundColor: '#2a2a2a',
  },
  backButton: {
    marginRight: 15,
  },
  backButtonText: {
    color: '#4a90e2',
    fontSize: 16,
    fontWeight: 'bold',
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: 'white',
  },
  statusContainer: {
    padding: 10,
    backgroundColor: '#333',
    alignItems: 'center',
  },
  statusText: {
    color: '#ccc',
    fontSize: 14,
  },
  videoContainer: {
    flex: 1,
    flexDirection: 'column',
  },
  videoWrapper: {
    flex: 1,
    margin: 10,
    borderRadius: 12,
    overflow: 'hidden',
    backgroundColor: '#000',
    elevation: 5,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.3,
    shadowRadius: 4,
  },
  peerLabel: {
    position: 'absolute',
    top: 10,
    left: 10,
    backgroundColor: 'rgba(0, 0, 0, 0.6)',
    color: 'white',
    padding: 6,
    borderRadius: 5,
    zIndex: 10,
    fontSize: 14,
  },
  video: {
    flex: 1,
    backgroundColor: '#121212',
  },
  noVideo: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  noVideoText: {
    color: '#888',
    fontSize: 16,
  },
  controlsContainer: {
    padding: 20,
    backgroundColor: '#2a2a2a',
  },
  button: {
    backgroundColor: '#4a90e2',
    padding: 15,
    borderRadius: 10,
    alignItems: 'center',
  },
  buttonDisabled: {
    backgroundColor: '#666',
  },
  endButton: {
    backgroundColor: '#e53935',
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
  },
});

export default WebRTCPage;