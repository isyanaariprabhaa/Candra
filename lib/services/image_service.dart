import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class ImageService {
  // Opsi 1: Upload ke server (jika ada backend)
  static Future<String?> uploadImageToServer(File imageFile) async {
    try {
      // Contoh upload ke server (ganti dengan endpoint yang sesuai)
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://your-api.com/upload-image'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonData = json.decode(responseData);

      if (response.statusCode == 200) {
        return jsonData['image_url']; // URL dari server
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
    return null;
  }

  // Opsi 2: Gunakan placeholder image service
  static String getPlaceholderImageUrl(String name) {
    // Menggunakan Unsplash untuk placeholder images
    return 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=600&q=80&text=${Uri.encodeComponent(name)}';
  }

  // Opsi 3: Gunakan category-based images
  static String getCategoryImageUrl(String category) {
    switch (category.toLowerCase()) {
      case 'makanan utama':
        return 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=600&q=80';
      case 'minuman':
        return 'https://images.unsplash.com/photo-1504674900247-ec6b0b1b7982?auto=format&fit=crop&w=600&q=80';
      case 'dessert':
        return 'https://images.unsplash.com/photo-1565958011703-44f9829ba187?auto=format&fit=crop&w=600&q=80';
      case 'snack':
        return 'https://images.unsplash.com/photo-1519864600265-abb23847ef2c?auto=format&fit=crop&w=600&q=80';
      case 'seafood':
        return 'https://images.unsplash.com/photo-1464306076886-debca5e8a6b0?auto=format&fit=crop&w=600&q=80';
      case 'vegetarian':
        return 'https://images.unsplash.com/photo-1502741338009-cac2772e18bc?auto=format&fit=crop&w=600&q=80';
      default:
        return 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=600&q=80';
    }
  }

  // Opsi 4: Convert local path to base64 (untuk testing)
  static Future<String?> convertImageToBase64(File imageFile) async {
    try {
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      return 'data:image/jpeg;base64,$base64Image';
    } catch (e) {
      print('Error converting image to base64: $e');
      return null;
    }
  }

  // Opsi 5: Generate unique filename dan simpan di local storage
  static String generateImageFileName(String originalName) {
    String extension = path.extension(originalName);
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return 'kuliner_$timestamp$extension';
  }

  // Opsi 6: Gunakan random food images dari Unsplash
  static String getRandomFoodImageUrl() {
    List<String> foodImages = [
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1519864600265-abb23847ef2c?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1502741338009-cac2772e18bc?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1464306076886-debca5e8a6b0?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1504674900247-ec6b0b1b7982?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1565958011703-44f9829ba187?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?auto=format&fit=crop&w=600&q=80',
    ];

    return foodImages[
        DateTime.now().millisecondsSinceEpoch % foodImages.length];
  }

  // Method utama untuk mendapatkan image URL
  static Future<String> getImageUrl(
      File? imageFile, String category, String name) async {
    // Jika ada gambar yang dipilih, gunakan base64 untuk menyimpan gambar lokal
    if (imageFile != null) {
      try {
        // Coba convert ke base64 terlebih dahulu
        String? base64Url = await convertImageToBase64(imageFile);
        if (base64Url != null) {
          print('Successfully converted image to base64');
          return base64Url;
        }
      } catch (e) {
        print('Error converting image to base64: $e');
      }

      // Jika base64 gagal, coba upload ke server (opsional)
      try {
        String? uploadedUrl = await uploadImageToServer(imageFile);
        if (uploadedUrl != null) {
          return uploadedUrl;
        }
      } catch (e) {
        print('Error uploading image to server: $e');
      }
    }

    // Fallback: gunakan category-based image
    return getCategoryImageUrl(category);
  }
}
