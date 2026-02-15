/**
 * Generate random OTP code
 */
exports.generateOTP = (length = 4) => {
  const digits = '0123456789';
  let otp = '';
  for (let i = 0; i < length; i++) {
    otp += digits[Math.floor(Math.random() * 10)];
  }
  return otp;
};

/**
 * Validate Saudi phone number
 */
exports.validateSaudiPhone = (phoneNumber) => {
  const saudiPhoneRegex = /^\+966[0-9]{9}$/;
  return saudiPhoneRegex.test(phoneNumber);
};

/**
 * Paginate results
 */
exports.paginate = (page = 1, limit = 20) => {
  const offset = (page - 1) * limit;
  return { limit, offset };
};

/**
 * Calculate pagination metadata
 */
exports.getPaginationMeta = (total, page, limit) => {
  const totalPages = Math.ceil(total / limit);
  return {
    total,
    page,
    limit,
    totalPages,
    hasNextPage: page < totalPages,
    hasPrevPage: page > 1
  };
};

/**
 * Check if user has injury conflict with exercise
 */
exports.hasInjuryConflict = (userInjuries, exerciseContraindications) => {
  if (!userInjuries || !exerciseContraindications) return false;
  
  return exerciseContraindications.some(contraindication =>
    userInjuries.some(injury =>
      injury.toLowerCase().includes(contraindication.toLowerCase()) ||
      contraindication.toLowerCase().includes(injury.toLowerCase())
    )
  );
};

/**
 * Calculate macro calories
 */
exports.calculateMacroCalories = (protein, carbs, fats) => {
  return (protein * 4) + (carbs * 4) + (fats * 9);
};

/**
 * Format currency
 */
exports.formatCurrency = (amount, currency = 'SAR') => {
  return new Intl.NumberFormat('ar-SA', {
    style: 'currency',
    currency
  }).format(amount);
};

/**
 * Generate unique order number
 */
exports.generateOrderNumber = () => {
  const timestamp = Date.now().toString(36).toUpperCase();
  const random = Math.random().toString(36).substring(2, 7).toUpperCase();
  return `ORD-${timestamp}-${random}`;
};

/**
 * Sanitize user input
 */
exports.sanitizeInput = (input) => {
  if (typeof input !== 'string') return input;
  return input.trim().replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '');
};

/**
 * Calculate age from date of birth
 */
exports.calculateAge = (dateOfBirth) => {
  const today = new Date();
  const birthDate = new Date(dateOfBirth);
  let age = today.getFullYear() - birthDate.getFullYear();
  const monthDiff = today.getMonth() - birthDate.getMonth();
  
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
    age--;
  }
  
  return age;
};

/**
 * Get quota limits by tier
 */
exports.getQuotaLimits = (tier) => {
  const limits = {
    freemium: {
      messages: 20,
      videoCalls: 1,
      nutritionTrial: 14 // days
    },
    premium: {
      messages: 200,
      videoCalls: 2,
      nutritionTrial: -1 // unlimited
    },
    smart_premium: {
      messages: -1, // unlimited
      videoCalls: 4,
      nutritionTrial: -1 // unlimited
    }
  };
  
  return limits[tier] || limits.freemium;
};

/**
 * Check if nutrition trial is expired
 */
exports.isTrialExpired = (trialStartDate, trialDays = 14) => {
  if (!trialStartDate) return true;
  
  const start = new Date(trialStartDate);
  const now = new Date();
  const daysPassed = Math.floor((now - start) / (1000 * 60 * 60 * 24));
  
  return daysPassed >= trialDays;
};

/**
 * Get days remaining in trial
 */
exports.getTrialDaysRemaining = (trialStartDate, trialDays = 14) => {
  if (!trialStartDate) return 0;
  
  const start = new Date(trialStartDate);
  const now = new Date();
  const daysPassed = Math.floor((now - start) / (1000 * 60 * 60 * 24));
  const remaining = trialDays - daysPassed;
  
  return remaining > 0 ? remaining : 0;
};
