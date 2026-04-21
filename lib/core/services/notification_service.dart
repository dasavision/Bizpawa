import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

const kNavyBlue = Color(0xFF1B2E6B);
const kOrange = Color(0xFFF5A623);

enum NotificationType { success, error, info, warning }

class AppNotification {
  final String message;
  final NotificationType type;
  final DateTime time;
  bool isRead;

  AppNotification({
    required this.message,
    required this.type,
    required this.time,
    this.isRead = false,
  });
}

class NotificationService {
  static final List<AppNotification> _history = [];
  static final AudioPlayer _player = AudioPlayer();

  static List<AppNotification> get history {
    final today = DateTime.now();
    _history.removeWhere((n) => !_isSameDay(n.time, today));
    return List.unmodifiable(_history);
  }

  static int get unreadCount =>
      _history.where((n) => !n.isRead).length;

  static void markAllRead() {
    for (final n in _history) {
      n.isRead = true;
    }
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Cheza sauti kulingana na aina
  static Future<void> _playSound(NotificationType type) async {
    try {
      String soundFile;
      switch (type) {
        case NotificationType.success:
        case NotificationType.info:
        case NotificationType.warning:
          soundFile = 'sounds/success.mp3';
          break;
        case NotificationType.error:
          soundFile = 'sounds/error.mp3';
          break;
      }
      await _player.play(AssetSource(soundFile));
    } catch (_) {
      // Kama sauti haifanyi kazi tumia vibration tu
      await HapticFeedback.mediumImpact();
    }
  }

  /// Sauti ya scanner — itatumika moja kwa moja
  static Future<void> playScanner() async {
    try {
      await _player.play(AssetSource('sounds/scanner.mp3'));
    } catch (_) {
      await HapticFeedback.lightImpact();
    }
  }

  static void show({
    required BuildContext context,
    required String message,
    NotificationType type = NotificationType.success,
  }) {
    _history.insert(
      0,
      AppNotification(
        message: message,
        type: type,
        time: DateTime.now(),
      ),
    );

    // Vibration + sauti
    switch (type) {
      case NotificationType.success:
        HapticFeedback.mediumImpact();
        break;
      case NotificationType.error:
        HapticFeedback.heavyImpact();
        break;
      case NotificationType.warning:
      case NotificationType.info:
        HapticFeedback.lightImpact();
        break;
    }

    _playSound(type);
    _showOverlay(context, message, type);
  }

  static void _showOverlay(
    BuildContext context,
    String message,
    NotificationType type,
  ) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _NotificationOverlay(
        message: message,
        type: type,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

/// ===== OVERLAY WIDGET =====
class _NotificationOverlay extends StatefulWidget {
  final String message;
  final NotificationType type;
  final VoidCallback onDismiss;

  const _NotificationOverlay({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_NotificationOverlay> createState() =>
      _NotificationOverlayState();
}

class _NotificationOverlayState
    extends State<_NotificationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _bgColor {
    switch (widget.type) {
      case NotificationType.success:
        return const Color(0xFF22C55E);
      case NotificationType.error:
        return const Color(0xFFEF4444);
      case NotificationType.warning:
        return kOrange;
      case NotificationType.info:
        return kNavyBlue;
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case NotificationType.success:
        return Icons.check_circle_outline;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.warning:
        return Icons.warning_amber_rounded;
      case NotificationType.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 12,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: () {
              _controller.reverse().then((_) {
                widget.onDismiss();
              });
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: _bgColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _bgColor.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(_icon, color: Colors.white, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.close,
                        color: Colors.white70, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}