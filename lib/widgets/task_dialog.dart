import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../models/location_model.dart';

class TaskDialog extends StatelessWidget {
  final Task? task;
  final Function(Task) onSave;

  const TaskDialog({super.key, this.task, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController(text: task?.title);
    final descriptionController = TextEditingController(text: task?.description);
    final dueDateController = TextEditingController(
      text: task?.dueDate?.toIso8601String(),
    );
    final locationController = TextEditingController(
      text: task?.location?.locationName,
    );

    return AlertDialog(
      title: Text(task == null ? 'Add Task' : 'Edit Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: dueDateController,
              decoration: const InputDecoration(labelText: 'Due Date (ISO format)'),
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location Name'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final newTask = Task(
              id: task?.id ?? DateTime.now().millisecondsSinceEpoch,
              title: titleController.text,
              description: descriptionController.text,
              done: task?.done ?? false,
              category: task?.category ?? 'Default Category',
              createdAt: task?.createdAt ?? DateTime.now(),
              dueDate: dueDateController.text.isNotEmpty
                  ? DateTime.parse(dueDateController.text)
                  : null,
              location: locationController.text.isNotEmpty
                  ? Location(
                      latitude: task?.location?.latitude ?? 0.0,
                      longitude: task?.location?.longitude ?? 0.0,
                      locationName: locationController.text,
                      locationDescription: task?.location?.locationDescription,
                    )
                  : null,
            );

            onSave(newTask);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
