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
      onPressed: () async {
        var content = _contentController.text;
        if (content.isNotEmpty) {
          var newTodoId = await Todo(content: content).save();
          Log.debug("新增待办事项: $newTodoId");
        }
        Navigator.pop(context);
      },
    );
  }
}
