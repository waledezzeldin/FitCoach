import 'package:flutter/material.dart';

class SubscriptionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Subscription')),
      body: Column(
        children: [
          ListTile(
            title: Text('Free Tier'),
            subtitle: Text('Basic access to FitCoach+ features'),
            trailing: ElevatedButton(
              onPressed: () {
                // TODO: Subscribe to Free Tier
              },
              child: Text('Select'),
            ),
          ),
          ListTile(
            title: Text('Pro Tier'),
            subtitle: Text('1-on-1 coaching, advanced tracking'),
            trailing: ElevatedButton(
              onPressed: () {
                // TODO: Subscribe to Pro Tier
              },
              child: Text('Upgrade'),
            ),
          ),
          ListTile(
            title: Text('Supplement Bundle'),
            subtitle: Text('Monthly supplement delivery'),
            trailing: ElevatedButton(
              onPressed: () {
                // TODO: Subscribe to Bundle
              },
              child: Text('Subscribe'),
            ),
          ),
        ],
      ),
    );
  }
}