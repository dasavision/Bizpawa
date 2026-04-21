import 'package:flutter/material.dart';
import 'create_pin_page.dart';

const _kNavy = Color(0xFF1B2E6B);
const _kOrange = Color(0xFFF5A623);

// ===== AINA ZA BIASHARA =====
class _BizType {
  final String emoji;
  final String name;
  final String desc;
  final Color color;

  const _BizType({
    required this.emoji,
    required this.name,
    required this.desc,
    required this.color,
  });
}

const List<_BizType> _bizTypes = [
  _BizType(emoji: '🛒', name: 'Duka la Mangi\n& Supermarket', desc: 'Vyakula, vinywaji, bidhaa za kila siku', color: Color(0xFF16A34A)),
  _BizType(emoji: '💊', name: 'Pharmacy\n& Dawa', desc: 'Dawa, vifaa vya hospitali', color: Color(0xFF0EA5E9)),
  _BizType(emoji: '👗', name: 'Fashion\n& Nguo', desc: 'Nguo, viatu, mifuko, accessories', color: Color(0xFFA855F7)),
  _BizType(emoji: '🍽️', name: 'Chakula\n& Bakery', desc: 'Mkate, keki, chakula cha kutengeneza', color: Color(0xFFEF4444)),
  _BizType(emoji: '📱', name: 'Electronics\n& Simu', desc: 'Simu, kompyuta, vifaa vya umeme', color: Color(0xFF3B82F6)),
  _BizType(emoji: '🛋️', name: 'Furniture\n& Samani', desc: 'Viti, meza, vitanda, mapambo', color: Color(0xFFF59E0B)),
  _BizType(emoji: '🔧', name: 'Hardware\n& Ujenzi', desc: 'Zana za ujenzi, vifaa vya chuma', color: Color(0xFF6B7280)),
  _BizType(emoji: '💍', name: 'Jewellery\n& Mapambo', desc: 'Pete, mikufu, herini, dhahabu', color: Color(0xFFEC4899)),
  _BizType(emoji: '🏦', name: 'Microfinance\n& Fedha', desc: 'Mkopo, akiba, huduma za fedha', color: Color(0xFF10B981)),
  _BizType(emoji: '🔩', name: 'Spare Parts\n& Mashine', desc: 'Vipande vya magari, mitambo', color: Color(0xFF64748B)),
  _BizType(emoji: '📚', name: 'Stationary\n& Vifaa vya Ofisi', desc: 'Kalamu, karatasi, vifaa vya shule', color: Color(0xFF8B5CF6)),
  _BizType(emoji: '🍺', name: 'Vinywaji\n& Pombe', desc: 'Bia, mvinyo, vinywaji baridi', color: Color(0xFFD97706)),
  _BizType(emoji: '💸', name: 'Wakala\n& Pesa', desc: 'M-Pesa, Tigo Pesa, Airtel Money', color: Color(0xFF059669)),
  _BizType(emoji: '👶', name: 'Babies\n& Kids', desc: 'Nguo za watoto, toys, vifaa', color: Color(0xFFF472B6)),
  _BizType(emoji: '💄', name: 'Cosmetics\n& Beauty', desc: 'Sabuni, manukato, vipodozi', color: Color(0xFFE11D48)),
  _BizType(emoji: '🔌', name: 'Huduma\n& Services', desc: 'Ushonaji, ukarabati, ushauri', color: Color(0xFF0891B2)),
];

class BusinessTypePage extends StatefulWidget {
  final String name;
  final String phone;
  final String bizName;
  final String address;

  const BusinessTypePage({
    super.key,
    required this.name,
    required this.phone,
    required this.bizName,
    required this.address,
  });

  @override
  State<BusinessTypePage> createState() => _BusinessTypePageState();
}

class _BusinessTypePageState extends State<BusinessTypePage>
    with SingleTickerProviderStateMixin {
  _BizType? _selected;
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [

            // ===== TOP BAR =====
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: _kNavy),
                    onPressed: () => Navigator.pop(context),
                  ),
                  // Step indicator
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i <= 1 ? 24 : 8,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i <= 1 ? _kNavy : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      )),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // ===== HEADER =====
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _kNavy.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.storefront_outlined, color: _kNavy, size: 24),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Aina ya Biashara Yako',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _kNavy),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hatua 2 ya 3 — Chagua aina inayofanana na biashara yako',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),

            // ===== GRID =====
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: _bizTypes.length,
                itemBuilder: (context, index) {
                  final type = _bizTypes[index];
                  final isSelected = _selected == type;
                  final delay = index * 0.03;

                  return AnimatedBuilder(
                    animation: _animCtrl,
                    builder: (_, child) {
                      final t = Curves.easeOutCubic.transform(
                        ((_animCtrl.value - delay).clamp(0.0, 1.0)),
                      );
                      return Opacity(
                        opacity: t,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - t)),
                          child: child,
                        ),
                      );
                    },
                    child: GestureDetector(
                      onTap: () => setState(() => _selected = type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? type.color.withValues(alpha: 0.08)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? type.color
                                : Colors.grey.shade200,
                            width: isSelected ? 1.5 : 0.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: type.color.withValues(alpha: 0.12),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Row(
                          children: [
                            // Emoji icon container
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? type.color.withValues(alpha: 0.15)
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  type.emoji,
                                  style: const TextStyle(fontSize: 26),
                                ),
                              ),
                            ),

                            const SizedBox(width: 14),

                            // Text
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    type.name.replaceAll('\n', ' '),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? type.color : _kNavy,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    type.desc,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Checkbox
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isSelected ? type.color : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSelected ? type.color : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ===== BOTTOM BUTTON =====
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Selected indicator
                  if (_selected != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: _selected!.color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Text(_selected!.emoji, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Text(
                            _selected!.name.replaceAll('\n', ' '),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _selected!.color,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.check_circle, color: _selected!.color, size: 16),
                        ],
                      ),
                    ),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selected != null ? _kNavy : Colors.grey.shade300,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _selected != null ? _onNext : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _selected == null ? 'Chagua Aina ya Biashara' : 'Endelea',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_selected != null) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onNext() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePinPage(
          name: widget.name,
          phone: widget.phone,
          bizName: widget.bizName,
          address: widget.address,
          bizType: _selected!.name.replaceAll('\n', ' '),
        ),
      ),
    );
  }
}