import 'package:flutter/widgets.dart';

class PlayerIcon {
  PlayerIcon._();

  static const _kFontFam = 'PlayerIcon';
  static const String? _kFontPkg = null;

  static const IconData speed =
      IconData(0xe800, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData lock =
      IconData(0xe801, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData lockopen =
      IconData(0xe802, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData previous =
      IconData(0xe803, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData next =
      IconData(0xe804, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData play =
      IconData(0xe805, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData pause =
      IconData(0xe806, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData mute =
      IconData(0xf325, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData unmute =
      IconData(0xf326, fontFamily: _kFontFam, fontPackage: _kFontPkg);
}
