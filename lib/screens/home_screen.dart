import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_firebase_app/screens/order_history_screen.dart';
import 'package:todo_firebase_app/providers/cart_provider.dart';
import 'package:todo_firebase_app/screens/cart_screen.dart';
import 'package:todo_firebase_app/screens/product_detail_screen.dart';
import 'package:todo_firebase_app/widgets/product_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedIndex = 0;

  static const Color primaryColor = Colors.greenAccent;
  static const Color accentColor = Colors.orangeAccent;
  static const Color backgroundColor = Color(0xFFF5F5F5);

  late List<ProductSection> _sections;

  @override
  void initState() {
    super.initState();
    _sections = [
      // Section 1: Painting Supplies
      ProductSection(
        collectionName: 'Painting Supplies',
        demoProducts: [
          {
            'name': 'Acrylic Paint Set',
            'price': 500.00,
            'description': 'High-quality 24-color acrylic paint set.',
            'imageUrl': 'https://m.media-amazon.com/images/I/81f-ZhAXeWL._AC_SL1500_.jpg',
          },
          {
            'name': 'Watercolor Paper',
            'price': 250.00,
            'description': '12 sheets of 200gsm watercolor paper.',
            'imageUrl': 'https://projectworkshopph.com/cdn/shop/files/FullSizeRender_df6b6423-ac80-4bd0-ac34-354c85808afb.jpg?v=1695279327',
          },
          {
            'name': 'Paint Brushes Set',
            'price': 350.00,
            'description': '10-piece assorted brushes.',
            'imageUrl': 'https://img.lazcdn.com/g/p/406540d0d5eb1adc42877d9e27b82398.jpg_720x720q80.jpg',
          },
        ],
        searchQuery: _searchQuery,
      ),
      ProductSection(
        collectionName: 'Crafting Materials',
        demoProducts: [
          {
            'name': 'Beads Kit',
            'price': 300.00,
            'description': 'Multicolor beads for jewelry making.',
            'imageUrl': 'https://example.com/beads.jpg',
          },
          {
            'name': 'Craft Glue',
            'price': 120.00,
            'description': 'Strong adhesive for multiple surfaces.',
            'imageUrl': 'https://example.com/glue.jpg',
          },
          {
            'name': 'Scissors',
            'price': 180.00,
            'description': 'Ergonomic handle, sharp blades for crafting.',
            'imageUrl': 'https://example.com/scissors.jpg',
          },
        ],
        searchQuery: _searchQuery,
      ),

      ProductSection(
        collectionName: 'Paper & Stationery',
        demoProducts: [
          {
            'name': 'Colored Paper Pack',
            'price': 200.00,
            'description': '50 sheets assorted colors for drawing & crafts.',
            'imageUrl': 'https://example.com/colored_paper.jpg',
          },
          {
            'name': 'Sketchbook',
            'price': 400.00,
            'description': '100 pages, 200gsm for sketching and drawing.',
            'imageUrl': 'https://example.com/sketchbook.jpg',
          },
          {
            'name': 'Markers Set',
            'price': 350.00,
            'description': '24 vibrant color markers for creative projects.',
            'imageUrl': 'https://example.com/markers.jpg',
          },
        ],
        searchQuery: _searchQuery,
      ),
    ];
  }
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
      body: IndexedStack(
        index: _selectedIndex,
        children: _sections.map((section) => ProductSection(
          collectionName: section.collectionName,
          demoProducts: section.demoProducts,
          searchQuery: _searchQuery,
        )).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.tag_sharp),
            label: 'Home and Super Sales',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen),
            label: 'Kitchenware',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.devices)
              , label: 'Appliances'),
        ],
      ),
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
              hintText: 'Search products...',
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
                icon: const Icon(Icons.shopping_basket),
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
        // --- ADDED THIS NEW BUTTON ---
        IconButton(
          icon: const Icon(Icons.receipt_long), // A "receipt" icon
          tooltip: 'My Orders',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const OrderHistoryScreen(),
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
}

class ProductSection extends StatefulWidget {
  final String collectionName;
  final List<Map<String, dynamic>> demoProducts;
  final String searchQuery;

  const ProductSection({
    required this.collectionName,
    required this.demoProducts,
    required this.searchQuery,
    super.key,
  });

  @override
  State<ProductSection> createState() => _ProductSectionState();
}

class _ProductSectionState extends State<ProductSection> {
  late final CollectionReference _productsCollection;

  @override
  void initState() {
    super.initState();
    _productsCollection = FirebaseFirestore.instance.collection(widget.collectionName);
  }

  List<Map<String, dynamic>> _filterProducts(List<Map<String, dynamic>> products) {
    if (widget.searchQuery.isEmpty) return products;
    return products.where((product) =>
        product['name'].toString().toLowerCase().contains(widget.searchQuery)).toList();
  }

  @override
  Widget build(BuildContext context) {
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

          // Fallback to demo products if no Firestore data
          final filteredDemo = _filterProducts(widget.demoProducts);
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
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2, // Responsive
        childAspectRatio: 0.8, // Adjusted for better card fit
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 6, // Show 6 shimmer placeholders
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

  Widget _buildProductGrid(List<Map<String, dynamic>> products, {required bool isFirestore}) {
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
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2, // Responsive
        childAspectRatio: 0.8, // Better proportions
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
                  productId: isFirestore ? '${widget.collectionName}_${index}' : 'demo_${widget.collectionName}_${index + 1}',
                ),
              ),
            );
          },
        );
      },
    );
  }
}
