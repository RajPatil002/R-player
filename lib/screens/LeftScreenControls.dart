import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:r_player/module/brightness.dart';

import '../module/volume.dart';

class LeftScreenControls extends StatefulWidget {
  final VideoPlayerController? videoController;
  final Brightness brightness;
  const LeftScreenControls({super.key, this.videoController, required this.brightness});

  @override
  State<LeftScreenControls> createState() => _LeftScreenControlsState();
}

class _LeftScreenControlsState extends State<LeftScreenControls> with SingleTickerProviderStateMixin {
  double _playbacktime = 0;
  int _lastdragposition = 0, brightnesslevel = 0;
  bool islocked = false;

  late Animation<Offset> _animation;
  late final AnimationController _animationController;
  Timer? _timer;

  void brightnessAnimationDebounce() {
    _animationController.reverse();
  }

  @override
  void initState() {
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _animation = Tween(begin: const Offset(-1, 0), end: Offset.zero).animate(_animationController);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, size) {
      return Stack(
        children: [
          SlideTransition(
            position: _animation,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(border: Border.all(color: Colors.white)),
                    width: 30,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: (size.maxHeight / 100) * (15 - brightnesslevel),
                          color: Colors.red,
                        ),
                        Container(
                          height: (size.maxHeight / 100) * brightnesslevel,
                          color: Colors.blue,
                        ),
                      ],
                    )),
              ),
            ),
          ),
          GestureDetector(
            onVerticalDragUpdate: (update) {
              int newposition = update.localPosition.dy.floor();
              int diff = (_lastdragposition - newposition);
              if (diff.abs() > size.maxHeight / 50) {
                _lastdragposition = newposition;
                if (diff.abs() < size.maxHeight / 40) {
                  if (diff.isNegative) {
                    if (brightnesslevel > 0) {
                      brightnesslevel -= 1;
                    }
                  } else {
                    if (brightnesslevel < 15) {
                      brightnesslevel += 1;
                    }
                  }
                }
                setState(() {
                  if (!_animationController.isCompleted) {
                    _animationController.forward();
                  }
                  if (_timer != null && _timer!.isActive) {
                    _timer!.cancel();
                  }
                  _timer = Timer(const Duration(seconds: 2), brightnessAnimationDebounce);
                });
              }
            },
            onDoubleTap: () {
              setState(() {
                _playbacktime = _playbacktime - 10;
                widget.videoController!.seekTo(Duration(seconds: _playbacktime.toInt()));
              });
            },
          ),
        ],
      );
    });
  }
}
