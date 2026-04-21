import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:bizpawa/core/state/business_state.dart';

const kNavyBlue = Color(0xFF1B2E6B);
const kOrange = Color(0xFFF5A623);

class SelectCustomerPage extends StatefulWidget {
  const SelectCustomerPage({super.key});

  @override
  State<SelectCustomerPage> createState() =>
      _SelectCustomerPageState();
}

class _SelectCustomerPageState
    extends State<SelectCustomerPage> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final business = context.watch<BusinessState>();

    final customers = business.customers.where((c) {
      if (_search.isEmpty) return true;
      return c.name
              .toLowerCase()
              .contains(_search.toLowerCase()) ||
          c.phone.contains(_search);
    }).toList();

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
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Tafuta mteja...',
            hintStyle:
                TextStyle(color: Colors.grey.shade400),
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => _search = v),
        ),
        actions: [
          /// Add customer button
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: kNavyBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person_add,
                  color: Colors.white, size: 18),
            ),
            onPressed: () =>
                _showAddCustomerSheet(context, business),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: customers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 60,
                      color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(
                    _search.isNotEmpty
                        ? 'Hakuna mteja anayelingana'
                        : 'Hakuna wateja bado',
                    style: TextStyle(
                        color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _showAddCustomerSheet(
                        context, business),
                    child: Container(
                      margin: const EdgeInsets.only(
                          top: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: kNavyBlue,
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Ongeza Mteja Mpya',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final customer = customers[index];

                return GestureDetector(
                  onTap: () =>
                      Navigator.pop(context, customer),
                  child: Container(
                    margin:
                        const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        /// Avatar
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: kNavyBlue
                                .withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              customer.name
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: kNavyBlue,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        /// Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer.name,
                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.w600,
                                  fontSize: 14,
                                  color: kNavyBlue,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone_outlined,
                                    size: 12,
                                    color: Colors
                                        .grey.shade400,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    customer.phone,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors
                                          .grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                              if (customer.address !=
                                      null &&
                                  customer
                                      .address!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons
                                          .location_on_outlined,
                                      size: 12,
                                      color: Colors
                                          .grey.shade400,
                                    ),
                                    const SizedBox(
                                        width: 4),
                                    Text(
                                      customer.address!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors
                                            .grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        const Icon(
                            Icons.chevron_right,
                            color: Colors.grey),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddCustomerSheet(
      BuildContext context, BusinessState business) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final addressController = TextEditingController();
    bool showMore = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom:
                MediaQuery.of(context).viewInsets.bottom +
                    24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Mteja Mpya',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kNavyBlue,
                  ),
                ),

                const SizedBox(height: 20),

                /// JINA
                _label('Jina la Mteja'),
                const SizedBox(height: 6),
                TextField(
                  controller: nameController,
                  textCapitalization:
                      TextCapitalization.words,
                  autofocus: true,
                  decoration: _inputDecoration(
                      'Mf. John Doe'),
                ),

                const SizedBox(height: 16),

                /// SIMU
                _label('Namba ya Simu'),
                const SizedBox(height: 6),
                Row(
  children: [
    Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Colors.grey.shade200),
      ),
      child: const Text(
        '🇹🇿 +255',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: kNavyBlue,
        ),
      ),
    ),
    const SizedBox(width: 8),
    Expanded(
      child: TextField(
        controller: phoneController,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly
        ],
        decoration: _inputDecoration('753412681'),
      ),
    ),
  ],
),

                const SizedBox(height: 16),

                /// ZAIDI button
                GestureDetector(
                  onTap: () =>
                      setModal(() => showMore = !showMore),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(12),
                      border: Border.all(
                        color: showMore
                            ? kNavyBlue
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          showMore
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: showMore
                              ? kNavyBlue
                              : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Taarifa za Ziada (hiari)',
                          style: TextStyle(
                            color: showMore
                                ? kNavyBlue
                                : Colors.grey.shade600,
                            fontWeight: showMore
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (showMore) ...[
                  const SizedBox(height: 16),

                  /// EMAIL
                  _label('Barua Pepe (hiari)'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: emailController,
                    keyboardType:
                        TextInputType.emailAddress,
                    decoration:
                        _inputDecoration('Mf. john@gmail.com'),
                  ),

                  const SizedBox(height: 16),

                  /// ANWANI
                  _label('Anwani (hiari)'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: addressController,
                    textCapitalization:
                        TextCapitalization.sentences,
                    decoration:
                        _inputDecoration('Mf. Kigoma Mjini'),
                  ),
                ],

                const SizedBox(height: 24),

                /// SAVE
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kNavyBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                    icon:
                        const Icon(Icons.person_add_outlined),
                    label: const Text(
                      'Hifadhi Mteja',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15),
                    ),
                    onPressed: () {
                      final name =
                          nameController.text.trim();
                      final phone =
                          phoneController.text.trim();

                      if (name.isEmpty || phone.isEmpty) {
                        return;
                      }

                      final customer = Customer(
                        id: DateTime.now()
                            .millisecondsSinceEpoch
                            .toString(),
                        name: name,
                        phone: phone.startsWith('0')
    ? '+255${phone.substring(1)}'
    : phone.startsWith('255')
        ? '+$phone'
        : '+255$phone',
                        email: emailController.text
                                .trim()
                                .isEmpty
                            ? null
                            : emailController.text.trim(),
                        address: addressController.text
                                .trim()
                                .isEmpty
                            ? null
                            : addressController.text
                                .trim(),
                      );

                      business.addCustomer(customer);
                      Navigator.pop(context); // close sheet
                      Navigator.pop(
                          context, customer); // return customer
                    },
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: kNavyBlue,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kNavyBlue),
      ),
    );
  }
}