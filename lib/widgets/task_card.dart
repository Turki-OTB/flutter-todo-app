import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;

  const TaskCard({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onToggleComplete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Card(
        elevation: 5,
        color: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(12),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                task.title,
                style: (Theme.of(context).brightness == Brightness.light)
                    ? TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        decoration: task.isComplete
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      )
                    : TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        decoration: task.isComplete
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
              ),
              SizedBox(height: 8),
              Text(
                task.description,
                style: TextStyle(
                  fontSize: 16,
                  color: (Theme.of(context).brightness == Brightness.light)
                      ? Colors.black
                      : Colors.amber,
                  decoration: task.isComplete
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(Icons.delete, color: Colors.red),
                  ),
                  IconButton(
                    onPressed: onToggleComplete,
                    icon: Icon(Icons.check, color: Colors.green, size: 40),
                  ),
                  IconButton(onPressed: onEdit, icon: Icon(Icons.edit)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
