
export const BASE_URL = "http://192.168.40.78:8000";
export const SIGNALING_SERVER_URL = 'ws://192.168.40.78:50001';





import axios from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';

// Create axios instance
export const api = axios.create({
  baseURL: BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add request interceptor
api.interceptors.request.use(
  async (config) => {
    try {
      const token = await AsyncStorage.getItem('access_token');
      if (token) {
        config.headers['Authorization'] = `Bearer ${token}`;
      }
      return config;
    } catch (error) {
      return Promise.reject(error);
    }
  },
  (error) => {
    return Promise.reject(error);
  }
);

export default api;

// Usage example:
// import api from './Config';
// const response = await api.get('/user/profile');
// For non-authenticated requests, directly use fetch() API no need to use axios instance