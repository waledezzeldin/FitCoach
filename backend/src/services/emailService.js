const nodemailer = require('nodemailer');
const logger = require('../utils/logger');
const { isBypassEnabled } = require('../utils/featureFlags');

let transporter;

const getTransporter = () => {
  if (!transporter) {
    transporter = nodemailer.createTransport({
      host: process.env.SMTP_HOST || 'smtp.gmail.com',
      port: process.env.SMTP_PORT || 587,
      secure: false, // true for 465, false for other ports
      auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASSWORD
      }
    });
  }

  return transporter;
};

/**
 * Send email
 */
exports.sendEmail = async (to, subject, html, text) => {
  try {
    if (isBypassEnabled('BYPASS_SMTP')) {
      logger.info(`SMTP bypass enabled, skipping email send to ${to}`);
      return {
        messageId: `bypass_smtp_${Date.now()}`,
        accepted: [to],
        bypassed: true
      };
    }

    const mailOptions = {
      from: `"FitCoach+" <${process.env.SMTP_USER}>`,
      to,
      subject,
      text: text || '',
      html: html || text
    };
    
    const info = await getTransporter().sendMail(mailOptions);
    
    logger.info(`Email sent: ${info.messageId}`);
    return info;
    
  } catch (error) {
    logger.error('Email send error:', error);
    throw new Error('Failed to send email');
  }
};

/**
 * Send welcome email
 */
exports.sendWelcomeEmail = async (userEmail, userName) => {
  const subject = 'Welcome to FitCoach+ - مرحباً بك في FitCoach+';
  
  const html = `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
      <h1 style="color: #4CAF50;">Welcome to FitCoach+!</h1>
      <h2 style="color: #4CAF50; direction: rtl;">مرحباً بك في FitCoach+</h2>
      
      <p>Hi ${userName},</p>
      <p style="direction: rtl;">مرحباً ${userName}</p>
      
      <p>Thank you for joining FitCoach+. We're excited to help you achieve your fitness goals!</p>
      <p style="direction: rtl;">شكراً لانضمامك إلى FitCoach+. نحن متحمسون لمساعدتك في تحقيق أهدافك الرياضية!</p>
      
      <div style="margin: 30px 0;">
        <a href="${process.env.FRONTEND_URL}" style="background-color: #4CAF50; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px;">
          Get Started
        </a>
      </div>
      
      <p>Best regards,<br>The FitCoach+ Team</p>
      <p style="direction: rtl;">مع أطيب التحيات،<br>فريق FitCoach+</p>
    </div>
  `;
  
  return exports.sendEmail(userEmail, subject, html);
};

/**
 * Send password reset email
 */
exports.sendPasswordResetEmail = async (userEmail, resetToken) => {
  const resetUrl = `${process.env.FRONTEND_URL}/reset-password?token=${resetToken}`;
  
  const subject = 'Reset Your Password - إعادة تعيين كلمة المرور';
  
  const html = `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
      <h1>Reset Your Password</h1>
      <h2 style="direction: rtl;">إعادة تعيين كلمة المرور</h2>
      
      <p>You requested to reset your password. Click the button below to reset it:</p>
      <p style="direction: rtl;">لقد طلبت إعادة تعيين كلمة المرور. انقر على الزر أدناه لإعادة تعيينها:</p>
      
      <div style="margin: 30px 0;">
        <a href="${resetUrl}" style="background-color: #4CAF50; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px;">
          Reset Password
        </a>
      </div>
      
      <p>This link will expire in 1 hour.</p>
      <p style="direction: rtl;">سينتهي صلاحية هذا الرابط خلال ساعة واحدة.</p>
      
      <p>If you didn't request this, please ignore this email.</p>
      <p style="direction: rtl;">إذا لم تطلب هذا، يرجى تجاهل هذه الرسالة.</p>
    </div>
  `;
  
  return exports.sendEmail(userEmail, subject, html);
};

/**
 * Send booking confirmation email
 */
exports.sendBookingConfirmationEmail = async (userEmail, userName, bookingDetails) => {
  const subject = 'Booking Confirmed - تأكيد الحجز';
  
  const html = `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
      <h1 style="color: #4CAF50;">Booking Confirmed!</h1>
      <h2 style="color: #4CAF50; direction: rtl;">تم تأكيد الحجز!</h2>
      
      <p>Hi ${userName},</p>
      <p style="direction: rtl;">مرحباً ${userName}</p>
      
      <p>Your video call booking has been confirmed.</p>
      <p style="direction: rtl;">تم تأكيد حجز مكالمة الفيديو الخاصة بك.</p>
      
      <div style="background: #f5f5f5; padding: 20px; border-radius: 5px; margin: 20px 0;">
        <h3>Booking Details / تفاصيل الحجز</h3>
        <p><strong>Date / التاريخ:</strong> ${bookingDetails.date}</p>
        <p><strong>Time / الوقت:</strong> ${bookingDetails.time}</p>
        <p><strong>Duration / المدة:</strong> ${bookingDetails.duration} minutes / دقيقة</p>
        <p><strong>Coach / المدرب:</strong> ${bookingDetails.coachName}</p>
      </div>
      
      <div style="margin: 30px 0;">
        <a href="${bookingDetails.meetingUrl}" style="background-color: #4CAF50; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px;">
          Join Meeting
        </a>
      </div>
      
      <p>See you soon!</p>
      <p style="direction: rtl;">نراك قريباً!</p>
    </div>
  `;
  
  return exports.sendEmail(userEmail, subject, html);
};

/**
 * Send quota warning email
 */
exports.sendQuotaWarningEmail = async (userEmail, userName, quotaType, percentUsed) => {
  const subject = `Quota Warning - تحذير الحصة`;
  
  const html = `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
      <h1 style="color: #FF9800;">Quota Warning</h1>
      <h2 style="color: #FF9800; direction: rtl;">تحذير الحصة</h2>
      
      <p>Hi ${userName},</p>
      <p style="direction: rtl;">مرحباً ${userName}</p>
      
      <p>You've used ${percentUsed}% of your ${quotaType} quota this month.</p>
      <p style="direction: rtl;">لقد استخدمت ${percentUsed}٪ من حصة ${quotaType} هذا الشهر.</p>
      
      <p>Consider upgrading your plan to enjoy more features!</p>
      <p style="direction: rtl;">فكر في ترقية خطتك للاستمتاع بمزيد من الميزات!</p>
      
      <div style="margin: 30px 0;">
        <a href="${process.env.FRONTEND_URL}/subscription" style="background-color: #4CAF50; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px;">
          Upgrade Now
        </a>
      </div>
    </div>
  `;
  
  return exports.sendEmail(userEmail, subject, html);
};
