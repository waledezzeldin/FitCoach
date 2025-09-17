import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Progress Tracking')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Log Workout'),
            onTap: () {
              // TODO: Navigate to workout log form
            },
          ),
          ListTile(
            title: Text('Log Nutrition'),
            onTap: () {
              // TODO: Navigate to nutrition log form
            },
          ),
          ListTile(
            title: Text('Log Supplement'),
            onTap: () {
              // TODO: Navigate to supplement log form
            },
          ),
        ],
      ),
    );
  }
}