import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bizpawa/core/state/business_state.dart';


const kNavyBlue = Color(0xFF1B2E6B);
const kOrange = Color(0xFFF5A623);

class SelectProductPage extends StatefulWidget {
  const SelectProductPage({super.key});

  @override
  State<SelectProductPage> createState() => _SelectProductPageState();
}

class _SelectProductPageState extends State<SelectProductPage> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  String _search = '';

  @override
  void initState() {
    super.initState();
    /// Focus search mara moja ukifungua page
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

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final business = context.watch<BusinessState>();

    final items = business.inventory.where((item) {
      if (_search.isEmpty) return true;
      return item.name
          .toLowerCase()
          .contains(_search.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kNavyBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Tafuta bidhaa au huduma...',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => _search = v),
        ),
        actions: [
          if (_search.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () {
                _searchController.clear();
                setState(() => _search = '');
              },
            ),
        ],
      ),

      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off,
                      size: 60, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(
                    _search.isNotEmpty
                        ? 'Hakuna bidhaa inayolingana na "$_search"'
                        : 'Hakuna bidhaa bado',
                    style: TextStyle(color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isService = item.unit == 'SERVICE';
                final outOfStock =
                    !isService && item.stock == 0;

                return GestureDetector(
                  onTap: outOfStock
                      ? null
                      : () => Navigator.pop(context, item),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: outOfStock
                          ? Colors.grey.shade100
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: outOfStock
                          ? []
                          : [
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
                        /// Picha
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(10),
                            color: isService
                                ? kOrange.withValues(alpha: 0.1)
                                : kNavyBlue.withValues(alpha: 0.08),
                            image: item.imagePath != null
                                ? DecorationImage(
                                    image: FileImage(
                                        File(item.imagePath!)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: item.imagePath == null
                              ? Icon(
                                  isService
                                      ? Icons.handyman
                                      : Icons.inventory_2,
                                  color: isService
                                      ? kOrange
                                      : kNavyBlue,
                                  size: 20,
                                )
                              : null,
                        ),

                        const SizedBox(width: 12),

                        /// Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: outOfStock
                                      ? Colors.grey
                                      : kNavyBlue,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                isService
                                    ? 'Huduma • ${item.category}'
                                    : '${item.stock} ${item.unit} • ${item.category}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// Bei + Status
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${_formatCurrency(item.sellingPrice)} TZS',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: outOfStock
                                    ? Colors.grey
                                    : kNavyBlue,
                              ),
                            ),
                            if (outOfStock) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red
                                      .withValues(alpha: 0.1),
                                  borderRadius:
                                      BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'IMEISHA',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}