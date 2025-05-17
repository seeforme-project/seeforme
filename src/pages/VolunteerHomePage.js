import React, { useState, useEffect } from "react";
import { 
  View, 
  StyleSheet, 
  Text, 
  TouchableOpacity, 
  ScrollView, 
  StatusBar,
  Animated,
  Easing
} from "react-native";
import { Appbar, Button, Card, IconButton } from "react-native-paper";
import Icon from "react-native-vector-icons/MaterialCommunityIcons";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { BASE_URL, api } from "../../Config";

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

// Enhanced Availability Toggle Component with Large Circular Design
const AvailabilityToggle = ({ isAvailable, onToggle }) => {
  const [animation] = useState(new Animated.Value(isAvailable ? 1 : 0));
  
  useEffect(() => {
    Animated.timing(animation, {
      toValue: isAvailable ? 1 : 0,
      duration: 400,
      easing: Easing.bezier(0.4, 0.0, 0.2, 1),
      useNativeDriver: false,
    }).start();
  }, [isAvailable]);

  const backgroundColor = animation.interpolate({
    inputRange: [0, 1],
    outputRange: [DarkThemeColors.unavailable, DarkThemeColors.available]
  });

  const scale = animation.interpolate({
    inputRange: [0, 0.5, 1],
    outputRange: [1, 0.95, 1]
  });

  return (
    <View style={styles.toggleWrapper}>
      <TouchableOpacity 
        onPress={onToggle}
        activeOpacity={0.8}
      >
        <Animated.View 
          style={[
            styles.toggleContainer,
            { 
              backgroundColor,
              transform: [{ scale }]
            }
          ]}
        >
          <Icon
            name={isAvailable ? "check-circle" : "power-sleep"}
            size={40}
            color={DarkThemeColors.text}
            style={styles.toggleIcon}
          />
          <Text style={styles.toggleStatus}>
            {isAvailable ? "AVAILABLE" : "UNAVAILABLE"}
          </Text>
        </Animated.View>
      </TouchableOpacity>
    </View>
  );
};

export default function VolunteerHomePage({ navigation }) {
  const [isAvailable, setIsAvailable] = useState(false);
  
  const pendingCalls = [
    {
      id: "1",
      userName: "John Smith",
      timeRequested: "5 minutes ago",
      location: "Downtown, City",
      color: DarkThemeColors.callYellow,
    },
    {
      id: "2",
      userName: "Sarah Johnson",
      timeRequested: "15 minutes ago",
      location: "North Park, City",
      color: DarkThemeColors.callGreen,
    },
    {
      id: "3",
      userName: "David Lee",
      timeRequested: "30 minutes ago",
      location: "West Mall, City",
      color: DarkThemeColors.callBlue,
    },
    {
      id: "4",
      userName: "Emma Wilson",
      timeRequested: "45 minutes ago",
      location: "East Side, City",
      color: DarkThemeColors.callRed,
    },
  ];

  const toggleAvailability = () => {
    setIsAvailable(!isAvailable);
  };

  return (
    <View style={styles.container}>
      <StatusBar backgroundColor={DarkThemeColors.background} barStyle="light-content" />
      
      <Appbar.Header style={styles.appBar}>
        <Appbar.Content title="Dashboard" titleStyle={styles.appBarTitle} />
        <Appbar.Action 
          icon="headset" 
          onPress={() => navigation.navigate("Support")} 
          color={DarkThemeColors.text}
        />
        <Appbar.Action 
          icon="account" 
          onPress={() => navigation.navigate("Profile")} 
          color={DarkThemeColors.text}
        />
      </Appbar.Header>
      
      <ScrollView style={styles.content}>
        <View style={styles.availabilityContainer}>
          <AvailabilityToggle 
            isAvailable={isAvailable}
            onToggle={toggleAvailability}
          />
        </View>
        
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Pending Assistance Calls</Text>
          
          {pendingCalls.length > 0 ? (
            pendingCalls.map((call) => (
              <Card 
                key={call.id} 
                style={[styles.callCard, { backgroundColor: call.color }]}
                onPress={() => navigation.navigate("CallDetails", { callId: call.id })}
              >
                <Card.Content>
                  <View style={styles.callCardHeader}>
                    <Text style={styles.callUserName}>{call.userName}</Text>
                    <Text style={styles.callTime}>{call.timeRequested}</Text>
                  </View>
                  <View style={styles.callDetails}>
                    <Icon name="map-marker" size={16} color={DarkThemeColors.muted} />
                    <Text style={styles.callLocation}>{call.location}</Text>
                  </View>
                </Card.Content>
                <Card.Actions style={styles.callCardActions}>
                  <Button 
                    mode="contained" 
                    style={styles.acceptButton}
                    contentStyle={styles.buttonContent}
                    labelStyle={styles.buttonLabel}
                    onPress={() => console.log("Accepted call", call.id)}
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
            ))
          ) : (
            <View style={styles.emptyState}>
              <Icon name="bell-off" size={50} color={DarkThemeColors.muted} />
              <Text style={styles.emptyStateText}>No pending calls at this time</Text>
            </View>
          )}
        </View>
        
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Nearby Requests</Text>
          <View style={styles.mapContainer}>
            <Text style={styles.mapPlaceholder}>Map will be displayed here</Text>
          </View>
        </View>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: DarkThemeColors.background,
  },
  appBar: {
    backgroundColor: DarkThemeColors.background,
    elevation: 2,
    borderBottomWidth: 1,
    borderBottomColor: DarkThemeColors.border,
  },
  appBarTitle: {
    color: DarkThemeColors.text,
    fontSize: 20,
    fontWeight: "600",
    letterSpacing: 0.5,
  },
  content: {
    flex: 1,
    padding: 20,
  },
  availabilityContainer: {
    alignItems: "center",
    marginVertical: 24,
  },
  toggleWrapper: {
    alignItems: 'center',
    justifyContent: 'center',
    marginVertical: 20,
  },
  toggleContainer: {
    width: 180,
    height: 180,
    borderRadius: 90,
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: "#000",
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.3,
    shadowRadius: 6,
    elevation: 10,
    backgroundColor: DarkThemeColors.unavailable,
  },
  toggleIcon: {
    marginBottom: 12,
  },
  toggleStatus: {
    color: DarkThemeColors.text,
    fontSize: 18,
    fontWeight: 'bold',
    letterSpacing: 1,
  },
  section: {
    marginBottom: 24,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: "bold",
    color: DarkThemeColors.text,
    marginBottom: 16,
    letterSpacing: 0.5,
  },
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
  mapContainer: {
    height: 200,
    backgroundColor: DarkThemeColors.card,
    borderRadius: 12,
    justifyContent: "center",
    alignItems: "center",
    overflow: "hidden",
    borderWidth: 1,
    borderColor: DarkThemeColors.border,
    borderStyle: "dashed",
  },
  mapPlaceholder: {
    fontSize: 16,
    color: DarkThemeColors.muted,
    letterSpacing: 0.5,
  },
});