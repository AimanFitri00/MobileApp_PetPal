# PetPal - Smart Pet Care Companion

A cross-platform Flutter mobile application connecting pet owners, veterinarians, and pet sitters in one ecosystem.

## Features

- **Multi-role Support**: Pet Owners, Veterinarians, and Pet Sitters
- **Authentication**: Secure email/password authentication with Firebase Auth
- **Pet Management**: CRUD operations for pets with photo uploads
- **Booking System**: Book appointments with vets and sitters
- **Real-time Chat**: Chat between owners, vets, and sitters
- **Push Notifications**: FCM notifications for bookings and messages
- **Profile Management**: Edit profile with image upload
- **Clean Architecture**: BLoC pattern with repository layer

## Tech Stack

- **Flutter** 3.24.0 (null-safe)
- **Firebase**: Auth, Firestore, Storage, Cloud Functions, Cloud Messaging
- **State Management**: flutter_bloc
- **Architecture**: Clean Architecture with Repository pattern

## Project Structure

```
lib/
├── blocs/          # BLoC state management
├── models/         # Data models
├── repositories/   # Data layer
├── services/       # Firebase service wrappers
├── ui/             # UI screens and widgets
├── utils/          # Utilities and validators
└── config/         # Configuration
```

## Getting Started

### Prerequisites

- Flutter SDK (3.24.0 or higher)
- Dart SDK (3.9.2 or higher)
- Firebase account
- Android Studio / Xcode (for mobile development)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd petpal_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Authentication (Email/Password)
   - Enable Firestore Database
   - Enable Cloud Storage
   - Enable Cloud Messaging
   - Run `flutterfire configure` or manually update `lib/firebase_options.dart`

4. **Deploy Firestore Rules**
   ```bash
   firebase deploy --only firestore:rules
   ```

5. **Deploy Cloud Functions** (optional)
   ```bash
   cd functions
   npm install
   npm run build
   firebase deploy --only functions
   ```

6. **Run the app**
   ```bash
   flutter run
   ```

## Testing

Run tests:
```bash
flutter test
```

Run with coverage:
```bash
flutter test --coverage
```

## CI/CD

GitHub Actions automatically runs:
- `flutter analyze` on push/PR
- `flutter test` on push/PR

## Firestore Security Rules

Security rules are located in `firestore.rules` and implement role-based access control (RBAC).

## Cloud Functions

Cloud Functions are located in `functions/` directory:
- `onUserCreate`: Creates user document on signup
- `sendBookingNotifications`: Sends FCM notifications for bookings
- `onMessageWrite`: Updates chat metadata
- `scheduledReminders`: Sends daily booking reminders

## Contributing

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Make your changes
3. Run tests: `flutter test`
4. Commit: `git commit -m "Add your feature"`
5. Push: `git push origin feature/your-feature`
6. Create a Pull Request

## License

This project is private and proprietary.
