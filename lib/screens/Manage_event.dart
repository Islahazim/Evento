import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageEventsPage extends StatefulWidget {
  const ManageEventsPage({super.key});

  @override
  _ManageEventsPageState createState() => _ManageEventsPageState();
}

class _ManageEventsPageState extends State<ManageEventsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Events'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Created'),
            Tab(text: 'Joined'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab for Created Events
          _buildCreatedEventsTab(),
          // Tab for Joined Events
          _buildJoinedEventsTab(),
        ],
      ),
    );
  }

  Widget _buildCreatedEventsTab() {
    if (user == null) {
      return const Center(child: Text('You need to sign in to view your events.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('CreatedEvents') // Created events subcollection
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No created events.'));
        }

        final events = snapshot.data!.docs;

        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index].data() as Map<String, dynamic>;

            return ListTile(
              title: Text(event['eventName']),
              subtitle: Text(event['eventDateTime']),
            );
          },
        );
      },
    );
  }

  Widget _buildJoinedEventsTab() {
    if (user == null) {
      return const Center(child: Text('You need to sign in to view your events.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('joinedEvents') // Joined events subcollection
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No joined events.'));
        }

        final events = snapshot.data!.docs;

        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index].data() as Map<String, dynamic>;

            return ListTile(
              title: Text(event['eventName']),
              subtitle: Text(event['eventDateTime']),
            );
          },
        );
      },
    );
  }

  Future<void> deleteEvent(String eventId) async {
    // Delete from the specific user's created events
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('events')
        .doc(eventId)
        .delete();

    // Optionally delete from the global events collection
    await FirebaseFirestore.instance.collection('events').doc(eventId).delete();
  }
}
