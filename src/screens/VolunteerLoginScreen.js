import React, { useState } from "react";
import { View, StyleSheet, Text, TouchableOpacity } from "react-native";
import { TextInput, Button } from "react-native-paper";
import AsyncStorage from "@react-native-async-storage/async-storage";

import { BASE_URL } from "../../Config";

const LightThemeColors = {
  background: "#F9FAFB", // Off-white background
  card: "#FFFFFF", // White for card-like UI elements
  primary: "#5E60CE", // Purple for primary buttons and highlights
  text: "#212529", // Dark text
  muted: "#6C757D", // Muted text for secondary information
  border: "#E5E7EB", // Light gray for borders
  error: "#DC2626", // Red for errors
};

export default function VolunteerLoginScreen({ navigation }) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [errorMessage, setErrorMessage] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  const handleLogin = async () => {
    // Basic validation
    if (!email) {
      setErrorMessage("Email is required");
      return;
    }

    if (!password) {
      setErrorMessage("Password is required");
      return;
    }

    // Reset errors
    setErrorMessage("");
    setIsLoading(true);

    try {
      // Call API endpoint
      const response = await fetch( BASE_URL + "/api/login/", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          email,
          password,
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        // Handle error responses
        setErrorMessage(data.error || "Login failed. Please try again.");
        return;
      }

    // Check if account_type is 'volunteer'
    if (data.user && data.user.account_type !== 'volunteer') {
      setErrorMessage(`Cannot continue as a volunteer. Your account type is '${data.user.account_type}'.`);
      return;
    }

      // Store tokens in AsyncStorage
      await AsyncStorage.setItem("access_token", data.access_token);
      await AsyncStorage.setItem("refresh_token", data.refresh_token);
      await AsyncStorage.setItem("user_data", JSON.stringify(data.user));

      // Navigate to success page
      navigation.navigate("VolunteerHome");
    } catch (error) {
      console.error("Login error:", error);
      setErrorMessage("Network error. Please check your connection.");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.logoContainer}>
        <Text style={styles.logoText}>See for Me</Text>
        <View style={styles.divider} />
        <Text style={styles.subtitle}>Vision Assistance App</Text>
      </View>

      <View style={styles.formContainer}>
        <Text style={styles.formTitle}>Volunteer Login</Text>

        <TextInput
          label="Email"
          mode="outlined"
          value={email}
          onChangeText={(text) => {
            setEmail(text);
            setErrorMessage("");
          }}
          style={styles.input}
          outlineColor={LightThemeColors.border}
          activeOutlineColor={LightThemeColors.primary}
          keyboardType="email-address"
          autoCapitalize="none"
        />

        <TextInput
          label="Password"
          mode="outlined"
          value={password}
          onChangeText={(text) => {
            setPassword(text);
            setErrorMessage("");
          }}
          secureTextEntry={!showPassword}
          style={styles.input}
          outlineColor={LightThemeColors.border}
          activeOutlineColor={LightThemeColors.primary}
          right={
            <TextInput.Icon
              icon={showPassword ? "eye-off" : "eye"}
              color={LightThemeColors.muted}
              onPress={() => setShowPassword(!showPassword)}
            />
          }
        />

        {errorMessage ? (
          <Text style={styles.errorText}>{errorMessage}</Text>
        ) : null}

        <TouchableOpacity style={styles.forgotPassword}>
          <Text style={styles.forgotPasswordText}>Forgot password?</Text>
        </TouchableOpacity>

        <Button
          mode="contained"
          onPress={handleLogin}
          style={styles.loginButton}
          buttonColor={LightThemeColors.primary}
          labelStyle={{ color: LightThemeColors.card }}
          loading={isLoading}
          disabled={isLoading}
        >
          Login
        </Button>

        <View style={styles.orContainer}>
          <View style={styles.orLine} />
          <Text style={styles.orText}>OR</Text>
          <View style={styles.orLine} />
        </View>

        <Button
          mode="outlined"
          onPress={() => navigation.navigate("VolunteerSignUp")}
          style={styles.signupButton}
          labelStyle={{ color: LightThemeColors.primary }}
        >
          Create an Account
        </Button>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: LightThemeColors.background,
    paddingHorizontal: 20,
    justifyContent: "center",
  },
  logoContainer: {
    alignItems: "center",
    marginBottom: 30,
  },
  logoText: {
    fontSize: 28,
    fontWeight: "bold",
    color: LightThemeColors.text,
    textShadowColor: LightThemeColors.primary,
    textShadowOffset: { width: 0, height: 0 },
    textShadowRadius: 10,
  },
  divider: {
    width: 50,
    height: 2,
    backgroundColor: LightThemeColors.primary,
    marginVertical: 10,
  },
  subtitle: {
    fontSize: 16,
    color: LightThemeColors.muted,
  },
  formContainer: {
    backgroundColor: LightThemeColors.card,
    borderRadius: 15,
    padding: 20,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  formTitle: {
    fontSize: 20,
    fontWeight: "bold",
    color: LightThemeColors.text,
    marginBottom: 20,
    textAlign: "center",
  },
  input: {
    marginBottom: 16,
    backgroundColor: LightThemeColors.card,
  },
  forgotPassword: {
    alignSelf: "flex-end",
    marginBottom: 20,
  },
  forgotPasswordText: {
    color: LightThemeColors.primary,
    fontSize: 14,
  },
  loginButton: {
    paddingVertical: 6,
    borderRadius: 25,
  },
  orContainer: {
    flexDirection: "row",
    alignItems: "center",
    marginVertical: 20,
  },
  orLine: {
    flex: 1,
    height: 1,
    backgroundColor: LightThemeColors.border,
  },
  orText: {
    color: LightThemeColors.muted,
    marginHorizontal: 10,
    fontSize: 14,
  },
  signupButton: {
    borderColor: LightThemeColors.primary,
    borderRadius: 25,
  },
  errorText: {
    color: LightThemeColors.error,
    fontSize: 12,
    marginBottom: 10,
  },
});