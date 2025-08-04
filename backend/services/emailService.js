const nodemailer = require('nodemailer');
const { logger } = require('../utils/logger');

// Email templates
const emailTemplates = {
  welcome: {
    subject: 'Welcome to SmartAgriNet - Your Smart Farming Journey Begins!',
    html: (firstName, language) => `
      <!DOCTYPE html>
      <html lang="${language}">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Welcome to SmartAgriNet</title>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #2E7D32, #4CAF50); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
          .button { display: inline-block; background: #4CAF50; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; margin: 20px 0; }
          .footer { text-align: center; margin-top: 30px; color: #666; font-size: 14px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🌱 Welcome to SmartAgriNet!</h1>
            <p>Empowering African Farmers with Smart Technology</p>
          </div>
          <div class="content">
            <h2>Hello ${firstName}!</h2>
            <p>Welcome to SmartAgriNet - your comprehensive smart agriculture platform designed specifically for African farmers.</p>
            
            <h3>🚀 What you can do with SmartAgriNet:</h3>
            <ul>
              <li><strong>AI-Powered Crop Recommendations</strong> - Get personalized crop suggestions based on your soil and weather</li>
              <li><strong>Pest Detection</strong> - Identify pests and diseases using your phone's camera</li>
              <li><strong>Smart Irrigation</strong> - Optimize water usage with automated irrigation planning</li>
              <li><strong>Marketplace</strong> - Buy and sell agricultural products directly</li>
              <li><strong>Financial Services</strong> - Access loans and insurance through our partners</li>
              <li><strong>Weather Forecasting</strong> - Get accurate weather predictions for your farm</li>
            </ul>
            
            <h3>📱 Getting Started:</h3>
            <ol>
              <li>Download the SmartAgriNet mobile app</li>
              <li>Complete your farm profile</li>
              <li>Start exploring our features</li>
              <li>Join our community of farmers</li>
            </ol>
            
            <a href="${process.env.FRONTEND_URL}/dashboard" class="button">Get Started Now</a>
            
            <h3>🎯 Quick Tips:</h3>
            <ul>
              <li>Add your farm location for accurate weather data</li>
              <li>Take photos of your crops for pest detection</li>
              <li>Connect with other farmers in your area</li>
              <li>Check the marketplace for best prices</li>
            </ul>
          </div>
          <div class="footer">
            <p>© 2024 SmartAgriNet. All rights reserved.</p>
            <p>If you have any questions, contact us at support@smartagrinet.com</p>
          </div>
        </div>
      </body>
      </html>
    `
  },
  
  passwordReset: {
    subject: 'Reset Your SmartAgriNet Password',
    html: (resetLink, language) => `
      <!DOCTYPE html>
      <html lang="${language}">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Password Reset - SmartAgriNet</title>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #FF9800, #FFB74D); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
          .button { display: inline-block; background: #FF9800; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; margin: 20px 0; }
          .warning { background: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 5px; margin: 20px 0; }
          .footer { text-align: center; margin-top: 30px; color: #666; font-size: 14px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🔐 Password Reset Request</h1>
            <p>SmartAgriNet Account Security</p>
          </div>
          <div class="content">
            <h2>Password Reset Request</h2>
            <p>We received a request to reset your SmartAgriNet account password.</p>
            
            <a href="${resetLink}" class="button">Reset Password</a>
            
            <div class="warning">
              <strong>⚠️ Security Notice:</strong>
              <ul>
                <li>This link will expire in 1 hour</li>
                <li>If you didn't request this, please ignore this email</li>
                <li>Never share your password with anyone</li>
              </ul>
            </div>
            
            <p>If the button doesn't work, copy and paste this link into your browser:</p>
            <p style="word-break: break-all; color: #666;">${resetLink}</p>
          </div>
          <div class="footer">
            <p>© 2024 SmartAgriNet. All rights reserved.</p>
            <p>If you have any questions, contact us at support@smartagrinet.com</p>
          </div>
        </div>
      </body>
      </html>
    `
  },
  
  weatherAlert: {
    subject: 'Weather Alert for Your Farm',
    html: (alertData, language) => `
      <!DOCTYPE html>
      <html lang="${language}">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Weather Alert - SmartAgriNet</title>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #2196F3, #64B5F6); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
          .alert { background: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 5px; margin: 20px 0; }
          .footer { text-align: center; margin-top: 30px; color: #666; font-size: 14px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🌦️ Weather Alert</h1>
            <p>Important weather information for your farm</p>
          </div>
          <div class="content">
            <h2>Weather Alert: ${alertData.type}</h2>
            <p><strong>Location:</strong> ${alertData.location}</p>
            <p><strong>Time:</strong> ${alertData.time}</p>
            <p><strong>Duration:</strong> ${alertData.duration}</p>
            
            <div class="alert">
              <h3>⚠️ Alert Details:</h3>
              <p>${alertData.description}</p>
            </div>
            
            <h3>🌱 Recommended Actions:</h3>
            <ul>
              ${alertData.recommendations.map(rec => `<li>${rec}</li>`).join('')}
            </ul>
            
            <p><strong>Stay safe and protect your crops!</strong></p>
          </div>
          <div class="footer">
            <p>© 2024 SmartAgriNet. All rights reserved.</p>
            <p>Manage your alerts in the SmartAgriNet app</p>
          </div>
        </div>
      </body>
      </html>
    `
  },
  
  marketUpdate: {
    subject: 'Market Price Update - SmartAgriNet',
    html: (marketData, language) => `
      <!DOCTYPE html>
      <html lang="${language}">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Market Update - SmartAgriNet</title>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #4CAF50, #81C784); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
          .price-table { width: 100%; border-collapse: collapse; margin: 20px 0; }
          .price-table th, .price-table td { border: 1px solid #ddd; padding: 12px; text-align: left; }
          .price-table th { background-color: #4CAF50; color: white; }
          .increase { color: #4CAF50; font-weight: bold; }
          .decrease { color: #f44336; font-weight: bold; }
          .footer { text-align: center; margin-top: 30px; color: #666; font-size: 14px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>📈 Market Price Update</h1>
            <p>Latest prices for your agricultural products</p>
          </div>
          <div class="content">
            <h2>Market Update: ${marketData.date}</h2>
            <p><strong>Market:</strong> ${marketData.marketName}</p>
            <p><strong>Location:</strong> ${marketData.location}</p>
            
            <h3>💰 Price Changes:</h3>
            <table class="price-table">
              <thead>
                <tr>
                  <th>Product</th>
                  <th>Current Price</th>
                  <th>Change</th>
                  <th>Trend</th>
                </tr>
              </thead>
              <tbody>
                ${marketData.products.map(product => `
                  <tr>
                    <td>${product.name}</td>
                    <td>${product.currentPrice}</td>
                    <td class="${product.change > 0 ? 'increase' : 'decrease'}">
                      ${product.change > 0 ? '+' : ''}${product.change}%
                    </td>
                    <td>${product.trend}</td>
                  </tr>
                `).join('')}
              </tbody>
            </table>
            
            <h3>💡 Market Insights:</h3>
            <ul>
              ${marketData.insights.map(insight => `<li>${insight}</li>`).join('')}
            </ul>
            
            <p><strong>Best time to sell:</strong> ${marketData.bestTimeToSell}</p>
          </div>
          <div class="footer">
            <p>© 2024 SmartAgriNet. All rights reserved.</p>
            <p>View real-time prices in the SmartAgriNet app</p>
          </div>
        </div>
      </body>
      </html>
    `
  }
};

