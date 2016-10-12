import { NativeModules, NativeAppEventEmitter, Platform } from 'react-native';
const NetworkTest = NativeModules.OpenTokNetworkTest;

export const testConnection = NetworkTest.testConnection;