import 'dart:io';

class AdHelper {
  static String get getAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-8743478038035209/4687361642';
    } else if (Platform.isIOS) {
      return '';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
