# Image Upload Guide - Balikuliner App 📸

## ✅ Fitur Upload Gambar - SUDAH DIPERBAIKI

### Fitur yang Tersedia:

- ✅ **Gallery Picker** - Pilih gambar dari galeri
- ❌ **Camera Picker** - Dihapus (hanya galeri)
- ✅ **Image Validation** - Validasi ukuran file (max 5MB)
- ✅ **Permission Handling** - Request storage permission otomatis
- ✅ **Error Handling** - Pesan error yang informatif
- ✅ **UI/UX** - Interface yang user-friendly

## 🔧 Setup yang Sudah Dilakukan

### 1. Android Permissions ✅

File: `android/app/src/main/AndroidManifest.xml`

```xml
<!-- Permissions for image picker (gallery only) -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

### 2. Dependencies ✅

File: `pubspec.yaml`

```yaml
dependencies:
  image_picker: ^1.0.4
  permission_handler: ^11.0.1
```

### 3. Permission Helper ✅

File: `lib/utils/permission_helper.dart`

- Handle storage permission only
- Handle location permission
- Show permission dialog

## 📱 Cara Menggunakan

### 1. Buka Add Culinary Screen

- Klik tombol "+" di home screen
- Atau navigasi ke "Add New Culinary Spot"

### 2. Upload Gambar

1. **Tap area "Add Photo"**
   - Langsung akan membuka galeri
2. **Pilih gambar dari galeri**

   - Pilih gambar yang sudah ada di galeri
   - Tidak ada opsi kamera

3. **Setelah memilih gambar:**
   - Gambar akan ditampilkan di preview
   - Nama file akan muncul di sebelah kanan
   - Tombol "X" merah untuk hapus gambar

### 3. Validasi Otomatis

- **Ukuran file**: Maksimal 5MB
- **Format**: JPG, PNG, dll
- **Permission**: Otomatis request storage permission

## 🛠️ Technical Details

### Image Picker Implementation

```dart
Future<void> _pickImage(ImageSource source) async {
  // Request storage permission only
  bool storageGranted = await PermissionHelper.requestStoragePermission(context);

  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(
    source: ImageSource.gallery, // Always use gallery
    maxWidth: 1024,
    maxHeight: 1024,
    imageQuality: 85,
  );

  // Validate file size
  final file = File(image.path);
  final fileSize = await file.length();
  final maxSize = 5 * 1024 * 1024; // 5MB
}
```

### Permission Handling

```dart
static Future<bool> requestStoragePermission(BuildContext context) async {
  PermissionStatus status = await Permission.storage.status;
  // Request storage permission only
}
```

### UI Components

- **Image Preview**: 120x120 dengan border rounded
- **Remove Button**: Tombol X merah di pojok kanan atas
- **Status Text**: Menampilkan nama file atau "No image selected"
- **Error Message**: Pesan error di bawah image picker

## 🚨 Troubleshooting

### 1. Permission Denied

**Problem**: "Storage permission is required to select images from gallery"
**Solution**:

- Tap "Settings" di dialog permission
- Enable Storage permission
- Restart app

### 2. Image Too Large

**Problem**: "Image size too large. Please select an image smaller than 5MB"
**Solution**:

- Pilih gambar yang lebih kecil
- Atau compress gambar terlebih dahulu

### 3. Gallery Not Working

**Problem**: Tidak bisa akses galeri
**Solution**:

- Pastikan permission storage sudah diizinkan
- Restart app
- Cek apakah ada gambar di galeri

## 📋 Test Cases

### Test Case 1: Upload dari Gallery

1. Buka Add Culinary Screen
2. Tap "Add Photo"
3. Pilih gambar dari galeri
4. ✅ Gambar muncul di preview

### Test Case 2: Permission Handling

1. Buka Add Culinary Screen
2. Tap "Add Photo"
3. Jika permission ditolak, dialog akan muncul
4. Tap "Settings" untuk buka pengaturan
5. ✅ Enable storage permission dan restart app

### Test Case 3: File Size Validation

1. Pilih gambar > 5MB
2. ✅ Error message muncul
3. ✅ Gambar tidak tersimpan

### Test Case 4: Remove Image

1. Upload gambar
2. Tap tombol "X" merah
3. ✅ Gambar terhapus dari preview

## 🎯 Best Practices

### 1. Image Optimization

- Gunakan gambar dengan ukuran < 5MB
- Format JPG untuk foto, PNG untuk gambar dengan transparansi
- Compress gambar jika terlalu besar

### 2. Permission Management

- Hanya request storage permission (tidak perlu camera)
- Berikan penjelasan mengapa permission diperlukan
- Handle kasus permission ditolak dengan graceful

### 3. Error Handling

- Tampilkan pesan error yang jelas
- Berikan solusi untuk user
- Log error untuk debugging

### 4. User Experience

- Preview gambar sebelum upload
- Loading indicator saat proses
- Konfirmasi sebelum hapus gambar

## 🔄 Future Improvements

### 1. Image Upload ke Server

- Upload gambar ke cloud storage
- Dapatkan URL untuk disimpan di database
- Handle upload progress

### 2. Image Editing

- Crop gambar
- Filter/effects
- Rotate image

### 3. Multiple Images

- Upload beberapa gambar sekaligus
- Image gallery untuk kuliner

### 4. Image Compression

- Auto compress sebelum upload
- Pilih quality level

## ✅ Status: PRODUCTION READY

Fitur upload gambar sudah **LENGKAP dan SIAP DIGUNAKAN**!

**Perubahan terbaru:**

- ✅ Hanya upload dari galeri (tidak ada kamera)
- ✅ Permission yang lebih sederhana (storage only)
- ✅ UI yang lebih clean dan straightforward

Semua komponen sudah terintegrasi:

- ✅ Storage permission handling
- ✅ Gallery picker
- ✅ File validation
- ✅ Error handling
- ✅ UI/UX yang baik

**Ready untuk testing dan deployment!** 🚀
