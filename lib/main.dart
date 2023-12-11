import 'package:flutter/material.dart';
import 'package:r_player/module/brightness.dart';
import 'package:r_player/module/volume.dart';
import 'package:r_player/screens/LeftScreenControls.dart';
import 'package:r_player/screens/RightScreenControls.dart';
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
  late Size size;
  final Volume volume = Volume();
  final Brightness brightness = Brightness();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      size = MediaQuery.of(context).size;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.green,
                    child: LeftScreenControls(brightness: Brightness()),
                  )),
              Expanded(
                flex: 3,
                child: Container(
                  color: Colors.red,
                ),
              ),
              Expanded(
                flex: 1,
                child: RightScreenControls(
                  volume: volume,
                ),
              ),
            ],
          ),
          Text("$br")
        ],
      ),
    );
  }
}
