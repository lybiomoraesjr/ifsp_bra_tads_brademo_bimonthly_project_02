import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../models/category_model.dart';

class TaskDialog extends StatelessWidget {
  final Task? task;
  final Function(Task) onSave;

  const TaskDialog({super.key, this.task, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController(text: task?.title);
    final descriptionController = TextEditingController(
      text: task?.description,
    );

    return AlertDialog(
      title: Text(task == null ? 'Add Task' : 'Edit Task'),
      content: Column(
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
        ],
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
              user: task?.user ?? User(id: 1, name: 'Default User'),
              category:
                  task?.category ?? Category(id: 1, name: 'Default Category'),
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
