import React, { useRef, useEffect, useState } from "react";
import { View, StyleSheet, Text, StatusBar, Animated, Easing } from "react-native";
import Icon from "react-native-vector-icons/MaterialCommunityIcons";
import { GestureHandlerRootView, PanGestureHandler, State } from "react-native-gesture-handler";

export default function BlindHomeScreen({ navigation }) {
  // Animation value for scaling the microphone
  const scaleAnim = useRef(new Animated.Value(1)).current;
  // Animation value for opacity pulse
  const opacityAnim = useRef(new Animated.Value(0.6)).current;
  
  // State to track swipe-down gestures
  const [lastSwipeTime, setLastSwipeTime] = useState(0);
  const [swipeCount, setSwipeCount] = useState(0);

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

  // Separate function to handle double swipe-down detection
  const handleDoubleSwipeDown = () => {
    const currentTime = new Date().getTime();
    
    // Reset count if the time between swipes is more than 1 second
    if (currentTime - lastSwipeTime > 1000) {
      setSwipeCount(1); // Reset to 1 (counting this swipe)
    } else {
      // Increment the swipe count
      const newCount = swipeCount + 1;
      setSwipeCount(newCount);
      
      // Check if we've reached 2 swipes
      if (newCount >= 2) {
        // Navigate back
        navigation.goBack();
        // Reset the counter
        setSwipeCount(0);
      }
    }
    
    // Update the last swipe time
    setLastSwipeTime(currentTime);
  };

  // Handle the gesture event
  const onGestureEvent = (event) => {
    // Check if it's a swipe down (positive y translation)
    if (event.nativeEvent.translationY > 50) {
      handleDoubleSwipeDown();
    }
  };

  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <PanGestureHandler
        onHandlerStateChange={({ nativeEvent }) => {
          if (nativeEvent.state === State.END) {
            // Only process completed gestures
            if (nativeEvent.translationY > 50) {
              handleDoubleSwipeDown();
            }
          }
        }}
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
            To exit, swipe-down two times.
            {swipeCount === 1 ? " (1 swipe detected)" : ""}
          </Text>
        </View>
      </PanGestureHandler>
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