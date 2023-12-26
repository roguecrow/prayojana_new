import 'package:url_launcher/url_launcher.dart';

class MapUtils {

  MapUtils._();

  static Future<void> openMap(location) async {
    final Uri url = Uri.parse(location);
    print('trying to open map');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
class makeCall {
  static Future<void> makePhoneCall(phone) async {
    final Uri url = Uri.parse(phone);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}