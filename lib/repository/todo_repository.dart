import 'package:f_todo/model/model.dart';

class TodoDataSource {
  Future<List<Todo>> queryAllTodo() => Todo()
      .select(getIsDeleted: false)
      // .completed
      // .equals(false)
      .orderByDesc(TodoFields.id.fieldName)
      .toList();
}
