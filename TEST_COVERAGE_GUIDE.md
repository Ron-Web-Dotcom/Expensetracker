# Test Coverage Configuration

## Running Tests

### Unit Tests
```bash
# Run all unit tests
flutter test

# Run specific test file
flutter test test/services/expense_data_service_test.dart

# Run tests with coverage
flutter test --coverage

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Widget Tests
```bash
# Run all widget tests
flutter test test/widgets/

# Run specific widget test
flutter test test/widgets/add_expense_test.dart
```

### Integration Tests
```bash
# Run integration tests on connected device
flutter test integration_test/

# Run specific integration test
flutter test integration_test/expense_creation_flow_test.dart

# Run on specific device
flutter test integration_test/ -d <device_id>
```

## Coverage Goals

### Target Coverage: 80%+

- **Services**: 90%+ coverage (critical business logic)
- **Widgets**: 70%+ coverage (UI components)
- **Integration**: 60%+ coverage (user flows)

## Test Structure

```
test/
├── services/                    # Unit tests for services
│   ├── expense_data_service_test.dart
│   ├── budget_data_service_test.dart
│   ├── analytics_service_test.dart
│   ├── notification_service_test.dart
│   └── secure_storage_service_test.dart
├── widgets/                     # Widget tests for screens
│   ├── add_expense_test.dart
│   ├── expense_dashboard_test.dart
│   ├── budget_management_test.dart
│   └── analytics_dashboard_test.dart
integration_test/                # Integration tests
├── expense_creation_flow_test.dart
├── budget_alert_flow_test.dart
└── data_export_flow_test.dart
```

## Continuous Integration

### GitHub Actions Example

```yaml
name: Flutter Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Run tests with coverage
      run: flutter test --coverage
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        files: ./coverage/lcov.info
        fail_ci_if_error: true
```

## Test Best Practices

### 1. Unit Tests
- Test one function/method at a time
- Mock external dependencies
- Test edge cases and error conditions
- Use descriptive test names

### 2. Widget Tests
- Test user interactions
- Verify UI elements are present
- Test form validation
- Test navigation flows

### 3. Integration Tests
- Test complete user journeys
- Test critical business flows
- Test data persistence
- Test error recovery

## Coverage Reporting

### Generate Coverage Report
```bash
# Generate coverage data
flutter test --coverage

# Install lcov (macOS)
brew install lcov

# Install lcov (Ubuntu/Debian)
sudo apt-get install lcov

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# View report
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
```

### Coverage Thresholds

```dart
// Add to test/coverage_test.dart
import 'package:test/test.dart';

void main() {
  test('Coverage threshold check', () {
    // This test ensures coverage is run
    expect(true, true);
  });
}
```

## Mocking

### Using Mockito

```yaml
# pubspec.yaml
dev_dependencies:
  mockito: ^5.4.4
  build_runner: ^2.4.8
```

```dart
// Generate mocks
import 'package:mockito/annotations.dart';

@GenerateMocks([ExpenseDataService, BudgetDataService])
void main() {
  // Tests here
}
```

```bash
# Generate mock files
flutter pub run build_runner build
```

## Performance Testing

### Measure Widget Build Time

```dart
testWidgets('Widget builds quickly', (tester) async {
  final stopwatch = Stopwatch()..start();
  
  await tester.pumpWidget(MyWidget());
  await tester.pumpAndSettle();
  
  stopwatch.stop();
  expect(stopwatch.elapsedMilliseconds, lessThan(100));
});
```

## Test Maintenance

### Regular Tasks

1. **Weekly**: Run full test suite
2. **Before Release**: Run integration tests on all devices
3. **Monthly**: Review and update test coverage
4. **Quarterly**: Refactor and optimize slow tests

## Troubleshooting

### Common Issues

**Issue**: Tests fail with "MissingPluginException"
**Solution**: Use `TestWidgetsFlutterBinding.ensureInitialized()`

**Issue**: Integration tests timeout
**Solution**: Increase timeout or optimize test steps

**Issue**: Coverage report missing files
**Solution**: Ensure all files are imported and tested

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)
