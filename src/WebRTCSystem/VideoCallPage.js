import React, { useEffect, useState, useRef } from 'react';
import {
  View,
  TouchableOpacity,
  Text,
  StyleSheet,
  Dimensions,
  ActivityIndicator,
  Modal,
  SafeAreaView,
  ScrollView,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { RTCView } from 'react-native-webrtc';
import Icon from 'react-native-vector-icons/MaterialIcons';

import TestClientComponent from './TestClientComponent';
import { SIGNALING_SERVER_URL } from '../../Config';

// Debug Panel Component using a Modal approach
const DebugPanel = ({ serverUrl }) => {
  const [isVisible, setIsVisible] = useState(false);

  const togglePanel = () => {
    setIsVisible(!isVisible);
  };

  return (
    <View style={styles.debugButtonContainer}>
      <TouchableOpacity
        style={styles.debugIconButton}
        onPress={togglePanel}
      >
        <Icon 
          name="bug-report" 
          size={24} 
          color="#fff" 
        />
        <Text style={styles.debugIconText}>Test Clients</Text>
      </TouchableOpacity>
      
      {/* Use a Modal instead of animation for more reliable rendering */}
      <Modal
        animationType="slide"
        transparent={true}
        visible={isVisible}
        onRequestClose={() => setIsVisible(false)}
      >
        <SafeAreaView style={styles.modalContainer}>
          <View style={styles.modalContent}>
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>Debug Test Clients</Text>
              <TouchableOpacity onPress={() => setIsVisible(false)}>
                <Icon name="close" size={24} color="#fff" />
              </TouchableOpacity>
            </View>
            
            <ScrollView style={styles.clientsContainer}>
              <View style={styles.clientSection}>
                <Text style={styles.clientSectionTitle}>Test Client 1</Text>
                <View style={styles.testClient}>
                  <TestClientComponent 
                    serverUrl={serverUrl} 
                    clientName="Test Client 1" 
                  />
                </View>
              </View>
              
              <View style={styles.clientSection}>
                <Text style={styles.clientSectionTitle}>Test Client 2</Text>
                <View style={styles.testClient}>
                  <TestClientComponent 
                    serverUrl={serverUrl} 
                    clientName="Test Client 2" 
                  />
                </View>
              </View>
            </ScrollView>
          </View>
        </SafeAreaView>
      </Modal>
    </View>
  );
};

const VideoCallPage = ({ webRTCSystem }) => {
  const navigation = useNavigation();

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

      {/* Debug Panel */}
      <DebugPanel serverUrl={SIGNALING_SERVER_URL} />

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
    zIndex: 10,
  },
  endCallButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
  },
  
  // Debug Panel styles with Modal
  debugButtonContainer: {
    position: 'absolute',
    top: 40,
    right: 20,
    zIndex: 9999,
  },
  debugIconButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#4CAF50', // Green color
    paddingVertical: 8,
    paddingHorizontal: 12,
    borderRadius: 20,
  },
  debugIconText: {
    color: '#fff',
    marginLeft: 5,
    fontWeight: 'bold',
  },
  modalContainer: {
    flex: 1,
    justifyContent: 'flex-end', // Modal slides up from the bottom
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
  },
  modalContent: {
    height: '70%', // Take up 70% of the screen
    backgroundColor: '#212121',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    padding: 20,
  },
  modalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 15,
  },
  modalTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#fff',
  },
  clientsContainer: {
    flex: 1,
  },
  clientSection: {
    marginBottom: 20,
  },
  clientSectionTitle: {
    fontSize: 16,
    color: '#4CAF50',
    fontWeight: '600',
    marginBottom: 10,
  },
  testClient: {
    borderWidth: 1,
    borderColor: '#555',
    borderRadius: 8,
    height: 300, // Fixed height
    backgroundColor: '#333',
    overflow: 'hidden',
  },
});

export default VideoCallPage;