// Create transporter
const createTransporter = () => {
  return nodemailer.createTransporter({
    service: 'gmail',
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASSWORD
    }
  });
};

// Send email function
const sendEmail = async (to, subject, html, attachments = []) => {
  try {
    const transporter = createTransporter();
    
    const mailOptions = {
      from: `"SmartAgriNet" <${process.env.SENDGRID_FROM_EMAIL}>`,
      to,
      subject,
      html,
      attachments
    };

    const result = await transporter.sendMail(mailOptions);
    
    logger.info('Email sent successfully:', {
      to,
      subject,
      messageId: result.messageId
    });

    return result;
  } catch (error) {
    logger.error('Email sending failed:', {
      to,
      subject,
      error: error.message
    });
    throw error;
  }
};

// Send welcome email
const sendWelcomeEmail = async (email, firstName, language = 'en') => {
  const template = emailTemplates.welcome;
  const html = template.html(firstName, language);
  
  return sendEmail(email, template.subject, html);
};

// Send password reset email
const sendPasswordResetEmail = async (email, resetLink, language = 'en') => {
  const template = emailTemplates.passwordReset;
  const html = template.html(resetLink, language);
  
  return sendEmail(email, template.subject, html);
};

// Send weather alert email
const sendWeatherAlertEmail = async (email, alertData, language = 'en') => {
  const template = emailTemplates.weatherAlert;
  const html = template.html(alertData, language);
  
  return sendEmail(email, template.subject, html);
};

// Send market update email
const sendMarketUpdateEmail = async (email, marketData, language = 'en') => {
  const template = emailTemplates.marketUpdate;
  const html = template.html(marketData, language);
  
  return sendEmail(email, template.subject, html);
};

// Send custom email
const sendCustomEmail = async (to, subject, content, language = 'en') => {
  const html = `
    <!DOCTYPE html>
    <html lang="${language}">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>SmartAgriNet</title>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #2E7D32, #4CAF50); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
        .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
        .footer { text-align: center; margin-top: 30px; color: #666; font-size: 14px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>🌱 SmartAgriNet</h1>
          <p>Empowering African Farmers</p>
        </div>
        <div class="content">
          ${content}
        </div>
        <div class="footer">
          <p>© 2024 SmartAgriNet. All rights reserved.</p>
          <p>Contact us at support@smartagrinet.com</p>
        </div>
      </div>
    </body>
    </html>
  `;
  
  return sendEmail(to, subject, html);
};

// Send bulk emails
const sendBulkEmails = async (emails, subject, content, language = 'en') => {
  const promises = emails.map(email => 
    sendCustomEmail(email, subject, content, language)
  );
  
  return Promise.allSettled(promises);
};

module.exports = {
  sendEmail,
  sendWelcomeEmail,
  sendPasswordResetEmail,
  sendWeatherAlertEmail,
  sendMarketUpdateEmail,
  sendCustomEmail,
  sendBulkEmails
}; 