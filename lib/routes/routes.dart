import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/route_names.dart';
import 'package:flutter_application_1/layouts/main_layout.dart';
import 'package:flutter_application_1/pages/sign_in_page.dart';
import 'package:flutter_application_1/pages/sign_up_page.dart';
import 'package:flutter_application_1/services/secure_storage_service.dart';

Future<bool> isLoggedIn() async {
  final storage = SecureStorageService();
  return await storage.isLoggedIn();
}

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  final publicRoutes = [RouteNames.signIn, RouteNames.signUp];
  final privateRoutes = [
    RouteNames.home,
    RouteNames.category,
    RouteNames.profile,
  ];

  return MaterialPageRoute(
    builder: (context) {
      return FutureBuilder<bool>(
        future: isLoggedIn(),
        builder: (context, snapshot) {
          final loggedIn = snapshot.data ?? false;
          final isPublic = publicRoutes.contains(settings.name);
          final isPrivate = privateRoutes.contains(settings.name);

          if (isPrivate && !loggedIn) {
            return const SignInPage();
          } else if (isPublic && loggedIn) {
            return const MainLayout();
          }

          switch (settings.name) {
            case RouteNames.signIn:
              return const SignInPage();
            case RouteNames.signUp:
              return const SignUpPage();
            case RouteNames.home:
            case RouteNames.category:
            case RouteNames.profile:
              return const MainLayout();
            default:
              return const Scaffold(
                body: Center(child: Text('Rota não encontrada')),
              );
          }
        },
      );
    },
  );
}
