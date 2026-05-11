import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/providers/friend_provider.dart';
import '../../../config/routes/app_router.dart';
import '../../../config/theme/app_theme.dart';
import '../../../domain/models/friend/friend.dart';
import '../../widgets/invoice/currency_format_helper.dart';
import '../../widgets/owl_mascot.dart';
import '../../widgets/retro_background.dart';

class FriendListPage extends ConsumerWidget {
  const FriendListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(friendProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Amigos',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'friend-list-fab',
        onPressed: () => context.push(AppRouter.friendNew),
        tooltip: 'Agregar amigo',
        child: const Icon(Icons.person_add_outlined),
      ),
      body: RetroBackground(
        child: Builder(
          builder: (_) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.friends.isEmpty) {
              return Center(
                child: OwlMascot(
                  scenario: OwlScenario.empty,
                  size: 160,
                  label: 'Sin amigos aún.\nPresiona + para agregar uno.',
                ),
              );
            }

            return Column(
              children: [
                // ── Encabezado con búho pequeño ──────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      const OwlMascot(scenario: OwlScenario.working, size: 56),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${state.friends.length} amigo${state.friends.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Toca una tarjeta para editar',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppTheme.cardBorder, height: 1),
                // ── Lista de tarjetas ─────────────────────────────────────
                Expanded(
                  child: ListView.builder(
                    key: const Key('friend-list'),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: state.friends.length,
                    itemBuilder: (context, index) {
                      final friend = state.friends[index];
                      return _FriendCard(
                        friend: friend,
                        onTap: () => context.push(
                          AppRouter.friendEdit.replaceFirst(
                            ':friendId',
                            friend.id,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Card de amigo ──────────────────────────────────────────────────────────────

class _FriendCard extends StatelessWidget {
  final Friend friend;
  final VoidCallback onTap;

  const _FriendCard({required this.friend, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('friend-card-${friend.id}'),
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
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Avatar ───────────────────────────────────────────────
              _FriendAvatar(friend: friend),
              const SizedBox(width: 12),
              // ── Info del amigo ────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.fullName,
                      key: Key('friend-name-${friend.id}'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (friend.knowledgeAreas.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _KnowledgeChips(areas: friend.knowledgeAreas),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      formatCurrency(friend.hourlyRate, friend.currency),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppTheme.accentColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FriendAvatar extends StatelessWidget {
  final Friend friend;

  const _FriendAvatar({required this.friend});

  @override
  Widget build(BuildContext context) {
    final imageBase64 = friend.imageBase64;
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      final Uint8List bytes = base64Decode(imageBase64);
      return ClipOval(
        child: Image.memory(bytes, width: 48, height: 48, fit: BoxFit.cover),
      );
    }
    final initial = friend.fullName.trim().isNotEmpty
        ? friend.fullName.trim()[0].toUpperCase()
        : '?';
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppTheme.accentColor.withValues(alpha: 0.2),
      child: Text(
        initial,
        style: const TextStyle(
          color: AppTheme.accentColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}

class _KnowledgeChips extends StatelessWidget {
  final List<String> areas;

  const _KnowledgeChips({required this.areas});

  @override
  Widget build(BuildContext context) {
    const maxVisible = 3;
    final visible = areas.take(maxVisible).toList();
    final extra = areas.length - maxVisible;

    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: [
        ...visible.map(
          (area) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.accentColor.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              area,
              style: const TextStyle(fontSize: 11, color: AppTheme.accentColor),
            ),
          ),
        ),
        if (extra > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.textSecondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '+$extra más',
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}
