# Development Guide

## Document Information
- **Purpose**: Complete guide for setting up, developing, and deploying عاش app
- **Version**: 2.0.0
- **Last Updated**: December 2024
- **Audience**: Developers, DevOps Engineers

---

## Table of Contents

1. [Environment Setup](#environment-setup)
2. [Project Structure](#project-structure)
3. [Development Workflow](#development-workflow)
4. [Code Standards](#code-standards)
5. [Testing Strategy](#testing-strategy)
6. [Build & Deployment](#build--deployment)
7. [Troubleshooting](#troubleshooting)
8. [Performance Optimization](#performance-optimization)

---

## Environment Setup

### Prerequisites

**Required Software**:
- Node.js: v18.0.0 or higher
- npm: v9.0.0 or higher
- Git: Latest version
- VS Code: Recommended IDE

**Optional Tools**:
- React DevTools (browser extension)
- Redux DevTools (if using Redux)
- Figma Desktop App (for design reference)

---

### Initial Setup

**1. Clone Repository**

```bash
git clone https://github.com/your-org/fitcoach-plus-v2.git
cd fitcoach-plus-v2
```

**2. Install Dependencies**

```bash
npm install
```

This installs:
- React 18 with TypeScript
- Vite 5 (build tool)
- Tailwind CSS v4.0
- Radix UI components
- Lucide React icons
- Recharts (charts)
- React Hook Form v7.55.0
- Sonner (toasts)
- Motion/React (animations)

**3. Environment Variables**

Create `.env` file in root:

```bash
# API Configuration
VITE_API_URL=https://api.fitcoachplus.com
VITE_DEMO_MODE=true

# Authentication (Production only)
VITE_TWILIO_ACCOUNT_SID=your_twilio_sid
VITE_TWILIO_AUTH_TOKEN=your_twilio_token

# Supabase (Production only)
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your_anon_key

# Payment Gateway (Production only)
VITE_STRIPE_PUBLIC_KEY=pk_live_...

# Analytics (Optional)
VITE_MIXPANEL_TOKEN=your_mixpanel_token

# Feature Flags
VITE_ENABLE_VIDEO_CALLS=true
VITE_ENABLE_STORE=true
```

**4. Start Development Server**

```bash
npm run dev
```

Server starts at: `http://localhost:5173`

---

### Development Tools Setup

**VS Code Extensions** (Recommended):

```json
{
  "recommendations": [
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "bradlc.vscode-tailwindcss",
    "ms-vscode.vscode-typescript-next",
    "christian-kohler.path-intellisense",
    "streetsidesoftware.code-spell-checker"
  ]
}
```

**VS Code Settings** (`.vscode/settings.json`):

```json
{
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "typescript.tsdk": "node_modules/typescript/lib",
  "tailwindCSS.experimental.classRegex": [
    ["cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]"]
  ]
}
```

---

## Project Structure

### Directory Organization

```
fitcoach-plus-v2/
├── public/                      # Static assets
│   ├── icons/                   # App icons
│   ├── images/                  # Static images
│   └── favicon.ico
│
├── src/
│   ├── components/              # React components
│   │   ├── screens/            # Screen components
│   │   │   ├── user/          # End user screens (12)
│   │   │   ├── coach/         # Coach screens (6)
│   │   │   └── admin/         # Admin screens (8)
│   │   │
│   │   ├── ui/                 # UI components (Radix)
│   │   │   ├── button.tsx
│   │   │   ├── dialog.tsx
│   │   │   ├── card.tsx
│   │   │   └── ...            # 40+ components
│   │   │
│   │   ├── shared/             # Shared components
│   │   │   ├── QuotaDisplay.tsx
│   │   │   ├── NutritionExpiryBanner.tsx
│   │   │   └── UpgradePrompt.tsx
│   │   │
│   │   └── LanguageContext.tsx # i18n context
│   │
│   ├── utils/                   # Utility functions
│   │   ├── injuryRules.ts      # Injury substitution
│   │   ├── quotaEnforcement.ts # Quota management
│   │   ├── nutritionExpiry.ts  # Nutrition trial
│   │   ├── phoneValidation.ts  # Phone validation
│   │   ├── fitnessScore.ts     # Score calculation
│   │   ├── translations.ts     # i18n helpers
│   │   ├── dateUtils.ts        # Date formatting
│   │   ├── storage.ts          # localStorage helpers
│   │   ├── validation.ts       # Input validators
│   │   └── api.ts              # API helpers
│   │
│   ├── types/                   # TypeScript types
│   │   ├── IntakeTypes.ts      # Intake data structures
│   │   ├── QuotaTypes.ts       # Quota types
│   │   ├── InBodyTypes.ts      # InBody types
│   │   ├── WorkoutTypes.ts     # Workout types
│   │   ├── NutritionTypes.ts   # Nutrition types
│   │   └── index.ts            # Type exports
│   │
│   ├── translations/            # i18n data
│   │   ├── translations-data.ts # 2,904 keys (ar/en)
│   │   ├── common.ts
│   │   └── index.ts
│   │
│   ├── styles/
│   │   └── globals.css         # Global styles + Tailwind
│   │
│   ├── hooks/                   # Custom React hooks
│   │   ├── useAuth.ts
│   │   ├── useQuota.ts
│   │   └── useLocalStorage.ts
│   │
│   ├── App.tsx                  # Main app component
│   ├── main.tsx                 # Vite entry point
│   └── vite-env.d.ts           # Vite types
│
├── docs/                        # Documentation (80,000+ words)
│   ├── 1-customer-requirements/
│   ├── 2-software-requirements/
│   ├── 3-software-architecture/
│   ├── 4-code-documentation/
│   └── INDEX.md
│
├── tests/                       # Test files
│   ├── unit/                    # Unit tests
│   ├── integration/             # Integration tests
│   └── e2e/                     # End-to-end tests
│
├── .github/                     # GitHub workflows
│   └── workflows/
│       ├── ci.yml              # Continuous integration
│       └── deploy.yml          # Deployment
│
├── .gitignore
├── .eslintrc.json              # ESLint config
├── .prettierrc                 # Prettier config
├── tsconfig.json               # TypeScript config
├── vite.config.ts              # Vite config
├── tailwind.config.js          # Tailwind config
├── package.json
├── package-lock.json
└── README.md
```

---

## Development Workflow

### Daily Development Cycle

**1. Start Development Server**

```bash
npm run dev
```

**2. Create Feature Branch**

```bash
git checkout -b feature/second-intake-prompt
```

**3. Make Changes**

- Edit component files
- Add/update translations
- Write/update tests
- Update documentation

**4. Test Changes**

```bash
# Type check
npm run type-check

# Lint
npm run lint

# Run tests
npm test

# Build check
npm run build
```

**5. Commit Changes**

```bash
git add .
git commit -m "feat: Add second intake prompt modal"
```

**Commit Message Format**:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting)
- `refactor:` - Code refactoring
- `test:` - Test additions/changes
- `chore:` - Build process, dependencies

**6. Push & Create Pull Request**

```bash
git push origin feature/second-intake-prompt
```

Then create PR on GitHub.

---

### Common Development Tasks

#### Adding a New Screen

**1. Create Component File**

```bash
touch src/components/screens/user/NewScreen.tsx
```

**2. Define Component**

```typescript
import React, { useState } from 'react';
import { useLanguage } from '../../LanguageContext';
import { Button } from '../../ui/button';
import { Card, CardHeader, CardTitle, CardContent } from '../../ui/card';

interface NewScreenProps {
  userId: string;
  onComplete: () => void;
}

export function NewScreen({ userId, onComplete }: NewScreenProps) {
  const { t } = useLanguage();
  const [loading, setLoading] = useState(false);
  
  return (
    <div className="container mx-auto p-4">
      <Card>
        <CardHeader>
          <CardTitle>{t('newScreen.title')}</CardTitle>
        </CardHeader>
        <CardContent>
          {/* Screen content */}
          <Button onClick={onComplete}>
            {t('common.continue')}
          </Button>
        </CardContent>
      </Card>
    </div>
  );
}
```

**3. Add Translations**

In `/src/translations/translations-data.ts`:

```typescript
export const translations = {
  en: {
    // ... existing translations
    'newScreen.title': 'New Screen Title',
    'newScreen.description': 'Screen description'
  },
  ar: {
    // ... existing translations
    'newScreen.title': 'عنوان الشاشة الجديدة',
    'newScreen.description': 'وصف الشاشة'
  }
};
```

**4. Add Route** (if applicable)

In `App.tsx`:

```typescript
import { NewScreen } from './components/screens/user/NewScreen';

// In component
<Routes>
  {/* Existing routes */}
  <Route path="/new-screen" element={<NewScreen userId={userId} onComplete={handleComplete} />} />
</Routes>
```

**5. Document Component**

Add to `/docs/4-code-documentation/component-reference.md`

---

#### Adding a New Utility Function

**1. Create/Update Utility File**

```bash
# New file
touch src/utils/newUtility.ts

# Or edit existing
code src/utils/injuryRules.ts
```

**2. Define Function with TypeScript**

```typescript
/**
 * Calculate user's BMI
 * @param weight - Weight in kg
 * @param height - Height in cm
 * @returns BMI value
 */
export function calculateBMI(weight: number, height: number): number {
  const heightInMeters = height / 100;
  return weight / (heightInMeters * heightInMeters);
}

/**
 * Get BMI category
 * @param bmi - BMI value
 * @returns Category string
 */
export function getBMICategory(bmi: number): string {
  if (bmi < 18.5) return 'Underweight';
  if (bmi < 25) return 'Normal';
  if (bmi < 30) return 'Overweight';
  return 'Obese';
}
```

**3. Write Unit Tests**

```typescript
// tests/unit/bmiUtils.test.ts
import { calculateBMI, getBMICategory } from '../../src/utils/bmiUtils';

describe('BMI Utilities', () => {
  test('calculates BMI correctly', () => {
    const bmi = calculateBMI(75, 175);
    expect(bmi).toBeCloseTo(24.49, 2);
  });
  
  test('categorizes BMI correctly', () => {
    expect(getBMICategory(18)).toBe('Underweight');
    expect(getBMICategory(22)).toBe('Normal');
    expect(getBMICategory(27)).toBe('Overweight');
    expect(getBMICategory(32)).toBe('Obese');
  });
});
```

**4. Document Function**

Add to `/docs/4-code-documentation/utilities-reference.md`

---

#### Adding Translation Keys

**1. Edit Translation Data**

```typescript
// src/translations/translations-data.ts

export const translations = {
  en: {
    // Add new keys in alphabetical order
    'feature.newKey': 'New English Text',
    'feature.anotherKey': 'Another Text'
  },
  ar: {
    // Add corresponding Arabic translations
    'feature.newKey': 'نص جديد بالعربية',
    'feature.anotherKey': 'نص آخر'
  }
};
```

**2. Use in Components**

```typescript
const { t } = useLanguage();

return (
  <div>
    <h1>{t('feature.newKey')}</h1>
    <p>{t('feature.anotherKey')}</p>
  </div>
);
```

**3. Verify Both Languages**

- Switch language in app
- Check both English and Arabic text render correctly
- Check RTL layout for Arabic

---

## Code Standards

### TypeScript Guidelines

**1. Always Use Types**

```typescript
// ✅ Good
interface UserData {
  id: string;
  name: string;
  age: number;
}

function getUser(id: string): UserData {
  // ...
}

// ❌ Bad
function getUser(id: any): any {
  // ...
}
```

**2. Use Type Unions for Fixed Values**

```typescript
// ✅ Good
type SubscriptionTier = 'Freemium' | 'Premium' | 'Smart Premium';

// ❌ Bad
let tier: string = 'Premium';
```

**3. Define Interfaces for Props**

```typescript
// ✅ Good
interface ButtonProps {
  label: string;
  onClick: () => void;
  variant?: 'primary' | 'secondary';
  disabled?: boolean;
}

export function Button({ label, onClick, variant = 'primary', disabled = false }: ButtonProps) {
  // ...
}

// ❌ Bad
export function Button(props: any) {
  // ...
}
```

---

### React Best Practices

**1. Use Functional Components**

```typescript
// ✅ Good
export function MyComponent({ prop1, prop2 }: MyComponentProps) {
  // ...
}

// ❌ Bad (class components)
export class MyComponent extends React.Component {
  // ...
}
```

**2. Extract Complex Logic to Hooks**

```typescript
// ✅ Good
function useQuotaStatus(userId: string) {
  const [status, setStatus] = useState<QuotaStatus | null>(null);
  
  useEffect(() => {
    fetchQuotaStatus(userId).then(setStatus);
  }, [userId]);
  
  return status;
}

function MyComponent({ userId }: Props) {
  const quotaStatus = useQuotaStatus(userId);
  // ...
}

// ❌ Bad (all logic in component)
function MyComponent({ userId }: Props) {
  const [status, setStatus] = useState<QuotaStatus | null>(null);
  
  useEffect(() => {
    fetchQuotaStatus(userId).then(setStatus);
  }, [userId]);
  // ...
}
```

**3. Memoize Expensive Calculations**

```typescript
import { useMemo } from 'react';

function MyComponent({ data }: Props) {
  const processedData = useMemo(() => {
    return expensiveProcessing(data);
  }, [data]);
  
  // ...
}
```

---

### Styling Guidelines

**1. Use Tailwind Utility Classes**

```typescript
// ✅ Good
<div className="p-4 bg-white rounded-lg shadow-md">
  <h1 className="text-2xl font-bold">Title</h1>
</div>

// ❌ Bad (inline styles)
<div style={{ padding: '16px', background: 'white' }}>
  <h1 style={{ fontSize: '24px', fontWeight: 'bold' }}>Title</h1>
</div>
```

**2. Responsive Design**

```typescript
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
  {/* Responsive grid: 1 col mobile, 2 cols tablet, 3 cols desktop */}
</div>
```

**3. RTL Support**

```typescript
<div className="text-left rtl:text-right pl-4 rtl:pr-4">
  {/* Left-aligned for English, right-aligned for Arabic */}
</div>
```

---

### Error Handling

**1. Try-Catch for Async Operations**

```typescript
async function handleSubmit() {
  try {
    setLoading(true);
    const result = await submitData(formData);
    toast.success(t('success.saved'));
  } catch (error) {
    console.error('Submit failed:', error);
    toast.error(t('errors.saveFailed'));
  } finally {
    setLoading(false);
  }
}
```

**2. Graceful Fallbacks**

```typescript
function UserProfile({ userId }: Props) {
  const [user, setUser] = useState<User | null>(null);
  const [error, setError] = useState<Error | null>(null);
  
  useEffect(() => {
    fetchUser(userId).then(setUser).catch(setError);
  }, [userId]);
  
  if (error) return <ErrorMessage error={error} />;
  if (!user) return <Skeleton />;
  
  return <div>{user.name}</div>;
}
```

---

## Testing Strategy

### Unit Tests

**Framework**: Vitest

**Run Tests**:
```bash
npm test
```

**Example Unit Test**:

```typescript
// tests/unit/fitnessScore.test.ts
import { describe, it, expect } from 'vitest';
import { calculateFitnessScore } from '../../src/utils/fitnessScore';

describe('Fitness Score Calculation', () => {
  it('calculates correct score for intermediate user', () => {
    const data = {
      age: 28,
      weight: 75,
      height: 175,
      experience: 'intermediate',
      frequency: 4,
      injuries: []
    };
    
    const score = calculateFitnessScore(data);
    expect(score).toBeGreaterThan(70);
    expect(score).toBeLessThan(90);
  });
  
  it('penalizes for injuries', () => {
    const withoutInjuries = calculateFitnessScore({
      age: 25, weight: 70, height: 175,
      experience: 'intermediate', frequency: 4, injuries: []
    });
    
    const withInjuries = calculateFitnessScore({
      age: 25, weight: 70, height: 175,
      experience: 'intermediate', frequency: 4, injuries: ['knee', 'shoulder']
    });
    
    expect(withInjuries).toBeLessThan(withoutInjuries);
  });
});
```

---

### Component Tests

**Framework**: React Testing Library

**Example Component Test**:

```typescript
// tests/component/Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from '../../src/components/ui/button';

describe('Button Component', () => {
  it('renders button with label', () => {
    render(<Button>Click Me</Button>);
    expect(screen.getByText('Click Me')).toBeInTheDocument();
  });
  
  it('calls onClick when clicked', () => {
    const handleClick = vi.fn();
    render(<Button onClick={handleClick}>Click Me</Button>);
    
    fireEvent.click(screen.getByText('Click Me'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });
  
  it('is disabled when disabled prop is true', () => {
    render(<Button disabled>Click Me</Button>);
    expect(screen.getByText('Click Me')).toBeDisabled();
  });
});
```

---

### End-to-End Tests

**Framework**: Playwright

**Run E2E Tests**:
```bash
npm run test:e2e
```

**Example E2E Test**:

```typescript
// tests/e2e/auth-flow.spec.ts
import { test, expect } from '@playwright/test';

test('complete authentication flow', async ({ page }) => {
  // Navigate to app
  await page.goto('http://localhost:5173');
  
  // Select language
  await page.click('text=English');
  
  // Skip intro
  await page.click('text=Skip');
  
  // Enter phone number
  await page.fill('input[name="phoneNumber"]', '512345678');
  await page.click('text=Send OTP');
  
  // Enter OTP (mock)
  await page.fill('input[name="otp"]', '123456');
  await page.click('text=Verify');
  
  // Should navigate to first intake
  await expect(page).toHaveURL(/.*first-intake/);
});
```

---

## Build & Deployment

### Development Build

```bash
npm run dev
```

Starts local development server with:
- Hot module replacement (HMR)
- Source maps
- Fast refresh

---

### Production Build

```bash
npm run build
```

Creates optimized production build in `/dist`:
- Minified JavaScript
- Optimized CSS
- Tree-shaking (removes unused code)
- Code splitting
- Asset optimization

**Build Output**:
```
dist/
├── assets/
│   ├── index-[hash].js
│   ├── index-[hash].css
│   └── [other-chunks].js
├── index.html
└── ...
```

---

### Preview Production Build

```bash
npm run preview
```

Serves production build locally for testing.

---

### Deployment Options

#### Option 1: Vercel (Recommended)

**1. Install Vercel CLI**:
```bash
npm i -g vercel
```

**2. Deploy**:
```bash
vercel
```

**3. Production Deploy**:
```bash
vercel --prod
```

**Auto Deployment**:
- Connect GitHub repo to Vercel
- Automatic deploys on push to `main`

---

#### Option 2: Netlify

**1. Install Netlify CLI**:
```bash
npm i -g netlify-cli
```

**2. Deploy**:
```bash
netlify deploy
```

**3. Production Deploy**:
```bash
netlify deploy --prod
```

---

#### Option 3: AWS S3 + CloudFront

**1. Build**:
```bash
npm run build
```

**2. Upload to S3**:
```bash
aws s3 sync dist/ s3://your-bucket-name --delete
```

**3. Invalidate CloudFront**:
```bash
aws cloudfront create-invalidation --distribution-id YOUR_DIST_ID --paths "/*"
```

---

### CI/CD Pipeline

**GitHub Actions** (`.github/workflows/ci.yml`):

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Type check
        run: npm run type-check
      
      - name: Lint
        run: npm run lint
      
      - name: Test
        run: npm test
      
      - name: Build
        run: npm run build
```

---

## Troubleshooting

### Common Issues

#### Issue: Build Fails with TypeScript Errors

**Solution**:
```bash
# Clean install
rm -rf node_modules package-lock.json
npm install

# Check TypeScript
npm run type-check
```

---

#### Issue: Tailwind Styles Not Applying

**Solution**:
1. Check `tailwind.config.js` includes all content paths
2. Verify `globals.css` imports Tailwind directives:
```css
@import 'tailwindcss';
```

---

#### Issue: Translation Keys Not Found

**Solution**:
1. Check key exists in `translations-data.ts`
2. Verify both `en` and `ar` have the key
3. Restart dev server

---

#### Issue: Hot Reload Not Working

**Solution**:
```bash
# Clear Vite cache
rm -rf node_modules/.vite

# Restart dev server
npm run dev
```

---

## Performance Optimization

### Bundle Size Optimization

**1. Analyze Bundle**:
```bash
npm run build -- --mode analyze
```

**2. Code Splitting**:
```typescript
// Lazy load heavy components
import { lazy, Suspense } from 'react';

const CoachDashboard = lazy(() => import('./components/coach/CoachDashboardScreen'));

function App() {
  return (
    <Suspense fallback={<LoadingSpinner />}>
      <CoachDashboard />
    </Suspense>
  );
}
```

**3. Tree Shaking**:
```typescript
// ✅ Good - imports only what's needed
import { Button } from './ui/button';

// ❌ Bad - imports entire library
import * as UI from './ui';
```

---

### Image Optimization

**1. Use WebP Format**:
```bash
# Convert images to WebP
npm install -g imagemin-cli imagemin-webp
imagemin input.jpg --plugin=webp > output.webp
```

**2. Lazy Load Images**:
```typescript
<img 
  src="image.jpg" 
  loading="lazy"
  alt="Description"
/>
```

**3. Responsive Images**:
```typescript
<img
  src="image-1920.jpg"
  srcSet="image-640.jpg 640w, image-1024.jpg 1024w, image-1920.jpg 1920w"
  sizes="(max-width: 640px) 640px, (max-width: 1024px) 1024px, 1920px"
  alt="Description"
/>
```

---

### React Performance

**1. Memo Components**:
```typescript
import { memo } from 'react';

export const ExpensiveComponent = memo(({ data }: Props) => {
  // Only re-renders if data changes
  return <div>{/* ... */}</div>;
});
```

**2. Use Callbacks**:
```typescript
import { useCallback } from 'react';

function Parent() {
  const handleClick = useCallback(() => {
    // Handler logic
  }, []);
  
  return <Child onClick={handleClick} />;
}
```

---

**End of Development Guide**
