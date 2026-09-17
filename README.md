# 🍳 Cooksy - Gourmet Smart Recipe & AI Cooking Assistant

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Gemini AI](https://img.shields.io/badge/Gemini_AI-2.5_Flash-8E75B2?style=for-the-badge&logo=googlegemini&logoColor=white)](https://ai.google.dev)
[![Android](https://img.shields.io/badge/Android-APK_Ready-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://developer.android.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

**Cooksy** is a modern, responsive mobile culinary companion built with Flutter and powered by Google Gemini AI. Cooksy empowers home cooks and food enthusiasts to transform whatever ingredients they have in their fridge into gourmet recipes with precise portion scaling, step-by-step cooking timers, categorized grocery planning, and offline support.

---

## ✨ Key Features

- 🧠 **Google Gemini AI Neural Recipe Generation**: Enter your available ingredients, target cooking time, and cuisine style to generate unique culinary recipes with structured JSON formatting.
- ⚡ **Offline Smart Synthesis Fallback**: No internet? No problem. Cooksy comes equipped with an offline culinary engine that synthesizes recipes without network connectivity.
- 🇵🇭 **Heritage & Halal Filipino Recipes**: Dedicated support for regional and Halal Filipino classics including *Piaparan a Manok*, *Bacolod Chicken Inasal*, *Tausug Beef Kulma*, *Tinola*, and *Escabeche*.
- ⚖️ **Dynamic Servings Scaler**: Real-time ingredient amount recalculation from 1 to 16 servings with intelligent fraction formatting.
- ⏱️ **Interactive Cook Mode & Multi-Timers**: Step-by-step cooking interface with built-in visual countdown timers for every recipe step.
- 🛒 **Smart Categorized Grocery List**: One-tap ingredient export organized by supermarket aisles (Produce, Meat & Seafood, Dairy & Eggs, Grains & Bakery, Pantry & Spices).
- 📖 **Personal Cookbook & Custom Recipe Creator**: Save your favorite generated dishes and author your own secret family recipes with offline local persistence.
- 🔄 **One-Tap Recipe Remixing**: Instantly adapt any recipe for *Air Fryer*, *Kid-Friendly*, *Dairy-Free*, *Keto / Low-Carb*, or *15-Min Express*.
- 🎨 **Sleek Gourmet Dark Mode UI**: Designed with Plus Jakarta Sans and Inter typography, tailored glassmorphism accents, and accessible contrast.

---

## 🏗️ Architecture & Tech Stack

```
cooksy_flutter/
├── android/               # Android native configuration & Gradle scripts
├── lib/
│   ├── main.dart          # App entry point & Theme configuration
│   ├── models/            # Immutable domain models (Recipe, GroceryItem, etc.)
│   ├── providers/         # State management with Provider (AppState)
│   ├── screens/           # Core view pages
│   │   ├── home_screen.dart        # Catalog, Search & Recommendations
│   │   ├── generate_screen.dart    # AI Ingredient Input & Recipe Generator
│   │   ├── recipe_screen.dart      # Recipe Details, Servings & Remixing
│   │   ├── saved_screen.dart       # Cookbook & Custom Recipe Library
│   │   └── navigation_shell.dart   # Bottom navigation bar container
│   ├── services/          # Data layer & API clients
│   │   ├── generator_service.dart  # Gemini AI & Offline Synthesis
│   │   ├── recipe_database.dart    # Curated offline recipe catalog
│   │   └── storage_service.dart    # SharedPreferences local persistence
│   └── widgets/           # Reusable UI components & modals
│       ├── add_recipe_modal.dart   # Custom family recipe modal
│       ├── api_key_dialog.dart     # Secure Gemini API Key settings dialog
│       ├── cook_mode_dialog.dart   # Step-by-step cooking timer overlay
│       └── grocery_list_modal.dart # Categorized shopping checklist
├── test/                  # Unit and widget test suite
└── pubspec.yaml           # Flutter dependencies & metadata
```

- **Framework**: Flutter 3.0+ (Dart 3.0+)
- **State Management**: `provider`
- **Storage**: `shared_preferences`
- **Typography & Icons**: `google_fonts`, Material Symbols
- **Networking**: `http`

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.0.0 or higher)
- [Android Studio](https://developer.android.com/studio) with Android SDK (API Level 21+)
- Git

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/DeniDeveloper/Cooksy.git
   cd Cooksy
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the application**:
   ```bash
   # Run on connected Android device or emulator
   flutter run
   ```

---

## 🔑 Setting Up the Gemini API Key (Securely)

To keep your credentials secure, **API keys are never stored in source code**.

1. Launch Cooksy on your device or emulator.
2. On the **Home** or **AI Chef** screen, tap the **Settings / Sparkle (✨)** icon.
3. Paste your [Google Gemini API Key](https://aistudio.google.com/app/apikey).
4. Tap **Save Settings**. Your key will be securely saved only to your device's local storage via `SharedPreferences`.

*(If no API key is set, Cooksy will seamlessly use its built-in offline recipe synthesis engine!)*

---

## 📦 Building Android APK / App Bundle

### Release APK
```bash
flutter build apk --release
```
The output APK file will be located at:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Google Play App Bundle (AAB)
```bash
flutter build appbundle --release
```
The output bundle will be located at:
```
build/app/outputs/bundle/release/app-release.aab
```

---

## 🧪 Testing & Code Quality

Run tests and static analysis:

```bash
# Run unit & widget tests
flutter test

# Run static analysis
flutter analyze
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
