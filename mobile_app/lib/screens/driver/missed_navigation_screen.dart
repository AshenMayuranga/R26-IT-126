import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../models/pickup_request.dart';
import '../../services/firestore_service.dart';
import 'navigate_to_point_screen.dart';
import '../../widgets/app_feedback.dart';
import '../../utils/friendly_error.dart';

class MissedNavigationScreen extends StatelessWidget {
  final PickupRequest request;
  const MissedNavigationScreen({super.key, required this.request});

  Future<bool> _reactivate(BuildContext context) async {
    try {
      await FirestoreService().rescheduleMissedRequest(request.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          appSnackBar(
            'Request rescheduled — it is back on the pickup route for the '
            'next ${FirestoreService.rescheduleWindow.inHours} hours.',
            kind: SnackKind.success,
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        // Same server-clock check as on the Missed Requests list.
        final refused = e is FirebaseException && e.code == 'permission-denied';
        showErrorDialog(
          context,
          refused
              ? 'The request was not rescheduled. Check that your phone\'s '
                  'date and time are set correctly, then try again.'
              : friendlyError(
                  e,
                  fallback: 'Could not reschedule the request. Please try again.',
                ),
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = '${request.createdAt.day}/${request.createdAt.month}/${request.createdAt.year}';
    return NavigateToPointScreen(
      destination: LatLng(request.lat, request.lng),
      title: 'Navigate to Missed Pickup',
      subtitle: 'Missed pickup — placed $date',
      accentColor: Colors.orange,
      destinationIcon: Icons.warning_amber_rounded,
      actionLabel: 'Schedule for Next Visit',
      onAction: _reactivate,
    );
  }
}
