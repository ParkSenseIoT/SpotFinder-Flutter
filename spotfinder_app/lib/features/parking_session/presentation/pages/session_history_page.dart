import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../domain/usecases/get_session_history_use_case.dart';
import '../blocs/session_history/session_history_bloc.dart';
import '../blocs/session_history/session_history_event.dart';
import '../blocs/session_history/session_history_state.dart';
import '../widgets/empty_session_view.dart';
import '../widgets/session_history_tile.dart';

class SessionHistoryPage extends StatelessWidget {
  const SessionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthBloc>().state.user?.id;
    return BlocProvider(
      create: (_) => SessionHistoryBloc(
        getSessionHistory: GetIt.I<GetSessionHistoryUseCase>(),
      )..add(SessionHistoryRequested(userId ?? 0)),
      child: const _SessionHistoryView(),
    );
  }
}

class _SessionHistoryView extends StatelessWidget {
  const _SessionHistoryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.primaryNeon),
        title: const Text('Session history', style: TextStyle(color: Colors.white)),
      ),
      body: BlocBuilder<SessionHistoryBloc, SessionHistoryState>(
        builder: (context, state) {
          switch (state.status) {
            case SessionHistoryStatus.initial:
            case SessionHistoryStatus.loading:
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon));
            case SessionHistoryStatus.failure:
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    state.errorMessage ?? 'Unable to load history',
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            case SessionHistoryStatus.success:
              if (state.sessions.isEmpty) {
                return const EmptySessionView(
                  title: 'No sessions yet',
                  subtitle: 'Past parking sessions will appear here once you start using SpotFinder.',
                  icon: Icons.history,
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: state.sessions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final session = state.sessions[index];
                  return SessionHistoryTile(session: session);
                },
              );
          }
        },
      ),
    );
  }
}
