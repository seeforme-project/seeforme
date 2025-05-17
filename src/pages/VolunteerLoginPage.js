import React, { useState } from "react";
import { 
  View, 
  StyleSheet, 
  Text, 
  TouchableOpacity, 
  KeyboardAvoidingView, 
  ScrollView, 
  Platform 
} from "react-native";
import { TextInput, Button } from "react-native-paper";
import AsyncStorage from "@react-native-async-storage/async-storage";

import { BASE_URL } from "../../Config";
import { getUserIdFromToken, saveLoggedInUserId } from "../utils/JWTUtils";

const DarkThemeColors = {
  background: "#111827", // Dark blue-tinted background
  primary: "#4F46E5", // Indigo for primary actions
  text: "#F3F4F6", // Off-white text
  muted: "#9CA3AF", // Muted text
  border: "#374151", // Border color
  error: "#EF4444", // Bright red for errors
  yellow: "#FBBF24", // Yellow for accents
};

const theme = {
  colors: {
    text: DarkThemeColors.text,
    placeholder: DarkThemeColors.muted,
    primary: DarkThemeColors.primary,
    background: DarkThemeColors.background,
    surface: DarkThemeColors.background,
    onSurface: DarkThemeColors.text,
    onSurfaceVariant: DarkThemeColors.text,
    surfaceVariant: DarkThemeColors.background,
  },
  roundness: 30,
};

