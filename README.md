# Ingsight 🍎 Know Before You Consume

![Swift](https://img.shields.io/badge/Swift-6-orange?style=flat&logo=swift)
![Platform](https://img.shields.io/badge/Platform-iOS%2026.2+-lightgrey?style=flat&logo=apple)
![License](https://img.shields.io/badge/License-MIT-blue?style=flat)
![Architecture](https://img.shields.io/badge/Architecture-MVVM-green?style=flat)

> **Scan ingredients. Detect risks. Stay healthy.** > *An offline-first iOS health assistant powered by on-device OCR.*

## 🌟 Overview

**Ingsight** is a modern iOS application designed to help users identify harmful ingredients and allergens in food products instantly. Unlike traditional apps, **Ingsight does not rely on barcode databases.** Instead, it uses the device's camera and Apple's **Vision Framework** to read the ingredients list directly, making it capable of analyzing *any* product, anywhere, without an internet connection.

## ✨ Key Features

* **📷 Live OCR Scanning:** Uses Apple's `Vision Framework` to detect text in real-time.
* **🛡️ Offline First:** No API calls, no cloud dependency. All analysis happens on-device for maximum privacy and speed.
* **🧠 Intelligent Analysis:** Instantly matches scanned text against a local database of harmful substances (e.g., MSG, Palm Oil, HFCS).
* **💾 Smart History:** Saves scan results using **SwiftData** to provide long-term health insights.
* **⚡️ High Performance:** Built with **SwiftUI** for a smooth, modern user experience.

## 🏗️ Tech Stack

| Component | Technology | Description |
| :--- | :--- | :--- |
| **Language** | Swift 6 | Modern, safe, and fast. |
| **UI Framework** | SwiftUI | Declarative user interface. |
| **Architecture** | MVVM | Clean separation of concerns. |
| **Database** | SwiftData | Modern persistence framework for user history. |
| **AI / ML** | Vision Framework | On-device Optical Character Recognition (OCR). |
| **Logic** | Fuzzy Matching | Custom algorithm to detect ingredients despite OCR errors.|

## 📂 Project Structure

```text
Ingsight
├── 📱 App
│   ├── IngsightApp.swift       # Entry point
│   └── ContentView.swift       # Main wrapper
├── 🧠 Models
│   ├── Ingredient.swift        # Data model for toxins
│   └── ScanResult.swift        # SwiftData model for history
├── ⚙️ ViewModels
│   ├── ScannerViewModel.swift  # Manages Vision & Camera logic
│   └── HistoryViewModel.swift  # Manages SwiftData queries
├── 🔧 Services
│   ├── IngredientService.swift # JSON loader & Analysis engine
│   └── OCRManager.swift        # Vision request handler
└── 📦 Resources
    └── toxic_ingredients.json  # Static database of harmful substances
