import React, { useState } from 'react';
import { SafeAreaView, StyleSheet, View, Text, TouchableOpacity } from 'react-native';
import { defaultWebRTCSystem } from './WebRTCSystem';
import StartCallButton from './StartCallButton';
import IncomingCallsList from './IncomingCallsList';
import VideoCallPage from './VideoCallPage';
import TestClientComponent from './TestClientComponent';

// Signaling server URL
const SIGNALING_SERVER_URL = 'ws://192.168.1.4:50001';

const App = () => {
  const [isInCall, setIsInCall] = useState(false);
  const [showTestClients, setShowTestClients] = useState(false);

  // Initialize the default WebRTC system
  React.useEffect(() => {
    defaultWebRTCSystem.initialize(SIGNALING_SERVER_URL);
  }, []);

  const handleCallStarted = () => {
    setIsInCall(true);
  };

  const handleCallAccepted = () => {
    setIsInCall(true);
  };

  const handleCallEnded = () => {
    setIsInCall(false);
  };

  const toggleTestClients = () => {
    setShowTestClients(!showTestClients);
  };

  // Main app content
  const renderMainContent = () => {
    if (isInCall) {
      return (
        <VideoCallPage 
          webRTCSystem={defaultWebRTCSystem} 
          onCallEnded={handleCallEnded}
        />
      );
    }
    
    return (
      <View style={styles.mainContentContainer}>
        <StartCallButton 
          webRTCSystem={defaultWebRTCSystem} 
          onCallStarted={handleCallStarted} 
        />
        <IncomingCallsList 
          webRTCSystem={defaultWebRTCSystem} 
          onCallAccepted={handleCallAccepted} 
        />
        <TouchableOpacity style={styles.testButton} onPress={toggleTestClients}>
          <Text style={styles.testButtonText}>
            {showTestClients ? 'Hide Test Clients' : 'Show Test Clients'}
          </Text>
        </TouchableOpacity>
      </View>
    );
  };

  // Test clients container
  const renderTestClients = () => {
    if (!showTestClients) return null;
    
    return (
      <View style={styles.testClientsContainer}>
        <Text style={styles.testClientsHeader}>Test Clients</Text>
        <View style={styles.clientsRow}>
          <View style={styles.testClient}>
            <TestClientComponent 
              serverUrl={SIGNALING_SERVER_URL} 
              clientName="Test Client 1" 
            />
          </View>
          <View style={styles.testClient}>
            <TestClientComponent 
              serverUrl={SIGNALING_SERVER_URL} 
              clientName="Test Client 2" 
            />
          </View>
        </View>
      </View>
    );
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.appContainer}>
        <Text style={styles.appHeader}>WebRTC Video Call</Text>
        {renderMainContent()}
        {renderTestClients()}
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  appContainer: {
    flex: 1,
  },
  appHeader: {
    fontSize: 22,
    fontWeight: 'bold',
    margin: 16,
    textAlign: 'center',
  },
  mainContentContainer: {
    padding: 16,
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

export default App;