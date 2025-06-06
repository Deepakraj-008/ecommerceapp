import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:ecommerceapp/pages/home/models/Fruitsmodel.dart';
import 'package:ecommerceapp/pages/home/models/vegitablemodel.dart';
import 'package:ecommerceapp/pages/home/screens/addproducts.dart';
import 'package:ecommerceapp/pages/home/screens/homescreen.dart';
import 'package:flutter/material.dart';

class DetailsPage extends StatefulWidget {
  final int? id;

  const DetailsPage({super.key, this.id});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  Getdata? fruit;
  GetVegdata? vege;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchdetailsFruits();
    fetchdetailsveg();
  }

  Future<void> fetchdetailsFruits() async {
    try {
      final response = await Dio()
          .get('http://192.168.0.14:8000/api/products/${widget.id}/');

      setState(() {
        fruit = Getdata.fromJson(response.data);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching fruit: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchdetailsveg() async {
    try {
      final response = await Dio()
          .get('http://192.168.0.14:8000/api/products/${widget.id}/');

      setState(() {
        vege = GetVegdata.fromJson(response.data);
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
        scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
        title: Text(fruit?.name ?? vege?.name ?? ''),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Container(
        color: const Color(0xFFE7e7e7),
        height: 0.5,
          ),
        ),
     
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
                      AddFruits: fruit,
                      vegitablesss: vege,
                      isUpdate: true,
                    ),
                  ),
                );
                if (updated == true) {
                  if (fruit != null) {
                    await fetchdetailsFruits();
                  } else if (vege != null) {
                    await fetchdetailsveg();
                  }
                  // Refresh details after update
                  
                  if (mounted) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Homescreenpage()));
                  }
                }
              } else if (value == 'delete') {
                // Delete logic
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete'),
                    content: const Text(
                        'Are you sure you want to delete this item?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  try {
                    await Dio().delete(
                        'http://192.168.0.14:8000/api/products/${widget.id}/');
                    if (mounted) Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Homescreenpage())); // Go back after delete
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
                      image: fruit != null
                          ? DecorationImage(
                              image: CachedNetworkImageProvider(
                                  fruit!.imageUrl ?? ''),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: Colors.grey[200],
                    ),
                    child: fruit == null
                        ? const Center(child: Icon(Icons.image, size: 60))
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8),
                    child: Text(
                      fruit?.name ?? '',
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      fruit?.description ?? '',
                      style: const TextStyle(fontSize: 20, ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8),
                    child: Text(
                      fruit != null ? '\$${fruit!.price ?? ''}' : '',
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
