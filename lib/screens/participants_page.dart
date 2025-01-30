import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParticipantsPage extends StatelessWidget {
  final String eventId;
  final String eventName;

  const ParticipantsPage(
      {super.key, required this.eventId, required this.eventName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Participants - $eventName')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .doc(eventId)
            .collection('Participants')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('No participants have joined yet.'));
          }

          final participants = snapshot.data!.docs;

          return ListView.builder(
            itemCount: participants.length,
            itemBuilder: (context, index) {
              final participant =
                  participants[index].data() as Map<String, dynamic>;

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: participant['photoURL'] != null
                      ? NetworkImage(participant['photoURL'])
                      : const AssetImage('assets/default_avatar.png')
                          as ImageProvider,
                ),
                title: Text(participant['name'] ?? 'Unknown'),
                subtitle: Text(participant['email'] ?? 'No Email'),
              );
            },
          );
        },
      ),
    );
  }
}
