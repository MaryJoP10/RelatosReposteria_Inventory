import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relatos/app/app.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Relatos shell shows brand and dashboard metrics', (tester) async {
    await tester.pumpWidget(const RelatosApp());
    await tester.pump();

    expect(find.text('Relatos'), findsWidgets);
    expect(find.text('Repostería'), findsOneWidget);
    expect(find.text('Ventas'), findsWidgets);
    expect(find.text('Gastos'), findsWidgets);
    expect(find.text('Ganancia'), findsOneWidget);
  });
}
