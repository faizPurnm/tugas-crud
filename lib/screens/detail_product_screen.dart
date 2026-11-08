import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/product_model.dart';
import '../services/api_services_product.dart';

class DetailProductScreen extends StatelessWidget {
  final int productId;
  const DetailProductScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final ApiServiceProducts api = ApiServiceProducts();

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk')),
      body: FutureBuilder<Product>(
        future: api.getProduct(productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Produk tidak ditemukan'));
          }

          final product = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                CachedNetworkImage(
                  imageUrl: product.thumbnail ?? '',
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.image_not_supported_outlined,
                    color: Color(0xFF9A909F),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  product.title ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kategori: ${product.category}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  'Harga: \$${product.price}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF668C75),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Brand: ${product.brand}'),
                Text('Stok: ${product.stock}'),
                Text('Rating: ${product.rating} ⭐'),
                const SizedBox(height: 16),
                const Text(
                  'Deskripsi:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(product.description ?? ''),
              ],
            ),
          );
        },
      ),
    );
  }
}
