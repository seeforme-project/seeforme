import React, { useEffect, useState, useRef } from "react";
import { NavigationContainer } from "@react-navigation/native";
import { createStackNavigator } from "@react-navigation/stack";
import WelcomeScreen from "./src/screens/WelcomeScreen";
import VolunteerSignUpScreen from "./src/screens/VolunteerSignupScreen";
import VolunteerLoginScreen from "./src/screens/VolunteerLoginScreen";
import BlindSignUpScreen from "./src/screens/BlindSignupScreen";
import BlindLoginScreen from "./src/screens/BlindLoginScreen";
import SuccessPage from "./src/screens/SuccessPage";
import VolunteerHomeScreen from "./src/screens/VolunteerHomeScreen";
import BlindHomeScreen from "./src/screens/BlindHomeScreen";

// Import required notification packages
import * as Notifications from 'expo-notifications';
import * as Device from 'expo-device';
import Constants from 'expo-constants';






import { scheduleLocalNotification } from "./src/NotificationService/NotificationService";


// Configure how notifications appear when the app is in foreground
Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: true,
    shouldSetBadge: true,
  }),
});

const Stack = createStackNavigator();

export default function App() {
  const [expoPushToken, setExpoPushToken] = useState('');
  const [notification, setNotification] = useState(null);
  const notificationListener = useRef();
  const responseListener = useRef();

  useEffect(() => {
    // Function to register for push notifications
    const registerForPushNotificationsAsync = async () => {
      let token;
      
      if (Device.isDevice) {
        const { status: existingStatus } = await Notifications.getPermissionsAsync();
        let finalStatus = existingStatus;
        
        if (existingStatus !== 'granted') {
          const { status } = await Notifications.requestPermissionsAsync();
          finalStatus = status;
        }
        
        if (finalStatus !== 'granted') {
          console.log('Failed to get push token for push notification!');
          return;
        }
        
        // Get the Expo push token
        token = (await Notifications.getExpoPushTokenAsync({
          projectId: Constants.expoConfig?.extra?.eas?.projectId,
        })).data;
        
        console.log('Expo Push Token:', token);
        setExpoPushToken(token);
        
        // Here you would typically send this token to your backend
        // sendTokenToBackend(token);
      } else {
        console.log('Must use physical device for Push Notifications');
      }
    };

    // Register for notifications
    registerForPushNotificationsAsync();

    // Set up notification listeners
    // This listener is called when a notification is received while the app is foregrounded
    notificationListener.current = Notifications.addNotificationReceivedListener(notification => {
      setNotification(notification);
      console.log('Notification received:', notification);
    });

    // This listener is called when a user taps on or interacts with a notification
    responseListener.current = Notifications.addNotificationResponseReceivedListener(response => {
      const { notification } = response;
      console.log('Notification response received:', notification);
      
      // Handle navigation based on notification data if needed
      // For example:
      // const data = notification.request.content.data;
      // if (data.screen) {
      //   navigation.navigate(data.screen);
      // }
    });

    // Clean up the listeners on unmount
    return () => {
      Notifications.removeNotificationSubscription(notificationListener.current);
      Notifications.removeNotificationSubscription(responseListener.current);
    };
  }, []);



  return (
    <NavigationContainer>
      <Stack.Navigator
        initialRouteName="WelcomeScreen"
        screenOptions={{ headerShown: false }}
      >
        <Stack.Screen name="WelcomeScreen" component={WelcomeScreen} />
        <Stack.Screen
          name="VolunteerSignUp"
          component={VolunteerSignUpScreen}
        />
        <Stack.Screen name="VolunteerLogin" component={VolunteerLoginScreen} />
        <Stack.Screen
          name="BlindSignUp"
          component={BlindSignUpScreen}
        />
        <Stack.Screen name="BlindLogin" component={BlindLoginScreen} />
        <Stack.Screen name="SuccessPage" component={SuccessPage} />
        <Stack.Screen
          name="VolunteerHome"
          component={VolunteerHomeScreen}
        />
        <Stack.Screen
          name="BlindHome"
          component={BlindHomeScreen}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
}