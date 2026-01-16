import 'package:flutter_test/flutter_test.dart';
import 'package:house_renting/main.dart';

void main() {
  testWidgets('Auth screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the AuthScreen is displayed
    expect(find.text('Tenant'), findsOneWidget);
    expect(find.text('Landlord'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget); // Initial state is Login
  });
}
