import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/task_model.dart';

class TaskProvider extends ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<TaskModel> tasks = [];

  void clearTasks() {
    tasks.clear();
    notifyListeners();
  }

  Future<void> fetchTasks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot =
        await firestore
            .collection("users")
            .doc(user.uid)
            .collection("tasks")
            .get();

    tasks =
        snapshot.docs
            .map((doc) => TaskModel.fromMap(doc.id, doc.data()))
            .where((task) => !task.isDeleted)
            .toList();

    // Organize tasks effectively: incomplete first, then completed.
    tasks.sort((a, b) {
      if (a.isCompleted == b.isCompleted) return 0;
      return a.isCompleted ? 1 : -1;
    });

    notifyListeners();
  }

  Future<void> addTask(String title) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await firestore.collection("users").doc(user.uid).collection("tasks").add({
      "title": title,
      "isCompleted": false,
      "isDeleted": false,
      "createdAt": FieldValue.serverTimestamp(),
    });

    fetchTasks();
  }

  Future<void> deleteTask(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Soft delete: toggle isDeleted flag
    await firestore
        .collection("users")
        .doc(user.uid)
        .collection("tasks")
        .doc(id)
        .update({"isDeleted": true});

    fetchTasks();
  }

  Future<void> toggleTask(TaskModel task) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await firestore
        .collection("users")
        .doc(user.uid)
        .collection("tasks")
        .doc(task.id)
        .update({"isCompleted": !task.isCompleted});

    fetchTasks();
  }

  Future<void> updateTask(String id, String newTitle) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await firestore
        .collection("users")
        .doc(user.uid)
        .collection("tasks")
        .doc(id)
        .update({"title": newTitle});

    fetchTasks();
  }
}
