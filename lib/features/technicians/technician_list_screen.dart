import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import 'technicians_provider.dart';

class TechnicianListScreen extends ConsumerWidget {
  const TechnicianListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final techsAsync = ref.watch(techniciansProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Technicians'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () =>
              context.push('/records/technicians/new'),
          child: const Icon(CupertinoIcons.add, size: 22),
        ),
      ),
      child: SafeArea(
        child: techsAsync.when(
          loading: () =>
              const Center(child: CupertinoActivityIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (techs) {
            if (techs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.person_badge_plus_fill,
                          size: 48, color: Color(0xFFC7C7CC)),
                      const SizedBox(height: 16),
                      const Text(
                        'No technicians yet.',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3A3A3C),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tap + to add your first technician.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14, color: Color(0xFF8E8E93)),
                      ),
                      const SizedBox(height: 24),
                      // Add button using list-row style
                      GestureDetector(
                        onTap: () =>
                            context.push('/records/technicians/new'),
                        child: Container(
                          color: CupertinoColors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(CupertinoIcons.add,
                                  size: 18, color: Color(0xFF007AFF)),
                              SizedBox(width: 10),
                              Text('Add Technician',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF007AFF))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return CupertinoScrollbar(
              child: ListView.builder(
              itemCount: techs.length,
              itemBuilder: (context, index) {
                final tech = techs[index];
                return _TechRow(
                  tech: tech,
                  onTap: () => context.push(
                      '/records/technicians/${tech.id}/edit'),
                  showDivider: index < techs.length - 1,
                );
              },
            ));
          },
        ),
      ),
    );
  }
}

class _TechRow extends StatelessWidget {
  final Technician tech;
  final VoidCallback onTap;
  final bool showDivider;

  const _TechRow({
    required this.tech,
    required this.onTap,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
          onTap: onTap,
          child: Container(
            color: CupertinoColors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                // Avatar circle with initials
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE5E5EA),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      tech.name.isNotEmpty
                          ? tech.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3A3A3C),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tech.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                      if (tech.specialty != null &&
                          tech.specialty!.isNotEmpty)
                        Text(
                          tech.specialty!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8E8E93),
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(CupertinoIcons.chevron_right,
                    size: 16, color: Color(0xFFC7C7CC)),
              ],
            ),
          ),
        ),
        ),
        if (showDivider)
          Container(
            height: 0.5,
            color: const Color(0xFFE5E5EA),
            margin: const EdgeInsets.only(left: 64),
          ),
      ],
    );
  }
}
