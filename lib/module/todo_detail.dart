import 'package:f_todo/model/model.dart';
import 'package:f_todo/widget/todo_detail_content.dart';
import 'package:f_todo/widget/todo_detail_remind.dart';
import 'package:f_todo/widget/todo_detail_title.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class TodoDetail extends StatelessWidget {
  final Todo item;
  final DateFormat _formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  TodoDetail({@required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("任务详情"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TodoDetailTitle(item: item),
            TodoDetailContent(item: item),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Card(
                child: Column(
                  children: [
                    TodoDetailRemind(item: item),
                    const Divider(
                      indent: 4,
                      endIndent: 4,
                    ),
                    TodoCreatedTime(item: item),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
