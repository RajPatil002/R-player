import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../module/volume.dart';

class RightScreenControls extends StatefulWidget {
  final VideoPlayerController? videoController;
  final Volume volume;
  const RightScreenControls({super.key, this.videoController, required this.volume});

  @override
  State<RightScreenControls> createState() => _RightScreenControlsState();
}

class _RightScreenControlsState extends State<RightScreenControls> with SingleTickerProviderStateMixin {
  double _playbacktime = 0;
  int _lastdragposition = 0, volumelevel = 0;

  late Animation<Offset> _animation;
  late final AnimationController _animationController;
  Timer? _timer;

  void volumeAnimationDebounce() {
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
      return Stack(
        children: [
          SlideTransition(
            position: _animation,
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(border: Border.all(color: Colors.green)),
                    width: 30,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: (size.maxHeight / 100) * (15 - volumelevel),
                          color: Colors.red,
                        ),
                        Container(
                          height: (size.maxHeight / 100) * volumelevel,
                          color: Colors.green,
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
                    if (volumelevel > 0) {
                      volumelevel -= 1;
                    }
                  } else {
                    if (volumelevel < 15) {
                      volumelevel += 1;
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
                  _timer = Timer(const Duration(seconds: 2), volumeAnimationDebounce);
                  widget.volume.updateVolumeFromInternal(volumelevel);
                });
              }
            },
            onDoubleTap: () {
              setState(() {
                _playbacktime = _playbacktime + 10;
                widget.videoController!.seekTo(Duration(seconds: _playbacktime.toInt()));
              });
            },
          ),
        ],
      );
    });
  }
}
