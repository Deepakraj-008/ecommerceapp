import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:ecommerceapp/pages/food/screens/detailspage.dart';
import 'package:ecommerceapp/pages/home/models/Fruitsmodel.dart';
import 'package:flutter/material.dart';

class Fruitspages extends StatefulWidget {
  const Fruitspages({super.key});

  @override
  State<Fruitspages> createState() => _FruitspagesState();
}

class _FruitspagesState extends State<Fruitspages> {
  List<Getdata> fruits = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFruits();
  }

  Future<void> fetchFruits() async {
    try {
      final response =
          await Dio().get('http://192.168.29.208:8000/api/products/');

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
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Popular Foods"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2),
              scrollDirection: Axis.vertical,
              itemCount: fruits.length,
              itemBuilder: (context, index) {
                final fruit = fruits[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context)=> DetailsPage(id: fruit.id)));
                  },
                  child:  Container(
                    width: 200,
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: Container(
                                        height: 140,
                                        width: 140,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.grey.shade100,
                                            image: DecorationImage(
                                                image:
                                                    CachedNetworkImageProvider(
                                                  fruit.imageUrl??"",
                                                ),
                                                fit: BoxFit.cover)),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Text(fruit.name ?? '',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(height: 4),
                                  Center(
                                    child: Text('Only \$${fruit.price}',
                                        style: const TextStyle(fontSize: 14)),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
