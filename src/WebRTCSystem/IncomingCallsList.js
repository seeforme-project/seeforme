import React, { useState, useEffect } from 'react';
import { View, Text, FlatList, TouchableOpacity, StyleSheet } from 'react-native';

const IncomingCallsList = ({ webRTCSystem }) => {
  const [incomingCalls, setIncomingCalls] = useState([]);

  useEffect(() => {
    // Set initial calls
    setIncomingCalls([...webRTCSystem.incomingCallRequests]);
    
    // Subscribe to incoming call events
    const handleIncomingCall = (calls) => {
      setIncomingCalls([...calls]);
    };
    
    webRTCSystem.on('incomingCallReceived', handleIncomingCall);
    
    // Cleanup subscription
    return () => {
      webRTCSystem.off('incomingCallReceived', handleIncomingCall);
    };
  }, [webRTCSystem]);

  const handleAcceptCall = async (callId, offer) => {
    try {
      const success = await webRTCSystem.answerCall(callId, offer);
      if (success) {
        navigation.navigate('VideoCall');
      }
    } catch (error) {
      console.error('Failed to answer call:', error);
    }
  };

  const formatTimestamp = (timestamp) => {
    const date = new Date(timestamp);
    const minutes = date.getMinutes().toString().padStart(2, '0');
    const seconds = date.getSeconds().toString().padStart(2, '0');
    return `${date.getHours()}:${minutes}:${seconds}`;
  };

  if (incomingCalls.length === 0) {
    return (
      <View style={styles.emptyContainer}>
        <Text style={styles.emptyText}>No incoming calls</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Incoming Calls</Text>
      <FlatList
        data={incomingCalls}
        keyExtractor={(item) => item.callId}
        renderItem={({ item }) => (
          <View style={styles.callItem}>
            <View style={styles.callInfo}>
              <Text style={styles.callId}>Call ID: {item.callId}</Text>
              <Text style={styles.timestamp}>
                Received at {formatTimestamp(item.timestamp)}
              </Text>
            </View>
            <TouchableOpacity
              style={styles.acceptButton}
              onPress={() => handleAcceptCall(item.callId, item.offer)}
            >
              <Text style={styles.acceptButtonText}>Accept</Text>
            </TouchableOpacity>
          </View>
        )}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 10,
    margin: 10,
    backgroundColor: '#f9f9f9',
  },
  title: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 10,
  },
  emptyContainer: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 15,
    margin: 10,
    alignItems: 'center',
    backgroundColor: '#f9f9f9',
  },
  emptyText: {
    color: '#888',
    fontStyle: 'italic',
  },
  callItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 10,
    borderWidth: 1,
    borderColor: '#eee',
    borderRadius: 5,
    marginVertical: 5,
    backgroundColor: '#fff',
  },
  callInfo: {
    flex: 1,
  },
  callId: {
    fontWeight: '500',
  },
  timestamp: {
    color: '#666',
    fontSize: 12,
    marginTop: 3,
  },
  acceptButton: {
    backgroundColor: '#4CAF50',
    paddingHorizontal: 15,
    paddingVertical: 8,
    borderRadius: 5,
  },
  acceptButtonText: {
    color: '#fff',
    fontWeight: 'bold',
  },
});

export default IncomingCallsList;