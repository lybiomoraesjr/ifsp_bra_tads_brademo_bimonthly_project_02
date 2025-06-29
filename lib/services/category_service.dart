import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class CategoryService {
  final ApiService _apiService;

  CategoryService() : _apiService = ApiService(baseUrl: ApiConstants.baseUrl);

  Future<List<Map<String, dynamic>>> getCategories({int? userId}) async {
    try {
      final queryParams = userId != null ? {'userId': userId} : null;
      print('CategoryService: Fazendo requisição para ${ApiConstants.baseUrl}${ApiConstants.categories}');
      print('CategoryService: Parâmetros: $queryParams');
      final response = await _apiService.get(ApiConstants.categories, queryParameters: queryParams);
      print('CategoryService: Resposta da API: ${response.data}');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      print('CategoryService: Erro na requisição: $e');
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getCategoryById(int id) async {
    try {
      final response = await _apiService.get('${ApiConstants.categories}/$id');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createCategory(Map<String, dynamic> categoryData) async {
    try {
      final response = await _apiService.post(ApiConstants.categories, data: categoryData);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateCategory(int id, Map<String, dynamic> categoryData) async {
    try {
      final response = await _apiService.put('${ApiConstants.categories}/$id', data: categoryData);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> deleteCategory(int id) async {
    try {
      final response = await _apiService.delete('${ApiConstants.categories}/$id');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getCategoryTasks(int categoryId) async {
    try {
      final response = await _apiService.get('${ApiConstants.categories}/$categoryId/tasks');
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
        final message = error.response?.data?['message'] ?? 'Erro desconhecido';

        switch (statusCode) {
          case 400:
            return Exception('Dados inválidos: $message');
          case 404:
            return Exception('Categoria não encontrada: $message');
          case 500:
            return Exception('Erro interno do servidor: $message');
          default:
            return Exception('Erro na resposta do servidor: $message');
        }
      case DioExceptionType.cancel:
        return Exception('Requisição cancelada');
      case DioExceptionType.connectionError:
        return Exception('Erro de conexão: Verifique sua internet');
      case DioExceptionType.unknown:
        return Exception('Erro desconhecido: ${error.message ?? 'Sem detalhes'}');
      default:
        final errorMessage = error.message ?? 'Erro de conexão';
        return Exception('Erro na conexão: $errorMessage');
    }
  }
} 