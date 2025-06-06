import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:ecommerceapp/pages/home/models/Fruitsmodel.dart';
import 'package:ecommerceapp/pages/home/models/vegitablemodel.dart';
import 'package:ecommerceapp/pages/home/screens/addproducts.dart';
import 'package:ecommerceapp/pages/home/screens/homescreen.dart';
import 'package:flutter/material.dart';

class vegDetailsPage extends StatefulWidget {
  final int? id;
  GetVegdata? vege;

  vegDetailsPage({super.key, this.id, this.vege});

  @override
  State<vegDetailsPage> createState() => _vegDetailsPageState();
}

class _vegDetailsPageState extends State<vegDetailsPage> {
  GetVegdata? vegg;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchdetailsFruits();
  }

  Future<void> fetchdetailsFruits() async {
    try {
      final response = await Dio()
          .get('http://192.168.0.14:8000/api/products/${widget.id}/');

      setState(() {
        vegg = GetVegdata.fromJson(response.data);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching fruit: $e');
      setState(() => isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(vegg?.name ?? ''),
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'edit') {
                // Navigate to Addproduct for editing
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => Addproduct(
                      vegitablesss: vegg,
                      isUpdate: true,
                  ),
                  ),
                );
                if (updated == true) {
                  // Refresh details after update
                  await fetchdetailsFruits();
                  if (mounted) {
                      Navigator.push(context,
                MaterialPageRoute(builder: (context) => Homescreenpage()));
                  }
                }
              } else if (value == 'delete') {
                // Delete logic
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete'),
                    content: const Text('Are you sure you want to delete this item?'),
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
                  try {
                    await Dio().delete('http://192.168.0.14:8000/api/products/${widget.id}/');
                    if (mounted) Navigator.pop(context); 
                      Navigator.push(context,
                MaterialPageRoute(builder: (context) => Homescreenpage()));// Go back after delete
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to delete: $e')),
                      );
                    }
                  }
                }
             
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
       
        ],
      ),
      body: isLoading 
      ? Center(child: CircularProgressIndicator())
      : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 290,
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: vegg != null
                          ? DecorationImage(
                              image: CachedNetworkImageProvider(
                                  vegg!.imageUrl ?? ''),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: Colors.grey[200],
                    ),
                    child: vegg == null
                        ? const Center(child: Icon(Icons.image, size: 60))
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8),
                    child: Text(
                      vegg?.name ?? '',
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      vegg?.description ?? '',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8),
                    child: Text(
                      vegg != null ? '\$${vegg!.price ?? ''}' : '',
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.green,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}