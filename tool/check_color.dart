import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final bytes = File('assets/images/app_logo.png').readAsBytesSync();
  final image = img.decodePng(bytes)!;
  final p = image.getPixel(512, 512);
// ignore: avoid_print
  print('Pixel at (512,512) in app_logo.png: R=${p.r}, G=${p.g}, B=${p.b}, A=${p.a}');

  final mipmapFile = File('android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png');
  if (mipmapFile.existsSync()) {
    final mBytes = mipmapFile.readAsBytesSync();
    final mImage = img.decodePng(mBytes)!;
    final mp = mImage.getPixel(mImage.width ~/ 2, mImage.height ~/ 2);
// ignore: avoid_print
    print('Pixel in mipmap-xxhdpi ic_launcher.png: R=${mp.r}, G=${mp.g}, B=${mp.b}, A=${mp.a}');
  }
}
