# Code Documentation

## Overview
This folder contains detailed code-level documentation for the عاش (FitCoach+ v2.0) fitness application. These documents explain implementation details, code organization, and provide guidance for developers working with the codebase.

## Purpose
- Document code structure and organization
- Explain implementation patterns
- Provide API references for internal modules
- Guide new developers in contributing
- Maintain code quality and consistency
- Enable efficient code maintenance

## Document Organization

### 📄 [component-reference.md](./component-reference.md) (~20,000 words)
Complete reference for all React components:
- **User Screen Components** (12 screens) - Language selection to progress tracking
- **Coach Screen Components** (6 screens) - Dashboard to performance metrics
- **Admin Screen Components** (8 screens) - Platform management and analytics
- **Shared Components** - QuotaDisplay, NutritionExpiryBanner, UpgradePrompt
- **UI Components** (40+ Radix-based) - Button, Dialog, Card, Input, etc.
- **Component Patterns** - Screen wrappers, form handling, conditional rendering
- Props documentation, state management, usage examples

### 📄 [utilities-reference.md](./utilities-reference.md) (~15,000 words)
Complete reference for utility functions and business logic:
- **Injury Substitution Engine** - Exercise safety checks and alternatives
- **Quota Management** - Message and call limit enforcement
- **Nutrition Expiry** - Trial management for Freemium users
- **Phone Validation** - Saudi number format validation
- **Fitness Score Calculation** - 0-100 score algorithm
- **Translation System** - Bilingual support (Arabic/English)
- **Date & Time Utilities** - Formatting and relative time
- **Storage Utilities** - localStorage helpers
- **Validation Utilities** - Input validators
- **API Helpers** - HTTP request wrappers
- Full function signatures, examples, edge cases

### 📄 [development-guide.md](./development-guide.md) (~10,000 words)
Complete setup and development workflow guide:
- **Environment Setup** - Prerequisites, installation, configuration
- **Project Structure** - Directory organization and file conventions
- **Development Workflow** - Daily cycle, branching, commits
- **Code Standards** - TypeScript, React, styling guidelines
- **Testing Strategy** - Unit, component, E2E tests
- **Build & Deployment** - Development, production, CI/CD
- **Troubleshooting** - Common issues and solutions
- **Performance Optimization** - Bundle size, images, React performance

## Codebase Structure

```
/
├── App.tsx                    # Main application entry point
├── main.tsx                   # Vite entry point
│
├── components/                # All React components
│   ├── screens/              # Main screen components (28 screens)
│   │   ├── user/            # End user screens (12)
│   │   ├── coach/           # Coach screens (6)
│   │   └── admin/           # Admin screens (8)
│   │
│   ├── ui/                   # Reusable UI components (40+)
│   │   ├── button.tsx
│   │   ├── dialog.tsx
│   │   ├── card.tsx
│   │   └── ...
│   │
│   ├── LanguageContext.tsx   # Internationalization context
│   ├── QuotaDisplay.tsx      # Quota usage component
│   ├── NutritionExpiryBanner.tsx
│   └── ...
│
├── utils/                     # Utility functions
│   ├── injuryRules.ts        # Injury substitution logic
│   ├── nutritionExpiry.ts    # Nutrition access control
│   ├── phoneValidation.ts    # Phone number validation
│   └── ...
│
├── types/                     # TypeScript type definitions
│   ├── IntakeTypes.ts        # Intake data structures
│   ├── QuotaTypes.ts         # Quota types
│   ├── InBodyTypes.ts        # InBody types
│   └── ...
│
├── translations/              # Internationalization data
│   ├── translations-data.ts  # 2,904 translation keys
│   ├── common.ts
│   └── index.ts
│
├── styles/
│   └── globals.css           # Global styles and Tailwind setup
│
└── docs/                      # Documentation (this folder)
```

## Code Organization Principles

### 1. File Naming Conventions

**Components** (PascalCase)
```
HomeScreen.tsx
WorkoutPlanBuilder.tsx
QuotaDisplay.tsx
```

