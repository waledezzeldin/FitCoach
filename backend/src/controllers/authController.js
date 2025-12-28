const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../database');
const logger = require('../utils/logger');
const { sendOTPSMS } = require('../services/twilioService');
const { generateOTP } = require('../utils/helpers');

/**
 * Send OTP to phone number
 */
exports.sendOTP = async (req, res) => {
  const client = await db.getClient();
  
  try {
    const { phoneNumber } = req.body;

    if (!phoneNumber) {
      return res.status(400).json({
        success: false,
        message: 'Phone number is required'
      });
    }

    const phoneRegex = /^\+\d{10,15}$/;
    if (!phoneRegex.test(phoneNumber)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid phone number format'
      });
    }
    
    await client.query('BEGIN');
    
    // Generate 4-digit OTP
    const otpCode = generateOTP(4);
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes
    
    // Delete old OTPs for this phone number
    await client.query(
      'DELETE FROM otp_verifications WHERE phone_number = $1',
      [phoneNumber]
    );
    
    // Store OTP in database
    await client.query(
      `INSERT INTO otp_verifications (phone_number, otp_code, expires_at)
       VALUES ($1, $2, $3)`,
      [phoneNumber, otpCode, expiresAt]
    );
    
    // Send OTP via SMS (Twilio)
    if (process.env.NODE_ENV === 'production') {
      await sendOTPSMS(phoneNumber, otpCode);
    } else {
      logger.info(`OTP for ${phoneNumber}: ${otpCode} (DEV MODE - not sent via SMS)`);
    }
    
    await client.query('COMMIT');
    
    res.json({
      success: true,
      message: 'OTP sent successfully',
      expiresIn: 300, // seconds
      ...(process.env.NODE_ENV === 'development' && { otpCode }) // Only in dev mode
    });
    
  } catch (error) {
    await client.query('ROLLBACK');
    logger.error('Send OTP error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to send OTP'
    });
  } finally {
    client.release();
  }
};

/**
 * Verify OTP and login/register user
 */
exports.verifyOTP = async (req, res) => {
  const client = await db.getClient();
  
  try {
    const { phoneNumber, otpCode } = req.body;

    if (!phoneNumber || !otpCode) {
      return res.status(400).json({
        success: false,
        message: 'Phone number and OTP code are required'
      });
    }
    
    await client.query('BEGIN');
    
    // Get OTP from database
    const otpResult = await client.query(
      `SELECT * FROM otp_verifications 
       WHERE phone_number = $1 
       AND otp_code = $2 
       AND expires_at > NOW()
       AND is_used = FALSE
       ORDER BY created_at DESC
       LIMIT 1`,
      [phoneNumber, otpCode]
    );
    
    if (otpResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(400).json({
        success: false,
        message: 'Invalid or expired OTP'
      });
    }
    
    const otp = otpResult.rows[0];
    
    // Mark OTP as used
    await client.query(
      'UPDATE otp_verifications SET is_used = TRUE WHERE id = $1',
      [otp.id]
    );
    
    // Check if user exists with this phone number
    let userResult = await client.query(
      'SELECT * FROM users WHERE phone_number = $1',
      [phoneNumber]
    );
    
    let user;
    let isNewUser = false;
    
    if (userResult.rows.length === 0) {
      // Create new user
      userResult = await client.query(
        `INSERT INTO users (
          full_name,
          phone_number,
          subscription_tier,
          is_verified,
          quota_reset_date
        ) VALUES ($1, $2, 'freemium', TRUE, NOW() + INTERVAL '1 month')
        RETURNING *`,
        ['User', phoneNumber]
      );
      
      user = userResult.rows[0];
      isNewUser = true;
      
      // Assign default coach (get the first active approved coach)
      const defaultCoachResult = await client.query(
        `SELECT c.id, c.user_id
         FROM coaches c
         JOIN users u ON c.user_id = u.id
         WHERE c.is_approved = TRUE 
         AND c.is_active = TRUE
         AND u.is_active = TRUE
         ORDER BY c.created_at ASC
         LIMIT 1`
      );
      
      if (defaultCoachResult.rows.length > 0) {
        const defaultCoach = defaultCoachResult.rows[0];
        
        // Assign coach to user
        await client.query(
          `INSERT INTO user_coaches (user_id, coach_id, assigned_date, is_active)
           VALUES ($1, $2, NOW(), TRUE)`,
          [user.id, defaultCoach.user_id]
        );
        
        logger.info(`Default coach ${defaultCoach.user_id} assigned to new user ${user.id}`);
      }
    } else {
      user = userResult.rows[0];
    }
    
    // Update last login
    await client.query(
      'UPDATE users SET last_login = NOW() WHERE id = $1',
      [user.id]
    );
    
    await client.query('COMMIT');
    
    // Generate JWT
    const token = jwt.sign(
      { userId: user.id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );
    
    delete user.password_hash;
    
    res.json({
      success: true,
      message: 'OTP verification successful',
      token,
      user,
      isNewUser
    });
    
  } catch (error) {
    await client.query('ROLLBACK');
    logger.error('Verify OTP error:', error);
    res.status(500).json({
      success: false,
      message: 'OTP verification failed'
    });
  } finally {
    client.release();
  }
};

/**
 * Login with email or phone + password
 */
exports.login = async (req, res) => {
  try {
    const { emailOrPhone, password } = req.body;
    
    if (!emailOrPhone || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email/Phone and password are required'
      });
    }
    
    // Check if it's email or phone
    const isEmail = emailOrPhone.includes('@');
    const field = isEmail ? 'email' : 'phone_number';
    
    // Find user
    const userResult = await db.query(
      `SELECT * FROM users WHERE ${field} = $1`,
      [emailOrPhone]
    );
    
    if (userResult.rows.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }
    
    const user = userResult.rows[0];
    
    // Check if user has password (some users only use OTP)
    if (!user.password_hash) {
      return res.status(401).json({
        success: false,
        message: 'Please use phone OTP to login'
      });
    }
    
    // Verify password
    const isValid = await bcrypt.compare(password, user.password_hash);
    
    if (!isValid) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }
    
    // Update last login
    await db.query(
      'UPDATE users SET last_login = NOW() WHERE id = $1',
      [user.id]
    );
    
    // Generate JWT
    const token = jwt.sign(
      { userId: user.id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );
    
    delete user.password_hash;
    
    res.json({
      success: true,
      message: 'Login successful',
      token,
      user,
      isNewUser: false
    });
    
    logger.info(`User logged in: ${user.id}`);
    
  } catch (error) {
    logger.error('Login error:', error);
    res.status(500).json({
      success: false,
      message: 'Login failed'
    });
  }
};

