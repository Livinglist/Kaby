import 'dart:math';

import 'package:flutter/material.dart' hide Scaffold, ScaffoldState;
import 'package:flutter/cupertino.dart';
import 'package:kanban/models/project.dart';

import 'package:kanban/models/task.dart';
import 'components/task_tile.dart';
import 'package:kanban/utils/list_extension.dart';
import 'components/custom_dismissable.dart' as Custom;
import 'components/custom_drawer.dart' as CustomDrawer;
import 'task_create_page.dart';
import 'package:kanban/bloc/project_bloc.dart';
import 'components/custom_scaffold.dart';

class HomePageWrapper extends StatefulWidget {
  @override
  _HomePageWrapperState createState() => _HomePageWrapperState();
}

class _HomePageWrapperState extends State<HomePageWrapper> {
  @override
  void initState() {
    projectBloc.fetchAllProjects();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: projectBloc.currentProject,
      builder: (_, AsyncSnapshot<Project> snapshot) {
        if (snapshot.hasData) {
          return HomePage(
            key: UniqueKey(),
            project: snapshot.data,
          );
        } else {
          print("no data");
          return Container();
        }
      },
    );
  }
}

enum InteractingStatus { delete, move }

class HomePage extends StatefulWidget {
  final Project project;
  final List<Task> allTasks;

  HomePage({this.project, Key key})
      : allTasks = project.tasks,
        super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final drawerKey = GlobalKey<Custom.CustomDismissibleState>();
  final nameEditingController = TextEditingController();
  Map<Task, GlobalKey<Custom.CustomDismissibleState>> dismissibleKeys;

  InteractingStatus interactingStatus = InteractingStatus.move;

  double initialTodoHeight, todoHeight, initialDoingHeight, doingHeight, initialDoneHeight, doneHeight;

  AnimationController animationController;
  AnimationController iconAnimationController;

  ///The task that is being interacted with.
  Task currentTask;

  List<Task> task, todoTask = [], doingTask = [], doneTask = [];
  double height;

