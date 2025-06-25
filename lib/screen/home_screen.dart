import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_providers.dart';
import '../providers/kuliner_provider.dart';
import '../widgets/kuliner_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BaliKuliner'),
        automaticallyImplyLeading: false,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    'Hello, ${auth.currentUser?.username ?? 'User'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _HomeScreenBody(),
    );
  }
}

class _HomeScreenBody extends StatefulWidget {
  @override
  State<_HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<_HomeScreenBody> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;

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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<KulinerProvider>(context, listen: false)
            .loadKuliner();
      },
      child: Consumer<KulinerProvider>(
        builder: (context, kulinerProvider, child) {
          if (kulinerProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final allKuliner = kulinerProvider.kulinerList;
          final categories = _getCategories(allKuliner);

          // Filter berdasarkan kategori dan search
          List kulinerList = allKuliner;
          if (_selectedCategory != null) {
            kulinerList = kulinerList
                .where((k) => k.category == _selectedCategory)
                .toList();
          }
          if (_searchQuery.isNotEmpty) {
            kulinerList = kulinerList
                .where((k) =>
                    k.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    k.address
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                .toList();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discover Authentic Balinese Cuisine',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Explore the best culinary experiences in Bali',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 16),
                    // Kategori
                    SizedBox(
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
                    ),
                    const SizedBox(height: 16),
                    // Search makanan/restoran
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
                  ],
                ),
              ),
              Expanded(
                child: kulinerList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.search_off_rounded,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Makanan atau restoran yang kamu cari tidak ditemukan.',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: kulinerList.length,
                        itemBuilder: (context, index) {
                          final kuliner = kulinerList[index];
                          return KulinerCard(kuliner: kuliner);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
