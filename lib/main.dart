import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/auth_gate.dart';
import 'screens/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProductApp());
}

class ProductApp extends StatelessWidget {
  const ProductApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Fieldnotes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF795548)),
        useMaterial3: true,
      ),
      home: AuthGate(
        authenticatedBuilder: (context) => const ProductHomePage(),
      ),
    );
  }
}

class ProductHomePage extends StatefulWidget {
  const ProductHomePage({super.key});

  @override
  State<ProductHomePage> createState() => _ProductHomePageState();
}

class _ProductHomePageState extends State<ProductHomePage> {
  final CollectionReference<Map<String, dynamic>> products = FirebaseFirestore
      .instance
      .collection('products');

  final TextEditingController searchController = TextEditingController();
  final TextEditingController minController = TextEditingController();
  final TextEditingController maxController = TextEditingController();

  String searchText = '';

  @override
  void dispose() {
    searchController.dispose();
    minController.dispose();
    maxController.dispose();
    super.dispose();
  }

  double? get minPrice {
    if (minController.text.trim().isEmpty) return null;
    return double.tryParse(minController.text.trim());
  }

  double? get maxPrice {
    if (maxController.text.trim().isEmpty) return null;
    return double.tryParse(maxController.text.trim());
  }

  bool get minInvalid {
    if (minController.text.trim().isEmpty) return false;
    final value = minPrice;
    return value == null || !value.isFinite || value < 0;
  }

  bool get maxInvalid {
    if (maxController.text.trim().isEmpty) return false;
    final value = maxPrice;
    return value == null || !value.isFinite || value < 0;
  }

  bool get rangeInvalid {
    if (minInvalid || maxInvalid) return false;

    final min = minPrice;
    final max = maxPrice;

    return min != null && max != null && min > max;
  }

  Future<void> showProductDialog({
    DocumentSnapshot<Map<String, dynamic>>? product,
  }) async {
    final data = product?.data();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return ProductEditorDialog(
          initialName: data?['name']?.toString() ?? '',
          initialPrice: data?['price']?.toString() ?? '',
          isEditing: product != null,
        );
      },
    );

    if (result == null) return;
    if (!mounted) return;

    try {
      if (product == null) {
        await products.add(result);
      } else {
        await products.doc(product.id).update(result);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            product == null
                ? 'Product added successfully!'
                : 'Product updated successfully!',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  }

  Future<void> deleteProduct(
    DocumentSnapshot<Map<String, dynamic>> product,
  ) async {
    final name = product.data()?['name'] ?? 'this product';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Product?'),
          content: Text('Are you sure you want to delete "$name"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await products.doc(product.id).delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully!')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  void resetFilters() {
    setState(() {
      searchController.clear();
      minController.clear();
      maxController.clear();
      searchText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🍂 Firebase Fieldnotes'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'My Profile',
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              final user = AuthService.instance.currentUser;

              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfileScreen(user: user)),
                );
              }
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showProductDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchText = value.trim().toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Search products by name',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        setState(() {
                          searchText = '';
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: 'Minimum price',
                          prefixText: '\$',
                          errorText: minInvalid
                              ? 'Enter a valid nonnegative price'
                              : null,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: TextField(
                        controller: maxController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: 'Maximum price',
                          prefixText: '\$',
                          errorText: maxInvalid
                              ? 'Enter a valid nonnegative price'
                              : null,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),

                if (rangeInvalid)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Minimum price cannot exceed maximum price.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: resetFilters,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset filters'),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: products.snapshots(includeMetadataChanges: true),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Error loading products:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allProducts = snapshot.data!.docs;

                if (minInvalid || maxInvalid || rangeInvalid) {
                  return const Center(
                    child: Text('Please correct the price filters.'),
                  );
                }

                final filteredProducts = allProducts.where((doc) {
                  final data = doc.data();

                  final name = (data['name'] ?? '').toString().toLowerCase();

                  final rawPrice = data['price'];

                  if (rawPrice is! num) return false;

                  final price = rawPrice.toDouble();

                  if (!price.isFinite) return false;

                  final matchesName = name.contains(searchText);

                  final matchesMin = minPrice == null || price >= minPrice!;

                  final matchesMax = maxPrice == null || price <= maxPrice!;

                  return matchesName && matchesMin && matchesMax;
                }).toList();

                return Column(
                  children: [
                    if (snapshot.data!.metadata.isFromCache)
                      Container(
                        width: double.infinity,
                        color: Colors.orange.shade100,
                        padding: const EdgeInsets.all(10),
                        child: const Row(
                          children: [
                            Icon(Icons.cloud_off),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Showing cached data. Changes will sync when online.',
                              ),
                            ),
                          ],
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        '${filteredProducts.length} products found',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),

                    Expanded(
                      child: filteredProducts.isEmpty
                          ? Center(
                              child: Text(
                                allProducts.isEmpty
                                    ? 'No products yet.\nTap Add Product to begin!'
                                    : 'No matching products found.',
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 90),
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                final doc = filteredProducts[index];
                                final data = doc.data();

                                final name = data['name'] ?? 'Unnamed';
                                final rawPrice = data['price'];

                                final price = rawPrice is num
                                    ? rawPrice.toDouble()
                                    : 0.0;

                                return Card(
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                      child: Icon(Icons.shopping_bag),
                                    ),
                                    title: Text(name.toString()),
                                    subtitle: Text('Document ID: ${doc.id}'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '\$${price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          onSelected: (choice) {
                                            if (choice == 'edit') {
                                              showProductDialog(product: doc);
                                            } else if (choice == 'delete') {
                                              deleteProduct(doc);
                                            }
                                          },
                                          itemBuilder: (context) => const [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Text('Edit'),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Separate stateful dialog owns its controllers.
// They are disposed when the dialog widget is removed.
class ProductEditorDialog extends StatefulWidget {
  final String initialName;
  final String initialPrice;
  final bool isEditing;

  const ProductEditorDialog({
    super.key,
    required this.initialName,
    required this.initialPrice,
    required this.isEditing,
  });

  @override
  State<ProductEditorDialog> createState() => _ProductEditorDialogState();
}

class _ProductEditorDialogState extends State<ProductEditorDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController priceController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.initialName);

    priceController = TextEditingController(text: widget.initialPrice);
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  void saveProduct() {
    if (!_formKey.currentState!.validate()) return;

    final price = double.parse(priceController.text.trim());

    Navigator.of(context)
        .pop({'name': nameController.text.trim(), 'price': price});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditing ? 'Edit Product' : 'Add Product'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Product name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name cannot be empty.';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Price',
                prefixText: '\$',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final price = double.tryParse(value?.trim() ?? '');

                if (price == null || !price.isFinite || price < 0) {
                  return 'Enter a valid nonnegative price.';
                }

                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: saveProduct, child: const Text('Save')),
      ],
    );
  }
}
