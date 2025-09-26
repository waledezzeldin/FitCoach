import 'package:flutter/material.dart';
import '../../services/coach_service.dart';

class CoachListScreen extends StatefulWidget {
  const CoachListScreen({super.key});
  @override
  State<CoachListScreen> createState() => _CoachListScreenState();
}

class _CoachListScreenState extends State<CoachListScreen> {
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> coaches = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    try {
      coaches = await CoachService().listCoaches();
    } catch (e) {
      error = 'Failed to load coaches';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Coaches'), backgroundColor: Colors.black, foregroundColor: green),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: coaches.length,
                    itemBuilder: (_, i) {
                      final c = coaches[i];
                      return ListTile(
                        title: Text((c['name'] ?? '').toString(), style: TextStyle(color: green)),
                        subtitle: Text((c['specialty'] ?? '').toString(), style: const TextStyle(color: Colors.white70)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/coach_schedule',
                          arguments: c,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}