# PetPal Mobile App - Complete Setup & Run Guide

## 📋 Prerequisites

Before running the app, ensure you have the following installed:

### 1. **Flutter SDK** (3.9.2 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Add Flutter to your PATH
   - Verify installation: `flutter doctor`

### 2. **Android Studio** (for Android development)
   - Download from: https://developer.android.com/studio
   - Install Android SDK (API 33+ recommended)
   - Install Android SDK Command-line Tools
   - Install Android Emulator

### 3. **Java Development Kit (JDK) 11 or higher**
   - Download from: https://adoptium.net/
   - Set JAVA_HOME environment variable

### 4. **Firebase CLI** (for Cloud Functions)
   ```bash
   npm install -g firebase-tools
   ```

### 5. **Git** (if not already installed)

---

## 🔧 Initial Setup

### Step 1: Clone/Open the Project
```bash
cd PetPal_Project
```

### Step 2: Install Flutter Dependencies
```bash
flutter pub get
```

### Step 3: Verify Flutter Setup
```bash
flutter doctor
```
Fix any issues reported by `flutter doctor` before proceeding.

### Step 4: Configure Firebase

1. **Install FlutterFire CLI** (if not already installed):
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. **Configure Firebase for your project**:
   ```bash
   flutterfire configure
   ```
   - Select your Firebase project (or create a new one)
   - Select platforms: Android, iOS (if on Mac), Web
   - This will update `lib/firebase_options.dart` and platform-specific config files

3. **Enable Firebase Services** in Firebase Console:
   - Go to https://console.firebase.google.com
   - Select your project
   - Enable the following services:
     - ✅ Authentication (Email/Password)
     - ✅ Cloud Firestore
     - ✅ Cloud Storage
     - ✅ Cloud Messaging (FCM)
     - ✅ Cloud Functions

4. **Set up Firestore Database**:
   - In Firebase Console → Firestore Database
   - Create database in **test mode** (for development)
   - Choose a location closest to you
   - The app will create collections automatically when you use it

### Step 5: Configure Android

1. **Update `android/local.properties`** (if needed):
   ```properties
   sdk.dir=C:\\Users\\YourUsername\\AppData\\Local\\Android\\Sdk
   flutter.sdk=C:\\flutter
   ```
   Update paths according to your system.

2. **Verify `google-services.json`**:
   - Should be at: `android/app/google-services.json`
   - If missing, download from Firebase Console → Project Settings → Your Android App

---

## 📱 Running the App on Android Emulator

### Method 1: Using Cursor/VS Code

1. **Start Android Emulator**:
   - Open Android Studio
   - Go to **Tools → Device Manager**
   - Click **▶ Play** button next to an emulator (or create one if none exist)
   - Wait for emulator to fully boot

2. **Verify Emulator is Running**:
   ```bash
   flutter devices
   ```
   You should see your emulator listed (e.g., `sdk gphone64 arm64`)

3. **Run the App**:
   - **Option A**: Press `F5` in Cursor/VS Code
   - **Option B**: Use Command Palette (`Ctrl+Shift+P`):
     - Type: `Flutter: Run Flutter`
   - **Option C**: Terminal:
     ```bash
     flutter run
     ```

4. **Select Device** (if multiple devices):
   - If prompted, select your Android emulator from the list

### Method 2: Using Terminal/Command Line

1. **List available devices**:
   ```bash
   flutter devices
   ```

2. **Run on specific device**:
   ```bash
   flutter run -d <device-id>
   ```
   Example: `flutter run -d emulator-5554`

3. **Run in debug mode** (default):
   ```bash
   flutter run
   ```

4. **Run in release mode**:
   ```bash
   flutter run --release
   ```

### Method 3: Using Flutter Commands

```bash
# Clean build (if having issues)
flutter clean
flutter pub get

# Run the app
flutter run

# Hot reload: Press 'r' in terminal
# Hot restart: Press 'R' in terminal
# Quit: Press 'q' in terminal
```

---

## 🐛 Troubleshooting Common Issues

### Issue 1: "No devices found" or Emulator not detected

**Solutions:**
1. Ensure emulator is fully booted (wait for home screen)
2. Check ADB connection:
   ```bash
   adb devices
   ```
   If device shows as "unauthorized", accept the prompt on emulator
3. Restart ADB:
   ```bash
   adb kill-server
   adb start-server
   ```
4. Restart the emulator

### Issue 2: "Gradle build failed"

**Solutions:**
1. Clean the project:
   ```bash
   cd android
   ./gradlew clean
   cd ..
   flutter clean
   flutter pub get
   ```
2. Check Java version:
   ```bash
   java -version
   ```
   Should be JDK 11 or higher
