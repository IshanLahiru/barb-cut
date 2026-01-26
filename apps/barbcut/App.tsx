import 'react-native-gesture-handler';
import './global.css';
import { StatusBar } from 'expo-status-bar';
import { View } from 'react-native';
import RootNavigator from './src/navigation/RootNavigator';
import { AuthProvider } from './src/context/AuthContext';

export default function App() {
  return (
    <View className="flex-1 bg-white">
      <AuthProvider>
        <RootNavigator />
      </AuthProvider>
      <StatusBar style="auto" />
    </View>
  );
}
