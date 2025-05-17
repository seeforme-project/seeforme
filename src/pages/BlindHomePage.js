import React from "react";
import { View, StyleSheet, Text, Alert } from "react-native";
import Icon from "react-native-vector-icons/MaterialCommunityIcons";
import { 
  GestureHandlerRootView,
  GestureDetector,
  Gesture
} from "react-native-gesture-handler";
import { runOnJS } from 'react-native-reanimated';

export default function BlindHomePage({ navigation }) {
  // Helper functions to be called from worklets
  const showAIAlert = () => {
    Alert.alert("Info", "AI not implemented");
  };

  const showDoubleTapAlert = () => {
    Alert.alert("Info", "Screen is double tapped");
  };

  const navigateBack = () => {
    navigation.goBack();
  };

  // Create a gesture for swipes
  const swipeGesture = Gesture.Pan()
    .onEnd((event) => {
      'worklet';
      // Check for swipe up
      if (event.velocityY < -50) {
        runOnJS(showAIAlert)();
      }
      // Check for swipe down (with threshold)
      if (event.velocityY > 50 && event.translationY > 100) {
        runOnJS(navigateBack)();
      }
    });

  // Create a gesture for double tap
  const doubleTapGesture = Gesture.Tap()
    .numberOfTaps(2)
    .onEnd(() => {
      'worklet';
      runOnJS(showDoubleTapAlert)();
    });

  // Combine both gestures
  const gesture = Gesture.Simultaneous(swipeGesture, doubleTapGesture);

  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <GestureDetector gesture={gesture}>
        <View style={styles.container}>
          <Text style={styles.title}>Voice Interface for Visually Impaired</Text>
          
          <View style={styles.iconContainer}>
            <Icon name="microphone-outline" size={64} color="#8A7EF8" />
          </View>

          <View style={styles.commandsContainer}>
            <Text style={styles.commandText}>> Swipe up to talk with AI</Text>
            <Text style={styles.commandText}>> Double tap for volunteer</Text>
            <Text style={styles.commandText}>> Swipe down twice to exit</Text>
          </View>
        </View>
      </GestureDetector>
    </GestureHandlerRootView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#000000",
    justifyContent: "center",
    alignItems: "center",
    padding: 20,
  },
  title: {
    color: "#8A7EF8",
    fontSize: 20,
    fontFamily: "monospace",
    marginBottom: 50,
    textAlign: "center",
  },
  iconContainer: {
    marginVertical: 40,
  },
  commandsContainer: {
    alignSelf: "stretch",
    paddingHorizontal: 20,
  },
  commandText: {
    color: "#ffffff",
    fontSize: 18,
    fontFamily: "monospace",
    marginBottom: 20,
    opacity: 0.9,
  },
});