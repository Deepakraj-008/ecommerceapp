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
                                  padding: const EdgeInsets.only(left: 10.0,top: 10),
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
}
