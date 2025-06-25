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
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                    // Update image URL berdasarkan category jika tidak ada gambar yang dipilih
                    if (_pickedImage == null) {
                      _imageUrl =
                          ImageService.getCategoryImageUrl(_selectedCategory);
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceRangeController,
                decoration: const InputDecoration(
                  labelText: 'Price Range (e.g., Rp 20.000 - 50.000)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the price range';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildImagePicker(),
              if (_imageError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _imageError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Add Culinary Spot'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Photo', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: _pickedImage != null
                  ? Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[400]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_pickedImage!.path),
                              width: 120,
                              height: 120,
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
                                _imageUrl = ImageService.getCategoryImageUrl(
                                    _selectedCategory);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo,
                              size: 40, color: Colors.grey[700]),
                          const SizedBox(height: 4),
                          Text(
                            'Add Photo',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _pickedImage == null
                        ? 'Using category image'
                        : 'Image selected: ${_pickedImage!.name}',
                    style: TextStyle(
                      color: _pickedImage == null
                          ? Colors.grey[600]
                          : Colors.green[700],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to select image from gallery',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                  if (_pickedImage == null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Or use category-based image',
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showImageSourceDialog() {
    // Langsung pilih dari gallery tanpa dialog
    _pickImage(ImageSource.gallery);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _imageError = null;
      });

      // Request storage permission only (no camera needed)
      bool storageGranted =
          await PermissionHelper.requestStoragePermission(context);
      if (!storageGranted) {
        setState(() {
          _imageError =
              'Storage permission is required to select images from gallery.';
        });
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery, // Always use gallery
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _pickedImage = image;
        });

        // Validate file size
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
        _imageError = 'Failed to pick image: ${e.toString()}';
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
        String imageUrl;
        if (_pickedImage != null) {
          // Ada gambar yang dipilih, gunakan ImageService
          File imageFile = File(_pickedImage!.path);
          imageUrl = await ImageService.getImageUrl(
              imageFile, _selectedCategory, _nameController.text);
        } else {
          // Tidak ada gambar, gunakan category-based image
          imageUrl = ImageService.getCategoryImageUrl(_selectedCategory);
        }

        final kuliner = Kuliner(
          name: _nameController.text,
          description: _descriptionController.text,
          category: _selectedCategory,
          priceRange: _priceRangeController.text,
          address: _addressController.text,
          latitude: lat,
          longitude: lng,
          imageUrl: imageUrl,
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
