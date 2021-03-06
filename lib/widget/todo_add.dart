import 'package:f_todo/model/model.dart';
import 'package:f_todo/todo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TodoAddBottomSheet extends StatefulWidget {
  @override
  State createState() => TodoAddBottomSheetState();
}

class TodoAddBottomSheetState extends State<TodoAddBottomSheet> {
  var _contentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(child: _buildInputTextField()),
          _buildDoneIcon(),
        ],
      ),
    );
  }

  Widget _buildInputTextField() {
    return TextField(
      controller: _contentController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: "请输入待办事项",
        fillColor: Color(0x30cccccc),
        filled: true,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0x00FF0000)),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0x00000000)),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      textInputAction: TextInputAction.done,
    );
  }

  Widget _buildDoneIcon() {
    return IconButton(
      icon: Icon(Icons.done),
      color: Colors.lightBlue,
      onPressed: () {
        var title = _contentController.text;
        if (title.isEmpty) {
          Navigator.pop(context);
          return;
        }
        var item = Todo(
          title: title,
          createdTime: DateTime.now().millisecondsSinceEpoch,
        );
        item.save().then((newTodoId) {
          Log.debug("新增待办事项id: $newTodoId");
          Navigator.pop(context, item);
        });
      },
    );
  }
}
