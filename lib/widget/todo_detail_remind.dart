import 'package:f_todo/model/model.dart';
import 'package:f_todo/todo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class TodoDetailRemind extends StatefulWidget {
  final Todo item;
  TodoDetailRemind({@required this.item});
  @override
  _TodoDetailRemindState createState() => _TodoDetailRemindState();
}

class _TodoDetailRemindState extends State<TodoDetailRemind> {
  final DateFormat _formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  DateTime _remindDate;

  @override
  void initState() {
    super.initState();
    if (widget.item.remind != null) {
      _remindDate = DateTime.fromMillisecondsSinceEpoch(widget.item.remind);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Row(
        children: [
          const Padding(padding: const EdgeInsets.only(left: 16)),
          const Icon(Icons.alarm),
          const Padding(padding: const EdgeInsets.only(left: 16)),
          _buildDateText(widget.item),
          _buildClearButton(widget.item),
        ],
      ),
    );
  }

  Widget _buildDateText(Todo item) {
    return Expanded(
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          child: Text("提醒: ${_remindDate?.format(_formatter)}" ?? "选择提醒时间"),
          style: TextButton.styleFrom(
            primary: Colors.black,
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          onPressed: () {
            DateTime now = DateTime.now();
            DateTime storeDateTime = _remindDate ?? now;
            TimeOfDay storeTimeOfDay = TimeOfDay(
              hour: storeDateTime.hour,
              minute: storeDateTime.minute,
            );
            showDatePicker(
                    context: context,
                    locale: Localizations.localeOf(context),
                    initialDate: storeDateTime,
                    firstDate: now,
                    lastDate: DateTime(now.year + 100))
                .then((date) {
                  _remindDate = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    storeTimeOfDay.hour,
                    storeTimeOfDay.minute,
                  );
                  item.remind = _remindDate.millisecondsSinceEpoch;
                  return item.save();
                })
                .then((int) => showTimePicker(
                      context: context,
                      initialTime: storeTimeOfDay,
                    ))
                .then((time) {
                  _remindDate = DateTime(
                    _remindDate.year,
                    _remindDate.month,
                    _remindDate.day,
                    time.hour,
                    time.minute,
                  );
                  item.remind = _remindDate.millisecondsSinceEpoch;
                  return item.save();
                })
                .then((value) {
                  setStateSafely(() {});
                })
                .catchError((e) {
                  Log.debug("待办事项提醒时间变更异常: ${e?.toString()}");
                });
          },
        ),
      ),
    );
  }

  Widget _buildClearButton(Todo item) {
    return Visibility(
      visible: _remindDate != null,
      child: IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          item.remind = null;
          item.save().then((value) {
            setStateSafely(() {
              _remindDate = null;
            });
          }).catchError((e) {
            Log.debug("待办事项提醒时间清空异常: ${e?.toString()}");
          });
        },
      ),
    );
  }
}

class TodoCreatedTime extends StatelessWidget {
  final Todo item;
  final DateFormat _formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  TodoCreatedTime({@required this.item});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Row(
        children: [
          const Padding(padding: const EdgeInsets.only(left: 16)),
          const Icon(Icons.date_range_rounded),
          const Padding(padding: const EdgeInsets.only(left: 24)),
          Text(
            "创建: ${item.createdTime?.formatDateTim()?.format(_formatter)}",
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

extension DateTimeFormat on DateTime {
  String format(DateFormat formatter) => formatter.format(this);
}

extension FromMillisecondsSinceEpoch on int {
  DateTime formatDateTim() => DateTime.fromMillisecondsSinceEpoch(this);
}
