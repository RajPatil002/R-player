import 'package:flutter/material.dart';
import 'package:r_player/module/volume.dart';
import 'package:r_player/screens/RightControlsScreen.dart';
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
    final Volume volume = Volume();
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              Expanded(
                  flex: 4,
                  child: Container(
                    color: Colors.red,
                  )),
              Expanded(
                flex: 1,
                child: RightControlsScreen(
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
