import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:ecommerceapp/pages/food/screens/detailspage.dart';
import 'package:ecommerceapp/pages/food/screens/fruitpage.dart';
import 'package:ecommerceapp/pages/home/models/Fruitsmodel.dart';
import 'package:ecommerceapp/pages/home/screens/addproducts.dart';
import 'package:ecommerceapp/pages/home/screens/searchpage.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Homescreenpage extends StatefulWidget {
  const Homescreenpage({super.key});

  @override
  State<Homescreenpage> createState() => _HomescreenpageState();
}

class _HomescreenpageState extends State<Homescreenpage> {
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
        body: RefreshIndicator(
          onRefresh: () async {},
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(children: [
                const SizedBox(height: 30),
                 _title() ,
                _bannerImage(),
                const SizedBox(height: 20),
                _sectionHeader(),
                const SizedBox(height: 20),
                _fruitsList()
              ]),
            ),
          ),
        ),
        floatingActionButton: _addFruit());
  }



  Widget _title() {
    return Text(
      "Fruits Market",
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.orange,
        fontFamily: 'Pacifico', // Use a beautiful font like Pacifico
        letterSpacing: 1.2,
        shadows: [
          Shadow(
            blurRadius: 4,
            color: Colors.orangeAccent.withOpacity(0.4),
            offset: Offset(2, 2),
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
                  autoPlayInterval: Duration(seconds: 3),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
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

  Widget _sectionHeader() {
    return Row(
      children: [
        const Text("Popular Foods", style: TextStyle(fontSize: 24)),
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

  Widget _fruitsList() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: fruits.length,
        itemBuilder: (context, index) {
          final fruit = fruits[index];
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
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, top: 10),
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

//  Widget _vegList() {
//     return SizedBox(
//       height: 200,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: fruits.length,
//         itemBuilder: (context, index) {
//           final fruit = fruits[index];
//           return GestureDetector(
//             onTap: () {
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => DetailsPage(id: fruit.id)));
//             },
//             child: Container(
//               width: 200,
//               margin: const EdgeInsets.only(right: 16),
//               child: SizedBox(
//                 width: 140,
//                 child: Card(
//                   shadowColor: Colors.blueGrey,
//                   borderOnForeground: true,
//                   color: Colors.white,
//                   elevation: 2,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       ClipRRect(
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(15),
//                           topRight: Radius.circular(15),
//                         ),
//                         child: CachedNetworkImage(
//                           imageUrl: fruit.imageUrl ?? "",
//                           fit: BoxFit.cover,
//                           width: double.infinity,
//                           height: 100,
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.only(left: 10.0, top: 10),
//                         child: Text(
//                           fruit.name ?? ' ',
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Padding(
//                         padding: const EdgeInsets.only(left: 10.0),
//                         child: RichText(
//                           text: TextSpan(
//                             children: [
//                               const TextSpan(
//                                 text: 'Price ',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                               const TextSpan(
//                                 text: '\$',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.orange,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               TextSpan(
//                                 text: '${fruit.price}',
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.orange,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

  Widget _addFruit() {
    return Stack(children: [
      Positioned(
        bottom: 30,
        right: 5,
        child: FloatingActionButton(
          tooltip: "Add Fruit",
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Addproduct()));
          },
          backgroundColor: Colors.amber,
          child: const Padding(
              padding: EdgeInsets.all(10.0), child: Icon(Icons.add)),
        ),
      ),
    ]);
  }

  // Widget _circleIcon(IconData icon) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(10),
  //       color: const Color(0xFFB5B5B5).withOpacity(0.2),
  //     ),
  //     height: 53,
  //     width: 53,
  //     child: Icon(icon, size: 23, color: const Color(0xFF1E1E1E)),
  //   );
  // }

}


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(18.0),
//         child: Column(children: [
//           Row(
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   color: const Color(0xFFB5B5B5).withOpacity(0.2),
//                 ),
//                 height: 53,
//                 width: 53,
//                 child: const Icon(
//                   Icons.menu,
//                   color: Color(0xFF1E1E1E),
//                   size: 23,
//                 ),
//               ),
//               const Spacer(),
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   color: const Color(0xFFB5B5B5).withOpacity(0.2),
//                 ),
//                 height: 53,
//                 width: 53,
//                 child: const Icon(
//                   Icons.person,
//                   size: 23,
//                   color: Color(0xFF1E1E1E),
//                 ),
//               )
//             ],
//           ),
//           const SizedBox(
//             height: 20,
//           ),
//           Row(
//             children: [
//               Expanded(
//                 child: Container(
//                   height: 50,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10),
//                     color: const Color(0xFFB5B5B5).withOpacity(0.2),
//                   ),
//                   child: Row(
//                     children: [
//                       const SizedBox(width: 10),
//                       const Icon(Icons.search),
//                       const SizedBox(
//                         width: 10,
//                       ),
//                       Expanded(
//                         child: Container(
//                           height: 30,
//                           alignment: Alignment.centerLeft,
//                           child: Center(
//                             child: TextField(
//                               controller: _controller,
//                               textAlign: TextAlign.start,
//                               decoration: const InputDecoration(
//                                 hintText: 'Search...',
//                                 border: OutlineInputBorder(
//                                   borderSide: BorderSide.none,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(
//                 width: 16,
//               ),
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   color: const Color(0xFFB5B5B5).withOpacity(0.2),
//                 ),
//                 height: 50,
//                 width: 50,
//                 child: const Icon(
//                   Icons.menu,
//                   size: 20,
//                   color: Color(0xFF1E1E1E),
//                 ),
//               )
//             ],
//           ),
//           const SizedBox(
//             height: 20,
//           ),
//           Container(
//             height: 230,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(10),
//               image: const DecorationImage(
//                 image: AssetImage("assets/images/image1.jpg"),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           const SizedBox(
//             height: 20,
//           ),
//           Row(
//             children: [
//               const Text(
//                 "Popular Foods",
//                 style: TextStyle(fontSize: 24),
//               ),
//               const Spacer(),
//               GestureDetector(
//                 onTap: () {
//                   Navigator.push(context,
//                       MaterialPageRoute(builder: (context) => Fruitspages()));
//                 },
//                 child: const Text(
//                   "See All",
//                   style: TextStyle(fontSize: 20),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(
//             height: 20,
//           ),
//           isLoading
//               ? const Center(child: CircularProgressIndicator())
//               :
//                SizedBox(
//                   height: 270,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: fruits.length,
//                     itemBuilder: (context, index) {
//                       final fruit = fruits[index];
//                       return GestureDetector(
//                          onTap: () {
//                     Navigator.push(
//                         context, MaterialPageRoute(builder: (context)=> DetailsPage(id:fruit.id)));
//                   },
//                         child: Container(
//                           width: 200,
//                           child: Card(
//                             elevation: 2,
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(16)),
//                             child: Stack(
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.all(12),
//                                   child: Center(
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Expanded(
//                                           child: Center(
//                                             child: Container(
//                                               height: 140,
//                                               width:140,
//                                               decoration: BoxDecoration(
//                                                   borderRadius:
//                                                       BorderRadius.circular(10),
//                                                   color: Colors.grey.shade100,
//                                                   image: DecorationImage(
//                                                     image: CachedNetworkImageProvider(
//                                                       imagess!.imageUrl ?? '',
//                                                     ),fit: BoxFit.cover
//                                                   )),
//                                             ),
//                                           ),
//                                         ),
//                                         Center(
//                                           child: Text(fruit.name ?? '',
//                                               style: const TextStyle(
//                                                   fontSize: 18,
//                                                   fontWeight: FontWeight.bold)),
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Center(
//                                           child: Text('Only \$${fruit.price}',
//                                               style: const TextStyle(fontSize: 14)),
//                                         ),
//                                         const SizedBox(height: 8),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//         ]),
//       ),
//     );
//   }
// }
