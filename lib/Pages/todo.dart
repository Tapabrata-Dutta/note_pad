import 'package:cloud_firestore/cloud_firestore.dart';

class Todoo {
  Timestamp createdOn;
  bool isDone;
  String tasks;
  Timestamp updatedOn;

  Todoo({
    required this.createdOn,
    required this.isDone,
    required this.tasks,
    required this.updatedOn,
});

  Todoo.fromJson(Map<String, Object?> json ): this
      (
      createdOn: json [ 'createdOn' ] ! as Timestamp,
      isDone: json ['isDone']! as bool,
      tasks: json ['tasks']! as String,
      updatedOn: json ['updatedOn'] ! as Timestamp,
    );

  Todoo copyWith({
    Timestamp? createdOn,
    bool? isDone,
    String? tasks,
    Timestamp? updatedOn,
}){
    return Todoo(createdOn: createdOn ?? this.createdOn,
        isDone: isDone ?? this.isDone,
        tasks: tasks ?? this.tasks,
        updatedOn: updatedOn ?? this.updatedOn);
  }

  Map<String, Object?> toJson(){
    return {
      'createdOn' : createdOn,
      'isDone' : isDone,
      'tasks' : tasks,
      'updatedOn' : updatedOn,
    };
  }
}