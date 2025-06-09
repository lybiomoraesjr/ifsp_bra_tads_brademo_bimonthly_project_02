import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
  
  static const String users = '/api/users';
  static const String categories = '/api/categories';
  static const String tasks = '/api/tasks';
} 