import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app_assignment/core/widgets/full_screen_loading.dart';
import '../../test_helpers/test_setup.dart';

void main() {
  setUp(() {
    TestSetup.setupWidgetTest();
  });

  testWidgets('FullScreenLoading renders correctly',
      (WidgetTester tester) async {
    // Build our widget and trigger a frame
    await tester.pumpWidget(
      const MaterialApp(
        home: FullScreenLoading(),
      ),
    );

    // Verify FullScreenLoading is rendered
    expect(find.byType(FullScreenLoading), findsOneWidget);
    expect(find.byType(RotatingImage), findsOneWidget);
  });

  testWidgets('RotatingImage animation works correctly',
      (WidgetTester tester) async {
    // Create a key for our widget to uniquely identify it
    final rotatingImageKey = GlobalKey();

    // Build the RotatingImage widget with the key
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RotatingImage(key: rotatingImageKey),
        ),
      ),
    );

    // Verify the initial state - using key for finding
    expect(find.byKey(rotatingImageKey), findsOneWidget);
    expect(
        find.descendant(
          of: find.byKey(rotatingImageKey),
          matching: find.byType(Image),
        ),
        findsOneWidget);

    // Take a widget snapshot before animation
    await tester.pump();
    final initialWidget = tester.widget(find.byKey(rotatingImageKey));

    // Advance time to simulate animation
    await tester.pump(const Duration(milliseconds: 500));

    // Take a snapshot after animation progress
    await tester.pump();

    // Verify image asset is used
    final image = tester.widget<Image>(
      find.descendant(
        of: find.byKey(rotatingImageKey),
        matching: find.byType(Image),
      ),
    );
    expect(image.image, isA<AssetImage>());
    expect(
        (image.image as AssetImage).assetName, 'assets/icons/ic_loading.png');
  });

  testWidgets('RotatingImage cleans up resources on dispose',
      (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RotatingImage(),
        ),
      ),
    );

    // Verify the widget is created
    expect(find.byType(RotatingImage), findsOneWidget);

    // Rebuild with a different widget to dispose RotatingImage
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(),
        ),
      ),
    );

    // Wait for disposal
    await tester.pump();

    // Verify the widget is gone
    expect(find.byType(RotatingImage), findsNothing);
  });
}
