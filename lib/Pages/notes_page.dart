import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:note_pad/Pages/login.dart';

class MyHomePage extends StatefulWidget {
  final User user;
  const MyHomePage({Key? key, required this.user}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _noteController = TextEditingController();


  // Upload note to Firestore
  Future<void> uploadNote(String content) async {
    if (content.trim().isEmpty) return;

    await FirebaseFirestore.instance.collection('notes').add({
      'content': content.trim(),
      'timestamp': Timestamp.now(),
      'uid': widget.user.uid,
    });
  }


  void _showEditDialog(String oldContent, String docId) {
    TextEditingController _editController = TextEditingController(text: oldContent);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Note"),
          content: TextField(
            controller: _editController,
            decoration: InputDecoration(
              hintText: "Update your note",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String newContent = _editController.text.trim();
                if (newContent.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('notes')
                      .doc(docId)
                      .update({
                    'content': newContent,
                    'timestamp': Timestamp.now(),
                    'uid': widget.user.uid,  // Add this ✅
                  });
                }
                Navigator.of(context).pop();
              },

              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Welcome ${widget.user.displayName ?? widget.user.email ?? "User"}'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => login()),
              );
            },
          ),
        ],
      ),

        body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: "Write your note...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            // Button to save the note
            ElevatedButton(
              onPressed: () async {
                if (_noteController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter something')),
                  );
                  return;
                }
                await uploadNote(_noteController.text);
                _noteController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note uploaded')),
                );
              },
              child: const Text('Save Notes'),
            ),
            const SizedBox(height: 20),

            // StreamBuilder to fetch data from Firestore
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('notes')
                    .where('uid', isEqualTo: widget.user.uid)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No notes found"));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  var notes = snapshot.data!.docs;

                  return ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        var note = notes[index].data() as Map<String, dynamic>;
                        return Card(
                          child: ListTile(
                            title: Text(note['content'] ?? ''),
                            subtitle: Text(note['timestamp'].toDate().toString()),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditDialog(note['content'], notes[index].id);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('notes')
                                        .doc(notes[index].id)
                                        .delete();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Note deleted")),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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