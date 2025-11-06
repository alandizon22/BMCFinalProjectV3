import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_firebase_app/providers/cart_provider.dart';
import 'package:todo_firebase_app/screens/cart_screen.dart';
import 'package:todo_firebase_app/screens/product_detail_screen.dart';
import 'package:todo_firebase_app/widgets/product_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ArtCraftSection extends StatefulWidget {
  const ArtCraftSection({super.key});

  @override
  State<ArtCraftSection> createState() => _ArtCraftSectionState();
}

class _ArtCraftSectionState extends State<ArtCraftSection> {
  final CollectionReference _productsCollection =
  FirebaseFirestore.instance.collection('artcraft_products');
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const Color primaryColor = Colors.greenAccent;
  static const Color accentColor = Colors.orangeAccent;
  static const Color backgroundColor = Color(0xFFF5F5F5);

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logged out successfully")),
      );
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<Map<String, dynamic>> _filterProducts(List<Map<String, dynamic>> products) {
    if (_searchQuery.isEmpty) return products;
    return products
        .where((product) => product['name'].toString().toLowerCase().contains(_searchQuery))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Art & Craft Materials Store',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, accentColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search art & craft items...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
      actions: [
        Consumer<CartProvider>(
          builder: (context, cart, child) {
            return Badge(
              label: Text(cart.itemCount.toString()),
              isLabelVisible: cart.itemCount > 0,
              child: IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CartScreen(),
                    ),
                  );
                },
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _logout,
        ),
      ],
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: StreamBuilder<QuerySnapshot>(
        stream: _productsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load products. Please try again.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            final products = snapshot.data!.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
            final filteredProducts = _filterProducts(products);
            return _buildProductGrid(filteredProducts, isFirestore: true);
          }

          // Demo products if Firestore is empty
          final demoProducts = [
            {
              'name': 'Acrylic Paint Set',
              'price': 120.00,
              'description': 'Vibrant colors for all your art projects.',
              'imageUrl':
              'https://example.com/acrylic_paint.jpg',
            },
            {
              'name': 'Watercolor Paper Pad',
              'price': 250.00,
              'description': 'High-quality paper for watercolor painting.',
              'imageUrl':
              'https://example.com/watercolor_paper.jpg',
            },
            {
              'name': 'Brush Set',
              'price': 150.00,
              'description': 'Set of various brushes for painting.',
              'imageUrl':
              'https://example.com/brush_set.jpg',
            },
          ];

          final filteredDemo = _filterProducts(demoProducts);
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Demo Products (No data available)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(child: _buildProductGrid(filteredDemo, isFirestore: false)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductGrid(List<Map<String, dynamic>> products,
      {required bool isFirestore}) {
    if (products.isEmpty) {
      return const Center(
        child: Text(
          'No products found matching your search.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          productData: product,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(
                  productData: product,
                  productId: isFirestore ? 'firestore_${index}' : 'demo_${index + 1}',
                ),
              ),
            );
          },
        );
      },
    );
  }
}