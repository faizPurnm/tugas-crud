import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/product_model.dart';
import '../providers/product_providers.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;
  const EditProductScreen({super.key, required this.product});
  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title, _price, _description, _category, _stock, _brand, _thumbnail;
  bool _loading = false;
  @override
  void initState() { super.initState(); final p = widget.product; _title = TextEditingController(text: p.title ?? ''); _price = TextEditingController(text: (p.price ?? 0).toString()); _description = TextEditingController(text: p.description ?? ''); _category = TextEditingController(text: p.category ?? 'Umum'); _stock = TextEditingController(text: (p.stock ?? 0).toString()); _brand = TextEditingController(text: p.brand ?? ''); _thumbnail = TextEditingController(text: p.thumbnail ?? ''); }
  @override
  void dispose() { _title.dispose(); _price.dispose(); _description.dispose(); _category.dispose(); _stock.dispose(); _brand.dispose(); _thumbnail.dispose(); super.dispose(); }
  Widget _field(String label, TextEditingController c, {bool number = false, int lines = 1, bool required = false}) => Padding(padding: const EdgeInsets.only(bottom: 13), child: TextFormField(controller: c, maxLines: lines, keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()), validator: (v) { if (required && (v == null || v.trim().isEmpty)) return '$label wajib diisi'; if (number && v != null && v.isNotEmpty && (double.tryParse(v) == null || double.parse(v) < 0)) return 'Masukkan angka yang valid'; if (label == 'Stok' && v != null && v.isNotEmpty && int.tryParse(v) == null) return 'Stok harus berupa bilangan bulat'; return null; }));
  Future<void> _update() async { if (!_formKey.currentState!.validate()) return; setState(() => _loading = true); final ok = await context.read<ProductProvider>().updateProductData(widget.product.id!, {'title': _title.text.trim(), 'price': double.parse(_price.text), 'description': _description.text.trim(), 'category': _category.text.trim(), 'stock': int.tryParse(_stock.text) ?? 0, 'brand': _brand.text.trim(), 'thumbnail': _thumbnail.text.trim()}); if (!mounted) return; setState(() => _loading = false); if (ok) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produk berhasil diperbarui'))); context.go('/'); } else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.read<ProductProvider>().error ?? 'Gagal memperbarui produk'))); } }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Edit Produk')), body: Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(18), children: [_field('Nama produk', _title, required: true), _field('Harga (Rp)', _price, number: true, required: true), _field('Kategori', _category, required: true), _field('Deskripsi', _description, lines: 3), _field('Stok', _stock, number: true), _field('Merek', _brand), _field('URL gambar', _thumbnail), const SizedBox(height: 8), FilledButton.icon(onPressed: _loading ? null : _update, icon: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save), label: Text(_loading ? 'Memperbarui...' : 'Simpan Perubahan'))])));
}
