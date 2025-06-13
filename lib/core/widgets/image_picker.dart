import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as picker;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// A dynamic image picker widget that supports both camera and gallery image picking
class ImagePickerWidget extends StatelessWidget {
  final Function(File?)? onImagePicked;
  final double? width;
  final double? height;
  final String? cameraButtonText;
  final String? galleryButtonText;
  final IconData? cameraIcon;
  final IconData? galleryIcon;
  final Color? buttonColor;
  final Color? iconColor;
  final bool showCameraOption;
  final bool showGalleryOption;
  final double? borderRadius;
  final Widget? placeholder;

  const ImagePickerWidget({
    Key? key,
    this.onImagePicked,
    this.width,
    this.height,
    this.cameraButtonText = 'Take Photo',
    this.galleryButtonText = 'Choose from Gallery',
    this.cameraIcon = Icons.camera_alt,
    this.galleryIcon = Icons.photo_library,
    this.buttonColor,
    this.iconColor,
    this.showCameraOption = true,
    this.showGalleryOption = true,
    this.borderRadius,
    this.placeholder,
  }) : super(key: key);

  Future<void> pickImage(ImageSource source, BuildContext context) async {
    try {
      // Request permission based on source
      if (source == ImageSource.camera) {
        final status = await Permission.camera.request();
        if (!status.isGranted) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Camera permission is required to take photos'),
              ),
            );
          }
          return;
        }
      } else {
        final status = await Permission.photos.request();
        if (!status.isGranted) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Photo library permission is required'),
              ),
            );
          }
          return;
        }
      }

      final picker.ImagePicker imagePicker = picker.ImagePicker();
      final XFile? pickedFile = await imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        onImagePicked?.call(imageFile);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showCameraOption)
                ListTile(
                  leading: Icon(cameraIcon, color: iconColor),
                  title: Text(cameraButtonText ?? 'Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    pickImage(ImageSource.camera, context);
                  },
                ),
              if (showGalleryOption)
                ListTile(
                  leading: Icon(galleryIcon, color: iconColor),
                  title: Text(galleryButtonText ?? 'Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    pickImage(ImageSource.gallery, context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showImageSourceDialog(context),
      child: Container(
        width: width ?? 150,
        height: height ?? 150,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
        ),
        child: placeholder ??
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_a_photo,
                  size: 40,
                  color: iconColor ?? Colors.grey[600],
                ),
                const SizedBox(height: 8),
                Text(
                  'Add Image',
                  style: TextStyle(
                    color: iconColor ?? Colors.grey[600],
                  ),
                ),
              ],
            ),
      ),
    );
  }
}

/// A utility class for picking images programmatically
class ImagePickerService {
  static final ImagePickerService _instance = ImagePickerService._internal();
  factory ImagePickerService() => _instance;
  ImagePickerService._internal();

  final picker.ImagePicker _picker = picker.ImagePicker();

  /// Pick an image from the camera
  Future<File?> pickFromCamera({
    int imageQuality = 85,
    int maxWidth = 1920,
    int maxHeight = 1080,
  }) async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        throw Exception('Camera permission not granted');
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: imageQuality,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
      );

      return pickedFile != null ? File(pickedFile.path) : null;
    } catch (e) {
      rethrow;
    }
  }

  /// Pick an image from the gallery
  Future<File?> pickFromGallery({
    int imageQuality = 85,
    int maxWidth = 1920,
    int maxHeight = 1080,
  }) async {
    try {
      if (Platform.isAndroid) {
        // For Android 13 and above
        if (await Permission.storage.status.isGranted) {
          final XFile? pickedFile = await _picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: imageQuality,
            maxWidth: maxWidth.toDouble(),
            maxHeight: maxHeight.toDouble(),
          );
          return pickedFile != null ? File(pickedFile.path) : null;
        }
        
        // Request storage permission
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          throw Exception('Storage permission not granted');
        }
      } else if (Platform.isIOS) {
        // For iOS
        if (await Permission.photos.status.isGranted) {
          final XFile? pickedFile = await _picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: imageQuality,
            maxWidth: maxWidth.toDouble(),
            maxHeight: maxHeight.toDouble(),
          );
          return pickedFile != null ? File(pickedFile.path) : null;
        }
        
        // Request photos permission
        final status = await Permission.photos.request();
        if (!status.isGranted) {
          throw Exception('Photos permission not granted');
        }
      }

      // If we get here, permission was granted, so try picking the image
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
      );

      return pickedFile != null ? File(pickedFile.path) : null;
    } catch (e) {
      rethrow;
    }
  }
}