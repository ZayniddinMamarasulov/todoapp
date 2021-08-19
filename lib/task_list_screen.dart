import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todoapp_live/add_task_screen.dart';
import 'package:todoapp_live/database_helper.dart';
import 'package:todoapp_live/task.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen();

  @override
  _TaskListSreenState createState() => _TaskListSreenState();
}

class _TaskListSreenState extends State<TaskListScreen> {
  late Future<List<Task>> _taskList;
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy, hh:mm');
  late int completedTaskCount = 0;
  late int allTaskCount = 0;
  bool orderByDate = false;
  bool filterByStatus = false;

  Widget _buildItem(Task task) {
    return Container(
      child: ListTile(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AddTaskScreen(
                      updateTaskList: _updateTaskList,
                      task: task,
                    ))),
        title: Text(task.title!,
            style: TextStyle(
                decoration: task.status == 0
                    ? TextDecoration.none
                    : TextDecoration.lineThrough)),
        subtitle: Text(_dateFormat.format(task.date),
            style: TextStyle(
                decoration: task.status == 0
                    ? TextDecoration.none
                    : TextDecoration.lineThrough)),
        trailing: Checkbox(
          value: task.status == 0 ? false : true,
          activeColor: Theme.of(context).primaryColor,
          onChanged: (bool? value) {
            if (value != null) task.status = value ? 1 : 0;
            DatabaseHelper.instance.updateTask(task);
            _updateTaskList();
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Allow notification'),
                content: Text('this app wants to show notification'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Dont Allow',
                        style: TextStyle(color: Colors.green, fontSize: 18)),
                  ),
                  TextButton(
                    onPressed: () => AwesomeNotifications()
                        .requestPermissionToSendNotifications()
                        .then((_) => Navigator.pop(context)),
                    child: Text('Allow',
                        style: TextStyle(color: Colors.green, fontSize: 18)),
                  )
                ],
              ));
    });

    AwesomeNotifications().createdStream.listen((notification) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Notification created')));
    });

    AwesomeNotifications().actionStream.listen((event) {
      AwesomeNotifications()
          .getGlobalBadgeCounter()
          .then((value) => AwesomeNotifications().setGlobalBadgeCounter(value));
    });

    _updateTaskList();
  }

  _updateTaskList() {
    setState(() {
      _taskList =
          DatabaseHelper.instance.getTaskList(orderByDate, filterByStatus);
      // completedTaskCount = _taskList
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    AddTaskScreen(updateTaskList: _updateTaskList))),
        child: Icon(Icons.add),
      ),
      body: SafeArea(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    child: Row(
                      children: [
                        Text(
                          'My tasks',
                          style: TextStyle(
                              fontSize: 40.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 10.0),
                        Text(
                          '$completedTaskCount / $allTaskCount',
                          style: TextStyle(
                              fontSize: 28.0, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Center(
                    child: Row(
                      children: [
                        Text('Order by Date'),
                        Checkbox(
                          value: orderByDate,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (bool? value) {
                            if (value != null) orderByDate = value;
                            DatabaseHelper.instance
                                .getTaskList(orderByDate, filterByStatus);
                            _updateTaskList();
                          },
                        ),
                        Text('Filter by status'),
                        Checkbox(
                          value: filterByStatus,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (bool? value) {
                            if (value != null) filterByStatus = value;
                            DatabaseHelper.instance
                                .getTaskList(orderByDate, filterByStatus);
                            _updateTaskList();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: FutureBuilder(
                      future: _taskList,
                      builder: (context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              Future.delayed(Duration.zero, () async {
                                setState(() {
                                  allTaskCount = snapshot.data.length;
                                  completedTaskCount = snapshot.data
                                      .where((Task task) => task.status == 1)
                                      .toList()
                                      .length;
                                });
                              });
                              return _buildItem(snapshot.data[index]);
                            });
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
