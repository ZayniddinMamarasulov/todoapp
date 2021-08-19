import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todoapp_live/database_helper.dart';
import 'package:todoapp_live/notifications.dart';
import 'package:todoapp_live/task.dart';

class AddTaskScreen extends StatefulWidget {
  final Function? updateTaskList;
  final Task? task;

  const AddTaskScreen({this.updateTaskList, this.task});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _title = '';
  String? _priority;
  String? _hour, _minute, _time;
  DateTime _date = DateTime.now();
  DateTime _dateWithTime = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay(hour: 00, minute: 00);
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  final DateFormat _timeFormat = DateFormat('hh:mm');
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  _handleDatePicker() async {
    final date = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2020),
        lastDate: DateTime(2050));

    if (date != _date) {
      setState(() {
        _date = date as DateTime;
      });
      _dateController.text = _dateFormat.format(date!);
    }
  }

  _handleTimePicker() async {
    final timePicked =
        await showTimePicker(context: context, initialTime: _selectedTime);

    if (timePicked != null) {
      setState(() {
        _selectedTime = timePicked;
        _hour = _selectedTime.hour.toString();
        _minute = _selectedTime.minute.toString();
        _time = _hour! + " : " + _minute!;
        _dateWithTime = DateTime(_date.year, _date.month, _date.day,
            _selectedTime.hour, _selectedTime.minute);
        _timeController.text = _timeFormat.format(_dateWithTime);
      });
    }
  }

  _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Task task = Task(title: _title, date: _dateWithTime, priority: _priority);

      createReminderNotification(task);

      if (widget.task == null) {
        // insert database
        task.status = 0;
        DatabaseHelper.instance.insertTask(task);
      } else {
        // update database logic
        task.id = widget.task!.id;
        task.status = widget.task!.status;
        task.title = _title;
        task.date = _dateWithTime;
        task.priority = _priority;
        DatabaseHelper.instance.updateTask(task);
      }

      if (widget.updateTaskList != null) widget.updateTaskList!();
      Navigator.pop(context);
    }
  }

  _delete() {
    DatabaseHelper.instance.deleteTask(widget.task!.id);
    widget.updateTaskList!();
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _title = widget.task!.title;
      _date = widget.task!.date;
      _priority = widget.task!.priority;
      _dateWithTime = widget.task!.date;
    }

    _dateController.text = _dateFormat.format(_date);
    _timeController.text = _timeFormat.format(_dateWithTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            child: Column(
              children: [
                Text(
                  widget.task == null ? 'Create task' : 'Update task',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Title'),
                        onSaved: (input) => _title = input,
                        validator: (input) => input!.trim().isEmpty
                            ? 'Please, enter task title'
                            : null,
                        initialValue: _title,
                      ),
                      TextFormField(
                        readOnly: true,
                        controller: _dateController,
                        onTap: _handleDatePicker,
                        decoration: InputDecoration(
                            labelText: 'Date',
                            labelStyle: TextStyle(color: Colors.black)),
                      ),
                      TextFormField(
                        readOnly: true,
                        controller: _timeController,
                        onTap: _handleTimePicker,
                        decoration: InputDecoration(
                            labelText: 'Time',
                            labelStyle: TextStyle(color: Colors.black)),
                      ),
                      DropdownButtonFormField(
                          icon: Icon(Icons.arrow_drop_down),
                          decoration: InputDecoration(labelText: 'Priority'),
                          onChanged: (value) {
                            setState(() {
                              _priority = value! as String;
                            });
                          },
                          items: _priorities.map((priority) {
                            return DropdownMenuItem<String>(
                              value: priority,
                              child: Text(
                                priority,
                                style: TextStyle(color: Colors.black),
                              ),
                            );
                          }).toList(),
                          value: _priority,
                          validator: (input) => _priority == null
                              ? 'Please, select priority level'
                              : null),
                    ],
                  ),
                ),
                TextButton(onPressed: _submit, child: Text('Save')),
                TextButton(onPressed: _delete, child: Text('Delete')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
