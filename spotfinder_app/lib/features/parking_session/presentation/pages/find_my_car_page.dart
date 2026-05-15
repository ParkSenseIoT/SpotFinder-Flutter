import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../blocs/active_session/active_session_bloc.dart';
import '../blocs/active_session/active_session_state.dart';
import '../widgets/empty_session_view.dart';
import '../widgets/session_timer.dart';

class FindMyCarPage extends StatelessWidget {
  const FindMyCarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.primaryNeon),
        title: const Text('Find my car', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: BlocBuilder<ActiveSessionBloc, ActiveSessionState>(
        builder: (context, state) {
          final session = state.session;
          if (state.status == ActiveSessionStatus.loading && session == null) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon));
          }
          if (session == null) {
            return const EmptySessionView(
              title: 'No vehicle parked',
              subtitle: 'When your car is detected in a SpotFinder lot, its location will appear here.',
              icon: Icons.car_crash_outlined,
            );
          }
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: AppColors.surfaceDark,
                      border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.4)),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Positioned(
                          top: 16,
                          left: 16,
                          child: Text(
                            'Slot',
                            style: TextStyle(color: AppColors.textGray, fontSize: 12, letterSpacing: 1.5),
                          ),
                        ),
                        Text(
                          session.slotId == null ? '—' : '#${session.slotId}',
                          style: const TextStyle(
                            color: AppColors.primaryNeon,
                            fontSize: 96,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    session.licensePlate,
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4),
                  ),
                  const SizedBox(height: 12),
                  const Text('Parked for', style: TextStyle(color: AppColors.textGray, fontSize: 13)),
                  const SizedBox(height: 4),
                  SessionTimer(entryTimestamp: session.entryTimestamp),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => context.push('/sessions/${session.id}'),
                      icon: const Icon(Icons.receipt_long, color: Colors.black),
                      label: const Text('View session details', style: TextStyle(color: Colors.black)),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryNeon,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
