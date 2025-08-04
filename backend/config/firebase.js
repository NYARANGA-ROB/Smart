const admin = require('firebase-admin');
const { initializeApp } = require('firebase/app');
const { getAuth } = require('firebase/auth');
const { getFirestore } = require('firebase/firestore');
const { getStorage } = require('firebase/storage');

// Firebase Admin SDK configuration
const serviceAccount = {
  type: process.env.FIREBASE_TYPE,
  project_id: process.env.FIREBASE_PROJECT_ID,
  private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
  private_key: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
  client_email: process.env.FIREBASE_CLIENT_EMAIL,
  client_id: process.env.FIREBASE_CLIENT_ID,
  auth_uri: process.env.FIREBASE_AUTH_URI,
  token_uri: process.env.FIREBASE_TOKEN_URI,
  auth_provider_x509_cert_url: process.env.FIREBASE_AUTH_PROVIDER_X509_CERT_URL,
  client_x509_cert_url: process.env.FIREBASE_CLIENT_X509_CERT_URL
};

// Firebase Client SDK configuration
const firebaseConfig = {
  apiKey: process.env.FIREBASE_API_KEY,
  authDomain: process.env.FIREBASE_AUTH_DOMAIN,
  projectId: process.env.FIREBASE_PROJECT_ID,
  storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.FIREBASE_APP_ID,
  measurementId: process.env.FIREBASE_MEASUREMENT_ID
};

let adminApp;
let clientApp;
let auth;
let db;
let storage;

const initializeFirebase = () => {
  try {
    // Initialize Firebase Admin SDK
    adminApp = admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      storageBucket: process.env.FIREBASE_STORAGE_BUCKET
    });

    // Initialize Firebase Client SDK
    clientApp = initializeApp(firebaseConfig);
    auth = getAuth(clientApp);
    db = getFirestore(clientApp);
    storage = getStorage(clientApp);

    console.log('Firebase initialized successfully');
  } catch (error) {
    console.error('Error initializing Firebase:', error);
    throw error;
  }
};

const getAdminAuth = () => {
  if (!adminApp) {
    throw new Error('Firebase Admin not initialized');
  }
  return admin.auth(adminApp);
};

const getAdminFirestore = () => {
  if (!adminApp) {
    throw new Error('Firebase Admin not initialized');
  }
  return admin.firestore(adminApp);
};

const getAdminStorage = () => {
  if (!adminApp) {
    throw new Error('Firebase Admin not initialized');
  }
  return admin.storage(adminApp);
};

const getClientAuth = () => {
  if (!auth) {
    throw new Error('Firebase Client not initialized');
  }
  return auth;
};

const getClientFirestore = () => {
  if (!db) {
    throw new Error('Firebase Client not initialized');
  }
  return db;
};

const getClientStorage = () => {
  if (!storage) {
    throw new Error('Firebase Client not initialized');
  }
  return storage;
};

module.exports = {
  initializeFirebase,
  getAdminAuth,
  getAdminFirestore,
  getAdminStorage,
  getClientAuth,
  getClientFirestore,
  getClientStorage,
  admin,
  auth,
  db,
  storage
}; 