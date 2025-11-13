import 'package:qlutter/ver_3/common/router/routes.dart';

class HomeGuard {
  bool canActivate(Routes route) {
    // Implement your guard logic here
    // For example, ensure home route is always on top
    return true;
  }
}
