import 'package:flutter/material.dart';

import 'package:kanban/models/task.dart';
import 'components/task_tile.dart';
import 'package:kanban/utils/list_extension.dart';
import 'components/custom_dismissable.dart' as Custom;
import 'task_create_page.dart';
import 'package:kanban/bloc/task_bloc.dart';

class HomePageWrapper extends StatefulWidget {
  @override
  _HomePageWrapperState createState() => _HomePageWrapperState();
}

class _HomePageWrapperState extends State<HomePageWrapper> {
  @override
  void initState() {
    taskBloc.fetchAllTasks();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey globalKey;
    return StreamBuilder(
      stream: taskBloc.allTasks,
      builder: (_, AsyncSnapshot<List<Task>> snapshot) {
        if (snapshot.hasData) {
          List<Task> task = snapshot.data;
//          Map<Task, GlobalKey<Custom.CustomDismissibleState>> dismissibleKeys =
//              Map.fromEntries(task.map((task) => MapEntry(task, GlobalKey<Custom.CustomDismissibleState>(debugLabel: task.title))));

          return HomePage(
            key: globalKey,
            allTasks: task,
            //dismissibleKeys: dismissibleKeys,
          );
        } else {
          return Container();
        }
      },
    );
  }
}

enum InteractingStatus{ delete, move}

class HomePage extends StatefulWidget {
  final List<Task> allTasks;

