import React, { useRef, useEffect, useState } from "react";
import { View, StyleSheet, Text, StatusBar, Animated, Easing } from "react-native";
import Icon from "react-native-vector-icons/MaterialCommunityIcons";
import { GestureHandlerRootView, TapGestureHandler, State } from "react-native-gesture-handler";
import AsyncStorage from "@react-native-async-storage/async-storage";

import { api } from '../../Config';



export default function BlindHomeScreen({ navigation }) {
  // Animation value for scaling the microphone
  const scaleAnim = useRef(new Animated.Value(1)).current;
  // Animation value for opacity pulse
  const opacityAnim = useRef(new Animated.Value(0.6)).current;
  
  // State to track double tap
  const doubleTapRef = useRef(null);
  const [lastTapTime, setLastTapTime] = useState(0);









// send notification to user_id 1 on double tap to screen
function foo(){
  const testNotificationToUser = async () => {
    try {
      const response = await api.post('/api/send-push-notification/', {
        user_id: 1,
        title: 'Test Notification',
        message: `Test notification sent by mujtaba-io at ${new Date().toISOString()}`,
        data: {
          timestamp: new Date().toISOString(),
          sender: 'mujtaba-io'
        }
      });
  
      console.log('Notification sent:', response.data);
      return response.data;
    } catch (error) {
      // Enhanced error logging for better debugging
      console.error('Failed to send notification:', {
        message: error.message,
        response: error.response?.data,
        status: error.response?.status
      });
      throw error;
    }
  };
  
  // Call the function to send a test notification
  testNotificationToUser()
    .then(result => {
      console.log('Notification sent successfully:', result);
    })
    .catch(error => {
      console.error('Error sending notification:', error);
    });

}














  useEffect(() => {
    // Create scaling animation
    const scaleAnimation = Animated.sequence([
      Animated.timing(scaleAnim, {
        toValue: 1.3,
        duration: 800,
        useNativeDriver: true,
        easing: Easing.out(Easing.ease),
      }),
      Animated.timing(scaleAnim, {
        toValue: 1,
        duration: 800,
        useNativeDriver: true,
        easing: Easing.in(Easing.ease),
      }),
    ]);

    // Create opacity pulse animation
    const opacityAnimation = Animated.sequence([
      Animated.timing(opacityAnim, {
        toValue: 1,
        duration: 800,
        useNativeDriver: true,
        easing: Easing.out(Easing.ease),
      }),
      Animated.timing(opacityAnim, {
        toValue: 0.6,
        duration: 800,
        useNativeDriver: true,
        easing: Easing.in(Easing.ease),
      }),
    ]);

    // Run both animations in parallel and loop them
    Animated.loop(
      Animated.parallel([scaleAnimation, opacityAnimation])
    ).start();

    return () => {
      // Clean up animations when component unmounts
      scaleAnim.stopAnimation();
      opacityAnim.stopAnimation();
    };
  }, []);

  const onSingleTapEvent = ({ nativeEvent }) => {
    if (nativeEvent.state === State.ACTIVE) {
      const now = Date.now();
      const DOUBLE_TAP_DELAY = 300; // 300ms between taps

      if (now - lastTapTime < DOUBLE_TAP_DELAY) {
        // Double tap detected
        foo(); // Call the foo() function
      }
      
      setLastTapTime(now);
    }
  };


  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <TapGestureHandler
        onHandlerStateChange={onSingleTapEvent}
        ref={doubleTapRef}
      >
        <View style={styles.container}>
          <StatusBar backgroundColor="#000000" barStyle="light-content" />
          
          <Text style={styles.instructionText}>
            Say 'See for Me'!
          </Text>
          
          {/* Animated Microphone Icon */}
          <View style={styles.iconContainer}>
            <Animated.View
              style={[
                styles.pulseCircle,
                {
                  opacity: opacityAnim,
                  transform: [{ scale: scaleAnim }],
                },
              ]}
            />
            <Icon name="microphone" size={80} color="#FFFFFF" style={styles.micIcon} />
          </View>
          
          <Text style={styles.exitText}>
            Double tap anywhere on the screen.
          </Text>
        </View>
      </TapGestureHandler>
    </GestureHandlerRootView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#000000",
    justifyContent: "center",
    alignItems: "center",
    padding: 30,
  },
  instructionText: {
    color: "#FFFFFF",
    fontSize: 28,
    fontWeight: "bold",
    textAlign: "center",
    marginBottom: 60,
  },
  exitText: {
    color: "#FFFFFF",
    fontSize: 18,
    fontWeight: "bold",
    textAlign: "center",
    marginTop: 60,
  },
  iconContainer: {
    justifyContent: "center",
    alignItems: "center",
    height: 120,
    width: 120,
  },
  micIcon: {
    position: "absolute",
  },
  pulseCircle: {
    position: "absolute",
    width: 120,
    height: 120,
    borderRadius: 60,
    backgroundColor: "rgba(255, 255, 255, 0.2)",
  },
});