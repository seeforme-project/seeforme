import React, { useState } from "react";
import {
  View,
  ScrollView,
  StyleSheet,
  Text,
  TouchableOpacity,
  Alert,
} from "react-native";
import { TextInput, Button, Appbar } from "react-native-paper";
import Icon from "react-native-vector-icons/MaterialCommunityIcons";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { BASE_URL } from "../../Config";

const DarkThemeColors = {
  background: "#111827",
  primary: "#4F46E5",
  secondary: "#8B5CF6",
  accent: "#F59E0B",
  info: "#3B82F6",
  text: "#F3F4F6",
  muted: "#9CA3AF",
  border: "#374151",
  error: "#EF4444",
  cardBg: "#1F2937",
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

const OutlinedCard = ({ iconName, title, description, color = DarkThemeColors.primary }) => (
  <View style={[styles.outlinedCard, { borderColor: color }]}>
    <Icon name={iconName} size={24} color={color} style={styles.cardIcon} />
    <View style={styles.cardContent}>
      <Text style={[styles.cardTitle, { color }]}>{title}</Text>
      <Text style={styles.cardDescription}>{description}</Text>
    </View>
  </View>
);

export default function VolunteerSignupPage({ navigation }) {
  const [currentStep, setCurrentStep] = useState(0);
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [errorMessage, setErrorMessage] = useState("");

  const validateFirstStep = () => {
    if (!name.trim()) {
      Alert.alert("Error", "Please enter your name");
      return false;
    }
    if (!email.trim()) {
      Alert.alert("Error", "Please enter your email");
      return false;
    }
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
      const response = await fetch(`${BASE_URL}/api/signup/`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          name,
          email,
          password,
          account_type: "volunteer",
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || "Failed to create account");
      }

      await AsyncStorage.setItem("access_token", data.access_token);
      await AsyncStorage.setItem("refresh_token", data.refresh_token);

      Alert.alert(
        "Success",
        "Your account has been created successfully!",
        [
          {
            text: "OK",
            onPress: () => navigation.navigate("VolunteerLogin"),
          },
        ]
      );
    } catch (error) {
      Alert.alert("Error", error.message);
      setErrorMessage(error.message);
    } finally {
      setLoading(false);
    }
  };

  const renderStepContent = () => {
    switch (currentStep) {
      case 0:
        return (
          <View style={styles.stepContent}>
            <OutlinedCard
              iconName="account-details"
              title="Personal Information"
              description="We use this information to create your volunteer profile and verify your identity."
              color={DarkThemeColors.info}
            />
            
            <TextInput
              label="Full Name"
              mode="outlined"
              value={name}
              onChangeText={(text) => {
                setName(text);
                setErrorMessage("");
              }}
              style={styles.input}
              outlineColor={DarkThemeColors.border}
              activeOutlineColor={DarkThemeColors.info}
              textColor={DarkThemeColors.text}
              theme={theme}
              left={<TextInput.Icon icon="account" color={DarkThemeColors.muted} />}
            />

            <OutlinedCard
              iconName="email-check"
              title="Contact Details"
              description="Your email will be used for account verification and important communications."
              color={DarkThemeColors.secondary}
            />

            <TextInput
              label="Email Address"
              mode="outlined"
              value={email}
              onChangeText={(text) => {
                setEmail(text);
                setErrorMessage("");
              }}
              keyboardType="email-address"
              style={styles.input}
              outlineColor={DarkThemeColors.border}
              activeOutlineColor={DarkThemeColors.secondary}
              textColor={DarkThemeColors.text}
              theme={theme}
              autoCapitalize="none"
              left={<TextInput.Icon icon="email" color={DarkThemeColors.muted} />}
            />
            
            {errorMessage ? (
              <Text style={styles.errorText}>{errorMessage}</Text>
            ) : null}
          </View>
        );
      case 1:
        return (
          <View style={styles.stepContent}>
            <OutlinedCard
              iconName="shield-lock"
              title="Account Security"
              description="Create a strong password that includes letters, numbers, and special characters for better security."
              color={DarkThemeColors.accent}
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
              outlineColor={DarkThemeColors.border}
              activeOutlineColor={DarkThemeColors.accent}
              textColor={DarkThemeColors.text}
              theme={theme}
              left={<TextInput.Icon icon="lock" color={DarkThemeColors.muted} />}
              right={
                <TextInput.Icon
                  icon={showPassword ? "eye-off" : "eye"}
                  color={DarkThemeColors.muted}
                  onPress={() => setShowPassword(!showPassword)}
                />
              }
            />

            <TextInput
              label="Confirm Password"
              mode="outlined"
              value={confirmPassword}
              onChangeText={(text) => {
                setConfirmPassword(text);
                setErrorMessage("");
              }}
              secureTextEntry={!showConfirmPassword}
              style={styles.input}
              outlineColor={DarkThemeColors.border}
              activeOutlineColor={DarkThemeColors.accent}
              textColor={DarkThemeColors.text}
              theme={theme}
              left={<TextInput.Icon icon="lock-check" color={DarkThemeColors.muted} />}
              right={
                <TextInput.Icon
                  icon={showConfirmPassword ? "eye-off" : "eye"}
                  color={DarkThemeColors.muted}
                  onPress={() => setShowConfirmPassword(!showConfirmPassword)}
                />
              }
            />
            
            {errorMessage ? (
              <Text style={styles.errorText}>{errorMessage}</Text>
            ) : null}
          </View>
        );
      case 2:
        return (
          <View style={styles.stepContent}>
            <OutlinedCard
              iconName="checkbox-marked-circle"
              title="Ready to Join"
              description="Review your information before creating your volunteer account. Thank you for choosing to make a difference."
              color={DarkThemeColors.primary}
            />
            
            <View style={styles.summaryCard}>
              <Icon 
                name="account-check" 
                size={60} 
                color={DarkThemeColors.primary} 
                style={styles.confirmIcon}
              />
              <Text style={styles.confirmText}>Account Review</Text>
              <Text style={styles.confirmSubtext}>
                Press 'Create Account' to complete your registration
              </Text>
            </View>
            
            {errorMessage ? (
              <Text style={styles.errorText}>{errorMessage}</Text>
            ) : null}
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
              <Icon name="check" size={20} color={DarkThemeColors.text} />
            ) : (
              <Text style={{
                color: currentStep >= index ? DarkThemeColors.text : DarkThemeColors.muted,
              }}>
                {index + 1}
              </Text>
            )}
          </View>
          <Text style={[
            styles.stepLabel,
            currentStep >= index && styles.activeStepLabel,
          ]}>
            {label}
          </Text>
          {index < 2 && (
            <View style={[
              styles.stepLine,
              currentStep > index && styles.activeStepLine
            ]} />
          )}
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
      <Appbar.Header style={styles.appBar}>
        <Appbar.BackAction 
          onPress={() => navigation.goBack()} 
          color={DarkThemeColors.text} 
        />
        <Appbar.Content 
          title="Volunteer Registration" 
          subtitle="Join our community of helpers"
          titleStyle={styles.appBarTitle}
          subtitleStyle={styles.appBarSubtitle}
        />
      </Appbar.Header>

      <ScrollView 
        contentContainerStyle={styles.scrollContainer}
        showsVerticalScrollIndicator={false}
      >
        {renderStepIndicator()}
        {renderStepContent()}
      </ScrollView>

      <View style={styles.navigationContainer}>
        <Button
          mode="outlined"
          onPress={() => setCurrentStep((prev) => Math.max(prev - 1, 0))}
          disabled={currentStep === 0 || loading}
          style={[styles.navigationButton, styles.backButton]}
          labelStyle={styles.buttonLabel}
          theme={theme}
        >
          Back
        </Button>
        <Button
          mode="contained"
          onPress={handleNextStep}
          style={[styles.navigationButton, styles.nextButton]}
          buttonColor={DarkThemeColors.primary}
          labelStyle={styles.buttonLabel}
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
    backgroundColor: DarkThemeColors.background,
  },
  appBar: {
    backgroundColor: DarkThemeColors.background,
    elevation: 0,
    borderBottomWidth: 1,
    borderBottomColor: DarkThemeColors.border,
  },
  appBarTitle: {
    color: DarkThemeColors.text,
    fontSize: 20,
    fontWeight: "bold",
  },
  appBarSubtitle: {
    color: DarkThemeColors.muted,
    fontSize: 14,
  },
  scrollContainer: {
    padding: 20,
    paddingBottom: 100,
  },
  outlinedCard: {
    borderWidth: 1,
    borderRadius: 12,
    padding: 16,
    marginBottom: 20,
    flexDirection: 'row',
    alignItems: 'flex-start',
    backgroundColor: DarkThemeColors.cardBg,
  },
  cardIcon: {
    marginRight: 12,
    marginTop: 2,
  },
  cardContent: {
    flex: 1,
  },
  cardTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    marginBottom: 4,
  },
  cardDescription: {
    fontSize: 14,
    color: DarkThemeColors.muted,
    lineHeight: 20,
  },
  stepIndicator: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 30,
    paddingHorizontal: 10,
  },
  stepContainer: {
    flexDirection: "row",
    alignItems: "center",
    flex: 1,
  },
  stepCircle: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: DarkThemeColors.cardBg,
    justifyContent: "center",
    alignItems: "center",
    borderWidth: 2,
    borderColor: DarkThemeColors.border,
  },
  activeStep: {
    backgroundColor: DarkThemeColors.primary,
    borderColor: DarkThemeColors.primary,
  },
  stepLabel: {
    fontSize: 12,
    color: DarkThemeColors.muted,
    marginLeft: 8,
  },
  activeStepLabel: {
    color: DarkThemeColors.text,
  },
  stepLine: {
    flex: 1,
    height: 2,
    backgroundColor: DarkThemeColors.border,
    marginHorizontal: 4,
  },
  activeStepLine: {
    backgroundColor: DarkThemeColors.primary,
  },
  stepContent: {
    marginBottom: 20,
  },
  input: {
    marginBottom: 24,
    backgroundColor: DarkThemeColors.background,
    borderRadius: 30,
  },
  summaryCard: {
    alignItems: 'center',
    padding: 24,
    backgroundColor: DarkThemeColors.cardBg,
    borderRadius: 12,
    marginTop: 20,
  },
  confirmIcon: {
    marginBottom: 16,
  },
  confirmText: {
    fontSize: 20,
    fontWeight: 'bold',
    color: DarkThemeColors.text,
    textAlign: 'center',
    marginBottom: 8,
  },
  confirmSubtext: {
    fontSize: 14,
    color: DarkThemeColors.muted,
    textAlign: 'center',
    lineHeight: 20,
  },
  navigationContainer: {
    flexDirection: "row",
    justifyContent: "space-between",
    padding: 20,
    backgroundColor: DarkThemeColors.background,
    borderTopWidth: 1,
    borderColor: DarkThemeColors.border,
    position: "absolute",
    bottom: 0,
    left: 0,
    right: 0,
  },
  navigationButton: {
    flex: 1,
    marginHorizontal: 5,
    borderRadius: 30,
    height: 50,
  },
  buttonLabel: {
    fontSize: 16,
    color: DarkThemeColors.text,
  },
  backButton: {
    borderColor: DarkThemeColors.text,
    borderWidth: 1.5,
  },
  nextButton: {
    elevation: 0,
  },
  errorText: {
    color: DarkThemeColors.error,
    fontSize: 13,
    marginVertical: 8,
    textAlign: 'center',
  },
});