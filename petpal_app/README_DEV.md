# PetPal Development Setup Guide

## Prerequisites

1. **Install Flutter**
   - Download from [flutter.dev](https://flutter.dev/docs/get-started/install)
   - Verify installation: `flutter doctor`

2. **Install Firebase CLI**
   ```bash
   npm install -g firebase-tools
   firebase login
   ```

3. **Install FlutterFire CLI**
   ```bash
   dart pub global activate flutterfire_cli
   ```

## Initial Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd petpal_app
   ```

2. **Get dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   ```bash
   flutterfire configure
   ```
   This will:
   - Connect to your Firebase project
   - Generate `lib/firebase_options.dart`
   - Configure Android and iOS apps

4. **Set up Firestore**
   - Go to Firebase Console → Firestore Database
   - Create database (start in test mode)
   - Deploy security rules:
     ```bash
     firebase deploy --only firestore:rules
     ```

5. **Set up Cloud Storage**
   - Go to Firebase Console → Storage
   - Enable Storage
   - Set up storage rules (see Firebase Console)

6. **Set up Cloud Functions** (optional)
   ```bash
   cd functions
   npm install
   npm run build
   firebase deploy --only functions
   ```

## Running the App

### Android
```bash
flutter run -d android
```

### iOS
```bash
flutter run -d ios
```

### Web
```bash
flutter run -d chrome
```

## Development Workflow

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature
   ```

2. **Make changes and test**
   ```bash
   flutter analyze
   flutter test
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## Environment Variables

Create a `.env` file (do NOT commit):
```
FIREBASE_API_KEY=your_key
FIREBASE_PROJECT_ID=your_project_id
```

## Firebase Emulators (Optional)

Run Firebase emulators locally:
```bash
firebase emulators:start
```

Update `lib/firebase_options.dart` to point to emulators in development.

## Testing

- **Unit Tests**: `flutter test`
- **Widget Tests**: `flutter test test/widget_test.dart`
- **Integration Tests**: `flutter test integration_test/`

## Code Generation

If using code generation (e.g., for mocks):
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Troubleshooting

### Firebase not initialized
- Ensure `firebase_options.dart` is properly configured
- Check Firebase project settings

### Build errors
- Run `flutter clean`
- Run `flutter pub get`
- Delete `build/` folder

### iOS build issues
- Run `cd ios && pod install`
- Check Xcode project settings

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [BLoC Pattern](https://bloclibrary.dev/)

