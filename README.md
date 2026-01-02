# Agri Waste to Fertilizer - Android App

**AI-enabled Circular Economy Platform for Agricultural Waste Management**

## 🌾 Overview

A Flutter-based mobile application that connects farmers and processors to transform agricultural waste into valuable organic fertilizers. This platform creates a sustainable circular economy by:

- **Farmers**: Upload and sell agricultural waste
- **Processors**: Buy waste and produce organic fertilizers
- **AI Chatbot**: Provides guidance for both parties
- **Smart Delivery**: Distance-based delivery charge calculation

---

## 🚀 Features

### 👨‍🌾 Farmer Features
- ✅ Upload agricultural waste with photos and details
- ✅ Browse and buy organic fertilizers
- ✅ AI chatbot for farming guidance
- ✅ Transaction history tracking
- ✅ Multi-language support (English/Hindi)

### 🏭 Processor Features
- ✅ Browse available agricultural waste
- ✅ List fertilizers for sale
- ✅ AI mentor for production planning
- ✅ Input-output calculations
- ✅ Sales and purchase history

### 🤖 AI Features
- ✅ Composting guidance
- ✅ Fertilizer production planning
- ✅ Pricing recommendations
- ✅ Quality control tips

### 📍 Smart Features
- ✅ Distance-based delivery charges (₹15/km)
- ✅ Minimum delivery charge: ₹50
- ✅ Maximum delivery distance: 100 km
- ✅ Location-based marketplace

---

## 🛠️ Tech Stack

| Component | Technology |
|-----------|-----------|
| **Framework** | Flutter 3.x |
| **Language** | Dart |
| **Backend** | Firebase (Auth, Firestore, Storage) |
| **Maps** | Google Maps Flutter |
| **State Management** | Provider |
| **UI** | Material Design 3 |
| **AI Chatbot** | OpenAI API / Dialogflow |

---

## 📁 Project Structure

```
lib/
│
├── main.dart                          # App entry point
│
├── core/
│   ├── constants/
│   │   └── app_constants.dart        # App-wide constants
│   └── theme/
│       └── app_theme.dart            # Material theme
│
├── auth/
│   ├── language_selection.dart       # Language picker
│   ├── login_screen.dart             # Login UI
│   └── register_screen.dart          # Registration UI
│
├── farmer/
│   ├── farmer_dashboard.dart         # Farmer home
│   ├── upload_waste/
│   │   └── upload_waste_screen.dart  # Post waste
│   ├── buy_fertilizer/
│   │   └── buy_fertilizer_screen.dart # Buy fertilizer
│   ├── chatbot/
│   │   └── farmer_chatbot_screen.dart # AI assistant
│   └── history/
│       └── farmer_history_screen.dart # Transaction history
│
├── processor/
│   ├── processor_dashboard.dart      # Processor home
│   ├── buy_waste/
│   │   └── buy_waste_screen.dart     # Browse waste
│   ├── sell_fertilizer/
│   │   └── sell_fertilizer_screen.dart # List fertilizer
│   ├── chatbot/
│   │   └── processor_chatbot_screen.dart # AI mentor
│   └── history/
│       └── processor_history_screen.dart # Sales history
│
├── models/
│   ├── user_model.dart               # User data
│   ├── waste_model.dart              # Waste post
│   ├── fertilizer_model.dart         # Fertilizer listing
│   └── order_model.dart              # Transaction
│
├── services/
│   ├── auth_service.dart             # Firebase Auth
│   ├── firestore_service.dart        # Database operations
│   └── chatbot_service.dart          # AI integration
│
└── delivery/
    └── delivery_service.dart         # Distance calculation
```

---

## 📦 Installation

### Prerequisites
- Flutter SDK (3.0+)
- Android Studio / VS Code
- Firebase account
- Git

### Setup Steps

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/agri-waste-app.git
cd agri-waste-app
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**
   - Create a Firebase project
   - Download `google-services.json`
   - Place in `android/app/`
   - Enable Authentication and Firestore

4. **Add API Keys**
   - Update `chatbot_service.dart` with OpenAI API key
   - Add Google Maps API key in `AndroidManifest.xml`

5. **Run the app**
```bash
flutter run
```

---

## 🔑 Configuration

### Firebase Setup

1. **Authentication**
   - Enable Email/Password authentication
   - (Optional) Enable Google Sign-In

2. **Firestore Database**
   - Create collections:
     - `users`
     - `waste_posts`
     - `fertilizers`
     - `orders`

3. **Storage**
   - Setup for image uploads

### Environment Variables

Create `.env` file:
```env
OPENAI_API_KEY=your_openai_key
GOOGLE_MAPS_API_KEY=your_maps_key
```

---

## 🎨 Design System

### Colors
- **Primary Green**: `#4CAF50` - Agriculture theme
- **Dark Green**: `#388E3C` - Headers
- **Accent Orange**: `#FF9800` - CTAs
- **Background**: `#F5F5F5` - Clean look

### Typography
- **Font**: Google Fonts - Poppins
- **Headings**: Bold, 24-32px
- **Body**: Regular, 14-16px

---

## 🧪 Testing

Run tests:
```bash
flutter test
```

Build APK:
```bash
flutter build apk --release
```

---

## 📱 Screenshots

*(Add screenshots of your app here)*

1. Language Selection
2. Login Screen
3. Farmer Dashboard
4. Upload Waste
5. Fertilizer Marketplace
6. AI Chatbot

---

## 🚀 Deployment

### Generate Release APK
```bash
flutter build apk --release
```

### App Signing
1. Create keystore
2. Configure `key.properties`
3. Build signed APK

### Play Store
1. Create developer account
2. Upload APK
3. Complete store listing
4. Submit for review

---

## 🎯 Future Enhancements

- [ ] Push notifications
- [ ] Payment gateway integration
- [ ] Real-time chat between users
- [ ] Advanced analytics dashboard
- [ ] iOS version
- [ ] Multi-language expansion
- [ ] Blockchain for transaction transparency

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

---

## 📄 License

This project is licensed under the MIT License.

---

## 👥 Team

- **Developer**: Your Name
- **Project Type**: Final Year Project / Startup MVP
- **Institution**: Your College/University

---

## 📞 Contact

- **Email**: your.email@example.com
- **LinkedIn**: linkedin.com/in/yourprofile
- **GitHub**: github.com/yourusername

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- OpenAI for AI capabilities
- All contributors and testers

---

**Made with ❤️ for sustainable agriculture**
