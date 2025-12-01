enum SubscriptionTier { freemium, premium, smartPremium }

extension SubscriptionTierDisplay on SubscriptionTier {
  String get label {
    switch (this) {
      case SubscriptionTier.premium:
        return 'Premium';
      case SubscriptionTier.smartPremium:
        return 'Smart Premium';
      default:
        return 'Freemium';
    }
  }

  static SubscriptionTier parse(String? value) {
    switch (value) {
      case 'premium':
      case 'Premium':
        return SubscriptionTier.premium;
      case 'smart_premium':
      case 'smart-premium':
      case 'Smart Premium':
        return SubscriptionTier.smartPremium;
      default:
        return SubscriptionTier.freemium;
    }
  }

  String get apiValue {
    switch (this) {
      case SubscriptionTier.premium:
        return 'premium';
      case SubscriptionTier.smartPremium:
        return 'smart_premium';
      default:
        return 'freemium';
    }
  }
}

class QuotaLimits {
  const QuotaLimits({
    required this.messages,
    required this.calls,
    required this.callDuration,
    required this.chatAttachments,
    required this.nutritionPersistent,
    required this.nutritionWindowDays,
  });

  final dynamic messages;
  final int calls;
  final int callDuration;
  final bool chatAttachments;
  final bool nutritionPersistent;
  final int? nutritionWindowDays;

  factory QuotaLimits.fromJson(Map<String, dynamic> json) => QuotaLimits(
        messages: json['messages'],
        calls: json['calls'] ?? 0,
        callDuration: json['callDuration'] ?? 0,
        chatAttachments: json['chatAttachments'] == true,
        nutritionPersistent: json['nutritionPersistent'] == true,
        nutritionWindowDays: json['nutritionWindowDays'] as int?,
      );
}

class QuotaUsage {
  const QuotaUsage({
    required this.messagesUsed,
    required this.callsUsed,
    required this.attachmentsUsed,
    required this.resetAt,
  });

  final int messagesUsed;
  final int callsUsed;
  final int attachmentsUsed;
  final DateTime resetAt;

  factory QuotaUsage.fromJson(Map<String, dynamic> json) => QuotaUsage(
        messagesUsed: json['messagesUsed'] ?? 0,
        callsUsed: json['callsUsed'] ?? 0,
        attachmentsUsed: json['attachmentsUsed'] ?? 0,
        resetAt: DateTime.tryParse(json['resetAt'] ?? '') ?? DateTime.now(),
      );
}

class QuotaSnapshot {
  const QuotaSnapshot({
    required this.userId,
    required this.tier,
    required this.usage,
    required this.limits,
  });

  final String userId;
  final SubscriptionTier tier;
  final QuotaUsage usage;
  final QuotaLimits limits;

  factory QuotaSnapshot.fromJson(Map<String, dynamic> json) => QuotaSnapshot(
        userId: json['userId']?.toString() ?? '',
        tier: SubscriptionTierDisplay.parse(json['tier']?.toString()),
        usage: QuotaUsage.fromJson(json['usage'] as Map<String, dynamic>),
        limits: QuotaLimits.fromJson(json['limits'] as Map<String, dynamic>),
      );
}

class NutritionPlanMeta {
  const NutritionPlanMeta({
    required this.generatedAt,
    required this.expiresAt,
    required this.locked,
    this.windowDays,
  });

  final DateTime generatedAt;
  final DateTime? expiresAt;
  final bool locked;
  final int? windowDays;

  factory NutritionPlanMeta.fromJson(Map<String, dynamic> json) => NutritionPlanMeta(
        generatedAt: DateTime.tryParse(json['generatedAt'] ?? '') ?? DateTime.now(),
        expiresAt: json['expiresAt'] != null ? DateTime.tryParse(json['expiresAt']) : null,
        locked: json['locked'] == true,
        windowDays: json['windowDays'] as int?,
      );
}

class NutritionExpiryStatus {
  const NutritionExpiryStatus({
    required this.isExpired,
    required this.isLocked,
    required this.canAccess,
    this.daysRemaining,
    this.hoursRemaining,
    this.expiryMessage,
  });

