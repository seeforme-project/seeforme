import React, { useEffect, useState } from 'react';
import {
  View,
  TouchableOpacity,
  Text,
  StyleSheet,
  Dimensions,
  ActivityIndicator,
} from 'react-native';
import { RTCView } from 'react-native-webrtc';

const VideoCallPage = ({ webRTCSystem, onCallEnded }) => {
  const [localStream, setLocalStream] = useState(null);
  const [remoteStream, setRemoteStream] = useState(null);
  const [isConnecting, setIsConnecting] = useState(true);

  useEffect(() => {
    // Set initial streams if they exist
    if (webRTCSystem.localStream) {
      setLocalStream(webRTCSystem.localStream);
    }
    
    if (webRTCSystem.remoteStream) {
      setRemoteStream(webRTCSystem.remoteStream);
    }
    
    // Subscribe to stream updates
    const handleLocalStreamUpdate = (stream) => {
      setLocalStream(stream);
    };
    
    const handleRemoteStreamUpdate = (stream) => {
      setRemoteStream(stream);
      if (stream) setIsConnecting(false);
    };
    
    const handleCallConnected = () => {
      setIsConnecting(false);
    };
    
    const handleCallEnded = () => {
      if (onCallEnded) {
        onCallEnded();
      }
    };
    
    // Add event listeners
    webRTCSystem.on('localStreamUpdated', handleLocalStreamUpdate);
    webRTCSystem.on('remoteStreamUpdated', handleRemoteStreamUpdate);
    webRTCSystem.on('callConnected', handleCallConnected);
    webRTCSystem.on('callEnded', handleCallEnded);
    
    // Clean up event listeners
    return () => {
      webRTCSystem.off('localStreamUpdated', handleLocalStreamUpdate);
      webRTCSystem.off('remoteStreamUpdated', handleRemoteStreamUpdate);
      webRTCSystem.off('callConnected', handleCallConnected);
      webRTCSystem.off('callEnded', handleCallEnded);
    };
  }, [webRTCSystem, onCallEnded]);

  const handleEndCall = () => {
    webRTCSystem.endCall();
    if (onCallEnded) {
      onCallEnded();
    }
  };

  return (
    <View style={styles.container}>
      {/* Local video stream (top half) */}
      <View style={styles.localStreamContainer}>
        {localStream ? (
          <RTCView
            streamURL={localStream.toURL()}
            style={styles.localStream}
            objectFit="cover"
            mirror={true}
          />
        ) : (
          <View style={styles.noStreamContainer}>
            <Text style={styles.noStreamText}>No local stream</Text>
          </View>
        )}
      </View>

      {/* Remote video stream (bottom half) */}
      <View style={styles.remoteStreamContainer}>
        {isConnecting ? (
          <View style={styles.connectingContainer}>
            <ActivityIndicator size="large" color="#2196F3" />
            <Text style={styles.connectingText}>Connecting to remote peer...</Text>
          </View>
        ) : remoteStream ? (
          <RTCView
            streamURL={remoteStream.toURL()}
            style={styles.remoteStream}
            objectFit="cover"
            mirror={false}
          />
        ) : (
          <View style={styles.noStreamContainer}>
            <Text style={styles.noStreamText}>No remote stream</Text>
          </View>
        )}
      </View>

      {/* End call button */}
      <TouchableOpacity style={styles.endCallButton} onPress={handleEndCall}>
        <Text style={styles.endCallButtonText}>End Call</Text>
      </TouchableOpacity>
    </View>
  );
};

const { width, height } = Dimensions.get('window');

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000',
  },
  localStreamContainer: {
    height: height / 2,
    width: width,
    backgroundColor: '#222',
  },
  localStream: {
    width: '100%',
    height: '100%',
  },
  remoteStreamContainer: {
    height: height / 2,
    width: width,
    backgroundColor: '#222',
  },
  remoteStream: {
    width: '100%',
    height: '100%',
  },
  noStreamContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#333',
  },
  noStreamText: {
    color: '#fff',
    fontSize: 18,
  },
  connectingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#333',
  },
  connectingText: {
    color: '#fff',
    fontSize: 16,
    marginTop: 10,
  },
  endCallButton: {
    position: 'absolute',
    bottom: 30,
    alignSelf: 'center',
    backgroundColor: '#f44336',
    paddingHorizontal: 25,
    paddingVertical: 12,
    borderRadius: 25,
  },
  endCallButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
  },
});

export default VideoCallPage;