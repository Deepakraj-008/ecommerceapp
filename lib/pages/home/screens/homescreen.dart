import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:ecommerceapp/pages/food/screens/detailspage.dart';
import 'package:ecommerceapp/pages/food/screens/fruitpage.dart';
import 'package:ecommerceapp/pages/food/screens/vegdetailpage.dart';
import 'package:ecommerceapp/pages/food/screens/vegitablepage.dart';
import 'package:ecommerceapp/pages/home/models/Fruitsmodel.dart';
import 'package:ecommerceapp/pages/home/models/vegitablemodel.dart';
import 'package:ecommerceapp/pages/home/screens/addproducts.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Homescreenpage extends StatefulWidget {
  const Homescreenpage({super.key});

  @override
  State<Homescreenpage> createState() => _HomescreenpageState();
}

class _HomescreenpageState extends State<Homescreenpage> {
  List<Getdata> fruitss = [];
  List<GetVegdata> veg = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFruits();
    // Future.delayed(
    //     Duration(
    //       seconds: 2,
    //     ), () {
    //   fetchFruits();
    // });
    fetchvegitable();
  }

  Future<void> fetchFruits() async {
    try {
      final response = await Dio()
          .get('http://192.168.0.14:8000/api/products/category/fruit/');

      setState(() {
        fruitss = getdataFromJson(jsonEncode(response.data));
        print(response.data);
        print(
            "fruis -------------------------------------------------> $fruitss");
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching fruits: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchvegitable() async {
    try {
      final response = await Dio()
          .get('http://192.168.0.14:8000/api/products/category/vegetable/');

      setState(() {
        veg = getVegdataFromJson(jsonEncode(response.data));
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
        // appBar: AppBar(
        //   automaticallyImplyLeading: false,
        //   scrolledUnderElevation: 0,
        //   centerTitle: true,
        //   title: _title(),
        //   bottom: PreferredSize(
        //     preferredSize: const Size.fromHeight(10),
        //     child: Container(
        //       color: const Color(0xFFE7e7e7),
        //       height: 0.5,
        //     ),
        //   ),
        // ),
      drawer: Drawer(
        child: Column(
          children: [
        // Profile section (top 25%)
        Container(
          height: MediaQuery.of(context).size.height * 0.25,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          // Profile image
          CircleAvatar(
            radius: 40,
            
           // backgroundImage: AssetImage('assets/images/Avatars4.png'),
          ),
          SizedBox(height: 12),
          // User name
          Text(
            'Deepak Raj',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
            ],
          ),
        ),
        // Drawer items
        Expanded(
          child: ListView(
            children: [
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context); // Close drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context); // Close drawer
            },
          ),
          // Add more items as needed
            ],
          ),
        ),
          ],
        ),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: _title(),
        leading: Builder(
          builder: (context) => IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Container(
        color: const Color(0xFFE7e7e7),
        height: 0.5,
          ),
        ),
     
      ),
        body: RefreshIndicator(
            onRefresh: () async {
            await fetchFruits();
            await fetchvegitable();
            },
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 18.0, right: 18, top: 10, bottom: 18),
                    child: Column(children: [
                      _bannerImage(),
                      const SizedBox(height: 20),
                      _fruitsHeader(),
                      const SizedBox(height: 20),
                      Fruitsinfo(),
                      const SizedBox(height: 20),
                      _vegHeader(),
                      const SizedBox(height: 20),
                      _vegList(),
                      const SizedBox(height: 20),
                    ]),
                  ),
                ),
        ),
        floatingActionButton: _addFruit());
  }

  Widget _title() {
    return Text(
      "Food Market",
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.orange,
        fontFamily: 'Pacifico',
        letterSpacing: 1.2,
        shadows: [
          Shadow(
            blurRadius: 4,
            color: Colors.orangeAccent.withOpacity(0.4),
            offset: const Offset(2, 2),
          ),
        ],
      ),
    );
  }

  Widget _bannerImage() {
    final List<String> images = [
      "assets/images/image1.jpg",
      "assets/images/image2.jpg",
      "assets/images/image3.jpg",
      "assets/images/image4.jpg",
    ];

    int _current = 0;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            SizedBox(
              height: 230,
              width: double.infinity,
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 170,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction: 0.92,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  },
                  initialPage: _current,
                ),
                items: images.map((img) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: AssetImage(img),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: images.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _current = entry.key;
                    });
                  },
                  child: Container(
                    width: 10.0,
                    height: 10.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _current == entry.key
                          ? Colors.amber
                          : Colors.grey.withOpacity(0.4),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _fruitsHeader() {
    return Row(
      children: [
        const Text("Popular Fruits", style: TextStyle(fontSize: 24)),
        const Spacer(),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Fruitspages()));
          },
          child: const Text("See All", style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }

  Widget Fruitsinfo() {
    //  print("---------------------------------first");
    // final fruitList =
    //     fruitss!.where((f) => (f.category ?? '') == 'Fruit').toList();
    // //     print("---------------------------------second");
    // if (fruitList.isEmpty) {
    //   // print("---------------------------------third");
    //   return const Center(child: Text("No Fruits available"));
    //   //  print("---------------------------------four");
    // }
    return fruitss.isEmpty
        ? const CircularProgressIndicator()
        : SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: fruitss.length,
              itemBuilder: (context, index) {
                final fruit = fruitss[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DetailsPage(id: fruit.id)));
                  },
                  child: Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 16),
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
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: fruit.imageUrl ?? "",
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 100,
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10.0, top: 10),
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
                                    const TextSpan(
                                      text: 'Price ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: '\$',
                                      style: TextStyle(
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
                  ),
                );
              },
            ),
          );
  }

  Widget _vegHeader() {
    return Row(
      children: [
        const Text("Popular Vegetables", style: TextStyle(fontSize: 24)),
        const Spacer(),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const vegitablepages()));
          },
          child: const Text("See All", style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }

  Widget _vegList() {
    final vegList = veg
        .where((f) => (f.category ?? '').toLowerCase() == 'vegetable')
        .toList();
    if (vegList.isEmpty) {
      return const Center(child: Text("No vegetables available"));
    }
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: vegList.length,
        itemBuilder: (context, index) {
          final veg = vegList[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => vegDetailsPage(id: veg.id)));
            },
            child: Container(
              width: 200,
              margin: const EdgeInsets.only(right: 16),
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
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: veg.imageUrl ?? "",
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 100,
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, top: 10),
                        child: Text(
                          veg.name ?? ' ',
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
                              const TextSpan(
                                text: 'Price ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              const TextSpan(
                                text: '\$',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: '${veg.price}',
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
          );
        },
      ),
    );
  }

  Widget _addFruit() {
    return FloatingActionButton(
      tooltip: "Add Fruit",
      onPressed: () async {
        final result = await Navigator.push(context,
            MaterialPageRoute(builder: (context) => const Addproduct()));
        if (result == true) {
          fetchFruits();
        }
      },
      backgroundColor: Colors.amber,
      child:
          const Padding(padding: EdgeInsets.all(10.0), child: Icon(Icons.add)),
    );
  }
}
