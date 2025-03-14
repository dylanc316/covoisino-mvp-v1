import 'package:covoisino/core/localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

Future<void> choosePhoto(BuildContext context, Function(String?) onPhotoSelected) async {
  final l10n = AppLocalizations.of(context);
  final ImagePicker picker = ImagePicker();
  
  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: Text(l10n.get('take_photo')),
            onTap: () async {
              Navigator.pop(context);
              try {
                final XFile? photo = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                );
                if (photo != null) {
                  onPhotoSelected(photo.path);
                }
              } catch (e) {
                if (context.mounted) {
                  showError(context, '${l10n.get('error')}$e');
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: Text(l10n.get('choose_from_gallery')),
            onTap: () async {
              Navigator.pop(context);
              try {
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );
                if (image != null) {
                  onPhotoSelected(image.path);
                }
              } catch (e) {
                if (context.mounted) {
                  showError(context, '${l10n.get('error')}$e');
                }
              }
            },
          ),
        ],
      ),
    ),
  );
}

void showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

// This is a utility function to display a photo from a path
Widget displayPhoto(String path, {double size = 100}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(size / 2),
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: path.startsWith('http')
          ? Image.network(
              path,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.person,
                size: 50,
                color: Colors.grey,
              ),
            )
          : Image.file(
              File(path),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.person,
                size: 50,
                color: Colors.grey,
              ),
            ),
    ),
  );
}