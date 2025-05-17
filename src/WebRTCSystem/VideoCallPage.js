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

import TestClientComponent from './TestClientComponent';
import { SIGNALING_SERVER_URL } from '../../Config';
import { transparent } from 'react-native-paper/lib/typescript/styles/themes/v2/colors';

const VideoCallPage = ({ webRTCSystem }) => {
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
      navigation.goBack();
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
  }, [webRTCSystem]);

  const handleEndCall = () => {
    webRTCSystem.endCall();
    // navigation.goBack();
  };

  return (
    <View style={styles.container}>
      {/* Local video stream (top half) */}
      <View style={styles.localStreamContainer}>










      { /* Test clients container */ }
      
        
        
          <View style={styles.testClient}>
            <TestClientComponent 
              serverUrl={SIGNALING_SERVER_URL} 
              clientName="Test Client 1" 
            />
          </View>
       
      











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




















  testButton: {
    backgroundColor: '#673AB7',
    padding: 12,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 20,
  },
  testButtonText: {
    color: '#fff',
    fontWeight: 'bold',
  },
  testClientsContainer: {
    marginTop: 20,
    padding: 16,
    borderTopWidth: 1,
    borderColor: '#ddd',
  },
  testClientsHeader: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 10,
  },
  clientsRow: {
    flexDirection: 'row',
    height: 400,
  },
  testClient: {
    flex: 1,
    borderWidth: 1,
    borderColor: '#ccc',
    margin: 5,
  },
});

export default VideoCallPage;