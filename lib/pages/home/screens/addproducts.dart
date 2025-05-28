import 'package:ecommerceapp/pages/home/models/Fruitsmodel.dart';
import 'package:ecommerceapp/pages/home/models/vegitablemodel.dart';
import 'package:ecommerceapp/pages/home/screens/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart';

class Addproduct extends StatefulWidget {
  final Getdata? AddFruits;
  final GetVegdata? vegitablesss;
  final bool isUpdate;

  const Addproduct(
      {super.key, this.AddFruits, this.isUpdate = false, this.vegitablesss});

  @override
  State<Addproduct> createState() => _AddproductState();
}

class _AddproductState extends State<Addproduct> {
  final TextEditingController _AddFruitscontroller = TextEditingController();
  final TextEditingController _descriptioncontroller = TextEditingController();
  final TextEditingController _pricecontroller = TextEditingController();

  File? _image;
  bool _isSubmitting = false;

  // Category list and selected category id
  final List<Map<String, dynamic>> _categories = [
    {'id': 2, 'name': 'Fruit'},
    {'id': 1, 'name': 'Vegetable'},
  ];
  int? _selectedCategoryId;

  @override
void initState() {
  super.initState();
  if (widget.isUpdate) {
    if (widget.AddFruits != null) {
      _AddFruitscontroller.text = widget.AddFruits!.name ?? '';
      _descriptioncontroller.text = widget.AddFruits!.description ?? '';
      _pricecontroller.text = widget.AddFruits!.price?.toString() ?? '';
      final found = _categories.firstWhere(
        (cat) => cat['name'] == widget.AddFruits!.category,
        orElse: () => _categories[0],
      );
      _selectedCategoryId = found['id'];
    } else if (widget.vegitablesss != null) {
      _AddFruitscontroller.text = widget.vegitablesss!.name ?? '';
      _descriptioncontroller.text = widget.vegitablesss!.description ?? '';
      _pricecontroller.text = widget.vegitablesss!.price?.toString() ?? '';
      final found = _categories.firstWhere(
        (cat) => cat['name'] == widget.vegitablesss!.category,
        orElse: () => _categories[1],
      );
      _selectedCategoryId = found['id'];
    }
  }
}
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Image Source"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(ImageSource.camera),
              child: const Text("Camera"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
              child: const Text("Gallery"),
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
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 50),
               (widget.vegitablesss != null)  ?_VegForm() :_FruitsForm(),
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
                                if (widget.vegitablesss != null) {
                                  await _submitVeg();
                                } else {
                                  await _submitProduct();
                                }
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

