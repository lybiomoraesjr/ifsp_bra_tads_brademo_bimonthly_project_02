import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';
import 'secure_storage_service.dart';

class UserService {
  final ApiService _apiService;
  final SecureStorageService _secureStorage;

  UserService()
    : _apiService = ApiService(baseUrl: ApiConstants.baseUrl),
      _secureStorage = SecureStorageService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('UserService: Fazendo login para email: $email');
      final response = await _apiService.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      final userData = response.data;
      print('UserService: Resposta do login: $userData');
      print('UserService: Token presente: ${userData['token'] != null}');

      await _secureStorage.saveUser(userData);
      print('UserService: Usuário salvo no storage');

      return userData;
    } on DioException catch (e) {
      print('UserService: Erro no login: $e');
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await _apiService.post(
        ApiConstants.register,
        data: userData,
      );

      final data = response.data;

      await _secureStorage.saveUser(data);

      return data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _secureStorage.clearUserData();
    } catch (e) {
      await _secureStorage.clearUserData();
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    return await _secureStorage.getUser();
  }

  Future<bool> isLoggedIn() async {
    return await _secureStorage.isLoggedIn();
  }

  Future<Map<String, dynamic>> updateUser(
    int id,
    Map<String, dynamic> userData,
  ) async {
    try {
      final response = await _apiService.put(
        '${ApiConstants.users}/$id',
        data: userData,
      );

      final updatedUser = response.data;

      await _secureStorage.updateUser(updatedUser);

      return updatedUser;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getUserById(int id) async {
    try {
      final response = await _apiService.get('${ApiConstants.users}/$id');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await _apiService.get(ApiConstants.users);
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> deleteUser(int id) async {
    try {
      final response = await _apiService.delete('${ApiConstants.users}/$id');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getUserCategories(int userId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.users}/$userId/categories',
      );
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getUserTasks(int userId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.users}/$userId/tasks',
      );
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Erro de timeout na conexão');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data['message'] ?? 'Erro desconhecido';

        switch (statusCode) {
          case 400:
            return Exception('Dados inválidos: $message');
          case 401:
            return Exception('Não autorizado: $message');
          case 404:
            return Exception('Usuário não encontrado: $message');
          case 409:
            return Exception('Email já cadastrado: $message');
          case 500:
            return Exception('Erro interno do servidor: $message');
          default:
            return Exception('Erro na resposta do servidor: $message');
        }
      case DioExceptionType.cancel:
        return Exception('Requisição cancelada');
      default:
        return Exception('Erro na conexão: ${error.message}');
    }
  }
}
