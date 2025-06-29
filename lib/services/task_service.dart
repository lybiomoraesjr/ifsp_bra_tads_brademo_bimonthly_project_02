import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class TaskService {
  final ApiService _apiService;

  TaskService() : _apiService = ApiService(baseUrl: ApiConstants.baseUrl);

  Future<List<Map<String, dynamic>>> getTasks({int? userId}) async {
    try {
      print('TaskService: getTasks chamado com userId: $userId');
      final queryParams = userId != null ? {'userId': userId} : null;
      print('TaskService: Query params: $queryParams');
      print(
        'TaskService: URL da requisição: ${ApiConstants.baseUrl}${ApiConstants.tasks}',
      );

      final response = await _apiService.get(
        ApiConstants.tasks,
        queryParameters: queryParams,
      );
      print('TaskService: Resposta da API: ${response.statusCode}');
      print('TaskService: Dados da resposta: ${response.data}');

      final tasks = List<Map<String, dynamic>>.from(response.data);
      print('TaskService: Tarefas convertidas: ${tasks.length}');

      return tasks;
    } on DioException catch (e) {
      print('TaskService: Erro na requisição getTasks: $e');
      throw _handleError(e);
    } catch (e) {
      print('TaskService: Erro inesperado em getTasks: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getTaskById(int id) async {
    try {
      final response = await _apiService.get('${ApiConstants.tasks}/$id');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createTask(Map<String, dynamic> taskData) async {
    try {
      final response = await _apiService.post(
        ApiConstants.tasks,
        data: taskData,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateTask(
    int id,
    Map<String, dynamic> taskData,
  ) async {
    try {
      final response = await _apiService.put(
        '${ApiConstants.tasks}/$id',
        data: taskData,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> deleteTask(int id) async {
    try {
      final response = await _apiService.delete('${ApiConstants.tasks}/$id');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> toggleTask(int id) async {
    try {
      final response = await _apiService.patch(
        '${ApiConstants.tasks}/$id/toggle',
      );
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
        final message = error.response?.data?['message'] ?? 'Erro desconhecido';

        switch (statusCode) {
          case 400:
            return Exception('Dados inválidos: $message');
          case 404:
            return Exception('Tarefa não encontrada: $message');
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
        return Exception(
          'Erro desconhecido: ${error.message ?? 'Sem detalhes'}',
        );
      default:
        final errorMessage = error.message ?? 'Erro de conexão';
        return Exception('Erro na conexão: $errorMessage');
    }
  }
}
