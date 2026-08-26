import 'package:flutter/widgets.dart';

const double desktopMinWidth = 600;
const double desktopContentMaxWidth = 640;

bool isDesktopLayout(BuildContext context) {
  return MediaQuery.sizeOf(context).width >= desktopMinWidth;
}

class DesktopNarrow extends StatelessWidget {
  final Widget child;

  const DesktopNarrow({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!isDesktopLayout(context)) return child;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: desktopContentMaxWidth),
        child: child,
      ),
    );
  }
}
