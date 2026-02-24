import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/app_data.dart';
import '../services/auth_service.dart';
import '../theme/theme.dart';
import '../widgets/firebase_image.dart';

class QuestionnaireConfig {
  final List<String> hairTypes;
  final List<String> faceShapes;
  final List<String> preferredLengths;
  final List<String> beardStyles;
  final List<String> lifestyles;
  final int photoCount;
  final bool requirePhotos;
  final String title;
  final String photoHelpText;
  final String sectionPhotosTitle;
  final String sectionStyleTitle;
  final String saveButtonText;
  final String? defaultHairType;
  final String? defaultFaceShape;
  final String? defaultPreferredLength;
  final String? defaultBeardStyle;
  final String? defaultLifestyle;

  const QuestionnaireConfig({
    this.hairTypes = const ['Straight', 'Wavy', 'Curly', 'Coily'],
    this.faceShapes = const [
      'Oval',
      'Round',
      'Square',
      'Heart',
      'Diamond',
      'Oblong',
    ],
    this.preferredLengths = const ['Short', 'Medium', 'Long'],
    this.beardStyles = const [
      'None',
      'Full Beard',
      'Goatee',
      'Stubble',
      'Mustache',
      'Van Dyke',
    ],
    this.lifestyles = const ['Active', 'Professional', 'Casual', 'Sporty'],
    this.photoCount = 4,
    this.requirePhotos = true,
    this.title = 'My Profile & Photos',
    this.photoHelpText =
        'Upload 4 photos of your current hairstyle from different angles',
    this.sectionPhotosTitle = 'Your Photos',
    this.sectionStyleTitle = 'Style Preferences',
    this.saveButtonText = 'Save Profile',
    this.defaultHairType,
    this.defaultFaceShape,
    this.defaultPreferredLength,
    this.defaultBeardStyle,
    this.defaultLifestyle,
  });
}

class QuestionnaireView extends StatefulWidget {
  final QuestionnaireConfig config;
  final bool isOnboarding;
  final bool allowBack;
  final Future<void> Function()? onCompleted;

  const QuestionnaireView({
    super.key,
    this.config = const QuestionnaireConfig(),
    this.isOnboarding = false,
    this.allowBack = true,
    this.onCompleted,
  });

  @override
  State<QuestionnaireView> createState() => _QuestionnaireViewState();
}

class _QuestionnaireViewState extends State<QuestionnaireView> {
  final ImagePicker _picker = ImagePicker();
  late final List<File?> _photos;
  late final List<String?> _photoPaths;

