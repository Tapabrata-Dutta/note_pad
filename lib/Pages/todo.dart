import 'package:cloud_firestore/cloud_firestore.dart';

class Toodoo {
  Timestamp createdOn;
  bool isDone;
  String tasks;
  Timestamp updatedOn;

  Toodoo({
    required this.createdOn,
    required this.isDone,
    required this.tasks,
    required this.updatedOn,
});

  Toodoo.fromJson(Map<String, Object?> json ): this
      (
      createdOn: json [ 'createdOn' ] ! as Timestamp,
      isDone: json ['isDone']! as bool,
      tasks: json ['tasks']! as String,
      updatedOn: json ['updatedOn'] ! as Timestamp,
    );

  Toodoo copyWith({
    Timestamp? createdOn,
    bool? isDone,
    String? tasks,
    Timestamp? updatedOn,
}){
    return Toodoo(createdOn: createdOn ?? this.createdOn,
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