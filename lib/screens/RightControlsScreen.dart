import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../module/volume.dart';

class RightControlsScreen extends StatefulWidget {
  final VideoPlayerController? videoController;
  final Volume volume;
  const RightControlsScreen({super.key, this.videoController, required this.volume});

  @override
  State<RightControlsScreen> createState() => _RightControlsScreenState();
}

class _RightControlsScreenState extends State<RightControlsScreen> with SingleTickerProviderStateMixin {
  double _playbacktime = 0;
  int _lastpositionvolume = 0, volumecontroller = 0;
  bool islocked = false;

  late Animation<Offset> _animation;
  late final AnimationController _animationController;
  Timer? _timer;

  volumeAnimationDebounce() {
    print("bounce");
    _animationController.reverse();
  }

  @override
  void initState() {
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _animation = Tween(begin: const Offset(1, 0), end: Offset.zero).animate(_animationController);
    widget.volume.volumecontroller.listener((_) => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, size) {
      print(size);
      return Stack(
        children: [
          SlideTransition(
            position: _animation,
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(border: Border.all(color: Colors.green)),
                    // color: Colors.yellow,
                    width: size.maxWidth / 3,
                    height: 150,
                    child: Column(
                      children: [
                        volumecontroller != 15
                            ? Expanded(
                                flex: 15 - volumecontroller,
                                child: Container(
                                  height: 10,
                                  color: Colors.red,
                                ))
                            : Container(),
                        volumecontroller != 0
                            ? Expanded(
                                flex: volumecontroller,
                                child: Container(
                                  height: 10,
                                  color: Colors.green,
                                ))
                            : Container(),
                      ],
                    )),
              ),
            ),
          ),
          GestureDetector(
            onVerticalDragUpdate: (update) {
              int diff = (_lastpositionvolume - update.localPosition.dy.floor());
              if (diff.abs() > size.maxHeight / 50) {
                _lastpositionvolume = update.localPosition.dy.floor();
                if (diff.isNegative) {
                  volumecontroller -= 1;
                  if (volumecontroller < 0) {
                    volumecontroller = 0;
                  }
                } else {
                  volumecontroller += 1;
                  if (volumecontroller > 15) {
                    volumecontroller = 15;
                  }
                }
                setState(() {
                  print(_animationController.status);
                  if (!_animationController.isCompleted) {
                    _animationController.forward();
                  }
                  if (_timer != null && _timer!.isActive) {
                    _timer!.cancel();
                  }
                  _timer = Timer(const Duration(seconds: 2), volumeAnimationDebounce);
                  widget.volume.updateVolumeFromInternal(volumecontroller);
                });
              }
            },
            onDoubleTap: () {
              setState(() {
                _playbacktime = _playbacktime - 10;
                widget.videoController!.seekTo(Duration(seconds: _playbacktime.toInt() - 10));
              });
            },
          ),
        ],
      );
    });
  }
}
