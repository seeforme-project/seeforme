import React from "react";
import { NavigationContainer } from "@react-navigation/native";
import { createStackNavigator } from "@react-navigation/stack";
import WelcomeScreen from "./src/screens/WelcomeScreen"; // Ensure this file exists
import VolunteerSignUpScreen from "./src/screens/VolunteerSignupScreen"; // Ensure this file exists
import LoginScreen from "./src/screens/LoginScreen"; // Add the new login screen
import SuccessPage from "./src/screens/SuccessPage"; // Add the success page

const Stack = createStackNavigator();

export default function App() {
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
        <Stack.Screen name="Login" component={LoginScreen} />
        <Stack.Screen name="SuccessPage" component={SuccessPage} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
