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
                Consumer<KulinerProvider>(
                  builder: (context, kulinerProvider, child) {
                    final categories =
                        _getCategories(kulinerProvider.kulinerList);
                    return SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (context, i) =>
                            const SizedBox(width: 10),
                        itemBuilder: (context, i) {
                          final cat = categories[i];
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
                    );
                  },
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
                      distance =
                          _distanceToUser(kuliner.latitude, kuliner.longitude);
                    }
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      elevation: 4,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green[50],
                          child:
                              Icon(Icons.restaurant, color: Colors.green[400]),
                        ),
                        title: Text(kuliner.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(kuliner.category),
                            if (distance != null && distance < double.infinity)
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text('Jarak: ${distance ~/ 1} m',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.blueGrey)),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            Text(kuliner.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
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
