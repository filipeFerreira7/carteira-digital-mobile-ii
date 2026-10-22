import 'package:flutter_test/flutter_test.dart';
import 'package:carteira_digital/main.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CarteiraApp(isLoggedIn: false));

    expect(find.text('Acesse sua carteira digital'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
