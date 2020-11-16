import 'package:f_todo/model/model.dart';
import 'package:flutter/widgets.dart';

enum TodoListEvent {
  ADD,
  REMOVE,
  UPDATE,
}

class TodoListProvider with ChangeNotifier {
  TodoListEvent event;
  int index;
  Todo item;
}
