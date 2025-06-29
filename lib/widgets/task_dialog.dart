import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/task_model.dart';
import '../models/location_model.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';

class TaskDialog extends StatefulWidget {
  final Task? task;
  final Function(Task) onSave;
  final int userId;

  const TaskDialog({
    super.key,
    this.task,
    required this.onSave,
    required this.userId,
  });

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  int? _selectedCategoryId;
  int? _selectedReminderMinutes;

  final List<Map<String, dynamic>> _reminderOptions = [
    {'label': 'Sem lembrete', 'value': null},
    {'label': 'Na hora', 'value': 0},
    {'label': '1 minuto antes', 'value': 1},
    {'label': '5 minutos antes', 'value': 5},
    {'label': '10 minutos antes', 'value': 10},
    {'label': '15 minutos antes', 'value': 15},
    {'label': '30 minutos antes', 'value': 30},
    {'label': '1 hora antes', 'value': 60},
    {'label': '2 horas antes', 'value': 120},
    {'label': '1 dia antes', 'value': 1440},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _locationController = TextEditingController(
      text: widget.task?.location?.locationName ?? '',
    );
    _selectedCategoryId = widget.task?.categoryId;
    _selectedReminderMinutes = widget.task?.reminderMinutes;
    if (widget.task?.dueDate != null) {
      _selectedDate = widget.task!.dueDate;
      _selectedTime = TimeOfDay.fromDateTime(widget.task!.dueDate!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: Theme.of(context).primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: Theme.of(context).primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _fetchUserLocation() async {
    setState(() => _isLoading = true);
    try {
      final locationService = LocationService();

      final isEnabled = await locationService.isLocationServiceEnabled();
      if (!isEnabled) {
        _showSnackBar(
          'Serviço de localização desabilitado. Habilite nas configurações do dispositivo.',
        );
        return;
      }

      final permission = await locationService.checkPermission();
      if (permission == LocationPermission.denied) {
        final newPermission = await locationService.requestPermission();
        if (newPermission == LocationPermission.denied) {
          _showSnackBar(
            'Permissão de localização negada. É necessário permitir o acesso à localização.',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar(
          'Permissão de localização negada permanentemente. Habilite nas configurações do aplicativo.',
        );
        return;
      }

      final position = await locationService.getLocation();
      setState(() {
        _locationController.text =
            'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
      });
      _showSnackBar('Localização obtida com sucesso!', isSuccess: true);
    } catch (e) {
      String errorMessage = 'Erro ao obter localização';

      if (e.toString().contains('timeout')) {
        errorMessage =
            'Timeout ao obter localização. Verifique sua conexão com GPS.';
      } else if (e.toString().contains('permission')) {
        errorMessage =
            'Erro de permissão de localização. Verifique as configurações.';
      } else if (e.toString().contains('desabilitado')) {
        errorMessage =
            'Serviço de localização desabilitado. Habilite nas configurações.';
      } else {
        errorMessage =
            'Erro ao obter localização: ${e.toString().replaceFirst('Exception: ', '')}';
      }

      _showSnackBar(errorMessage);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  void _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      DateTime? dueDate;
      if (_selectedDate != null) {
        if (_selectedTime != null) {
          dueDate = DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
            _selectedTime!.hour,
            _selectedTime!.minute,
          );
        } else {
          dueDate = DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
          );
        }
      }

      final newTask = Task(
        id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        done: widget.task?.done ?? false,
        categoryId: _selectedCategoryId,
        userId: widget.userId,
        createdAt: widget.task?.createdAt ?? DateTime.now(),
        dueDate: dueDate,
        reminderMinutes: _selectedReminderMinutes,
        location:
            _locationController.text.isNotEmpty
                ? Location(
                  latitude: widget.task?.location?.latitude ?? 0.0,
                  longitude: widget.task?.location?.longitude ?? 0.0,
                  locationName: _locationController.text.trim(),
                  locationDescription:
                      widget.task?.location?.locationDescription,
                )
                : null,
      );

      print('TaskDialog: Salvando tarefa: ${newTask.toJson()}');

      await _manageTaskNotification(newTask);

      widget.onSave(newTask);
      Navigator.of(context).pop();
    } catch (e) {
      print('TaskDialog: Erro ao salvar tarefa: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar tarefa: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _manageTaskNotification(Task task) async {
    final notificationService = NotificationService();

    if (widget.task != null) {
      await notificationService.cancelTaskNotification(widget.task!.id);
    }

    if (task.dueDate != null && task.reminderMinutes != null && !task.done) {
      try {
        await notificationService.scheduleTaskNotification(
          taskId: task.id,
          taskTitle: task.title,
          dueDate: task.dueDate!,
          reminderMinutes: task.reminderMinutes!,
        );
      } catch (e) {
        print('Erro ao agendar notificação: $e');
      }
    }
  }

  void _clearDate() {
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
    });
  }

  void _clearTime() {
    setState(() {
      _selectedTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<CategoryProvider>(context).categories;
    print('TaskDialog: Categorias disponíveis: ${categories.length}');
    print(
      'TaskDialog: Categorias: ${categories.map((c) => '${c.id}: ${c.name}').toList()}',
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.task == null ? Icons.add_task : Icons.edit,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.task == null ? 'Nova Tarefa' : 'Editar Tarefa',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Título da Tarefa',
                          hintText: 'Ex: Estudar Flutter',
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, insira um título';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<int?>(
                        value: _selectedCategoryId,
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Sem categoria'),
                          ),
                          ...categories.map(
                            (cat) => DropdownMenuItem<int?>(
                              value: cat.id,
                              child: Text(cat.name),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Categoria (opcional)',
                          hintText: 'Selecione uma categoria',
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descrição',
                          hintText: 'Detalhes da tarefa...',
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: _selectDate,
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _selectedDate != null
                                                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                                    : 'Selecionar Data',
                                                style: TextStyle(
                                                  color:
                                                      _selectedDate != null
                                                          ? Colors.black
                                                          : Colors.grey,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_selectedDate != null)
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.red,
                              ),
                              onPressed: _clearDate,
                              tooltip: 'Remover data',
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap:
                                          _selectedDate != null
                                              ? _selectTime
                                              : null,
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.access_time,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _selectedTime != null
                                                    ? _selectedTime!.format(
                                                      context,
                                                    )
                                                    : 'Hora',
                                                style: TextStyle(
                                                  color:
                                                      _selectedTime != null
                                                          ? Colors.black
                                                          : Colors.grey,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_selectedTime != null)
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.red,
                              ),
                              onPressed: _clearTime,
                              tooltip: 'Remover hora',
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _locationController,
                              decoration: const InputDecoration(
                                labelText: 'Localização',
                                hintText: 'Nome do local',
                                prefixIcon: Icon(Icons.location_on),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _fetchUserLocation,
                            icon:
                                _isLoading
                                    ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Icon(Icons.my_location),
                            label: const Text('GPS'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (_selectedDate != null)
              DropdownButtonFormField<int?>(
                value: _selectedReminderMinutes,
                items:
                    _reminderOptions
                        .map(
                          (option) => DropdownMenuItem<int?>(
                            value: option['value'],
                            child: Text(option['label']),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedReminderMinutes = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Lembrete',
                  hintText: 'Selecione quando notificar',
                  prefixIcon: Icon(Icons.notifications),
                ),
              ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveTask,
                      icon: const Icon(Icons.save),
                      label: const Text('Salvar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
