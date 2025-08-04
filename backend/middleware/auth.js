const jwt = require('jsonwebtoken');
const { getAdminAuth } = require('../config/firebase');
const { logger } = require('../utils/logger');

const authenticateToken = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
      return res.status(401).json({
        error: 'Access token required',
        message: 'No authorization token provided'
      });
    }

    // Verify Firebase token
    const adminAuth = getAdminAuth();
    const decodedToken = await adminAuth.verifyIdToken(token);
    
    // Add user info to request
    req.user = {
      uid: decodedToken.uid,
      email: decodedToken.email,
      phoneNumber: decodedToken.phone_number,
      displayName: decodedToken.name,
      photoURL: decodedToken.picture,
      emailVerified: decodedToken.email_verified,
      role: decodedToken.role || 'farmer',
      farmId: decodedToken.farm_id
    };

    logger.info(`User authenticated: ${req.user.uid}`);
    next();
  } catch (error) {
    logger.error('Authentication error:', error);
    
    if (error.code === 'auth/id-token-expired') {
      return res.status(401).json({
        error: 'Token expired',
        message: 'Your session has expired. Please login again.'
      });
    }
    
    if (error.code === 'auth/id-token-revoked') {
      return res.status(401).json({
        error: 'Token revoked',
        message: 'Your session has been revoked. Please login again.'
      });
    }

    return res.status(403).json({
      error: 'Invalid token',
      message: 'Invalid or malformed authorization token'
    });
  }
};

const requireRole = (roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        error: 'Authentication required',
        message: 'User must be authenticated'
      });
    }

    const userRole = req.user.role;
    const allowedRoles = Array.isArray(roles) ? roles : [roles];

    if (!allowedRoles.includes(userRole)) {
      return res.status(403).json({
        error: 'Insufficient permissions',
        message: `Access denied. Required role: ${allowedRoles.join(' or ')}`
      });
    }

    next();
  };
};

const requireFarmAccess = async (req, res, next) => {
  try {
    if (!req.user) {
      return res.status(401).json({
        error: 'Authentication required',
        message: 'User must be authenticated'
      });
    }

    const farmId = req.params.farmId || req.body.farmId || req.query.farmId;
    
    if (!farmId) {
      return res.status(400).json({
        error: 'Farm ID required',
        message: 'Farm ID must be provided'
      });
    }

    // Check if user has access to this farm
    const { getAdminFirestore } = require('../config/firebase');
    const db = getAdminFirestore();
    
    const farmDoc = await db.collection('farms').doc(farmId).get();
    
    if (!farmDoc.exists) {
      return res.status(404).json({
        error: 'Farm not found',
        message: 'The specified farm does not exist'
      });
    }

    const farmData = farmDoc.data();
    
    // Check if user is owner or has access
    if (farmData.ownerId !== req.user.uid && 
        !farmData.members?.includes(req.user.uid) &&
        req.user.role !== 'admin') {
      return res.status(403).json({
        error: 'Access denied',
        message: 'You do not have access to this farm'
      });
    }

    req.farm = farmData;
    next();
  } catch (error) {
    logger.error('Farm access check error:', error);
    return res.status(500).json({
      error: 'Internal server error',
      message: 'Error checking farm access'
    });
  }
};

const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (token) {
      const adminAuth = getAdminAuth();
      const decodedToken = await adminAuth.verifyIdToken(token);
      
      req.user = {
        uid: decodedToken.uid,
        email: decodedToken.email,
        phoneNumber: decodedToken.phone_number,
        displayName: decodedToken.name,
        photoURL: decodedToken.picture,
        emailVerified: decodedToken.email_verified,
        role: decodedToken.role || 'farmer',
        farmId: decodedToken.farm_id
      };
    }

    next();
  } catch (error) {
    // Continue without authentication for optional routes
    next();
  }
};

module.exports = {
  authenticateToken,
  requireRole,
  requireFarmAccess,
  optionalAuth
}; 