**Utilities** (camelCase)
```
injuryRules.ts
phoneValidation.ts
nutritionExpiry.ts
```

**Types** (PascalCase for files, interfaces)
```
IntakeTypes.ts
  → interface FirstIntakeData
  → interface SecondIntakeData
```

**Styles** (kebab-case)
```
globals.css
```

### 2. Component Structure

Standard component file organization:

```typescript
// 1. Imports
import React, { useState, useEffect } from 'react';
import { Button } from './ui/button';
import { useLanguage } from './LanguageContext';

// 2. Type Definitions
interface ComponentProps {
  prop1: string;
  prop2?: number;
}

// 3. Component Definition
export function ComponentName({ prop1, prop2 = 0 }: ComponentProps) {
  // 3a. Hooks
  const { t, language } = useLanguage();
  const [state, setState] = useState<string>('');
  
  useEffect(() => {
    // side effects
  }, []);
  
  // 3b. Event Handlers
  const handleClick = () => {
    // logic
  };
  
  // 3c. Derived Values
  const computedValue = useMemo(() => {
    return heavyComputation(state);
  }, [state]);
  
  // 3d. Conditional Returns
  if (loading) return <Skeleton />;
  if (error) return <ErrorMessage />;
  
  // 3e. Main Render
  return (
    <div className="container">
      {/* JSX */}
    </div>
  );
}
```

### 3. State Management

**Local State** (Component-specific)
```typescript
const [count, setCount] = useState<number>(0);
```

**Context State** (Global shared state)
```typescript
const LanguageContext = createContext<LanguageContextType | undefined>(undefined);

export function LanguageProvider({ children }) {
  const [language, setLanguage] = useState<Language>('en');
  // ... provider logic
}
```

**Persistent State** (LocalStorage)
```typescript
localStorage.setItem('fitcoach_language', 'ar');
localStorage.getItem('fitcoach_language'); // 'ar'
```

### 4. Type Safety

**Interface Definitions**
```typescript
interface UserProfile {
  id: string;
  name: string;
  phoneNumber: string;
  subscriptionTier: SubscriptionTier;
  // ... more fields
}
```

**Type Unions**
```typescript
type SubscriptionTier = 'Freemium' | 'Premium' | 'Smart Premium';
type InjuryArea = 'shoulder' | 'knee' | 'lower_back' | 'neck' | 'ankle';
```

**Function Signatures**
```typescript
function calculateFitnessScore(data: SecondIntakeData): number {
  // implementation
}
```

### 5. Internationalization

**Translation Keys**
```typescript
// Access translation
const { t } = useLanguage();
const greeting = t('home.greeting'); // "Good Morning" or "صباح الخير"
```

**Translation Structure**
```typescript
const translations = {
  en: {
    'home.greeting': 'Good Morning',
    'home.startWorkout': 'Start Workout'
  },
  ar: {
    'home.greeting': 'صباح الخير',
    'home.startWorkout': 'ابدأ التمرين'
  }
};
```

### 6. Error Handling

**Try-Catch Blocks**
```typescript
try {
  const result = await api.sendMessage(content);
  toast.success('Message sent!');
} catch (error) {
  console.error('Failed to send message:', error);
  toast.error(t('errors.sendMessageFailed'));
}
```

**Error Boundaries** (React 18)
```typescript
<ErrorBoundary fallback={<ErrorScreen />}>
  <App />
</ErrorBoundary>
```

### 7. Styling (Tailwind CSS)

**Responsive Classes**
```tsx
<div className="p-4 md:p-6 lg:p-8">
  {/* Padding increases on larger screens */}
</div>
```

**Conditional Classes**
```tsx
<button className={`btn ${isPrimary ? 'bg-blue-600' : 'bg-gray-600'}`}>
  Click Me
</button>
```

**RTL Support**
```tsx
<div className="text-left rtl:text-right">
  {/* Left-aligned for English, right-aligned for Arabic */}
</div>
```

