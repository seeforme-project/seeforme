import React from "react";
import { View, StyleSheet, Text, TouchableOpacity } from "react-native";
import Icon from "react-native-vector-icons/MaterialCommunityIcons";

const WelcomeScreen = ({ navigation }) => {
  return (
    <View style={styles.container}>
      {/* Title Section */}
      <View style={styles.titleSection}>
        <Text style={styles.title}>See for Me</Text>
        <View style={styles.divider} />
        <Text style={styles.subtitle}>Vision Assistance App</Text>
      </View>

      {/* Buttons */}
      <TouchableOpacity
        style={styles.volunteerButton}
        onPress={() => navigation.navigate("VolunteerLogin")} // Navigate to Login page directly now
      >
        <Icon name="handshake" size={20} color="#FFFFFF" />
        <Text style={styles.buttonText}>I am Volunteer</Text>
      </TouchableOpacity>

      <View style={styles.separator}>
        <Icon
          name="star"
          size={16}
          color="#6C757D"
          style={styles.separatorIcon}
        />
        <View style={styles.separatorLine} />
      </View>

      <TouchableOpacity
        style={styles.blindButton}
        onPress={() => {
          // ALSO LISTEN TO VOICE COMMAND AS WELL.
          navigation.navigate("BlindLogin");
        }}
      >
        <Icon name="microphone" size={20} color="#5E60CE" />
        <Text style={styles.buttonTextBlind}>say "I'm blind"</Text>
      </TouchableOpacity>

      {/* Login Button */}
      

      {/* Footer Text */}
      <Text style={styles.footerText}>Begin your journey</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#F9FAFB", // Light background color
    alignItems: "center",
    justifyContent: "center", // Center content vertically
    paddingHorizontal: 20,
    paddingVertical: 30,
  },
  titleSection: {
    alignItems: "center",
    marginBottom: 40,
  },
  title: {
    fontSize: 32,
    fontWeight: "bold",
    color: "#212529",
    textShadowColor: "#5E60CE",
    textShadowOffset: { width: 0, height: 0 },
    textShadowRadius: 10,
  },
  divider: {
    width: 50,
    height: 2,
    backgroundColor: "#5E60CE",
    marginVertical: 10,
  },
  subtitle: {
    fontSize: 16,
    color: "#6C757D",
  },
  volunteerButton: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "#5E60CE",
    paddingVertical: 15,
    paddingHorizontal: 40,
    borderRadius: 25,
    marginBottom: 20,
    width: "80%",
  },
  buttonText: {
    color: "#FFFFFF",
    fontSize: 16,
    fontWeight: "600",
    marginLeft: 10,
  },
  separator: {
    flexDirection: "row",
    alignItems: "center",
    marginBottom: 20,
    width: "80%",
  },
  separatorLine: {
    flex: 1,
    height: 1,
    backgroundColor: "#6C757D",
    marginLeft: 10,
  },
  separatorIcon: {
    marginRight: 10,
  },
  blindButton: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "#E9ECEF",
    paddingVertical: 15,
    paddingHorizontal: 40,
    borderRadius: 25,
    width: "80%",
  },
  buttonTextBlind: {
    color: "#5E60CE",
    fontSize: 16,
    fontWeight: "600",
    marginLeft: 10,
  },
  loginButton: {
    flexDirection: "row",
    alignItems: "center",
    marginTop: 30,
    paddingVertical: 10,
  },
  loginText: {
    color: "#5E60CE",
    fontSize: 14,
    marginLeft: 5,
    textDecorationLine: "underline",
  },
  footerText: {
    marginTop: 40,
    fontSize: 14,
    color: "#6C757D",
  },
});

export default WelcomeScreen;
