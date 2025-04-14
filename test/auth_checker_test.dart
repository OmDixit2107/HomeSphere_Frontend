import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesphere/main.dart';
import 'package:homesphere/pages/property_owner/PropertyOwnerHome.dart';
import 'package:homesphere/pages/user/UserHome.dart';
import 'package:homesphere/auth/login.dart';
import 'package:provider/provider.dart';
import 'package:homesphere/providers/ChatProvider.dart';
import 'package:homesphere/providers/PropertyProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthChecker Tests', () {
    // Helper function to build widget under test
    Widget createWidgetUnderTest() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ChatProvider()),
          ChangeNotifierProvider(create: (_) => PropertyProvider()),
        ],
        child: MaterialApp(
          home: AuthChecker(),
        ),
      );
    }

    testWidgets('AuthChecker shows loading indicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Verify that a CircularProgressIndicator is shown during loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AuthChecker navigates to LoginScreen when no role is found', (WidgetTester tester) async {
      // Set up mock SharedPreferences
      SharedPreferences.setMockInitialValues({
        'userRole': '',
      });
      
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Wait for the Future to complete
      await tester.pumpAndSettle();
      
      // Verify that LoginScreen is shown
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('AuthChecker navigates to UserHome for User role', (WidgetTester tester) async {
      // Set up mock SharedPreferences
      SharedPreferences.setMockInitialValues({
        'userRole': 'User',
        'user_id': 1,
      });
      
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Wait for the Future to complete
      await tester.pumpAndSettle();
      
      // Verify that UserHome is shown
      expect(find.byType(UserHome), findsOneWidget);
    });

    testWidgets('AuthChecker navigates to PropertyOwnerHome for Property Owner role', (WidgetTester tester) async {
      // Set up mock SharedPreferences
      SharedPreferences.setMockInitialValues({
        'userRole': 'Property Owner',
        'user_id': 2,
      });
      
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Wait for the Future to complete
      await tester.pumpAndSettle();
      
      // Verify that PropertyOwnerHome is shown
      expect(find.byType(PropertyOwnerHome), findsOneWidget);
    });

    test('getUserRole returns correct role from SharedPreferences', () async {
      // Set up mock SharedPreferences
      SharedPreferences.setMockInitialValues({
        'userRole': 'Test Role',
      });
      
      // Call the function
      final role = await getUserRole();
      
      // Verify the result
      expect(role, equals('Test Role'));
    });

    test('getUserRole returns empty string when no role is found', () async {
      // Set up mock SharedPreferences without a role
      SharedPreferences.setMockInitialValues({});
      
      // Call the function
      final role = await getUserRole();
      
      // Verify the result
      expect(role, equals(''));
    });
  });
} 