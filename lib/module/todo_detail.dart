import 'package:f_todo/model/model.dart';
import 'package:f_todo/todo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TodoDetail extends StatefulWidget {
  final Todo item;
  TodoDetail({@required this.item});
  @override
  State createState() => TodoDetailState();
}

class TodoDetailState extends State<TodoDetail> {
  TextEditingController _titleController;
  TextEditingController _contentController;
  bool _completed;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _contentController = TextEditingController(text: widget.item.content);
    _completed = widget.item.completed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("详情"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTitle(widget.item),
            _buildContent(widget.item),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(Todo item) {
    return Container(
      margin: const EdgeInsets.all(8),
      alignment: Alignment.centerLeft,
      child: Card(
        child: Row(
          children: [
            Checkbox(
                value: _completed,
                onChanged: (completed) {
                  item.completed = completed;
                  item.save().whenComplete(() {
                    setStateSafely(() {
                      _completed = completed;
                    });
                  }).catchError((e) {
                    item.completed = !_completed;
                    Log.debug("待办事项状态变更异常: ${e?.toString()}");
                  });
                }),
            Expanded(
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  fontSize: 20,
                  color: item.completed ? Colors.grey : Colors.black,
                  decoration: item.completed
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
                onEditingComplete: () {
                  var recoverTitle = item.title;
                  item.title = _titleController.text;
                  item.save().catchError((e) {
                    Log.debug("待办事项标题变更异常: ${e?.toString()}");
                    // 保存失败则恢复之前的标题
                    item.title = recoverTitle;
                    _titleController.text = recoverTitle;
                    Scaffold.of(context).showSnackBar(
                      SnackBar(content: Text("任务保存异常")),
                    );
                  });
                },
                textInputAction: TextInputAction.done,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Todo item) {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _contentController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "任务内容",
            ),
            strutStyle: StrutStyle(
              forceStrutHeight: true,
              leading: 0.3,
            ),
            maxLines: null,
            expands: true,
            onEditingComplete: () {
              var recoverContent = item.content;
              item.content = _contentController.text;
              item.save().catchError((e) {
                Log.debug("待办事项内容变更异常: ${e?.toString()}");
                // 保存失败则恢复之前的标题
                item.content = recoverContent;
                _contentController.text = recoverContent;
                Scaffold.of(context).showSnackBar(
                  SnackBar(content: Text("任务保存异常")),
                );
              });
            },
            textInputAction: TextInputAction.done,
          ),
        ),
      ),
    );
  }
}
