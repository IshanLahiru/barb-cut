import firebase from '@react-native-firebase/app';
import auth from '@react-native-firebase/auth';
import firestore from '@react-native-firebase/firestore';
import storage from '@react-native-firebase/storage';

// Firebase is automatically initialized via google-services.json (Android) and GoogleService-Info.plist (iOS)
// No manual initialization needed with React Native Firebase

export { firebase, auth, firestore, storage };
