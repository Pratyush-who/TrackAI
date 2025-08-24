import 'dart:io';
import 'dart:convert'; // Added for utf8 encoding
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';

class FileDownloadService {
  // Request storage permission with better error handling
  static Future<bool> requestStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;

        // For Android 11+ (API 30+), we need MANAGE_EXTERNAL_STORAGE
        if (androidInfo.version.sdkInt >= 30) {
          var status = await Permission.manageExternalStorage.status;
          if (status != PermissionStatus.granted) {
            status = await Permission.manageExternalStorage.request();
            if (status != PermissionStatus.granted) {
              // If MANAGE_EXTERNAL_STORAGE is denied, try WRITE_EXTERNAL_STORAGE
              status = await Permission.storage.status;
              if (status != PermissionStatus.granted) {
                status = await Permission.storage.request();
              }
            }
          }
          return status == PermissionStatus.granted;
        } else {
          // For older Android versions, use WRITE_EXTERNAL_STORAGE
          var status = await Permission.storage.status;
          if (status != PermissionStatus.granted) {
            status = await Permission.storage.request();
          }
          return status == PermissionStatus.granted;
        }
      } else if (Platform.isIOS) {
        // iOS doesn't require storage permissions for app documents
        return true;
      }

      return false;
    } catch (e) {
      print('Error requesting storage permission: $e');
      return false;
    }
  }

  // Check if we have storage permission
  static Future<bool> hasStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;

        if (androidInfo.version.sdkInt >= 30) {
          final manageStatus = await Permission.manageExternalStorage.status;
          final storageStatus = await Permission.storage.status;
          return manageStatus == PermissionStatus.granted ||
              storageStatus == PermissionStatus.granted;
        } else {
          final status = await Permission.storage.status;
          return status == PermissionStatus.granted;
        }
      } else if (Platform.isIOS) {
        return true;
      }

      return false;
    } catch (e) {
      print('Error checking storage permission: $e');
      return false;
    }
  }

  // Download workout plan as text file with better error handling
  static Future<String?> downloadWorkoutPlan(
    String content,
    String planTitle,
  ) async {
    try {
      // Check if we already have permission
      bool hasPermission = await hasStoragePermission();

      // If not, request permission
      if (!hasPermission) {
        hasPermission = await requestStoragePermission();
        if (!hasPermission) {
          throw Exception(
            'Storage permission is required to download files. Please grant permission in settings.',
          );
        }
      }

      // Get the appropriate directory
      Directory? directory;

      if (Platform.isAndroid) {
        // Try to get the Downloads directory first
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          // Fallback to external storage directory
          directory = await getExternalStorageDirectory();
          if (directory == null) {
            // Final fallback to app documents directory
            directory = await getApplicationDocumentsDirectory();
          }
        }
      } else if (Platform.isIOS) {
        // For iOS, use documents directory
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access storage directory');
      }

      // Ensure directory exists
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Create filename with timestamp
      final now = DateTime.now();
      final timestamp =
          '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}';
      final sanitizedTitle = planTitle.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      final fileName = 'WorkoutPlan_${sanitizedTitle}_$timestamp.txt';

      // Create file
      final file = File('${directory.path}/$fileName');

      // Write content to file
      await file.writeAsString(content, encoding: utf8);

      print('File downloaded successfully to: ${file.path}');
      return file.path;
    } catch (e) {
      print('Error downloading workout plan: $e');
      throw Exception('Failed to download file: ${e.toString()}');
    }
  }

  // Share workout plan file
  static Future<void> shareWorkoutPlan(String content, String planTitle) async {
    try {
      // Get temporary directory
      final tempDir = await getTemporaryDirectory();

      // Create filename
      final now = DateTime.now();
      final timestamp =
          '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
      final sanitizedTitle = planTitle.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      final fileName = 'WorkoutPlan_${sanitizedTitle}_$timestamp.txt';

      // Create file in temp directory
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(content, encoding: utf8);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Check out my AI-generated workout plan!',
        subject: 'My Workout Plan - $planTitle',
      );
    } catch (e) {
      print('Error sharing workout plan: $e');
      throw Exception('Failed to share workout plan: ${e.toString()}');
    }
  }

  // Show permission dialog
  static Future<void> showPermissionDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Storage Permission Required'),
          content: Text(
            'This app needs storage permission to download your workout plans. '
            'Please grant permission to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }
}
