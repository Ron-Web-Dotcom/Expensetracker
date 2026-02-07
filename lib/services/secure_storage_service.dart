import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cryptography/cryptography.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Secure storage service for encrypting sensitive financial data
/// Uses AES-256-GCM encryption with flutter_secure_storage for key management
class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const String _encryptionKeyName = 'financial_data_encryption_key';
  static const String _ivKeyName = 'financial_data_iv';

  /// Initialize encryption keys (call once on app start)
  Future<void> initialize() async {
    try {
      // Check if encryption key exists
      final existingKey = await _secureStorage.read(key: _encryptionKeyName);
      if (existingKey == null) {
        // Generate new encryption key
        final algorithm = AesGcm.with256bits();
        final secretKey = await algorithm.newSecretKey();
        final keyBytes = await secretKey.extractBytes();

        // Store key securely
        await _secureStorage.write(
          key: _encryptionKeyName,
          value: base64Encode(keyBytes),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('SecureStorage initialization error: $e');
      }
    }
  }

  /// Encrypt and save sensitive data
  Future<void> saveEncrypted(String key, String value) async {
    try {
      final encryptedData = await _encryptData(value);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('encrypted_$key', encryptedData);
    } catch (e) {
      if (kDebugMode) {
        print('Encryption error for key $key: $e');
      }
      rethrow;
    }
  }

  /// Decrypt and retrieve sensitive data
  Future<String?> readEncrypted(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encryptedData = prefs.getString('encrypted_$key');

      if (encryptedData == null) return null;

      return await _decryptData(encryptedData);
    } catch (e) {
      if (kDebugMode) {
        print('Decryption error for key $key: $e');
      }
      return null;
    }
  }

  /// Remove encrypted data
  Future<void> removeEncrypted(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('encrypted_$key');
  }

  /// Clear all encryption keys (use with caution)
  Future<void> clearAllKeys() async {
    await _secureStorage.delete(key: _encryptionKeyName);
    await _secureStorage.delete(key: _ivKeyName);
  }

  // Private encryption methods
  Future<String> _encryptData(String plaintext) async {
    final algorithm = AesGcm.with256bits();

    // Retrieve encryption key
    final keyString = await _secureStorage.read(key: _encryptionKeyName);
    if (keyString == null) {
      throw Exception('Encryption key not found');
    }

    final keyBytes = base64Decode(keyString);
    final secretKey = SecretKey(keyBytes);

    // Encrypt data
    final secretBox = await algorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: secretKey,
    );

    // Combine nonce + ciphertext + mac for storage
    final combined = [
      ...secretBox.nonce,
      ...secretBox.cipherText,
      ...secretBox.mac.bytes,
    ];

    return base64Encode(combined);
  }

  Future<String> _decryptData(String encrypted) async {
    final algorithm = AesGcm.with256bits();

    // Retrieve encryption key
    final keyString = await _secureStorage.read(key: _encryptionKeyName);
    if (keyString == null) {
      throw Exception('Encryption key not found');
    }

    final keyBytes = base64Decode(keyString);
    final secretKey = SecretKey(keyBytes);

    // Decode combined data
    final combined = base64Decode(encrypted);

    // Extract nonce (12 bytes), ciphertext, and MAC (16 bytes)
    final nonce = combined.sublist(0, 12);
    final mac = combined.sublist(combined.length - 16);
    final cipherText = combined.sublist(12, combined.length - 16);

    // Decrypt data
    final secretBox = SecretBox(cipherText, nonce: nonce, mac: Mac(mac));

    final decrypted = await algorithm.decrypt(secretBox, secretKey: secretKey);

    return utf8.decode(decrypted);
  }
}
