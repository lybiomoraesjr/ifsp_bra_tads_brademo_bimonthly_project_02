import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/location_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
        LocationService().getLocationByMap(context);
          },
          child: const Text('Abrir Mapa'),
        ),
      ),
    );
  }
}