  final bool isExpired;
  final bool isLocked;
  final bool canAccess;
  final int? daysRemaining;
  final int? hoursRemaining;
  final String? expiryMessage;

  factory NutritionExpiryStatus.fromJson(Map<String, dynamic> json) => NutritionExpiryStatus(
        isExpired: json['isExpired'] == true,
        isLocked: json['isLocked'] == true,
        canAccess: json['canAccess'] == true,
        daysRemaining: json['daysRemaining'] as int?,
        hoursRemaining: json['hoursRemaining'] as int?,
        expiryMessage: json['expiryMessage']?.toString(),
      );
}

class NutritionAccessSnapshot {
  const NutritionAccessSnapshot({
    required this.plan,
    required this.status,
  });

  final NutritionPlanMeta plan;
  final NutritionExpiryStatus status;

  factory NutritionAccessSnapshot.fromJson(Map<String, dynamic> json) => NutritionAccessSnapshot(
        plan: NutritionPlanMeta.fromJson(_coercePlan(json)),
        status: NutritionExpiryStatus.fromJson(json['status'] as Map<String, dynamic>),
      );
}

Map<String, dynamic> _coercePlan(Map<String, dynamic> json) {
  final planValue = json['plan'];
  if (planValue is Map<String, dynamic>) {
    return planValue;
  }
  if (planValue is Map) {
    return planValue.map((key, value) => MapEntry(key.toString(), value));
  }
  return {
    'generatedAt': json['generatedAt'],
    'expiresAt': json['expiresAt'],
    'locked': json['locked'],
    'windowDays': json['windowDays'],
  }..removeWhere((_, value) => value == null);
}

class NutritionPreferences {
  const NutritionPreferences({
    required this.proteinSources,
    required this.proteinAllergies,
    required this.dinnerPreferences,
    this.additionalNotes,
    this.completedAt,
  });

  final List<String> proteinSources;
  final List<String> proteinAllergies;
  final Map<String, dynamic>? dinnerPreferences;
  final String? additionalNotes;
  final DateTime? completedAt;

  factory NutritionPreferences.fromJson(Map<String, dynamic> json) => NutritionPreferences(
        proteinSources: List<String>.from(json['proteinSources'] ?? const []),
        proteinAllergies: List<String>.from(json['proteinAllergies'] ?? const []),
        dinnerPreferences: json['dinnerPreferences'] == null
            ? null
            : Map<String, dynamic>.from(json['dinnerPreferences'] as Map),
        additionalNotes: json['additionalNotes']?.toString(),
        completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt']) : null,
      );

  Map<String, dynamic> toJson() => {
        'proteinSources': proteinSources,
        'proteinAllergies': proteinAllergies,
        'dinnerPreferences': dinnerPreferences,
        'additionalNotes': additionalNotes,
      }..removeWhere((_, value) => value == null);

  NutritionPreferences copyWith({
    List<String>? proteinSources,
    List<String>? proteinAllergies,
    Map<String, dynamic>? dinnerPreferences,
    String? additionalNotes,
    DateTime? completedAt,
  }) =>
      NutritionPreferences(
        proteinSources: proteinSources ?? this.proteinSources,
        proteinAllergies: proteinAllergies ?? this.proteinAllergies,
        dinnerPreferences: dinnerPreferences ?? this.dinnerPreferences,
        additionalNotes: additionalNotes ?? this.additionalNotes,
        completedAt: completedAt ?? this.completedAt,
      );

  static NutritionPreferences empty() => const NutritionPreferences(
        proteinSources: <String>[],
        proteinAllergies: <String>[],
        dinnerPreferences: <String, dynamic>{},
        additionalNotes: null,
        completedAt: null,
      );
}

NutritionPreferences parsePreferencesResponse(Map<String, dynamic>? payload) {
  if (payload == null) return NutritionPreferences.empty();
  return NutritionPreferences.fromJson(payload);
}
