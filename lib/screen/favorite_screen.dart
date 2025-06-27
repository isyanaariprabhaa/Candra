import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/kuliner_provider.dart';
import '../widgets/kuliner_card.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite'),
      ),
      body: Consumer2<FavoriteProvider, KulinerProvider>(
        builder: (context, favoriteProvider, kulinerProvider, child) {
          final favoriteIds = favoriteProvider.favoriteIds;
          final favoriteKuliners = kulinerProvider.getKulinerByIds(favoriteIds);
          if (favoriteKuliners.isEmpty) {
            return const Center(
              child: Text('Belum ada makanan favorite.'),
            );
          }
          return ListView.builder(
            itemCount: favoriteKuliners.length,
            itemBuilder: (context, index) {
              final kuliner = favoriteKuliners[index];
              return KulinerCard(kuliner: kuliner);
            },
          );
        },
      ),
    );
  }
}
