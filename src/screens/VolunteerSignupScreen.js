import React, { useState } from "react";
import {
  View,
  ScrollView,
  StyleSheet,
  Text,
  TouchableOpacity,
} from "react-native";
import { TextInput, Button, Chip } from "react-native-paper";
import Icon from "react-native-vector-icons/MaterialCommunityIcons";

const LightThemeColors = {
  background: "#F9FAFB", // Off-white background
  card: "#FFFFFF", // White for card-like UI elements
  primary: "#5E60CE", // Purple for primary buttons and highlights
  text: "#212529", // Dark text
  muted: "#6C757D", // Muted text for secondary information
  border: "#E5E7EB", // Light gray for borders
  infoBackground: "#F8F9FA", // Slightly darker off-white for info box
};

export default function VolunteerSignupScreen({ navigation }) {
  const [currentStep, setCurrentStep] = useState(0);
  const [phone, setPhone] = useState("");
  const [email, setEmail] = useState("");
  const [fullName, setFullName] = useState("");
  const [age, setAge] = useState("");
  const [password, setPassword] = useState("");

  // Schedule state
  const [selectedDays, setSelectedDays] = useState({
    Mon: {
      selected: false,
      timeSlots: [{ startTime: "09:00", endTime: "17:00" }],
    },
    Tue: {
      selected: false,
      timeSlots: [{ startTime: "09:00", endTime: "17:00" }],
    },
    Wed: {
      selected: false,
      timeSlots: [{ startTime: "09:00", endTime: "17:00" }],
    },
    Thu: {
      selected: false,
      timeSlots: [{ startTime: "09:00", endTime: "17:00" }],
    },
    Fri: {
      selected: false,
      timeSlots: [{ startTime: "09:00", endTime: "17:00" }],
    },
    Sat: {
      selected: false,
      timeSlots: [{ startTime: "09:00", endTime: "17:00" }],
    },
    Sun: {
      selected: false,
      timeSlots: [{ startTime: "09:00", endTime: "17:00" }],
    },
  });

  const toggleDay = (day) => {
    setSelectedDays((prev) => ({
      ...prev,
      [day]: {
        ...prev[day],
        selected: !prev[day].selected,
      },
    }));
  };

  const updateTime = (day, slotIndex, field, value) => {
    setSelectedDays((prev) => {
      const updatedDay = { ...prev[day] };
      updatedDay.timeSlots[slotIndex][field] = value;
      return { ...prev, [day]: updatedDay };
    });
  };

  const addTimeSlot = (day) => {
    setSelectedDays((prev) => {
      const updatedDay = { ...prev[day] };
      updatedDay.timeSlots.push({ startTime: "09:00", endTime: "17:00" });
      return { ...prev, [day]: updatedDay };
    });
  };

  const removeTimeSlot = (day, slotIndex) => {
    setSelectedDays((prev) => {
      const updatedDay = { ...prev[day] };
      if (updatedDay.timeSlots.length > 1) {
        updatedDay.timeSlots = updatedDay.timeSlots.filter(
          (_, index) => index !== slotIndex
        );
      }
      return { ...prev, [day]: updatedDay };
    });
  };

  const handleCompleteSignup = () => {
    // Log form data
    console.log("Full Name:", fullName);
    console.log("Age:", age);
    console.log("Phone:", phone);
    console.log("Email:", email);
    console.log("Password:", password);
    console.log("Schedule:", selectedDays);

    // Navigate to Login screen after signup
    navigation.navigate("Login");
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
              Let others know who their helper is.
            </Text>
            <TextInput
              label="Full Name"
              mode="outlined"
              value={fullName}
              onChangeText={setFullName}
              style={styles.input}
              outlineColor={LightThemeColors.border}
              activeOutlineColor={LightThemeColors.primary}
            />
            <TextInput
              label="Age"
              mode="outlined"
              value={age}
              onChangeText={setAge}
              keyboardType="numeric"
              style={styles.input}
              outlineColor={LightThemeColors.border}
              activeOutlineColor={LightThemeColors.primary}
            />
          </View>
        );
      case 1:
        return (
          <View>
            <View style={styles.sectionHeader}>
              <Icon
                name="account-box"
                size={24}
                color={LightThemeColors.primary}
              />
              <Text style={styles.stepTitle}>Contact Information</Text>
            </View>
            <Text style={styles.stepSubtitle}>
              We'll use these details to connect you with people who need
              assistance.
            </Text>
            <TextInput
              label="Phone Number"
              mode="outlined"
              value={phone}
              onChangeText={setPhone}
              keyboardType="phone-pad"
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
            <View style={styles.infoBox}>
              <Icon
                name="shield-check"
                size={16}
                color={LightThemeColors.primary}
              />
              <Text style={styles.infoText}>
                Your contact information is secure and will only be shared with
                verified users.
              </Text>
            </View>
          </View>
        );
      case 2:
        return (
          <View>
            <View style={styles.sectionHeader}>
              <Icon
                name="clock-outline"
                size={24}
                color={LightThemeColors.primary}
              />
              <Text style={styles.stepTitle}>Availability Schedule</Text>
            </View>
            <Text style={styles.stepSubtitle}>
              Select the days you're available and specify your time slots.
            </Text>

            {/* Day selection chips */}
            <View style={styles.daysContainer}>
              {Object.keys(selectedDays).map((day) => (
                <Chip
                  key={day}
                  selected={selectedDays[day].selected}
                  onPress={() => toggleDay(day)}
                  style={[
                    styles.dayChip,
                    selectedDays[day].selected && styles.selectedDayChip,
                  ]}
                  textStyle={{
                    color: selectedDays[day].selected
                      ? LightThemeColors.card
                      : LightThemeColors.primary,
                  }}
                  mode={selectedDays[day].selected ? "flat" : "outlined"}
                  selectedColor={
                    selectedDays[day].selected
                      ? LightThemeColors.card
                      : LightThemeColors.primary
                  }
                >
                  {day}
                </Chip>
              ))}
            </View>

            {/* Time slots for selected days */}
            <View style={styles.selectedDaysContainer}>
              {Object.keys(selectedDays).map(
                (day) =>
                  selectedDays[day].selected && (
                    <View key={day} style={styles.dayScheduleContainer}>
                      <Text style={styles.dayScheduleTitle}>{day}</Text>

                      {selectedDays[day].timeSlots.map((slot, index) => (
                        <View key={index} style={styles.timeSlotContainer}>
                          <View style={styles.timeInputsRow}>
                            <View style={styles.timeInput}>
                              <Text style={styles.timeLabel}>Start</Text>
                              <TextInput
                                mode="outlined"
                                value={slot.startTime}
                                onChangeText={(value) =>
                                  updateTime(day, index, "startTime", value)
                                }
                                style={styles.timeTextInput}
                                outlineColor={LightThemeColors.border}
                                activeOutlineColor={LightThemeColors.primary}
                                dense
                              />
                            </View>

                            <Text style={styles.timeToText}>to</Text>

                            <View style={styles.timeInput}>
                              <Text style={styles.timeLabel}>End</Text>
                              <TextInput
                                mode="outlined"
                                value={slot.endTime}
                                onChangeText={(value) =>
                                  updateTime(day, index, "endTime", value)
                                }
                                style={styles.timeTextInput}
                                outlineColor={LightThemeColors.border}
                                activeOutlineColor={LightThemeColors.primary}
                                dense
                              />
                            </View>

                            {selectedDays[day].timeSlots.length > 1 && (
                              <TouchableOpacity
                                onPress={() => removeTimeSlot(day, index)}
                                style={styles.removeButton}
                              >
                                <Icon
                                  name="minus-circle"
                                  size={22}
                                  color={LightThemeColors.muted}
                                />
                              </TouchableOpacity>
                            )}
                          </View>
                        </View>
                      ))}

                      <TouchableOpacity
                        onPress={() => addTimeSlot(day)}
                        style={styles.addSlotButton}
                      >
                        <Icon
                          name="plus"
                          size={16}
                          color={LightThemeColors.primary}
                        />
                        <Text style={styles.addSlotText}>
                          Add another time slot
                        </Text>
                      </TouchableOpacity>
                    </View>
                  )
              )}
            </View>

            {Object.values(selectedDays).every((day) => !day.selected) && (
              <View style={styles.noSelectionContainer}>
                <Icon
                  name="calendar-clock"
                  size={40}
                  color={LightThemeColors.muted}
                />
                <Text style={styles.noSelectionText}>
                  Please select days you're available to help
                </Text>
              </View>
            )}
          </View>
        );
      default:
        return null;
    }
  };

  const renderStepIndicator = () => (
    <View style={styles.stepIndicator}>
      {["Personal", "Contact", "Schedule"].map((label, index) => (
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

  return (
    <View style={styles.container}>
      <Text style={styles.header}>Volunteer Signup</Text>
      {renderStepIndicator()}
      <ScrollView contentContainerStyle={styles.scrollContainer}>
        {renderStepContent()}
      </ScrollView>
      <View style={styles.navigationContainer}>
        <Button
          mode="outlined"
          onPress={() => setCurrentStep((prev) => Math.max(prev - 1, 0))}
          disabled={currentStep === 0}
          style={styles.navigationButton}
          labelStyle={{ color: LightThemeColors.primary }}
        >
          Back
        </Button>
        <Button
          mode="contained"
          onPress={() => {
            if (currentStep < 2) {
              setCurrentStep((prev) => prev + 1);
            } else {
              // Complete the signup process and navigate to Login
              handleCompleteSignup();
            }
          }}
          style={styles.navigationButton}
          buttonColor={LightThemeColors.primary}
          labelStyle={{ color: LightThemeColors.card }}
        >
          {currentStep === 2 ? "Start Helping" : "Next"}
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
  },
  navigationButton: {
    flex: 1,
    marginHorizontal: 5,
  },
  // Styles for schedule selection
  daysContainer: {
    flexDirection: "row",
    flexWrap: "wrap",
    marginBottom: 20,
  },
  dayChip: {
    margin: 4,
  },
  selectedDayChip: {
    backgroundColor: LightThemeColors.primary,
  },
  selectedDaysContainer: {
    marginTop: 10,
  },
  dayScheduleContainer: {
    marginBottom: 20,
    padding: 12,
    backgroundColor: LightThemeColors.card,
    borderRadius: 10,
    borderLeftWidth: 3,
    borderLeftColor: LightThemeColors.primary,
  },
  dayScheduleTitle: {
    fontSize: 16,
    fontWeight: "600",
    color: LightThemeColors.text,
    marginBottom: 12,
  },
  timeSlotContainer: {
    marginBottom: 10,
  },
  timeInputsRow: {
    flexDirection: "row",
    alignItems: "center",
  },
  timeInput: {
    flex: 1,
  },
  timeTextInput: {
    height: 40,
    backgroundColor: LightThemeColors.card,
  },
  timeLabel: {
    fontSize: 12,
    color: LightThemeColors.muted,
    marginBottom: 4,
  },
  timeToText: {
    marginHorizontal: 12,
    color: LightThemeColors.muted,
  },
  addSlotButton: {
    flexDirection: "row",
    alignItems: "center",
    marginTop: 8,
  },
  addSlotText: {
    color: LightThemeColors.primary,
    marginLeft: 5,
    fontSize: 14,
  },
  removeButton: {
    marginLeft: 10,
    alignSelf: "center",
    padding: 4,
  },
  noSelectionContainer: {
    alignItems: "center",
    justifyContent: "center",
    padding: 40,
    backgroundColor: LightThemeColors.infoBackground,
    borderRadius: 10,
  },
  noSelectionText: {
    color: LightThemeColors.muted,
    marginTop: 10,
    textAlign: "center",
  },
});
