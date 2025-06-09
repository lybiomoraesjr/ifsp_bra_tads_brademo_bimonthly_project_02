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
      final response = await _apiService.post(
        '${ApiConstants.users}/login',
        data: {'email': email, 'password': password},
      );

      final userData = response.data;

      // await _secureStorage.saveToken(userData['token']);
      await _secureStorage.saveUser(userData['user']);

      return userData;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await _apiService.post(
        '${ApiConstants.users}/register',
        data: userData,
      );

      final data = response.data;

      // await _secureStorage.saveToken(data['token']); 
      await _secureStorage.saveUser(data['user']);

      return data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post('${ApiConstants.users}/logout');
    } finally {
      await _secureStorage.clearUserData();
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
          case 401:
            return Exception(
              'Não autorizado. Por favor, faça login novamente.',
            );
          case 403:
            return Exception('Acesso negado.');
          case 404:
            return Exception('Usuário não encontrado.');
          case 409:
            return Exception('Email já cadastrado.');
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
