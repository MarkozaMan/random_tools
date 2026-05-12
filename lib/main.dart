import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const RandomToolsApp());
}

class RandomToolsApp extends StatelessWidget {
  const RandomToolsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Tools',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void openPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Random Tools')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => openPage(context, const NotesPage()),
              child: const Text('Note Taking'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => openPage(context, const TodoPage()),
              child: const Text('Todo List'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => openPage(context, const ChoicePage()),
              child: const Text('Random Choice Picker'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => openPage(context, const StopwatchPage()),
              child: const Text('Stopwatch'),
            ),
          ],
        ),
      ),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _controller = TextEditingController();
  List<String> notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getString('notes');
    if (notesJson != null) {
      final List<dynamic> decoded = json.decode(notesJson);
      setState(() {
        notes = decoded.cast<String>();
      });
    }
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = json.encode(notes);
    await prefs.setString('notes', notesJson);
  }

  void addNote() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      notes.add(text);
      _controller.clear();
    });
    _saveNotes();
  }

  void deleteNote(int index) {
    setState(() {
      notes.removeAt(index);
    });
    _saveNotes();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Note Taking')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Add a new note',
                    ),
                    onSubmitted: (_) => addNote(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: addNote, child: const Text('Add')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return Card(
                    child: ListTile(
                      title: Text(note),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => deleteNote(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController _todoController = TextEditingController();
  final List<_TodoItem> items = [];

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = prefs.getString('todos');
    if (todosJson != null) {
      final List<dynamic> decoded = json.decode(todosJson);
      setState(() {
        items.addAll(decoded.map((e) => _TodoItem.fromJson(e)));
      });
    }
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = json.encode(items.map((e) => e.toJson()).toList());
    await prefs.setString('todos', todosJson);
  }

  void addTodo() {
    final text = _todoController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      items.add(_TodoItem(text));
      _todoController.clear();
    });
    _saveTodos();
  }

  void toggleTodo(int index) {
    setState(() {
      items[index].done = !items[index].done;
    });
    _saveTodos();
  }

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo List')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _todoController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Add todo item',
                    ),
                    onSubmitted: (_) => addTodo(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: addTodo, child: const Text('Add')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return CheckboxListTile(
                    title: Text(item.text),
                    value: item.done,
                    onChanged: (value) => toggleTodo(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodoItem {
  _TodoItem(this.text);
  final String text;
  bool done = false;

  Map<String, dynamic> toJson() => {'text': text, 'done': done};

  factory _TodoItem.fromJson(Map<String, dynamic> json) =>
      _TodoItem(json['text'])..done = json['done'];
}

class ChoicePage extends StatefulWidget {
  const ChoicePage({super.key});

  @override
  State<ChoicePage> createState() => _ChoicePageState();
}

class _ChoicePageState extends State<ChoicePage> {
  final TextEditingController _choicesController = TextEditingController();
  String result = '';

  void pickRandom() {
    final raw = _choicesController.text.trim();
    final list = raw
        .split(RegExp(r'[\n,;]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (list.isEmpty) {
      setState(() => result = 'Enter at least one choice.');
      return;
    }
    final index = Random().nextInt(list.length);
    setState(() => result = 'Picked: ${list[index]}');
  }

  @override
  void dispose() {
    _choicesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Random Choice Picker')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _choicesController,
              maxLines: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter choices separated by commas or new lines',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: pickRandom, child: const Text('Pick')),
            const SizedBox(height: 16),
            Text(result, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  State<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  int totalElapsedMs = 0;
  DateTime? startTime;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _loadElapsed();
  }

  Future<void> _loadElapsed() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalElapsedMs = prefs.getInt('stopwatch_elapsed') ?? 0;
    });
  }

  Future<void> _saveElapsed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('stopwatch_elapsed', totalElapsedMs);
  }

  @override
  void dispose() {
    timer?.cancel();
    _saveElapsed();
    super.dispose();
  }

  void updateTime() {
    setState(() {});
  }

  void startStopwatch() {
    startTime = DateTime.now();
    updateTime(); // immediate update
    timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => updateTime(),
    );
  }

  void stopStopwatch() {
    if (startTime != null) {
      totalElapsedMs += DateTime.now().difference(startTime!).inMilliseconds;
      startTime = null;
    }
    timer?.cancel();
    setState(() {});
    _saveElapsed();
  }

  void resetStopwatch() {
    totalElapsedMs = 0;
    startTime = null;
    timer?.cancel();
    setState(() {});
    _saveElapsed();
  }

  int currentElapsedMs() {
    if (startTime == null) return totalElapsedMs;
    return totalElapsedMs +
        DateTime.now().difference(startTime!).inMilliseconds;
  }

  String formattedTime() {
    final ms = currentElapsedMs();
    final seconds = (ms ~/ 1000) % 60;
    final minutes = (ms ~/ 60000) % 60;
    final hundredths = (ms ~/ 10) % 100;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${hundredths.toString().padLeft(2, '0')}';
  }

  bool isRunning() => startTime != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stopwatch')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              formattedTime(),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: isRunning() ? stopStopwatch : startStopwatch,
                  child: Text(isRunning() ? 'Stop' : 'Start'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: resetStopwatch,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
