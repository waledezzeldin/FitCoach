import 'package:flutter/material.dart';
import '../../services/recommendation_service.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  final _service = RecommendationService();
  String? _result;
  bool _loading = false;

  Future<void> _fetchRecommendations() async {
    setState(() => _loading = true);
    try {
      final res = await _service.getRecommendations({
        "goal": "muscle_gain",
        "diet": "high_protein",
        "experience": "beginner"
      });
      setState(() => _result = res['plan'] ?? res.toString());
    } catch (e) {
      setState(() => _result = "Error: $e");
    }
    setState(() => _loading = false);
  }

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Recommendations")),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : _result != null
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_result!),
                  )
                : const Text("No recommendations yet"),
      ),
    );
  }
}
