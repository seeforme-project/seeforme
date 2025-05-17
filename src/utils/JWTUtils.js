
import { jwtDecode } from 'jwt-decode';
import AsyncStorage from '@react-native-async-storage/async-storage';

export const getUserIdFromToken = async () => {
  try {
    const token = await AsyncStorage.getItem('access_token');
    
    if (!token) {
      return null;
    }

    const decoded = jwtDecode(token);
    console.log('Decoded JWT:', decoded);
    return decoded.user_id;
  } catch (error) {
    console.error('Error decoding JWT token:', error);
    return null;
  }
};


export const saveLoggedInUserId = async (userId) => {
  try {
    await AsyncStorage.setItem('userId', toString(userId));
  } catch (error) {
    console.error('Error saving user ID:', error);
  }
}