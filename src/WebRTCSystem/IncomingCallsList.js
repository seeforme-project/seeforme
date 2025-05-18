import React, { useState, useEffect } from 'react';
import { View, StyleSheet, Text, Animated, Easing } from 'react-native';
import { Card, Button } from 'react-native-paper';
import Icon from "react-native-vector-icons/MaterialCommunityIcons";
import { useNavigation } from '@react-navigation/native';

const DarkThemeColors = {
  background: "#111827",
  primary: "#4F46E5",
  text: "#F3F4F6",
  muted: "#9CA3AF",
  border: "#374151",
  error: "#EF4444",
  yellow: "#FBBF24",
  card: "#1F2937",
  available: "#059669",
  unavailable: "#4B5563",
  callYellow: "#292524",
  callGreen: "#064E3B",
  callBlue: "#0C4A6E",
  callRed: "#7F1D1D",
};

const IncomingCallsList = ({ webRTCSystem }) => {
  const [incomingCalls, setIncomingCalls] = useState([]);
  const navigation = useNavigation();

  // Color rotation for incoming calls
  const callColors = [
    DarkThemeColors.callYellow, 
    DarkThemeColors.callGreen, 
    DarkThemeColors.callBlue, 
    DarkThemeColors.callRed
  ];

  useEffect(() => {
    // Set initial calls
    if (webRTCSystem?.incomingCallRequests) {
      // Map the incoming calls to match the UI format
      const formattedCalls = webRTCSystem.incomingCallRequests.map((call, index) => ({
        id: call.callId,
        callId: call.callId,
        userName: `Caller ${call.callId.substring(0, 5)}`,
        timeRequested: formatTimestamp(call.timestamp),
        location: "Location unavailable",
        color: callColors[index % callColors.length],
        timestamp: call.timestamp,
        offer: call.offer
      }));
      
      setIncomingCalls(formattedCalls);
    }
    
    // Subscribe to incoming call events
    const handleIncomingCall = (calls) => {
      const formattedCalls = calls.map((call, index) => ({
        id: call.callId,
        callId: call.callId,
        userName: `Caller ${call.callId.substring(0, 5)}`,
        timeRequested: formatTimestamp(call.timestamp),
        location: "Location unavailable",
        color: callColors[index % callColors.length],
        timestamp: call.timestamp,
        offer: call.offer
      }));
      
      setIncomingCalls(formattedCalls);
    };
    
    if (webRTCSystem) {
      webRTCSystem.on('incomingCallReceived', handleIncomingCall);
      
      // Cleanup subscription
      return () => {
        webRTCSystem.off('incomingCallReceived', handleIncomingCall);
      };
    }
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
    const now = new Date();
    const date = new Date(timestamp);
    const diffMinutes = Math.floor((now - date) / (1000 * 60));
    
    if (diffMinutes < 1) return "Just now";
    if (diffMinutes === 1) return "1 minute ago";
    if (diffMinutes < 60) return `${diffMinutes} minutes ago`;
    
    const diffHours = Math.floor(diffMinutes / 60);
    if (diffHours === 1) return "1 hour ago";
    return `${diffHours} hours ago`;
  };

  if (incomingCalls.length === 0) {
    return (
      <View style={styles.emptyState}>
        <Icon name="bell-off" size={50} color={DarkThemeColors.muted} />
        <Text style={styles.emptyStateText}>No incoming calls at this time</Text>
      </View>
    );
  }

  return (
    <View>
      {incomingCalls.map((call) => (
        <Card 
          key={call.id} 
          style={[styles.callCard, { backgroundColor: call.color }]}
          onPress={() => console.log("Call details", call.id)}
        >
          <Card.Content>
            <View style={styles.callCardHeader}>
              <Text style={styles.callUserName}>{call.userName}</Text>
              <Text style={styles.callTime}>{call.timeRequested}</Text>
            </View>
            <View style={styles.callDetails}>
              <Icon name="phone-incoming" size={16} color={DarkThemeColors.muted} />
              <Text style={styles.callLocation}>Call ID: {call.callId}</Text>
            </View>
          </Card.Content>
          <Card.Actions style={styles.callCardActions}>
            <Button 
              mode="contained" 
              style={styles.acceptButton}
              contentStyle={styles.buttonContent}
              labelStyle={styles.buttonLabel}
              onPress={() => handleAcceptCall(call.callId, call.offer)}
            >
              Accept
            </Button>
            <Button 
              mode="outlined"
              style={styles.declineButton}
              contentStyle={styles.buttonContent}
              labelStyle={[styles.buttonLabel, { color: DarkThemeColors.muted }]}
              onPress={() => console.log("Declined call", call.id)}
            >
              Decline
            </Button>
          </Card.Actions>
        </Card>
      ))}
    </View>
  );
};

const styles = StyleSheet.create({
  callCard: {
    marginBottom: 12,
    borderRadius: 12,
    elevation: 2,
  },
  callCardHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 8,
  },
  callUserName: {
    fontSize: 16,
    fontWeight: "bold",
    color: DarkThemeColors.text,
    letterSpacing: 0.5,
  },
  callTime: {
    fontSize: 12,
    color: DarkThemeColors.muted,
    letterSpacing: 0.5,
  },
  callDetails: {
    flexDirection: "row",
    alignItems: "center",
  },
  callLocation: {
    fontSize: 14,
    color: DarkThemeColors.muted,
    marginLeft: 4,
    letterSpacing: 0.5,
  },
  callCardActions: {
    justifyContent: "flex-end",
    paddingTop: 8,
  },
  acceptButton: {
    backgroundColor: DarkThemeColors.primary,
    marginRight: 8,
    borderRadius: 30,
  },
  declineButton: {
    borderColor: DarkThemeColors.muted,
    borderRadius: 30,
  },
  buttonContent: {
    height: 40,
    paddingHorizontal: 16,
  },
  buttonLabel: {
    color: DarkThemeColors.text,
    fontSize: 14,
    letterSpacing: 0.5,
  },
  emptyState: {
    alignItems: "center",
    justifyContent: "center",
    padding: 32,
    backgroundColor: DarkThemeColors.card,
    borderRadius: 12,
  },
  emptyStateText: {
    marginTop: 12,
    fontSize: 16,
    color: DarkThemeColors.muted,
    textAlign: "center",
    letterSpacing: 0.5,
  },
});

export default IncomingCallsList;