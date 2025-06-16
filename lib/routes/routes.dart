import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/route_names.dart';
import 'package:flutter_application_1/layouts/main_layout.dart';
import 'package:flutter_application_1/pages/sign_in_page.dart';
import 'package:flutter_application_1/pages/sign_up_page.dart';

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case RouteNames.signIn:
      return MaterialPageRoute(builder: (_) => const SignInPage());

    case RouteNames.signUp:
      return MaterialPageRoute(builder: (_) => const SignUpPage());

    case RouteNames.home:
    case RouteNames.category:
    case RouteNames.profile:
      return MaterialPageRoute(builder: (_) => const MainLayout());

    default:
      return MaterialPageRoute(
        builder:
            (_) => const Scaffold(body: Center(child: Text('Rota não encontrada'))),
      );
  }
}
