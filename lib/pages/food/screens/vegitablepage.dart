import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:ecommerceapp/pages/food/screens/detailspage.dart';
import 'package:ecommerceapp/pages/food/screens/vegdetailpage.dart';
import 'package:ecommerceapp/pages/home/models/Fruitsmodel.dart';
import 'package:ecommerceapp/pages/home/models/vegitablemodel.dart';
import 'package:ecommerceapp/pages/home/screens/searchpage.dart';
import 'package:ecommerceapp/pages/home/screens/vegsearch.dart';
import 'package:flutter/material.dart';

class vegitablepages extends StatefulWidget {
  const vegitablepages({super.key});

  @override
  State<vegitablepages> createState() => _vegitablepagesState();
}

num _parsePrice(dynamic price) {
  if (price == null) return 0;
  if (price is num) return price;
  if (price is String) return num.tryParse(price) ?? 0;
  return 0;
}

class _vegitablepagesState extends State<vegitablepages> {
  List<GetVegdata> vegi = [];
  bool isLoading = true;
  final TextEditingController _controller = TextEditingController();
  bool shows = true; // selection mode
  final Set<GetVegdata> selectedvegs = {};

  @override
  void initState() {
    super.initState();
    fetchFruits();
    // Do NOT call deleteselectedvegss() here!
  }

// ...existing code...
Future<void> fetchFruits() async {
  try {
    final response =
        await Dio().get('http://192.168.0.14:8000/api/products/category/vegetable/');
    // Filter for only vegetables (assuming category is 'Vegetable' or category_id == 2)
    final allProducts = getVegdataFromJson(jsonEncode(response.data));
    setState(() {
      vegi = allProducts.where((item) =>
        (item.category?.toLowerCase() == 'vegetable') || (item.category == 2)
      ).toList();
      isLoading = false;
    });
  } catch (e) {
    print('Error fetching fruits: $e');
    setState(() => isLoading = false);
  }
}
  Future<void> deleteselectedvegss() async {
    if (selectedvegs.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete'),
        content: const Text('Are you sure you want to delete the selected fruits?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        isLoading = true;
      });
      try {
        final ids = selectedvegs.map((v) => v.id).toList();
        final response = await Dio().delete(
          'http://192.168.0.14:8000/api/products/delete/selected/', // <-- Your bulk delete endpoint
          data: jsonEncode({'ids': ids}), 
          options: Options(
            headers: {'Content-Type': 'application/json'},
          ),
        );

        if (response.statusCode == 200 || response.statusCode == 204) {
          setState(() {
            vegi.removeWhere((fruit) => ids.contains(fruit.id));
            selectedvegs.clear();
            shows = true; // Exit selection mode
            isLoading = false;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete selected fruits.')),
          );
          setState(() => isLoading = false); 
        }
      } catch (e) {
        print('Error deleting selected fruits: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting selected fruits: $e')),
        );
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text("Popular Vegitable"),
        centerTitle: true,
        actions: [
          Row(
            children: [
              shows
                  ? Checkbox(
                      value: shows,
                      onChanged: (val) {
                        setState(() {
                          shows = val ?? false;
                          selectedvegs.clear();
                        });
                      },
                    )
                  : Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${selectedvegs.length}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: selectedvegs.isEmpty
                              ? null
                              : () async {
                                  await deleteselectedvegss();
                                },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          tooltip: "Cancel selection",
                          onPressed: () {
                            setState(() {
                              shows = true;
                              selectedvegs.clear();
                            });
                          },
                        ),
                      ],
                    ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchFruits();
        },
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 15, top: 15, bottom: 15),
                    child: _searchBar(),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 0.91,
                            crossAxisCount: 2),
                        scrollDirection: Axis.vertical,
                        itemCount: vegi.length,
                        itemBuilder: (context, index) {
                          final vegit = vegi[index];
                          final isSelected = selectedvegs.contains(vegit);

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                width: !shows
                                    ? MediaQuery.of(context).size.width * 0.32
                                    : MediaQuery.of(context).size.width * 0.45,
                                child: GestureDetector(
                                   onLongPress: () {
                                    setState(() {
                                      shows = false;
                                       selectedvegs.clear();
                                       selectedvegs.add(vegit);
                                        if (selectedvegs.isEmpty ) {
                                        shows = true;
                                      }
                                    });
                                    },
                                  onTap: () {
                                    if (!shows) {
                                      setState(() {
                                        if (isSelected) {
                                          selectedvegs.remove(vegit);
                                        } else {
                                          selectedvegs.add(vegit);
                                        }
                                        if (selectedvegs.isEmpty) {
                                        shows = true;
                                        }
                                      });
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => vegDetailsPage(id: vegit.id),
                                        ),
                                      );
                                    }
                                  },
                                  child: Card(
                                    shadowColor: Colors.blueGrey,
                                    borderOnForeground: true,
                                    color: Colors.white,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            topRight: Radius.circular(15),
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: vegit.imageUrl ?? "",
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: 100,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10.0, top: 10),
                                          child: Text(
                                            vegit.name ?? ' ',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10.0),
                                          child: RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'Price ',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: '\$',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.orange,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: '${vegit.price}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.orange,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              if (!shows)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 4.0, top: 20),
                                    child: Checkbox(
                                      value: isSelected,
                                      onChanged: (val) {
                                        setState(() {
                                          if (val == true) {
                                            selectedvegs.add(vegit);
                                          } else {
                                            selectedvegs.remove(vegit);
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _searchBar() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchveggPage(veg: vegi ),
                ),
              );
            },
            child: AbsorbPointer(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFFB5B5B5).withOpacity(0.2),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    const Icon(Icons.search),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Search...',
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                        enabled: false, // disables editing
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        PopupMenuButton<String>(
          icon: const Icon(Icons.sort),
          onSelected: (value) {
            setState(() {
              if (value == 'Alphabetical') {
                vegi.sort((a, b) {
                  final nameA = (a.name ?? '').toLowerCase();
                  final nameB = (b.name ?? '').toLowerCase();
                  return nameA.compareTo(nameB);
                });
              } else if (value == 'Low to High') {
                vegi.sort((a, b) =>
                    _parsePrice(a.price).compareTo(_parsePrice(b.price)));
              } else if (value == 'High to Low') {
                vegi.sort((a, b) =>
                    _parsePrice(b.price).compareTo(_parsePrice(a.price)));
              } else if (value == 'All') {
                fetchFruits(); // reload original order
              }
            });
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'Alphabetical',
              child: Text('Alphabetical'),
            ),
            const PopupMenuItem(
              value: 'High to Low',
              child: Text('High to Low'),
            ),
            const PopupMenuItem(
              value: 'Low to High',
              child: Text('Low to High'),
            ),
            const PopupMenuItem(
              value: 'All',
              child: Text('All'),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}