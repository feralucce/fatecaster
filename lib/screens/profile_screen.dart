import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/user_service.dart';
import '../models/user_profile.dart';
import '../routes/app_routes.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../widgets/custom_button.dart';
import '../widgets/error_banner.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _avatarController = TextEditingController();
  final _userService = UserService();

  bool _editing = false;
  bool _loading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    final profile = context.read<UserProvider>().profile;
    _nameController.text = profile?.displayName ?? '';
    _avatarController.text = profile?.avatarUrl ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final userProvider = context.read<UserProvider>();
      if (_nameController.text.trim().isNotEmpty) {
        await userProvider.updateDisplayName(_nameController.text.trim());
      }
      if (_avatarController.text.trim().isNotEmpty) {
        await userProvider.updateAvatarUrl(_avatarController.text.trim());
      }
      setState(() => _editing = false);
    } catch (e) {
      setState(() => _error = 'Failed to save profile. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updatePreferences(
      UserPreferences prefs, String uid) async {
    try {
      await _userService.updatePreferences(uid, prefs);
      await context.read<UserProvider>().refreshProfile();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final profile = userProvider.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _editing = true),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAvatar(profile),
              const SizedBox(height: 24),
              if (_editing) _buildEditForm() else _buildProfileView(profile),
              const SizedBox(height: 24),
              _buildStatsCard(profile),
              const SizedBox(height: 24),
              if (profile != null)
                _buildPreferences(profile, userProvider.firebaseUser!.uid),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(UserProfile? profile) {
    final name = profile?.displayName ?? 'U';
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.primary,
            backgroundImage: profile?.avatarUrl != null
                ? NetworkImage(profile!.avatarUrl!)
                : null,
            child: profile?.avatarUrl == null
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileView(UserProfile? profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoRow(label: 'Display Name', value: profile?.displayName ?? '-'),
        const Divider(),
        _InfoRow(label: 'Email', value: profile?.email ?? '-'),
      ],
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          ErrorBanner(
              message: _error,
              onDismiss: () => setState(() => _error = '')),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Display Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Name is required';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _avatarController,
            decoration: const InputDecoration(
              labelText: 'Avatar URL (optional)',
              prefixIcon: Icon(Icons.image_outlined),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Cancel',
                  onPressed: () => setState(() => _editing = false),
                  variant: CustomButtonVariant.outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  label: 'Save',
                  onPressed: _save,
                  isLoading: _loading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(UserProfile? profile) {
    final stats = profile?.stats;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Statistics', style: AppStyles.heading3),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Total Rolls',
                    value: stats?.totalRolls.toString() ?? '0',
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Average',
                    value: stats != null
                        ? stats.averageResult.toStringAsFixed(1)
                        : '0.0',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Highest Roll',
                    value: stats?.highestRoll.toString() ?? '0',
                    valueColor: AppColors.success,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Lowest Roll',
                    value: stats?.lowestRoll.toString() ?? '0',
                    valueColor: AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferences(UserProfile profile, String uid) {
    final prefs = profile.preferences;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preferences', style: AppStyles.heading3),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Notifications'),
              subtitle: const Text('Roll alerts from room members'),
              value: prefs.notificationsEnabled,
              onChanged: (v) => _updatePreferences(
                UserPreferences(
                  darkMode: prefs.darkMode,
                  notificationsEnabled: v,
                  defaultDiceType: prefs.defaultDiceType,
                ),
                uid,
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Default Dice'),
              trailing: DropdownButton<String>(
                value: prefs.defaultDiceType,
                underline: const SizedBox.shrink(),
                items: ['d4', 'd6', 'd8', 'd10', 'd12', 'd20', 'd100']
                    .map((d) => DropdownMenuItem(
                        value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  _updatePreferences(
                    UserPreferences(
                      darkMode: prefs.darkMode,
                      notificationsEnabled: prefs.notificationsEnabled,
                      defaultDiceType: v,
                    ),
                    uid,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({Key? key, required this.label, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: AppStyles.label),
          ),
          Expanded(child: Text(value, style: AppStyles.bodyMedium)),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatItem(
      {Key? key,
      required this.label,
      required this.value,
      this.valueColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
        Text(label, style: AppStyles.bodySmall),
      ],
    );
  }
}
