# CRUD Operations Documentation - Balikuliner App

## Overview

Database helper sudah mendukung operasi CRUD (Create, Read, Update, Delete) lengkap untuk semua entitas:

- **User** (Pengguna)
- **Kuliner** (Tempat makan)
- **Review** (Ulasan)

Database mendukung dua platform:

- **SQLite** untuk mobile (Android/iOS)
- **Sembast** untuk web

## User CRUD Operations

### Create (Insert)

```dart
// Insert user baru
Future<int> insertUser(User user)
```

### Read

```dart
// Get user by email (untuk login)
Future<User?> getUserByEmail(String email)

// Get user by ID
Future<User?> getUserById(int id)

// Get semua users (untuk admin)
Future<List<User>> getAllUsers()
```

### Update

```dart
// Update user
Future<int> updateUser(User user)
```

### Delete

```dart
// Delete user by ID
Future<int> deleteUser(int id)
```

## Kuliner CRUD Operations

### Create (Insert)

```dart
// Insert kuliner baru
Future<int> insertKuliner(Kuliner kuliner)
```

### Read

```dart
// Get semua kuliner
Future<List<Kuliner>> getAllKuliner()

// Get kuliner by ID
Future<Kuliner?> getKulinerById(int id)

// Search kuliner (by name, description, address)
Future<List<Kuliner>> searchKuliner(String query)
```

### Update

```dart
// Update kuliner
Future<int> updateKuliner(Kuliner kuliner)
```

### Delete

```dart
// Delete kuliner by ID (akan delete reviews terkait juga)
Future<int> deleteKuliner(int id)
```

## Review CRUD Operations

### Create (Insert)

```dart
// Insert review baru
Future<int> insertReview(Review review)
```

### Read

```dart
// Get reviews untuk kuliner tertentu
Future<List<Review>> getReviewsForKuliner(int kulinerId)

// Get review by ID
Future<Review?> getReviewById(int id)

// Get semua reviews (untuk admin)
Future<List<Review>> getAllReviews()
```

### Update

```dart
// Update review (akan update rating kuliner otomatis)
Future<int> updateReview(Review review)
```

### Delete

```dart
// Delete review by ID (akan update rating kuliner otomatis)
Future<int> deleteReview(int id)
```

## Contoh Penggunaan

### 1. Menambah Kuliner Baru

```dart
final kuliner = Kuliner(
  name: 'Warung Makan Baru',
  description: 'Warung makan enak di Bali',
  category: 'Makanan Utama',
  priceRange: 'Rp 20.000 - 50.000',
  address: 'Jl. Raya Kuta',
  latitude: -8.7237,
  longitude: 115.1750,
  userId: 1,
  createdAt: DateTime.now(),
);

final id = await DatabaseHelper.instance.insertKuliner(kuliner);
```

### 2. Mencari Kuliner

```dart
// Search by keyword
final results = await DatabaseHelper.instance.searchKuliner('ayam');

// Get semua kuliner
final allKuliner = await DatabaseHelper.instance.getAllKuliner();
```

### 3. Menambah Review

```dart
final review = Review(
  kulinerId: 1,
  userId: 1,
  rating: 5,
  comment: 'Enak sekali!',
  createdAt: DateTime.now(),
);

final id = await DatabaseHelper.instance.insertReview(review);
```

### 4. Update Kuliner

```dart
final kuliner = await DatabaseHelper.instance.getKulinerById(1);
if (kuliner != null) {
  final updatedKuliner = kuliner.copyWith(
    name: 'Nama Baru',
    description: 'Deskripsi baru',
  );
  await DatabaseHelper.instance.updateKuliner(updatedKuliner);
}
```

### 5. Delete Kuliner

```dart
// Ini akan delete kuliner dan semua review terkait
await DatabaseHelper.instance.deleteKuliner(1);
```

## Fitur Khusus

### 1. Auto Rating Update

- Ketika review ditambah/diupdate/dihapus, rating kuliner akan otomatis diupdate
- Rating dihitung dari rata-rata semua review untuk kuliner tersebut

### 2. Cascade Delete

- Ketika kuliner dihapus, semua review terkait akan otomatis dihapus

### 3. Cross-Platform Support

- SQLite untuk mobile (Android/iOS)
- Sembast untuk web
- Otomatis memilih database yang sesuai

### 4. Data Dummy

- Database sudah berisi data dummy untuk testing
- User default: candra@balikuliner.com / admin123
- 5 kuliner dummy dengan review

## Error Handling

Semua operasi CRUD mengembalikan:

- `Future<int>` untuk insert/update/delete (jumlah baris yang terpengaruh)
- `Future<T?>` untuk get by ID (null jika tidak ditemukan)
- `Future<List<T>>` untuk get all/search (empty list jika tidak ada data)

## Best Practices

1. Selalu gunakan `DatabaseHelper.instance` untuk mengakses database
2. Handle null values dengan baik
3. Gunakan try-catch untuk error handling
4. Update UI setelah operasi CRUD berhasil
5. Validasi data sebelum insert/update
