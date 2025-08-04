const express = require('express');
const { body, validationResult } = require('express-validator');
const { getAdminAuth, getAdminFirestore } = require('../config/firebase');
const { logger, businessLogger } = require('../utils/logger');
const { sendWelcomeEmail, sendPasswordResetEmail } = require('../services/emailService');
const { generateCustomToken } = require('../services/authService');

const router = express.Router();

// Validation middleware
const validateRegistration = [
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 8 }),
  body('firstName').trim().isLength({ min: 2 }),
  body('lastName').trim().isLength({ min: 2 }),
  body('phoneNumber').isMobilePhone(),
  body('location').isObject(),
  body('location.lat').isFloat(),
  body('location.lng').isFloat(),
  body('location.address').isString(),
  body('language').isIn(['en', 'fr', 'sw', 'ha', 'yo', 'ar']),
  body('role').isIn(['farmer', 'agronomist', 'admin'])
];

const validateLogin = [
  body('email').isEmail().normalizeEmail(),
  body('password').notEmpty()
];

// Register new user
router.post('/register', validateRegistration, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const {
      email,
      password,
      firstName,
      lastName,
      phoneNumber,
      location,
      language,
      role,
      farmSize,
      crops,
      experience
    } = req.body;

    const adminAuth = getAdminAuth();
    const db = getAdminFirestore();

    // Check if user already exists
    try {
      await adminAuth.getUserByEmail(email);
      return res.status(409).json({
        error: 'User already exists',
        message: 'An account with this email already exists'
      });
    } catch (error) {
      // User doesn't exist, continue with registration
    }

    // Create user in Firebase Auth
    const userRecord = await adminAuth.createUser({
      email,
      password,
      displayName: `${firstName} ${lastName}`,
      phoneNumber: phoneNumber.startsWith('+') ? phoneNumber : `+${phoneNumber}`,
      emailVerified: false
    });

    // Create user profile in Firestore
    const userProfile = {
      uid: userRecord.uid,
      email,
      firstName,
      lastName,
      phoneNumber,
      location,
      language: language || 'en',
      role: role || 'farmer',
      farmSize: farmSize || 0,
      crops: crops || [],
      experience: experience || 'beginner',
      isActive: true,
      createdAt: new Date(),
      updatedAt: new Date(),
      lastLoginAt: null,
      preferences: {
        notifications: {
          email: true,
          push: true,
          sms: false
        },
        privacy: {
          shareData: false,
          publicProfile: false
        }
      },
      stats: {
        totalHarvests: 0,
        totalRevenue: 0,
        cropsPlanted: 0
      }
    };

    await db.collection('users').doc(userRecord.uid).set(userProfile);

    // Send welcome email
    try {
      await sendWelcomeEmail(email, firstName, language);
    } catch (emailError) {
      logger.warn('Failed to send welcome email:', emailError);
    }

    // Generate custom token for immediate login
    const customToken = await generateCustomToken(userRecord.uid);

    businessLogger('auth', 'user_registered', {
      userId: userRecord.uid,
      email,
      role,
      language
    });

    res.status(201).json({
      message: 'User registered successfully',
      user: {
        uid: userRecord.uid,
        email: userRecord.email,
        displayName: userRecord.displayName,
        role: userProfile.role
      },
      token: customToken
    });

  } catch (error) {
    logger.error('Registration error:', error);
    res.status(500).json({
      error: 'Registration failed',
      message: 'Unable to create user account'
    });
  }
});

