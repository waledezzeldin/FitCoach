# Non-Functional Requirements - عاش (FitCoach+ v2.0)

## Document Information
- **Document Type**: Non-Functional Requirements Specification
- **Version**: 2.0.0
- **Last Updated**: December 2024
- **Status**: Production Ready

---

## Table of Contents

1. [Performance Requirements](#1-performance-requirements)
2. [Scalability Requirements](#2-scalability-requirements)
3. [Reliability Requirements](#3-reliability-requirements)
4. [Security Requirements](#4-security-requirements)
5. [Usability Requirements](#5-usability-requirements)
6. [Accessibility Requirements](#6-accessibility-requirements)
7. [Compatibility Requirements](#7-compatibility-requirements)
8. [Maintainability Requirements](#8-maintainability-requirements)
9. [Internationalization Requirements](#9-internationalization-requirements)
10. [Compliance Requirements](#10-compliance-requirements)

---

## 1. Performance Requirements

### NFR-PERF-001: Page Load Time
**Priority**: Critical  
**Category**: Performance

**Requirement**:  
The application SHALL load the initial screen within 3 seconds on a 4G mobile connection (5 Mbps).

**Measurement**:
- Time from URL request to interactive UI
- Measured using Lighthouse performance score
- Target: Lighthouse score ≥ 90

**Acceptance Criteria**:
- AC1: Home screen loads in < 3 seconds on 4G
- AC2: Initial bundle size < 500KB (gzipped)
- AC3: Time to Interactive (TTI) < 4 seconds
- AC4: First Contentful Paint (FCP) < 1.5 seconds

**Implementation Notes**:
```typescript
// Code splitting for large modules
const translations = await import('./translations-data');

// Lazy loading for admin screens
const AdminDashboard = lazy(() => import('./components/AdminDashboard'));

// Image optimization
<img 
  src="workout.webp" 
  loading="lazy" 
  width={300} 
  height={200}
/>
```

---

### NFR-PERF-002: Screen Transition Time
**Priority**: High  
**Category**: Performance

**Requirement**:  
Screen transitions SHALL complete within 300 milliseconds with smooth animations.

**Measurement**:
- Time from user action (click/tap) to new screen fully rendered
- Frame rate during transition ≥ 30 FPS

**Acceptance Criteria**:
- AC1: Transitions complete in < 300ms
- AC2: No janky animations (frame drops)
- AC3: Smooth fade/slide transitions

---

### NFR-PERF-003: API Response Time
**Priority**: Critical  
**Category**: Performance

**Requirement**:  
95% of API requests SHALL complete within 1 second under normal load.

**Measurement**:
- Server response time from request initiation to data received
- Measured at 95th percentile

**Acceptance Criteria**:
- AC1: 95% of requests < 1 second
- AC2: 99% of requests < 2 seconds
- AC3: No request takes > 5 seconds (timeout)

**Load Scenarios**:
- Normal: 100 concurrent users
- Peak: 500 concurrent users
- Stress: 1000 concurrent users

---

### NFR-PERF-004: Database Query Performance
**Priority**: High  
**Category**: Performance

**Requirement**:  
Database queries SHALL execute within 100 milliseconds for 95% of requests.

**Measurement**:
- Query execution time from PostgreSQL logs
- Measured at 95th percentile

**Acceptance Criteria**:
- AC1: Simple queries (SELECT by ID) < 10ms
- AC2: Complex queries (JOIN, aggregations) < 100ms
- AC3: All queries indexed appropriately
- AC4: No full table scans on tables > 10,000 rows

**Optimization Strategies**:
```sql
-- Index on frequently queried columns
CREATE INDEX idx_users_phone ON users(phone_number);
CREATE INDEX idx_messages_conversation ON messages(conversation_id, sent_at DESC);
CREATE INDEX idx_quota_user_tier ON quota_usage(user_id, tier);

-- Composite index for common queries
CREATE INDEX idx_workout_user_active ON workout_plans(user_id, is_active);
```

---

### NFR-PERF-005: Real-Time Messaging Latency
**Priority**: High  
**Category**: Performance

**Requirement**:  
Messages SHALL be delivered to recipients within 2 seconds in real-time scenarios.

**Measurement**:
- Time from sender clicking "Send" to recipient receiving notification
- Measured using WebSocket/Server-Sent Events latency

**Acceptance Criteria**:
- AC1: Message delivery < 2 seconds (95% of cases)
- AC2: Read receipts update within 1 second
- AC3: Typing indicators appear within 500ms

---

## 2. Scalability Requirements

### NFR-SCALE-001: Concurrent Users
**Priority**: Critical  
**Category**: Scalability

**Requirement**:  
The system SHALL support 10,000 concurrent active users without performance degradation.

**Measurement**:
- Load testing with JMeter/k6
- Monitor response times under increasing load

**Acceptance Criteria**:
- AC1: 10,000 concurrent users with < 1 second response time
- AC2: No increase in error rate under load
- AC3: Server CPU usage < 70% at peak
- AC4: Database connections managed efficiently

**Scaling Strategy**:
- Horizontal scaling of application servers
- Database read replicas for load distribution
- CDN for static assets
- Redis caching layer

```typescript
// Connection pooling
const pool = new Pool({
  max: 20, // Maximum connections
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000
});
```

---

### NFR-SCALE-002: Data Volume
**Priority**: High  
**Category**: Scalability

**Requirement**:  
The system SHALL handle storage and retrieval of:
- 100,000+ user accounts
- 1,000,000+ workout logs per month
- 5,000,000+ messages per month
- 50,000+ nutrition plans

**Measurement**:
- Database size monitoring
- Query performance as data grows

**Acceptance Criteria**:
- AC1: Database size < 100GB for first year
- AC2: Query performance unchanged with data growth
- AC3: Automatic data archiving after 2 years
- AC4: Pagination for all large datasets

**Data Management**:
```typescript
// Pagination for large results
async function getMessages(conversationId: string, page: number = 1, limit: number = 50) {
  const offset = (page - 1) * limit;
  return db.messages.find({
    conversationId
  })
  .sort({ sentAt: -1 })
  .limit(limit)
  .offset(offset);
}

// Archiving old data
async function archiveOldWorkoutLogs() {
  const twoYearsAgo = new Date();
  twoYearsAgo.setFullYear(twoYearsAgo.getFullYear() - 2);
  
  await db.workoutLogs.updateMany(
    { completedAt: { $lt: twoYearsAgo } },
    { archived: true }
  );
}
```

---

### NFR-SCALE-003: Geographic Distribution
**Priority**: Medium  
**Category**: Scalability

**Requirement**:  
The system SHALL support users across Saudi Arabia with consistent performance.

**Measurement**:
- Response times from different cities (Riyadh, Jeddah, Dammam)
- CDN edge location coverage

**Acceptance Criteria**:
- AC1: < 200ms latency from any Saudi city
- AC2: CDN coverage in Middle East region
- AC3: Multi-region deployment capability

---

## 3. Reliability Requirements

### NFR-REL-001: Availability
**Priority**: Critical  
**Category**: Reliability

**Requirement**:  
The system SHALL maintain 99.5% uptime (max 3.65 hours downtime per month).

**Measurement**:
- Uptime monitoring with Pingdom/UptimeRobot
- Incident tracking and MTTR (Mean Time To Recovery)

**Acceptance Criteria**:
- AC1: 99.5% uptime measured monthly
- AC2: Planned maintenance announced 48 hours in advance
- AC3: Unplanned downtime < 2 hours per incident
- AC4: Maximum 3 incidents per month

**High Availability Setup**:
```yaml
# Example: Kubernetes deployment with 3 replicas
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fitcoach-api
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
```

---

### NFR-REL-002: Error Rate
**Priority**: Critical  
**Category**: Reliability

**Requirement**:  
The system SHALL maintain error rate below 0.1% of all requests.

**Measurement**:
- HTTP 5xx error rate from server logs
- Client-side error rate from Sentry

**Acceptance Criteria**:
- AC1: Server error rate < 0.1%
- AC2: Client error rate < 0.5%
- AC3: Zero critical errors (data loss, security breach)
- AC4: All errors logged with stack traces

---

### NFR-REL-003: Data Integrity
**Priority**: Critical  
**Category**: Reliability

**Requirement**:  
The system SHALL ensure zero data loss and maintain data consistency.

**Measurement**:
- Database integrity checks
- Transaction success rate

**Acceptance Criteria**:
- AC1: Zero data loss incidents
- AC2: All database transactions are ACID-compliant
- AC3: Daily automated backups
- AC4: Point-in-time recovery capability (last 30 days)

**Backup Strategy**:
```bash
# Automated daily backups
0 2 * * * pg_dump fitcoach_db | gzip > /backups/fitcoach_$(date +\%Y\%m\%d).sql.gz

# Retain backups for 30 days
find /backups -name "fitcoach_*.sql.gz" -mtime +30 -delete
```

---

### NFR-REL-004: Graceful Degradation
**Priority**: High  
**Category**: Reliability

**Requirement**:  
The system SHALL degrade gracefully when external services (SMS, payment) are unavailable.

**Acceptance Criteria**:
- AC1: Core features work if SMS service is down (show manual code option)
- AC2: Workout timer works offline
- AC3: Messaging queued if server unavailable, sent when reconnected
- AC4: Clear error messages when features unavailable

**Fallback Mechanisms**:
```typescript
async function sendOTP(phoneNumber: string) {
  try {
    // Primary: Twilio
    await twilioService.sendSMS(phoneNumber, code);
  } catch (error) {
    try {
      // Fallback: AWS SNS
      await awsSNS.sendSMS(phoneNumber, code);
    } catch (fallbackError) {
      // Last resort: Manual entry option
      showManualCodeEntry();
      logError('SMS service unavailable', { phoneNumber, error, fallbackError });
    }
  }
}
```

---

## 4. Security Requirements

### NFR-SEC-001: Authentication Security
**Priority**: Critical  
**Category**: Security

**Requirement**:  
The system SHALL implement secure OTP-based authentication with proper rate limiting and hashing.

**Acceptance Criteria**:
- AC1: OTP codes hashed with bcrypt (salt rounds ≥ 10)
- AC2: OTP expires after 5 minutes
- AC3: Maximum 3 OTP requests per phone per hour
- AC4: Maximum 3 verification attempts per OTP session
- AC5: Account lockout after 5 failed login attempts (15 min)

**Security Implementation**:
```typescript
// Hash OTP before storage
const hashedOTP = await bcrypt.hash(code, 10);

// Rate limiting middleware
const otpLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 3, // 3 requests per hour
  keyGenerator: (req) => req.body.phoneNumber,
  handler: (req, res) => {
    res.status(429).json({ error: 'Too many OTP requests' });
  }
});

app.post('/api/auth/send-otp', otpLimiter, sendOTPHandler);
```

---

### NFR-SEC-002: Data Encryption
**Priority**: Critical  
**Category**: Security

**Requirement**:  
The system SHALL encrypt all data in transit and at rest.

**Acceptance Criteria**:
- AC1: HTTPS (TLS 1.3) for all client-server communication
- AC2: Database encryption at rest (AES-256)
- AC3: Sensitive fields (phone numbers) encrypted in database
- AC4: No sensitive data in URLs or logs

**Encryption Example**:
```typescript
// Encrypt phone numbers before storage
import { createCipher } from 'crypto';

function encryptPhoneNumber(phone: string): string {
  const cipher = createCipher('aes-256-cbc', process.env.ENCRYPTION_KEY);
  let encrypted = cipher.update(phone, 'utf8', 'hex');
  encrypted += cipher.final('hex');
  return encrypted;
}
```

---

### NFR-SEC-003: Input Validation
**Priority**: Critical  
**Category**: Security

**Requirement**:  
The system SHALL validate and sanitize all user inputs to prevent injection attacks.

**Acceptance Criteria**:
- AC1: SQL injection prevention (parameterized queries only)
- AC2: XSS prevention (sanitize HTML inputs)
- AC3: CSRF protection (tokens for state-changing requests)
- AC4: File upload validation (type, size, malware scan)

**Validation Example**:
```typescript
import validator from 'validator';
import sanitizeHtml from 'sanitize-html';

// SQL injection prevention
const user = await db.query(
  'SELECT * FROM users WHERE phone_number = $1',
  [phoneNumber] // Parameterized query
);

// XSS prevention
const sanitizedMessage = sanitizeHtml(userMessage, {
  allowedTags: [], // No HTML tags allowed
  allowedAttributes: {}
});

// CSRF token validation
app.use(csrf({ cookie: true }));
app.post('/api/users/update', (req, res) => {
  // CSRF token automatically validated
});
```

---

### NFR-SEC-004: Access Control
**Priority**: Critical  
**Category**: Security

**Requirement**:  
The system SHALL enforce role-based access control (RBAC) for all protected resources.

**Acceptance Criteria**:
- AC1: Users can only access their own data
- AC2: Coaches can only access assigned clients' data
- AC3: Admins have full access but actions are logged
- AC4: JWT tokens include role claim
- AC5: API endpoints verify permissions before processing

**RBAC Middleware**:
```typescript
function requireRole(...roles: UserRole[]) {
  return (req, res, next) => {
    const user = req.user;
    
    if (!user) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    
    if (!roles.includes(user.role)) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    
    next();
  };
}

// Usage
app.get('/api/admin/users', requireRole('admin'), getUsers);
app.get('/api/coach/clients', requireRole('coach'), getClients);
```

---

### NFR-SEC-005: Privacy Protection
**Priority**: Critical  
**Category**: Security

**Requirement**:  
The system SHALL protect user privacy and comply with data protection regulations.

**Acceptance Criteria**:
- AC1: Minimal PII collection (only necessary data)
- AC2: User consent for data collection
- AC3: Right to data export (JSON format)
- AC4: Right to deletion (anonymize user data)
- AC5: No third-party data sharing without consent

**Privacy Implementation**:
```typescript
// Data export
async function exportUserData(userId: string): Promise<UserDataExport> {
  const user = await db.users.findById(userId);
  const workouts = await db.workoutLogs.find({ userId });
  const messages = await db.messages.find({ userId });
  
  return {
    profile: user,
    workouts,
    messages: messages.map(m => ({
      content: m.content,
      sentAt: m.sentAt
    })),
    exportedAt: new Date()
  };
}

// Data deletion (anonymization)
async function deleteUserAccount(userId: string) {
  await db.users.update(userId, {
    phoneNumber: 'DELETED',
    name: 'Deleted User',
    email: null,
    deleted: true,
    deletedAt: new Date()
  });
  
  // Keep workout logs for statistics but anonymize
  await db.workoutLogs.updateMany(
    { userId },
    { userId: 'ANONYMOUS' }
  );
}
```

---

## 5. Usability Requirements

### NFR-USE-001: Ease of Use
**Priority**: High  
**Category**: Usability

**Requirement**:  
New users SHALL be able to complete first workout within 10 minutes of registration.

**Measurement**:
- Time from account creation to workout completion
- User testing with 10 participants

**Acceptance Criteria**:
- AC1: Onboarding completes in < 3 minutes
- AC2: First workout starts in < 5 minutes
- AC3: No more than 3 clicks to reach any main feature
- AC4: User testing shows 90% success rate

---

### NFR-USE-002: Visual Design
**Priority**: High  
**Category**: Usability

**Requirement**:  
The system SHALL provide clear, consistent, and aesthetically pleasing visual design.

**Acceptance Criteria**:
- AC1: Consistent color scheme throughout app
- AC2: Minimum touch target size: 44x44 pixels
- AC3: Clear visual hierarchy (headings, body text, CTAs)
- AC4: Loading indicators for all async operations
- AC5: Error messages in red, success in green

**Design System**:
```typescript
// Color palette
const colors = {
  primary: '#3B82F6',      // Blue
  secondary: '#10B981',    // Green
  error: '#EF4444',        // Red
  warning: '#F59E0B',      // Orange
  text: {
    primary: '#1F2937',    // Dark gray
    secondary: '#6B7280',  // Medium gray
  },
  background: {
    primary: '#FFFFFF',    // White
    secondary: '#F3F4F6',  // Light gray
  }
};

// Typography scale
const fontSize = {
  xs: '12px',
  sm: '14px',
  base: '16px',
  lg: '18px',
  xl: '20px',
  '2xl': '24px',
  '3xl': '30px',
};
```

---

### NFR-USE-003: Error Handling
**Priority**: High  
**Category**: Usability

**Requirement**:  
The system SHALL provide clear, actionable error messages in user's language.

**Acceptance Criteria**:
- AC1: Error messages explain what went wrong
- AC2: Error messages suggest how to fix
- AC3: No technical jargon in user-facing errors
- AC4: Errors translated to Arabic/English

**Error Message Examples**:
```typescript
const errorMessages = {
  en: {
    phoneInvalid: 'Please enter a valid Saudi phone number starting with 5',
    otpExpired: 'Your verification code has expired. Please request a new one.',
    quotaExceeded: 'You've used all your messages this month. Upgrade to Premium for more.',
    networkError: 'Connection failed. Please check your internet and try again.'
  },
  ar: {
    phoneInvalid: 'الرجاء إدخال رقم هاتف سعودي صحيح يبدأ بـ 5',
    otpExpired: 'انتهت صلاحية رمز التحقق. الرجاء طلب رمز جديد.',
    quotaExceeded: 'لقد استخدمت جميع رسائلك هذا الشهر. قم بالترقية إلى بريميوم للمزيد.',
    networkError: 'فشل الاتصال. تحقق من الإنترنت وحاول مرة أخرى.'
  }
};
```

---

### NFR-USE-004: Responsive Design
**Priority**: Critical  
**Category**: Usability

**Requirement**:  
The system SHALL adapt to different screen sizes from mobile (320px) to desktop (1920px).

**Acceptance Criteria**:
- AC1: Mobile-first design (320px minimum width)
- AC2: Tablet optimization (768px+)
- AC3: Desktop optimization (1024px+)
- AC4: No horizontal scrolling on any screen size
- AC5: Touch-friendly on mobile, mouse-friendly on desktop

**Responsive Breakpoints**:
```css
/* Mobile first */
.container {
  padding: 1rem;
}

/* Tablet */
@media (min-width: 768px) {
  .container {
    padding: 1.5rem;
    max-width: 768px;
  }
}

/* Desktop */
@media (min-width: 1024px) {
  .container {
    padding: 2rem;
    max-width: 1200px;
  }
}
```

---

## 6. Accessibility Requirements

### NFR-ACC-001: WCAG Compliance
**Priority**: High  
**Category**: Accessibility

**Requirement**:  
The system SHALL comply with WCAG 2.1 Level AA standards.

**Acceptance Criteria**:
- AC1: Color contrast ratio ≥ 4.5:1 for normal text
- AC2: Color contrast ratio ≥ 3:1 for large text (18pt+)
- AC3: All images have alt text
- AC4: Keyboard navigation supported
- AC5: Screen reader compatible (ARIA labels)

**Accessibility Implementation**:
```tsx
// Color contrast
<button className="bg-blue-600 text-white"> {/* 4.5:1 contrast */}
  Start Workout
</button>

// Alt text
<img src="exercise.jpg" alt="Person performing push-up exercise" />

// ARIA labels
<button aria-label="Close dialog">
  <X /> {/* Icon only */}
</button>

// Keyboard navigation
<div 
  role="button" 
  tabIndex={0}
  onKeyPress={(e) => e.key === 'Enter' && handleClick()}
>
  Click me
</div>
```

---

### NFR-ACC-002: Screen Reader Support
**Priority**: Medium  
**Category**: Accessibility

**Requirement**:  
The system SHALL be fully navigable and usable with screen readers.

**Acceptance Criteria**:
- AC1: All interactive elements have descriptive labels
- AC2: Form fields have associated labels
- AC3: Dynamic content changes announced
- AC4: Skip navigation links provided

---

## 7. Compatibility Requirements

### NFR-COMPAT-001: Browser Support
**Priority**: Critical  
**Category**: Compatibility

**Requirement**:  
The system SHALL support modern browsers from the past 2 years.

**Supported Browsers**:
- Chrome 90+ (primary)
- Safari 14+ (iOS support)
- Firefox 88+
- Edge 90+
- Samsung Internet 14+

**Acceptance Criteria**:
- AC1: Full functionality on all supported browsers
- AC2: Graceful degradation on older browsers
- AC3: Browser detection and warnings for unsupported versions

---

### NFR-COMPAT-002: Mobile OS Support
**Priority**: Critical  
**Category**: Compatibility

**Requirement**:  
The system SHALL support iOS 14+ and Android 10+.

**Acceptance Criteria**:
- AC1: Full functionality on iOS Safari 14+
- AC2: Full functionality on Android Chrome 90+
- AC3: Responsive design tested on real devices
- AC4: Touch gestures work correctly

---

### NFR-COMPAT-003: Device Support
**Priority**: High  
**Category**: Compatibility

**Requirement**:  
The system SHALL work on smartphones (4.7"+), tablets (7"+), and desktops.

**Tested Devices**:
- iPhone SE (4.7")
- iPhone 12/13/14 (6.1")
- iPad (10.2")
- iPad Pro (12.9")
- Android phones (5.5" - 6.7")
- Desktop (1920x1080)

---

## 8. Maintainability Requirements

### NFR-MAINT-001: Code Quality
**Priority**: High  
**Category**: Maintainability

**Requirement**:  
The codebase SHALL maintain high quality standards for long-term maintainability.

**Acceptance Criteria**:
- AC1: TypeScript for type safety (no `any` types)
- AC2: ESLint with no warnings
- AC3: Code coverage ≥ 80%
- AC4: All functions documented with JSDoc
- AC5: Consistent code style (Prettier)

**Code Quality Tools**:
```json
{
  "scripts": {
    "lint": "eslint . --ext .ts,.tsx",
    "lint:fix": "eslint . --ext .ts,.tsx --fix",
    "format": "prettier --write \"**/*.{ts,tsx,json,md}\"",
    "type-check": "tsc --noEmit",
    "test": "jest --coverage"
  }
}
```

---

### NFR-MAINT-002: Documentation
**Priority**: High  
**Category**: Maintainability

**Requirement**:  
The system SHALL be fully documented for developers and users.

**Acceptance Criteria**:
- AC1: README with setup instructions
- AC2: API documentation (OpenAPI/Swagger)
- AC3: Component documentation (Storybook)
- AC4: Architecture diagrams
- AC5: Inline code comments for complex logic

---

### NFR-MAINT-003: Monitoring & Logging
**Priority**: Critical  
**Category**: Maintainability

**Requirement**:  
The system SHALL provide comprehensive logging and monitoring for debugging and analytics.

**Acceptance Criteria**:
- AC1: All errors logged with stack traces
- AC2: Performance metrics tracked (APM)
- AC3: User actions logged for analytics
- AC4: Alerts for critical errors
- AC5: Log retention for 90 days

**Logging Setup**:
```typescript
import winston from 'winston';

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});

// Usage
logger.info('User logged in', { userId, phoneNumber });
logger.error('Payment failed', { userId, error, amount });
```

---

## 9. Internationalization Requirements

### NFR-I18N-001: Multi-Language Support
**Priority**: Critical  
**Category**: Internationalization

**Requirement**:  
The system SHALL support Arabic and English with seamless language switching.

**Acceptance Criteria**:
- AC1: 100% of UI text translatable
- AC2: Language selection persists across sessions
- AC3: RTL layout for Arabic
- AC4: LTR layout for English
- AC5: No hardcoded strings in code

**Translation System**:
```typescript
const translations = {
  en: {
    'home.greeting': 'Good Morning, {name}',
    'workout.start': 'Start Workout'
  },
  ar: {
    'home.greeting': 'صباح الخير، {name}',
    'workout.start': 'ابدأ التمرين'
  }
};

// Usage
function HomeScreen() {
  const { t } = useLanguage();
  return <h1>{t('home.greeting', { name: user.name })}</h1>;
}
```

---

### NFR-I18N-002: RTL Layout Support
**Priority**: Critical  
**Category**: Internationalization

**Requirement**:  
The system SHALL properly display Right-to-Left layout for Arabic.

**Acceptance Criteria**:
- AC1: Text alignment right for Arabic
- AC2: UI elements mirrored (icons, navigation)
- AC3: Form inputs RTL-aware
- AC4: Tables and lists RTL-compatible

**RTL Implementation**:
```css
/* Automatic RTL with Tailwind */
.container {
  text-align: left; /* LTR */
}

html[dir="rtl"] .container {
  text-align: right; /* RTL */
}

/* OR use Tailwind RTL classes */
<div className="text-left rtl:text-right">Content</div>
```

---

### NFR-I18N-003: Date & Number Formatting
**Priority**: Medium  
**Category**: Internationalization

**Requirement**:  
The system SHALL format dates and numbers according to user's locale.

**Acceptance Criteria**:
- AC1: Dates in DD/MM/YYYY for Arabic, MM/DD/YYYY for English
- AC2: Numbers with proper separators (1,000 vs 1.000)
- AC3: Currency formatting (SAR, USD)

**Formatting Example**:
```typescript
// Date formatting
const formatter = new Intl.DateTimeFormat(language === 'ar' ? 'ar-SA' : 'en-US');
formatter.format(new Date()); // "١٨/١٢/٢٠٢٤" or "12/18/2024"

// Number formatting
const numberFormatter = new Intl.NumberFormat(language === 'ar' ? 'ar-SA' : 'en-US');
numberFormatter.format(1000); // "١٬٠٠٠" or "1,000"
```

---

## 10. Compliance Requirements

### NFR-COMP-001: Data Protection
**Priority**: Critical  
**Category**: Compliance

**Requirement**:  
The system SHALL comply with GDPR and Saudi Arabia Personal Data Protection Law.

**Acceptance Criteria**:
- AC1: User consent for data collection
- AC2: Right to access personal data
- AC3: Right to delete personal data
- AC4: Data breach notification within 72 hours
- AC5: Data Processing Agreement with third parties

---

### NFR-COMP-002: Payment Compliance
**Priority**: Critical  
**Category**: Compliance

**Requirement**:  
The system SHALL comply with PCI-DSS for payment processing.

**Acceptance Criteria**:
- AC1: No credit card data stored on servers
- AC2: Payment processing via PCI-compliant provider (Stripe/Paddle)
- AC3: HTTPS for all payment pages
- AC4: Strong customer authentication (SCA)

---

## Summary

| Category | Critical | High | Medium | Total |
|----------|----------|------|--------|-------|
| Performance | 3 | 3 | 0 | 6 |
| Scalability | 1 | 1 | 1 | 3 |
| Reliability | 3 | 1 | 0 | 4 |
| Security | 5 | 0 | 0 | 5 |
| Usability | 1 | 3 | 0 | 4 |
| Accessibility | 0 | 2 | 0 | 2 |
| Compatibility | 3 | 1 | 0 | 4 |
| Maintainability | 1 | 2 | 0 | 3 |
| Internationalization | 3 | 0 | 1 | 4 |
| Compliance | 2 | 0 | 0 | 2 |
| **TOTAL** | **22** | **13** | **2** | **37** |

---

**Document Status**: ✅ Complete  
**Last Updated**: December 2024  
**Version**: 2.0.0

---

**End of Non-Functional Requirements Specification**
