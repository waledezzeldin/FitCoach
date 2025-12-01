import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  List<Map<String, dynamic>> calls = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final newCall = args?['newCall'];
    if (newCall is Map<String, dynamic>) {
      setState(() => calls = [newCall]);
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
      body: calls.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Video calls will appear here once booked from your coach dashboard.',
                    style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
              ),
            )
          : ListView.builder(
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
    );
  }
}