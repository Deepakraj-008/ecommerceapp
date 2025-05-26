import 'package:ecommerceapp/pages/home/screens/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ecommerceapp/pages/home/models/Fruitsmodel.dart';

class Addproduct extends StatefulWidget {
  final Getdata? fruit;
  final bool isUpdate;

  const Addproduct({super.key, this.fruit, this.isUpdate = false});

  @override
  State<Addproduct> createState() => _AddproductState();
}

class _AddproductState extends State<Addproduct> {
  final TextEditingController _fruitcontroller = TextEditingController();
  final TextEditingController _descriptioncontroller = TextEditingController();
  final TextEditingController _pricecontroller = TextEditingController();

  File? _image;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.isUpdate && widget.fruit != null) {
      _fruitcontroller.text = widget.fruit!.name ?? '';
      _descriptioncontroller.text = widget.fruit!.description ?? '';
      _pricecontroller.text = widget.fruit!.price?.toString() ?? '';
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Image Source"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(ImageSource.camera),
              child: Text("Camera"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
              child: Text("Gallery"),
            ),
          ],
        );
      },
    );

    if (source != null) {
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _submitProduct() async {
    setState(() => _isSubmitting = true);

    final name = _fruitcontroller.text.trim();
    final desc = _descriptioncontroller.text.trim();
    final price = _pricecontroller.text.trim();

    if (name.isEmpty || price.isEmpty) {
      _showError("Please fill all the fields.");
      setState(() => _isSubmitting = false);
      return;
    }

    try {
      final dio = Dio();
      if (widget.isUpdate && widget.fruit != null) {
        // Update logic
        final old = widget.fruit!;
        final bool nameChanged = name != (old.name ?? '');
        final bool descChanged = desc != (old.description ?? '');
        final bool priceChanged = price != (old.price?.toString() ?? '');
        final bool imageChanged = _image != null;
        final int changedCount = [
          nameChanged,
          descChanged,
          priceChanged,
          imageChanged
        ].where((e) => e).length;
        final data = <String, dynamic>{};
        if (nameChanged) data['name'] = name;
        if (descChanged) data['description'] = desc;
        if (priceChanged) data['price'] = price;
        try {
          Response response;
          // All fields changed, use PUT
          // FormData formData = FormData.fromMap({
          //   'name': name,
          //   'description': desc,
          //   'price': price,
          //   if (_image != null)
          //     'image': await MultipartFile.fromFile(_image!.path, filename: _image!.path.split('/').last),
          // });
          // response = await dio.put(
          //   'http://192.168.29.208:8000/api/products/${old.id}/',
          //   data: formData,
          //   options: Options(contentType: 'multipart/form-data'),
          // );

          // Partial update, use PATCH
          FormData formData = FormData.fromMap({
            ...data,
            if (_image != null)
              'image': await MultipartFile.fromFile(_image!.path,
                  filename: _image!.path.split('/').last),
          });
          response = await dio.put(
            'http://192.168.29.208:8000/api/products/${old.id}/',
            data: formData,
            options: Options(contentType: 'multipart/form-data'),
          );
          if (response.statusCode == 200) {
            _showSuccess("Updated successfully!");
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Homescreenpage())
                          ); // Return true to refresh details
            });
          } else {
            _showError("Failed to update product.");
          } 
        } catch (e) {
          print(e);
        }
      } else {
        try {
          // Add new product
          FormData formData = FormData.fromMap({
            'name': name,
            'description': desc,
            'price': price,
            if (_image != null)
              'image': await MultipartFile.fromFile(_image!.path,
                  filename: _image!.path.split('/').last),
          });
          final response = await dio.post(
            'http://192.168.29.208:8000/api/products/',
            data: formData,
            options: Options(contentType: 'multipart/form-data'),
          );

          if (response.statusCode == 201) {
            _showSuccess("Added successfully!");
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Homescreenpage())); // Return true to refresh details
            });
          } else {
            _showError("Failed to add product.");
          }
        } catch (e) {
          print(e);
        }
      }
    } catch (e) {
      _showError("Failed: $e");
    }
    setState(() => _isSubmitting = false);
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String msg) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 80,
        alignment: Alignment.center,
        child: Text(
          msg,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.isUpdate;
    return Scaffold(
      appBar: AppBar(
        title: Text(isUpdate ? "Update Product" : "Add Product"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 50),
                _fruit(),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isUpdate)
                      SizedBox(
                        width: 120,
                        child: OutlinedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => Navigator.of(context).pop(false),
                          child: const Text("Cancel"),
                        ),
                      ),
                    if (isUpdate) const SizedBox(width: 20),
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () async {
                                await _submitProduct();
                              },
                        child: Text(isUpdate ? "Update" : "Add"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fruit() {
    final isUpdate = widget.isUpdate;
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 10),
            const Text("Fruit Name"),
            const Spacer(),
            Container(
              width: 220,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black.withOpacity(0.1))),
              child: TextFormField(
                controller: _fruitcontroller,
                decoration: const InputDecoration(
                  hintText: 'Enter the fruit name',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const SizedBox(width: 10),
            const Text("Description"),
            const Spacer(),
            Container(
              width: 220,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black.withOpacity(0.1))),
              child: TextFormField(
                controller: _descriptioncontroller,
                decoration: const InputDecoration(
                  hintText: 'Description',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const SizedBox(width: 10),
            const Text("Fruit Price"),
            const Spacer(),
            Container(
              width: 220,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black.withOpacity(0.1))),
              child: TextFormField(
                controller: _pricecontroller,
                decoration: const InputDecoration(
                  hintText: 'Enter the price',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const SizedBox(width: 10),
            const Text("Fruit Image"),
            const Spacer(),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 220,
                constraints: BoxConstraints(
                  minHeight: 80,
                  maxHeight: 220,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: (_image == null &&
                          !(isUpdate && widget.fruit?.imageUrl != null))
                      ? Border.all(color: Colors.black.withOpacity(0.1))
                      : null,
                ),
                child: _image == null
                    ? (isUpdate && widget.fruit?.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              widget.fruit!.imageUrl!,
                              fit: BoxFit.contain,
                              width: 220,
                              height: 220,
                            ),
                          )
                        : Center(child: Text("Select Image")))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _image!,
                          fit: BoxFit.contain,
                          width: 220,
                          height: 220,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
