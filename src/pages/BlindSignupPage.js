import React, { useState } from "react";
import {
  View,
  ScrollView,
  StyleSheet,
  Text,
  TouchableOpacity,
  Alert,
} from "react-native";
import { TextInput, Button } from "react-native-paper";
import Icon from "react-native-vector-icons/MaterialCommunityIcons";

import AsyncStorage from "@react-native-async-storage/async-storage";


import { BASE_URL } from "../../Config";


const LightThemeColors = {
  background: "#F9FAFB", // Off-white background
  card: "#FFFFFF", // White for card-like UI elements
  primary: "#5E60CE", // Purple for primary buttons and highlights
  text: "#212529", // Dark text
  muted: "#6C757D", // Muted text for secondary information
  border: "#E5E7EB", // Light gray for borders
  infoBackground: "#F8F9FA", // Slightly darker off-white for info box
};

export default function BlindSignupPage({ navigation }) {
  const [currentStep, setCurrentStep] = useState(0);
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [loading, setLoading] = useState(false);

  const validateFirstStep = () => {
    if (!name.trim()) {
      Alert.alert("Error", "Please enter your name");
      return false;
    }
    if (!email.trim()) {
      Alert.alert("Error", "Please enter your email");
      return false;
    }
    // Basic email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      Alert.alert("Error", "Please enter a valid email address");
      return false;
    }
    return true;
  };

  const validateSecondStep = () => {
    if (!password) {
      Alert.alert("Error", "Please enter a password");
      return false;
    }
    if (password.length < 8) {
      Alert.alert("Error", "Password must be at least 8 characters long");
      return false;
    }
    if (password !== confirmPassword) {
      Alert.alert("Error", "Passwords do not match");
      return false;
    }
    return true;
  };

  const handleSignup = async () => {
    setLoading(true);
    try {
      const response = await fetch(BASE_URL + "/api/signup/", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          name,
          email,
          password,
          account_type: "blind",
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || "Failed to create account");
      }

      // Handle successful signup
      console.log("Signup successful:", data);
      
      // Store tokens
      AsyncStorage.setItem('access_token', data.access_token);
      AsyncStorage.setItem('refresh_token', data.refresh_token);
      
      // Navigate to Login screen after signup
      Alert.alert(
        "Success",
        "Your account has been created successfully!",
        [
          {
            text: "OK",
            onPress: () => navigation.navigate("BlindLogin"),
          },
        ]
      );
    } catch (error) {
      Alert.alert("Error", error.message);
    } finally {
      setLoading(false);
    }
  };

  const renderStepContent = () => {
    switch (currentStep) {
      case 0:
        return (
          <View>
            <View style={styles.sectionHeader}>
              <Icon
                name="account-circle"
                size={24}
                color={LightThemeColors.primary}
              />
              <Text style={styles.stepTitle}>Personal Details</Text>
            </View>
            <Text style={styles.stepSubtitle}>
              Let's start with your basic information.
            </Text>
            <TextInput
              label="Full Name"
              mode="outlined"
              value={name}
              onChangeText={setName}
              style={styles.input}
              outlineColor={LightThemeColors.border}
              activeOutlineColor={LightThemeColors.primary}
            />
            <TextInput
              label="Email"
              mode="outlined"
              value={email}
              onChangeText={setEmail}
              keyboardType="email-address"
              style={styles.input}
              outlineColor={LightThemeColors.border}
              activeOutlineColor={LightThemeColors.primary}
            />
            <View style={styles.infoBox}>
              <Icon
                name="information-outline"
                size={16}
                color={LightThemeColors.primary}
              />
              <Text style={styles.infoText}>
                We'll use your email for account verification and important updates.
              </Text>
            </View>
          </View>
        );
      case 1:
        return (
          <View>
            <View style={styles.sectionHeader}>
              <Icon
                name="shield-lock"
                size={24}
                color={LightThemeColors.primary}
              />
              <Text style={styles.stepTitle}>Secure Your Account</Text>
            </View>
            <Text style={styles.stepSubtitle}>
              Create a strong password to protect your account.
            </Text>
            <TextInput
              label="Password"
              mode="outlined"
              value={password}
              onChangeText={setPassword}
              secureTextEntry={true}
              style={styles.input}
              outlineColor={LightThemeColors.border}
              activeOutlineColor={LightThemeColors.primary}
            />
            <TextInput
              label="Confirm Password"
              mode="outlined"
              value={confirmPassword}
              onChangeText={setConfirmPassword}
              secureTextEntry={true}
              style={styles.input}
              outlineColor={LightThemeColors.border}
              activeOutlineColor={LightThemeColors.primary}
            />
            <View style={styles.infoBox}>
              <Icon
                name="shield-check"
                size={16}
                color={LightThemeColors.primary}
              />
              <Text style={styles.infoText}>
                Your password should be at least 8 characters long for better security.
              </Text>
            </View>
          </View>
        );
      case 2:
        return (
          <View style={styles.finalStepContainer}>
            <Icon
              name="check-circle-outline"
              size={60}
              color={LightThemeColors.primary}
            />
            <Text style={styles.finalStepTitle}>Almost Done!</Text>
            <Text style={styles.finalStepText}>
              By continuing, your account will be created.
            </Text>
            <Text style={styles.finalStepSubText}>
              You'll be able to sign in using your email and password.
            </Text>
          </View>
        );
      default:
        return null;
    }
  };

  const renderStepIndicator = () => (
    <View style={styles.stepIndicator}>
      {["Account", "Security", "Confirm"].map((label, index) => (
        <View key={index} style={styles.stepContainer}>
          <View
            style={[
              styles.stepCircle,
              currentStep >= index && styles.activeStep,
            ]}
          >
            {currentStep > index ? (
              <Icon name="check" size={20} color={LightThemeColors.card} />
            ) : (
              <Text
                style={{
                  color:
                    currentStep >= index
                      ? LightThemeColors.card
                      : LightThemeColors.muted,
                }}
              >
                {index + 1}
              </Text>
            )}
          </View>
          <Text
            style={[
              styles.stepLabel,
              currentStep >= index && styles.activeStepLabel,
            ]}
          >
            {label}
          </Text>
          {index < 2 && <View style={styles.stepLine} />}
        </View>
      ))}
    </View>
  );

  const handleNextStep = () => {
    if (currentStep === 0) {
      if (validateFirstStep()) {
        setCurrentStep(1);
      }
    } else if (currentStep === 1) {
      if (validateSecondStep()) {
        setCurrentStep(2);
      }
    } else if (currentStep === 2) {
      handleSignup();
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.header}>Create Blind Account</Text>
      {renderStepIndicator()}
      <ScrollView contentContainerStyle={styles.scrollContainer}>
        {renderStepContent()}
      </ScrollView>
      <View style={styles.navigationContainer}>
        <Button
          mode="outlined"
          onPress={() => setCurrentStep((prev) => Math.max(prev - 1, 0))}
          disabled={currentStep === 0 || loading}
          style={styles.navigationButton}
          labelStyle={{ color: LightThemeColors.primary }}
        >
          Back
        </Button>
        <Button
          mode="contained"
          onPress={handleNextStep}
          style={styles.navigationButton}
          buttonColor={LightThemeColors.primary}
          labelStyle={{ color: LightThemeColors.card }}
          loading={loading}
          disabled={loading}
        >
          {currentStep === 2 ? "Create Account" : "Next"}
        </Button>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: LightThemeColors.background,
  },
  header: {
    fontSize: 20,
    fontWeight: "bold",
    color: LightThemeColors.text,
    textAlign: "center",
    marginVertical: 20,
  },
  stepIndicator: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 20,
  },
  stepContainer: {
    flexDirection: "row",
    alignItems: "center",
  },
  stepCircle: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: LightThemeColors.muted,
    justifyContent: "center",
    alignItems: "center",
  },
  activeStep: {
    backgroundColor: LightThemeColors.primary,
  },
  stepLabel: {
    fontSize: 12,
    color: LightThemeColors.muted,
    marginTop: 5,
    textAlign: "center",
  },
  activeStepLabel: {
    color: LightThemeColors.primary,
  },
  stepLine: {
    width: 40,
    height: 2,
    backgroundColor: LightThemeColors.muted,
    marginHorizontal: 10,
  },
  scrollContainer: {
    padding: 20,
    paddingBottom: 100, // Add extra padding at the bottom
  },
  sectionHeader: {
    flexDirection: "row",
    alignItems: "center",
    marginBottom: 10,
  },
  stepTitle: {
    fontSize: 18,
    fontWeight: "bold",
    color: LightThemeColors.text,
    marginLeft: 8,
  },
  stepSubtitle: {
    fontSize: 14,
    color: LightThemeColors.muted,
    marginBottom: 20,
  },
  input: {
    marginBottom: 16,
    backgroundColor: LightThemeColors.card,
  },
  infoBox: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: LightThemeColors.infoBackground,
    padding: 10,
    borderRadius: 8,
    marginTop: 10,
  },
  infoText: {
    fontSize: 12,
    color: LightThemeColors.muted,
    marginLeft: 8,
  },
  navigationContainer: {
    flexDirection: "row",
    justifyContent: "space-between",
    padding: 20,
    backgroundColor: LightThemeColors.background,
    borderTopWidth: 1,
    borderColor: LightThemeColors.border,
    position: "absolute",
    bottom: 0,
    left: 0,
    right: 0,
  },
  navigationButton: {
    flex: 1,
    marginHorizontal: 5,
  },
  finalStepContainer: {
    alignItems: "center",
    justifyContent: "center",
    padding: 30,
    backgroundColor: LightThemeColors.card,
    borderRadius: 10,
    marginTop: 20,
  },
  finalStepTitle: {
    fontSize: 22,
    fontWeight: "bold",
    color: LightThemeColors.text,
    marginTop: 20,
    marginBottom: 10,
  },
  finalStepText: {
    fontSize: 16,
    color: LightThemeColors.text,
    textAlign: "center",
    marginBottom: 10,
  },
  finalStepSubText: {
    fontSize: 14,
    color: LightThemeColors.muted,
    textAlign: "center",
  },
});