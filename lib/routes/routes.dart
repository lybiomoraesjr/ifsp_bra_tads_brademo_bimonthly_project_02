import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/route_names.dart';
import 'package:flutter_application_1/pages/category_page.dart';
import 'package:flutter_application_1/pages/home_page.dart';
import 'package:flutter_application_1/pages/profile_page.dart';
import 'package:flutter_application_1/pages/sign_in_page.dart';
import 'package:flutter_application_1/pages/sign_up_page.dart';


Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case RouteNames.signIn:
      return MaterialPageRoute(builder: (_) => SignInPage());

    case RouteNames.signUp:
      return MaterialPageRoute(builder: (_) => SignUpPage());

    case RouteNames.home:
      return MaterialPageRoute(builder: (_) => HomePage());

    case RouteNames.category:
      return MaterialPageRoute(builder: (_) => CategoryPage());

    case RouteNames.profile:
      return MaterialPageRoute(builder: (_) => ProfilePage());

    default:
      return MaterialPageRoute(
        builder:
            (_) => Scaffold(body: Center(child: Text('Rota não encontrada'))),
      );
  }
}
