import 'package:flutter/material.dart';
import '../models/kuliner.dart';
import '../utils/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';
import 'dart:io';
import 'dart:convert';

class KulinerCard extends StatelessWidget {
  final Kuliner kuliner;
  final VoidCallback? onTap;
  final double? distance;

  const KulinerCard({
    super.key,
    required this.kuliner,
    this.onTap,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final isFav = favoriteProvider.isFavorite(kuliner.id ?? 0);
    
    // Debug print untuk memeriksa ID kuliner
    if (kuliner.id == null || kuliner.id == 0) {
      print('Warning: KulinerCard received kuliner with invalid ID: ${kuliner.id}');
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                    ),
                    child: _buildImageWidget(),
                  ),
                ),

                // Content section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              kuliner.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                kuliner.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Category
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          kuliner.category,
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Description
                      Text(
                        kuliner.description,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Price and location
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            color: Colors.green[600],
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            kuliner.priceRange,
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.location_on,
                            color: Colors.red[400],
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final url =
                                    'https://www.google.com/maps/search/?api=1&query=${kuliner.latitude},${kuliner.longitude}';
                                if (await canLaunch(url)) {
                                  await launch(url);
                                }
                              },
                              child: Text(
                                kuliner.address,
                                style: TextStyle(
                                  color: Colors.red[400],
                                  fontSize: 12,
                                  decoration: TextDecoration.underline,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Tampilkan jarak jika tersedia
                      if (distance != null && distance! < double.infinity)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.directions_walk,
                                size: 14,
                                color: Colors.blue[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Jarak: ${distance! ~/ 1} m',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Hanya tampilkan tombol favorite jika ID kuliner valid
          if (kuliner.id != null && kuliner.id! > 0)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  favoriteProvider.toggleFavorite(kuliner.id!);
                },
                tooltip: isFav ? 'Hapus dari Favorite' : 'Tambah ke Favorite',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageWidget() {
    if (kuliner.imageUrl != null && kuliner.imageUrl!.isNotEmpty) {
      if (kuliner.imageUrl!.startsWith('http')) {
        return Image.network(
          kuliner.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.restaurant,
              size: 80,
              color: Colors.grey,
            );
          },
        );
      } else if (kuliner.imageUrl!.startsWith('assets/')) {
        return Image.asset(
          kuliner.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.restaurant,
              size: 80,
              color: Colors.grey,
            );
          },
        );
      } else if (kuliner.imageUrl!.startsWith('data:image/')) {
        return Image.memory(
          base64Decode(kuliner.imageUrl!.split(',').last),
          fit: BoxFit.cover,
        );
      } else {
        return Image.file(
          File(kuliner.imageUrl!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.restaurant,
              size: 80,
              color: Colors.grey,
            );
          },
        );
      }
    } else {
      return Image.asset(
        'assets/images/ayam_betutu.jpeg',
        fit: BoxFit.cover,
      );
    }
  }
}