export default function VolunteerLoginPage({ navigation }) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [errorMessage, setErrorMessage] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  const handleLogin = async () => {
    if (!email) {
      setErrorMessage("Email is required");
      return;
    }

    if (!password) {
      setErrorMessage("Password is required");
      return;
    }

    setErrorMessage("");
    setIsLoading(true);

    try {
      const response = await fetch(BASE_URL + "/api/login/", {
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
        setErrorMessage(data.error || "Login failed. Please try again.");
        return;
      }

      if (data.user && data.user.account_type !== 'volunteer') {
        setErrorMessage(`Cannot continue as a volunteer. Your account type is '${data.user.account_type}'.`);
        return;
      }

      await AsyncStorage.setItem("access_token", data.access_token);
      await AsyncStorage.setItem("refresh_token", data.refresh_token);
      await AsyncStorage.setItem("user_data", JSON.stringify(data.user));

      const userId = await getUserIdFromToken();
      if (userId) {
        await saveLoggedInUserId(userId);
      } else {
        console.error("Failed to retrieve user ID from token");
      }

      navigation.navigate("VolunteerHome");
    } catch (error) {
      console.error("Login error:", error);
      setErrorMessage("Network error. Please check your connection.");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView 
      behavior={Platform.OS === "ios" ? "padding" : "height"}
      style={styles.container}
      keyboardVerticalOffset={Platform.OS === "ios" ? 64 : 0}
    >
      <ScrollView 
        contentContainerStyle={styles.scrollContainer}
        showsVerticalScrollIndicator={false}
        bounces={false}
      >
        {/* Status Bar */}
        <View style={styles.statusBar}>
          <Text style={styles.statusText}>Welcome</Text>
        </View>

        <View style={styles.logoContainer}>
          <Text style={styles.logoText}>See for Me</Text>
          <View style={styles.divider} />
          <Text style={styles.subtitle}>Vision Assistance App</Text>
          <View style={styles.labelContainer}>
            <Text style={styles.labelText}>BETA</Text>
          </View>
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
            style={[styles.input, { color: DarkThemeColors.text }]}
            outlineColor={DarkThemeColors.border}
            activeOutlineColor={DarkThemeColors.primary}
            keyboardType="email-address"
            autoCapitalize="none"
            textColor={DarkThemeColors.text}
            theme={theme}
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
            style={[styles.input, { color: DarkThemeColors.text }]}
            outlineColor={DarkThemeColors.border}
            activeOutlineColor={DarkThemeColors.primary}
            textColor={DarkThemeColors.text}
            theme={theme}
            right={
              <TextInput.Icon
                icon={showPassword ? "eye-off" : "eye"}
                color={DarkThemeColors.muted}
                onPress={() => setShowPassword(!showPassword)}
              />
            }
          />

          {errorMessage ? (
            <Text style={styles.errorText}>{errorMessage}</Text>
          ) : null}

          <Button
            mode="contained"
            onPress={handleLogin}
            style={styles.loginButton}
            buttonColor={DarkThemeColors.primary}
            contentStyle={styles.buttonContent}
            labelStyle={styles.buttonLabel}
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
            labelStyle={styles.outlineButtonLabel}
            theme={{
              colors: {
                outline: DarkThemeColors.text,
              },
            }}
          >
            Create an Account
          </Button>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: DarkThemeColors.background,
  },
  scrollContainer: {
    flexGrow: 1,
    paddingHorizontal: 20,
    paddingBottom: 20, // Add padding at the bottom
  },
  statusBar: {
    marginTop: 40,
    alignSelf: 'center',
    alignItems: 'center',
  },
  statusText: {
    color: DarkThemeColors.muted,
    fontSize: 12,
    letterSpacing: 2,
    fontWeight: '600',
  },
  userText: {
    color: DarkThemeColors.muted,
    fontSize: 12,
    marginTop: 4,
    letterSpacing: 1,
  },
  logoContainer: {
    alignItems: "center",
    marginTop: 60, // Reduced from 100
    marginBottom: 40, // Reduced from 50
  },
  logoText: {
    fontSize: 38,
    fontWeight: "bold",
    color: DarkThemeColors.text,
    letterSpacing: 1,
  },
  divider: {
    width: 40,
    height: 2,
    backgroundColor: DarkThemeColors.border,
    marginVertical: 15,
  },
  subtitle: {
    fontSize: 16,
    color: DarkThemeColors.muted,
    marginBottom: 15,
    letterSpacing: 0.5,
  },
  labelContainer: {
    marginTop: 12,
    backgroundColor: 'rgba(251, 191, 36, 0.1)',
    paddingVertical: 4,
    paddingHorizontal: 10,
    borderRadius: 12,
  },
  labelText: {
    color: DarkThemeColors.yellow,
    fontSize: 12,
    letterSpacing: 2,
    fontWeight: '600',
  },
  formContainer: {
    width: '100%',
    paddingHorizontal: 20,
  },
  formTitle: {
    fontSize: 24,
    fontWeight: "bold",
    color: DarkThemeColors.text,
    marginBottom: 24,
    textAlign: "center",
  },
  input: {
    marginBottom: 16,
    backgroundColor: DarkThemeColors.background,
    borderRadius: 30,
  },
  loginButton: {
    borderRadius: 30,
    marginTop: 8,
    height: 50,
  },
  buttonContent: {
    height: 50,
    paddingVertical: 0,
  },
  buttonLabel: {
    color: DarkThemeColors.text,
    fontSize: 16,
    letterSpacing: 0.5,
    lineHeight: 20,
  },
  outlineButtonLabel: {
    color: DarkThemeColors.text,
    fontSize: 16,
    letterSpacing: 0.5,
  },
  orContainer: {
    flexDirection: "row",
    alignItems: "center",
    marginVertical: 24,
  },
  orLine: {
    flex: 1,
    height: 1,
    backgroundColor: DarkThemeColors.border,
  },
  orText: {
    color: DarkThemeColors.muted,
    marginHorizontal: 16,
    fontSize: 14,
    letterSpacing: 1,
  },
  signupButton: {
    borderColor: DarkThemeColors.text,
    borderRadius: 30,
    borderWidth: 1.5,
  },
  errorText: {
    color: DarkThemeColors.error,
    fontSize: 13,
    marginBottom: 12,
    textAlign: 'center',
  },
});