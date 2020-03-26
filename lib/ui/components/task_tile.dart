import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'dart:math';

import 'package:kanban/models/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;

  TaskTile({this.task}) : assert(task != null);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(12),
        child: Material(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          elevation: 8,
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Flex(
              direction: Axis.vertical,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(task.title, style: TextStyle(color: Colors.black87, fontSize: 16)),
                )
                //Text(task.createdDate.toLocal().toString())
              ],
            ),
            decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.all(Radius.circular(8))),
          ),
        ));
  }
}

class AnimatedTaskTile extends StatefulWidget {
  final Task task;

  AnimatedTaskTile({this.task});

  @override
  _AnimatedTaskTileState createState() => _AnimatedTaskTileState();
}

class _AnimatedTaskTileState extends State<AnimatedTaskTile> with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> curvedAnimation;
  Tween<double> sizeScaleTween = Tween<double>(begin: 1.0, end: 1.5)..chain(Tween<double>(begin: 0.5, end: 1.4));

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, lowerBound: 0.0, upperBound: 1.0, duration: Duration(seconds: 2));
      //..animateWith(SpringSimulation(SpringDescription(mass: 30.0, stiffness: 1.0, damping: 1.0), 0, 1, -4000.0));

    sizeScaleTween.animate(controller);

    curvedAnimation = CurvedAnimation(
      parent: controller,
      curve: Springy(),
      reverseCurve: Springy(),
    );

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Transform.scale(
          scale: curvedAnimation.value,
          child: TaskTile(task: widget.task),
        );
      },
    );
  }
}

class Springy extends Curve {
  @override
  double transform(double x) {
    return -(pow(e, (-x / 0.15)) * cos(19.4 * x)) + 1;
  }
}
