import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class CategoryService {
  final ApiService _apiService;

  CategoryService() : _apiService = ApiService(baseUrl: ApiConstants.baseUrl);

  Future<Response> getCategories() async {
    return await _apiService.get(ApiConstants.categories);
  }

  Future<Response> getCategoryById(int id) async {
    return await _apiService.get('${ApiConstants.categories}/$id');
  }

  Future<Response> createCategory(Map<String, dynamic> categoryData) async {
    return await _apiService.post(ApiConstants.categories, data: categoryData);
  }

  Future<Response> updateCategory(int id, Map<String, dynamic> categoryData) async {
    return await _apiService.put('${ApiConstants.categories}/$id', data: categoryData);
  }

  Future<Response> deleteCategory(int id) async {
    return await _apiService.delete('${ApiConstants.categories}/$id');
  }
} 