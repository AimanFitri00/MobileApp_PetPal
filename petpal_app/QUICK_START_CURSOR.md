# 🚀 Quick Start Guide - Running PetPal in Cursor

## Step-by-Step: Run App on Android Emulator

### 1️⃣ **Start Android Emulator First**

**Option A: Using Android Studio**
1. Open Android Studio
2. Click **Device Manager** (phone icon in toolbar)
3. Click **▶ Play** button next to an emulator
4. Wait for emulator to fully boot (home screen appears)

**Option B: Using Command Line**
```bash
# List available emulators
emulator -list-avds

# Start an emulator (replace with your emulator name)
emulator -avd Pixel_5_API_33
```

### 2️⃣ **Verify Emulator is Detected**

Open terminal in Cursor (`Ctrl + ~` or `View → Terminal`) and run:
```bash
cd PetPal_Project
flutter devices
```

You should see something like:
```
sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64  • Android 13 (API 33)
```

### 3️⃣ **Run the App in Cursor**

**Method 1: Using Run Button (Easiest)**
1. Open `lib/main.dart` in Cursor
2. Click the **▶ Run** button in the top-right corner
3. Select **"Flutter: Run Flutter"** or **"Dart & Flutter"**
4. Select your emulator from the device list

**Method 2: Using Command Palette**
1. Press `Ctrl + Shift + P` (Windows) or `Cmd + Shift + P` (Mac)
2. Type: `Flutter: Run Flutter`
3. Press Enter
4. Select your emulator

**Method 3: Using Terminal**
```bash
cd PetPal_Project
flutter run
```

### 4️⃣ **First Time Setup (If Not Done)**

If you haven't set up the project yet:

```bash
# Navigate to project
cd PetPal_Project

# Install dependencies
flutter pub get

# Check for issues
flutter doctor

# Configure Firebase (if not done)
flutterfire configure
```

---

## 🔧 Common Issues & Quick Fixes

### ❌ "No devices found"
**Fix:**
1. Make sure emulator is fully booted (not just starting)
2. Run: `adb devices` - should show your emulator
3. If not, restart ADB:
   ```bash
   adb kill-server
   adb start-server
   ```

### ❌ "Gradle build failed"
**Fix:**
```bash
cd PetPal_Project
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
flutter run
```

### ❌ "Package name mismatch"
**Fix:** Already fixed! But if you see this error:
- Check that `MainActivity.kt` is in: `android/app/src/main/kotlin/com/scrumshank/petpal/`

### ❌ "Firebase not initialized"
**Fix:**
1. Check `android/app/google-services.json` exists
2. Run: `flutterfire configure`
3. Verify Firebase services are enabled in Firebase Console

---

## 📱 Hot Reload & Debugging

While app is running:
- **Hot Reload**: Press `r` in terminal (preserves state)
- **Hot Restart**: Press `R` in terminal (restarts app)
- **Quit**: Press `q` in terminal

**In Cursor:**
- Set breakpoints by clicking left of line numbers
- Use Debug Console to inspect variables
- Check terminal for `print()` output

---

## ✅ Pre-Flight Checklist

Before running, make sure:
- [ ] Android Emulator is running and fully booted
- [ ] `flutter devices` shows your emulator
- [ ] `flutter pub get` completed successfully
- [ ] Firebase is configured (`google-services.json` exists)
- [ ] Internet connection is active (for Firebase)

---

## 🎯 What to Do After App Starts

1. **Register a new account** (choose role: owner)
2. **Add a pet** to test the app
3. **Explore features**: Vets, Sitters, Bookings, Reports

---

## 💡 Pro Tips

- **Keep emulator running** - Don't close it between runs
- **Use Hot Reload** - Much faster than full restart
- **Check terminal output** - Errors and logs appear there
- **Use Flutter DevTools** - For advanced debugging:
  ```bash
  flutter pub global activate devtools
  flutter pub global run devtools
  ```

---

**Need more help?** Check `SETUP_GUIDE.md` for detailed instructions.

