import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../providers/product_providers.dart';

class ListProductScreen extends StatefulWidget {
  const ListProductScreen({super.key});

  @override
  State<ListProductScreen> createState() => _ListProductScreenState();
}

class _ListProductScreenState extends State<ListProductScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProduct();
      context.read<ProductProvider>().fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('PPB Products - DummyJSON'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: 'Urutkan Harga Tertinggi',
            onPressed: () => provider.sortProducts('price', 'desc'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh produk dari database',
            onPressed: () {
              provider.fetchProduct();
              provider.fetchCategories();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Tambah produk',
            onPressed: () => context.go('/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari produk (contoh: phone)...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    provider.fetchProduct();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: (value) => provider.searchProducts(value),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: provider.categoryList.length,
              itemBuilder: (context, index) {
                final cat = provider.categoryList[index];
                final isSelected = provider.selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        provider.filterByCategory(cat);
                      } else {
                        provider.fetchProduct();
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(),
          if (provider.loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (provider.error != null)
            Expanded(child: Center(child: Text('Error: ${provider.error}')))
          else
            Expanded(
              child: ListView.builder(
                itemCount: provider.product.length,
                itemBuilder: (context, index) {
                  final product = provider.product[index];
                  return Card(
                    color: Colors.white,
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Color(0xFFE5DCEA)),
                    ),
                    child: ListTile(
                      leading: CachedNetworkImage(
                        imageUrl: product.thumbnail ?? '',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.image_not_supported_outlined,
                          color: Color(0xFF9A909F),
                        ),
                      ),
                      title: Text(product.title ?? ''),
                      subtitle: Text(
                        '\$${product.price} | Kategori: ${product.category}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Color(0xFF79699F),
                        ),
                        onPressed: () =>
                            context.go('/edit/${product.id}', extra: product),
                      ),
                      onTap: () => context.go('/detail/${product.id}'),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