  Widget _FruitsForm() {
    final isUpdate = widget.isUpdate;
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 10),
            const Text(" Name"),
            const Spacer(),
            Container(
              width: 220,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black.withOpacity(0.1))),
              child: TextFormField(
                controller: _AddFruitscontroller,
                decoration: const InputDecoration(
                  hintText: 'Enter the  name',
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
            const Text(" Price"),
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
            const Text("Category"),
            const Spacer(),
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                items: _categories
                    .map((cat) => DropdownMenuItem<int>(
                          value: cat['id'],
                          child: Text(cat['name']),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value!;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Select Category',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const SizedBox(width: 10),
            const Text("Add Image"),
            const Spacer(),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 220,
                constraints: const BoxConstraints(
                  minHeight: 80,
                  maxHeight: 220,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: (_image == null &&
                          !(isUpdate && widget.AddFruits?.imageUrl != null))
                      ? Border.all(color: Colors.black.withOpacity(0.1))
                      : null,
                ),
                child: _image == null
                    ? (isUpdate && widget.AddFruits?.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              widget.AddFruits!.imageUrl!,
                              fit: BoxFit.contain,
                              width: 220,
                              height: 220,
                            ),
                          )
                        : const Center(child: Text("Select Image")))
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

  Future<void> _submitProduct() async {
    setState(() => _isSubmitting = true);

    final name = _AddFruitscontroller.text.trim();
    final desc = _descriptioncontroller.text.trim();
    final price = _pricecontroller.text.trim();

    if (name.isEmpty || price.isEmpty) {
      _showError("Please fill all the fields and select an image.");
      setState(() => _isSubmitting = false);
      return;
    }

    try {
      final dio = Dio();
      if (widget.isUpdate && widget.AddFruits != null) {
        // Update logic
        try {
          final old = widget.AddFruits!;
          final bool nameChanged = name != (old.name ?? '');
          final bool descChanged = desc != (old.description ?? '');
          final bool priceChanged = price != (old.price?.toString() ?? '');
          final bool categoryChanged =
              _selectedCategoryId != (old.category ?? 1);
          final data = <String, dynamic>{};
          if (nameChanged) data['name'] = name;
          if (descChanged) data['description'] = desc;
          if (priceChanged) data['price'] = price;
          if (categoryChanged) data['category_id'] = _selectedCategoryId;
          FormData formData = FormData.fromMap({
            ...data,
            if (_image != null)
              'image': await MultipartFile.fromFile(_image!.path,
                  filename: _image!.path.split('/').last),
          });
          final response = await dio.put(
            'http://192.168.0.14:8000/api/products/${old.id}/',
            data: formData,
          );
          if (response.statusCode == 200) {
            _showSuccess("Updated successfully!");

            Future.delayed(const Duration(seconds: 1), () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Homescreenpage()));
            });
          } else {
            _showError("Failed to update product.");
          }
        } catch (e) {
          print(e);
        }
      } else {
        // Add new product
        try {
          FormData formData = FormData.fromMap({
            'name': name,
            'description': desc,
            'price': double.tryParse(price) ?? 0,
            'category_id': _selectedCategoryId,
            'image': await MultipartFile.fromFile(_image!.path,
                filename: _image!.path.split('/').last),
          });
          print('FormData fields: ${formData.fields}');
          print('FormData files: ${formData.files}');
          final response = await dio.post(
            'http://192.168.0.14:8000/api/products/',
            data: formData,
            options: Options(contentType: 'multipart/form-data'),
          );
          print('Response status: ${response.statusCode}');
          print('Response data: ${response.data}');
          if (response.statusCode == 201) {
            _showSuccess("Added successfully!");
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Homescreenpage()));
            });
          } else {
            _showError("Failed to add product. ${response.data}");
          }
        } catch (e) {
          print(e);
          if (e is DioException && e.response != null) {
            _showError("Failed: ${e.response?.data}");
          } else {
            _showError("Failed: $e");
          }
        }
      }
    } catch (e) {
      _showError("Failed: $e");
    }
    setState(() => _isSubmitting = false);
  }

 Widget _VegForm() {
    final isUpdate = widget.isUpdate;
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 10),
            const Text(" Name"),
            const Spacer(),
            Container(
              width: 220,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black.withOpacity(0.1))),
              child: TextFormField(
                controller: _AddFruitscontroller,
                decoration: const InputDecoration(
                  hintText: 'Enter the  name',
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
            const Text(" Price"),
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
            const Text("Category"),
            const Spacer(),
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                items: _categories
                    .map((cat) => DropdownMenuItem<int>(
                          value: cat['id'],
                          child: Text(cat['name']),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value!;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Select Category',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const SizedBox(width: 10),
            const Text("Add Image"),
            const Spacer(),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 220,
                constraints: const BoxConstraints(
                  minHeight: 80,
                  maxHeight: 220,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: (_image == null &&
                          !(isUpdate && widget.vegitablesss?.imageUrl != null))
                      ? Border.all(color: Colors.black.withOpacity(0.1))
                      : null,
                ),
                child: _image == null
                    ? (isUpdate && widget.vegitablesss?.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              widget.vegitablesss!.imageUrl!,
                              fit: BoxFit.contain,
                              width: 220,
                              height: 220,
                            ),
                          )
                        : const Center(child: Text("Select Image")))
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


  Future<void> _submitVeg() async {
    setState(() => _isSubmitting = true);

    final name = _AddFruitscontroller.text.trim();
    final desc = _descriptioncontroller.text.trim();
    final price = _pricecontroller.text.trim();

    if (name.isEmpty || price.isEmpty) {
      _showError("Please fill all the fields and select an image.");
      setState(() => _isSubmitting = false);
      return;
    }

    try {
      final dio = Dio();
      if (widget.isUpdate && widget.vegitablesss != null) {
        // Update logic
        try {
          final oldd = widget.vegitablesss!;
          final bool nameChanged = name != (oldd.name ?? '');
          final bool descChanged = desc != (oldd.description ?? '');
          final bool priceChanged = price != (oldd.price?.toString() ?? '');
          final bool categoryChanged =
              _selectedCategoryId != (oldd.category ?? 1);
          final data = <String, dynamic>{};
          if (nameChanged) data['name'] = name;
          if (descChanged) data['description'] = desc;
          if (priceChanged) data['price'] = price;
          if (categoryChanged) data['category_id'] = _selectedCategoryId;
          FormData formData = FormData.fromMap({
            ...data,
            if (_image != null)
              'image': await MultipartFile.fromFile(_image!.path,
                  filename: _image!.path.split('/').last),
          });
          final response = await dio.put(
            'http://192.168.0.14:8000/api/products/${oldd.id}/',
            data: formData,
          );
          if (response.statusCode == 200) {
            _showSuccess("Updated successfully!");

            Future.delayed(const Duration(seconds: 1), () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Homescreenpage()));
            });
          } else {
            _showError("Failed to update product.");
          }
        } catch (e) {
          print(e);
        }
      } else {
        // Add new product
        try {
          FormData formData = FormData.fromMap({
            'name': name,
            'description': desc,
            'price': double.tryParse(price) ?? 0,
            'category_id': _selectedCategoryId,
            'image': await MultipartFile.fromFile(_image!.path,
                filename: _image!.path.split('/').last),
          });
          print('FormData fields: ${formData.fields}');
          print('FormData files: ${formData.files}');
          final response = await dio.post(
            'http://192.168.0.14:8000/api/products/',
            data: formData,
            options: Options(contentType: 'multipart/form-data'),
          );
          print('Response status: ${response.statusCode}');
          print('Response data: ${response.data}');
          if (response.statusCode == 201) {
            _showSuccess("Added successfully!");
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Homescreenpage()));
            });
          } else {
            _showError("Failed to add product. ${response.data}");
          }
        } catch (e) {
          print(e);
          if (e is DioException && e.response != null) {
            _showError("Failed: ${e.response?.data}");
          } else {
            _showError("Failed: $e");
          }
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
        title: const Text("Error"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
