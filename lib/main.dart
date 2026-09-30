
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Products API',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const ProductPage(),
    );
  }
}

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<dynamic> products = [];

  bool isLoading = true;
  String errorMessage = '';

  // NEW API
  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://fakestoreapi.com/products'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          products = data;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              'Failed to load products.\nStatus code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Products List',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: fetchProducts,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),

                      const SizedBox(height: 15),

                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: fetchProducts,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchProducts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];

                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              // PRODUCT IMAGE
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(10),
                                child: Image.network(
                                  product['image'].toString(),
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.contain,
                                  errorBuilder:
                                      (context, error, stackTrace) {
                                    return Container(
                                      width: 90,
                                      height: 90,
                                      color: Colors.grey.shade300,
                                      child: const Icon(
                                        Icons
                                            .image_not_supported,
                                      ),
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(width: 15),

                              // PRODUCT DETAILS
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['title'].toString(),
                                      maxLines: 2,
                                      overflow:
                                          TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    Text(
                                      'Category: ${product['category']}',
                                      style: TextStyle(
                                        color:
                                            Colors.grey.shade700,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    Text(
                                      '\$${product['price']}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight:
                                            FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          size: 18,
                                          color: Colors.orange,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          '${product['rating']['rate']}',
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          '(${product['rating']['count']} reviews)',
                                          style: TextStyle(
                                            color: Colors
                                                .grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
