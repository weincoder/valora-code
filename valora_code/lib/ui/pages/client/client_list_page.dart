import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/providers/client_provider.dart';
import '../../../config/routes/app_router.dart';
import '../../../config/theme/app_theme.dart';
import '../../../domain/models/client/client.dart';

class ClientListPage extends ConsumerWidget {
  const ClientListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clientProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRouter.clientNew),
        tooltip: 'Nuevo cliente',
        child: const Icon(Icons.person_add_outlined),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.clients.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: AppTheme.accentColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hay clientes registrados',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.clients.length,
              itemBuilder: (context, index) {
                final client = state.clients[index];
                return _ClientCard(
                  client: client,
                  onTap: () => context.push(
                    AppRouter.clientEdit.replaceFirst(':clientId', client.id),
                  ),
                );
              },
            ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback onTap;

  const _ClientCard({required this.client, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('client-card-${client.id}'),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: const Border(
              left: BorderSide(color: AppTheme.accentColor, width: 4),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildAvatar(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.fullName,
                        key: Key('client-name-${client.id}'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Doc: ${client.documentId}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        client.email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppTheme.accentColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (client.imageBase64 != null) {
      return ClipOval(
        child: Image.memory(
          base64Decode(client.imageBase64!),
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => _defaultAvatar(),
        ),
      );
    }
    return _defaultAvatar();
  }

  Widget _defaultAvatar() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.accentColor.withValues(alpha: 0.12),
      ),
      child: Center(
        child: Text(
          client.fullName.isNotEmpty ? client.fullName[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.accentColor,
          ),
        ),
      ),
    );
  }
}
