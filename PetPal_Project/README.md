# PetPal – Smart Pet Care Companion

Flutter + Firebase application that connects pet owners, veterinarians, and pet sitters in one ecosystem. The project follows clean architecture with a dedicated repository layer, Firebase service wrappers, and BLoC-based presentation logic.

## Tech Stack

- Flutter 3.x (Material 3, responsive layouts)
- Firebase Authentication, Firestore, Storage, Cloud Messaging, Cloud Functions
- flutter_bloc + equatable for state management
- Firebase Cloud Functions (Node 18 + TypeScript)
- PDF/Printing, Share Plus, Table Calendar, etc.

## Project Structure

```
lib/
 ├── blocs/                 # Feature-specific BLoCs (auth, pets, bookings, reports…)
 ├── models/                # Data models for users, pets, bookings, activities
 ├── repositories/          # Domain repositories talking to services
 ├── services/              # FirebaseAuth/Firestore/Storage wrappers, notifications, PDF
 ├── screens/               # UI modules (auth, profile, pets, vets, sitters, reports)
 ├── utils/                 # Constants, validators, dialogs
 ├── widgets/               # Reusable UI components
 └── main.dart              # App bootstrap, Firebase init, MultiBlocProvider routing
```

The Firebase Cloud Functions live under `functions/` with TypeScript sources.

## Firebase Setup

1. Install the FlutterFire CLI and run `flutterfire configure` to generate `lib/firebase_options.dart`. Replace the placeholder values currently in that file.
2. Enable Authentication (Email/Password), Firestore, Storage, Cloud Messaging, and Cloud Functions in the Firebase console.
3. (Optional) Add App Check & Crashlytics if you plan to use those services.
4. Deploy Cloud Functions:
   ```bash
   cd functions
   npm install
   npm run build
   firebase deploy --only functions
   ```

## Key Modules

- **Authentication**: Login, register (role selection), forgot password with Firebase Auth + password history enforcement via callable function.
- **Profile Management**: View/edit profile, upload profile photo to Storage.
- **Pet CRUD**: Add/edit/delete pets, detail page with share/export options and activity logging.
- **Vet & Sitter Booking**: Browsing, detail pages, booking forms, booking summary/history, Cloud Function powered push notifications for status changes.
- **Activity Logs & Reports**: Track daily activities, generate pet health/appointment reports, export as PDF/share.
- **Notifications**: Firebase Messaging + local notifications wrapper for reminders and server-triggered updates.

## Running the App

```bash
flutter pub get
flutter run
```

Ensure Developer Mode is enabled on Windows for plugin symlinks.

## Testing

- Widget and bloc tests can be added under `test/`; `bloc_test` and `mocktail` are included.
- Use `flutter test` to execute the suite.

## Next Steps

- Add actual user/device FCM token registration to enable push notifications fully.
- Connect booking forms to real pet/provider selections (currently placeholders for IDs).
- Hook password reset flow to callable function before updating credentials.
