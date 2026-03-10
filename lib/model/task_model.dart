class TaskModel {
  String id;
  String title;
  bool isCompleted;
  bool isDeleted;

  TaskModel({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.isDeleted,
  });

  // Convert Firestore JSON → TaskModel
  factory TaskModel.fromMap(String id, Map<String, dynamic> data) {
    return TaskModel(
      id: id,
      title: data['title'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  // Convert TaskModel → JSON for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted,
      'isDeleted': isDeleted,
    };
  }
}
