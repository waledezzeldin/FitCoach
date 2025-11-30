import React from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { UserProfile } from '../App';

interface NutritionDebugPanelProps {
  userProfile: UserProfile;
  onClose: () => void;
}

export function NutritionDebugPanel({ userProfile, onClose }: NutritionDebugPanelProps) {
  const [flags, setFlags] = React.useState(() => {
    return {
      pendingIntake: localStorage.getItem(`pending_nutrition_intake_${userProfile.phoneNumber}`),
      completed: localStorage.getItem(`nutrition_preferences_completed_${userProfile.phoneNumber}`),
      wasFreemium: localStorage.getItem(`was_freemium_${userProfile.phoneNumber}`),
      preferences: localStorage.getItem(`nutrition_preferences_${userProfile.phoneNumber}`)
    };
  });

  const refreshFlags = () => {
    setFlags({
      pendingIntake: localStorage.getItem(`pending_nutrition_intake_${userProfile.phoneNumber}`),
      completed: localStorage.getItem(`nutrition_preferences_completed_${userProfile.phoneNumber}`),
      wasFreemium: localStorage.getItem(`was_freemium_${userProfile.phoneNumber}`),
      preferences: localStorage.getItem(`nutrition_preferences_${userProfile.phoneNumber}`)
    });
  };

  const clearAllFlags = () => {
    localStorage.removeItem(`pending_nutrition_intake_${userProfile.phoneNumber}`);
    localStorage.removeItem(`nutrition_preferences_completed_${userProfile.phoneNumber}`);
    localStorage.removeItem(`was_freemium_${userProfile.phoneNumber}`);
    localStorage.removeItem(`nutrition_preferences_${userProfile.phoneNumber}`);
    refreshFlags();
    alert('✅ All nutrition flags cleared!\n\nNext steps:\n1. Navigate back to home\n2. Go to nutrition screen again\n3. You will see the welcome screen → intake flow');
  };

  const resetForNewUser = () => {
    if (confirm('This will reset ALL nutrition data for this user.\n\nAre you sure?')) {
      clearAllFlags();
    }
  };

  const simulateUpgrade = () => {
    localStorage.setItem(`pending_nutrition_intake_${userProfile.phoneNumber}`, 'true');
    localStorage.removeItem(`nutrition_preferences_completed_${userProfile.phoneNumber}`);
    refreshFlags();
    alert('Simulated upgrade! Navigate to nutrition screen to see intake.');
  };

  const markAsCompleted = () => {
    localStorage.setItem(`nutrition_preferences_completed_${userProfile.phoneNumber}`, 'true');
    localStorage.removeItem(`pending_nutrition_intake_${userProfile.phoneNumber}`);
    refreshFlags();
    alert('Marked as completed! Reload nutrition screen.');
  };

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
      <Card className="w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <CardHeader>
          <div className="flex items-center justify-between">
            <CardTitle>Nutrition Debug Panel</CardTitle>
            <Button variant="ghost" size="sm" onClick={onClose}>Close</Button>
          </div>
        </CardHeader>
        <CardContent className="space-y-4">
          {/* User Info */}
          <div className="p-3 bg-gray-100 rounded">
            <h3 className="font-semibold mb-2">User Info</h3>
            <div className="space-y-1 text-sm">
              <div>Phone: <Badge variant="outline">{userProfile.phoneNumber}</Badge></div>
              <div>Tier: <Badge>{userProfile.subscriptionTier}</Badge></div>
            </div>
          </div>

          {/* LocalStorage Flags */}
          <div className="p-3 bg-blue-50 rounded">
            <div className="flex items-center justify-between mb-2">
              <h3 className="font-semibold">LocalStorage Flags</h3>
              <Button variant="outline" size="sm" onClick={refreshFlags}>Refresh</Button>
            </div>
            <div className="space-y-2 text-sm font-mono">
              <div className="flex items-center justify-between">
                <span>pending_nutrition_intake:</span>
                <Badge variant={flags.pendingIntake === 'true' ? 'default' : 'secondary'}>
                  {flags.pendingIntake || 'null'}
                </Badge>
              </div>
              <div className="flex items-center justify-between">
                <span>nutrition_preferences_completed:</span>
                <Badge variant={flags.completed === 'true' ? 'default' : 'secondary'}>
                  {flags.completed || 'null'}
                </Badge>
              </div>
              <div className="flex items-center justify-between">
                <span>was_freemium:</span>
                <Badge variant={flags.wasFreemium === 'true' ? 'default' : 'secondary'}>
                  {flags.wasFreemium || 'null'}
                </Badge>
              </div>
              <div className="flex items-center justify-between">
                <span>preferences_data:</span>
                <Badge variant={flags.preferences ? 'default' : 'secondary'}>
                  {flags.preferences ? 'EXISTS' : 'null'}
                </Badge>
              </div>
            </div>
          </div>

          {/* Expected Behavior */}
          <div className="p-3 bg-green-50 rounded">
            <h3 className="font-semibold mb-2">Expected Behavior</h3>
            <div className="text-sm space-y-2">
              {userProfile.subscriptionTier === 'Freemium' && (
                <div className="text-red-600">
                  ❌ Freemium users should see LOCKED nutrition screen
                </div>
              )}
              {userProfile.subscriptionTier !== 'Freemium' && flags.completed !== 'true' && (
                <div className="text-green-600">
                  ✅ Should show WELCOME/INTAKE screen
                </div>
              )}
              {userProfile.subscriptionTier !== 'Freemium' && flags.completed === 'true' && (
                <div className="text-blue-600">
                  ✅ Should show NUTRITION TRACKING screen
                </div>
              )}
              {flags.pendingIntake === 'true' && (
                <div className="text-orange-600">
                  ⚠️ Pending intake flag detected - user should see intake on next visit
                </div>
              )}
            </div>
          </div>

          {/* Actions */}
          <div className="space-y-2">
            <h3 className="font-semibold">Quick Actions</h3>
            <div className="grid grid-cols-2 gap-2">
              <Button 
                variant="outline" 
                size="sm" 
                onClick={simulateUpgrade}
                disabled={userProfile.subscriptionTier === 'Freemium'}
              >
                Simulate Upgrade
              </Button>
              <Button 
                variant="outline" 
                size="sm" 
                onClick={markAsCompleted}
              >
                Mark as Completed
              </Button>
              <Button 
                variant="destructive" 
                size="sm" 
                onClick={resetForNewUser}
                className="col-span-2"
              >
                🔄 Reset for New User Testing
              </Button>
            </div>
          </div>

          {/* Testing Instructions */}
          <div className="p-3 bg-purple-50 rounded">
            <h3 className="font-semibold mb-2">📋 Testing Different Users</h3>
            <div className="text-sm space-y-2 text-gray-700">
              <p className="font-medium">To test as a different user:</p>
              <ol className="list-decimal list-inside space-y-1 pl-2">
                <li>Log out from current user</li>
                <li>Log in with a different phone number</li>
                <li>Each phone number has its own nutrition data</li>
                <li>Premium users see Welcome → Intake → Tracking</li>
                <li>Freemium users see Locked screen</li>
              </ol>
              <p className="text-xs mt-2 text-gray-500">
                💡 Tip: Use the "Reset for New User Testing" button to clear current user's data and test the intake flow again
              </p>
            </div>
          </div>

          {/* Console Logs */}
          <div className="p-3 bg-yellow-50 rounded">
            <h3 className="font-semibold mb-2">Console Logs</h3>
            <p className="text-sm text-gray-600">
              Open browser DevTools (F12) and check the Console tab for detailed logs
              starting with <code className="bg-gray-200 px-1 rounded">[NutritionScreen]</code>
            </p>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
