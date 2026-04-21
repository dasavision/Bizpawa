import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/state/business_state.dart';
import 'core/state/auth_state.dart';
import 'features/auth/splash_screen.dart';
import 'features/inventory/add_product_page.dart';

import 'models/product.dart';
import 'models/stock_batch.dart';
import 'models/customer.dart';
import 'models/expense.dart';
import 'models/supplier.dart';
import 'models/sale_entry.dart';
import 'models/app_note.dart';
import 'models/app_user.dart';

void main() async {
  // Lazima iwe kabla ya runApp kwa async main
  WidgetsFlutterBinding.ensureInitialized();

  // Anzisha Hive
  await Hive.initFlutter();

  // Sajili adapters zote — kila model lazima isajiliwe
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(StockBatchAdapter());
  Hive.registerAdapter(CustomerAdapter());
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(SupplierPaymentAdapter());
  Hive.registerAdapter(SupplierAdapter());
  Hive.registerAdapter(DebtPaymentAdapter());
  Hive.registerAdapter(SaleItemEntryAdapter());
  Hive.registerAdapter(RefundItemAdapter());
  Hive.registerAdapter(RefundEntryAdapter());
  Hive.registerAdapter(SaleEntryAdapter());
  Hive.registerAdapter(AppNoteAdapter());
  Hive.registerAdapter(SellerPermissionsAdapter());
  Hive.registerAdapter(AppUserAdapter());

  // Fungua Boxes zote — kila "droo" ya data
  await Hive.openBox<Product>('products');
  await Hive.openBox<SaleEntry>('sales');
  await Hive.openBox<Expense>('expenses');
  await Hive.openBox<Customer>('customers');
  await Hive.openBox<Supplier>('suppliers');
  await Hive.openBox<AppNote>('notes');
  await Hive.openBox('auth');       // Box ya admin credentials
  await Hive.openBox<AppUser>('sellers'); // Box ya wauzaji

  // MPYA
final authState = AuthState();
await authState.init();

runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => BusinessState()),
      ChangeNotifierProvider.value(value: authState),
    ],
    child: const MyApp(),
  ),
);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B2E6B),
          primary: const Color(0xFF1B2E6B),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.grey.shade50,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF1B2E6B)),
          titleTextStyle: TextStyle(
            color: Color(0xFF1B2E6B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B2E6B),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
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
            borderSide: const BorderSide(color: Color(0xFF1B2E6B)),
          ),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/add-product': (_) => const AddProductPage(),
      },
    );
  }
}