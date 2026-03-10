class TaskModel {
  String id;
  String title;
  bool isCompleted;

  TaskModel({required this.id, required this.title, required this.isCompleted});

  // Convert Firestore JSON → TaskModel
  factory TaskModel.fromMap(String id, Map<String, dynamic> data) {
    return TaskModel(
      id: id,
      title: data['title'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  // Convert TaskModel → JSON for Firestore
  Map<String, dynamic> toMap() {
    return {'title': title, 'isCompleted': isCompleted};
  }
}
