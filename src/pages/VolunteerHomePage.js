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
import IncomingCallsList from "../WebRTCSystem/IncomingCallsList"; // Import the new component
import { defaultWebRTCSystem } from "../WebRTCSystem/WebRTCSystem"; // Import the actual WebRTC system

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
  
  // Simply use the imported WebRTC system
  const webRTCSystem = defaultWebRTCSystem;

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
          
          {/* Use the IncomingCallsList component with the actual WebRTC system */}
          <IncomingCallsList webRTCSystem={webRTCSystem} />
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