import 'react-native-gesture-handler'; // must be at the top
import { GestureHandlerRootView } from 'react-native-gesture-handler';



import React from "react";
import { StatusBar } from "react-native";
import { NavigationContainer } from "@react-navigation/native";
import { createStackNavigator } from "@react-navigation/stack";


import { SIGNALING_SERVER_URL } from './Config';


import WelcomePage from "./src/pages/WelcomePage";
import VolunteerSignUpPage from "./src/pages/VolunteerSignupPage";
import VolunteerLoginPage from "./src/pages/VolunteerLoginPage";
import BlindSignUpPage from "./src/pages/BlindSignupPage";
import BlindLoginPage from "./src/pages/BlindLoginPage";
import SuccessPage from "./src/pages/SuccessPage";
import VolunteerHomePage from "./src/pages/VolunteerHomePage";
import BlindHomePage from "./src/pages/BlindHomePage";


import VideoCallPage from './src/WebRTCSystem/VideoCallPage';
import { defaultWebRTCSystem } from './src/WebRTCSystem/WebRTCSystem';




import {PermissionsAndroid, Platform} from 'react-native';
async function requestPermissions() {
  if (Platform.OS === 'android') {
    await PermissionsAndroid.requestMultiple([
      PermissionsAndroid.PERMISSIONS.CAMERA,
      PermissionsAndroid.PERMISSIONS.RECORD_AUDIO,
    ]);
  }
}





const Stack = createStackNavigator();

export default function App() {
  // Request permissions for camera and microphone
  React.useEffect(() => {
    requestPermissions();
  }, []);

  React.useEffect(() => {
    defaultWebRTCSystem.initialize(SIGNALING_SERVER_URL);
  }, []);


  return (
      <GestureHandlerRootView style={{ flex: 1 }}>
      <NavigationContainer>




        <Stack.Navigator
          initialRouteName="WelcomePage"
          screenOptions={{ headerShown: false }}>

          <Stack.Screen name="WelcomePage" component={WelcomePage} />
          <Stack.Screen
            name="VolunteerSignUp"
            component={VolunteerSignUpPage}
          />
          <Stack.Screen name="VolunteerLogin" component={VolunteerLoginPage} />
          <Stack.Screen
            name="BlindSignUp"
            component={BlindSignUpPage}
          />
          <Stack.Screen name="BlindLogin" component={BlindLoginPage} />
          <Stack.Screen name="SuccessPage" component={SuccessPage} />
          <Stack.Screen
            name="VolunteerHome"
            component={VolunteerHomePage}
          />
          <Stack.Screen
            name="BlindHome"
            component={BlindHomePage}
          />


          <Stack.Screen name="VideoCall">
            {() => (
              <VideoCallPage
                webRTCSystem={defaultWebRTCSystem}
              />
            )}
          </Stack.Screen>



        </Stack.Navigator>



      </NavigationContainer>
      </GestureHandlerRootView>
  );
}
