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
      final userId = await getCurrentUserId();
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

  Future<String> getCurrentUserId() async {
    // Replace with your actual user ID retrieval logic
    return 'USER_ID';
  }

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Recommendations'),
        backgroundColor: Colors.black,
        foregroundColor: green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.white)))
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: recommendations.length,
                  itemBuilder: (context, index) {
                    final rec = recommendations[index];
                    return Card(
                      color: Colors.black,
                      child: ListTile(
                        leading: Icon(Icons.recommend, color: green),
                        title: Text(rec['title'] ?? 'Recommendation', style: TextStyle(color: green)),
                        subtitle: Text(rec['content'] ?? '', style: const TextStyle(color: Colors.white)),
                      ),
                    );
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
