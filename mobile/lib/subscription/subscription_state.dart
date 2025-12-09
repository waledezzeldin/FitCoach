import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SubscriptionTier { freemium, premium, smartPremium }

class SubscriptionState extends ChangeNotifier {
  static const _tierKey = 'subscription.tier';
  SubscriptionTier _tier = SubscriptionTier.freemium;

  SubscriptionTier get tier => _tier;

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final v = sp.getString(_tierKey);
    if (v != null) {
      switch (v) {
        case 'premium':
          _tier = SubscriptionTier.premium;
          break;
        case 'smartPremium':
          _tier = SubscriptionTier.smartPremium;
          break;
        default:
          _tier = SubscriptionTier.freemium;
      }
    }
    notifyListeners();
  }

  Future<void> setTier(SubscriptionTier t) async {
    _tier = t;
    final sp = await SharedPreferences.getInstance();
    final s = switch (t) {
      SubscriptionTier.freemium => 'freemium',
      SubscriptionTier.premium => 'premium',
      SubscriptionTier.smartPremium => 'smartPremium',
    };
    await sp.setString(_tierKey, s);
    notifyListeners();
  }
}
