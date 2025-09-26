enum DemoRole { user, coach, admin }

class DemoSession {
  static DemoRole role = DemoRole.user;

  static Map<String, dynamic> profile() {
    switch (role) {
      case DemoRole.coach:
        return {'id': 'coach_1', 'name': 'Coach Sara', 'subscription': 'pro'};
      case DemoRole.admin:
        return {'id': 'admin_1', 'name': 'Admin', 'subscription': 'pro'};
      default:
        return {'id': 'user_1', 'name': 'Marawan', 'subscription': 'freemium'};
    }
  }
}