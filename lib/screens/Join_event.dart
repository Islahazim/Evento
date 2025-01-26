import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JoinEventPage extends StatelessWidget {
  final TextEditingController eventCodeController = TextEditingController();

  JoinEventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: eventCodeController,
              decoration: const InputDecoration(labelText: 'Enter Event Code'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final eventCode = eventCodeController.text.trim();
                if (eventCode.isNotEmpty) {
                  final event = await fetchEventByCode(eventCode);
                  if (event != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Joined event: ${event['eventName']}')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid event code')),
                    );
                  }
                }
              },
              child: const Text('Join Event'),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> fetchEventByCode(String eventCode) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('eventId', isEqualTo: eventCode)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.data();
    }
    return null;
  }
}
