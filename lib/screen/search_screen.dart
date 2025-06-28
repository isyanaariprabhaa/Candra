import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/kuliner_provider.dart';
import '../widgets/kuliner_card.dart';
import '../models/kuliner.dart';
import 'kuliner_detail_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'dart:io';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  bool _showNearest = false;
  Position? _userPosition;

  // Kategori yang sama dengan add kuliner screen
  final List<String> _categories = [
    'Makanan Utama',
    'Minuman',
    'Dessert',
    'Snack',
    'Seafood',
    'Vegetarian',
  ];

  @override
  void initState() {
    super.initState();
    _loadKulinerData();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _userPosition = position;
      });
    } catch (e) {
      // ignore error
    }
  }

  double _distanceToUser(double lat, double lng) {
    if (_userPosition == null) return double.infinity;
    return Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      lat,
      lng,
    );
  }

  Widget _buildKulinerImage(Kuliner kuliner) {
    final imageUrl = kuliner.imageUrl ?? '';
    if (imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('data:image') || imageUrl.startsWith('/')) {
        // Base64 image
        try {
          return Image.memory(
            base64Decode(imageUrl.replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '')),
            fit: BoxFit.cover,
            width: 60,
            height: 60,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                color: Colors.grey[300],
                child: Icon(
                  Icons.restaurant,
                  color: Colors.grey[600],
                  size: 24,
                ),
              );
            },
          );
        } catch (e) {
          return Container(
            width: 60,
            height: 60,
            color: Colors.grey[300],
            child: Icon(
              Icons.restaurant,
              color: Colors.grey[600],
              size: 24,
            ),
          );
        }
      } else if (imageUrl.startsWith('http')) {
        // Network image (URL internet)
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: 60,
          height: 60,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 60,
              height: 60,
              color: Colors.grey[300],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image: $error');
            return Container(
              width: 60,
              height: 60,
              color: Colors.grey[300],
              child: Icon(
                Icons.restaurant,
                color: Colors.grey[600],
                size: 24,
              ),
            );
          },
        );
      } else {
        // File image
        return Image.file(
          File(imageUrl),
          fit: BoxFit.cover,
          width: 60,
          height: 60,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 60,
              height: 60,
              color: Colors.grey[300],
              child: Icon(
                Icons.restaurant,
                color: Colors.grey[600],
                size: 24,
              ),
            );
          },
        );
      }
    } else {
      // Default icon
      return Container(
        width: 60,
        height: 60,
        color: Colors.grey[300],
        child: Icon(
          Icons.restaurant,
          color: Colors.grey[600],
          size: 24,
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadKulinerData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<KulinerProvider>(context, listen: false).loadKuliner();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            color: Colors.transparent,
            child: Column(
              children: [
                Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(18),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari makanan atau restoran...',
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: Color(0xFF43E97B)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (context, i) =>
                        const SizedBox(width: 10),
                    itemBuilder: (context, i) {
                      final cat = _categories[i];
                      final selected = cat == _selectedCategory;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: selected,
                          onSelected: (val) {
                            setState(() {
                              _selectedCategory = selected ? null : cat;
                            });
                          },
                          selectedColor: const Color(0xFF43E97B),
                          labelStyle: TextStyle(
                            color:
                                selected ? Colors.white : Colors.green[800],
                            fontWeight: FontWeight.bold,
                          ),
                          backgroundColor: Colors.green[50],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: selected ? 4 : 0,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Terdekat',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    Switch(
                      value: _showNearest,
                      activeColor: const Color(0xFF43E97B),
                      onChanged: (val) {
                        setState(() {
                          _showNearest = val;
                        });
                        if (val && _userPosition == null) {
                          _getUserLocation();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<KulinerProvider>(
              builder: (context, kulinerProvider, child) {
                if (kulinerProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                final allKuliner = kulinerProvider.kulinerList;
                List filteredKuliner = allKuliner;
                if (_selectedCategory != null) {
                  filteredKuliner = filteredKuliner
                      .where((k) => k.category == _selectedCategory)
                      .toList();
                }
                if (_searchQuery.isNotEmpty) {
                  filteredKuliner = filteredKuliner
                      .where((k) =>
                          k.name
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ||
                          k.address
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()))
                      .toList();
                }
                if (_showNearest && _userPosition != null) {
                  filteredKuliner.sort((a, b) =>
                      _distanceToUser(a.latitude, a.longitude)
                          .compareTo(_distanceToUser(b.latitude, b.longitude)));
                }
                if (filteredKuliner.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.search_off, size: 80, color: Colors.grey),
                        SizedBox(height: 20),
                        Text(
                          'Tidak ada kuliner yang ditemukan',
                          style: TextStyle(fontSize: 20, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  itemCount: filteredKuliner.length,
                  itemBuilder: (context, index) {
                    final kuliner = filteredKuliner[index];
                    double? distance;
                    if (_showNearest && _userPosition != null) {
                      distance = _distanceToUser(kuliner.latitude, kuliner.longitude);
                    }
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      elevation: 4,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  KulinerDetailScreen(kuliner: kuliner),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Leading image/icon
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: _buildKulinerImage(kuliner),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      kuliner.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        kuliner.category,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            kuliner.address,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (distance != null && distance < double.infinity)
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Jarak: ${distance ~/ 1} m',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.blue[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // Rating
                              Column(
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        kuliner.rating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    kuliner.priceRange,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
