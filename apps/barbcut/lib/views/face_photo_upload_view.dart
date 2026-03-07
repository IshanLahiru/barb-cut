import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/user_photo_service.dart';
import '../theme/theme.dart';

class FacePhotoUploadView extends StatefulWidget {
  const FacePhotoUploadView({super.key});

  @override
  State<FacePhotoUploadView> createState() => _FacePhotoUploadViewState();
}

class _FacePhotoUploadViewState extends State<FacePhotoUploadView> {
  final ImagePicker _imagePicker = ImagePicker();
  final Map<String, File?> _selectedImages = {
    'front': null,
    'left': null,
    'right': null,
    'back': null,
  };
  final Map<String, bool> _uploading = {
    'front': false,
    'left': false,
    'right': false,
    'back': false,
  };
  final Map<String, String?> _uploadedUrls = {
    'front': null,
    'left': null,
    'right': null,
    'back': null,
  };

  @override
  void initState() {
    super.initState();
    _loadUploadedPhotos();
  }

  Future<void> _loadUploadedPhotos() async {
    try {
      final photos = await UserPhotoService.getUserPhotos();
      setState(() {
        _uploadedUrls.addAll(photos);
      });
    } catch (e) {
      debugPrint('Failed to load photos: $e');
    }
  }

  Future<void> _pickImage(String position, ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImages[position] = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  Future<void> _uploadPhoto(String position) async {
    final imageFile = _selectedImages[position];
    if (imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    setState(() {
      _uploading[position] = true;
    });

    try {
      final gsUrl = await UserPhotoService.uploadFacePhoto(
        position: position,
        imageFile: imageFile,
      );
      setState(() {
        _uploadedUrls[position] = gsUrl;
        _selectedImages[position] = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('✅ $position photo uploaded!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to upload: $e')));
      }
    } finally {
      setState(() {
        _uploading[position] = false;
      });
    }
  }

  Future<void> _deletePhoto(String position) async {
    try {
      await UserPhotoService.deleteFacePhoto(position);
      setState(() {
        _uploadedUrls[position] = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$position photo deleted')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Face Photos'),
        backgroundColor: AiColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Your Face from 4 Angles',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Upload photos from the front, left, right, and back angles. These will be used to generate better haircut and beard previews.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AiColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ...[
              ('front', 'Front View'),
              ('left', 'Left Side'),
              ('right', 'Right Side'),
              ('back', 'Back View'),
            ].map((item) {
              final position = item.$1;
              final label = item.$2;
              final isUploaded = _uploadedUrls[position] != null;
              final isUploading = _uploading[position] ?? false;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: PhotoUploadCard(
                  position: position,
                  label: label,
                  selectedImage: _selectedImages[position],
                  isUploaded: isUploaded,
                  isUploading: isUploading,
                  onTakePhoto: () => _pickImage(position, ImageSource.camera),
                  onPickFromGallery:
                      () => _pickImage(position, ImageSource.gallery),
                  onUpload: () => _uploadPhoto(position),
                  onDelete: () => _deletePhoto(position),
                ),
              );
            }),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AiColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PhotoUploadCard extends StatelessWidget {
  final String position;
  final String label;
  final File? selectedImage;
  final bool isUploaded;
  final bool isUploading;
  final VoidCallback onTakePhoto;
  final VoidCallback onPickFromGallery;
  final VoidCallback onUpload;
  final VoidCallback onDelete;

  const PhotoUploadCard({
    super.key,
    required this.position,
    required this.label,
    required this.selectedImage,
    required this.isUploaded,
    required this.isUploading,
    required this.onTakePhoto,
    required this.onPickFromGallery,
    required this.onUpload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isUploaded ? Colors.green : Colors.grey.shade300,
          width: isUploaded ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isUploaded ? '✅ Uploaded' : 'Not uploaded',
                        style: TextStyle(
                          color: isUploaded ? Colors.green : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selectedImage != null || isUploaded)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: selectedImage != null
                          ? Image.file(selectedImage!, fit: BoxFit.cover)
                          : Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image),
                            ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isUploading ? null : onTakePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isUploading ? null : onPickFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (selectedImage == null || isUploading)
                        ? null
                        : onUpload,
                    icon: isUploading
                        ? SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                isUploaded ? Colors.green : AiColors.primary,
                              ),
                            ),
                          )
                        : const Icon(Icons.cloud_upload),
                    label: Text(isUploading ? 'Uploading...' : 'Upload'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isUploaded
                          ? Colors.green
                          : AiColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            if (isUploaded)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                  tooltip: 'Delete photo',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