3. Update Gradle (if needed):
   - Check `android/gradle/wrapper/gradle-wrapper.properties`
   - Ensure compatible Gradle version

### Issue 3: "Package name mismatch" error

**Solution:**
- The package name is already fixed: `com.scrumshank.petpal`
- If you see errors, ensure `MainActivity.kt` is in:
  `android/app/src/main/kotlin/com/scrumshank/petpal/MainActivity.kt`

### Issue 4: "Firebase not initialized" or Firebase errors

**Solutions:**
1. Verify `google-services.json` exists in `android/app/`
2. Check `lib/firebase_options.dart` has correct values
3. Ensure Firebase services are enabled in Firebase Console
4. Run `flutterfire configure` again if needed

### Issue 5: "Permission denied" errors

**Solution:**
- Permissions are already added to `AndroidManifest.xml`
- For Android 13+, notification permission is requested at runtime

### Issue 6: App crashes on startup

**Solutions:**
1. Check logs:
   ```bash
   flutter run --verbose
   ```
2. Check Firebase configuration
3. Ensure internet connection (for Firebase)
4. Verify Firestore rules allow read/write (use test mode for development)

### Issue 7: "SDK location not found"

**Solution:**
- Update `android/local.properties`:
  ```properties
  sdk.dir=C:\\Users\\YourUsername\\AppData\\Local\\Android\\Sdk
  flutter.sdk=C:\\flutter
  ```
  Use your actual paths.

---

## 🔥 Firebase Firestore Setup (Initial Data)

The app creates collections automatically, but you can add sample data:

### Collections Structure:
- `users` - User accounts (created automatically on registration)
- `pets` - Pet information (created via app)
- `vetBookings` - Veterinary appointments
- `sitterBookings` - Pet sitter bookings
- `activityLogs` - Pet activity tracking

### Optional: Add Sample Vet/Sitter Data

To test vet/sitter listings, you can manually add data in Firestore Console:

**Sample Vet User:**
```json
{
  "name": "Dr. Sarah Johnson",
  "email": "sarah@vetclinic.com",
  "role": "vet",
  "address": "123 Main St, City",
  "clinicName": "City Animal Hospital",
  "location": "123 Main St, City",
  "specialization": "Surgery",
  "schedule": ["Monday", "Wednesday", "Friday"],
  "bio": "Experienced veterinarian with 10 years in practice"
}
```

**Sample Sitter User:**
```json
{
  "name": "John Doe",
  "email": "john@sitter.com",
  "role": "sitter",
  "address": "456 Oak Ave, City",
  "location": "456 Oak Ave, City",
  "experience": "5 years",
  "pricing": "$30/day",
  "services": ["Dog Walking", "Pet Sitting", "Overnight Care"]
}
```

---

## 📝 Development Workflow

### Hot Reload & Hot Restart
- **Hot Reload** (`r`): Preserves app state, updates UI quickly
- **Hot Restart** (`R`): Restarts app, loses state
- **Full Restart**: Stop and run again

### Debugging
- Use `print()` statements (visible in terminal)
- Use Flutter DevTools: `flutter pub global activate devtools` then `flutter pub global run devtools`
- Set breakpoints in Cursor/VS Code

### Building APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## ✅ Verification Checklist

Before running, ensure:
- [ ] Flutter SDK installed and in PATH
- [ ] Android Studio installed with Android SDK
- [ ] Android Emulator created and can be started
- [ ] Java JDK 11+ installed
- [ ] `flutter doctor` shows no critical issues
- [ ] `flutter pub get` completed successfully
- [ ] Firebase project created and configured
- [ ] `google-services.json` in `android/app/`
- [ ] `lib/firebase_options.dart` has correct values
- [ ] Firebase services enabled in console
- [ ] Emulator is running and detected by `flutter devices`

---

## 🚀 Quick Start Commands

```bash
# 1. Navigate to project
cd PetPal_Project

# 2. Get dependencies
flutter pub get

# 3. Check setup
flutter doctor

# 4. List devices
flutter devices

# 5. Run app
flutter run
```

---

## 📞 Need Help?

- Check Flutter documentation: https://flutter.dev/docs
- Check Firebase documentation: https://firebase.google.com/docs
- Review error messages carefully - they usually point to the issue
- Check `flutter run --verbose` for detailed logs

---

## 🎯 Next Steps After Running

1. **Register a new account** (role: owner)
2. **Add a pet** to your profile
3. **Register vet/sitter accounts** (or add sample data in Firestore)
4. **Test booking functionality**
5. **Explore other features**: Reports, Activity Logs, etc.

---

**Happy Coding! 🐾**

