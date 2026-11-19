import 'package:material_ui/material_ui.dart';
import 'package:wiji_mobile/core/theme/wiji_theme.dart';
import 'package:wiji_mobile/features/home/screens/home_screen.dart';

void main() {
  runApp(const WijiApp());
}

class WijiApp extends StatelessWidget {
  const WijiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wiji',
      debugShowCheckedModeBanner: false,
      theme: WijiTheme.light,
      home: const HomeScreen(),
    );
  }
}
