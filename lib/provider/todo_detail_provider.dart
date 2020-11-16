import 'package:f_todo/model/model.dart';
import 'package:f_todo/todo.dart';
import 'package:flutter/widgets.dart';

class TodoDetailProvider with ChangeNotifier {
  final Todo item;
  TodoDetailProvider({@required this.item});

  void modifyState({complete = true}) {
    item.completed = complete;
    item.completedTime =
        complete ? DateTime.now().millisecondsSinceEpoch : null;
    item.save().whenComplete(() {
      notifyListeners();
    }).catchError((e) {
      Log.debug("待办事项状态变更异常: ${e?.toString()}");
    });
  }
}
