import 'package:go_router/go_router.dart';
import 'package:app/src/features/landing/presentation/landing_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(path: '/home', builder: (context, state) => const LandingPage()),
  ],
);
