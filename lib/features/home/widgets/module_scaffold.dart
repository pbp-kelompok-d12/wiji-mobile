import 'package:material_ui/material_ui.dart';
import 'package:wiji_mobile/features/home/menu.dart';
import 'package:wiji_mobile/features/home/widgets/app_drawer.dart';

/// Kerangka halaman utama tiap modul: judul AppBar sama drawer udah nyambung,
/// tinggal isi [body]. Halaman detail atau form nggak perlu pakai ini.
class ModuleScaffold extends StatelessWidget {
  const ModuleScaffold({
    super.key,
    required this.menu,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  final WijiMenu menu;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(menu.label), actions: actions),
      drawer: AppDrawer(current: menu),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
