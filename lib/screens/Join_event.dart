import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Services/firebase_services.dart';

class JoinEventPage extends StatefulWidget {
  const JoinEventPage({super.key});

  @override
  State<JoinEventPage> createState() => _JoinEventPageState();
}

class _JoinEventPageState extends State<JoinEventPage> {
  final TextEditingController eventCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    eventCodeController.addListener(() {
      final text = eventCodeController.text.toUpperCase();
      if (eventCodeController.text != text) {
        eventCodeController.value = eventCodeController.value.copyWith(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    });
  }

  @override
  void dispose() {
    eventCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Event'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFD1A055), // Top gradient color
              Color(0xFFF3C1A9), // Bottom gradient color
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
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
                  try {
                    final event = await fetchEventByCode(eventCode);
                    if (event != null) {
                      await addToJoinedEvents(event);
                      await FirebaseServices().addUserToParticipants(eventCode);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Joined event: ${event['eventName']}')),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid event code')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid event code')),
                  );
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
        .where('eventCode', isEqualTo: eventCode)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.data();
    }
    return null;
  }

  Future<void> addToJoinedEvents(Map<String, dynamic> event) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not signed in.');
    }

    final joinedEventRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('JoinedEvents')
        .doc(event['eventId']);

    await joinedEventRef.set(event);
  }
}

