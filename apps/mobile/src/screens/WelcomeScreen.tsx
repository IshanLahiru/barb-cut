import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { AuthStackParamList } from '../navigation/AuthStack';

type Props = NativeStackScreenProps<AuthStackParamList, 'Welcome'>;

export default function WelcomeScreen({ navigation }: Props) {
  return (
    <View className="flex-1 bg-white items-center justify-center px-6">
      <Text className="text-2xl font-bold mb-2">BarbCut</Text>
      <Text className="text-gray-600 mb-6">AI Hairstyle & Beard Try-On</Text>
      <TouchableOpacity
        className="bg-black px-5 py-3 rounded-md"
        onPress={() => navigation.navigate('Login')}
        accessibilityLabel="Get Started"
      >
        <Text className="text-white font-semibold">Get Started</Text>
      </TouchableOpacity>
    </View>
  );
}
