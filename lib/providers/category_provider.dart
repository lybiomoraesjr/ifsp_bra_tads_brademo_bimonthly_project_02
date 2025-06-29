import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';
import '../services/secure_storage_service.dart';

class CategoryProvider extends ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;
  int? _userId;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  CategoryProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadCategories();
    });
  }

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();
    final storage = SecureStorageService();
    final user = await storage.getUser();
    if (user != null && user['id'] != null) {
      _userId = user['id'] as int;
      print('CategoryProvider: Carregando categorias para usuário $_userId');
      final rawCategories = await CategoryService().getCategories(
        userId: _userId,
      );
      print('CategoryProvider: Categorias recebidas da API: $rawCategories');
      _categories =
          rawCategories.map((json) => Category.fromJson(json)).toList();
      print('CategoryProvider: Categorias convertidas: ${_categories.length}');
    } else {
      print('CategoryProvider: Usuário não encontrado ou ID nulo');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCategory(String name) async {
    if (_userId == null) return;
    await CategoryService().createCategory({'name': name, 'userId': _userId});
    await loadCategories();
  }

  Future<void> updateCategory(int id, String name) async {
    if (_userId == null) return;
    await CategoryService().updateCategory(id, {
      'name': name,
      'userId': _userId,
    });
    await loadCategories();
  }

  Future<void> deleteCategory(int id) async {
    await CategoryService().deleteCategory(id);
    await loadCategories();
  }
}
