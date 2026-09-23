import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

/// Ensures the modal sheet works inside an app built with `package:material_ui`.
///
/// When the package imported the SDK's `package:flutter/material.dart`, the
/// `Material`, `Theme`, `MaterialLocalizations` and `ScaffoldMessenger` types
/// inside the modal did not match the ones provided by a `material_ui` app.
void main() {
  const customBackgroundColor = Color(0xFF123456);
  const pageText = 'material_ui page';
  const snackBarText = 'Snack from modal';

  Widget buildApp() {
    return MaterialApp(
      theme: ThemeData(
        extensions: const [
          WoltModalSheetThemeData(backgroundColor: customBackgroundColor),
        ],
      ),
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  WoltModalSheet.show(
                    context: context,
                    pageListBuilder: (_) => [
                      WoltModalSheetPage(
                        child: Builder(
                          builder: (context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(pageText),
                                Text(MaterialLocalizations.of(context)
                                    .closeButtonLabel),
                                const TextField(),
                                ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(snackBarText)),
                                    );
                                  },
                                  child: const Text('Show snack'),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
                child: const Text('Open sheet'),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> openSheet(WidgetTester tester) async {
    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();
  }

  testWidgets('material_ui widgets inside the sheet find a Material ancestor',
      (tester) async {
    await openSheet(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('MaterialLocalizations resolve inside the sheet', (tester) async {
    await openSheet(tester);

    expect(
      find.text(const DefaultMaterialLocalizations().closeButtonLabel),
      findsOneWidget,
    );
  });

  testWidgets('WoltModalSheetThemeData from the material_ui theme is applied',
      (tester) async {
    await openSheet(tester);

    final Material sheetMaterial = tester.widget(find
        .ancestor(of: find.text(pageText), matching: find.byType(Material))
        .first);
    expect(sheetMaterial.color, customBackgroundColor);
  });

  testWidgets('SnackBar shown from inside the sheet appears in the sheet',
      (tester) async {
    await openSheet(tester);

    await tester.tap(find.text('Show snack'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.descendant(
        of: find.byType(WoltModalSheet),
        matching: find.text(snackBarText),
      ),
      findsOneWidget,
    );
  });
}
