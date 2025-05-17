import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import WebRTCSystem from './WebRTCSystem';
import StartCallButton from './StartCallButton';
import IncomingCallsList from './IncomingCallsList';
import VideoCallPage from './VideoCallPage';

const TestClientComponent = ({ serverUrl, clientName }) => {
  const [isInCall, setIsInCall] = useState(false);
  const [isConnected, setIsConnected] = useState(false);
  const [webRTCSystem] = useState(() => new WebRTCSystem());

  useEffect(() => {
    // Initialize WebRTC system with signaling server URL
    webRTCSystem.initialize(serverUrl);
    
    // Subscribe to connection state changes
    const handleConnectionState = (connected) => {
      setIsConnected(connected);
    };
    
    webRTCSystem.on('connectionStateChanged', handleConnectionState);
    
    // Cleanup
    return () => {
      webRTCSystem.off('connectionStateChanged', handleConnectionState);
    };
  }, [webRTCSystem, serverUrl]);

  const handleCallStarted = () => {
    setIsInCall(true);
  };

  const handleCallAccepted = () => {
    setIsInCall(true);
  };

  const handleCallEnded = () => {
    setIsInCall(false);
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerText}>{clientName}</Text>
        <View style={[
          styles.connectionStatus,
          { backgroundColor: isConnected ? '#4CAF50' : '#f44336' }
        ]} />
      </View>

      {isInCall ? (
        <VideoCallPage 
          webRTCSystem={webRTCSystem} 
          onCallEnded={handleCallEnded}
        />
      ) : (
        <ScrollView>
          <StartCallButton 
            webRTCSystem={webRTCSystem} 
            onCallStarted={handleCallStarted} 
          />
          <IncomingCallsList 
            webRTCSystem={webRTCSystem} 
            onCallAccepted={handleCallAccepted} 
          />
        </ScrollView>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: 10,
    paddingHorizontal: 15,
    backgroundColor: '#2196F3',
  },
  headerText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
  connectionStatus: {
    width: 12,
    height: 12,
    borderRadius: 6,
  },
});

export default TestClientComponent;