import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/parking_session.dart';
import '../../domain/usecases/calculate_fee_use_case.dart';
import '../../domain/usecases/end_session_use_case.dart';
import '../../domain/usecases/get_session_by_id_use_case.dart';
import '../../domain/value_objects/session_status.dart';
import '../blocs/active_session/active_session_bloc.dart';
import '../blocs/active_session/active_session_event.dart';
import '../blocs/session_detail/session_detail_bloc.dart';
import '../blocs/session_detail/session_detail_event.dart';
import '../blocs/session_detail/session_detail_state.dart';
import '../widgets/fee_display.dart';
import '../widgets/session_timer.dart';

class SessionDetailPage extends StatelessWidget {
  const SessionDetailPage({super.key, required this.sessionId});

  final int sessionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SessionDetailBloc(
        getSessionById: GetIt.I<GetSessionByIdUseCase>(),
        calculateFee: GetIt.I<CalculateFeeUseCase>(),
        endSession: GetIt.I<EndSessionUseCase>(),
      )..add(SessionDetailRequested(sessionId)),
      child: _SessionDetailView(sessionId: sessionId),
    );
  }
}

class _SessionDetailView extends StatelessWidget {
  const _SessionDetailView({required this.sessionId});

  final int sessionId;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionDetailBloc, SessionDetailState>(
      listener: (context, state) {
        if (state.status == SessionDetailStatus.ended) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session ended'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
            ),
          );
          context.read<ActiveSessionBloc>().add(const ActiveSessionCleared());
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          iconTheme: const IconThemeData(color: AppColors.primaryNeon),
          title: const Text('Session details', style: TextStyle(color: Colors.white)),
        ),
        body: BlocBuilder<SessionDetailBloc, SessionDetailState>(
          builder: (context, state) {
            switch (state.status) {
              case SessionDetailStatus.initial:
              case SessionDetailStatus.loading:
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryNeon),
                );
              case SessionDetailStatus.failure:
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      state.errorMessage ?? 'Unable to load session',
                      style: const TextStyle(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              case SessionDetailStatus.success:
              case SessionDetailStatus.ending:
              case SessionDetailStatus.ended:
                final session = state.session;
                if (session == null) return const SizedBox.shrink();
                return _DetailContent(state: state, session: session);
            }
          },
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.state, required this.session});

  final SessionDetailState state;
  final ParkingSession session;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy • HH:mm:ss');
    final isActive = session.sessionStatus == SessionStatus.active;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _InfoCard(
            children: [
              _InfoRow(label: 'License plate', value: session.licensePlate),
              _InfoRow(label: 'Slot', value: session.slotId == null ? '—' : '#${session.slotId}'),
              _InfoRow(label: 'Entry', value: dateFormat.format(session.entryTimestamp)),
              if (session.exitTimestamp != null)
                _InfoRow(label: 'Exit', value: dateFormat.format(session.exitTimestamp!)),
              _InfoRow(label: 'Status', value: session.sessionStatus.label),
              _InfoRow(label: 'Payment', value: session.paymentStatus.label),
            ],
          ),
          const SizedBox(height: 20),
          if (isActive)
            _InfoCard(
              children: [
                const Text('Elapsed', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
                const SizedBox(height: 4),
                SessionTimer(entryTimestamp: session.entryTimestamp),
                const SizedBox(height: 20),
                const Text('Estimated fee', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
                const SizedBox(height: 4),
                FeeDisplay(fee: state.fee),
              ],
            )
          else
            _InfoCard(
              children: [
                _InfoRow(
                  label: 'Total duration',
                  value: _formatDuration(session.durationSinceEntry(DateTime.now())),
                ),
              ],
            ),
          const SizedBox(height: 30),
          if (isActive)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: state.status == SessionDetailStatus.ending
                    ? null
                    : () => _confirmEnd(context),
                icon: const Icon(Icons.stop_circle_outlined, color: Colors.black),
                label: Text(
                  state.status == SessionDetailStatus.ending ? 'Ending…' : 'End session',
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryNeon,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmEnd(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('End this session?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Make sure payment is settled before ending the session.',
          style: TextStyle(color: AppColors.textGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('End', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    context.read<SessionDetailBloc>().add(const SessionDetailEndRequested());
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: AppColors.textGray, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
