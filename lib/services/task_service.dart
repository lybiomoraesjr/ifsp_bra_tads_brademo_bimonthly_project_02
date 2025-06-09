import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class TaskService {
  final ApiService _apiService;

  TaskService() : _apiService = ApiService(baseUrl: ApiConstants.baseUrl);

  Future<Response> getTasks() async {
    return await _apiService.get(ApiConstants.tasks);
  }

  Future<Response> getTasksByCategory(int categoryId) async {
    return await _apiService.get(
      ApiConstants.tasks,
      queryParameters: {'categoryId': categoryId},
    );
  }

  Future<Response> getTaskById(int id) async {
    return await _apiService.get('${ApiConstants.tasks}/$id');
  }

  Future<Response> createTask(Map<String, dynamic> taskData) async {
    return await _apiService.post(ApiConstants.tasks, data: taskData);
  }

  Future<Response> updateTask(int id, Map<String, dynamic> taskData) async {
    return await _apiService.put('${ApiConstants.tasks}/$id', data: taskData);
  }

  Future<Response> deleteTask(int id) async {
    return await _apiService.delete('${ApiConstants.tasks}/$id');
  }

  Future<Response> completeTask(int id) async {
    return await _apiService.put('${ApiConstants.tasks}/$id/complete');
  }
} 