/**
 * Signup with email
 */
exports.signup = async (req, res) => {
  const client = await db.getClient();
  
  try {
    const { name, email, phone, password } = req.body;
    
    if (!name || !email || !phone || !password) {
      return res.status(400).json({
        success: false,
        message: 'All fields are required'
      });
    }
    
    await client.query('BEGIN');
    
    // Check if user exists
    const existingUser = await client.query(
      'SELECT id FROM users WHERE email = $1 OR phone_number = $2',
      [email, phone]
    );
    
    if (existingUser.rows.length > 0) {
      await client.query('ROLLBACK');
      return res.status(400).json({
        success: false,
        message: 'User already exists with this email or phone'
      });
    }
    
    // Hash password
    const passwordHash = await bcrypt.hash(password, 10);
    
    // Create user
    const userResult = await client.query(
      `INSERT INTO users (
        full_name,
        email,
        phone_number,
        password_hash,
        subscription_tier,
        is_verified,
        quota_reset_date
      ) VALUES ($1, $2, $3, $4, 'freemium', TRUE, NOW() + INTERVAL '1 month')
      RETURNING *`,
      [name, email, phone, passwordHash]
    );
    
    const user = userResult.rows[0];
    
    // Assign default coach (get the first active approved coach)
    const defaultCoachResult = await client.query(
      `SELECT c.id, c.user_id
       FROM coaches c
       JOIN users u ON c.user_id = u.id
       WHERE c.is_approved = TRUE 
       AND c.is_active = TRUE
       AND u.is_active = TRUE
       ORDER BY c.created_at ASC
       LIMIT 1`
    );
    
    if (defaultCoachResult.rows.length > 0) {
      const defaultCoach = defaultCoachResult.rows[0];
      
      // Assign coach to user
      await client.query(
        `INSERT INTO user_coaches (user_id, coach_id, assigned_date, is_active)
         VALUES ($1, $2, NOW(), TRUE)`,
        [user.id, defaultCoach.user_id]
      );
      
      logger.info(`Default coach ${defaultCoach.user_id} assigned to new user ${user.id}`);
    }
    
    await client.query('COMMIT');
    
    // Generate JWT
    const token = jwt.sign(
      { userId: user.id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );
    
    delete user.password_hash;
    
    res.status(201).json({
      success: true,
      message: 'Account created successfully',
      token,
      user,
      isNewUser: true
    });
    
    logger.info(`New user signed up: ${user.id}`);
    
  } catch (error) {
    await client.query('ROLLBACK');
    logger.error('Signup error:', error);
    res.status(500).json({
      success: false,
      message: 'Signup failed'
    });
  } finally {
    client.release();
  }
};

/**
 * Social login (Google, Facebook, Apple)
 */
exports.socialLogin = async (req, res) => {
  const client = await db.getClient();
  
  try {
    const { provider, accessToken, socialId, email, name, profilePhoto } = req.body;
    
    if (!provider || !socialId) {
      return res.status(400).json({
        success: false,
        message: 'Provider and social ID are required'
      });
    }
    
    // Validate provider
    if (!['google', 'facebook', 'apple'].includes(provider)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid provider'
      });
    }
    
    await client.query('BEGIN');
    
    // Check if user exists with this social account
    let userResult = await client.query(
      `SELECT u.* FROM users u
       LEFT JOIN social_logins sl ON u.id = sl.user_id
       WHERE sl.provider = $1 AND sl.provider_user_id = $2`,
      [provider, socialId]
    );
    
    let user;
    let isNewUser = false;
    
    if (userResult.rows.length === 0) {
      // Check if user exists with email
      if (email) {
        userResult = await client.query(
          'SELECT * FROM users WHERE email = $1',
          [email]
        );
      }
      
      if (userResult.rows.length > 0) {
        // User exists, link social account
        user = userResult.rows[0];
        
        await client.query(
          `INSERT INTO social_logins (user_id, provider, provider_user_id, access_token)
           VALUES ($1, $2, $3, $4)
           ON CONFLICT (provider, provider_user_id) DO UPDATE
           SET access_token = $4, updated_at = NOW()`,
          [user.id, provider, socialId, accessToken]
        );
      } else {
        // Create new user
        userResult = await client.query(
          `INSERT INTO users (
            full_name,
            email,
            profile_photo_url,
            subscription_tier,
            is_verified,
            quota_reset_date
          ) VALUES ($1, $2, $3, 'freemium', TRUE, NOW() + INTERVAL '1 month')
          RETURNING *`,
          [name || 'User', email, profilePhoto]
        );
        
        user = userResult.rows[0];
        isNewUser = true;
        
        // Link social account
        await client.query(
          `INSERT INTO social_logins (user_id, provider, provider_user_id, access_token)
           VALUES ($1, $2, $3, $4)`,
          [user.id, provider, socialId, accessToken]
        );
        
        logger.info(`New user via ${provider}: ${user.id}`);
      }
    } else {
      user = userResult.rows[0];
      
      // Update access token
      await client.query(
        `UPDATE social_logins
         SET access_token = $1, updated_at = NOW()
         WHERE provider = $2 AND provider_user_id = $3`,
        [accessToken, provider, socialId]
      );
    }
    
    // Update last login
    await client.query(
      'UPDATE users SET last_login = NOW() WHERE id = $1',
      [user.id]
    );
    
    await client.query('COMMIT');
    
    // Generate JWT
    const token = jwt.sign(
      { userId: user.id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );
    
    delete user.password_hash;
    
    res.json({
      success: true,
      message: 'Social login successful',
      token,
      user,
      isNewUser
    });
    
  } catch (error) {
    await client.query('ROLLBACK');
    logger.error('Social login error:', error);
    res.status(500).json({
      success: false,
      message: 'Social login failed'
    });
  } finally {
    client.release();
  }
};

