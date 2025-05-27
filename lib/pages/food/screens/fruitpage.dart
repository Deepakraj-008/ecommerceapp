import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:ecommerceapp/pages/food/screens/detailspage.dart';
import 'package:ecommerceapp/pages/home/models/Fruitsmodel.dart';
import 'package:ecommerceapp/pages/home/screens/searchpage.dart';
import 'package:flutter/material.dart';

class Fruitspages extends StatefulWidget {
  const Fruitspages({super.key});

  @override
  State<Fruitspages> createState() => _FruitspagesState();
}

num _parsePrice(dynamic price) {
  if (price == null) return 0;
  if (price is num) return price;
  if (price is String) return num.tryParse(price) ?? 0;
  return 0;
}

class _FruitspagesState extends State<Fruitspages> {
  List<Getdata> fruits = [];
  bool isLoading = true;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchFruits();
  }

  Future<void> fetchFruits() async {
    try {
      final response =
          await Dio().get('http://192.168.0.20:8000/api/products/');

      setState(() {
        fruits = getdataFromJson(jsonEncode(response.data));
        print("$fruits");
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching fruits: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text("Popular Foods"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0,right: 15,top: 15,bottom: 15),
                    child: _searchBar(),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                                childAspectRatio: 0.91,
                                crossAxisCount: 2),
                        scrollDirection: Axis.vertical,
                        itemCount: fruits.length,
                        itemBuilder: (context, index) {
                          final fruit = fruits[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DetailsPage(id: fruit.id)));
                            },
                            child: SizedBox(
                              width: 140,
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
                                        imageUrl: fruit.imageUrl ?? "",
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 100,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10.0, top: 10),
                                      child: Text(
                                        fruit.name ?? ' ',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
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
                                              text: '${fruit.price}',
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
                  builder: (context) => SearchPage(fruits: fruits),
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
                fruits.sort((a, b) {
                  final nameA = (a.name ?? '').toLowerCase();
                  final nameB = (b.name ?? '').toLowerCase();
                  return nameA.compareTo(nameB);
                });
              } else if (value == 'Low to High') {
                fruits.sort((a, b) =>
                    _parsePrice(a.price).compareTo(_parsePrice(b.price)));
              } else if (value == 'High to Low') {
                fruits.sort((a, b) =>
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
