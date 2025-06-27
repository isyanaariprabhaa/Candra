import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/kuliner_provider.dart';
import 'kuliner_detail_screen.dart';
import 'package:geolocator/geolocator.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> _getCategories(List kulinerList) {
    final categories =
        kulinerList.map((k) => k.category).toSet().toList().cast<String>();
    categories.sort();
    return categories;
  }

  void _loadKulinerData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<KulinerProvider>(context, listen: false).loadKuliner();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari makanan atau restoran...',
                    prefixIcon: const Icon(Icons.search_rounded),
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                Consumer<KulinerProvider>(
                  builder: (context, kulinerProvider, child) {
                    final categories =
                        _getCategories(kulinerProvider.kulinerList);
                    return SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (context, i) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final cat = categories[i];
                          final selected = cat == _selectedCategory;
                          return ChoiceChip(
                            label: Text(cat),
                            selected: selected,
                            onSelected: (val) {
                              setState(() {
                                _selectedCategory = selected ? null : cat;
                              });
                            },
                            selectedColor: Colors.green[600],
                            labelStyle: TextStyle(
                              color:
                                  selected ? Colors.white : Colors.green[800],
                              fontWeight: FontWeight.bold,
                            ),
                            backgroundColor: Colors.green[50],
                          );
                        },
                      ),
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Terdekat'),
                    Switch(
                      value: _showNearest,
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
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: Colors.grey[600]),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada kuliner yang ditemukan',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredKuliner.length,
                  itemBuilder: (context, index) {
                    final kuliner = filteredKuliner[index];
                    double? distance;
                    if (_showNearest && _userPosition != null) {
                      distance =
                          _distanceToUser(kuliner.latitude, kuliner.longitude);
                    }
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          child:
                              Icon(Icons.restaurant, color: Colors.grey[600]),
                        ),
                        title: Text(kuliner.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(kuliner.category),
                            if (distance != null && distance < double.infinity)
                              Text('Jarak: ${distance ~/ 1} m',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.blueGrey)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            Text(kuliner.rating.toStringAsFixed(1)),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  KulinerDetailScreen(kuliner: kuliner),
                            ),
                          );
                        },
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