// Login user
router.post('/login', validateLogin, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const { email, password } = req.body;

    // Note: Firebase Auth handles the actual authentication
    // This endpoint is for custom token generation and user data retrieval
    const adminAuth = getAdminAuth();
    const db = getAdminFirestore();

    // Get user by email
    const userRecord = await adminAuth.getUserByEmail(email);
    
    // Get user profile from Firestore
    const userDoc = await db.collection('users').doc(userRecord.uid).get();
    
    if (!userDoc.exists) {
      return res.status(404).json({
        error: 'User not found',
        message: 'User profile not found'
      });
    }

    const userProfile = userDoc.data();

    // Update last login
    await db.collection('users').doc(userRecord.uid).update({
      lastLoginAt: new Date(),
      updatedAt: new Date()
    });

    // Generate custom token
    const customToken = await generateCustomToken(userRecord.uid);

    businessLogger('auth', 'user_login', {
      userId: userRecord.uid,
      email,
      role: userProfile.role
    });

    res.json({
      message: 'Login successful',
      user: {
        uid: userRecord.uid,
        email: userRecord.email,
        displayName: userRecord.displayName,
        role: userProfile.role,
        language: userProfile.language,
        location: userProfile.location
      },
      token: customToken
    });

  } catch (error) {
    logger.error('Login error:', error);
    res.status(401).json({
      error: 'Authentication failed',
      message: 'Invalid email or password'
    });
  }
});

// Password reset request
router.post('/forgot-password', [
  body('email').isEmail().normalizeEmail()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const { email } = req.body;
    const adminAuth = getAdminAuth();

    try {
      const userRecord = await adminAuth.getUserByEmail(email);
      
      // Generate password reset link
      const resetLink = await adminAuth.generatePasswordResetLink(email);
      
      // Send password reset email
      await sendPasswordResetEmail(email, resetLink);

      businessLogger('auth', 'password_reset_requested', {
        email,
        userId: userRecord.uid
      });

      res.json({
        message: 'Password reset email sent',
        email: email
      });
    } catch (error) {
      // Don't reveal if email exists or not for security
      res.json({
        message: 'If an account exists with this email, a password reset link has been sent'
      });
    }

  } catch (error) {
    logger.error('Password reset error:', error);
    res.status(500).json({
      error: 'Password reset failed',
      message: 'Unable to process password reset request'
    });
  }
});

// Verify email
router.post('/verify-email', async (req, res) => {
  try {
    const { token } = req.body;

    if (!token) {
      return res.status(400).json({
        error: 'Token required',
        message: 'Verification token is required'
      });
    }

    const adminAuth = getAdminAuth();
    
    // Verify the email verification token
    const decodedToken = await adminAuth.verifyIdToken(token);
    
    // Mark email as verified
    await adminAuth.updateUser(decodedToken.uid, {
      emailVerified: true
    });

    businessLogger('auth', 'email_verified', {
      userId: decodedToken.uid,
      email: decodedToken.email
    });

    res.json({
      message: 'Email verified successfully'
    });

  } catch (error) {
    logger.error('Email verification error:', error);
    res.status(400).json({
      error: 'Email verification failed',
      message: 'Invalid or expired verification token'
    });
  }
});

// Refresh token
router.post('/refresh-token', async (req, res) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({
        error: 'Refresh token required',
        message: 'Refresh token is required'
      });
    }

    const adminAuth = getAdminAuth();
    
    // Verify the refresh token
    const decodedToken = await adminAuth.verifyIdToken(refreshToken);
    
    // Generate new custom token
    const newToken = await generateCustomToken(decodedToken.uid);

    res.json({
      message: 'Token refreshed successfully',
      token: newToken
    });

  } catch (error) {
    logger.error('Token refresh error:', error);
    res.status(401).json({
      error: 'Token refresh failed',
      message: 'Invalid or expired refresh token'
    });
  }
});

// Logout (client-side token invalidation)
router.post('/logout', async (req, res) => {
  try {
    const { uid } = req.body;

    if (uid) {
      businessLogger('auth', 'user_logout', {
        userId: uid
      });
    }

    res.json({
      message: 'Logout successful'
    });

  } catch (error) {
    logger.error('Logout error:', error);
    res.status(500).json({
      error: 'Logout failed',
      message: 'Unable to process logout request'
    });
  }
});

module.exports = router; 