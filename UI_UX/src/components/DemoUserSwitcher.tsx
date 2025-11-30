import React, { useState } from 'react';
import { Card, CardContent } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Info, Users, X } from 'lucide-react';
import { useLanguage } from './LanguageContext';

interface DemoUserSwitcherProps {
  currentPhoneNumber: string;
}

export function DemoUserSwitcher({ currentPhoneNumber }: DemoUserSwitcherProps) {
  const { t, isRTL } = useLanguage();
  const [isExpanded, setIsExpanded] = useState(false);

  if (!isExpanded) {
    return (
      <div className="fixed bottom-4 right-4 z-40">
        <Button
          variant="outline"
          size="sm"
          onClick={() => setIsExpanded(true)}
          className="shadow-lg bg-white hover:bg-gray-50"
        >
          <Users className="w-4 h-4 mr-2" />
          Multi-User Testing
        </Button>
      </div>
    );
  }

  return (
    <div className="fixed bottom-4 right-4 z-40">
      <Card className="w-80 shadow-xl">
        <CardContent className="p-4">
          <div className="flex items-start justify-between mb-3">
            <div className="flex items-center gap-2">
              <Info className="w-5 h-5 text-blue-600" />
              <h3 className="font-semibold">Multi-User Testing</h3>
            </div>
            <Button
              variant="ghost"
              size="icon"
              onClick={() => setIsExpanded(false)}
              className="h-6 w-6 -mt-1 -mr-1"
            >
              <X className="w-4 h-4" />
            </Button>
          </div>

          <div className="space-y-3 text-sm">
            <div>
              <p className="text-muted-foreground mb-1">Current User:</p>
              <Badge variant="outline" className="font-mono">
                {currentPhoneNumber}
              </Badge>
            </div>

            <div className="p-3 bg-blue-50 rounded-lg space-y-2">
              <p className="font-medium text-blue-900">💡 Testing Tip</p>
              <p className="text-blue-800 text-xs">
                Each phone number has independent data. To test as a different user:
              </p>
              <ol className="list-decimal list-inside text-xs text-blue-800 space-y-1 pl-2">
                <li>Log out (Account → Logout)</li>
                <li>Log in with a different number</li>
                <li>New user sees fresh onboarding</li>
              </ol>
            </div>

            <div className="text-xs text-muted-foreground space-y-1">
              <p className="font-medium">Example phone numbers:</p>
              <div className="font-mono space-y-0.5 text-xs">
                <div>• +966501234567</div>
                <div>• +966507654321</div>
                <div>• +966509876543</div>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
