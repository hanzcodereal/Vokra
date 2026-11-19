## Maintenance Notification System

### Cara Penggunaan:

#### 1. **Untuk Menampilkan Notifikasi di Anime Page**
Sudah otomatis ditambahkan di `HomeAnimePage`. Maintenance banner akan muncul di bagian atas.

#### 2. **Untuk Mengaktifkan Maintenance Mode dari Developer Panel**

**Tambahkan di file Admin Panel atau Dashboard:**

```dart
import 'package:xxo25/maintenance_panel.dart';

// Di dalam admin atau dashboard page, tambahkan route/button untuk membuka panel:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => Scaffold(
      appBar: AppBar(
        title: const Text('Developer Settings'),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.lightBlue),
      ),
      body: const MaintenancePanel(),
    ),
  ),
);
```

#### 3. **Untuk Mengaktifkan Maintenance Mode Programmatically**

```dart
import 'package:xxo25/maintenance_notification.dart';

// Aktifkan maintenance mode
await MaintenanceNotification.setMaintenanceMode(
  true,
  'Server sedang maintenance. Kembali dalam 1 jam.'
);

// Nonaktifkan maintenance mode
await MaintenanceNotification.setMaintenanceMode(false, null);

// Reset notifikasi (tampilkan kembali ke semua user)
await MaintenanceNotification.resetDismissed();
```

#### 4. **Perubahan di File**

- **maintenance_notification.dart** - Core logic untuk maintenance notification
- **maintenance_panel.dart** - UI panel untuk developer mengaktifkan/nonaktifkan
- **anime.dart** - Sudah ditambahkan MaintenanceBanner di bagian atas

### Fitur:
✅ Notifikasi muncul di semua perangkat  
✅ User bisa dismiss, tapi notif bisa di-reset dari dashboard  
✅ Styling sesuai dark theme app  
✅ LocalStorage (SharedPreferences) - bisa diakses offline  
✅ Custom maintenance message  

### Dimana Maintenance Banner Muncul:
- HomeAnimePage (sudah otomatis)
- Bisa ditambahkan ke halaman lain dengan menambahkan `MaintenanceBanner()`

### Testing:
1. Buka app
2. Di Developer Panel, aktifkan Maintenance Mode
3. Lihat notifikasi amber muncul di atas search bar
4. Notifikasi muncul otomatis di semua perangkat yang buka app
5. User bisa dismiss dengan click X
6. Developer bisa reset notifikasi untuk menampilkan ulang