## Key Code Modules

### 1. Injury Substitution Engine (`/utils/injuryRules.ts`)

**Purpose**: Detect exercises contraindicated for user's injuries and suggest safe alternatives.

**Key Functions**:
- `getContraindicatedExercises(injuries: InjuryArea[]): Exercise[]`
- `getSafeAlternatives(exercise: Exercise, injury: InjuryArea): Exercise[]`
- `isExerciseSafe(exercise: Exercise, injuries: InjuryArea[]): boolean`

**Example**:
```typescript
const userInjuries: InjuryArea[] = ['knee'];
const workout = getWorkoutPlan(userId);

workout.exercises.forEach(exercise => {
  if (!isExerciseSafe(exercise, userInjuries)) {
    const alternatives = getSafeAlternatives(exercise, 'knee');
    console.log(`Replace ${exercise.name} with ${alternatives[0].name}`);
  }
});
```

### 2. Quota Management (`/utils/quotaEnforcement.ts`)

**Purpose**: Enforce message and call limits based on subscription tier.

**Key Functions**:
- `checkQuota(userId: string, action: 'message' | 'call'): QuotaCheckResult`
- `incrementQuota(userId: string, action: 'message' | 'call'): void`
- `resetMonthlyQuotas(): void` (scheduled job)

**Example**:
```typescript
const quotaCheck = await checkQuota(userId, 'message');

if (!quotaCheck.allowed) {
  showUpgradePrompt({
    message: 'Message quota exceeded. Upgrade to send more messages.',
    currentTier: user.subscriptionTier
  });
  return;
}

// Quota available, send message
await sendMessage(content, conversationId);
await incrementQuota(userId, 'message');
```

### 3. Nutrition Expiry (`/utils/nutritionExpiry.ts`)

**Purpose**: Manage time-limited nutrition access for Freemium users.

**Key Functions**:
- `getNutritionAccessStatus(userId: string): NutritionAccessStatus`
- `startNutritionTrial(userId: string): void`
- `checkNutritionExpiry(userId: string): { isExpired: boolean; daysLeft: number }`

**Example**:
```typescript
const accessStatus = await getNutritionAccessStatus(userId);

if (accessStatus.isExpired) {
  return <UpgradePromptScreen message="Nutrition trial expired" />;
}

if (accessStatus.daysLeft <= 2) {
  showExpiryBanner({
    daysLeft: accessStatus.daysLeft,
    message: `${accessStatus.daysLeft} days left in nutrition trial`
  });
}

// Show nutrition screen
return <NutritionScreen />;
```

### 4. Phone Validation (`/utils/phoneValidation.ts`)

**Purpose**: Validate Saudi phone numbers for OTP authentication.

**Key Functions**:
- `validateSaudiPhone(phone: string): ValidationResult`
- `formatPhoneNumber(phone: string): string`

**Example**:
```typescript
const phone = "512345678";
const validation = validateSaudiPhone(phone);

if (!validation.isValid) {
  showError(validation.error); // "Phone number must start with 5"
  return;
}

// Phone valid, send OTP
const formatted = validation.formatted; // "+966512345678"
await sendOTP(formatted);
```

## Development Guidelines

### 1. Adding a New Screen Component

1. Create file in `/components/` (e.g., `NewScreen.tsx`)
2. Define component props interface
3. Implement component with hooks
4. Add translations to `/translations/translations-data.ts`
5. Import and integrate in `App.tsx`
6. Test in both English and Arabic
7. Test responsiveness (mobile, tablet, desktop)
8. Document in this folder

### 2. Adding a New Utility Function

1. Create file in `/utils/` (e.g., `newUtility.ts`)
2. Define input/output types
3. Implement function with error handling
4. Write unit tests
5. Document with JSDoc comments
6. Export from file
7. Document in this folder

### 3. Adding New Types

