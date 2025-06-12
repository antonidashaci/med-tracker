# 💊 İlaç Takibi (Medicine Tracker)

[![Flutter](https://img.shields.io/badge/Flutter-3.16+-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.2+-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Modern ve kullanıcı dostu bir ilaç takip uygulaması. iOS tarzı tasarım ile Flutter kullanılarak geliştirilmiştir.

## 🌟 Özellikler

### 📱 Ana Özellikler
- **iOS tarzı tasarım** - Cupertino widget'ları ile modern arayüz
- **Çift dil desteği** - Türkçe ve İngilizce
- **Yerel depolama** - Hive ile güvenli veri saklama
- **Bildirimler** - İlaç hatırlatıcıları
- **QR kod tarama** - İlaç bilgilerini hızlıca ekleme
- **QR kod oluşturma** - İlaç bilgilerini paylaşma

### 💊 İlaç Yönetimi
- ✅ Yeni ilaç ekleme ve düzenleme
- ✅ İlaç detay görüntüleme
- ✅ QR kod ile hızlı ilaç ekleme
- ✅ İlaç düzenleme ve silme
- ✅ Aktif/pasif durumu değiştirme

### 📊 İstatistikler ve Grafikler
- 📈 İlaç alma geçmişi grafiği
- 📊 Uyumluluk oranları
- 🔥 Seri takibi (mevcut/en uzun)
- ⏰ Zamanında/gecikmeli alma istatistikleri
- 📅 Farklı zaman aralıkları (7 gün, 30 gün, 3 ay)

### 🔔 Bildirimler
- ⏰ İlaç hatırlatıcıları
- 🕐 Özelleştirilebilir saatler
- 📅 Günlük tekrarlar
- ⚙️ Bildirim yönetimi

### 📦 Stok Takibi
- 📦 İlaç stok adedi takibi
- ⚠️ Stok azalma uyarıları
- 🔔 Stok bildirimleri
- 📊 Hızlı stok güncelleme

### ⚠️ İlaç Etkileşimleri
- 🔗 Etkileşimli ilaç seçimi
- ⚠️ Etkileşim uyarıları
- 🛡️ Güvenli ilaç kullanımı

### 📈 Gelişmiş Analiz
- 📊 Detaylı uyumluluk grafikleri
- 📈 Günlük alım analizi
- 🕐 Zaman bazlı analiz
- 📋 İstatistik raporları

## 🚀 Kurulum

### Gereksinimler
- Flutter 3.16+
- Dart 3.2+
- iOS 12.0+ / Android 5.0+

### Adımlar

1. **Repository'yi klonlayın**
```bash
git clone https://github.com/antonidashaci/med-tracker.git
cd med-tracker
```

2. **Bağımlılıkları yükleyin**
```bash
flutter pub get
```

3. **Hive adapter'larını oluşturun**
```bash
flutter packages pub run build_runner build
```

4. **Uygulamayı çalıştırın**
```bash
flutter run
```

## 📱 Ekran Görüntüleri

### Ana Ekran
- İstatistik kartları
- İlaç listesi
- Stok uyarıları
- Hızlı erişim butonları

### İlaç Detay
- Detaylı ilaç bilgileri
- Gelişmiş grafikler
- Stok durumu
- Etkileşim uyarıları

### QR Kod Tarama
- Kamera ile QR kod okuma
- Otomatik bilgi doldurma
- Hızlı ilaç ekleme

## 🛠️ Teknik Detaylar

### Kullanılan Teknolojiler
- **Flutter** - Cross-platform framework
- **Provider** - State management
- **Hive** - Local database
- **flutter_local_notifications** - Bildirimler
- **qr_code_scanner** - QR kod tarama
- **qr_flutter** - QR kod oluşturma
- **fl_chart** - Grafikler
- **intl** - Çoklu dil desteği

### Proje Yapısı
```
lib/
├── core/
│   ├── constants/     # Sabitler
│   ├── theme/         # Tema ayarları
│   └── utils/         # Yardımcı fonksiyonlar
├── data/
│   ├── models/        # Veri modelleri
│   └── adapters/      # Hive adapter'ları
├── presentation/
│   ├── screens/       # Ekranlar
│   ├── widgets/       # Widget'lar
│   └── providers/     # State provider'ları
├── services/          # Servisler
└── routes/            # Rota yönetimi
```

### Veri Modelleri
- **Medicine** - İlaç bilgileri
- **Reminder** - Hatırlatıcılar
- **MedicineHistory** - İlaç alma geçmişi

## 🔧 Konfigürasyon

### Bildirim Ayarları
```dart
// Android için
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE" />

// iOS için
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

### Hive Konfigürasyonu
```dart
// main.dart
await Hive.initFlutter();
Hive.registerAdapter(MedicineAdapter());
Hive.registerAdapter(ReminderAdapter());
Hive.registerAdapter(MedicineHistoryAdapter());
```

## 📊 Özellik Detayları

### QR Kod Formatı
```
MEDICINE|name|dosage|dosageUnit|frequency|category
```

### Stok Takibi
- Stok adedi girişi
- Uyarı eşiği belirleme
- Otomatik bildirimler
- Hızlı güncelleme

### İlaç Etkileşimleri
- Etkileşimli ilaç seçimi
- Uyarı dialog'ları
- Güvenlik kontrolleri

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📝 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 🙏 Teşekkürler

- [Flutter](https://flutter.dev) - Cross-platform framework
- [Hive](https://pub.dev/packages/hive) - Local database
- [Provider](https://pub.dev/packages/provider) - State management
- [fl_chart](https://pub.dev/packages/fl_chart) - Grafikler

## 📞 İletişim

- **GitHub**: [@antonidashaci](https://github.com/antonidashaci)
- **Repository**: [med-tracker](https://github.com/antonidashaci/med-tracker)

---

⭐ Bu projeyi beğendiyseniz yıldız vermeyi unutmayın!

