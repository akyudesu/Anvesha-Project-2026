import 'package:flutter/material.dart';

class DashboardTopBar extends StatelessWidget {
  const DashboardTopBar({
    super.key,
    required this.showMenuIcon,
    required this.onRefresh,
    required this.onSignOut,
  });

  final bool showMenuIcon;
  final VoidCallback onRefresh;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(color: colors.onSurface.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
          if (showMenuIcon) ...[
            Builder(
              builder: (context) => IconButton(
                tooltip: 'Open navigation menu',
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu_rounded),
              ),
            ),
            const SizedBox(width: 14),
          ],
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'School safety network',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 3),
                Text(
                  'Fire evacuation command center',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Color(0xFF8A9AAD)),
                ),
              ],
            ),
          ),
          if (!showMenuIcon) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF55C987).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.circle, size: 8, color: Color(0xFF55C987)),
                  SizedBox(width: 8),
                  Text(
                    'LIVE',
                    style: TextStyle(
                      color: Color(0xFF55C987),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],
          IconButton(
            tooltip: 'Refresh dashboard',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
          if (showMenuIcon)
            PopupMenuButton<String>(
              tooltip: 'Account options',
              onSelected: (_) => onSignOut(),
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'signout', child: Text('Sign out')),
              ],
              icon: const Icon(Icons.account_circle_outlined),
            )
          else ...[
            CircleAvatar(
              radius: 18,
              backgroundColor: colors.primary.withValues(alpha: 0.14),
              child: Icon(
                Icons.person_outline,
                color: colors.primary,
                size: 20,
              ),
            ),
            IconButton(
              tooltip: 'Sign out',
              onPressed: onSignOut,
              icon: const Icon(Icons.logout_rounded),
            ),
          ],
        ],
      ),
    );
  }
}
