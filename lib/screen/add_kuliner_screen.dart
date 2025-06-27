import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/kuliner.dart';
import '../providers/auth_providers.dart';
import '../providers/kuliner_provider.dart';
import '../utils/app_theme.dart';
import '../utils/permission_helper.dart';
import '../services/image_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddKulinerScreen extends StatefulWidget {
  const AddKulinerScreen({super.key});

  @override
  _AddKulinerScreenState createState() => _AddKulinerScreenState();
}

class _AddKulinerScreenState extends State<AddKulinerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceRangeController = TextEditingController();

  String _selectedCategory = 'Makanan Utama';
  double _rating = 5.0; // Default rating
  bool _isLoading = false;
  bool _isGettingLocation = false;
  double? _latitude;
  double? _longitude;
  XFile? _pickedImage;
  String? _imageError;
  String? _imageUrl;

  final List<String> _categories = [
    'Makanan Utama',
    'Minuman',
    'Dessert',
    'Snack',
    'Seafood',
    'Vegetarian',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _priceRangeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Culinary Spot'),
        automaticallyImplyLeading: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                const Icon(Icons.restaurant_menu,
                    size: 64, color: Colors.green),
                const SizedBox(height: 8),
                Text(
                  'Tambah Kuliner Baru',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                ),
                const SizedBox(height: 16),
              ],
            ),
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTextInput(_nameController, 'Nama Kuliner',
                          labelBold: true),
                      const SizedBox(height: 16),
                      _buildTextInput(_descriptionController, 'Deskripsi',
                          maxLines: 3, labelBold: true),
                      const SizedBox(height: 16),
                      _buildDropdown(),
                      const SizedBox(height: 16),
                      _buildRatingSelector(),
                      const SizedBox(height: 16),
                      _buildTextInput(_priceRangeController,
                          'Rentang Harga (misal: Rp 20.000 - 50.000)',
                          labelBold: true),
                      const SizedBox(height: 16),
                      _buildAddressInput(),
                      const SizedBox(height: 24),
                      const Divider(height: 32),
                      const Text('Foto',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      Center(child: _buildImagePicker(previewSize: 160)),
                      if (_imageError != null) _buildImageError(),
                      const SizedBox(height: 32),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput(TextEditingController controller, String label,
      {int maxLines = 1, bool labelBold = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            labelBold ? const TextStyle(fontWeight: FontWeight.bold) : null,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      validator: (value) =>
          value == null || value.isEmpty ? 'Mohon isi $label' : null,
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
      ),
      items: _categories
          .map((category) =>
              DropdownMenuItem(value: category, child: Text(category)))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value!;
          if (_pickedImage == null) {
            _imageUrl = ImageService.getCategoryImageUrl(_selectedCategory);
          }
        });
      },
    );
  }

  Widget _buildRatingSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rating',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '/ 5.0',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _rating = index + 1.0;
                      });
                    },
                    child: Icon(
                      Icons.star,
                      size: 32,
                      color: index < _rating ? Colors.amber : Colors.grey[300],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Slider(
                value: _rating,
                min: 1.0,
                max: 5.0,
                divisions: 8, // 0.5 increments
                activeColor: Colors.amber,
                onChanged: (value) {
                  setState(() {
                    _rating = value;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressInput() {
    return TextFormField(
      controller: _addressController,
      decoration: InputDecoration(
        labelText: 'Address',
        border: const OutlineInputBorder(),
        suffixIcon: _isGettingLocation
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: _getCurrentLocation,
              ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter the address' : null,
    );
  }

  Widget _buildImagePicker({double previewSize = 120}) {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: _pickedImage != null
          ? Stack(
              children: [
                Container(
                  width: previewSize,
                  height: previewSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(_pickedImage!.path),
                      width: previewSize,
                      height: previewSize,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _pickedImage = null;
                        _imageError = null;
                        _imageUrl =
                            ImageService.getCategoryImageUrl(_selectedCategory);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            )
          : Container(
              width: previewSize,
              height: previewSize,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child:
                  const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
            ),
    );
  }

  Widget _buildImageError() => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          _imageError!,
          style: const TextStyle(color: Colors.red, fontSize: 12),
        ),
      );

  Widget _buildSubmitButton() => ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Add Culinary Spot'),
        ),
      );

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil dari Kamera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _imageError = null;
      });

      bool permissionGranted = false;
      if (source == ImageSource.camera) {
        permissionGranted =
            await PermissionHelper.requestCameraPermission(context);
      } else {
        permissionGranted =
            await PermissionHelper.requestStoragePermission(context);
      }
      if (!permissionGranted) {
        setState(() {
          _imageError = source == ImageSource.camera
              ? 'Camera permission is required.'
              : 'Storage permission is required to select images from gallery.';
        });
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _pickedImage = image;
        });

        final file = File(image.path);
        final fileSize = await file.length();
        final maxSize = 5 * 1024 * 1024; // 5MB

        if (fileSize > maxSize) {
          setState(() {
            _imageError =
                'Image size too large. Please select an image smaller than 5MB.';
            _pickedImage = null;
          });
        }
      }
    } catch (e) {
      setState(() {
        _imageError = 'Failed to pick image: ${e.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      // Request location permission first
      bool locationGranted =
          await PermissionHelper.requestLocationPermission(context);
      if (!locationGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Location permission is required to get current location.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isGettingLocation = false;
        });
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address =
            '${place.street}, ${place.subLocality}, ${place.locality}';
        _addressController.text = address;
        _latitude = position.latitude;
        _longitude = position.longitude;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get location: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isGettingLocation = false;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // If location is not set, use default coordinates (Ubud, Bali)
        double lat = _latitude ?? -8.5069;
        double lng = _longitude ?? 115.2625;

        final user =
            Provider.of<AuthProvider>(context, listen: false).currentUser;

        // Handle image URL menggunakan ImageService
        String imageUrl = '';
        if (_pickedImage != null) {
          File imageFile = File(_pickedImage!.path);
          imageUrl = await ImageService.getImageUrl(
              imageFile, _selectedCategory, _nameController.text);
        }
        // Jika imageUrl masih kosong/null, fallback ke default
        if (imageUrl.isEmpty || imageUrl == 'null') {
          imageUrl = ImageService.getCategoryImageUrl(_selectedCategory);
        }
        print('Image URL yang disimpan: ' + imageUrl);

        final kuliner = Kuliner(
          id: 0,
          name: _nameController.text,
          description: _descriptionController.text,
          category: _selectedCategory,
          priceRange: _priceRangeController.text,
          address: _addressController.text,
          latitude: lat,
          longitude: lng,
          imageUrl: imageUrl,
          rating: _rating,
          userId: user!.id!,
          createdAt: DateTime.now(),
        );

        final success =
            await Provider.of<KulinerProvider>(context, listen: false)
                .addKuliner(kuliner);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Culinary spot added successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Clear form
          _nameController.clear();
          _descriptionController.clear();
          _addressController.clear();
          _priceRangeController.clear();
          _latitude = null;
          _longitude = null;
          setState(() {
            _selectedCategory = 'Makanan Utama';
            _rating = 5.0; // Reset rating to default
            _pickedImage = null;
            _imageError = null;
            _imageUrl = null;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add culinary spot'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }
}
