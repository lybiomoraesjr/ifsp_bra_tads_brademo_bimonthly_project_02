import 'package:geolocator/geolocator.dart';
import 'dart:io';

class LocationService {
  Future<Position> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
        'Serviço de localização desabilitado. Por favor, habilite a localização nas configurações do dispositivo.',
      );
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception(
          'Permissão de localização negada. É necessário permitir o acesso à localização para usar esta funcionalidade.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Permissão de localização permanentemente negada. Por favor, habilite a localização nas configurações do aplicativo.',
      );
    }

    LocationSettings locationSettings;

    if (Platform.isAndroid) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        forceLocationManager: false,
      );
    } else if (Platform.isIOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        allowBackgroundLocationUpdates: false,
        pauseLocationUpdatesAutomatically: true,
        activityType: ActivityType.fitness,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
      );
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception(
          'Timeout ao obter localização. Verifique sua conexão com GPS.',
        );
      } else if (e.toString().contains('permission')) {
        throw Exception(
          'Erro de permissão de localização. Verifique as configurações do aplicativo.',
        );
      } else {
        throw Exception('Erro ao obter localização: $e');
      }
    }
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
}
