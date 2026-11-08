import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'providers/product_providers.dart';
import 'screens/detail_product_screen.dart';
import 'screens/add_product_screen.dart';
import 'screens/edit_product_screen.dart';
import 'screens/home_screen.dart';
import 'models/product_model.dart';

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/detail/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return DetailProductScreen(productId: id);
      },
    ),
    GoRoute(
      path: '/add',
      builder: (context, state) => const AddProductScreen(),
    ),
    GoRoute(
      path: '/edit/:id',
      builder: (context, state) {
        final product = state.extra as Product;
        return EditProductScreen(product: product);
      },
    ),
  ],
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const pastelLavender = Color(0xFFD9CCF0);
    const deepLavender = Color(0xFF79699F);
    const ink = Color(0xFF42384F);
    const canvas = Color(0xFFFFF9F6);
    const outline = Color(0xFFE5DCEA);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: pastelLavender,
      brightness: Brightness.light,
    ).copyWith(
      primary: deepLavender,
      onPrimary: Colors.white,
      secondary: const Color(0xFFD7EBDD),
      onSecondary: const Color(0xFF344A40),
      tertiary: const Color(0xFFF5DCE7),
      onTertiary: const Color(0xFF573E4B),
      surface: const Color(0xFFFFFEFC),
      onSurface: ink,
      outline: outline,
    );

    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ProductProvider())],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'PPB Produk Bawaan',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: colorScheme,
          scaffoldBackgroundColor: canvas,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFEDE4F7),
            foregroundColor: ink,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              color: ink,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            hintStyle: const TextStyle(color: Color(0xFF9A909F)),
            labelStyle: const TextStyle(color: Color(0xFF746A7D)),
            prefixIconColor: deepLavender,
            suffixIconColor: const Color(0xFF817889),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: deepLavender, width: 1.6),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: pastelLavender,
              foregroundColor: ink,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: ink,
              backgroundColor: const Color(0xFFFFF5F0),
              side: const BorderSide(color: Color(0xFFE5D5E7)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: deepLavender,
            circularTrackColor: Color(0xFFEDE4F7),
          ),
          dividerTheme: const DividerThemeData(
            color: outline,
            thickness: 1,
            space: 1,
          ),
          chipTheme: ChipThemeData(
            backgroundColor: const Color(0xFFFFFEFC),
            selectedColor: pastelLavender,
            labelStyle: const TextStyle(color: ink),
            secondaryLabelStyle: const TextStyle(color: ink),
            side: const BorderSide(color: outline),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          snackBarTheme: const SnackBarThemeData(
            backgroundColor: Color(0xFF51465F),
            contentTextStyle: TextStyle(color: Colors.white),
            behavior: SnackBarBehavior.floating,
          ),
        ),
        routerConfig: _router,
      ),
    );
  }
}
