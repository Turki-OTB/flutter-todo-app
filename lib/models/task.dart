//class to create a task

class Task {
  String title;
  String description;
  bool isComplete = false;

  //Named constructre, we use this because the order here to add a task doesn't matter

  Task({
    required this.title,
    required this.description,
    this.isComplete = false,
  });

  //convert a task to json
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isComplete': isComplete,
    };
  }
  //get task from json and create an object of task, through the constructure.

  Task.fromJson(Map<String, dynamic> json)
    : title = json['title'],
      description = json['description'],
      isComplete = json['isComplete'];
}
