import 'package:flutter/material.dart';
import '../../services/coach_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> calls = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load(initialArgs: ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?);
  }

  Future<void> _load({Map<String, dynamic>? initialArgs}) async {
    setState(() { loading = true; error = null; calls = []; });
    try {
      calls = await CoachService().videoCalls();
      final newCall = initialArgs?['newCall'];
      if (newCall is Map<String, dynamic>) {
        calls.insert(0, newCall);
      }
    } catch (e) {
      error = 'Failed to load video calls';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _join(Map<String, dynamic> call) async {
    final url = (call['joinUrl'] ?? call['meetingUrl'] ?? call['link'] ?? '').toString();
    if (url.isEmpty) {
      _showSnack('No meeting link available');
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _showSnack('Invalid meeting link');
      await Clipboard.setData(ClipboardData(text: url));
      return;
    }
    try {
      final ok = await canLaunchUrl(uri);
      if (!ok) {
        _showSnack('Cannot open link. Copied to clipboard.');
        await Clipboard.setData(ClipboardData(text: url));
        return;
      }
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      _showSnack('Failed to launch. Copied to clipboard.');
      await Clipboard.setData(ClipboardData(text: url));
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Video Calls'), backgroundColor: Colors.black, foregroundColor: green),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
              : RefreshIndicator(
                  onRefresh: () => _load(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: calls.length,
                    itemBuilder: (_, i) {
                      final c = calls[i];
                      return Card(
                        color: Colors.black,
                        child: ListTile(
                          leading: Icon(Icons.video_call, color: green),
                          title: Text((c['coach'] ?? c['coachName'] ?? '').toString(), style: TextStyle(color: green)),
                          subtitle: Text(
                            '${c['date'] ?? ''} • ${c['time'] ?? ''} • ${c['status'] ?? 'Scheduled'}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: TextButton(
                            onPressed: () => _join(c),
                            child: const Text('Join'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}