1. Create/update file in `/types/` (e.g., `NewTypes.ts`)
2. Define interfaces with clear field names
3. Add JSDoc comments for complex fields
4. Export types
5. Use throughout codebase
6. Document in this folder

### 4. Adding Translation Keys

1. Open `/translations/translations-data.ts`
2. Add keys in both English and Arabic:
```typescript
'newFeature.title': 'New Feature',
'newFeature.description': 'Feature description',
```
3. Use in components: `t('newFeature.title')`
4. Test in both languages

### 5. Code Review Checklist

- [ ] TypeScript types defined for all data
- [ ] Error handling implemented
- [ ] Translations added for all user-facing text
- [ ] Component props documented
- [ ] Responsive design tested (mobile/tablet/desktop)
- [ ] RTL layout tested for Arabic
- [ ] Accessibility considered (ARIA labels, keyboard nav)
- [ ] No console.logs in production code
- [ ] Code follows existing patterns
- [ ] Documentation updated

## Testing Strategy

### Unit Tests
- Test utility functions (injuryRules, quotaEnforcement)
- Test validation functions (phoneValidation)
- Test business logic calculations (fitnessScore)

### Component Tests
- Test component rendering
- Test user interactions (clicks, form inputs)
- Test conditional rendering (loading, error states)
- Test prop variations

### Integration Tests
- Test screen navigation flows
- Test data flow between components
- Test API integration (mock responses)

### End-to-End Tests
- Test complete user journeys (signup to workout)
- Test tier upgrade flows
- Test quota enforcement

## Code Quality Tools

### TypeScript Compiler
```bash
npx tsc --noEmit  # Type check without building
```

### ESLint
```bash
npm run lint      # Check code style
npm run lint:fix  # Auto-fix issues
```

### Prettier
```bash
npm run format    # Format code
```

## Performance Profiling

### React DevTools Profiler
- Identify slow components
- Optimize re-renders
- Measure rendering time

### Chrome DevTools Performance
- Analyze bundle size
- Identify long tasks
- Check memory usage

### Lighthouse
- Test performance score
- Check accessibility
- SEO optimization

## Common Patterns & Solutions

### Pattern 1: Conditional Screen Rendering

```typescript
// Check if user is Premium+ before showing screen
if (userProfile.subscriptionTier === 'Freemium') {
  return <UpgradePromptScreen requiredTier="Premium" />;
}

// Premium+ users see actual screen
return <SecondIntakeScreen />;
```

### Pattern 2: Loading States

```typescript
if (loading) return <Skeleton />;
if (error) return <ErrorMessage error={error} />;
if (!data) return null;

return <DataDisplay data={data} />;
```

### Pattern 3: Form Validation

```typescript
const [errors, setErrors] = useState<Record<string, string>>({});

const validate = () => {
  const newErrors: Record<string, string> = {};
  
  if (!name) newErrors.name = 'Name is required';
  if (age < 13) newErrors.age = 'Must be at least 13';
  
  setErrors(newErrors);
  return Object.keys(newErrors).length === 0;
};

const handleSubmit = () => {
  if (!validate()) return;
  // proceed with submission
};
```

### Pattern 4: Async Data Fetching

```typescript
useEffect(() => {
  let isMounted = true;
  
  async function fetchData() {
    try {
      setLoading(true);
      const data = await api.getData();
      if (isMounted) {
        setData(data);
      }
    } catch (error) {
      if (isMounted) {
        setError(error);
      }
    } finally {
      if (isMounted) {
        setLoading(false);
      }
    }
  }
  
  fetchData();
  
  return () => {
    isMounted = false;
  };
}, []);
```

## Document Maintenance

- **Owner**: Development Team Lead
- **Review Frequency**: Weekly during active development
- **Last Updated**: December 2024 (v2.0)
- **Status**: Living Document

## Contributing

To add code documentation:
1. Create markdown file in appropriate subfolder
2. Follow existing documentation format
3. Include code examples and usage
4. Update this README with links
5. Submit for review

---

**Next**: Explore subfolders for detailed component, utility, and type documentation.