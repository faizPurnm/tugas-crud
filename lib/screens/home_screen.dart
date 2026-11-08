import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/product_providers.dart';

// ==================== HALAMAN DETAIL PRODUK (PASTEL LAVENDER, PEACH, MINT) ====================
class ProductDetailScreen extends StatelessWidget {
  final dynamic product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F6),
      appBar: AppBar(
        title: Text(
          product.title ?? 'Detail Produk',
          style: const TextStyle(fontSize: 16, color: Color(0xFF42384F)),
        ),
        backgroundColor: const Color(0xFFEDE4F7),
        foregroundColor: const Color(0xFF42384F),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              width: double.infinity,
              color: const Color(0xFFF4ECF8),
              child: Image.network(
                product.thumbnail ?? '',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 50,
                    color: Color(0xFF9A909F),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title ?? '',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF42384F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${product.price ?? 0}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF79699F),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFE5DCEA)),
                  const SizedBox(height: 16),
                  const Text(
                    'Deskripsi Produk',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF42384F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description ??
                        'Tidak ada deskripsi untuk produk ini.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF817889),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        color: const Color(0xFFFFF9F6),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Produk dimasukkan ke keranjang!'),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFD8CBE8)),
                  backgroundColor: const Color(0xFFF5EAF8),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '+ Keranjang',
                  style: TextStyle(
                    color: Color(0xFF42384F),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Menuju halaman checkout...')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD9CCF0),
                  foregroundColor: const Color(0xFF42384F),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Beli Sekarang',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== HALAMAN UTAMA (PASTEL STORE LAYOUT) ====================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSort = 'Default';

  static const Color _ink = Color(0xFF42384F);
  static const Color _mutedInk = Color(0xFF817889);
  static const Color _lavender = Color(0xFFEDE4F7);
  static const Color _lavenderAccent = Color(0xFFD9CCF0);
  static const Color _canvas = Color(0xFFFFFEFC);
  static const Color _sortBar = Color(0xFFF0EDF2);
  static const Color _outline = Color(0xFFE8E0EC);
  static const List<Color> _imagePastels = [
    Color(0xFFF5EAF8),
    Color(0xFFFFEEE5),
    Color(0xFFE5F1E8),
    Color(0xFFF8E7ED),
    Color(0xFFE9EAF8),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProduct();
      Provider.of<ProductProvider>(context, listen: false).fetchCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _categoryLabel(String category) {
    return category
        .split(RegExp(r'[-_ ]'))
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  void _openProduct(dynamic product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }

  Widget _buildProductCard(dynamic product, double tileWidth) {
    final idValue = product.id;
    final colorIndex = idValue is int
        ? idValue.abs() % _imagePastels.length
        : 0;

    return SizedBox(
      width: tileWidth,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openProduct(product),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: tileWidth,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(
                        color: _imagePastels[colorIndex],
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.network(
                            product.thumbnail ?? '',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    size: 42,
                                    color: Color(0xFF9A909F),
                                  ),
                                ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 5,
                        left: 5,
                        child: Material(
                          color: Colors.white.withOpacity(0.92),
                          shape: const CircleBorder(),
                          child: PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            iconSize: 20,
                            icon: const Icon(Icons.more_vert, color: _ink),
                            onSelected: (action) async {
                              if (action == 'edit') {
                                context.push('/edit/${product.id}', extra: product);
                              } else if (action == 'delete') {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (dialogContext) => AlertDialog(
                                    title: const Text('Hapus produk?'),
                                    content: Text('Produk "${product.title}" akan dihapus dari database.'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Batal')),
                                      FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Hapus')),
                                    ],
                                  ),
                                );
                                if (confirmed == true && context.mounted) {
                                  final ok = await context.read<ProductProvider>().deleteProduct(product.id!);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Produk berhasil dihapus' : (context.read<ProductProvider>().error ?? 'Gagal menghapus produk'))));
                                  }
                                }
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Edit'), dense: true)),
                              PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline), title: Text('Hapus'), dense: true)),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 9,
                        right: 9,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9ED),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 13,
                                color: Color(0xFFC68A40),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${product.rating ?? 4.0}',
                                style: const TextStyle(
                                  color: _ink,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(11, 9, 9, 9),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.title ?? 'Produk',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 13,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                '\$${product.price ?? 0}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF79699F),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Material(
                              color: _lavenderAccent,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${product.title} ditambahkan ke keranjang!',
                                      ),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: const SizedBox(
                                  width: 29,
                                  height: 29,
                                  child: Icon(
                                    Icons.add_rounded,
                                    color: _ink,
                                    size: 19,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final tileWidth = screenWidth < 420 ? 158.0 : (screenWidth < 700 ? 176.0 : 200.0);

    // Kelompokkan daftar produk yang sedang ditampilkan berdasarkan kategori.
    // Data tetap berasal dari ProductProvider yang sama.
    final Map<String, List<dynamic>> groupedProducts = {};
    for (final product in productProvider.product) {
      final category = (product.category ?? 'lainnya').toString();
      groupedProducts.putIfAbsent(category, () => <dynamic>[]).add(product);
    }

    final sectionCategories = <String>[];
    for (final category in productProvider.categoryList) {
      if (groupedProducts.containsKey(category)) {
        sectionCategories.add(category);
      }
    }
    for (final category in groupedProducts.keys) {
      if (!sectionCategories.contains(category)) {
        sectionCategories.add(category);
      }
    }

    return Scaffold(
      backgroundColor: _canvas,
      appBar: AppBar(
        toolbarHeight: 59,
        elevation: 0,
        backgroundColor: _lavender,
        foregroundColor: _ink,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _lavenderAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.shopping_bag_rounded,
                color: _ink,
                size: 19,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Store App',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 16,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Koleksi Produk Pilihan',
                  style: TextStyle(
                    color: _mutedInk,
                    fontSize: 10,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Keranjang',
            icon: const Icon(Icons.shopping_bag_outlined, size: 20),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Kolom pencarian tetap menggunakan fungsi searchProducts semula.
          Container(
            color: _lavender,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 13),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF4EFF8)),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: _ink, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Cari produk, merek, atau kategori...',
                  hintStyle: const TextStyle(
                    color: Color(0xFFAAA1B2),
                    fontSize: 12,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF9A8DA9),
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          tooltip: 'Hapus pencarian',
                          icon: const Icon(
                            Icons.close_rounded,
                            color: _mutedInk,
                            size: 18,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            productProvider.searchProducts('');
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                onChanged: (query) {
                  setState(() {});
                  productProvider.searchProducts(query);
                },
              ),
            ),
          ),

          // Baris Sort By dibuat selebar layar seperti referensi.
          Container(
            height: 64,
            color: _sortBar,
            padding: const EdgeInsets.symmetric(horizontal: 19),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Sort By',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Pilih pengurutan',
                  padding: const EdgeInsets.only(left: 8),
                  icon: const Icon(
                    Icons.tune_rounded,
                    color: _ink,
                    size: 27,
                  ),
                  onSelected: (value) {
                    setState(() {
                      _selectedSort = value;
                    });
                  },
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                    for (final option in <String>[
                      'Default',
                      'Termurah',
                      'Termahal',
                    ])
                      PopupMenuItem<String>(
                        value: option,
                        child: Row(
                          children: [
                            Expanded(child: Text(option)),
                            if (_selectedSort == option)
                              const Icon(
                                Icons.check_rounded,
                                size: 18,
                                color: Color(0xFF79699F),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: productProvider.loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF79699F)),
                  )
                : productProvider.error != null
                ? Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_off_rounded,
                              size: 46,
                              color: Color(0xFF9A829F),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Tidak dapat memuat produk',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _ink,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SelectableText(
                              productProvider.error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: _mutedInk,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                productProvider.fetchProduct();
                                productProvider.fetchCategories();
                              },
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Coba lagi'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : productProvider.product.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 42,
                          color: Color(0xFF9A909F),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _searchController.text.trim().isEmpty
                              ? 'Database belum berisi produk'
                              : 'Produk tidak ditemukan',
                          style: const TextStyle(
                            color: _mutedInk,
                            fontSize: 15,
                          ),
                        ),
                        if (_searchController.text.trim().isEmpty) ...[
                          const SizedBox(height: 6),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'Pastikan proses import DummyJSON berhasil, lalu coba muat ulang.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: _mutedInk, fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () {
                              productProvider.fetchProduct();
                              productProvider.fetchCategories();
                            },
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Muat ulang produk'),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 17, bottom: 24),
                    itemCount: sectionCategories.length,
                    itemBuilder: (context, index) {
                      final category = sectionCategories[index];
                      final products = groupedProducts[category] ?? <dynamic>[];
                      final isSelected =
                          productProvider.selectedCategory == category;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 23),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _categoryLabel(category),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: _ink,
                                        fontSize: 25,
                                        height: 1.15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (isSelected) {
                                        productProvider.fetchProduct();
                                      } else {
                                        productProvider.filterByCategory(
                                          category,
                                        );
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: _ink,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 7,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      isSelected ? 'see all' : 'see more',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: tileWidth + 88,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                ),
                                itemCount: products.length,
                                separatorBuilder: (context, itemIndex) =>
                                    const SizedBox(width: 18),
                                itemBuilder: (context, itemIndex) =>
                                    _buildProductCard(
                                      products[itemIndex],
                                      tileWidth,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add'),
        backgroundColor: _lavenderAccent,
        foregroundColor: _ink,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
      ),
    );
  }
}
