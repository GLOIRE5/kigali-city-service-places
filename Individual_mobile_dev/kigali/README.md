# Kigali City Services & Places Directory

A Flutter mobile application that helps Kigali residents locate and navigate to essential public services and leisure locations such as hospitals, police stations, libraries, restaurants, cafés, parks, and tourist attractions.

# Features

# Authentication

- Email & password sign-up and sign-in via **Firebase Authentication**
- **Email verification** required before accessing the app
- User profiles stored in **Cloud Firestore** linked by UID
- Password reset via email

# Location Listings (CRUD)

- Create new service/place listings with name, category, address, contact, description, and GPS coordinates
- Read all listings in a shared real-time directory
- Update listings you created
-  Delete listings you created
- All changes reflect immediately via Firestore real-time listeners

# Directory Search & Filtering

- Search listings by name or address
- Filter by category (Hospital, Police Station, Library, Restaurant, Café, Park, Tourist Attraction)
- Results update dynamically as Firestore data changes

# Detail Page & Map Integration

- Detailed view of each listing with all information
- **Embedded Google Map** with a marker showing the location
- **"Get Directions"** button launches Google Maps for turn-by-turn navigation
- Tap-to-call contact numbers

# Map View

- Full-screen Google Map displaying all listings as markers
- Color-coded markers by category
- Category filter chips to show/hide specific types
- Satellite/street view toggle

# Settings

- Displays authenticated user's profile information
- Toggle for enabling/disabling location-based notifications
- Sign out with confirmation

# Architecture

lib/
├── main.dart                          
├── firebase_options.dart              
├── models/
│   └── listing.dart                   
├── services/
│   ├── auth_service.dart             
│   └── firestore_service.dart         
├── providers/
│   ├── auth_provider.dart             
│   ├── listings_provider.dart         
│   └── settings_provider.dart         
├── screens/
│   ├── sign_in_screen.dart            
│   ├── register_screen.dart           
│   ├── email_verification_screen.dart 
│   ├── home_shell.dart                
│   ├── directory_screen.dart         
│   ├── my_listings_screen.dart        
│   ├── map_screen.dart                
│   ├── settings_screen.dart           
│   ├── listing_detail_screen.dart    
│   └── listing_form_screen.dart       
└── widgets/
    └── listing_card.dart              


# State Management

Uses Provider with `ChangeNotifier` pattern:

- AuthProvider manages Firebase Auth state, sign-in/sign-up, email verification
- ListingsProvider real-time Firestore listener, CRUD operations, search & category filtering
- SettingsProvider notification preference toggle via SharedPreferences

All Firestore interactions go through a dedicated service layer (`AuthService`, `FirestoreService`). No direct database queries in UI widgets.

# Tech Stack

 Technology           Purpose                                                    
 Flutter             Cross-platform UI framework                               
 Firebase Auth       User authentication                                       
 Cloud Firestore      Real-time database                                        
 Google Maps Flutter  Map display & markers                                     Provider             State management                                          
Geolocator          Device location                                           
URL Launcher         External navigation (Google Maps directions, phone calls) 
SharedPreferences    Local settings persistence                                
 HTTP                 Geocoding via Nominatim API                               

# Navigation

BottomNavigationBar with 4 tabs:

1. Directory — Browse and search all listings
2. My Listings — Manage your own listings (create, edit, delete)
3. Map — View all listings on Google Map
4. Settings— Profile info, notification toggle, sign out

# Setup

# Prerequisites

- Flutter SDK ^3.10.4
- A Firebase project with Authentication and Firestore enabled
- Google Maps API key

# Firebase Configuration

1. Enable Email/Password sign-in in Firebase Console → Authentication → Sign-in method
2. Create a Firestore Database in Firebase Console
3. The `firebase_options.dart` file is already configured for this project

# Google Maps API Key

The API key is configured in:

- Android: `android/local.properties` → `MAPS_API_KEY=YOUR_KEY`
- iOS: `ios/Flutter/Secrets.xcconfig` → `MAPS_API_KEY=YOUR_KEY`
Web: `web/index.html` → Google Maps JS script tag

# Run the App
bash

flutter pub get
flutter run

# Firestore Data Structure

# users collection

users/{uid}
├── displayName: string
├── email: string
├── createdAt: timestamp
└── notificationsEnabled: boolean


# listings collection


listings/{docId}
├── name: string
├── category: string
├── address: string
├── contactNumber: string
├── description: string
├── latitude: number
├── longitude: number
├── createdBy: string (user UID)
├── timestamp: timestamp
└── imageUrl: string (optional)


## Categories

- Hospital
- Police Station
- Library
- Restaurant
- Café
- Park
- Tourist Attraction
