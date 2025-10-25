# Motaba3a - Quick Setup Guide

This guide will help you get the Motaba3a app running on your local machine in **15 minutes**.

## 📋 Prerequisites Checklist

- [ ] Flutter SDK installed (run `flutter --version` to check)
- [ ] Firebase account created
- [ ] Android Studio or Xcode installed
- [ ] Git installed

## 🔥 Firebase Setup (5 minutes)

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Name it "Motaba3a" (or any name you prefer)
4. Disable Google Analytics (optional for development)
5. Click "Create project"

### Step 2: Enable Authentication

1. In Firebase Console, go to **Authentication**
2. Click "Get started"
3. Enable **Email/Password** authentication
4. Save changes

### Step 3: Create Firestore Database

1. Go to **Firestore Database**
2. Click "Create database"
3. Choose **Test mode** (for development)
4. Select a location (closest to you)
5. Click "Enable"

### Step 4: Add Apps to Firebase

**For Android:**
1. Click the Android icon in Project Overview
2. Register app with package name: `com.example.motaba3a`
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`

**For iOS:**
1. Click the iOS icon in Project Overview
2. Register app with bundle ID: `com.example.motaba3a`
3. Download `GoogleService-Info.plist`
4. Place it in: `ios/Runner/GoogleService-Info.plist`

## 📱 Local Setup (5 minutes)

### Step 1: Clone and Install Dependencies

```bash
# Navigate to project directory
cd /Users/gojo/Documents/Projects/motaba3a

# Install dependencies
flutter pub get

# Check for issues
flutter doctor
```

### Step 2: Add Firebase Configuration

**Option A: FlutterFire CLI (Recommended)**
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure

# Follow the prompts and select your Firebase project
```

**Option B: Manual (if FlutterFire fails)**
- Make sure `google-services.json` and `GoogleService-Info.plist` are in place
- Firebase will auto-configure on first run

### Step 3: Run the App

```bash
# List available devices
flutter devices

# Run on first available device
flutter run

# Or run on specific device
flutter run -d <device-id>
```

## 🧪 Testing the App (5 minutes)

### Test Authentication Flow

1. **Launch the app** - You should see the login screen
2. **Register a new account**:
   - Toggle to "مستخدم" (User) or "ورشة" (Workshop)
   - Fill in all required fields
   - Click "إنشاء حساب" (Create Account)
3. **Verify success** - You should see a confirmation modal
4. **Check Firebase Console**:
   - Go to Authentication tab
   - You should see the new user
   - Go to Firestore and verify user document created

### Test Service Request Flow

1. **Navigate to home screen** after login
2. **Click "أضافة عميل"** (Add Client)
3. **Fill in service request form**:
   - Client name and phone
   - Vehicle details
   - Service types
   - Dates and price
4. **Submit the request**
5. **Verify in Firestore**:
   - Check `service_requests` collection
   - New document should appear

### Test Search Feature

1. From home screen, **tap search bar**
2. Enter a phone number of an existing client
3. Results should appear in real-time

## 🐛 Troubleshooting

### Issue: "Firebase not initialized"

**Solution:**
```bash
# Make sure Firebase is properly configured
flutterfire configure

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Issue: "MissingPluginException"

**Solution:**
```bash
# Stop the app
# Rebuild completely
flutter clean
flutter pub get
cd ios && pod install && cd ..  # iOS only
flutter run
```

### Issue: "google-services.json not found"

**Solution:**
- Download file from Firebase Console
- Place in: `android/app/google-services.json`
- Ensure it's NOT in `.gitignore`
- Rebuild: `flutter clean && flutter run`

### Issue: Firestore "Permission Denied"

**Solution:**
1. Go to Firestore Console
2. Click "Rules" tab
3. Replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

4. Click "Publish"

### Issue: App crashes on startup

**Solution:**
```bash
# Check logs
flutter run --verbose

# Common fixes:
flutter clean
flutter pub get
flutter pub upgrade

# For iOS
cd ios
pod deintegrate
pod install
cd ..

# Try again
flutter run
```

## 📊 Verify Setup is Complete

Run these checks to ensure everything is working:

- [ ] App compiles without errors
- [ ] Login screen appears correctly (RTL Arabic)
- [ ] Can register new user
- [ ] User appears in Firebase Authentication
- [ ] User document created in Firestore
- [ ] Can navigate to home screen
- [ ] Can create service request
- [ ] Service request appears in Firestore
- [ ] Can search for clients by phone
- [ ] Real-time updates work (create request in Firestore console, it appears in app)

## 🎉 Next Steps

Once setup is complete:

1. **Explore the code**:
   - Check `lib/models/` for data structures
   - Review `lib/viewmodels/` for business logic
   - Examine `lib/views/` for UI implementation

2. **Customize**:
   - Update app colors in `lib/utils/constants.dart`
   - Modify Firebase rules for production
   - Add more features based on requirements

3. **Deploy**:
   - Set up CI/CD (see README)
   - Build release APK/IPA
   - Deploy to Firebase App Distribution

## 📞 Need Help?

- Check the main [README.md](README.md) for detailed documentation
- Review Firebase Console for backend issues
- Use `flutter doctor` to diagnose environment issues
- Check Flutter logs: `flutter run --verbose`

---

**Setup Time: ~15 minutes**
**Ready to code! 🚀**


