import React, { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, Alert } from 'react-native';
import { useAuth } from '../context/AuthContext';

export default function SignUpScreen() {
  const { signup } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirm, setConfirm] = useState('');

  const onSubmit = async () => {
    if (!email || !password || !confirm) {
      return Alert.alert('Missing fields', 'Please fill all fields');
    }
    if (password !== confirm) {
      return Alert.alert('Password mismatch', 'Passwords do not match');
    }
    await signup(email.trim(), password);
  };

  return (
    <View className="flex-1 bg-white px-6 pt-10">
      <Text className="text-2xl font-bold mb-6">Create your account</Text>
      <TextInput
        className="border border-gray-300 rounded-md px-4 py-3 mb-3"
        placeholder="Email"
        inputMode="email"
        autoCapitalize="none"
        value={email}
        onChangeText={setEmail}
      />
      <TextInput
        className="border border-gray-300 rounded-md px-4 py-3 mb-3"
        placeholder="Password"
        secureTextEntry
        value={password}
        onChangeText={setPassword}
      />
      <TextInput
        className="border border-gray-300 rounded-md px-4 py-3 mb-4"
        placeholder="Confirm Password"
        secureTextEntry
        value={confirm}
        onChangeText={setConfirm}
      />
      <TouchableOpacity className="bg-black rounded-md px-5 py-3" onPress={onSubmit} accessibilityLabel="Sign up">
        <Text className="text-white text-center font-semibold">Sign up</Text>
      </TouchableOpacity>
    </View>
  );
}
