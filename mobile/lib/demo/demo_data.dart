import 'demo_session.dart';

class DemoData {
  // Profile
  static const profile = {
    'name': 'Demo User',
    'email': 'demo@example.com',
    'avatarUrl': null,
  };

  static const stats = {
    'workouts': 42,
    'minutes': 1230,
    'streak': 7,
  };

  static const workoutPlan = {
    'name': 'Starter Plan',
    'days': [
      {'day': 'Monday', 'focus': 'Chest'},
      {'day': 'Tuesday', 'focus': 'Back'},
    ]
  };

  static List<Map<String, dynamic>> storeCategories = [
    {'title': 'Supplements', 'image': 'assets/images/store/supplements.png'},
    {'title': 'Equipment', 'image': 'assets/images/store/equipment.png'},
  ];

  // Chats
  static final conversations = [
    {'id': 'c1', 'peerName': 'Coach Sara', 'lastMessage': 'Keep it up!', 'unread': 2},
    {'id': 'c2', 'peerName': 'Nutrition Bot', 'lastMessage': 'Lunch logged ✅', 'unread': 0},
  ];
  static final messages = {
    'c1': [
      {'id': 'm1', 'sender': 'coach', 'text': 'Great job 👏'},
      {'id': 'm2', 'sender': 'me', 'text': 'Thanks!'},
    ],
  };

  // Workout
  static final history = [
    {'id': 'h1', 'workoutName': 'Chest + Triceps', 'date': 'Today', 'volume': 12450},
    {'id': 'h2', 'workoutName': 'Legs', 'date': 'Yesterday', 'volume': 15600},
  ];
  static Map<String, dynamic> workout() => {
        'id': 'w1',
        'name': 'Chest + Triceps',
        'exercises': [
          {
            'id': 'e1',
            'name': 'Bench Press',
            'sets': [
              {'reps': 10, 'rest': 60},
              {'reps': 8, 'rest': 90},
            ]
          },
          {'id': 'e2', 'name': 'Cable Fly', 'sets': [{'reps': 12, 'rest': 45}]},
        ],
      };

  // Nutrition
  static final plan = {
    'meals': [
      {
        'id': 'm1',
        'name': 'Breakfast',
        'items': [
          {'id': 'i1', 'name': 'Oats', 'calories': 250, 'protein': 10, 'carbs': 40, 'fat': 5, 'consumed': true},
          {'id': 'i2', 'name': 'Eggs', 'calories': 180, 'protein': 12, 'carbs': 1, 'fat': 14, 'consumed': false},
        ],
      },
      {
        'id': 'm2',
        'name': 'Lunch',
        'items': [
          {'id': 'i3', 'name': 'Chicken + Rice', 'calories': 520, 'protein': 35, 'carbs': 60, 'fat': 12, 'consumed': false},
        ],
      },
    ],
  };

  // Subscription
  static final plans = [
    {'id': 'p_m', 'name': 'Monthly Plan', 'price': 9.99, 'currency': 'USD'},
    {'id': 'p_y', 'name': 'Annual Plan', 'price': 79.99, 'currency': 'USD'},
  ];

  static Map<String, dynamic> currentSub() => {
        'status': 'active',
        'planId': DemoSession.role == DemoRole.user ? 'p_m' : 'p_y',
        'planName': DemoSession.role == DemoRole.user ? 'Monthly Plan' : 'Annual Plan',
      };
}