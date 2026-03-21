import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'main.dart';

// The router defines every screen address in the app.
// Think of each GoRoute as a page in a book — the 'path' is its page number,
// and 'builder' is what gets displayed when you turn to that page.

final appRouter = GoRouter(
  initialLocation: '/repair-orders',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/repair-orders',
          builder: (context, state) =>
              const PlaceholderScreen(title: 'Repair Orders'),
        ),
        GoRoute(
          path: '/parts',
          builder: (context, state) =>
              const PlaceholderScreen(title: 'Parts'),
        ),
        GoRoute(
          path: '/payments',
          builder: (context, state) =>
              const PlaceholderScreen(title: 'Payments'),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) =>
              const PlaceholderScreen(title: 'Dashboard'),
        ),
        GoRoute(
          path: '/accounting',
          builder: (context, state) =>
              const PlaceholderScreen(title: 'Accounting'),
        ),
      ],
    ),
  ],
);
