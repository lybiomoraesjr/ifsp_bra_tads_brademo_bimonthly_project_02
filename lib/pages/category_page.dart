import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';
import '../services/secure_storage_service.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final CategoryService _categoryService = CategoryService();
  final SecureStorageService _secureStorage = SecureStorageService();
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<Category> _categories = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  Category? _editingCategory;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final user = await _secureStorage.getUser();
      if (user == null) {
        _showSnackBar('Usuário não autenticado');
        return;
      }

      final userId = user['id'] as int?;
      if (userId == null) {
        _showSnackBar('ID do usuário não encontrado');
        return;
      }

      final List<Map<String, dynamic>> data = await _categoryService
          .getCategories(userId: userId);
      setState(() {
        _categories = data.map((json) => Category.fromJson(json)).toList();
      });
    } catch (e) {
      _showSnackBar('Erro ao carregar categorias: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final user = await _secureStorage.getUser();
      if (user == null) {
        _showSnackBar('Usuário não autenticado');
        return;
      }

      final userId = user['id'] as int?;
      if (userId == null) {
        _showSnackBar('ID do usuário não encontrado');
        return;
      }

      final categoryData = {
        'name': _nameController.text.trim(),
        'userId': userId,
      };

      if (_editingCategory != null) {
        await _categoryService.updateCategory(
          _editingCategory!.id,
          categoryData,
        );
        _showSnackBar('Categoria atualizada com sucesso!');
      } else {
        await _categoryService.createCategory(categoryData);
        _showSnackBar('Categoria criada com sucesso!');
      }

      _clearForm();
      _loadCategories();
    } catch (e) {
      _showSnackBar('Erro ao salvar categoria: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _deleteCategory(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar exclusão'),
            content: Text(
              'Tem certeza que deseja excluir a categoria "${category.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Excluir'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await _categoryService.deleteCategory(category.id);
        _showSnackBar('Categoria excluída com sucesso!');
        _loadCategories();
      } catch (e) {
        _showSnackBar('Erro ao excluir categoria: $e');
      }
    }
  }

  void _editCategory(Category category) {
    setState(() {
      _editingCategory = category;
      _nameController.text = category.name;
    });
  }

  void _clearForm() {
    setState(() {
      _editingCategory = null;
      _nameController.clear();
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            message.contains('sucesso') ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _editingCategory != null
                        ? 'Editar Categoria'
                        : 'Nova Categoria',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nome da Categoria',
                      hintText: 'Ex: Trabalho, Pessoal, Estudos...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.category),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, insira um nome para a categoria';
                      }
                      if (value.trim().length < 2) {
                        return 'O nome deve ter pelo menos 2 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _saveCategory,
                          icon:
                              _isSubmitting
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Icon(
                                    _editingCategory != null
                                        ? Icons.save
                                        : Icons.add,
                                  ),
                          label: Text(
                            _isSubmitting
                                ? 'Salvando...'
                                : _editingCategory != null
                                ? 'Atualizar'
                                : 'Adicionar',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      if (_editingCategory != null) ...[
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _clearForm,
                          icon: const Icon(Icons.clear),
                          label: const Text('Cancelar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _categories.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Nenhuma categoria encontrada',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Adicione sua primeira categoria acima',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                category.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              category.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text('ID: ${category.id}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _editCategory(category),
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  tooltip: 'Editar',
                                ),
                                IconButton(
                                  onPressed: () => _deleteCategory(category),
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  tooltip: 'Excluir',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
