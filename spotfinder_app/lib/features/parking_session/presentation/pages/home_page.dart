import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../auth/presentation/blocs/auth_event.dart';
import '../../../auth/presentation/blocs/auth_state.dart';
import '../blocs/active_session/active_session_bloc.dart';
import '../blocs/active_session/active_session_event.dart';
import '../blocs/active_session/active_session_state.dart';
import '../widgets/active_session_card.dart';
import '../widgets/empty_session_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _loadActiveSession();
  }

  void _loadActiveSession() {
    final authState = context.read<AuthBloc>().state;
    final userId = authState.user?.id;
    if (userId == null) return;
    context.read<ActiveSessionBloc>().add(ActiveSessionRequested(userId));
  }

  Future<void> _refresh() async {
    final authState = context.read<AuthBloc>().state;
    final userId = authState.user?.id;
    if (userId == null) return;
    context.read<ActiveSessionBloc>().add(ActiveSessionRefreshRequested(userId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (p, n) => p.status != n.status,
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final user = state.user;
              return Text(
                user == null ? 'SpotFinder' : 'Hi, ${user.firstName.isEmpty ? user.email : user.firstName}',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.history, color: AppColors.primaryNeon),
              tooltip: 'History',
              onPressed: () => context.push('/sessions/history'),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: AppColors.textGray),
              tooltip: 'Sign out',
              onPressed: () => context.read<AuthBloc>().add(const AuthSignOutRequested()),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.primaryNeon,
          backgroundColor: AppColors.surfaceDark,
          child: BlocBuilder<ActiveSessionBloc, ActiveSessionState>(
            builder: (context, state) {
              return ListView(
                padding: const EdgeInsets.all(20),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  if (state.status == ActiveSessionStatus.empty)
                    const EmptySessionView()
                  else
                    const ActiveSessionCard(),
                  const SizedBox(height: 30),
                  _QuickActions(hasSession: state.session != null),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.hasSession});

  final bool hasSession;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick actions',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                icon: Icons.pin_drop_outlined,
                label: 'Find my car',
                enabled: hasSession,
                onTap: () => context.push('/find-my-car'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionTile(
                icon: Icons.history_toggle_off,
                label: 'History',
                enabled: true,
                onTap: () => context.push('/sessions/history'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppColors.primaryNeon : AppColors.textGray;
    return Material(
      color: AppColors.surfaceDark,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: enabled ? Colors.white : AppColors.textGray, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
