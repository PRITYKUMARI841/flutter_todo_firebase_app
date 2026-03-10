import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController taskController = TextEditingController();

  final user = FirebaseAuth.instance.currentUser;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  void addTask() async {
    if (taskController.text.isEmpty) return;

    await firestore.collection("users").doc(user!.uid).collection("tasks").add({
      "title": taskController.text,
      "isCompleted": false,
      "createdAt": Timestamp.now(),
    });

    taskController.clear();
  }

  void deleteTask(String taskId) async {
    await firestore
        .collection("users")
        .doc(user!.uid)
        .collection("tasks")
        .doc(taskId)
        .delete();
  }

  void toggleTask(bool value, String taskId) async {
    await firestore
        .collection("users")
        .doc(user!.uid)
        .collection("tasks")
        .doc(taskId)
        .update({"isCompleted": value});
  }

  void showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Task"),
          content: TextField(
            controller: taskController,
            decoration: const InputDecoration(hintText: "Enter task"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                addTask();
                Navigator.pop(context);
              },
              child: const Text("Add"),
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
        title: const Text("Todo List"),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream:
            firestore
                .collection("users")
                .doc(user!.uid)
                .collection("tasks")
                .orderBy("createdAt")
                .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var tasks = snapshot.data!.docs;

          if (tasks.isEmpty) {
            return const Center(child: Text("No Tasks Yet"));
          }

          return ListView.builder(
            itemCount: tasks.length,

            itemBuilder: (context, index) {
              var task = tasks[index];

              return ListTile(
                title: Text(
                  task["title"],
                  style: TextStyle(
                    decoration:
                        task["isCompleted"]
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                  ),
                ),

                leading: Checkbox(
                  value: task["isCompleted"],
                  onChanged: (value) {
                    toggleTask(value!, task.id);
                  },
                ),

                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    deleteTask(task.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
