import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/router/app_router.dart';
import 'core/di/injection.dart';
import 'core/theme/app_colors.dart';
import 'features/auth/presentation/blocs/auth_bloc.dart';
import 'features/parking_session/presentation/blocs/active_session/active_session_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const SpotFinderApp());
}

class SpotFinderApp extends StatelessWidget {
  const SpotFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => getIt<AuthBloc>()),
        BlocProvider<ActiveSessionBloc>(create: (_) => getIt<ActiveSessionBloc>()),
      ],
      child: Builder(
        builder: (context) {
          final authBloc = context.read<AuthBloc>();
          final router = buildAppRouter(authBloc);
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'SpotFinder',
            theme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: AppColors.background,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primaryNeon,
                surface: AppColors.surfaceDark,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.background,
                elevation: 0,
                centerTitle: false,
              ),
            ),
            routerConfig: router,
          );
        },
      ),
    );
  }
}
