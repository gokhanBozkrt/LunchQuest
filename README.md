# 🍽️ LunchQuest

> **Ofis sosyalleşmesini yeniden tanımlayan, AI destekli yemek ve mola platformu.**  
> *GİB Mobil Hackathon 2026 — Gamification & Corporate Play*

---

## 📱 Uygulama Hakkında

LunchQuest, şirketteki "bugün ne yesek?" sorusunu çözmekten çok daha fazlasını yapıyor. Yemek kararlarını oyunlaştırıyor, kahve molalarını sosyal etkinliğe dönüştürüyor ve çalışanlar arasındaki bağı güçlendiriyor.

### Çözülen Problemler

- 🤔 Her gün tekrarlayan "ne yesek?" tartışması
- 🔄 Hep aynı restorana sipariş verme alışkanlığı
- ☕ Kahve ve çatı molalarını organize etmenin zorluğu
- 👋 Yeni çalışanların ekiple kaynaşamaması
- 🏢 Şirket içi sosyalleşmenin yetersizliği

---

## ✨ Özellikler

### 🍕 Yemek Modülü
- AI destekli günlük restoran önerileri
- Takım bazlı oylama sistemi
- Geçmiş sipariş analizi ve tekrar azaltma
- Restoran keşif ve değerlendirme

### ☕ Mola Organizasyonu
- Tek tuşla kahve molası başlatma
- Çatı molası ve sosyal aktivite oluşturma
- Push notification ile anlık davet
- Katılımcı sayısı tahmini (AI)

### 🎮 Gamification
- XP ve seviye sistemi
- Rozet koleksiyonu
- Takım ve bireysel liderboard
- Dünya mutfakları keşif sistemi

### 🤖 AI Entegrasyonu
- Kişiselleştirilmiş restoran önerileri
- Takım tercih analizi
- Akıllı bildirim önceliklendirme
- Katılım tahmini

---

## 🛠️ Teknoloji Stack

| Katman | Teknoloji |
|--------|-----------|
| **Framework** | Flutter 3.x (Cross-platform) |
| **State Management** | Provider |
| **Navigation** | GoRouter |
| **Backend** | Supabase |
| **Push Notification** | Firebase Cloud Messaging |
| **Local Notifications** | flutter_local_notifications |
| **Networking** | Dio |
| **DI** | GetIt |
| **Local Storage** | SharedPreferences |
| **Architecture** | MVVM + Clean Architecture |

---

## 🏗️ Mimari

```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   └── utils/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── viewmodels/
    ├── views/
    └── widgets/
```

---

## 🚀 Kurulum

### Gereksinimler

- Flutter SDK `^3.10.0`
- Dart SDK `^3.10.0`
- Firebase projesi
- Supabase projesi

### Adımlar

```bash
# Repoyu klonla
git clone https://github.com/gokhanBozkrt/LunchQuest.git
cd LunchQuest

# Bağımlılıkları yükle
flutter pub get

# Uygulamayı çalıştır
flutter run
```

### Ortam Değişkenleri

Proje kök dizininde `.env` dosyası oluştur:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

Firebase için `google-services.json` (Android) ve `GoogleService-Info.plist` (iOS) dosyalarını ilgili klasörlere ekle.

---

## 📋 Teknik Gereksinimler (Hackathon)

| Gereksinim | Durum | Detay |
|------------|-------|-------|
| ✅ Cross-platform | Tamamlandı | iOS + Android |
| ✅ Backend Entegrasyonu | Tamamlandı | Supabase |
| ✅ Push Notification | Tamamlandı | FCM |
| ✅ Deeplink | Tamamlandı | GoRouter |
| ✅ Offline Mode | Tamamlandı | SharedPreferences cache |
| ✅ Biometric Auth | Tamamlandı | local_auth |
| ✅ AI / LLM | Tamamlandı | Restoran öneri motoru |

---

## 🎯 Ekran Akışı

```
Biometrik Giriş
      ↓
Ana Ekran (AI Öneriler + Aktif Oylamalar + Mola CTA)
      ↓
  ┌───────────────────────┐
  │                       │
Oylama Ekranı      Mola Oluştur
(Restoran seç)     (Tür + Mesaj)
  │                       │
  └──────────┬────────────┘
             ↓
      Liderboard + Rozetler
```

---

## 🏆 Gamification Sistemi

### XP Tablosu

| Aksiyon | XP |
|---------|----|
| Oylama katılımı | +10 |
| Mola organizasyonu | +25 |
| Etkinliğe katılım | +15 |
| 7 gün streak | +50 |
| Yeni restoran denemek | +30 |

### Seviyeler

| Seviye | XP | Unvan |
|--------|-----|-------|
| 1 | 0-100 | Yeni Gelen ☕ |
| 2 | 101-300 | Kahve Dostu ☕☕ |
| 3 | 301-700 | Öğle Kaşifi 🗺️ |
| 4 | 701-1500 | Sosyal Katalizör ⚡ |
| 5 | 1500+ | Ofis Efsanesi 👑 |

---

## 👥 Ekip

**GİB Teknoloji — Mobil Hackathon 2026**

---

## 📄 Lisans

Bu proje GİB Mobil Hackathon 2026 kapsamında geliştirilmiştir.
