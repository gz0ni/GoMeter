import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gometer/core/widgets/dropdown_pill.dart';
import 'package:gometer/core/widgets/limit_card.dart';
import 'package:gometer/core/widgets/phone_notif.dart';
import 'package:gometer/core/widgets/status_card.dart';
import 'package:gometer/core/theme/app_extra_colors.dart';
import 'package:gometer/features/usage/models/usage_limit.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('StatusCard renders label and status text', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const StatusCard(
          level: UsageLevel.amber,
          windowName: '7 дней',
          percent: 79,
          resetInSeconds: 3600,
        ),
      ),
    );

    expect(find.text('Почти у предела'), findsOneWidget);
    expect(
      find.textContaining(
        '7 дней · использовано 79% · окно в течение 1 ч 00 мин',
        findRichText: true,
      ),
      findsOneWidget,
    );
  });

  testWidgets('DropdownPill shows current value and menu', (tester) async {
    await tester.pumpWidget(
      _wrap(
        DropdownPill<int>(
          value: 5,
          items: const [
            DropdownPillItem(value: 1, label: '1 мин'),
            DropdownPillItem(value: 3, label: '3 мин'),
            DropdownPillItem(value: 5, label: '5 мин'),
          ],
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('5 мин'), findsOneWidget);

    await tester.tap(find.byType(DropdownPill<int>));
    await tester.pumpAndSettle();

    expect(find.text('1 мин'), findsOneWidget);
    expect(find.text('3 мин'), findsOneWidget);
  });

  testWidgets('PhoneNotif renders header and body', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const PhoneNotif(
          title: 'Лимит 80% · 5-часовое окно',
          text: 'Осталось 20%. Окно сбросится примерно через 47 минут.',
        ),
      ),
    );

    expect(find.text('GoMeter'), findsOneWidget);
    expect(find.text('Лимит 80% · 5-часовое окно'), findsOneWidget);
    expect(
      find.text('Осталось 20%. Окно сбросится примерно через 47 минут.'),
      findsOneWidget,
    );
  });

  testWidgets('LimitCard shows percent and remainder', (tester) async {
    await tester.pumpWidget(
      _wrap(
        LimitCard(
          limit: UsageLimit(
            id: 'weekly',
            name: '7 дней',
            window: 'Неделя',
            percent: 79,
          ),
        ),
      ),
    );

    expect(find.text('7 дней'), findsOneWidget);
    expect(find.textContaining('79%', findRichText: true), findsOneWidget);
    expect(find.text('осталось 21%'), findsOneWidget);
  });
}