  // Questionnaire answers
  late String _hairType;
  late String _faceShape;
  late String _preferredLength;
  bool _hasBeard = false;
  late String _beardStyle;
  late String _lifestyle;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _photos = List<File?>.filled(widget.config.photoCount, null);
    _photoPaths = List<String?>.filled(widget.config.photoCount, null);
    _seedPhotoPaths();
    _hairType = widget.config.defaultHairType ?? widget.config.hairTypes.first;
    _faceShape =
        widget.config.defaultFaceShape ?? widget.config.faceShapes.first;
    _preferredLength =
        widget.config.defaultPreferredLength ??
        widget.config.preferredLengths.first;
    _beardStyle =
        widget.config.defaultBeardStyle ?? widget.config.beardStyles.first;
    _lifestyle =
        widget.config.defaultLifestyle ?? widget.config.lifestyles.first;
  }

  void _seedPhotoPaths() {
    final rawPaths = AppData.defaultProfile['photoPaths'];
    if (rawPaths is! List) {
      return;
    }

    for (
      var index = 0;
      index < rawPaths.length && index < _photoPaths.length;
      index++
    ) {
      final value = rawPaths[index]?.toString().trim() ?? '';
      _photoPaths[index] = value.isEmpty ? null : value;
    }
  }

  Future<void> _pickImage(int index) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _photos[index] = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AdaptiveThemeColors.error(context),
          ),
        );
      }
    }
  }

  Future<void> _takePhoto(int index) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _photos[index] = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to take photo: $e'),
            backgroundColor: AdaptiveThemeColors.error(context),
          ),
        );
      }
    }
  }

  void _showImageSourceDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AdaptiveThemeColors.surface(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
          ),
          child: Container(
            padding: EdgeInsets.all(AiSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose Photo Source',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AdaptiveThemeColors.textPrimary(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AiSpacing.lg),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(AiSpacing.sm),
                    decoration: BoxDecoration(
                      color: AdaptiveThemeColors.neonCyan(
                        context,
                      ).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(
                        AiSpacing.radiusMedium,
                      ),
                    ),
                    child: Icon(
                      Icons.photo_library,
                      color: AdaptiveThemeColors.neonCyan(context),
                    ),
                  ),
                  title: Text(
                    'Gallery',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AdaptiveThemeColors.textPrimary(context),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(index);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(AiSpacing.sm),
                    decoration: BoxDecoration(
                      color: AdaptiveThemeColors.neonPurple(
                        context,
                      ).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(
                        AiSpacing.radiusMedium,
                      ),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: AdaptiveThemeColors.neonPurple(context),
                    ),
                  ),
                  title: Text(
                    'Camera',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AdaptiveThemeColors.textPrimary(context),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto(index);
                  },
                ),
                SizedBox(height: AiSpacing.sm),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: AdaptiveThemeColors.textTertiary(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _removePhoto(int index) {
    setState(() {
      _photos[index] = null;
      _photoPaths[index] = null;
    });
  }

  bool _hasPhotoAt(int index) {
    return _photos[index] != null || _photoPaths[index] != null;
  }

  bool _validateRequiredPhotos() {
    if (!widget.config.requirePhotos) {
      return true;
    }

    if (_photos.isEmpty || !_photos.asMap().keys.every(_hasPhotoAt)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please upload all ${widget.config.photoCount} photos to continue.',
          ),
          backgroundColor: AdaptiveThemeColors.error(context),
        ),
      );
      return false;
    }

    return true;
  }

  Future<List<String>> _uploadPhotos(String userId) async {
    final storage = FirebaseStorage.instance;
    final List<String> resolvedPaths = List<String>.generate(
      widget.config.photoCount,
      (index) => _photoPaths[index] ?? '',
    );

    for (var index = 0; index < _photos.length; index++) {
      final photo = _photos[index];
      if (photo == null) {
        continue;
      }

      final storagePath = 'users/$userId/questionnaire/photo_${index + 1}.jpg';
      final ref = storage.ref(storagePath);
      await ref.putFile(photo);
      final downloadUrl = await ref.getDownloadURL();
      final cacheBustedUrl = _appendCacheBuster(downloadUrl);
      resolvedPaths[index] = cacheBustedUrl;
      _photoPaths[index] = cacheBustedUrl;
    }

    return resolvedPaths;
  }

  String _appendCacheBuster(String url) {
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}v=${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _saveProfile() async {
    if (_isSaving || !_validateRequiredPhotos()) {
      return;
    }

    await AuthService().ensureAuthenticated();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please sign in to save your profile.'),
          backgroundColor: AdaptiveThemeColors.error(context),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final photoPaths = await _uploadPhotos(user.uid);
      final Map<String, dynamic> profileData = {
        'userId': user.uid,
        'hairType': _hairType,
        'faceShape': _faceShape,
        'preferredLength': _preferredLength,
        'hasBeard': _hasBeard,
        'beardStyle': _hasBeard ? _beardStyle : 'None',
        'lifestyle': _lifestyle,
        'photoPaths': photoPaths,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (user.displayName != null && user.displayName!.isNotEmpty) {
        profileData['username'] = user.displayName;
      }

      if (user.email != null && user.email!.isNotEmpty) {
        profileData['email'] = user.email;
      }

      await FirebaseFirestore.instance
          .collection('userProfiles')
          .doc(user.uid)
          .set(profileData, SetOptions(merge: true));

      await AppData.refreshFromFirebase();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile saved successfully!'),
          backgroundColor: AdaptiveThemeColors.neonCyan(context),
        ),
      );

      if (widget.onCompleted != null) {
        await widget.onCompleted!.call();
      } else {
        Navigator.pop(context);
      }
    } on FirebaseException catch (e) {
      if (!mounted) return;
      final message = e.code == 'unauthorized'
          ? 'Storage access denied. Check Firebase Auth and Storage rules.'
          : 'Failed to save profile: ${e.message ?? e.code}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AdaptiveThemeColors.error(context),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save profile: $e'),
          backgroundColor: AdaptiveThemeColors.error(context),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdaptiveThemeColors.backgroundDeep(context),
      appBar: AppBar(
        backgroundColor: AdaptiveThemeColors.backgroundDark(context),
        elevation: 0,
        automaticallyImplyLeading: widget.allowBack,
        leading: widget.allowBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
                color: AdaptiveThemeColors.textPrimary(context),
              )
            : null,
        title: Text(
          widget.config.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AdaptiveThemeColors.textPrimary(context),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(AiSpacing.lg),
        children: [
          // Photos Section
          _buildSectionTitle(widget.config.sectionPhotosTitle),
          SizedBox(height: AiSpacing.md),
          Text(
            widget.config.photoHelpText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AdaptiveThemeColors.textTertiary(context),
            ),
          ),
          SizedBox(height: AiSpacing.lg),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AiSpacing.md,
              mainAxisSpacing: AiSpacing.md,
              childAspectRatio: 0.9,
            ),
            itemCount: widget.config.photoCount,
            itemBuilder: (context, index) {
              return _buildPhotoCard(index);
            },
          ),

          SizedBox(height: AiSpacing.xxxl),

          // Questionnaire Section
          _buildSectionTitle(widget.config.sectionStyleTitle),
          SizedBox(height: AiSpacing.lg),

          _buildDropdownQuestion(
            'Hair Type',
            _hairType,
            widget.config.hairTypes,
            (value) => setState(() => _hairType = value!),
            Icons.waves,
          ),

          _buildDropdownQuestion(
            'Face Shape',
            _faceShape,
            widget.config.faceShapes,
            (value) => setState(() => _faceShape = value!),
            Icons.face,
          ),

          _buildDropdownQuestion(
            'Preferred Length',
            _preferredLength,
            widget.config.preferredLengths,
            (value) => setState(() => _preferredLength = value!),
            Icons.straighten,
          ),

          _buildSwitchQuestion(
            'Do you have a beard?',
            _hasBeard,
            (value) => setState(() {
              _hasBeard = value;
              if (!value) {
                _beardStyle = 'None';
                return;
              }

              if (_beardStyle == 'None') {
                final options = widget.config.beardStyles
                    .where((style) => style != 'None')
                    .toList();
                if (options.isNotEmpty) {
                  _beardStyle = options.first;
                }
              }
            }),
            Icons.face_retouching_natural,
          ),

          if (_hasBeard)
            Builder(
              builder: (context) {
                final beardOptions = widget.config.beardStyles
                    .where((style) => style != 'None')
                    .toList();
                if (beardOptions.isEmpty) {
                  return const SizedBox.shrink();
                }

                final beardValue = beardOptions.contains(_beardStyle)
                    ? _beardStyle
                    : beardOptions.first;

                return _buildDropdownQuestion(
                  'Beard Style',
                  beardValue,
                  beardOptions,
                  (value) => setState(() => _beardStyle = value!),
                  Icons.face_retouching_natural,
                );
              },
            ),

          _buildDropdownQuestion(
            'Lifestyle',
            _lifestyle,
            widget.config.lifestyles,
            (value) => setState(() => _lifestyle = value!),
            Icons.directions_run,
          ),

          SizedBox(height: AiSpacing.xxxl),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AdaptiveThemeColors.neonCyan(context),
                foregroundColor: AdaptiveThemeColors.surface(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
                ),
                elevation: 4,
                shadowColor: AdaptiveThemeColors.neonCyan(
                  context,
                ).withValues(alpha: 0.3),
              ),
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AdaptiveThemeColors.surface(context),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.save, size: 20),
                        SizedBox(width: AiSpacing.sm),
                        Text(
                          widget.config.saveButtonText,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AdaptiveThemeColors.surface(context),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
            ),
          ),

          SizedBox(height: AiSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: AdaptiveThemeColors.textPrimary(context),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPhotoCard(int index) {
    final hasPhoto = _hasPhotoAt(index);
    final storedPath = _photoPaths[index];

    return GestureDetector(
      onTap: () => hasPhoto ? null : _showImageSourceDialog(index),
      child: Container(
        decoration: BoxDecoration(
          color: AdaptiveThemeColors.backgroundSecondary(context),
          borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
          border: Border.all(
            color: AdaptiveThemeColors.borderLight(context),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AdaptiveThemeColors.neonCyan(
                context,
              ).withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
              child: hasPhoto
                  ? (_photos[index] != null
                        ? Image.file(
                            _photos[index]!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : FirebaseImage(
                            storedPath ?? '',
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ))
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 40,
                            color: AdaptiveThemeColors.textTertiary(context),
                          ),
                          SizedBox(height: AiSpacing.sm),
                          Text(
                            'Photo ${index + 1}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AdaptiveThemeColors.textTertiary(
                                    context,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
            ),
            if (hasPhoto)
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _showImageSourceDialog(index),
                      child: Container(
                        padding: EdgeInsets.all(AiSpacing.xs),
                        decoration: BoxDecoration(
                          color: AdaptiveThemeColors.neonCyan(context),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.edit,
                          size: 16,
                          color: AdaptiveThemeColors.surface(context),
                        ),
                      ),
                    ),
                    SizedBox(width: AiSpacing.xs),
                    GestureDetector(
                      onTap: () => _removePhoto(index),
                      child: Container(
                        padding: EdgeInsets.all(AiSpacing.xs),
                        decoration: BoxDecoration(
                          color: AdaptiveThemeColors.error(context),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: AdaptiveThemeColors.surface(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownQuestion(
    String label,
    String value,
    List<String> options,
    void Function(String?) onChanged,
    IconData icon,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: AiSpacing.lg),
      padding: EdgeInsets.all(AiSpacing.lg),
      decoration: BoxDecoration(
        color: AdaptiveThemeColors.backgroundSecondary(context),
        borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
        border: Border.all(
          color: AdaptiveThemeColors.borderLight(context),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: AdaptiveThemeColors.neonCyan(context),
              ),
              SizedBox(width: AiSpacing.sm),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AdaptiveThemeColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AiSpacing.md),
          Container(
            padding: EdgeInsets.symmetric(horizontal: AiSpacing.md),
            decoration: BoxDecoration(
              color: AdaptiveThemeColors.surface(context),
              borderRadius: BorderRadius.circular(AiSpacing.radiusMedium),
              border: Border.all(
                color: AdaptiveThemeColors.borderLight(context),
                width: 1,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: AdaptiveThemeColors.surface(context),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AdaptiveThemeColors.textPrimary(context),
                ),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: AdaptiveThemeColors.neonCyan(context),
                ),
                items: options.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchQuestion(
    String label,
    bool value,
    void Function(bool) onChanged,
    IconData icon,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: AiSpacing.lg),
      padding: EdgeInsets.all(AiSpacing.lg),
      decoration: BoxDecoration(
        color: AdaptiveThemeColors.backgroundSecondary(context),
        borderRadius: BorderRadius.circular(AiSpacing.radiusLarge),
        border: Border.all(
          color: AdaptiveThemeColors.borderLight(context),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AdaptiveThemeColors.neonCyan(context)),
          SizedBox(width: AiSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AdaptiveThemeColors.textPrimary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AdaptiveThemeColors.neonCyan(context),
            activeTrackColor: AdaptiveThemeColors.neonCyan(
              context,
            ).withValues(alpha: 0.5),
            inactiveThumbColor: AdaptiveThemeColors.textTertiary(context),
            inactiveTrackColor: AdaptiveThemeColors.borderLight(context),
          ),
        ],
      ),
    );
  }
}