/**
 * Refresh JWT token
 */
exports.refreshToken = async (req, res) => {
  try {
    const { refreshToken } = req.body;
    
    if (!refreshToken) {
      return res.status(400).json({
        success: false,
        message: 'Refresh token required'
      });
    }
    
    // Verify refresh token
    const decoded = jwt.verify(refreshToken, process.env.JWT_SECRET);
    
    // Get user
    const result = await db.query(
      'SELECT id, role, subscription_tier FROM users WHERE id = $1 AND is_active = TRUE',
      [decoded.userId]
    );
    
    if (result.rows.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'Invalid refresh token'
      });
    }
    
    const user = result.rows[0];
    
    // Generate new access token
    const accessToken = jwt.sign(
      { 
        userId: user.id, 
        role: user.role,
        tier: user.subscription_tier
      },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '30d' }
    );
    
    res.json({
      success: true,
      accessToken
    });
    
  } catch (error) {
    logger.error('Refresh token error:', error);
    res.status(401).json({
      success: false,
      message: 'Invalid or expired refresh token'
    });
  }
};

/**
 * Logout user
 */
exports.logout = async (req, res) => {
  try {
    // In a production app, you might want to blacklist the token
    // For now, we'll just return success
    res.json({
      success: true,
      message: 'Logged out successfully'
    });
  } catch (error) {
    logger.error('Logout error:', error);
    res.status(500).json({
      success: false,
      message: 'Logout failed'
    });
  }
};

/**
 * Get current user profile
 */
exports.getCurrentUser = async (req, res) => {
  try {
    const result = await db.query(
      `SELECT 
        u.*,
        c.id as coach_id,
        c.bio as coach_bio,
        c.average_rating as coach_rating
       FROM users u
       LEFT JOIN coaches c ON u.assigned_coach_id = c.user_id
       WHERE u.id = $1`,
      [req.user.userId]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }
    
    const user = result.rows[0];
    delete user.password_hash;
    
    res.json({
      success: true,
      user
    });
    
  } catch (error) {
    logger.error('Get current user error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get user profile'
    });
  }
};