  HomePage({this.allTasks, Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  Map<Task, GlobalKey<Custom.CustomDismissibleState>> dismissibleKeys;

  InteractingStatus interactingStatus = InteractingStatus.move;

  double todoHeight, doingHeight, doneHeight;

  AnimationController animationController;

  ///The task that is being interacted with.
  Task currentTask;

  List<Task> task, todoTask = [], doingTask = [], doneTask = [];
  double height;

  @override
  void initState() {
    super.initState();

    print("initState");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("=========add post frame callback========");
      this.task = widget.allTasks;
      todoTask = task.where((e) => e.status == TaskStatus.todo).toList();
      doingTask = task.where((e) => e.status == TaskStatus.doing).toList();
      doneTask = task.where((e) => e.status == TaskStatus.done).toList();

      for (var task in dismissibleKeys.keys) {
        var dismissibleKey = dismissibleKeys[task];
        print("map: $task");
        dismissibleKey.currentState.moveController.addListener(() {
          setState(() {
            //Delete task.
            if (dismissibleKey.currentState.dismissDirection == Custom.DismissDirection.endToStart) {
              currentTask = null;
            }
            //Moving task to next section.
            else if (dismissibleKey.currentState.dismissDirection == Custom.DismissDirection.startToEnd) {
              currentTask = task;
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

    //Newly added Task
    if (dismissibleKeys.containsKey(task.last) == false) {
      dismissibleKeys[task.last] = GlobalKey<Custom.CustomDismissibleState>();
      computeHeight();
    }

    print("===============build===============");
    print(task);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("=========add post frame callback========");
      this.task = widget.allTasks;
      todoTask = task.where((e) => e.status == TaskStatus.todo).toList();
      doingTask = task.where((e) => e.status == TaskStatus.doing).toList();
      doneTask = task.where((e) => e.status == TaskStatus.done).toList();

      for (var task in dismissibleKeys.keys) {
        var dismissibleKey = dismissibleKeys[task];
        print("map: $task");
        dismissibleKey.currentState.moveController.addListener(() {
          setState(() {
            //Delete task.
            if (dismissibleKey.currentState.dismissDirection == Custom.DismissDirection.endToStart) {
              currentTask = null;
            }
            //Moving task to next section.
            else if (dismissibleKey.currentState.dismissDirection == Custom.DismissDirection.startToEnd) {
              currentTask = task;
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
          elevation: 8,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => TaskCreatePage()));
                this.deactivate();
              },
            )
          ],
        ),
        body: AnimatedBuilder(
          animation: animationController,
          builder: (_, __) {
            double todoHeight = this.todoHeight, doingHeight = this.doingHeight, doneHeight = this.doneHeight;
            
            if (currentTask != null) {
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
            } else {
              double deletedUnit = height / (task.length - 1);
              todoHeight = todoHeight + (animationController.value + 1) * deletedUnit;
              doingHeight = doingHeight + (animationController.value + 1) * deletedUnit;
              doneHeight = doneHeight + (animationController.value + 1) * deletedUnit;
            }

            return Stack(
              children: <Widget>[
                Positioned(
                    top: doingHeight + todoHeight,
                    height: doneHeight,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                        color: Colors.blueGrey,
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
                                      child: currentTask == null || currentTask.status != TaskStatus.doing
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
                                      child: currentTask == null || currentTask.status != TaskStatus.todo
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
                    color: Colors.blueAccent,
                    child: Container(
                        color: Colors.blueAccent,
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
        ));

//    return Scaffold(
//      body: Stack(
//        children: <Widget>[
//          Positioned(
//              top: height*2,
//              height: MediaQuery.of(context).size.height,
//              width: MediaQuery.of(context).size.width,
//              child: Container(
//                height: MediaQuery.of(context).size.height,
//                color: Colors.blueGrey,
//                child: DragTarget(
//                  builder: (_, __, ____) {
//                    return Flex(
//                      direction: Axis.vertical,
//                      children: buildChildren(doneTask),
//                    );
//                  },
//                  onAccept: (Task acceptedData) {
//                    switch (acceptedData.status) {
//                      case TaskStatus.todo:
//                        todoTask.remove(acceptedData);
//                        break;
//                      case TaskStatus.doing:
//                        doingTask.remove(acceptedData);
//                        break;
//                      default:
//                        break;
//                    }
//                    setState(() {
//                      acceptedData.status = TaskStatus.done;
//                      doneTask.addIfNotExist(acceptedData);
//                    });
//                  },
//                  onWillAccept: (Task data) {
//                    return true;
//                  },
//                ),
//              )),
//          Positioned(
//              top: height+height*0.5,
//              height: height*0.5,
//              width: MediaQuery.of(context).size.width,
//              child: Material(
//                elevation: 8,
//                child: Container(
//                  height: height*2,
//                  color: Colors.redAccent,
//                  child: DragTarget(
//                    builder: (_, __, ____) {
//                      return Flex(
//                        direction: Axis.vertical,
//                        children: buildChildren(doingTask),
//                      );
//                    },
//                    onAccept: (Task acceptedData) {
//                      switch (acceptedData.status) {
//                        case TaskStatus.todo:
//                          todoTask.remove(acceptedData);
//                          break;
//                        case TaskStatus.done:
//                          doneTask.remove(acceptedData);
//                          break;
//                        default:
//                          break;
//                      }
//                      setState(() {
//                        acceptedData.status = TaskStatus.doing;
//                        doingTask.addIfNotExist(acceptedData);
//                      });
//                    },
//                    onWillAccept: (Task data) {
//                      return true;
//                    },
//                  ),
//                ),
//              )),
//          Positioned(
//            top: 0,
//            height: height+height*0.5,
//            width: MediaQuery.of(context).size.width,
//            child: Material(
//              elevation: 8,
//              color: Colors.blueAccent,
//              child: Container(
//                height: height * 1,
//                color: Colors.blueAccent,
//                child: DragTarget(
//                  builder: (_, __, ____) {
//                    return Flex(
//                      direction: Axis.vertical,
//                      children: [SizedBox(height: 28),...buildChildren(todoTask)],
//                    );
//                  },
//                  onAccept: (Task acceptedData) {
//                    switch (acceptedData.status) {
//                      case TaskStatus.done:
//                        doneTask.remove(acceptedData);
//                        break;
//                      case TaskStatus.doing:
//                        doingTask.remove(acceptedData);
//                        break;
//                      default:
//                        break;
//                    }
//                    setState(() {
//                      acceptedData.status = TaskStatus.todo;
//                      todoTask.addIfNotExist(acceptedData);
//                    });
//                  },
//                  onWillAccept: (Task data) {
//                    return true;
//                  },
//                ),
//              ),
//            ),
//          )
//        ],
//      ),
//    );
  }

//  List<Widget> buildChildren(List<Task> tasks) {
//    return tasks
//        .map((e) => Draggable(
//            data: e,
//            child: AnimatedTaskTile(task: e),
//            feedback: Transform.scale(scale: 1.2, child: TaskTile(task: e)),
//            childWhenDragging: Container()))
//        .toList();
//  }

  List<Widget> buildChildren(List<Task> tasks) {
    return tasks.map((e) {
      return Custom.CustomDismissible(
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
              taskBloc.deleteTask(e);
//              setState(() {
//                computeHeight();
//              });
            });
            return true;
          } else {
            switch (e.status) {
              case TaskStatus.todo:
                setState(() {
                  currentTask = null;

                  e.status = TaskStatus.doing;

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

                  doingTask.remove(e);
                  doneTask.add(e);

                  doingHeight -= unit;
                  doneHeight += unit;
                });
                break;
              default:
                break;
            }
          }
          //animationController.animateTo(-1);
          return false;
        },
        onDismissed: (direction) {},
        onResize: () {},
      );
    }).toList();
  }
}
