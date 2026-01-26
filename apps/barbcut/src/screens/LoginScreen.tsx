import React, { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, Alert } from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { AuthStackParamList } from '../navigation/AuthStack';
import { useAuth } from '../context/AuthContext';

type Props = NativeStackScreenProps<AuthStackParamList, 'Login'>;

export default function LoginScreen({ navigation }: Props) {
  const { login } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const onSubmit = async () => {
    if (!email || !password) {
      return Alert.alert('Missing fields', 'Please enter email and password');
    }
    await login(email.trim(), password);
  };

  return (
    <View className="flex-1 bg-white px-6 pt-10">
      <Text className="text-2xl font-bold mb-6">Welcome back</Text>
      <TextInput
        className="border border-gray-300 rounded-md px-4 py-3 mb-3"
        placeholder="Email"
        inputMode="email"
        autoCapitalize="none"
        value={email}
        onChangeText={setEmail}
      />
      <TextInput
        className="border border-gray-300 rounded-md px-4 py-3 mb-4"
        placeholder="Password"
        secureTextEntry
        value={password}
        onChangeText={setPassword}
      />
      <TouchableOpacity className="bg-black rounded-md px-5 py-3 mb-3" onPress={onSubmit} accessibilityLabel="Sign in">
        <Text className="text-white text-center font-semibold">Sign in</Text>
      </TouchableOpacity>
      <TouchableOpacity onPress={() => navigation.navigate('SignUp')} accessibilityLabel="Go to signup">
        <Text className="text-center text-gray-700">No account? <Text className="font-semibold">Sign up</Text></Text>
      </TouchableOpacity>
    </View>
  );
}
