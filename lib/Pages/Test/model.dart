import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ToDo(),
    );
  }
}

class ToDo extends StatefulWidget {
  const ToDo({super.key});

  @override
  State<ToDo> createState() => _ToDo();
}

class _ToDo extends State<ToDo> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _newTaskController = TextEditingController();

  Future<void> _addTask(String taskText) async {
    if (taskText.trim().isEmpty) return;
    await _firestore.collection('tasks').add({
      'text': taskText.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });
    _newTaskController.clear();
  }

  Future<void> _deleteTask(String docId) async {
    await _firestore.collection('tasks').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Welcome buddy",
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        centerTitle: true,
        leading: const Icon(Icons.accessibility_new_rounded),
        toolbarHeight: 50,
        toolbarOpacity: 0.8,
        titleSpacing: 70,
        titleTextStyle: const TextStyle(
          color: Colors.blue,
          fontSize: 25,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
        elevation: 10,
        shadowColor: Colors.black,
        primary: true,
        shape: const Border(
          left: BorderSide(color: Colors.pink, width: 3),
          right: BorderSide(color: Colors.pink, width: 3),
          top: BorderSide(color: Colors.pink, width: 2),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _newTaskController,
              decoration: InputDecoration(
                hintText: 'Enter a task',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addTask(_newTaskController.text),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('tasks')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final tasks = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final doc = tasks[index];
                    final taskText = doc['text'];
                    return ListTile(
                      title: Text(taskText),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteTask(doc.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}