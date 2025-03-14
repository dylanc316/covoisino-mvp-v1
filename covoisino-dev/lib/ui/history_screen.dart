import 'package:covoisino/core/localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/app_theme.dart';
import '../core/providers.dart';
import '../core/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';

class RideHistoryScreen extends StatelessWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('ride_history')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer2<AppAuthProvider, RideProvider>(
        builder: (context, auth, ride, _) {
          final user = auth.currentUser;
          if (user == null) return const SizedBox.shrink();

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('rides')
                .where('status', isEqualTo: 'completed')
                .where(Filter.or(
                  Filter('driverId', isEqualTo: user.email),
                  Filter('passengerId', isEqualTo: user.email),
                ))
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final rides = snapshot.data!.docs;
              if (rides.isEmpty) {
                return Center(
                  child: Text(
                    l10n.get('no_rides_yet'),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: rides.length,
                itemBuilder: (context, index) {
                  final rideData = rides[index].data() as Map<String, dynamic>;
                  final isDriver = rideData['driverId'] == user.email;

                  final otherUserData = isDriver
                      ? rideData['passenger'] as Map<String, dynamic>? ??
                          {'name': 'Unknown Rider'}
                      : rideData['driver'] as Map<String, dynamic>? ??
                          {'name': 'Unknown Driver'};

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDriver ? Colors.blue[50] : Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isDriver ? Colors.blue[100]! : Colors.green[100]!,
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              isDriver ? Colors.blue[100] : Colors.green[100],
                          child: Icon(
                            Icons.person,
                            color:
                                isDriver ? Colors.blue[700] : Colors.green[700],
                          ),
                        ),
                        title: Text(
                          otherUserData['name'] ?? 'Unknown User',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          isDriver ? l10n.get('driver') : l10n.get('rider'),
                        ),
                        trailing: Text(
                          _formatDate(
                            (rideData['timestamp'] as Timestamp).toDate(),
                          ),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }
}
