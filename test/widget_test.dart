import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cooksy_flutter/main.dart';
import 'package:cooksy_flutter/providers/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CooksyApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppState()),
        ],
        child: const CooksyApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('What are we cooking?'), findsOneWidget);
  });
}


