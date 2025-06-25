import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionHelper {
  static Future<bool> requestCameraPermission(BuildContext context) async {
    PermissionStatus status = await Permission.camera.status;

    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDialog(
        context,
        'Camera Permission',
        'Camera permission is permanently denied. Please enable it in app settings.',
        () => openAppSettings(),
      );
      return false;
    }

    return status.isGranted;
  }

  static Future<bool> requestStoragePermission(BuildContext context) async {
    PermissionStatus status = await Permission.storage.status;

    if (status.isDenied) {
      status = await Permission.storage.request();
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDialog(
        context,
        'Storage Permission',
        'Storage permission is permanently denied. Please enable it in app settings.',
        () => openAppSettings(),
      );
      return false;
    }

    return status.isGranted;
  }

  static Future<bool> requestLocationPermission(BuildContext context) async {
    PermissionStatus status = await Permission.location.status;

    if (status.isDenied) {
      status = await Permission.location.request();
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDialog(
        context,
        'Location Permission',
        'Location permission is permanently denied. Please enable it in app settings.',
        () => openAppSettings(),
      );
      return false;
    }

    return status.isGranted;
  }

  static void _showPermissionDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onSettingsPressed,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onSettingsPressed();
              },
              child: const Text('Settings'),
            ),
          ],
        );
      },
    );
  }

  static Future<bool> requestImagePickerPermissions(
      BuildContext context) async {
    bool storageGranted = await requestStoragePermission(context);
    bool locationGranted = await requestLocationPermission(context);

    return storageGranted && locationGranted;
  }
}
