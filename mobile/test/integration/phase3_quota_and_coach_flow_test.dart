import 'package:fitcoach_plus/models/home_summary.dart';
import 'package:fitcoach_plus/models/quota_models.dart';
import 'package:fitcoach_plus/services/home_summary_service.dart';
import 'package:fitcoach_plus/services/quota_service.dart';
import 'package:fitcoach_plus/state/app_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/mock_secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final secureStorageMock = MockSecureStorageChannel()..install();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    secureStorageMock.reset();
  });

  test('phase 3 flow hydrates and throttles coach quota lookups', () async {
    final quotaService = _RecordingQuotaService(snapshot: _buildQuotaSnapshot());
    final homeSummaryService = _FakeHomeSummaryService(summary: _buildHomeSummary());
    final app = AppState(
      enableNetworkSync: false,
      quotaService: quotaService,
      homeSummaryService: homeSummaryService,
    );
    await app.load();

    await app.signIn(user: {'id': 'phase3-user', 'role': 'member'});
    await pumpEventQueue();

    expect(quotaService.callCount, 1);
    expect(app.quotaSnapshot?.usage.messagesUsed, 2);

    await app.refreshQuota();
    expect(quotaService.callCount, 1, reason: 'cached quota should skip duplicate fetches within 5 minutes');

    await app.refreshQuota(force: true);
    expect(quotaService.callCount, 2, reason: 'force flag bypasses cache window');

    await app.signOut();
    expect(app.quotaSnapshot, isNull, reason: 'sign out should drop quota snapshots');

    await app.signIn(user: {'id': 'phase3-user'});
    await pumpEventQueue();

    expect(quotaService.callCount, 3, reason: 'new session should fetch quota again');
    expect(quotaService.requestedUserIds.where((id) => id == 'phase3-user').length, 3);
  });
}

QuotaSnapshot _buildQuotaSnapshot() {
  return QuotaSnapshot(
    userId: 'phase3-user',
    tier: SubscriptionTier.premium,
    usage: QuotaUsage(
      messagesUsed: 2,
      callsUsed: 0,
      attachmentsUsed: 0,
      resetAt: DateTime.now().add(const Duration(days: 10)),
    ),
    limits: const QuotaLimits(
      messages: 200,
      calls: 2,
      callDuration: 30,
      chatAttachments: true,
      nutritionPersistent: true,
      nutritionWindowDays: 14,
    ),
  );
}

HomeSummary _buildHomeSummary() {
  return HomeSummary(
    userId: 'phase3-user',
    generatedAt: DateTime.now(),
    quickStats: const HomeQuickStats(
      workoutsCompletedWeek: 2,
      caloriesBurnedWeek: 900,
      caloriesConsumedToday: 1200,
      targetCalories: 2100,
      streakDays: 3,
      programWeek: 5,
      nutritionAdherencePct: 70,
    ),
    macros: const HomeMacroSummary.placeholder(),
    weeklyProgress: const HomeWeeklyProgress(
      completionPct: 40,
      completedSessions: 2,
      targetSessions: 5,
    ),
    quickActions: const HomeQuickActions(
      canBookVideoSession: true,
      canViewProgress: true,
      canAccessExerciseLibrary: true,
      hasInBodyData: false,
      canShopSupplements: true,
    ),
    todayWorkout: null,
    upcomingSession: null,
    quota: null,
  );
}

class _RecordingQuotaService extends QuotaService {
  _RecordingQuotaService({required this.snapshot});

  final QuotaSnapshot snapshot;
  int callCount = 0;
  final List<String> requestedUserIds = <String>[];

  @override
  Future<QuotaSnapshot> fetchSnapshot(String userId) async {
    callCount += 1;
    requestedUserIds.add(userId);
    final usage = snapshot.usage;
    final limits = snapshot.limits;
    return QuotaSnapshot(
      userId: userId,
      tier: snapshot.tier,
      usage: QuotaUsage(
        messagesUsed: usage.messagesUsed,
        callsUsed: usage.callsUsed,
        attachmentsUsed: usage.attachmentsUsed,
        resetAt: usage.resetAt,
      ),
      limits: QuotaLimits(
        messages: limits.messages,
        calls: limits.calls,
        callDuration: limits.callDuration,
        chatAttachments: limits.chatAttachments,
        nutritionPersistent: limits.nutritionPersistent,
        nutritionWindowDays: limits.nutritionWindowDays,
      ),
    );
  }
}

class _FakeHomeSummaryService extends HomeSummaryService {
  _FakeHomeSummaryService({required this.summary}) : super();

  final HomeSummary summary;

  @override
  Future<HomeSummary> fetchSummary(String userId) async {
    return summary;
  }
}
