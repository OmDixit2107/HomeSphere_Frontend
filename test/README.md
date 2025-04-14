# HomeSphere App Tests

This directory contains test files for the HomeSphere app. These tests cover models, providers, services, and UI components.

## Test Files

### Model Tests
- `user_model_test.dart` - Tests for the User model serialization and deserialization
- `property_model_test.dart` - Tests for the Property model serialization and deserialization
- `chat_message_test.dart` - Tests for the ChatMessage model serialization and deserialization

### Provider Tests
- `chat_provider_test.dart` - Tests for the ChatProvider class
- `property_provider_test.dart` - Tests for the PropertyProvider class

### Service Tests
- `user_api_test.dart` - Tests for the UserAPI service
- `chat_websocket_test.dart` - Tests for the ChatWebSocket service

### UI Tests
- `auth_checker_test.dart` - Tests for the AuthChecker component
- `widget_test.dart` - Basic widget tests

## Running Tests

### Running All Tests

To run all tests, use the following command:

```bash
flutter test
```

### Running Specific Tests

To run a specific test file, use:

```bash
flutter test test/filename_test.dart
```

For example:

```bash
flutter test test/user_model_test.dart
```

### Run Tests with Coverage

To run tests with coverage, use:

```bash
flutter test --coverage
```

This generates a `coverage/lcov.info` file. You can then generate an HTML report:

```bash
genhtml coverage/lcov.info -o coverage/html
```

## Test Dependencies

The tests use the following packages:

- `flutter_test` - Flutter's testing framework
- `mockito` - For creating mock objects
- `http` - For making HTTP requests
- `http/testing.dart` - For mocking HTTP requests

## Notes for Test Implementation

1. Some tests are commented out as they require modifications to the implementation classes to allow for proper dependency injection.
2. For better testing, consider:
   - Adding interfaces for services that can be mocked
   - Using dependency injection to provide mock implementations
   - Making private methods protected or internal for testing
   - Adding test-only constructors or factory methods

## Test Organization

- Each test file focuses on a specific component
- Tests are grouped logically
- Setup is performed in the `setUp` method
- Test data is initialized in the setup
- Each test verifies a specific behavior or functionality 