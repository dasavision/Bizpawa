import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bizpawa/core/state/business_state.dart';
import 'package:bizpawa/core/services/notification_service.dart';

const kNavyBlue = Color(0xFF1B2E6B);
const kOrange = Color(0xFFF5A623);

class ExpenseDetailPage extends StatelessWidget {
  final Expense expense;

  const ExpenseDetailPage({super.key, required this.expense});

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'chakula':
        return Icons.restaurant_outlined;
      case 'umeme':
        return Icons.bolt_outlined;
      case 'bando':
        return Icons.wifi_outlined;
      case 'usafiri':
        return Icons.directions_car_outlined;
      case 'usafi':
        return Icons.cleaning_services_outlined;
      case 'kodi ya pango':
        return Icons.home_outlined;
      case 'mishahara':
        return Icons.people_outline;
      case 'matengenezo':
        return Icons.build_outlined;
      default:
        return Icons.receipt_outlined;
    }
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'chakula':
        return const Color(0xFFEF4444);
      case 'umeme':
        return const Color(0xFFF59E0B);
      case 'bando':
        return const Color(0xFF3B82F6);
      case 'usafiri':
        return const Color(0xFF8B5CF6);
      case 'usafi':
        return const Color(0xFF06B6D4);
      case 'kodi ya pango':
        return const Color(0xFF10B981);
      case 'mishahara':
        return const Color(0xFFF97316);
      case 'matengenezo':
        return const Color(0xFF6366F1);
      default:
        return kNavyBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final business = context.read<BusinessState>();
    final color = _categoryColor(expense.category);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: kNavyBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Taarifa za Matumizi',
          style: TextStyle(
              color: kNavyBlue,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// ===== ICON + CATEGORY =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _categoryIcon(expense.category),
                      color: color,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    expense.category,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kNavyBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_formatCurrency(expense.amount)} TZS',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// ===== TAARIFA =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _infoRow(
                    icon: Icons.category_outlined,
                    label: 'Aina ya Matumizi',
                    value: expense.category,
                    color: color,
                  ),
                  const Divider(height: 24),
                  _infoRow(
                    icon: Icons.calendar_today,
                    label: 'Tarehe',
                    value:
                        '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                    color: kNavyBlue,
                  ),
                  const Divider(height: 24),
                  _infoRow(
                    icon: Icons.access_time,
                    label: 'Muda',
                    value:
                        '${expense.date.hour.toString().padLeft(2, '0')}:${expense.date.minute.toString().padLeft(2, '0')}',
                    color: kNavyBlue,
                  ),
                  const Divider(height: 24),
                  _infoRow(
                    icon: Icons.payments_outlined,
                    label: 'Kiasi',
                    value:
                        '${_formatCurrency(expense.amount)} TZS',
                    color: color,
                    bold: true,
                  ),
                  const Divider(height: 24),
                  _infoRow(
                    icon: Icons.person_outline,
                    label: 'Aliyerekodi',
                    value: expense.recordedBy,
                    color: kNavyBlue,
                  ),
                  if (expense.note != null &&
                      expense.note!.isNotEmpty) ...[
                    const Divider(height: 24),
                    _infoRow(
                      icon: Icons.notes,
                      label: 'Maelezo',
                      value: expense.note!,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            /// ===== FUTA BUTTON =====
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.delete_outline),
                label: const Text(
                  'Futa Matumizi Haya',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
                onPressed: () =>
                    _confirmDelete(context, business),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool bold = false,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: bold ? 15 : 14,
                  fontWeight: bold
                      ? FontWeight.bold
                      : FontWeight.w500,
                  color: kNavyBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDelete(
      BuildContext context, BusinessState business) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Futa Matumizi',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          'Una uhakika unataka kufuta matumizi ya ${expense.category} ya ${expense.amount} TZS?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ghairi'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              business.deleteExpense(expense.id);
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // rudi analytics

              NotificationService.show(
                context: context,
                message:
                    'Matumizi ya ${expense.category} yamefutwa',
                type: NotificationType.error,
              );
            },
            child: const Text('Futa'),
          ),
        ],
      ),
    );
  }
}