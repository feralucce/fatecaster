import 'package:flutter/material.dart';

/// A dismissible banner shown at the top of the screen when the device is
/// offline.  Include it near the top of your scaffold body (e.g. inside a
/// [Column] above your main content) and control its visibility with the
/// [visible] parameter.
///
/// Usage:
/// ```dart
/// Column(
///   children: [
///     OfflineIndicator(
///       visible: !isOnline,
///       onReconnect: () => _connectivityService.tryReconnect(),
///     ),
///     Expanded(child: _buildContent()),
///   ],
/// )
/// ```
class OfflineIndicator extends StatelessWidget {
  /// Controls whether the banner is shown.
  final bool visible;

  /// Optional callback for the **Reconnect** button.  If `null`, the button
  /// is hidden.
  final VoidCallback? onReconnect;

  const OfflineIndicator({
    super.key,
    this.visible = true,
    this.onReconnect,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: visible ? _banner(context) : const SizedBox.shrink(),
    );
  }

  Widget _banner(BuildContext context) {
    final theme = Theme.of(context);
    const background = Color(0xFFF57F17); // amber-800
    const foreground = Colors.white;

    return Material(
      color: background,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.wifi_off_rounded, color: foreground, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'You are offline. Some features may be unavailable.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: foreground, fontWeight: FontWeight.w500),
                ),
              ),
              if (onReconnect != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onReconnect,
                  style: TextButton.styleFrom(
                    foregroundColor: foreground,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Reconnect',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
