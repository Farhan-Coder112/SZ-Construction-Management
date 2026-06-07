# SZ Construction Management System

A comprehensive Flutter desktop application for construction project management, built for Windows with Firebase backend and local SQLite support.

## Features

- **Project Management**: Track multiple construction projects with progress monitoring
- **Worker Management**: Manage workers, attendance, and daily wages
- **Labour Tracking**: Monitor labour hours, overtime, and shift management
- **Financial Management**: Track expenses, payments, and client billing
- **Daily Updates**: Record daily site progress and activities
- **Inventory Management**: Track materials and supplies
- **Reports**: Generate PDF and Excel reports for financial, labour, and project data
- **Dashboard**: Real-time analytics and overview of all operations
- **Authentication**: Secure user authentication with role-based access control
- **Offline Support**: Local SQLite database for offline operations

## Tech Stack

- **Framework**: Flutter (SDK >=3.0.0)
- **Backend**: Firebase (Auth, Firestore, Storage, Messaging, Analytics)
- **Local Database**: SQLite (sqflite_common_ffi for Windows)
- **State Management**: Provider
- **UI**: Material Design with custom theming
- **Reports**: PDF and Excel generation
- **Window Management**: Custom window manager for desktop

## Prerequisites

- Flutter SDK (>=3.0.0)
- Windows 10 or later
- Firebase project with Windows app configured
- Internet connection (for Firebase sync)

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd SZ Construction Management
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Replace placeholder values in `lib/firebase/firebase_options.dart` with your Firebase project configuration
   - Or use the existing configuration if already set up

4. Run the application:
```bash
flutter run -d windows
```

## Firebase Setup

1. Create a Firebase project at https://console.firebase.google.com
2. Add a Windows app to your Firebase project
3. Copy the configuration values
4. Update `lib/firebase/firebase_options.dart` with your credentials

## Project Structure

```
lib/
├── animations/          # UI animations
├── database/           # SQLite database helper and sync service
├── firebase/           # Firebase services (Auth, Firestore, Storage)
├── models/             # Data models
├── providers/          # State management providers
├── screens/            # UI screens
├── services/           # Business logic services (Reports, Export, Notifications)
├── themes/            # App theming
├── utils/             # Utilities and constants
└── widgets/           # Reusable widgets
```

## User Roles

- **Admin**: Full system access, can manage all users and settings
- **Manager**: Can manage projects, workers, and expenses
- **Supervisor**: Can post daily updates and manage attendance
- **Employee**: View-only access to assigned projects
- **Client**: View-only access to their projects

## Building for Production

To create a Windows executable:

```bash
flutter build windows --release
```

The executable will be located at:
`build/windows/x64/runner/Release/sz_construction_management.exe`

## Demo Accounts

For testing without Firebase configuration, use these demo accounts:

- **Admin**: admin@szgroup.com / admin123
- **Manager**: manager@szgroup.com / manager123
- **Employee**: employee@szgroup.com / employee123

## Features Overview

### Dashboard
- Overview of all projects, workers, and financials
- Monthly expense and revenue charts
- Recent activity feed
- Quick access to all modules

### Projects
- Create and manage construction projects
- Track project progress and milestones
- Manage project documents and images
- Client and engineer assignment

### Workers
- Worker profile management
- Attendance tracking
- Daily wage calculation
- ID proof verification

### Labour
- Daily labour attendance
- Shift management
- Overtime tracking
- Labour cost analysis

### Payments
- Client payment tracking
- Labour payment management
- Payment status monitoring
- Receipt generation

### Expenses
- Expense categorization
- Vendor management
- Project expense allocation
- Expense approval workflow

### Reports
- Financial reports (PDF/Excel)
- Labour reports
- Project progress reports
- Expense breakdown reports
- Client payment reports

## Support

For support and inquiries, contact the development team.

## License

Copyright © 2024 SZ Group. All rights reserved.
