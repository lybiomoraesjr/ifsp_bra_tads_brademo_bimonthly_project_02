import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/constants/route_names.dart';
import 'package:flutter_application_1/routes/routes.dart';
import 'package:flutter_application_1/theme/theme.dart';
import 'package:flutter_application_1/providers/category_provider.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CategoryProvider())],
      child: MaterialApp(
        title: 'ToDo Bem',
        theme: customTheme,
        initialRoute: RouteNames.signIn,
        onGenerateRoute: onGenerateRoute,
      ),
    );
  }
}
