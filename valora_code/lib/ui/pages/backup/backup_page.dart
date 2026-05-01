import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/providers/backup_provider.dart';
import '../../../config/theme/app_theme.dart';
import '../../widgets/retro_background.dart';

class BackupPage extends ConsumerWidget {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(backupProvider);
    final notifier = ref.read(backupProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Backup')),
      body: RetroBackground(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SectionHeader(
                icon: Icons.cloud_upload,
                title: 'Exportar respaldo',
                subtitle: 'Descarga todos tus productos en un archivo JSON',
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                key: const Key('export-backup-button'),
                onPressed: state.isExporting
                    ? null
                    : () async {
                        RenderBox? box;
                        final ctx = context;
                        if (ctx.mounted) {
                          box = ctx.findRenderObject() as RenderBox?;
                        }
                        final origin = box != null
                            ? box.localToGlobal(Offset.zero) & box.size
                            : null;
                        await notifier.export(sharePositionOrigin: origin);
                        if (ctx.mounted && state.error == null) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                              content: Text('Backup exportado exitosamente'),
                            ),
                          );
                        }
                      },
                icon: const Icon(Icons.upload_file),
                label: const Text('Exportar backup'),
              ),
              if (state.lastBackup != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Último backup: ${_formatDate(state.lastBackup!)}',
                  key: const Key('last-backup-date'),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              const _SectionHeader(
                icon: Icons.cloud_download,
                title: 'Importar respaldo',
                subtitle:
                    'Restaura tus datos desde un archivo JSON exportado anteriormente',
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                key: const Key('import-backup-button'),
                onPressed: state.isImporting
                    ? null
                    : () async {
                        final ctx = context;
                        final confirm = await showDialog<bool>(
                          context: ctx,
                          builder: (dialogCtx) => AlertDialog(
                            title: const Text('Restaurar backup'),
                            content: const Text(
                              'Esta acción reemplazará TODOS tus datos actuales con los del archivo. ¿Continuar?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogCtx, false),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(dialogCtx, true),
                                child: const Text('Restaurar'),
                              ),
                            ],
                          ),
                        );
                        if (confirm != true) return;
                        await notifier.import();
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(
                              content: Text(
                                state.error ?? 'Backup importado exitosamente',
                              ),
                            ),
                          );
                        }
                      },
                icon: const Icon(Icons.download),
                label: const Text('Importar backup'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.accentColor),
                  foregroundColor: AppTheme.accentColor,
                ),
              ),
              if (state.isExporting || state.isImporting) ...[
                const SizedBox(height: 24),
                const Center(
                  child: CircularProgressIndicator(
                    key: Key('backup-loading-indicator'),
                  ),
                ),
              ],
              if (state.error != null) ...[
                const SizedBox(height: 16),
                Text(
                  state.error!,
                  key: const Key('backup-error-text'),
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.accentColor, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
