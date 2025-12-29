import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../services/ocr_service.dart';

/// Receipt camera capture screen with OCR processing
class ReceiptCameraScreen extends StatefulWidget {
  const ReceiptCameraScreen({super.key});

  @override
  State<ReceiptCameraScreen> createState() => _ReceiptCameraScreenState();
}

class _ReceiptCameraScreenState extends State<ReceiptCameraScreen> {
  final ImagePicker _picker = ImagePicker();
  final OcrService _ocrService = OcrService();

  String? _capturedImagePath;
  bool _isProcessing = false;
  Map<String, dynamic>? _extractedData;

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;

    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _captureReceipt() async {
    try {
      final hasPermission = await _requestCameraPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Camera permission is required to capture receipts',
              ),
            ),
          );
        }
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _capturedImagePath = image.path;
          _isProcessing = true;
        });

        HapticFeedback.mediumImpact();

        // Process image with OCR
        final extractedData = await _ocrService.extractReceiptData(image.path);

        setState(() {
          _extractedData = extractedData;
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture receipt: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _selectFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _capturedImagePath = image.path;
          _isProcessing = true;
        });

        HapticFeedback.mediumImpact();

        // Process image with OCR
        final extractedData = await _ocrService.extractReceiptData(image.path);

        setState(() {
          _extractedData = extractedData;
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select image: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedImagePath = null;
      _extractedData = null;
      _isProcessing = false;
    });
  }

  void _useReceipt() {
    if (_capturedImagePath != null) {
      Navigator.pop(context, {
        'imagePath': _capturedImagePath,
        'extractedData': _extractedData,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.expenseDashboard,
              (route) => false,
            );
          },
        ),
        title: Text(
          'Scan Receipt',
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
      ),
      body: _capturedImagePath == null
          ? _buildCaptureView(theme)
          : _buildPreviewView(theme),
    );
  }

  Widget _buildCaptureView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'receipt_long',
            color: Colors.white,
            size: 80,
          ),
          SizedBox(height: 3.h),
          Text(
            'Capture Your Receipt',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Text(
              'Take a clear photo of your receipt to automatically extract expense details',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 5.h),
          ElevatedButton.icon(
            onPressed: _captureReceipt,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take Photo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          TextButton.icon(
            onPressed: _selectFromGallery,
            icon: const Icon(Icons.photo_library, color: Colors.white70),
            label: Text(
              'Choose from Gallery',
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewView(ThemeData theme) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Center(
                child: Image.file(
                  File(_capturedImagePath!),
                  fit: BoxFit.contain,
                ),
              ),
              if (_isProcessing)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 2.h),
                        Text(
                          'Processing receipt...',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        Container(
          color: Colors.black87,
          padding: EdgeInsets.all(4.w),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                if (_extractedData != null && !_isProcessing)
                  _buildExtractedDataPreview(theme),
                if (_extractedData != null && !_isProcessing)
                  SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _retakePhoto,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Retake'),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _useReceipt,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Use Receipt'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExtractedDataPreview(ThemeData theme) {
    final amount = _extractedData?['amount'];
    final merchant = _extractedData?['merchant'];
    final date = _extractedData?['date'];

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Extracted Data:',
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          if (amount != null)
            Text(
              'Amount: \$${amount.toStringAsFixed(2)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
          if (merchant != null)
            Text(
              'Merchant: $merchant',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
          if (date != null)
            Text(
              'Date: ${date.toString().split(' ')[0]}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
          if (amount == null && merchant == null && date == null)
            Text(
              'No data extracted. You can still add the receipt photo.',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
            ),
        ],
      ),
    );
  }
}
