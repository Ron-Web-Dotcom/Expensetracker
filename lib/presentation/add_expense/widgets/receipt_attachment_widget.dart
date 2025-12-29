import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ReceiptAttachmentWidget extends StatelessWidget {
  final List<String> receiptPhotos;
  final ValueChanged<String> onReceiptAdded;
  final ValueChanged<String> onReceiptRemoved;
  final Function(Map<String, dynamic>)? onReceiptScanned;

  const ReceiptAttachmentWidget({
    super.key,
    required this.receiptPhotos,
    required this.onReceiptAdded,
    required this.onReceiptRemoved,
    this.onReceiptScanned,
  });

  Future<void> _addPhoto(BuildContext context, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        HapticFeedback.mediumImpact();
        onReceiptAdded(image.path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to add photo. Please try again.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _openReceiptCamera(BuildContext context) async {
    final result = await Navigator.pushNamed(context, '/receipt-camera');

    if (result != null && result is Map<String, dynamic>) {
      final imagePath = result['imagePath'] as String?;
      final extractedData = result['extractedData'] as Map<String, dynamic>?;

      if (imagePath != null) {
        HapticFeedback.mediumImpact();
        onReceiptAdded(imagePath);

        if (extractedData != null && onReceiptScanned != null) {
          onReceiptScanned!(extractedData);
        }
      }
    }
  }

  void _showPhotoOptions(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'document_scanner',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Scan Receipt (OCR)',
                style: theme.textTheme.bodyLarge,
              ),
              subtitle: Text(
                'Auto-extract expense details',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _openReceiptCamera(context);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'camera_alt',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Take Photo', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                _addPhoto(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'photo_library',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Choose from Gallery',
                style: theme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                _addPhoto(context, ImageSource.gallery);
              },
            ),
            SizedBox(height: 1.h),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Receipt',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.5.h),
        receiptPhotos.isEmpty
            ? InkWell(
                onTap: () => _showPhotoOptions(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 15.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'add_a_photo',
                          color: theme.colorScheme.primary,
                          size: 32,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Add Photo',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : SizedBox(
                height: 15.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: receiptPhotos.length + 1,
                  separatorBuilder: (context, index) => SizedBox(width: 3.w),
                  itemBuilder: (context, index) {
                    if (index == receiptPhotos.length) {
                      return InkWell(
                        onTap: () => _showPhotoOptions(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 15.h,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(
                                alpha: 0.3,
                              ),
                              width: 1,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Center(
                            child: CustomIconWidget(
                              iconName: 'add',
                              color: theme.colorScheme.primary,
                              size: 32,
                            ),
                          ),
                        ),
                      );
                    }

                    return Stack(
                      children: [
                        Container(
                          width: 15.h,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(
                                alpha: 0.3,
                              ),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CustomImageWidget(
                              imageUrl: receiptPhotos[index],
                              width: 15.h,
                              height: 15.h,
                              fit: BoxFit.cover,
                              semanticLabel: 'Receipt photo ${index + 1}',
                            ),
                          ),
                        ),
                        Positioned(
                          top: 1.w,
                          right: 1.w,
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              onReceiptRemoved(receiptPhotos[index]);
                            },
                            child: Container(
                              padding: EdgeInsets.all(1.w),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error,
                                shape: BoxShape.circle,
                              ),
                              child: CustomIconWidget(
                                iconName: 'close',
                                color: theme.colorScheme.onError,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
      ],
    );
  }
}
