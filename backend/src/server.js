const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const dotenv = require('dotenv');
const { createServer } = require('http');
const { Server } = require('socket.io');

// Load environment variables
dotenv.config();

// Import routes
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const farmRoutes = require('./routes/farms');
const cropRoutes = require('./routes/crops');
const weatherRoutes = require('./routes/weather');
const marketplaceRoutes = require('./routes/marketplace');
const pestDetectionRoutes = require('./routes/pestDetection');
const irrigationRoutes = require('./routes/irrigation');
const livestockRoutes = require('./routes/livestock');
const supplyChainRoutes = require('./routes/supplyChain');
const governmentRoutes = require('./routes/government');
const elearningRoutes = require('./routes/elearning');
const advisoryRoutes = require('./routes/advisory');
const analyticsRoutes = require('./routes/analytics');
const adminRoutes = require('./routes/admin');

// Import middleware
const { authenticateToken } = require('./middleware/auth');
const { errorHandler } = require('./middleware/errorHandler');
const { logger } = require('./utils/logger');

// Import Firebase initialization
const { initializeFirebase } = require('./config/firebase');

const app = express();
const server = createServer(app);
const io = new Server(server, {
  cors: {
    origin: process.env.FRONTEND_URL || "http://localhost:3000",
    methods: ["GET", "POST"]
  }
});

// Initialize Firebase
initializeFirebase();

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.'
});

// Middleware
app.use(helmet());
app.use(cors({
  origin: process.env.FRONTEND_URL || "http://localhost:3000",
  credentials: true
}));
app.use(compression());
app.use(limiter);
app.use(morgan('combined', { stream: { write: message => logger.info(message.trim()) } }));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', authenticateToken, userRoutes);
app.use('/api/farms', authenticateToken, farmRoutes);
app.use('/api/crops', authenticateToken, cropRoutes);
app.use('/api/weather', authenticateToken, weatherRoutes);
app.use('/api/marketplace', authenticateToken, marketplaceRoutes);
app.use('/api/pest-detection', authenticateToken, pestDetectionRoutes);
app.use('/api/irrigation', authenticateToken, irrigationRoutes);
app.use('/api/livestock', authenticateToken, livestockRoutes);
app.use('/api/supply-chain', authenticateToken, supplyChainRoutes);
app.use('/api/government', authenticateToken, governmentRoutes);
app.use('/api/elearning', authenticateToken, elearningRoutes);
app.use('/api/advisory', authenticateToken, advisoryRoutes);
app.use('/api/analytics', authenticateToken, analyticsRoutes);
app.use('/api/admin', authenticateToken, adminRoutes);

// Socket.IO connection handling
io.on('connection', (socket) => {
  logger.info(`User connected: ${socket.id}`);

  // Join user to their farm room
  socket.on('join-farm', (farmId) => {
    socket.join(`farm-${farmId}`);
    logger.info(`User ${socket.id} joined farm ${farmId}`);
  });

  // Weather updates
  socket.on('subscribe-weather', (location) => {
    socket.join(`weather-${location.lat}-${location.lng}`);
  });

  // Marketplace updates
  socket.on('subscribe-marketplace', (region) => {
    socket.join(`marketplace-${region}`);
  });

  // Real-time notifications
  socket.on('subscribe-notifications', (userId) => {
    socket.join(`notifications-${userId}`);
  });

  socket.on('disconnect', () => {
    logger.info(`User disconnected: ${socket.id}`);
  });
});

// Error handling middleware
app.use(errorHandler);

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Route not found',
    message: `Cannot ${req.method} ${req.originalUrl}`
  });
});

// Global error handler
process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

process.on('uncaughtException', (error) => {
  logger.error('Uncaught Exception:', error);
  process.exit(1);
});

const PORT = process.env.PORT || 5000;

server.listen(PORT, () => {
  logger.info(`SmartAgriNet Backend Server running on port ${PORT}`);
  logger.info(`Environment: ${process.env.NODE_ENV || 'development'}`);
});

module.exports = { app, server, io }; 