import 'package:material_ui/material_ui.dart';
import 'package:wiji_mobile/core/theme/wiji_colors.dart';
import 'package:wiji_mobile/core/theme/wiji_theme.dart';

// Tiga keadaan yang wajib ada di tiap halaman yang ngambil data:
// lagi loading, gagal, sama kosong. Pakai yang ini aja biar semua modul seragam.

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message = 'Lagi ngambil data...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(WijiSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: WijiColors.moss),
            const SizedBox(height: WijiSpacing.md),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});

  final String message;

  /// Kalau diisi, muncul tombol "Coba lagi".
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return _StateMessage(
      icon: Icons.cloud_off_outlined,
      iconColor: WijiColors.brick,
      iconBackground: WijiColors.brickBg,
      title: 'Gagal ngambil data',
      message: message,
      action: onRetry == null
          ? null
          : OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  final String title;
  final String message;
  final IconData icon;

  /// Tombol opsional, misalnya "Tambah lahan".
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return _StateMessage(
      icon: icon,
      iconColor: WijiColors.moss,
      iconBackground: WijiColors.leaf,
      title: title,
      message: message,
      action: action,
    );
  }
}

/// Tampilan dasar yang dipakai bareng sama ErrorView dan EmptyView.
class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Dibungkus scroll biar nggak kepotong pas layarnya pendek atau teksnya diperbesar.
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(WijiSpacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: iconBackground,
                child: Icon(icon, size: 32, color: iconColor),
              ),
              const SizedBox(height: WijiSpacing.md),
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: WijiSpacing.sm),
              Text(
                message,
                style: textTheme.bodyMedium?.copyWith(
                  color: WijiColors.inkSoft,
                ),
                textAlign: TextAlign.center,
              ),
              if (action != null) ...[
                const SizedBox(height: WijiSpacing.lg),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
