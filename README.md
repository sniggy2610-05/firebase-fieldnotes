# Firebase Fieldnotes

A Flutter product management application integrated with **Firebase Cloud Firestore**, developed for In-Class 12: Introduction to Firebase in Mobile App Development.

## Overview

Firebase Fieldnotes is a product catalogue application that allows users to manage product information using a cloud-hosted Firestore database.

The project demonstrates Firebase integration, real-time database updates, CRUD operations, search, price filtering, input validation, and offline caching.

## Features

- **Create:** Add products with a name and price.
- **Read:** Retrieve and display products from Firestore.
- **Update:** Edit existing product information.
- **Delete:** Remove products using their unique document IDs.
- **Real-Time Updates:** Automatically reflect Firestore changes using `StreamBuilder`.
- **Search:** Search products by name using case-insensitive substring matching.
- **Price Filtering:** Filter products using minimum and maximum prices.
- **Combined Filtering:** Apply name searches and price filters together.
- **Reset Filters:** Clear active search and price filters.
- **Input Validation:** Validate product names, prices, and price ranges.
- **Offline Support:** Display cached product data when offline and synchronize when connectivity returns.
- **UI States:** Handle loading, empty, error, and no-results states.

## Technologies Used

- Flutter
- Dart
- Firebase Core
- Cloud Firestore
- FlutterFire CLI
- Android Studio
- Git and GitHub

## Firestore Database Structure

**Database:** `(default)`

**Collection:** `products`

Each product is stored as an individual document with a unique Firestore-generated document ID.

| Field | Type | Description |
|---|---|---|
| name | String | Product name |
| price | Number | Product price |

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or another Flutter-compatible IDE
- A Firebase project with Cloud Firestore enabled

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/sniggy2610-05/firebase-fieldnotes.git
   ```

2. Navigate to the project:

   ```bash
   cd firebase-fieldnotes
   ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Configure Firebase if necessary:

   ```bash
   flutterfire configure
   ```

5. Run the application:

   ```bash
   flutter run
   ```

## Testing

The application was tested using the assignment's T1–T8 test cases:

| Test | Description |
|---|---|
| T1 | Create and read products |
| T2 | Real-time Firestore updates |
| T3 | Edit and delete products |
| T4 | Case-insensitive product search |
| T5 | Minimum, maximum, and combined price filters |
| T6 | Input validation |
| T7 | Offline caching and synchronization |
| T8 | Firestore Security Rules Playground simulations |

## AI Usage

AI assistance was used during development to support Firebase configuration, implementation troubleshooting, and organization of testing and screenshot evidence.

Further details about AI usage are documented in [AI_FEATURE.md](AI_FEATURE.md).

## Project Structure

```text
firebase-fieldnotes/
│
├── lib/
│   ├── main.dart
│   └── firebase_options.dart
│
├── android/
├── test/
├── pubspec.yaml
├── pubspec.lock
├── README.md
└── AI_FEATURE.md
```

## Author

**Snigdha Addagarla**

GitHub: [@sniggy2610-05](https://github.com/sniggy2610-05)

## Repository

[https://github.com/sniggy2610-05/firebase-fieldnotes](https://github.com/sniggy2610-05/firebase-fieldnotes)