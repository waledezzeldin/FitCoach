import 'package:fitcoach_plus/models/quota_models.dart';
import 'package:fitcoach_plus/screens/coach/coach_schedule_screen.dart';
import 'package:fitcoach_plus/services/coach_service.dart';
import 'package:fitcoach_plus/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final coach = {'id': 'coach-1', 'name': 'Coach Sam'};
  const slotIso = '2025-01-01T08:00:00.000Z';
  const slotLabel = '8:00 AM';

  testWidgets('shows quota warning and disables slots when calls are exhausted', (tester) async {
    final app = _TestAppState()
      ..user = {'id': 'user-1'}
      ..quotaSnapshot = _snapshot(callsUsed: 2, callLimit: 2);
    final service = _StubCoachService(availability: [
      {
        'date': 'Mon, Jan 1',
        'slots': [
          {'label': slotLabel, 'iso': slotIso},
        ],
      },
    ]);

    await tester.pumpWidget(_wrap(app, CoachScheduleScreen(coach: coach, coachService: service)));
    await tester.pumpAndSettle();

    expect(
      find.text('You have reached your video session quota. Upgrade to Smart Premium for more.'),
      findsOneWidget,
    );

    final disabledButton =
        tester.widget<OutlinedButton>(find.widgetWithText(OutlinedButton, slotLabel));
    expect(disabledButton.onPressed, isNull);
    expect(service.availabilityCalls, 1);
  });

  testWidgets('books a slot and refreshes quota when taps succeed', (tester) async {
    final app = _TestAppState()
      ..user = {'id': 'user-1'}
      ..quotaSnapshot = _snapshot(callsUsed: 0, callLimit: 2);
    final service = _StubCoachService(availability: [
      {
        'date': 'Mon, Jan 1',
        'slots': [
          {'label': slotLabel, 'iso': slotIso},
        ],
      },
    ]);

    await tester.pumpWidget(_wrap(app, CoachScheduleScreen(coach: coach, coachService: service)));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, slotLabel));
    await tester.pump();
    await tester.pump();

    expect(service.bookCalls, 1);
    expect(service.bookedSlots.single, slotIso);
    expect(app.quotaRefreshCount, 1);

    await tester.pump();
    expect(find.text('Session booked!'), findsOneWidget);
  });
}

Widget _wrap(AppState app, Widget child) {
  return MaterialApp(
    home: AppStateScope(
      notifier: app,
      child: child,
    ),
  );
}

QuotaSnapshot _snapshot({required int callsUsed, required int callLimit}) {
  return QuotaSnapshot(
    userId: 'user-1',
    tier: SubscriptionTier.premium,
    usage: QuotaUsage(
      messagesUsed: 0,
      callsUsed: callsUsed,
      attachmentsUsed: 0,
      resetAt: DateTime(2025, 1, 15),
    ),
    limits: QuotaLimits(
      messages: 200,
      calls: callLimit,
      callDuration: 30,
      chatAttachments: true,
      nutritionPersistent: true,
      nutritionWindowDays: 30,
    ),
  );
}

class _TestAppState extends AppState {
  _TestAppState() : super(enableNetworkSync: false);

  int quotaRefreshCount = 0;

  @override
  Future<void> refreshQuota({bool force = false}) async {
    quotaRefreshCount += 1;
  }
}

class _StubCoachService extends CoachService {
  _StubCoachService({required List<Map<String, dynamic>> availability})
      : _availability = availability;

  final List<Map<String, dynamic>> _availability;
  int availabilityCalls = 0;
  int bookCalls = 0;
  final List<String> bookedSlots = <String>[];

  @override
  Future<Map<String, dynamic>> availability(String coachId, {int days = 7}) async {
    availabilityCalls += 1;
    return {'availability': _availability};
  }

  @override
  Future<Map<String, dynamic>> bookSession({
    required String coachId,
    required String userId,
    required DateTime start,
    int durationMinutes = 30,
  }) async {
    bookCalls += 1;
    bookedSlots.add(start.toIso8601String());
    return {'status': 'ok'};
  }
}
