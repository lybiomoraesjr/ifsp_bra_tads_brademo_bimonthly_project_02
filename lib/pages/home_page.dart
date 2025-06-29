import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../widgets/task_dialog.dart';
import '../models/category_model.dart';
import '../services/secure_storage_service.dart';
import '../services/task_service.dart';
import '../services/notification_service.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Task> _tasks = [];
  String _searchQuery = '';
  Category? _selectedCategory;
  List<Category> _categories = [];
  bool _isLoadingCategories = false;
  final SecureStorageService _secureStorage = SecureStorageService();
  final TaskService _taskService = TaskService();
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserAndCategories();
    _testApiConnection();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserAndCategories();
  }

  Future<void> _loadUserAndCategories() async {
    print('HomePage: _loadUserAndCategories iniciado');
    setState(() => _isLoadingCategories = true);

    try {
      final user = await _secureStorage.getUser();
      print('HomePage: Usuário carregado do storage: $user');

      if (user != null && user['id'] != null) {
        _userId = user['id'] as int;
        print('HomePage: _userId definido como $_userId');

        final categoryProvider = Provider.of<CategoryProvider>(
          context,
          listen: false,
        );
        await categoryProvider.loadCategories();

        setState(() {
          _categories = categoryProvider.categories;
        });

        print('HomePage: Categorias carregadas: ${_categories.length}');

        await _loadTasks();
      } else {
        print('HomePage: Usuário não encontrado ou ID nulo');
      }
    } catch (e) {
      print('HomePage: Erro em _loadUserAndCategories: $e');
    } finally {
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _loadTasks() async {
    print('HomePage: _loadTasks iniciado');
    print('HomePage: _userId = $_userId');

    if (_userId == null) {
      print('HomePage: _userId é null, não carregando tarefas');
      return;
    }

    try {
      final categoryMapping = <String, int>{};
      for (final category in _categories) {
        categoryMapping[category.name] = category.id;
      }
      Task.setCategoryMapping(categoryMapping);
      print('HomePage: Mapeamento de categorias configurado: $categoryMapping');

      print(
        'HomePage: Fazendo requisição para carregar tarefas do usuário $_userId',
      );
      final data = await _taskService.getTasks(userId: _userId);
      print('HomePage: Tarefas recebidas da API: ${data.length}');
      print('HomePage: Dados das tarefas: $data');

      setState(() {
        _tasks.clear();
        _tasks.addAll(data.map((json) => Task.fromJson(json)));
      });

      print('HomePage: Tarefas carregadas no estado: ${_tasks.length}');
      
      for (int i = 0; i < _tasks.length; i++) {
        final task = _tasks[i];
        print('HomePage: Tarefa $i - "${task.title}" - categoryId: ${task.categoryId}');
      }
    } catch (e) {
      print('HomePage: Erro ao carregar tarefas: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar tarefas: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _testApiConnection() async {
    try {
      final apiService = ApiService(baseUrl: ApiConstants.baseUrl);
      final isConnected = await apiService.testConnection();
      print('HomePage: API conectada: $isConnected');
    } catch (e) {
      print('HomePage: Erro ao testar API: $e');
    }
  }

  void _addTask(Task task) async {
    try {
      final created = await _taskService.createTask(task.toJson());
      print('Resposta da API ao criar task: $created');
      final newTask = Task.fromJson(created);
      setState(() {
        _tasks.add(newTask);
      });
    } catch (e, stack) {
      print('Erro ao criar task: $e');
      print(stack);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar tarefa: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editTask(int index, Task updatedTask) async {
    try {
      print('HomePage: Editando tarefa ${updatedTask.id}');
      print('HomePage: Dados da tarefa: ${updatedTask.toJson()}');

      final updated = await _taskService.updateTask(
        updatedTask.id,
        updatedTask.toJson(),
      );
      print('HomePage: Resposta da API: $updated');

      setState(() {
        _tasks[index] = Task.fromJson(updated);
      });
    } catch (e) {
      print('HomePage: Erro ao editar tarefa: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao editar tarefa: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteTask(int index) async {
    try {
      final taskToDelete = _tasks[index];

      final notificationService = NotificationService();
      await notificationService.cancelTaskNotification(taskToDelete.id);

      await _taskService.deleteTask(taskToDelete.id);

      setState(() {
        _tasks.removeAt(index);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao deletar tarefa: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleTaskCompletion(int index) async {
    try {
      final toggled = await _taskService.toggleTask(_tasks[index].id);
      final updatedTask = Task.fromJson(toggled);

      final notificationService = NotificationService();
      if (updatedTask.done) {
        await notificationService.cancelTaskNotification(updatedTask.id);
      } else if (updatedTask.dueDate != null &&
          updatedTask.reminderMinutes != null) {
        await notificationService.scheduleTaskNotification(
          taskId: updatedTask.id,
          taskTitle: updatedTask.title,
          dueDate: updatedTask.dueDate!,
          reminderMinutes: updatedTask.reminderMinutes!,
        );
      }

      setState(() {
        _tasks[index] = updatedTask;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao alterar status da tarefa: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showTaskDialog({Task? task, int? index}) {
    showDialog(
      context: context,
      builder: (context) {
        return TaskDialog(
          task: task,
          onSave: (newTask) {
            if (task == null) {
              _addTask(newTask);
            } else if (index != null) {
              _editTask(index, newTask);
            }
          },
          userId: _userId ?? 1,
        );
      },
    );
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar exclusão'),
            content: Text(
              'Tem certeza que deseja excluir a tarefa "${_tasks[index].title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteTask(index);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Excluir'),
              ),
            ],
          ),
    );
  }

  List<Task> get _filteredTasks {
    print('HomePage: _filteredTasks - Iniciando filtro');
    print('HomePage: Total de tarefas: ${_tasks.length}');
    print('HomePage: Categoria selecionada: ${_selectedCategory?.name} (ID: ${_selectedCategory?.id})');
    print('HomePage: Query de busca: "$_searchQuery"');
    
    final filtered = _tasks.where((task) {
      final matchesName =
          _searchQuery.isEmpty ||
          task.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == null || task.categoryId == _selectedCategory!.id;
      
      print('HomePage: Tarefa "${task.title}" - categoryId: ${task.categoryId}, matchesName: $matchesName, matchesCategory: $matchesCategory');
      
      return matchesName && matchesCategory;
    }).toList();
    
    print('HomePage: Tarefas filtradas: ${filtered.length}');
    return filtered;
  }

  String _formatDueDate(DateTime dueDate) {
    if (dueDate.hour == 0 && dueDate.minute == 0) {
      return '${dueDate.day.toString().padLeft(2, '0')}/${dueDate.month.toString().padLeft(2, '0')}/${dueDate.year}';
    } else {
      return '${dueDate.day.toString().padLeft(2, '0')}/${dueDate.month.toString().padLeft(2, '0')}/${dueDate.year} '
          '${dueDate.hour.toString().padLeft(2, '0')}:${dueDate.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedTasks = _filteredTasks.where((task) => task.done).length;
    final totalTasks = _filteredTasks.length;
    final pendingTasks = totalTasks - completedTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () async {
              try {
                await NotificationService().testNotification();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notificação de teste enviada!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao testar notificação: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            tooltip: 'Testar Notificação',
          ),
          if (_filteredTasks.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$completedTasks/$totalTasks',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar por nome...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                _isLoadingCategories
                    ? const SizedBox(
                      width: 120,
                      height: 40,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                    : DropdownButton<Category?>(
                      value: _selectedCategory,
                      hint: const Text('Categoria'),
                      items: [
                        const DropdownMenuItem<Category?>(
                          value: null,
                          child: Text('Todas'),
                        ),
                        ..._categories.map(
                          (cat) => DropdownMenuItem<Category?>(
                            value: cat,
                            child: Text(cat.name),
                          ),
                        ),
                      ],
                      onChanged: (cat) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                    ),
              ],
            ),
          ),
          if (_filteredTasks.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Pendentes',
                      pendingTasks.toString(),
                      Icons.pending,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Concluídas',
                      completedTasks.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child:
                _filteredTasks.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = _filteredTasks[index];
                        return _buildTaskCard(task, _tasks.indexOf(task));
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: task.done,
          onChanged: (value) => _toggleTaskCompletion(index),
          activeColor: Theme.of(context).primaryColor,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.done ? TextDecoration.lineThrough : null,
            color: task.done ? Colors.grey : null,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Text(
                task.description,
                style: TextStyle(
                  decoration: task.done ? TextDecoration.lineThrough : null,
                  color: task.done ? Colors.grey : Colors.grey[600],
                ),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (task.dueDate != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color:
                            task.dueDate!.isBefore(DateTime.now()) && !task.done
                                ? Colors.red
                                : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDueDate(task.dueDate!),
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              task.dueDate!.isBefore(DateTime.now()) &&
                                      !task.done
                                  ? Colors.red
                                  : Colors.grey[600],
                          fontWeight:
                              task.dueDate!.isBefore(DateTime.now()) &&
                                      !task.done
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showTaskDialog(task: task, index: index),
              tooltip: 'Editar',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmation(index),
              tooltip: 'Excluir',
              style: IconButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.task_alt,
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhuma tarefa encontrada',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque no botão + para adicionar sua primeira tarefa',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showTaskDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Tarefa'),
          ),
        ],
      ),
    );
  }
}
