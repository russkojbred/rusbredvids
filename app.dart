import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:russkiy_bred/app/theme.dart';
import 'package:russkiy_bred/core/di/injection_container.dart';
import 'package:russkiy_bred/presentation/blocs/video/video_bloc.dart';
import 'package:russkiy_bred/presentation/pages/main_screen.dart';
import 'package:russkiy_bred/presentation/pages/splash_screen.dart';
import 'package:russkiy_bred/presentation/pages/video_player_screen.dart';
import 'package:russkiy_bred/presentation/pages/upload_screen.dart';

class RusskiyBredApp extends StatelessWidget {
  const RusskiyBredApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<VideoBloc>(
          create: (_) => sl<VideoBloc>()..add(LoadVideosEvent()),
        ),
        // Другие провайдеры BLoC
      ],
      child: MaterialApp.router(
        title: 'Русский Бред видеоматериалы',
        theme: buildRusskiyBredTheme(),
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  // Конфигурация маршрутов с использованием go_router
  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/main',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/player/:videoId',
        builder: (context, state) {
          final videoId = state.params['videoId']!;
          return VideoPlayerScreen(videoId: videoId);
        },
      ),
      GoRoute(
        path: '/upload',
        builder: (context, state) => const UploadScreen(),
      ),
    ],
    initialLocation: '/',
    debugLogDiagnostics: true,
  );
}
