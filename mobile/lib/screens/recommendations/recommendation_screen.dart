import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  List<Map<String, dynamic>> recommendations = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchRecommendations();
  }

  Future<void> fetchRecommendations() async {
    try {
      // TODO: Replace with your actual backend URL and user ID retrieval logic
      final userId = await getCurrentUserId(); // Implement this function based on your auth
      final response = await Dio().get(
        'http://localhost:3000/api/recommendations',
        queryParameters: {'userId': userId},
      );
      setState(() {
        recommendations = List<Map<String, dynamic>>.from(response.data);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load recommendations';
        isLoading = false;
      });
    }
  }

  // Example stub for user ID retrieval
  Future<String> getCurrentUserId() async {
    // Replace with your actual user ID retrieval logic (from secure storage, provider, etc.)
    return 'USER_ID';
  }

  @override
  Widget build(BuildContext context) {
    // Replace these with your actual values
    final userId = 'currentUserId';
    final userGoals = 'Lose weight and build muscle';
    final coachInput = 'Prefers home workouts';

    return Scaffold(
      appBar: AppBar(title: const Text('Recommendations')),
      body: FutureBuilder<String?>(
        future: fetchRecommendation(userId, userGoals, coachInput),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Failed to load recommendation'));
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(snapshot.data!),
            );
          }
        },
      ),
    );
  }
}

// Example function to fetch AI recommendation
Future<String?> fetchRecommendation(String userId, String goals, String coachInput) async {
  try {
    final response = await Dio().post(
      'http://your-backend-url/v1/recommendations',
      data: {
        'userId': userId,
        'goals': goals,
        'coachInput': coachInput,
      },
    );
    return response.data['content']; // AI recommendation text
  } catch (e) {
    return null;
  }
}
