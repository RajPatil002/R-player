import 'dart:async';
import 'dart:developer';
import 'dart:io' as io;
import 'package:file/memory.dart';
import 'package:file/file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen/screen.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:video_player/video_player.dart';
import 'package:volume_controller/volume_controller.dart';

import 'icon.dart';

class Player extends StatefulWidget {
  const Player({Key? key}) : super(key: key);

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  late VideoPlayerController _controller;
  double _playbacktime = 0;
  late String srt;
  Color greenaccent = const Color(0xff78FF9E);
  final List _volumerange = List.generate(16, (index) => double.parse(((index) / 15).toStringAsFixed(4)));
  final List _speedrange = List.generate(8, (index) => (index+1) * 0.25);
  int _lastpositionvolume = 0, _volumecontroller = 0, _lastpositionbrightness = 0,_speed = 3;
  late int _beforemute;
  late Size size;
  ScreenBrightness bright =  ScreenBrightness();
  bool islocked = false;

  @override
  void initState() {
    super.initState();
    Screen.keepOn(true);
    String movie = "storage/emulated/0/idmp/sonic.mp4";
    // SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight,DeviceOrientation.landscapeLeft,]);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      FileSystem fs = MemoryFileSystem(style: FileSystemStyle.posix);
      log("${(await fs.file(movie).exists()).toString()}             aaaaaaaaaaaa           ${(await io.File(movie).exists()).toString()}");
      size = MediaQuery.of(context).size;
      _volumecontroller = _volumerange.indexOf((await VolumeController().getVolume()));
      // log(_volumecontroller.toString());
      // srt = await fs.file("/storage/0/emulated/idmp/sonic.srt").readAsString();
      _beforemute = _volumecontroller;
      File video = fs.file(fs.path.absolute(movie));
      _controller = VideoPlayerController.file(video)
        ..setVolume(_volumerange[_volumecontroller])
        ..addListener(() {
          setState(() {
            // _playbacktime = _controller.value.position.inSeconds.toDouble();
          });
        })
        ..initialize().then((_) async {
          // log(_controller.value.toString());
          await _controller.play();
          setState(() {});
        });
      // log("${_controller.value.caption.text}aaaaaaaaaaaaaaaaaaaaaaaa");
    });
    VolumeController().listener((volume) async {
      // log("${_volumerange.indexOf(volume)}   $volume   ${_volumerange.contains(volume)}");
      _volumecontroller = _volumerange.indexOf(volume);
      await _controller.setVolume(_volumerange[_volumecontroller]);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xff0e1428),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     setState(() {
        //       _controller.value.isPlaying ? _controller.pause() : _controller.play();
        //     });
        //   },
        //   child: Icon(_controller.value.isPlaying ? (Icons.pause) : (Icons.play_arrow)),
        // ),
        body: Stack(
          children: [
            // _controller.value.isInitialized
            //     ?
            Center(child: AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller)))
            // : const Center(
            //     child: CircularProgressIndicator(),
            //   )
            ,

            // volume indicator
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
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
                        return Padding(
                          padding: const EdgeInsets.all(0.1),
                          child: Container(
                            height: 10,
                            color: index >= _volumecontroller ? Colors.green[50] : greenaccent,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // brightness indicator
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
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
                        return Padding(
                          padding: const EdgeInsets.all(0.1),
                          child: Container(
                            height: 10,
                            color: index >= _volumecontroller ? Colors.green[50] : greenaccent,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Gestures
            _controller.value.isInitialized
                ? Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onVerticalDragUpdate: (update) {
                            // todo the brightness sliding gesture
                            print(bright.current);
                          },
                          onDoubleTap: () {
                            setState(() {
                              _playbacktime = _playbacktime + 10;
                              _controller.seekTo(Duration(seconds: _playbacktime.toInt() + 10));
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
                    ],
                  )
                : Container(),

            // Controls
            islocked
                ? Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: IconButton(
                        icon: Icon(
                          PlayerIcon.lock,
                          color: greenaccent,
                        ),
                        onPressed: () {
                          setState(() {
                            islocked = false;
                          });
                        },
                      ),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextButton.icon(
                                  onPressed: () {
                                    ++_speed;
                                    if(_speed==8) {
                                      _speed=0;
                                    }
                                    setState(() {
                                      _controller.setPlaybackSpeed(_speedrange[_speed]);
                                    });
                                  },
                                  icon: Icon(
                                    false ? PlayerIcon.lock : PlayerIcon.speed,
                                    color: greenaccent,
                                  ), label: Text(_speedrange[_speed].toString(),style: TextStyle(color: greenaccent),),
                              ),
                            ),
                            Expanded(
                              child: IconButton(
                                  onPressed: () {
                                    log(_controller.value.caption.text);
                                    // _controller.setClosedCaptionFile(io.File("/storage/0/emulated/idmp/sonic.srt"))
                                    print("sub");
                                  },
                                  icon: Icon(
                                    Icons.subtitles,
                                    color: greenaccent,
                                  )),
                            ),
                            Expanded(
                              child: IconButton(
                                  onPressed: () {
                                    print("portrait");
                                  },
                                  icon: Icon(
                                    true ? Icons.screen_lock_portrait : Icons.screen_lock_landscape,
                                    color: greenaccent,
                                  )),
                            ),
                          ],
                        ),
                      ),
                      const Text("Time", style: TextStyle(color: Colors.white)),
                      SliderTheme(
                        data: SliderThemeData(
                            // activeTickMarkColor: Colors.,
                            activeTrackColor: greenaccent,
                            inactiveTrackColor: Colors.green.shade100,
                            thumbColor: Colors.white,
                            thumbShape: const RoundSliderThumbShape(),
                            valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                            valueIndicatorColor: Colors.white,
                            valueIndicatorTextStyle: const TextStyle(color: Color(0xff0e1428))
                            // overlayShape: RoundSliderOverlayShape(),
                            ),
                        child: _controller.value.isInitialized
                            ? Slider(
                                label: Duration(seconds: _playbacktime.toInt()).toString().replaceAll(".000000", ""),
                                value: _playbacktime,
                                min: 0,
                                max: _controller.value.duration.inSeconds.toDouble(),
                                divisions: _controller.value.duration.inSeconds,
                                onChangeEnd: (seek) {
                                  setState(() {
                                    _playbacktime = seek.floorToDouble();
                                    _controller.seekTo(Duration(seconds: seek.toInt()));
                                  });
                                },
                                onChanged: (change) {
                                  setState(() {
                                    _playbacktime = change.floorToDouble();
                                  });
                                },
                              )
                            : const Slider(value: 0.0, onChanged: null),
                      ),
                      // const Text("Volume ", style: TextStyle(color: Colors.white)),
                      // Slider(
                      //     value: _volumerange[_volumecontroller],
                      //     min: 0,
                      //     max: 1,
                      //     divisions: 15,
                      //     onChanged: (onChanged) {
                      //       setState(() {
                      //         _volumecontroller = (onChanged * 15).floor();
                      //         _controller.setVolume(_volumerange[_volumecontroller]);
                      //         VolumeController().setVolume(
                      //             _volumerange[_volumecontroller],
                      //             showSystemUI: false);
                      //       });
                      //     }),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(children: <Widget>[
                          Expanded(
                            child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    islocked = true;
                                  });
                                },
                                icon: Icon(
                                  PlayerIcon.lockopen,
                                  color: greenaccent,
                                )),
                          ),
                          Expanded(
                            child: IconButton(
                                onPressed: () {
                                  print("previous");
                                },
                                tooltip: "previous",
                                icon: Icon(
                                  PlayerIcon.previous,
                                  color: greenaccent,
                                )),
                          ),
                          Expanded(
                            child: IconButton(
                                onPressed: () {
                                  print("play");
                                  setState(() {
                                    _controller.value.isPlaying ? _controller.pause() : _controller.play();
                                  });
                                },
                                icon: Icon(
                                  (_controller.value.isPlaying ? PlayerIcon.pause : PlayerIcon.play),
                                  color: greenaccent,
                                )),
                          ),
                          Expanded(
                            child: IconButton(
                                onPressed: () {
                                  print("next");
                                },
                                icon: Icon(
                                  PlayerIcon.next,
                                  color: greenaccent,
                                )),
                          ),
                          Expanded(
                            child: IconButton(
                                onPressed: () {
                                  if(_volumecontroller != 0){
                                    _beforemute = _volumecontroller;
                                    _volumecontroller = 0;
                                    setState(() {
                                      _controller.setVolume(_volumerange[_volumecontroller]);
                                      VolumeController().setVolume(_volumerange[_volumecontroller], showSystemUI: false);
                                      // log(_volumerange[_volumecontroller].toString());
                                    });
                                  }else if(_volumecontroller == 0){
                                    _volumecontroller = _beforemute;
                                    setState(() {
                                      _controller.setVolume(_volumerange[_volumecontroller]);
                                      VolumeController().setVolume(_volumerange[_volumecontroller], showSystemUI: false);
                                      // log(_volumerange[_volumecontroller].toString());
                                    });
                                  }
                                  print("mute${_volumerange[_volumecontroller]}");
                                },
                                icon: Icon(
                                  _volumecontroller == 0? PlayerIcon.mute : PlayerIcon.unmute,
                                  color: greenaccent,
                                )),
                          ),
                        ]),
                      ),
                    ],
                  ),

            // Text
            Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                // _controller.value.isInitialized?ClosedCaption(
                //   text: srt,
                // ):Container(),
                Text("Current time : ${_controller.value.position}", style: const TextStyle(color: Colors.white)),
                Text("Current volume : ${_volumerange[_volumecontroller]}", style: const TextStyle(color: Colors.white)),
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
    ]);
    Screen.keepOn(false);
  }
}
