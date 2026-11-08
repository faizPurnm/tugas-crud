import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class ApiServiceProducts {
  // API_BASE_URL dapat dioverride dengan --dart-define.
  // Default otomatis disesuaikan dengan target Flutter:
  // - Android Emulator: 10.0.2.2 mengarah ke komputer host.
  // - Flutter Web/Desktop/iOS Simulator: localhost.
  static String get _baseUrl {
    const configuredUrl = String.fromEnvironment('API_BASE_URL');
    if (configuredUrl.isNotEmpty) {
      return configuredUrl.endsWith('/') ? configuredUrl : '$configuredUrl/';
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/backend/api/';
    }

    return 'http://localhost:8080/backend/api/';
  }

  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 15),
    headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
  ));

  Future<ProductResponse> getAllProducts({int limit = 100, int skip = 0}) async {
    final response = await _dio.get('products', queryParameters: {'limit': limit, 'skip': skip});
    return ProductResponse.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<Product> getProduct(int id) async {
    final response = await _dio.get('products/$id');
    return Product.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<ProductResponse> searchProducts(String query) async {
    final response = await _dio.get('products', queryParameters: {'q': query});
    return ProductResponse.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<List<String>> getCategories() async {
    final response = await _dio.get('categories');
    return List<String>.from(response.data['categories'] ?? []);
  }

  Future<List<String>> getCategoryList() => getCategories();

  Future<ProductResponse> getProductsByCategory(String category) async {
    final response = await _dio.get('products', queryParameters: {'category': category});
    return ProductResponse.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<ProductResponse> sortProducts(String sortBy, String order) async {
    final response = await _dio.get('products', queryParameters: {'sortBy': sortBy, 'order': order});
    return ProductResponse.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<Product> addProduct(Map<String, dynamic> data) async {
    final response = await _dio.post('products', data: data);
    return Product.fromJson(Map<String, dynamic>.from(response.data['product']));
  }

  Future<Product> updateProduct(int id, Map<String, dynamic> data) async {
    final response = await _dio.put('products/$id', data: data);
    return Product.fromJson(Map<String, dynamic>.from(response.data['product']));
  }

  Future<Product> patchProduct(int id, Map<String, dynamic> data) => updateProduct(id, data);

  Future<void> deleteProduct(int id) async {
    await _dio.delete('products/$id');
  }
}
