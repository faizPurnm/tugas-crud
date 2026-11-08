import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/product_model.dart';
import '../services/api_services_product.dart';

class ProductProvider extends ChangeNotifier {
  final ApiServiceProducts _api = ApiServiceProducts();
  List<Product> _products = [];
  List<String> _categoryList = [];
  bool _loading = false;
  String? _error;
  int _total = 0;
  int _skip = 0;
  String _selectedCategory = '';

  List<Product> get product => _products;
  List<String> get categoryList => _categoryList;
  bool get loading => _loading;
  int get total => _total;
  int get skip => _skip;
  String get selectedCategory => _selectedCategory;
  String? get error => _error;

  Future<void> fetchProduct({int limit = 100, int skip = 0}) async {
    _loading = true; _error = null; _selectedCategory = ''; notifyListeners();
    try {
      final res = await _api.getAllProducts(limit: limit, skip: skip);
      _products = res.product ?? []; _total = res.total ?? _products.length; _skip = res.skip ?? 0;
    } catch (e) { _error = _message(e); }
    _loading = false; notifyListeners();
  }

  Future<void> fetchCategories() async {
    try { _categoryList = await _api.getCategoryList(); notifyListeners(); }
    catch (e) { _error = _message(e); notifyListeners(); }
  }

  Future<void> searchProducts(String query) async {
    if (query.trim().isEmpty) return fetchProduct();
    _loading = true; _error = null; notifyListeners();
    try { final res = await _api.searchProducts(query.trim()); _products = res.product ?? []; }
    catch (e) { _error = _message(e); }
    _loading = false; notifyListeners();
  }

  Future<void> filterByCategory(String category) async {
    _selectedCategory = category; _loading = true; _error = null; notifyListeners();
    try { final res = await _api.getProductsByCategory(category); _products = res.product ?? []; }
    catch (e) { _error = _message(e); }
    _loading = false; notifyListeners();
  }

  Future<void> sortProducts(String sortBy, String order) async {
    _loading = true; _error = null; notifyListeners();
    try { final res = await _api.sortProducts(sortBy, order); _products = res.product ?? []; }
    catch (e) { _error = _message(e); }
    _loading = false; notifyListeners();
  }

  Future<bool> addProduct(Map<String, dynamic> data) async {
    _loading = true; _error = null; notifyListeners();
    try { await _api.addProduct(data); await fetchProduct(); await fetchCategories(); return true; }
    catch (e) { _error = _message(e); _loading = false; notifyListeners(); return false; }
  }

  Future<bool> updateProduct(int id, Product updated) async => updateProductData(id, updated.toJson());

  Future<bool> updateProductData(int id, Map<String, dynamic> data) async {
    _loading = true; _error = null; notifyListeners();
    try { await _api.updateProduct(id, data); await fetchProduct(); return true; }
    catch (e) { _error = _message(e); _loading = false; notifyListeners(); return false; }
  }

  Future<bool> deleteProduct(int id) async {
    _loading = true; _error = null; notifyListeners();
    try { await _api.deleteProduct(id); _products.removeWhere((p) => p.id == id); _total = _total > 0 ? _total - 1 : 0; }
    catch (e) { _error = _message(e); _loading = false; notifyListeners(); return false; }
    _loading = false; notifyListeners(); return true;
  }

  String _message(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      final uri = error.requestOptions.uri;
      final responseData = error.response?.data;

      if (status != null) {
        return 'Backend merespons HTTP $status pada $uri. '
            'Detail: ${responseData ?? error.message ?? 'Tidak ada detail'}';
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'Koneksi ke backend timeout (${error.type}). URL: $uri';
      }
      return 'Tidak dapat menghubungi backend pada $uri. '
          'Pastikan Docker Compose aktif, port 8080 terbuka, dan alamat API sesuai perangkat. '
          'Detail: ${error.message ?? error.toString()}';
    }
    return error.toString();
  }
}
