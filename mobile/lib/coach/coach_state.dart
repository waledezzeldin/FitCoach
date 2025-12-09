import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitcoach/subscription/subscription_state.dart';

class CoachState extends ChangeNotifier {
  static const _messagesKey = 'coach.messagesSent';
  static const _callsKey = 'coach.callsMade';
  static const _ratingKey = 'coach.rating';

  int messagesSent = 0;
  int callsMade = 0;
  double rating = 0;

  // Simple in-memory data for UI
  final List<String> schedule = [
    'Mon 10:00 - Strength',
    'Wed 18:00 - Cardio',
    'Sat 09:00 - Mobility',
  ];
  final List<String> requests = [
    'Session request from Ahmed',
    'Session request from Sara',
  ];
  final List<String> messages = [
    'Coach: Welcome! How can I help?',
  ];

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    messagesSent = sp.getInt(_messagesKey) ?? 0;
    callsMade = sp.getInt(_callsKey) ?? 0;
    rating = (sp.getDouble(_ratingKey) ?? 0.0);
    notifyListeners();
  }

  Map<String, int> _limits(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.freemium:
        return {'messages': 20, 'calls': 1};
      case SubscriptionTier.premium:
        return {'messages': 200, 'calls': 2};
      case SubscriptionTier.smartPremium:
        return {'messages': 1000000, 'calls': 4};
    }
  }

  bool canSendMessage(SubscriptionTier tier) => messagesSent < _limits(tier)['messages']!;
  bool canStartCall(SubscriptionTier tier) => callsMade < _limits(tier)['calls']!;

  Future<void> sendMessage() async {
    messagesSent += 1;
    messages.add('You: Message #$messagesSent');
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_messagesKey, messagesSent);
    notifyListeners();
  }

  Future<void> startCall() async {
    callsMade += 1;
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_callsKey, callsMade);
    notifyListeners();
  }

  void approveRequest(String r) {
    requests.remove(r);
    messages.add('Coach: Approved "$r"');
    notifyListeners();
  }

  void rejectRequest(String r) {
    requests.remove(r);
    messages.add('Coach: Rejected "$r"');
    notifyListeners();
  }

  Future<void> setRating(double value) async {
    rating = value;
    final sp = await SharedPreferences.getInstance();
    await sp.setDouble(_ratingKey, rating);
    notifyListeners();
  }
}
