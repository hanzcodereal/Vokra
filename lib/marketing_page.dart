import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MarketingPage extends StatefulWidget {
  final String sessionKey;
  final String role;

  const MarketingPage({
    super.key,
    required this.sessionKey,
    required this.role,
  });

  @override
  State<MarketingPage> createState() => _MarketingPageState();
}

class _MarketingPageState extends State<MarketingPage> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  final Color neonRed = const Color(0xFFFF2E63);
  final Color neonRedLight = const Color(0xFFFF6B8A);
  final Color neonRedDark = const Color(0xFFC41E3A);
  final Color bgDark = const Color(0xFF05050A);
  final Color bgCard = const Color(0xFF0A0A14);
  final Color bgSurface = const Color(0xFF11111F);
  final Color textPrimary = const Color(0xFFF3F8FF);
  final Color textMuted = const Color(0xFF8A93B5);

  List<Product> _products = [];
  bool _isLoading = true;
  bool _isAddingProduct = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _telegramController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.9).animate(_glowController);
    _loadProducts();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _whatsappController.dispose();
    _telegramController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = prefs.getString('marketing_products_${widget.sessionKey}');
      if (productsJson != null) {
        final List<dynamic> decoded = jsonDecode(productsJson);
        _products = decoded.map((p) => Product.fromJson(p)).toList();
      }
    } catch (e) {
      _products = [];
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = jsonEncode(_products.map((p) => p.toJson()).toList());
    await prefs.setString('marketing_products_${widget.sessionKey}', productsJson);
  }

  void _addProduct() {
    _nameController.clear();
    _priceController.clear();
    _descriptionController.clear();
    _imageUrlController.clear();
    _whatsappController.clear();
    _telegramController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bgCard,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: neonRed.withOpacity(0.4)),
                boxShadow: [
                  BoxShadow(color: neonRed.withOpacity(0.2), blurRadius: 30, spreadRadius: 5, offset: const Offset(0, 10)),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [neonRed, neonRedDark]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.add_business_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "ADD PRODUCT",
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 16,
                            color: neonRed,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildDialogInput(
                      controller: _nameController,
                      label: "PRODUCT NAME",
                      icon: Icons.shopping_bag_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildDialogInput(
                      controller: _priceController,
                      label: "PRICE (IDR)",
                      icon: Icons.attach_money_rounded,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _buildDialogInput(
                      controller: _descriptionController,
                      label: "DESCRIPTION",
                      icon: Icons.description_rounded,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    _buildDialogInput(
                      controller: _imageUrlController,
                      label: "IMAGE URL (CATBOX/IMGUR)",
                      icon: Icons.image_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildDialogInput(
                      controller: _whatsappController,
                      label: "WHATSAPP NUMBER",
                      icon: Icons.chat_rounded,
                      hint: "628xxxxxxxxxx",
                    ),
                    const SizedBox(height: 12),
                    _buildDialogInput(
                      controller: _telegramController,
                      label: "TELEGRAM USERNAME",
                      icon: Icons.send_rounded,
                      hint: "@username",
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Text("CANCEL", style: TextStyle(color: textMuted, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_nameController.text.trim().isEmpty ||
                                  _priceController.text.trim().isEmpty) {
                                _showSnackbar("NAME AND PRICE ARE REQUIRED", isError: true);
                                return;
                              }
                              final newProduct = Product(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                name: _nameController.text.trim(),
                                price: int.tryParse(_priceController.text.trim()) ?? 0,
                                description: _descriptionController.text.trim(),
                                imageUrl: _imageUrlController.text.trim(),
                                whatsapp: _whatsappController.text.trim(),
                                telegram: _telegramController.text.trim(),
                                createdAt: DateTime.now(),
                              );
                              setState(() {
                                _products.insert(0, newProduct);
                              });
                              await _saveProducts();
                              Navigator.pop(context);
                              _showSnackbar("PRODUCT ADDED SUCCESSFULLY");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: neonRed,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text("ADD PRODUCT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _deleteProduct(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: neonRed.withOpacity(0.5)),
        ),
        title: Text("DELETE PRODUCT", style: TextStyle(color: neonRed, fontFamily: 'Orbitron', fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete this product?", style: TextStyle(color: textMuted, fontFamily: 'ShareTechMono')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("CANCEL", style: TextStyle(color: textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _products.removeWhere((p) => p.id == id);
              });
              _saveProducts();
              Navigator.pop(context);
              _showSnackbar("PRODUCT DELETED");
            },
            style: ElevatedButton.styleFrom(backgroundColor: neonRed),
            child: const Text("DELETE", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _contactSeller(String? whatsapp, String? telegram) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: neonRed.withOpacity(0.3))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: neonRed.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "CONTACT SELLER",
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 18,
                color: neonRed,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
            if (whatsapp != null && whatsapp.isNotEmpty)
              _buildContactButton(
                icon: Icons.chat_rounded,
                label: "WHATSAPP",
                color: const Color(0xFF25D366),
                onTap: () async {
                  final number = whatsapp.replaceAll(RegExp(r'[^0-9]'), '');
                  await launchUrl(Uri.parse('https://wa.me/$number'));
                },
              ),
            if (telegram != null && telegram.isNotEmpty)
              const SizedBox(height: 12),
            if (telegram != null && telegram.isNotEmpty)
              _buildContactButton(
                icon: Icons.send_rounded,
                label: "TELEGRAM",
                color: const Color(0xFF0088cc),
                onTap: () async {
                  final username = telegram.replaceAll('@', '');
                  await launchUrl(Uri.parse('https://t.me/$username'));
                },
              ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("CLOSE", style: TextStyle(color: textMuted, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontFamily: 'ShareTechMono'),
      decoration: InputDecoration(
        hintText: hint ?? label,
        hintStyle: TextStyle(color: textMuted.withOpacity(0.5), fontSize: 12),
        prefixIcon: Icon(icon, color: neonRed, size: 18),
        filled: true,
        fillColor: bgSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: neonRed.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: neonRed, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'ShareTechMono', fontWeight: FontWeight.bold)),
        backgroundColor: isError ? neonRed : neonRedDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canAddProduct = widget.role.toLowerCase() == 'owner' || widget.role.toLowerCase() == 'admin' || widget.role.toLowerCase() == 'reseller';

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: neonRed),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [neonRed, neonRedDark]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              "MARKETPLACE",
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 14,
                color: neonRed,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          if (canAddProduct)
            IconButton(
              icon: Icon(Icons.add_rounded, color: neonRed),
              onPressed: _addProduct,
              tooltip: "ADD PRODUCT",
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color(0xFFFF2E63)),
                  const SizedBox(height: 16),
                  Text(
                    "LOADING PRODUCTS",
                    style: TextStyle(color: neonRed.withOpacity(0.7), fontSize: 11, fontFamily: 'ShareTechMono', letterSpacing: 2),
                  ),
                ],
              ),
            )
          : _products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, color: textMuted, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        "NO PRODUCTS AVAILABLE",
                        style: TextStyle(color: textMuted, fontFamily: 'Orbitron', fontSize: 14, letterSpacing: 1),
                      ),
                      const SizedBox(height: 8),
                      if (canAddProduct)
                        TextButton.icon(
                          onPressed: _addProduct,
                          icon: Icon(Icons.add_rounded, color: neonRed),
                          label: Text("ADD FIRST PRODUCT", style: TextStyle(color: neonRed)),
                        ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadProducts,
                  color: neonRed,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return _buildProductCard(product, canAddProduct);
                    },
                  ),
                ),
    );
  }

  Widget _buildProductCard(Product product, bool canDelete) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: bgCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: neonRed.withOpacity(0.25 + (0.1 * _glowAnimation.value)), width: 1.2),
            boxShadow: [
              BoxShadow(color: neonRed.withOpacity(0.05 * _glowAnimation.value), blurRadius: 15, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(23)),
                  child: Image.network(
                    product.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: bgSurface,
                      child: Center(
                        child: Icon(Icons.image_not_supported_rounded, color: textMuted, size: 48),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 18,
                              color: neonRed,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        if (canDelete)
                          GestureDetector(
                            onTap: () => _deleteProduct(product.id),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: neonRed.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: neonRed.withOpacity(0.3)),
                              ),
                              child: Icon(Icons.delete_outline_rounded, color: neonRed, size: 18),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.attach_money_rounded, color: neonRed, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "Rp${product.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 20,
                            color: neonRedLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (product.description.isNotEmpty)
                      Text(
                        product.description,
                        style: TextStyle(
                          fontFamily: 'ShareTechMono',
                          fontSize: 13,
                          color: textMuted,
                          height: 1.4,
                        ),
                      ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _contactSeller(product.whatsapp, product.telegram),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [neonRed, neonRedDark]),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(color: neonRed.withOpacity(0.3), blurRadius: 8),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.contact_support_rounded, color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    "CONTACT SELLER",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Posted: ${_formatDate(product.createdAt)}",
                      style: TextStyle(
                        fontFamily: 'ShareTechMono',
                        fontSize: 10,
                        color: textMuted.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}

class Product {
  final String id;
  final String name;
  final int price;
  final String description;
  final String imageUrl;
  final String whatsapp;
  final String telegram;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.whatsapp,
    required this.telegram,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'description': description,
    'imageUrl': imageUrl,
    'whatsapp': whatsapp,
    'telegram': telegram,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    name: json['name'],
    price: json['price'],
    description: json['description'] ?? '',
    imageUrl: json['imageUrl'] ?? '',
    whatsapp: json['whatsapp'] ?? '',
    telegram: json['telegram'] ?? '',
    createdAt: DateTime.parse(json['createdAt']),
  );
}