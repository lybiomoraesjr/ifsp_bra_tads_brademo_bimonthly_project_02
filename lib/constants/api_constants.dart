import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

class ApiConstants {
  static String get baseUrl {
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null) return envUrl;
    if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }

  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';

  static const String users = '/api/users';

  static const String tasks = '/api/tasks';

  static const String categories = '/api/categories';
}
