import 'dart:math';

import 'package:flutter/material.dart' hide Scaffold, ScaffoldState;
import 'package:flutter/cupertino.dart';
import 'package:app_review/app_review.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kanban/bloc/task_bloc.dart';

import 'package:kanban/models/project.dart';
import 'package:kanban/models/task.dart';
import 'components/task_tile.dart';
import 'package:kanban/utils/list_extension.dart';
import 'components/custom_dismissable.dart' as Custom;
import 'components/custom_drawer.dart' as CustomDrawer;
import 'task_create_page.dart';
import 'package:kanban/bloc/project_bloc.dart';
import 'components/custom_scaffold.dart';
import 'package:kanban/utils/datetime_extension.dart';
import 'icon_page.dart';

class HomePageWrapper extends StatefulWidget {
  @override
  _HomePageWrapperState createState() => _HomePageWrapperState();
}

class _HomePageWrapperState extends State<HomePageWrapper> {
  @override
  void initState() {
    projectBloc.fetchAllProjects();

    super.initState();

    if (Random(DateTime.now().millisecondsSinceEpoch).nextBool()) {
      AppReview.isRequestReviewAvailable.then((isAvailable) {
        if (isAvailable) {
          AppReview.requestReview;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: projectBloc.currentProject,
      builder: (_, AsyncSnapshot<Project> snapshot) {
        if (snapshot.hasData) {
          return StreamBuilder(
            stream: projectBloc.isKanban,
            builder: (_, AsyncSnapshot<bool> isKanbanSnapshot) {
              return HomePage(
                key: UniqueKey(),
                project: snapshot.data,
                isKanban: isKanbanSnapshot.data ?? true,
              );
            },
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
  final bool isKanban;

  HomePage({this.project, this.isKanban, Key key})
      : allTasks = project.tasks,
        super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
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
      scaffoldKey.currentState?.drawerKey?.currentState?.controller?.addListener(() {
        iconAnimationController.value = scaffoldKey.currentState.drawerKey?.currentState?.controller?.value ?? 0;
      });

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
    print("disposed");
    this.animationController.dispose();
    this.iconAnimationController.dispose();
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
      appBarColor = Colors.lightBlue;
      appBarTitle = "Empty";
    }

    //Newly added Task
    if (task.isNotEmpty && dismissibleKeys.containsKey(task.last) == false) {
      dismissibleKeys[task.last] = GlobalKey<Custom.CustomDismissibleState>();
      computeHeight();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      this.task = widget.allTasks;

      todoTask = task.where((e) => e.status == TaskStatus.todo).toList();
      doingTask = task.where((e) => e.status == TaskStatus.doing).toList();
      doneTask = task.where((e) => e.status == TaskStatus.done).toList();

      for (var task in dismissibleKeys.keys) {
        var dismissibleKey = dismissibleKeys[task];

        dismissibleKey.currentState?.moveController?.addListener(() {
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: appBarColor,
        title: Column(
          children: <Widget>[
            Text(widget.project.name, maxLines: 1),
            Text(appBarTitle, style: TextStyle(fontSize: 8)),
          ],
        ),
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
          AnimatedBuilder(
            animation: iconAnimationController,
            builder: (_, __) {
              return Opacity(
                  opacity: iconAnimationController.drive(Tween<double>(begin: 1.0, end: 0.0)).value,
                  child: IconButton(
                    icon: Icon(Icons.delete_sweep),
                    onPressed: () => showRemoveAllDialog(),
                  ));
            },
          ),
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
                      if (iconAnimationController.drive(Tween<double>(begin: 1.0, end: 0.0)).value != 0)
                        Navigator.push(context, MaterialPageRoute(builder: (_) => TaskCreatePage()));
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
                        Container(
                          color: widget.isKanban ? appBarColor : Colors.transparent,
                          child: ListTile(
                            leading: Icon(FontAwesomeIcons.gameBoardAlt, color: widget.isKanban ? Colors.white : Colors.black54),
                            title: Text(
                              "My Kanban",
                              style: TextStyle(color: widget.isKanban ? Colors.white : Colors.black),
                            ),
                            onTap: () {
                              scaffoldKey.currentState.closeDrawer();
                              projectBloc.getKanban();
                              //Navigator.pop(context);
                            },
                          ),
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
                                style: TextStyle(color: Colors.black),
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
                              color: (widget.project.id == p.id && widget.isKanban == false) ? appBarColor : Colors.transparent,
                              child: ListTile(
                                leading: Icon(
                                  FontAwesomeIconsMap[p.icon],
                                  color: (widget.project.id == p.id && widget.isKanban == false) ? Colors.white : Colors.black54,
                                ),
                                title: Text(
                                  p.name,
                                  style: TextStyle(
                                    color: (widget.project.id == p.id && widget.isKanban == false) ? Colors.white : Colors.black,
                                  ),
                                ),
                                subtitle:
                                    Text("${p.tasks.where((t) => t.isDone).toList().length}/${p.tasks.length}"),
                                onTap: () {
                                  scaffoldKey.currentState.closeDrawer();
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
                                          SizedBox(height: 12),
                                          CupertinoTextField(
                                            style: Theme.of(context).textTheme.body1,
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
                                                nameEditingController.clear();
                                                scaffoldKey.currentState.closeDrawer();
                                                Navigator.pop(context);
                                                String uid = projectBloc.createProject(name);
                                                projectBloc.getProjectById(uid);
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
                  if (task.length == 1) {
                  } else {
                    double initialTodoHeight = (todoTask.length / task.length) * height;
                    double initialDoingHeight = (doingTask.length / task.length) * height;
                    double initialDoneHeight = (doneTask.length / task.length) * height;
                    double deltaX, deltaY, deltaZ;

                    switch (currentTask.status) {
                      case TaskStatus.todo:
                        deltaX = height * (todoTask.length - 1) / (task.length - 1) - initialTodoHeight;
                        deltaY = height * (doingTask.length) / (task.length - 1) - initialDoingHeight;
                        deltaZ = height * (doneTask.length) / (task.length - 1) - initialDoneHeight;
                        break;
                      case TaskStatus.doing:
                        deltaX = height * (todoTask.length) / (task.length - 1) - initialTodoHeight;
                        deltaY = height * (doingTask.length - 1) / (task.length - 1) - initialDoingHeight;
                        deltaZ = height * (doneTask.length) / (task.length - 1) - initialDoneHeight;
                        break;
                      case TaskStatus.done:
                        deltaX = height * (todoTask.length) / (task.length - 1) - initialTodoHeight;
                        deltaY = height * (doingTask.length) / (task.length - 1) - initialDoingHeight;
                        deltaZ = height * (doneTask.length - 1) / (task.length - 1) - initialDoneHeight;
                        break;
                      default:
                        break;
                    }

                    todoHeight = initialTodoHeight + (animationController.value + 1) * deltaX;
                    doingHeight = initialDoingHeight + (animationController.value + 1) * deltaY;
                    doneHeight = initialDoneHeight + (animationController.value + 1) * deltaZ;
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
                          color: Colors.lightBlue,
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
                                Transform.translate(
                                    offset: Offset(animationController.value * MediaQuery.of(context).size.width, 0),
                                    child:
                                        currentTask == null || currentTask.status != TaskStatus.doing || interactingStatus == InteractingStatus.delete
                                            ? Container()
                                            : Container(
                                                color: Colors.white,
                                                child: ListTile(
                                                  title: Text(currentTask.title),
                                                ),
                                              ))
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
                  isScrollControlled: true,
                  context: context,
                  builder: (_) {
                    if (e.description == null || e.description.isEmpty) {
                      return Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  e.title,
                                  style: TextStyle(fontSize: 20, color: Colors.black),
                                ),
                                Spacer(),
                                Text(e.dueDate == null ? "" : "Due by ${e.dueDate.toLocal().toCustomString()}",
                                    style: TextStyle(color: Colors.black54)),
                                Divider(),
                                Text(e.createdDate == null ? "" : "Created on ${e.createdDate.toLocal().toCustomString()}",
                                    style: TextStyle(color: Colors.black54)),
                                SizedBox(height: 12)
                              ],
                            ),
                          ));
                    }

                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                        color: Colors.white,
                      ),
                      child: DraggableScrollableSheet(
                        expand: false,
                        maxChildSize: 0.9,
                        builder: (_, scrollController) {
                          return SingleChildScrollView(
                              //physics: NeverScrollableScrollPhysics(),
                              controller: scrollController,
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      e.title,
                                      style: TextStyle(fontSize: 20, color: Colors.black),
                                    ),
                                    Divider(),
                                    Flexible(
                                      child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        child: Text(
                                          e.description ?? "",
                                          style: TextStyle(fontSize: 16, color: Colors.black),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    if (e.dueDate != null) Divider(),
                                    Text(e.dueDate == null ? "" : "Due by ${e.dueDate.toLocal().toCustomString()}",
                                        style: TextStyle(color: Colors.black54)),
                                    Divider(),
                                    Text(e.createdDate == null ? "" : "Created on ${e.createdDate.toLocal().toCustomString()}",
                                        style: TextStyle(color: Colors.black54))
                                  ],
                                ),
                              ));
                        },
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
            cancelButton: CupertinoActionSheetAction(
              isDefaultAction: true,
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            actions: <Widget>[
              CupertinoActionSheetAction(
                isDestructiveAction: false,
                child: Text('Edit Name'),
                onPressed: () {
                  Navigator.pop(context);
                  showDialog<bool>(
                    context: context,
                    builder: (context) {
                      nameEditingController.text = p.name;
                      return CupertinoAlertDialog(
                        content: Flex(
                          direction: Axis.vertical,
                          children: <Widget>[
                            SizedBox(height: 12),
                            CupertinoTextField(
                              style: Theme.of(context).textTheme.body1,
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
                                  nameEditingController.clear();
                                  scaffoldKey.currentState.closeDrawer();
                                  Navigator.pop(context);
                                  p.name = name;
                                  print(p.name);
                                  projectBloc.updateProject(p);
                                }
                              },
                              child: Text("Confirm"),
                              isDefaultAction: true),
                        ],
                      );
                    },
                  );
                },
              ),
              CupertinoActionSheetAction(
                child: Text('Change Icon'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => IconPage(project: p)));
                },
              ),
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                child: Text('Remove ${p.name}'),
                onPressed: () {
                  Navigator.pop(context);
                  onRemoveTapped(p);
                },
              ),
            ],
          ));

  void onRemoveTapped(Project p) => showCupertinoModalPopup<bool>(
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
                      scaffoldKey.currentState.closeDrawer();
                      Navigator.pop(context, true);
                    },
                  ),
                ],
              )).then((value) {
        if (value != null && value) {
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

  void showRemoveAllDialog() => showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return CupertinoActionSheet(
          message: Text("Remove all tasks"),
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            child: Text('Cancel'),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
          actions: <Widget>[
            CupertinoActionSheetAction(
                onPressed: () {
                  projectBloc.removeAllTasks();
                  Navigator.pop(context);
                },
                child: Text("Confirm"),
                isDestructiveAction: true),
          ],
        );
      });
}
