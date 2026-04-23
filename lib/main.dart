import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
  // This widget is the root of your application.
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      home: MyHomePage(title: 'My To-Do', onThemeChanged: _updateTheme),
    );
  }

  void _updateTheme(ThemeMode newTheme) {
    setState(() {
      _themeMode = newTheme;
    });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.onThemeChanged,
  });

  final String title;
  final void Function(ThemeMode) onThemeChanged;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> tasks = [];
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadTasks();
    });
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    String tasksJson = jsonEncode(tasks);
    await prefs.setString('tasks', tasksJson); // ← Full key!
  }

  Future<void> _loadTasks() async {
    try {
      await Future.delayed(Duration(milliseconds: 100)); // Small delay
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload(); // Force reload from storage
      String? tasksJson = prefs.getString('tasks');

      if (tasksJson != null && tasksJson.isNotEmpty) {
        setState(() {
          tasks = List<Map<String, dynamic>>.from(
            jsonDecode(
              tasksJson,
            ).map((task) => Map<String, dynamic>.from(task)),
          );
        });
      }
    } catch (e) {
      print('Load error: $e');
    }
  }

  void _showAddTaskDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController desController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add a Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: desController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String title = titleController.text;
                String description = desController.text;
                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('You can not add a task with no title!'),
                    ),
                  );
                  return;
                }
                Map<String, dynamic> newTask = {
                  'title': title,
                  'description': description,
                  'isComplete': false,
                };
                setState(() {
                  tasks.add(newTask);
                });
                _saveTasks();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Task added!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditTaskDialog(Map<String, dynamic> task) {
    // task parameter = which task to
    TextEditingController titleController = TextEditingController(
      text: task['title'],
    );
    TextEditingController descriptionController = TextEditingController(
      text: task['description'],
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Task'), // ← Changed from "Add"
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // UPDATE logic will go here (different from Add!)
                setState(() {
                  task['title'] = titleController.text;
                  task['description'] = descriptionController.text;
                });
                _saveTasks();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Task Updated!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text('Save'), // ← Changed from "Add"
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: _showAddTaskDialog,
            icon: Icon(
              Icons.add,
              color: (Theme.of(context).brightness == Brightness.light)
                  ? Colors.black
                  : Colors.amber,
              size: 32,
            ),
          ),
          IconButton(
            onPressed: () {
              if (Theme.of(context).brightness == Brightness.dark) {
                widget.onThemeChanged(ThemeMode.light);
              } else {
                widget.onThemeChanged(ThemeMode.dark);
              }
            },
            icon: (Theme.of(context).brightness == Brightness.dark)
                ? Icon(Icons.light_mode, size: 32)
                : Icon(Icons.dark_mode, size: 32),
          ),
        ],
      ),
      body: ListView(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.

        // Column is also a layout widget. It takes a list of children and
        // arranges them vertically. By default, it sizes itself to fit its
        // children horizontally, and tries to be as tall as its parent.
        //
        // Column has various properties to control how it sizes itself and
        // how it positions its children. Here we use mainAxisAlignment to
        // center the children vertically; the main axis here is the vertical
        // axis because Columns are vertical (the cross axis would be
        // horizontal).
        //
        // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
        // action in the IDE, or press "p" in the console), to see the
        // wireframe for each widget.
        children: [
          if (tasks.isEmpty)
            Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Enjoy your day, or add some tasks! :)',
                textAlign: TextAlign.center,
                style: (Theme.of(context).brightness == Brightness.light)
                    ? TextStyle(fontSize: 18, color: Colors.indigo)
                    : TextStyle(fontSize: 18, color: Colors.amber),
              ),
            )
          else
            ...tasks.map((task) {
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
                          task['title'],
                          style:
                              (Theme.of(context).brightness == Brightness.light)
                              ? TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  decoration: task['isComplete']
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                )
                              : TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  decoration: task['isComplete']
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          task['description'],
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                (Theme.of(context).brightness ==
                                    Brightness.light)
                                ? Colors.black
                                : Colors.amber,
                            decoration: task['isComplete']
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Delete Task'),
                                    content: Text(
                                      'Are you sure that you want to delete "${task['title']}"?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          setState(() {
                                            tasks.remove(
                                              task,
                                            ); // 'task' is available from .map()
                                          });
                                          _saveTasks();
                                        },
                                        child: Text(
                                          'Delete',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: Icon(Icons.delete, color: Colors.red),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  task['isComplete'] = !task['isComplete'];
                                });
                                _saveTasks();
                              },
                              icon: Icon(
                                Icons.check,
                                color: Colors.green,
                                size: 40,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _showEditTaskDialog(task);
                              },
                              icon: Icon(Icons.edit),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
