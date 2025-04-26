import * as Device from 'expo-device';
import * as Notifications from 'expo-notifications';
import Constants from 'expo-constants';
import { Platform } from 'react-native';

// Configure notification behavior (you can also do this in App.js)
Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: true,
    shouldSetBadge: true,
  }),
});

// Request permission and get Expo push token
export const registerForPushNotificationsAsync = async (projectId) => {
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
      return null;
    }
    
    // Use the provided projectId
    token = (await Notifications.getExpoPushTokenAsync({
      projectId: projectId,  // Use the passed projectId
    })).data;
    
    console.log('Expo Push Token:', token);
  } else {
    console.log('Must use physical device for Push Notifications');
  }

  if (Platform.OS === 'android') {
    Notifications.setNotificationChannelAsync('default', {
      name: 'default',
      importance: Notifications.AndroidImportance.MAX,
      vibrationPattern: [0, 250, 250, 250],
      lightColor: '#FF231F7C',
    });
  }

  return token;
};

// Schedule a local notification (useful for testing)
export const scheduleLocalNotification = async (title, body, data = {}) => {
  await Notifications.scheduleNotificationAsync({
    content: {
      title,
      body,
      data,
    },
    trigger: null, // null means send immediately
  });
};

// Add notification listeners
export const addNotificationListeners = (onReceive, onResponse) => {
  const receivedListener = Notifications.addNotificationReceivedListener(
    onReceive || (notification => console.log('Notification received:', notification))
  );

  const responseListener = Notifications.addNotificationResponseReceivedListener(
    onResponse || (response => console.log('Notification response:', response))
  );

  return {
    receivedListener,
    responseListener,
    remove: () => {
      Notifications.removeNotificationSubscription(receivedListener);
      Notifications.removeNotificationSubscription(responseListener);
    }
  };
};

// Get the last received notification
export const getLastNotificationResponse = async () => {
  return await Notifications.getLastNotificationResponseAsync();
};

// Dismiss all notifications
export const dismissAllNotifications = async () => {
  await Notifications.dismissAllNotificationsAsync();
};






















import { api } from '../../Config';


// Add this function to send current logged in user's token to Django
export const sendTokenToBackend = async (projectId) => {
  try {
    if (!projectId) {
      throw new Error('Project ID is required. Please provide your Expo project ID.');
    }

    // Get the token using the existing function with projectId
    const token = await registerForPushNotificationsAsync(projectId);
    
    if (!token) {
      throw new Error('Failed to get push notification token');
    }

    // api is axios instance - axios doesn't have .ok property
    // and doesn't need .json() call
    const response = await api.post('/api/register-notification-token/', {
      token: token,
      device_type: Platform.OS,
    });
    
    // axios response data is already parsed
    console.log('Token registered successfully:', response.data);
    return response.data;
  } catch (error) {
    console.error('Error registering token:', error);
    throw error;
  }
};