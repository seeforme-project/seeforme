import React, { useState } from "react";
import { View, StyleSheet, Text, TouchableOpacity, ScrollView, StatusBar } from "react-native";
import { Appbar, Button, Card, IconButton } from "react-native-paper";
import Icon from "react-native-vector-icons/MaterialCommunityIcons";

const LightThemeColors = {
  background: "#F9FAFB", // Off-white background
  card: "#FFFFFF", // White for card-like UI elements
  primary: "#5E60CE", // Purple for primary buttons and highlights
  text: "#212529", // Dark text
  muted: "#6C757D", // Muted text for secondary information
  border: "#E5E7EB", // Light gray for borders
  error: "#DC2626", // Red for errors
  available: "#22C55E", // Green for available status
  unavailable: "#9CA3AF", // Gray for unavailable status
  // Call card colors (light shades)
  callYellow: "#FFF9C4", // Light yellow
  callGreen: "#E8F5E9", // Light green
  callBlue: "#E3F2FD", // Light blue
  callRed: "#FFEBEE", // Light red
};

export default function VolunteerHomeScreen({ navigation }) {
  const [isAvailable, setIsAvailable] = useState(false);
  
  // Mock data for pending calls
  const pendingCalls = [
    {
      id: "1",
      userName: "John Smith",
      timeRequested: "5 minutes ago",
      location: "Downtown, City",
      color: LightThemeColors.callYellow,
    },
    {
      id: "2",
      userName: "Sarah Johnson",
      timeRequested: "15 minutes ago",
      location: "North Park, City",
      color: LightThemeColors.callGreen,
    },
    {
      id: "3",
      userName: "David Lee",
      timeRequested: "30 minutes ago",
      location: "West Mall, City",
      color: LightThemeColors.callBlue,
    },
    {
      id: "4",
      userName: "Emma Wilson",
      timeRequested: "45 minutes ago",
      location: "East Side, City",
      color: LightThemeColors.callRed,
    },
  ];

  const toggleAvailability = () => {
    setIsAvailable(!isAvailable);
  };

  return (
    <View style={styles.container}>
      <StatusBar backgroundColor={LightThemeColors.primary} barStyle="light-content" />
      
      {/* App Bar */}
      <Appbar.Header style={styles.appBar}>
        <Appbar.Content title="See for Me" subtitle="Volunteer Dashboard" />
        <Appbar.Action 
          icon="headset" 
          onPress={() => navigation.navigate("Support")} 
          color={LightThemeColors.card}
        />
      </Appbar.Header>
      
      <ScrollView style={styles.content}>
        {/* Availability Toggle Button */}
        <View style={styles.availabilityContainer}>
          <TouchableOpacity 
            style={[
              styles.availabilityButton, 
              { backgroundColor: isAvailable ? LightThemeColors.available : LightThemeColors.unavailable }
            ]} 
            onPress={toggleAvailability}
          >
            <Icon 
              name={isAvailable ? "check-circle" : "sleep"} 
              size={50} 
              color={LightThemeColors.card} 
            />
          </TouchableOpacity>
          <Text style={styles.availabilityText}>
            {isAvailable ? "I'm available" : "I'm unavailable"}
          </Text>
        </View>
        
        {/* Pending Calls Section */}
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
                    <Icon name="map-marker" size={16} color={LightThemeColors.muted} />
                    <Text style={styles.callLocation}>{call.location}</Text>
                  </View>
                </Card.Content>
                <Card.Actions style={styles.callCardActions}>
                  <Button 
                    mode="contained" 
                    style={styles.acceptButton}
                    labelStyle={{ color: LightThemeColors.card }}
                    onPress={() => console.log("Accepted call", call.id)}
                  >
                    Accept
                  </Button>
                  <Button 
                    mode="outlined"
                    style={styles.declineButton}
                    labelStyle={{ color: LightThemeColors.muted }}
                    onPress={() => console.log("Declined call", call.id)}
                  >
                    Decline
                  </Button>
                </Card.Actions>
              </Card>
            ))
          ) : (
            <View style={styles.emptyState}>
              <Icon name="bell-off" size={50} color={LightThemeColors.muted} />
              <Text style={styles.emptyStateText}>No pending calls at this time</Text>
            </View>
          )}
        </View>
        
        {/* Map Container (Placeholder) */}
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
    backgroundColor: LightThemeColors.background,
  },
  appBar: {
    backgroundColor: LightThemeColors.primary,
    elevation: 4,
  },
  content: {
    flex: 1,
    padding: 16,
  },
  availabilityContainer: {
    alignItems: "center",
    marginVertical: 24,
  },
  availabilityButton: {
    width: 120,
    height: 120,
    borderRadius: 60,
    justifyContent: "center",
    alignItems: "center",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.2,
    shadowRadius: 5,
    elevation: 5,
  },
  availabilityText: {
    marginTop: 12,
    fontSize: 18,
    fontWeight: "bold",
    color: LightThemeColors.text,
  },
  section: {
    marginBottom: 24,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: "bold",
    color: LightThemeColors.text,
    marginBottom: 12,
  },
  callCard: {
    marginBottom: 12,
    borderRadius: 12,
    overflow: "hidden",
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
    color: LightThemeColors.text,
  },
  callTime: {
    fontSize: 12,
    color: LightThemeColors.muted,
  },
  callDetails: {
    flexDirection: "row",
    alignItems: "center",
  },
  callLocation: {
    fontSize: 14,
    color: LightThemeColors.muted,
    marginLeft: 4,
  },
  callCardActions: {
    justifyContent: "flex-end",
    paddingTop: 8,
  },
  acceptButton: {
    backgroundColor: LightThemeColors.primary,
    marginRight: 8,
  },
  declineButton: {
    borderColor: LightThemeColors.muted,
  },
  emptyState: {
    alignItems: "center",
    justifyContent: "center",
    padding: 32,
    backgroundColor: LightThemeColors.card,
    borderRadius: 12,
  },
  emptyStateText: {
    marginTop: 12,
    fontSize: 16,
    color: LightThemeColors.muted,
    textAlign: "center",
  },
  mapContainer: {
    height: 200,
    backgroundColor: LightThemeColors.card,
    borderRadius: 12,
    justifyContent: "center",
    alignItems: "center",
    overflow: "hidden",
    borderWidth: 1,
    borderColor: LightThemeColors.border,
    borderStyle: "dashed",
  },
  mapPlaceholder: {
    fontSize: 16,
    color: LightThemeColors.muted,
  },
});