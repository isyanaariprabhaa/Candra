import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/kuliner.dart';
import '../models/review.dart';
import '../providers/kuliner_provider.dart';
import '../providers/auth_providers.dart';
import '../utils/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

class KulinerDetailScreen extends StatefulWidget {
  final Kuliner kuliner;

  const KulinerDetailScreen({super.key, required this.kuliner});

  @override
  _KulinerDetailScreenState createState() => _KulinerDetailScreenState();
}

class _KulinerDetailScreenState extends State<KulinerDetailScreen> {
  List<Review> _reviews = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReviews();
    });
  }

  void _loadReviews() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final reviews = await Provider.of<KulinerProvider>(context, listen: false)
          .getReviewsForKuliner(widget.kuliner.id!);

      if (mounted) {
        setState(() {
          _reviews = reviews;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading reviews: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reviews: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.kuliner.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.directions),
            onPressed: _openInMaps,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildInfo(),
            _buildReviewSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReviewDialog,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.rate_review, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    try {
      final imageUrl = widget.kuliner.imageUrl;
      if (imageUrl == null || imageUrl.isEmpty) {
        return Container(
          height: 200,
          width: double.infinity,
          color: Colors.grey[300],
          child: const Icon(
            Icons.restaurant,
            size: 80,
            color: Colors.grey,
          ),
        );
      }

      Widget imageWidget;
      if (imageUrl.startsWith('assets/')) {
        imageWidget = Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading asset image: $imageUrl: ${error.toString()}');
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.restaurant, size: 80, color: Colors.grey),
            );
          },
        );
      } else if (imageUrl.startsWith('http')) {
        imageWidget = Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              color: Colors.grey[300],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print(
                'Error loading network image: $imageUrl: ${error.toString()}');
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.restaurant, size: 80, color: Colors.grey),
            );
          },
        );
      } else {
        imageWidget = Image.file(
          File(imageUrl),
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading file image: $imageUrl: ${error.toString()}');
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.restaurant, size: 80, color: Colors.grey),
            );
          },
        );
      }

      return Container(
        height: 200,
        width: double.infinity,
        color: Colors.grey[300],
        child: imageWidget,
      );
    } catch (e) {
      print('Error building header: $e');
      return Container(
        height: 200,
        width: double.infinity,
        color: Colors.grey[300],
        child: const Icon(
          Icons.restaurant,
          size: 80,
          color: Colors.grey,
        ),
      );
    }
  }

  Widget _buildInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.kuliner.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                widget.kuliner.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${_reviews.length} reviews)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.category, 'Category', widget.kuliner.category),
          _buildInfoRow(
              Icons.attach_money, 'Price Range', widget.kuliner.priceRange),
          _buildInfoRow(Icons.location_on, 'Address', widget.kuliner.address),
          const SizedBox(height: 16),
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.kuliner.description,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reviews',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_reviews.isEmpty)
            const Center(
              child: Text(
                'No reviews yet. Be the first to review!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                final review = _reviews[index];
                return _buildReviewCard(review);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  review.username ?? 'Anonymous',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      Icons.star,
                      color: index < review.rating ? Colors.amber : Colors.grey,
                      size: 16,
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              review.comment,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(review.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _openInMaps() async {
    final lat = widget.kuliner.latitude;
    final lng = widget.kuliner.longitude;
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open maps')),
      );
    }
  }

  void _showAddReviewDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add a review')),
      );
      return;
    }

    int rating = 5;
    String comment = '';
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Review'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Rating:'),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            Icons.star,
                            color: index < rating ? Colors.amber : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              rating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        labelText: 'Comment',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        comment = value;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _submitReview(rating, comment);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _submitReview(int rating, String comment) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final kulinerProvider =
          Provider.of<KulinerProvider>(context, listen: false);

      // Check if user is logged in
      if (authProvider.currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to add a review')),
        );
        return;
      }

      // Check if comment is not empty
      if (comment.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a comment')),
        );
        return;
      }

      double? latitude;
      double? longitude;

      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          if (permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always) {
            Position position = await Geolocator.getCurrentPosition();
            latitude = position.latitude;
            longitude = position.longitude;
          }
        }
      } catch (e) {
        print('Error getting location: $e');
        // Jika gagal ambil lokasi, biarkan null
      }

      final review = Review(
        kulinerId: widget.kuliner.id!,
        userId: authProvider.currentUser!.id!,
        rating: rating,
        comment: comment.trim(),
        createdAt: DateTime.now(),
        latitude: latitude,
        longitude: longitude,
        username: authProvider.currentUser!.username,
      );

      await kulinerProvider.addReview(review);

      if (mounted) {
        _loadReviews(); // Refresh reviews
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review added successfully!')),
        );
      }
    } catch (e) {
      print('Error submitting review: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding review: $e')),
        );
      }
    }
  }
}
