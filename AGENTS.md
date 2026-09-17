# 🍳 Cooksy - AI Agent Context & Knowledge Base (`AGENTS.md`)

This document provides complete, persistent context for AI agents working on the **Cooksy** project. Read this file first to instantly understand the architecture, patterns, key conventions, and past decisions.

---

## 📌 Project Overview
- **App Name**: Cooksy (Gourmet Smart Recipe & AI Cooking Assistant)
- **Primary Codebase**: `cooksy_flutter/` (Flutter / Dart)
- **Web Prototype**: `site/public/` (Static HTML/JS prototype)
- **GitHub Repository**: `https://github.com/DeniDeveloper/Cooksy.git` (Account: `DeniDeveloper`)
- **SDK Path**: `C:\Users\Lenovo\flutter\bin\flutter.bat`

---

## 🏗️ Architecture & Folder Structure

```
cooksy_flutter/
├── android/                        # Android Native Configuration
│   ├── app/build.gradle.kts        # Kotlin DSL: Java 17, minSdk 21+, compileSdk 34+
│   ├── build.gradle.kts            # Root Gradle configuration
│   └── app/src/main/AndroidManifest.xml # Permissions: INTERNET, ACCESS_NETWORK_STATE
├── lib/
│   ├── main.dart                   # Entry point: MultiProvider, Dark Theme (Plus Jakarta Sans/Inter)
│   ├── models/
│   │   ├── recipe.dart             # Domain model: Recipe, Ingredient, InstructionStep, Nutrition
│   │   └── grocery_item.dart       # Grocery checklist item & automatic aisle categorization
│   ├── providers/
│   │   └── app_state.dart          # Central State: Saved recipes, active recipe, grocery items, servings
│   ├── screens/
│   │   ├── home_screen.dart        # Catalog browsing, search filter, category selector
│   │   ├── generate_screen.dart    # Ingredient tags input, style picker, AI generation trigger
│   │   ├── recipe_screen.dart      # Recipe details, dynamic servings scaler, remix options, cost breakdown
│   │   ├── saved_screen.dart       # Cookbook library, custom family recipe creator, stat cards
│   │   └── navigation_shell.dart   # Bottom navigation bar with indexed stack
│   ├── services/
│   │   ├── generator_service.dart  # Gemini 2.5 Flash API client & offline rule-based chef synthesis
│   │   ├── recipe_database.dart    # Built-in offline curated recipes (including Halal Filipino dishes)
│   │   └── storage_service.dart    # SharedPreferences local storage persistence
│   └── widgets/
│       ├── add_recipe_modal.dart   # Modal sheet for authoring custom family recipes
│       ├── api_key_dialog.dart     # Modal for securely saving user's Gemini API key to local storage
│       ├── cook_mode_dialog.dart   # Fullscreen step-by-step cooking overlay with interactive timers
│       └── grocery_list_modal.dart # Smart categorized grocery checklist with aisle grouping
├── test/
│   └── widget_test.dart            # MultiProvider & mock SharedPreferences widget smoke test
└── pubspec.yaml                    # Dependencies: provider, shared_preferences, http, google_fonts, intl
```

---

## 🧠 Core Systems & Implementation Details

### 1. Gemini AI Integration (`generator_service.dart`)
- **Endpoint**: `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent`
- **Security Rule**: API keys are **NEVER hardcoded** in source files.
- **Key Flow**: Reads key from `StorageService.getApiKey()` (configured via `ApiKeyDialog`). If no key is set or device is offline, falls back seamlessly to offline synthesis.
- **Strict JSON Parsing**: Uses `generationConfig: { responseMimeType: 'application/json' }` and parses into `Recipe` model.

### 2. Built-in Recipe Catalog (`recipe_database.dart`)
Includes regional and Halal Filipino recipes:
- *Maranao Piaparan a Manok* (Halal coconut-turmeric chicken with palapa)
- *Bacolod Chicken Inasal* (Halal-friendly calamansi-annatto grilled chicken)
- *Tausug Beef Kulma* (Halal curry-spiced beef braised in coconut milk)
- *Chicken Tinola with Moringa* (Ginger-papaya broth)
- *Sweet & Sour Fish Escabeche* (Crispy fish with bell peppers)
- Plus international classics (Creamy Tuscan Garlic Chicken, Garlic Fried Rice, etc.)

### 3. Servings Scaler (`models/recipe.dart`)
- Fraction formatter converts decimals (0.25 -> ¼, 0.33 -> ⅓, 0.5 -> ½, 0.75 -> ¾).
- Scales ingredients dynamically from 1 to 16 servings.

### 4. Smart Grocery List (`models/grocery_item.dart` & `grocery_list_modal.dart`)
- Automatically sorts ingredients into supermarket aisles: `Produce`, `Meat & Seafood`, `Dairy & Eggs`, `Grains & Bakery`, `Pantry & Spices`.

---

## 🛠️ Build & Verification Commands

```powershell
# Always execute in c:\Users\Lenovo\Downloads\SmartApp\cooksy_flutter

# 1. Dependency sync
C:\Users\Lenovo\flutter\bin\flutter.bat pub get

# 2. Run tests (must pass with 0 errors)
C:\Users\Lenovo\flutter\bin\flutter.bat test

# 3. Static analysis (must report 0 issues)
C:\Users\Lenovo\flutter\bin\flutter.bat analyze

# 4. Build Android Release APK
C:\Users\Lenovo\flutter\bin\flutter.bat build apk --release

# 5. Output location
# build\app\outputs\flutter-apk\app-release.apk
```

---

## 🔒 Security Best Practices
- **Never commit API keys or private tokens** to version control.
- Any new features requiring external APIs must store secrets in `StorageService` (`SharedPreferences`) via UI dialogs.
