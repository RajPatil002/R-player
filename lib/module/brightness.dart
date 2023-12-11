import 'package:screen_brightness/screen_brightness.dart';

class Brightness {
  final ScreenBrightness _screenBrightness = ScreenBrightness();

  // Brightness() {
  //   get();
  //   _screenBrightness.onCurrentBrightnessChanged.listen((event) {
  //     print("asa sas $event");
  //   });
  // }
  get() async {
    // print(await _screenBrightness.current);
    setBrightness(2);
  }

  setBrightness(value) {
    _screenBrightness.setScreenBrightness(value);
  }
}