  @override
  void initState() {
    super.initState();

    print("initState");

    iconAnimationController = AnimationController(vsync: this, lowerBound: 0.0, upperBound: 1.0, duration: Duration(microseconds: 300));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scaffoldKey.currentState.drawerKey.currentState.controller.addListener(() {
        iconAnimationController.value = scaffoldKey.currentState.drawerKey.currentState.controller.value;
      });
      print("=========add post frame callback========");
      this.task = widget.allTasks;
      todoTask = task.where((e) => e.status == TaskStatus.todo).toList();
      doingTask = task.where((e) => e.status == TaskStatus.doing).toList();
      doneTask = task.where((e) => e.status == TaskStatus.done).toList();

      for (var task in dismissibleKeys.keys) {
        var dismissibleKey = dismissibleKeys[task];

        dismissibleKey.currentState.moveController.addListener(() {
          setState(() {
            //Delete task.
            if (dismissibleKey.currentState.dismissDirection == Custom.DismissDirection.endToStart) {
              currentTask = task;
              interactingStatus = InteractingStatus.delete;
            }
            //Moving task to next section.
            else if (dismissibleKey.currentState.dismissDirection == Custom.DismissDirection.startToEnd) {
              currentTask = task;
              interactingStatus = InteractingStatus.move;
            }
          });

          double val = dismissibleKey.currentState.moveController.value;

          animationController.value = -1 + val;

          if (animationController.value == 1) {
            animationController.value = -1.0;
          }
        });
      }
    });

    task = widget.allTasks;

    todoTask.addAll(task.where((e) => e.status == TaskStatus.todo));
    doingTask.addAll(task.where((e) => e.status == TaskStatus.doing));
    doneTask.addAll(task.where((e) => e.status == TaskStatus.done));

    dismissibleKeys = Map.fromEntries(task.map((task) => MapEntry(task, GlobalKey<Custom.CustomDismissibleState>(debugLabel: task.title))));

    animationController = AnimationController(vsync: this, lowerBound: -1.0, upperBound: 1.0, duration: Duration(microseconds: 300));
  }

  @override
  void dispose() {
    this.animationController.dispose();
    super.dispose();
  }

  double unit;
  void computeHeight() {
    var allTasks = [...todoTask, ...doingTask, ...doneTask];
    double todoPortion = todoTask.length / allTasks.length;
    double doingPortion = doingTask.length / allTasks.length;
    double donePortion = doneTask.length / allTasks.length;

    height = MediaQuery.of(context).size.height - AppBar().preferredSize.height;

    todoHeight = todoPortion * height;
    doingHeight = doingPortion * height;
    doneHeight = donePortion * height;

    print(todoHeight);
    print(doingHeight);
    print(doneHeight);

    unit = height / allTasks.length;
  }

  bool computed = false;

  @override
  Widget build(BuildContext context) {
    if (computed == false) {
      computeHeight();
      computed = true;
    }

    this.task = widget.allTasks;
    todoTask = task.where((e) => e.status == TaskStatus.todo).toList();
    doingTask = task.where((e) => e.status == TaskStatus.doing).toList();
    doneTask = task.where((e) => e.status == TaskStatus.done).toList();

    Color appBarColor;
    String appBarTitle;

    var temp = [...todoTask, ...doingTask, ...doneTask];

    if (temp.isNotEmpty) {
      switch (temp[0].status) {
        case TaskStatus.todo:
          appBarColor = Colors.lightBlue;
          appBarTitle = "Todo";
          break;
        case TaskStatus.doing:
          appBarColor = Colors.redAccent;
          appBarTitle = "Doing";
          break;
        case TaskStatus.done:
          appBarColor = Colors.blueAccent;
          appBarTitle = "Done";
          break;
        default:
      }
    } else {
      appBarColor = Colors.blueAccent;
      appBarTitle = "Todo";
    }

    //Newly added Task
    if (task.isNotEmpty && dismissibleKeys.containsKey(task.last) == false) {
      dismissibleKeys[task.last] = GlobalKey<Custom.CustomDismissibleState>();
      computeHeight();
    }

    print("===============build===============");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("=========add post frame callback========");
      this.task = widget.allTasks;

      todoTask = task.where((e) => e.status == TaskStatus.todo).toList();
      doingTask = task.where((e) => e.status == TaskStatus.doing).toList();
      doneTask = task.where((e) => e.status == TaskStatus.done).toList();

      for (var task in dismissibleKeys.keys) {
        var dismissibleKey = dismissibleKeys[task];

        dismissibleKey.currentState.moveController.addListener(() {
          setState(() {
            //Delete task.
            if (dismissibleKey.currentState.dismissDirection == Custom.DismissDirection.endToStart) {
              currentTask = task;
              interactingStatus = InteractingStatus.delete;
            }
            //Moving task to next section.
            else if (dismissibleKey.currentState.dismissDirection == Custom.DismissDirection.startToEnd) {
              currentTask = task;
              interactingStatus = InteractingStatus.move;
            }
          });

          double val = dismissibleKey.currentState.moveController.value;

          animationController.value = -1 + val;

          if (animationController.value == 1) {
            animationController.value = -1.0;
          }
        });
      }
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text(task.isEmpty ? "Empty" : appBarTitle),
        elevation: 8,
        leading: IconButton(
          icon: AnimatedIcon(progress: iconAnimationController.drive(Tween<double>(begin: 0.0, end: 1.0)), icon: AnimatedIcons.menu_arrow),
          onPressed: () {
            if (scaffoldKey.currentState.isDrawerOpen == false) {
              scaffoldKey.currentState.openDrawer();
            } else {
              scaffoldKey.currentState.closeDrawer();
            }
          },
        ),
        actions: <Widget>[
          //If there is no task, show the bottom on the center of the screen.
          if (task.isNotEmpty)
            AnimatedBuilder(
              animation: iconAnimationController,
              builder: (_, __) {
                return Opacity(
                  opacity: iconAnimationController.drive(Tween<double>(begin: 1.0, end: 0.0)).value,
                  child: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => TaskCreatePage()));
                      this.deactivate();
                    },
                  ),
                );
              },
            )
        ],
      ),
      body: Scaffold(
          key: scaffoldKey,
          drawer: Container(
            color: Colors.white,
            child: Drawer(
                elevation: 0,
                child: SingleChildScrollView(
                    child: StreamBuilder(
                  stream: projectBloc.allProjects,
                  builder: (_, AsyncSnapshot<List<Project>> snapshot) {
                    return Flex(
                      direction: Axis.vertical,
                      children: <Widget>[
                        ListTile(
                          title: Text("My Kanban"),
                          onTap: () {
                            projectBloc.getKanban();
                            //Navigator.pop(context);
                          },
                        ),
                        Container(
                            child: Flex(
                          direction: Axis.horizontal,
                          children: <Widget>[
                            Flexible(
                              child: Divider(),
                              flex: 1,
                            ),
                            Flexible(
                              child: ListTile(
                                  title: Text(
                                "Projects",
                                textAlign: TextAlign.center,
                              )),
                              flex: 1,
                            ),
                            Flexible(
                              child: Divider(),
                              flex: 1,
                            )
                          ],
                        )),
                        if (snapshot.hasData)
                          for (var p in snapshot.data)
                            Container(
                              color: widget.project.id == p.id ? appBarColor : Colors.transparent,
                              child: ListTile(
                                title: Text(p.name),
                                onTap: () {
                                  projectBloc.getProjectById(p.uid);
                                  //Navigator.pop(context);
                                },
                                onLongPress: () => onProjectListTileLongPressed(p),
                              ),
                            ),
                        Container(
                          color: Colors.transparent,
                          child: ListTile(
                              title: Icon(Icons.add),
                              onTap: () {
                                showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return CupertinoAlertDialog(
                                      title: Text('Name Your Project'),
                                      content: Flex(
                                        direction: Axis.vertical,
                                        children: <Widget>[
                                          CupertinoTextField(
                                            controller: nameEditingController,
                                          )
                                        ],
                                      ),
                                      actions: <Widget>[
                                        CupertinoActionSheetAction(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text("Cancel")),
                                        CupertinoActionSheetAction(
                                            onPressed: () {
                                              var name = nameEditingController.text;
                                              if (name.isNotEmpty) {
                                                projectBloc.createProject(name);
                                                Navigator.pop(context);
                                              }
                                            },
                                            child: Text("Confirm"),
                                            isDefaultAction: true),
                                      ],
                                    );
                                  },
                                );
                              }),
                        )
                      ],
                    );
                  },
                ))),
          ),
          body: AnimatedBuilder(
            animation: animationController,
            builder: (_, __) {
              double todoHeight = this.todoHeight, doingHeight = this.doingHeight, doneHeight = this.doneHeight;

              if (currentTask != null) {
                if (interactingStatus == InteractingStatus.move) {
                  switch (currentTask.status) {
                    case TaskStatus.todo:
                      todoHeight = todoHeight + (animationController.value + 1) * -unit;
                      doingHeight = doingHeight + (animationController.value + 1) * unit;
                      break;
                    case TaskStatus.doing:
                      doingHeight = doingHeight + (animationController.value + 1) * -unit;
                      doneHeight = doneHeight + (animationController.value + 1) * unit;
                      break;
                    default:
                      break;
                  }
                } else if (interactingStatus == InteractingStatus.delete) {
                  double initialTodoHeight = (todoTask.length / task.length) * height;
                  double initialDoingHeight = (doingTask.length / task.length) * height;
                  double initialDoneHeight = (doneTask.length / task.length) * height;

                  switch (currentTask.status) {
                    case TaskStatus.todo:
                      double deltaX = height * (todoTask.length - 1) / (task.length - 1) - initialTodoHeight;
                      double deltaY = height * (doingTask.length) / (task.length - 1) - initialDoingHeight;
                      double deltaZ = height * (doneTask.length) / (task.length - 1) - initialDoneHeight;

                      print(initialTodoHeight);
                      print(deltaX);

                      print(initialDoingHeight);
                      print(deltaY);

                      print(initialDoneHeight);
                      print(deltaZ);

                      todoHeight = initialTodoHeight + (animationController.value + 1) * deltaX;
                      doingHeight = initialDoingHeight + (animationController.value + 1) * deltaY;
                      doneHeight = initialDoneHeight + (animationController.value + 1) * deltaZ;

                      print(todoHeight);
                      print(doingHeight);
                      print(doneHeight);
                      break;
                    default:
                      break;
                  }
                }
              }

              if (task.isEmpty) {
                return Stack(
                  children: <Widget>[
                    Positioned(
                        top: 0,
                        height: height,
                        width: MediaQuery.of(context).size.width,
                        child: Material(
                          color: Colors.blueAccent,
                          child: Ink(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => TaskCreatePage()));
                              },
                              child: Center(
                                  child: Transform.scale(
                                scale: 5,
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                              )),
                            ),
                          ),
                        ))
                  ],
                );
              }

              return Stack(
                children: <Widget>[
                  Positioned(
                      top: doingHeight + todoHeight,
                      height: doneHeight,
                      width: MediaQuery.of(context).size.width,
                      child: Container(
                          color: Colors.blueAccent,
                          child: SingleChildScrollView(
                            key: UniqueKey(),
                            child: Flex(
                              key: UniqueKey(),
                              direction: Axis.vertical,
                              children: [
                                ...buildChildren(doneTask),
                                AnimatedBuilder(
                                  animation: animationController,
                                  builder: (_, __) {
                                    return Transform.translate(
                                        offset: Offset(animationController.value * MediaQuery.of(context).size.width, 0),
                                        child: currentTask == null ||
                                                currentTask.status != TaskStatus.doing ||
                                                interactingStatus == InteractingStatus.delete
                                            ? Container()
                                            : Container(
                                                color: Colors.white,
                                                child: ListTile(
                                                  title: Text(currentTask.title),
                                                ),
                                              ));
                                  },
                                )
                              ],
                            ),
                          ))),
                  //Doing section.
                  Positioned(
                      top: todoHeight,
                      height: doingHeight,
                      //height: doingHeight + animationController.value * -48,
                      width: MediaQuery.of(context).size.width,
                      child: Material(
                          elevation: 8,
                          child: Container(
                              //height: animationController.value * -20,
                              color: Colors.redAccent,
                              child: SingleChildScrollView(
                                child: Flex(
                                  key: UniqueKey(),
                                  direction: Axis.vertical,
                                  children: [
                                    ...buildChildren(doingTask),
                                    Transform.translate(
                                        offset: Offset(animationController.value * MediaQuery.of(context).size.width, 0),
                                        child: currentTask == null ||
                                                currentTask.status != TaskStatus.todo ||
                                                interactingStatus == InteractingStatus.delete
                                            ? Container()
                                            : Container(
                                                color: Colors.white,
                                                child: ListTile(
                                                  title: Text(currentTask.title),
                                                ),
                                              ))
                                  ],
                                ),
                              )))),
                  //Todo section
                  Positioned(
                    top: 0,
                    height: todoHeight,
                    width: MediaQuery.of(context).size.width,
                    child: Material(
                      elevation: 8,
                      color: Colors.lightBlue,
                      child: Container(
                          color: Colors.lightBlue,
                          child: SingleChildScrollView(
                            child: Flex(
                              key: UniqueKey(),
                              direction: Axis.vertical,
                              children: <Widget>[...buildChildren(todoTask)],
                            ),
                          )),
                    ),
                  )
                ],
              );
            },
          )),
    );
  }

  List<Widget> buildChildren(List<Task> tasks) {
    print(tasks);
    return tasks.map((e) {
      return Custom.CustomDismissible(
        direction: Custom.DismissDirection.horizontal,
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20.0),
          color: Colors.red,
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        key: dismissibleKeys[e],
        child: Container(
          color: Colors.white70,
          child: ListTile(
            title: Text(e.title),
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  builder: (_) {
                    return Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Text(e.description ?? "No details"),
                      ),
                    );
                  });
            },
          ),
        ),
        confirmDismiss: (direction) async {
          if (direction == Custom.DismissDirection.endToStart) {
            setState(() {
              currentTask = null;
              dismissibleKeys.remove(e);

              switch (e.status) {
                case TaskStatus.todo:
                  todoTask.remove(e);
                  break;
                case TaskStatus.doing:
                  doingTask.remove(e);
                  break;
                case TaskStatus.done:
                  doneTask.remove(e);
                  break;
                default:
                  break;
              }
              computeHeight();
              projectBloc.removeTask(e);
            });
            return true;
          } else {
            switch (e.status) {
              case TaskStatus.todo:
                setState(() {
                  currentTask = null;

                  e.status = TaskStatus.doing;

                  projectBloc.updateCurrent();

                  task.remove(e);
                  task.add(e);

                  todoTask.remove(e);
                  doingTask.add(e);

                  todoHeight -= unit;
                  doingHeight += unit;
                });
                break;
              case TaskStatus.doing:
                setState(() {
                  currentTask = null;

                  e.status = TaskStatus.done;

                  projectBloc.updateCurrent();

                  task.remove(e);
                  task.add(e);

                  doingTask.remove(e);
                  doneTask.add(e);

                  doingHeight -= unit;
                  doneHeight += unit;
                });
                break;
              case TaskStatus.done:
                showSnackBar("This is already done!");
                break;
              default:
                break;
            }
          }
          return false;
        },
        onDismissed: (direction) {},
        onResize: () {},
      );
    }).toList();
  }

  void onProjectListTileLongPressed(Project p) => showCupertinoModalPopup<bool>(
          context: context,
          builder: (BuildContext context) => CupertinoActionSheet(
                message: Text("Are you sure?"),
                cancelButton: CupertinoActionSheetAction(
                  isDefaultAction: true,
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                ),
                actions: <Widget>[
                  CupertinoActionSheetAction(
                    isDestructiveAction: true,
                    child: Text('Remove ${p.name}'),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                  ),
                ],
              )).then((value) {
        if (value) {
          projectBloc.deleteProject(p);
        }
      });

  void showSnackBar(String msg) {
    assert(msg != null);
    scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(msg),
        action: SnackBarAction(
            label: "Dismiss",
            onPressed: () {
              scaffoldKey.currentState.hideCurrentSnackBar();
            })));
  }
}
