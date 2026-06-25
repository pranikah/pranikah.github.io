import 'package:flutter_test/flutter_test.dart';
import 'package:pra_nikah_app/main.dart';

void main() {
  testWidgets('App launches', (tester) async {
    await tester.pumpWidget(const PraNikahApp(showOnboarding: false));
  });
}
