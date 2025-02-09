import 'dart:io';
import 'package:flutter/material.dart';
import 'package:homesphere/models/Property.dart';
import 'package:homesphere/services/api/PropertyOwnerAPI.dart';
import 'package:homesphere/services/api/UserAPI.dart';
import 'package:homesphere/services/functions/ImagePickerService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String _selectedType = "Buy";
  String _selectedStatus = "Available";
  bool _emiAvailable = false;
  List<String> _images = [];

  final ImagePickerService _imagePickerService = ImagePickerService();

  Future<void> _pickImages() async {
    final images = await _imagePickerService.pickImages();
    setState(() {
      _images = images;
    });
  }

  Future<void> _submitProperty() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString("email");

      if (email != null) {
        final user = await UserApi.getUserByEmail(email);

        if (user != null) {
          final property = Property(
            user: user,
            title: _titleController.text,
            description: _descriptionController.text,
            price: double.tryParse(_priceController.text) ?? 0.0,
            location: _locationController.text,
            type: _selectedType.toLowerCase(),
            status: _selectedStatus.toLowerCase(),
            emiAvailable: _emiAvailable,
            images: _images,
          );

          List<File> imageFiles = _images.map((path) => File(path)).toList();
          Property? pp =
              await PropertyOwnerApi.createProperty(property, imageFiles);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(pp != null
                    ? "Property submitted successfully!"
                    : "Failed to submit property.")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User not found. Please try again.")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Property")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                    _titleController, "Title", "Enter property title"),
                const SizedBox(height: 10),
                _buildTextField(_descriptionController, "Description",
                    "Enter property description",
                    maxLines: 3),
                const SizedBox(height: 10),
                _buildTextField(_priceController, "Price", "Enter price",
                    isNumber: true),
                const SizedBox(height: 10),
                _buildTextField(
                    _locationController, "Location", "Enter property location"),
                const SizedBox(height: 10),
                _buildDropdown("Type", ["Buy", "Rent"],
                    (value) => setState(() => _selectedType = value!)),
                _buildDropdown("Status", ["Available", "Sold", "Rented"],
                    (value) => setState(() => _selectedStatus = value!)),
                SwitchListTile(
                  title: const Text("EMI Available"),
                  value: _emiAvailable,
                  onChanged: (bool value) =>
                      setState(() => _emiAvailable = value),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: _pickImages, child: const Text("Select Images")),
                const SizedBox(height: 10),
                if (_images.isNotEmpty)
                  Wrap(
                    spacing: 8.0,
                    children: _images.map((imagePath) {
                      return Image.file(File(imagePath),
                          width: 100, height: 100, fit: BoxFit.cover);
                    }).toList(),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: _submitProperty,
                    child: const Text("Submit Property")),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, String hint,
      {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
          labelText: label, hintText: hint, border: OutlineInputBorder()),
      validator: (value) =>
          value == null || value.isEmpty ? "Please enter $label" : null,
    );
  }

  Widget _buildDropdown(
      String label, List<String> options, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: options[0],
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: options
              .map((option) =>
                  DropdownMenuItem(value: option, child: Text(option)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
