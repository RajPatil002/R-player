import 'dart:async';
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
  double _playbacktime = 0;
  final List _volumerange = List.generate(16, (index) => double.parse(((index) / 15).toStringAsFixed(4)));
  int _lastpositionvolume = 0, _volumecontroller = 0, _lastpositionbrightness = 0;
  late Size size;

  @override
  void initState() {
    super.initState();
    // SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight,DeviceOrientation.landscapeLeft,]);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      FileSystem fs = MemoryFileSystem(style: FileSystemStyle.posix);
      // log((await io.File("storage/emulated/0/download/govinda.mkv").exists()).toString());
      size = MediaQuery.of(context).size;
      _volumecontroller = _volumerange.indexOf((await VolumeController().getVolume()));
      // log(_volumecontroller.toString());
      File video = fs.file(fs.path.absolute("storage/emulated/0/download/govinda.mkv"));
      _controller = VideoPlayerController.file(video)
        ..setVolume(_volumerange[_volumecontroller])
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
      log("${_controller.value.aspectRatio}aaaaaaaaaaaaaaaaaaaaaaaa");
    });
    VolumeController().listener((volume) async {
      log("${_volumerange.indexOf(volume)}   $volume   ${_volumerange.contains(volume)}");
      _volumecontroller = _volumerange.indexOf(volume);
      await _controller.setVolume(_volumerange[_volumecontroller]);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xff0e1428),
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
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(border: Border.all(color: Colors.green)),
                  // color: Colors.yellow,
                  width: size.width / 12,
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      reverse: true,
                      itemCount: _volumerange.length - 1,
                      itemBuilder: (context, index) {
                        return Container(
                          height: 10,
                          color: index >= _volumecontroller ? Colors.blue[900] : Colors.red[400],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onVerticalDragUpdate: (update) {
                      int diff = (_lastpositionvolume - update.localPosition.dy.floor());
                      if (diff.abs() > size.height / 50) {
                        _lastpositionvolume = update.localPosition.dy.floor();
                        if (diff.isNegative) {
                          if (_volumecontroller > 0) {
                            _volumecontroller -= 1;
                          }
                        } else {
                          if (_volumecontroller < 15) {
                            _volumecontroller += 1;
                          }
                        }
                        setState(() {
                          _controller.setVolume(_volumerange[_volumecontroller]);
                          VolumeController().setVolume(_volumerange[_volumecontroller], showSystemUI: false);
                          // log(_volumerange[_volumecontroller].toString());
                        });
                      }
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
                    onHorizontalDragUpdate: (update) {
                      // log((update.delta.dx / 10).toString());
                      setState(() {
                        _playbacktime = _playbacktime + (update.delta.dx / 10);
                        _controller.seekTo(Duration(seconds: (_playbacktime).toInt()));
                      });
                    },
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onVerticalDragUpdate: (update) {
                      // todo the brightness sliding gesture
                    },
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
                const Text("Time",style: TextStyle(color: Colors.white)),
                SliderTheme(
                  data: SliderThemeData(
                    // activeTickMarkColor: Colors.,
                    activeTrackColor: Colors.green,
                    thumbColor: Colors.red,
                    thumbShape: RoundSliderThumbShape()
                  ),
                  child: Slider(
                      value: _controller.value.position.inSeconds.toDouble(),
                      min: 0,
                      max: _controller.value.duration.inSeconds.toDouble(),
                      onChanged: (onChanged) {
                        setState(() {
                          _playbacktime = onChanged.floorToDouble();
                          _controller.seekTo(Duration(seconds: onChanged.toInt()));
                        });
                      }),
                ),
                const Text("Volume ",style: TextStyle(color: Colors.white)),
                Slider(
                    value: _volumerange[_volumecontroller],
                    min: 0,
                    max: 1,
                    onChanged: (onChanged) {
                      setState(() {
                        _volumecontroller = (onChanged * 15).floor();
                        VolumeController().setVolume(_volumerange[_volumecontroller], showSystemUI: false);
                      });
                    }),
              ],
            ),
            Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                Text("Current time : ${_controller.value.position}",style: const TextStyle(color: Colors.white)),
                Text("Current volume : ${_volumerange[_volumecontroller]}",style: const TextStyle(color: Colors.white)),
              ],
            ),
          ],
        ));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}
