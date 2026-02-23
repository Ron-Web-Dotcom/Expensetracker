import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expensetracker/services/secure_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecureStorageService Tests', () {
    late SecureStorageService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = SecureStorageService();
    });

    test('saveEncrypted and readEncrypted should work correctly', () async {
      const testData = '{"test": "data", "amount": 100}';
      const key = 'test_key';

      await service.saveEncrypted(key, testData);
      final retrieved = await service.readEncrypted(key);

      expect(retrieved, testData);
    });

    test('readEncrypted should return null for non-existent key', () async {
      final result = await service.readEncrypted('non_existent_key');
      expect(result, isNull);
    });

    test('deleteEncrypted should remove data', () async {
      const testData = 'test data';
      const key = 'test_key';

      await service.saveEncrypted(key, testData);
      await service.deleteEncrypted(key);

      final retrieved = await service.readEncrypted(key);
      expect(retrieved, isNull);
    });

    test('should handle empty string', () async {
      const key = 'empty_key';
      await service.saveEncrypted(key, '');

      final retrieved = await service.readEncrypted(key);
      expect(retrieved, '');
    });

    test('should handle large data', () async {
      final largeData = List.generate(1000, (i) => 'item_$i').join(',');
      const key = 'large_data_key';

      await service.saveEncrypted(key, largeData);
      final retrieved = await service.readEncrypted(key);

      expect(retrieved, largeData);
    });

    test('should handle special characters', () async {
      const specialData =
          '{"emoji": "🎉", "symbols": "@#\$%^&*()", "unicode": "你好"}';
      const key = 'special_key';

      await service.saveEncrypted(key, specialData);
      final retrieved = await service.readEncrypted(key);

      expect(retrieved, specialData);
    });

    test('clearAll should remove all encrypted data', () async {
      await service.saveEncrypted('key1', 'data1');
      await service.saveEncrypted('key2', 'data2');
      await service.saveEncrypted('key3', 'data3');

      await service.clearAll();

      final result1 = await service.readEncrypted('key1');
      final result2 = await service.readEncrypted('key2');
      final result3 = await service.readEncrypted('key3');

      expect(result1, isNull);
      expect(result2, isNull);
      expect(result3, isNull);
    });
  });
}
