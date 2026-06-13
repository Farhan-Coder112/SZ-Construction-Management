# SZ Construction Management

A comprehensive construction management system built with Flutter for Windows.

## Features
- Project Management
- Worker Management
- Labour Tracking
- Financial Management
- Daily Updates
- Inventory Management
- Reports Generation
- In-App Updates (via GitHub Releases)

## 🛠️ Installation (from Git)

### Prerequisites
1. Install Flutter from https://flutter.dev/docs/get-started/install/windows
2. Install Visual Studio with "Desktop development with C++" workload

### Step-by-Step Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/Farhan-Coder112/SZ-Construction-Management.git
   cd SZ-Construction-Management
   ```

2. **Fix Common Errors:
   - **Error 1: Missing firebase_options.dart**
     Copy `lib\firebase\firebase_options.dart.template` to `lib\firebase\firebase_options.dart` and update with your Firebase config (see below)
   - **Error 2: Missing dependencies**
     Run `flutter pub get`
   - **Error 3: Windows build error**
     Make sure Visual Studio is installed with "Desktop development with C++"
   - **Error 4: Firebase initialization error**
     Make sure your Firebase project is correctly configured (see below)

3. Configure Firebase:
   - Go to https://console.firebase.google.com
   - Create/select your project
   - Enable: Authentication, Firestore Database, Storage, Messaging
   - Update `lib/firebase/firebase_options.dart` with your actual config

4. Run the app:
   ```bash
   flutter run -d windows
   ```

## 📦 Build Release Version
```bash
flutter build windows --release
```
Output will be in `build\windows\x64\runner\Release\`

## 🚀 In-App Updates
To use the in-app update feature:
1. Create a new release on GitHub
2. Attach the installer (use Inno Setup to create one from `installer_script.iss`)
3. The app will automatically detect new releases!
