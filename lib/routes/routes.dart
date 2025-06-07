import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/route_names.dart';
import 'package:flutter_application_1/pages/home.dart';


Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case RouteNames.signIn:
      return MaterialPageRoute(builder: (_) => HomePage());

    case RouteNames.signUp:
      return MaterialPageRoute(builder: (_) => HomePage());

    case RouteNames.home:
      return MaterialPageRoute(builder: (_) => HomePage());

    case RouteNames.category:
      return MaterialPageRoute(builder: (_) => HomePage());

    case RouteNames.profile:
      return MaterialPageRoute(builder: (_) => HomePage());

    default:
      return MaterialPageRoute(
        builder:
            (_) => Scaffold(body: Center(child: Text('Rota não encontrada'))),
      );
  }
}
