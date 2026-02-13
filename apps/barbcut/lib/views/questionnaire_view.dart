import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../theme/theme.dart';

class QuestionnaireView extends StatefulWidget {
  const QuestionnaireView({super.key});

  @override
  State<QuestionnaireView> createState() => _QuestionnaireViewState();
}

class _QuestionnaireViewState extends State<QuestionnaireView> {
  final ImagePicker _picker = ImagePicker();
  final List<File?> _photos = [null, null, null, null];

  // Questionnaire answers
  String _hairType = 'Straight';
  String _faceShape = 'Oval';
  String _preferredLength = 'Medium';
  bool _hasBeard = false;
  String _beardStyle = 'None';
  String _lifestyle = 'Active';

  final List<String> _hairTypes = ['Straight', 'Wavy', 'Curly', 'Coily'];
  final List<String> _faceShapes = [
    'Oval',
    'Round',
    'Square',
    'Heart',
    'Diamond',
    'Oblong',
  ];
  final List<String> _preferredLengths = ['Short', 'Medium', 'Long'];
  final List<String> _beardStyles = [
    'None',
    'Full Beard',
    'Goatee',
    'Stubble',
    'Mustache',
    'Van Dyke',
  ];
  final List<String> _lifestyles = [
    'Active',
    'Professional',
    'Casual',
    'Sporty',
  ];

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
    });
  }

  void _saveProfile() {
    // TODO: Implement saving to Firestore
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile saved successfully!'),
        backgroundColor: AdaptiveThemeColors.neonCyan(context),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdaptiveThemeColors.backgroundDeep(context),
      appBar: AppBar(
        backgroundColor: AdaptiveThemeColors.backgroundDark(context),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: AdaptiveThemeColors.textPrimary(context),
        ),
        title: Text(
          'My Profile & Photos',
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
          _buildSectionTitle('Your Photos'),
          SizedBox(height: AiSpacing.md),
          Text(
            'Upload 4 photos of your current hairstyle from different angles',
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
            itemCount: 4,
            itemBuilder: (context, index) {
              return _buildPhotoCard(index);
            },
          ),

          SizedBox(height: AiSpacing.xxxl),

          // Questionnaire Section
          _buildSectionTitle('Style Preferences'),
          SizedBox(height: AiSpacing.lg),

          _buildDropdownQuestion(
            'Hair Type',
            _hairType,
            _hairTypes,
            (value) => setState(() => _hairType = value!),
            Icons.waves,
          ),

          _buildDropdownQuestion(
            'Face Shape',
            _faceShape,
            _faceShapes,
            (value) => setState(() => _faceShape = value!),
            Icons.face,
          ),

          _buildDropdownQuestion(
            'Preferred Length',
            _preferredLength,
            _preferredLengths,
            (value) => setState(() => _preferredLength = value!),
            Icons.straighten,
          ),

          _buildSwitchQuestion(
            'Do you have a beard?',
            _hasBeard,
            (value) => setState(() {
              _hasBeard = value;
              if (!value) _beardStyle = 'None';
            }),
            Icons.face_retouching_natural,
          ),

          if (_hasBeard)
            _buildDropdownQuestion(
              'Beard Style',
              _beardStyle,
              _beardStyles.where((s) => s != 'None').toList(),
              (value) => setState(() => _beardStyle = value!),
              Icons.face_retouching_natural,
            ),

          _buildDropdownQuestion(
            'Lifestyle',
            _lifestyle,
            _lifestyles,
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
              onPressed: _saveProfile,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save, size: 20),
                  SizedBox(width: AiSpacing.sm),
                  Text(
                    'Save Profile',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
    final hasPhoto = _photos[index] != null;

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
                  ? Image.file(
                      _photos[index]!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    )
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
