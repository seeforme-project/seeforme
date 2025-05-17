import React from "react";
import { View, StyleSheet, Text, TouchableOpacity } from "react-native";
import { Button } from "react-native-paper";
import Icon from "react-native-vector-icons/MaterialCommunityIcons";

const LightThemeColors = {
  background: "#F9FAFB", // Off-white background
  card: "#FFFFFF", // White for card-like UI elements
  primary: "#5E60CE", // Purple for primary buttons and highlights
  text: "#212529", // Dark text
  muted: "#6C757D", // Muted text for secondary information
  success: "#10B981", // Green for success
};

export default function SuccessPage({ navigation }) {
  return (
    <View style={styles.container}>
      <View style={styles.card}>
        <Icon name="check-circle" size={80} color={LightThemeColors.success} />
        <Text style={styles.title}>Logged In Successfully!</Text>
        <Text style={styles.subtitle}>
          Welcome to See for Me. You are now ready to help those in need.
        </Text>
        <Button
          mode="contained"
          onPress={() => navigation.navigate("WelcomeScreen")}
          style={styles.button}
          buttonColor={LightThemeColors.primary}
          labelStyle={{ color: LightThemeColors.card }}
        >
          Back to Home
        </Button>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: LightThemeColors.background,
    justifyContent: "center",
    alignItems: "center",
    padding: 20,
  },
  card: {
    backgroundColor: LightThemeColors.card,
    borderRadius: 15,
    padding: 30,
    width: "100%",
    maxWidth: 400,
    alignItems: "center",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  title: {
    fontSize: 24,
    fontWeight: "bold",
    color: LightThemeColors.text,
    marginTop: 20,
    marginBottom: 10,
    textAlign: "center",
  },
  subtitle: {
    fontSize: 16,
    color: LightThemeColors.muted,
    marginBottom: 30,
    textAlign: "center",
    lineHeight: 24,
  },
  button: {
    paddingVertical: 6,
    borderRadius: 25,
    width: "100%",
  },
});
