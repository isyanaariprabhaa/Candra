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
import 'dart:convert';
import 'package:shimmer/shimmer.dart';

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
      print('Loading reviews for kuliner ID: ${widget.kuliner.id}');
      
      setState(() {
        _isLoading = true;
      });

      final reviews = await Provider.of<KulinerProvider>(context, listen: false)
          .getReviewsForKuliner(widget.kuliner.id!);

      print('Loaded ${reviews.length} reviews');

      if (mounted) {
        setState(() {
          _reviews = reviews;
          _isLoading = false;
        });
        print('Reviews state updated. Total reviews: ${_reviews.length}');
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
          color: Colors.grey[200],
          child: Center(
            child: Image.asset(
              'assets/images/ayam_betutu.jpeg',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
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
            return Container(
              color: Colors.grey[200],
              child: Center(
                child: Image.asset(
                  'assets/images/ayam_betutu.jpeg',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
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
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[300],
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: Center(
                child: Image.asset(
                  'assets/images/ayam_betutu.jpeg',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
            );
          },
        );
      } else if (imageUrl.startsWith('data:image/')) {
        // Handle base64 images
        try {
          imageWidget = Image.memory(
            base64Decode(imageUrl.split(',').last),
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: Center(
                  child: Image.asset(
                    'assets/images/ayam_betutu.jpeg',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          );
        } catch (e) {
          imageWidget = Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey[200],
            child: Center(
              child: Image.asset(
                'assets/images/ayam_betutu.jpeg',
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
          );
        }
      } else {
        // Try as file path
        try {
          imageWidget = Image.file(
            File(imageUrl),
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: Center(
                  child: Image.asset(
                    'assets/images/ayam_betutu.jpeg',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          );
        } catch (e) {
          imageWidget = Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey[200],
            child: Center(
              child: Image.asset(
                'assets/images/ayam_betutu.jpeg',
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
          );
        }
      }
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: imageWidget,
      );
    } catch (e) {
      return Container(
        height: 200,
        width: double.infinity,
        color: Colors.grey[200],
        child: Center(
          child: Image.asset(
            'assets/images/ayam_betutu.jpeg',
            width: 100,
            height: 100,
            fit: BoxFit.contain,
          ),
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
            Container(
              constraints: const BoxConstraints(
                maxHeight: 320,
              ),
              child: Scrollbar(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _reviews.length,
                  itemBuilder: (context, index) {
                    final review = _reviews[index];
                    return _buildReviewCard(review);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isMyReview = authProvider.currentUser != null &&
        review.userId == authProvider.currentUser!.id;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      color: index < review.rating
                          ? Colors.amber
                          : Colors.grey[300],
                      size: 18,
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              review.comment,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(review.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (isMyReview)
                  Row(
                    children: [
                      // Edit Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            _showEditReviewDialog(review);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Delete Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () async {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                  child: CircularProgressIndicator()),
                            );
                            try {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Review'),
                                  content: const Text(
                                      'Are you sure you want to delete this review?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Delete',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              Navigator.pop(context); // Remove loading dialog
                              if (confirm == true) {
                                await Provider.of<KulinerProvider>(context,
                                        listen: false)
                                    .deleteReview(review.id!);
                                _loadReviews();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Review deleted successfully!')),
                                );
                              }
                            } catch (e) {
                              Navigator.pop(context); // Remove loading dialog
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Error deleting review: $e')),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
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
      print('Submitting review with rating: $rating, comment: $comment');
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final kulinerProvider =
          Provider.of<KulinerProvider>(context, listen: false);

      // Check if user is logged in
      if (authProvider.currentUser == null) {
        print('User not logged in');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to add a review')),
        );
        return;
      }

      // Check if comment is not empty
      if (comment.trim().isEmpty) {
        print('Comment is empty');
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

      print('Created review object: ${review.toMap()}');

      final success = await kulinerProvider.addReview(review);
      print('Review submission result: $success');

      if (mounted) {
        if (success) {
          // Add a small delay to ensure data is saved
          await Future.delayed(const Duration(milliseconds: 500));
          _loadReviews(); // Refresh reviews
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review added successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add review')),
          );
        }
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

  void _showEditReviewDialog(Review review) {
    int rating = review.rating;
    String comment = review.comment;
    final commentController = TextEditingController(text: review.comment);
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Review'),
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
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() => isLoading = true);

                          // Validate comment
                          if (comment.trim().isEmpty) {
                            setState(() => isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a comment'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          try {
                            final updatedReview = review.copyWith(
                              rating: rating,
                              comment: comment.trim(),
                            );

                            await Provider.of<KulinerProvider>(context,
                                    listen: false)
                                .updateReview(updatedReview);

                            if (mounted) {
                              Navigator.of(context).pop();
                              _loadReviews(); // Refresh reviews
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Review updated successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            setState(() => isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error updating review: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
