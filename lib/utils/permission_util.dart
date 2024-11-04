import 'package:permission_handler/permission_handler.dart';

class PermissionUtil {
  static Future<bool> requestStoragePermissions() async {
    // Check if permission is already granted
    if (await Permission.storage.isGranted) {
      return true;
    }

    // Request permission if not yet granted
    var status = await Permission.storage.request();

    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      // Show an alert or guide the user to grant permission
      return false;
    } else if (status.isPermanentlyDenied) {
      // Take the user to the settings page to manually enable permissions
      await openAppSettings();
      return false;
    }
    return false;
  }
}