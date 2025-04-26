import React from "react";
import { NavigationContainer } from "@react-navigation/native";
import { createStackNavigator } from "@react-navigation/stack";
import WelcomeScreen from "./src/screens/WelcomeScreen"; // Ensure this file exists

import VolunteerSignUpScreen from "./src/screens/VolunteerSignupScreen"; // Ensure this file exists
import VolunteerLoginScreen from "./src/screens/VolunteerLoginScreen"; // Add the new login screen

import BlindSignUpScreen from "./src/screens/BlindSignupScreen"; // Ensure this file exists
import BlindLoginScreen from "./src/screens/BlindLoginScreen"; // Add the new login screen


import SuccessPage from "./src/screens/SuccessPage"; // Add the success page

import VolunteerHomeScreen from "./src/screens/VolunteerHomeScreen";
import BlindHomeScreen from "./src/screens/BlindHomeScreen";

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
