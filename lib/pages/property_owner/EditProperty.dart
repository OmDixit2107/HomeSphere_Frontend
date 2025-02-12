import 'dart:io';
import 'package:flutter/material.dart';
import 'package:homesphere/models/Property.dart';
import 'package:homesphere/services/api/PropertyOwnerAPI.dart';
import 'package:homesphere/services/functions/ImagePickerService.dart';

class EditProperty extends StatefulWidget {
  final int propertyId;
  const EditProperty({super.key, required this.propertyId});

  @override
  State<EditProperty> createState() => _EditPropertyState();
}

class _EditPropertyState extends State<EditProperty> {
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
  Property? _property;

  @override
  void initState() {
    super.initState();
    _loadPropertyDetails();
  }

  Future<void> _loadPropertyDetails() async {
    Property? property =
        await PropertyOwnerApi.getPropertyById(widget.propertyId);
    if (property != null) {
      setState(() {
        _property = property;
        _titleController.text = property.title;
        _descriptionController.text = property.description;
        _priceController.text = property.price.toString();
        _locationController.text = property.location;
        _selectedType = property.type;
        _selectedStatus = property.status;
        _emiAvailable = property.emiAvailable;
        _images = property.images;
      });
    }
  }

  Future<void> _pickImages() async {
    final images = await _imagePickerService.pickImages();
    setState(() {
      _images.addAll(images);
    });
  }

  Future<void> _updateProperty() async {
    if (_formKey.currentState!.validate()) {
      List<File> imageFiles =
          _images.map((imagePath) => File(imagePath)).toList();

      final updatedProperty = Property(
        id: widget.propertyId,
        user: _property!.user, // Ensuring user is passed correctly
        title: _titleController.text,
        description: _descriptionController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        location: _locationController.text,
        type: _selectedType.toLowerCase(),
        status: _selectedStatus.toLowerCase(),
        emiAvailable: _emiAvailable,
        images: _property!.images, // Keeping existing images
      );

      Property? success = await PropertyOwnerApi.updateProperty(
          widget.propertyId, updatedProperty, imageFiles);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Property updated successfully!",
              style: TextStyle(color: Colors.green)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_property == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Property")),
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
                    onPressed: _updateProperty,
                    child: const Text("Update Property")),
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
          value: options.contains(_selectedType) ? _selectedType : options[0],
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
