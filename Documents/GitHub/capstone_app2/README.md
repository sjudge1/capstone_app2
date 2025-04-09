# Organ Size Matching App

A Flutter application designed to help medical professionals match organ donors with recipients based on organ size compatibility. The app supports both heart and lung transplant matching.

## Features

- Separate screens for heart and lung patients/donors
- Advanced filtering capabilities:
  - Organ size range filter (2-10+ L for lungs, 75-500+ g for hearts)
  - Blood type filter
  - Gender filter
- Sorting options:
  - Name (A-Z, Z-A)
  - Date added (newest, oldest)
  - Organ size (smallest to largest, largest to smallest)
- Real-time updates with Firebase integration
- User authentication
- Intuitive form input for patient/donor data

## Getting Started

1. Clone the repository
2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```
3. Configure Firebase:
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Update Firebase configuration in the project

## Requirements

- Flutter SDK
- Firebase account
- iOS/Android development environment

## Development

This project uses:
- Flutter for the frontend
- Firebase for backend services
- Cloud Firestore for the database

## License

This project is proprietary and confidential. 