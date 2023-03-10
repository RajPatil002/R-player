import 'package:flutter/material.dart';
import 'package:r_player/player.dart';
import 'package:screen_brightness/screen_brightness.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(home: Just()));
}

class Just extends StatefulWidget {
  @override
  State<Just> createState() => _JustState();
}

class _JustState extends State<Just> {
  final b = ScreenBrightness();
  int br = 5;
  int _lastpositionbright = 0;
  late Size size;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) { 
      size = MediaQuery.of(context).size;
      setState(() {
        
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(border: Border.all(color: Colors.green)),
                  // color: Colors.yellow,
                  width: 50,
                  height: 150,
                  child: Column(
                    children: [
                      br != 10? Expanded(
                          flex: 10 - br,
                          child: Container(
                            height: 10,
                            color: Colors.red,
                          )):Container(),
                      br != 0? Expanded(
                          flex: br,
                          child: Container(
                            height: 10,
                            color: Colors.green,
                          )):Container(),
                    ],
                  )
                  // MediaQuery.removePadding(
                  //   context: context,
                  //   removeTop: true,
                  //   child: ListView.builder(
                  //     physics: const NeverScrollableScrollPhysics(),
                  //     shrinkWrap: true,
                  //     reverse: true,
                  //     itemCount: 15,
                  //     itemBuilder: (context, index) {
                  //       return Padding(
                  //         padding: const EdgeInsets.all(0.1),
                  //         child: Container(
                  //           height: 10,
                  //           color: index >= 4 ? Colors.green[50] : Colors.red,
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // ),
                  ),
            ),
          ),
          GestureDetector(
            // child: Container(
            //   color: Colors.yellow,
            // ),
            onVerticalDragUpdate: (update) {
              int diff = (_lastpositionbright - update.localPosition.dy.floor());
              if (diff.abs() > size.height / 50) {
                _lastpositionbright = update.localPosition.dy.floor();
                if (diff.isNegative) {
                  if (br > 0) {
                    br -= 1;
                  }
                } else {
                  if (br < 10) {
                    br += 1;
                  }
                }
                setState(() {
                  print(br);
                  // _controller.setVolume(_volumerange[br]);
                  // VolumeController().setVolume(_volumerange[br], showSystemUI: false);
                  // log(_volumerange[br].toString());
                });
              }
            },
          ),
          Text("$br")
        ],
      ),
    );
  }
}
