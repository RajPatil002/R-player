import 'package:volume_controller/volume_controller.dart';

class Volume {
  final List volumerange = List.generate(16, (index) => double.parse(((index) / 15).toStringAsFixed(4)));
  late int index;
  late double volume;
  final volumecontroller = VolumeController();
  Volume() {
    getSystemVolume();
    print("here");
    volumecontroller.listener(updateVolumeFromExternal);
  }
  updateVolumeFromExternal(value) {
    index = volumerange.indexOf(value);
    volume = value;
    print("vol ex $volumerange  $volume   $index");
  }

  // int index get
  updateVolumeFromInternal(index) => setSystemVolume(index);

  setSystemVolume(int index) {
    volumecontroller.setVolume(volumerange[index], showSystemUI: true);
  }

  void getSystemVolume() async {
    volume = await volumecontroller.getVolume();
    index = volumerange.indexOf(volume);
    print("vol $volumerange  $volume   $index");
    // setSystemVolume(index);
  }
}
