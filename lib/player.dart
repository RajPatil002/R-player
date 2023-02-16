import 'dart:developer';
import 'dart:io' as io;
import 'package:file/memory.dart';
import 'package:file/file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:volume_controller/volume_controller.dart';

class Player extends StatefulWidget {
  const Player({Key? key}) : super(key: key);

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  late VideoPlayerController _controller;
  double _playbacktime = 0, _volumecontroller = 0;


  @override
  void initState() {
    super.initState();
    // SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight,DeviceOrientation.landscapeLeft,]);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      FileSystem fs = MemoryFileSystem(style: FileSystemStyle.posix);
      // log((await io.File("storage/emulated/0/download/govinda.mkv").exists()).toString());
      _volumecontroller = await VolumeController().getVolume();
      File video = fs.file(fs.path.absolute("storage/emulated/0/download/govinda.mkv"));
      _controller = VideoPlayerController.file(video)
        ..setVolume(_volumecontroller)
        ..addListener(() {
          setState(() {
            // _playbacktime = _controller.value.position.inSeconds.toDouble();
          });
        })
        ..initialize().then((_) async {
          log(_controller.value.duration.toString());
          // await _controller.play();
          setState(() {});
        });
      // log("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa$_volumecontroller");
    });
    VolumeController().listener((vol) async {
      await _controller.setVolume(vol);
      _volumecontroller = vol;
      // setState(() {});
      // log("wwwwwwwwwwwwwwwwwww${_controller.value.volume}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _controller.value.isPlaying ? _controller.pause() : _controller.play();
            });
          },
          child: Icon(_controller.value.isPlaying ? (Icons.pause) : (Icons.play_arrow)),
        ),
        body: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller)),
                // IconButton(onPressed: ()async{
                //   VolumeController().muteVolume();
                //   await _controller.setVolume(0.0);
                //   setState(() {
                //
                //   });
                // }, icon: Icon(Icons.volume_mute))
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    child: Container(
                      color: Colors.red,
                    ),
                    onVerticalDragUpdate:(update) {
                      log("${update.delta.dx}         ${update.delta.dy}");
                      if (update.delta.dy.isNegative) {
                        if ((_volumecontroller - (update.delta.dy.toDouble() / 100)) <= 1) {
                          _volumecontroller -= (update.delta.dy.toDouble() / 100);
                        } else {
                          _volumecontroller = 1;
                        }
                      } else {
                        if ((_volumecontroller - (update.delta.dy.toDouble() / 100)) >= 0) {
                          _volumecontroller -= (update.delta.dy.toDouble() / 100);
                        } else {
                          _volumecontroller = 0;
                        }
                      }
                      setState(() {
                        VolumeController().setVolume(_volumecontroller, showSystemUI: true);
                      });
                      log("$_volumecontroller");
                    },
                    onDoubleTap: () {
                      setState(() {
                        _playbacktime = _playbacktime - 10;
                        _controller.seekTo(Duration(seconds: _playbacktime.toInt() - 10));
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    child: Container(
                      // color: Colors.green,
                    ),
                    onHorizontalDragUpdate: (update) {
                      log((update.delta.dx / 10).toString());
                      setState(() {
                        _playbacktime = _playbacktime + (update.delta.dx / 10);
                        _controller.seekTo(Duration(seconds: (_playbacktime).toInt()));
                      });
                    },
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    child: Container(
                      // color: Colors.blue,
                    ),
                    onDoubleTap: () {
                      setState(() {
                        _playbacktime = _playbacktime + 10;
                        _controller.seekTo(Duration(seconds: _playbacktime.toInt() + 10));
                      });
                    },
                  ),
                )
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Slider(
                    value: _playbacktime,
                    min: 0,
                    max: _controller.value.duration.inSeconds.toDouble(),
                    onChanged: (onChanged) {
                      setState(() {
                        _playbacktime = onChanged.floorToDouble();
                        _controller.seekTo(Duration(seconds: onChanged.toInt()));
                      });
                    }),
                // Slider(
                //     value: _volumecontroller,
                //     min: 0,
                //     max: 1,
                //     onChanged: (onChanged) {
                //       setState(() {
                //         _volumecontroller = onChanged;
                //         VolumeController().setVolume(_volumecontroller, showSystemUI: false);
                //       });
                //     }),
              ],
            ),
            Column(
              children: [
                SizedBox(
                  height: 50,
                ),
                Text("Current time : ${_controller.value.position}"),
                Text("Current volume : $_volumecontroller"),
              ],
            ),
          ],
        ));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp,DeviceOrientation.landscapeRight, DeviceOrientation.landscapeRight,]);
  }

}
