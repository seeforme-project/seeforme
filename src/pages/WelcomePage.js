import React from "react";
import { View, StyleSheet, Text, TouchableOpacity } from "react-native";
import Icon from "react-native-vector-icons/MaterialCommunityIcons";

const WelcomePage = ({ navigation }) => {
  return (
    <View style={styles.container}>
      {/* Status Indicator */}
      <View style={styles.statusBar}>
        <Text style={styles.statusText}>CONNECTED</Text>
      </View>

      {/* Title Section */}
      <View style={styles.titleSection}>
        <Text style={styles.title}>See for Me</Text>
        <View style={styles.divider} />
        <Text style={styles.subtitle}>Vision Assistance App</Text>
        <View style={styles.labelContainer}>
          <Text style={styles.labelText}>BETA</Text>
        </View>
      </View>

      {/* Buttons */}
      <TouchableOpacity
        style={styles.volunteerButton} 
        onPress={() => navigation.navigate("VolunteerLogin")}
      >
        <Icon name="handshake" size={22} color="#FFFFFF" />
        <Text style={styles.buttonText}>I am Volunteer</Text>
      </TouchableOpacity>

      <View style={styles.separator}>
        <View style={styles.separatorLine} />
      </View>

      <TouchableOpacity
        style={styles.blindButton}
        onPress={() => {
          navigation.navigate("BlindLogin");
        }}
      >
        <Icon name="microphone" size={22} color="#FFFFFF" />
        <Text style={styles.buttonTextBlind}>say "I'm blind"</Text>
      </TouchableOpacity>

      {/* Footer */}
      <Text style={styles.footerText}>Begin your journey</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#111827", // Slightly blue-tinted dark background
    alignItems: "center",
    justifyContent: "center",
    paddingHorizontal: 20,
  },
  statusBar: {
    position: 'absolute',
    top: 40,
  },
  statusText: {
    color: '#6B7280',
    fontSize: 12,
    letterSpacing: 2,
    fontWeight: '600',
  },
  titleSection: {
    alignItems: "center",
    marginBottom: 60,
  },
  title: {
    fontSize: 38, // Slightly larger
    fontWeight: "bold",
    color: "#F3F4F6", // Slightly off-white for better contrast
    letterSpacing: 1,
  },
  divider: {
    width: 40,
    height: 2,
    backgroundColor: "#4B5563", // Lighter gray
    marginVertical: 15,
  },
  subtitle: {
    fontSize: 16,
    color: "#9CA3AF", // Warmer gray
    marginBottom: 15,
    letterSpacing: 0.5,
  },
  labelContainer: {
    marginTop: 12,
    backgroundColor: 'rgba(251, 191, 36, 0.1)', // Very subtle yellow background
    paddingVertical: 4,
    paddingHorizontal: 10,
    borderRadius: 12,
  },
  labelText: {
    color: '#FBBF24', // Warm yellow
    fontSize: 12,
    letterSpacing: 2,
    fontWeight: '600',
  },
  volunteerButton: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "#4F46E5", // Indigo color - more professional
    paddingVertical: 18,
    paddingHorizontal: 40,
    borderRadius: 30,
    marginBottom: 20,
    width: "85%",
  },
  buttonText: {
    color: "#FFFFFF",
    fontSize: 16,
    fontWeight: "500",
    marginLeft: 12,
    letterSpacing: 0.5,
  },
  separator: {
    width: "85%",
    marginBottom: 20,
  },
  separatorLine: {
    height: 1,
    backgroundColor: "#374151", // Darker gray for subtle separation
  },
  blindButton: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "#1F2937", // Slightly lighter than background
    paddingVertical: 18,
    paddingHorizontal: 40,
    borderRadius: 30,
    width: "85%",
    borderWidth: 1.5,
    borderColor: "#E5E7EB", // Slightly off-white border
  },
  buttonTextBlind: {
    color: "#F3F4F6", // Matching title color
    fontSize: 16,
    fontWeight: "500",
    marginLeft: 12,
    letterSpacing: 0.5,
  },
  footerText: {
    position: 'absolute',
    bottom: 40,
    color: "#6B7280", // Matching status text
    fontSize: 14,
    letterSpacing: 1,
  },
});

export default WelcomePage;