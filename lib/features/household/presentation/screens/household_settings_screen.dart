import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/features/auth/domain/user_model.dart';
import 'package:homely/features/household/models/household_model.dart';
import 'package:homely/features/household/providers/household_providers.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';

class HouseholdSettingsScreen extends ConsumerWidget {
  const HouseholdSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final householdAsync = ref.watch(householdProvider);
    final membersAsync = ref.watch(householdMembersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Household'),
      ),
      body: householdAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (household) {
          if (household == null) {
            return const Center(child: Text('No household found.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Invite Code Card [cite: 101]
              _buildInviteCodeCard(context, theme, household),
              const SizedBox(height: 24),

              // Members List [cite: 101]
              Text('Members', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              membersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('Error loading members: $err'),
                data: (members) => _buildMembersList(members, household),
              ),
              const SizedBox(height: 24),

              // Invite Member Button
              FilledButton.icon(
                icon: const Icon(EvaIcons.personAddOutline),
                label: const Text('INVITE MEMBER'),
                onPressed: () => _copyInviteCode(context, household.inviteCode),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInviteCodeCard(
      BuildContext context, ThemeData theme, HouseholdModel household) {
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              household.name,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'INVITE CODE',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  household.inviteCode,
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    letterSpacing: 2.0,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    EvaIcons.copyOutline,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  onPressed: () =>
                      _copyInviteCode(context, household.inviteCode),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersList(List<UserModel> members, HouseholdModel household) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          final bool isOwner = member.uid == household.ownerId;
          return ListTile(
            leading: const CircleAvatar(
              child: Icon(EvaIcons.personOutline),
            ),
            title: Text(member.name),
            trailing: isOwner
                ? Text(
                    '(Owner)',
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                : null,
          );
        },
      ),
    );
  }

  void _copyInviteCode(BuildContext context, String inviteCode) {
    Clipboard.setData(ClipboardData(text: inviteCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite code copied to clipboard!')),
    );
  }
}
