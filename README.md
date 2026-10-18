# TapWait Waiter

A Flutter-based Android application for restaurant and bar waiters to receive customer service requests, get notified, vibrate when supported, and accept table assignments.

TapWait is part of a QR-based waiter-calling system designed to help hospitality businesses respond to customers faster and coordinate staff more efficiently.

## Project Status

**Current phase:** Android notification and vibration demo.

The initial version focuses on testing the waiter experience on a physical Android device before integrating the Node.js backend, MongoDB, and customer website.

## Features

### Current MVP

- Simple waiter interface built with Flutter.
- Test customer request for a table.
- Vibration test on supported Android devices.
- Accept a customer service request.
- Display the request status.
- Reset the demo to test another request.

### Planned Features

- Receive real-time requests from a Node.js API.
- Receive background notifications through Firebase Cloud Messaging (FCM).
- Register waiter devices and notification tokens.
- Display table numbers and request details.
- Accept or decline incoming requests.
- Prevent multiple waiters from accepting the same request.
- Track pending, accepted, and completed requests.
- Update the customer website when a waiter accepts.
- Support multiple waiters and tables within a bar or restaurant.

## How It Works

The intended workflow is:

1. A customer scans a QR code on their table.
2. The customer website displays a **Call a Waiter** button.
3. The customer requests assistance.
4. The backend stores the request and alerts eligible waiter devices.
5. A waiter receives an alert and vibration where supported.
6. The waiter accepts the request.
7. The backend assigns the request to that waiter.
8. The customer sees a confirmation, such as **"Keza is on the way to your table!"**

## Technology Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform waiter application |
| Dart | Application programming language |
| Node.js + Express | Planned backend API |
| MongoDB | Planned database |
| Firebase Cloud Messaging | Planned push notification delivery |
| Socket.IO | Optional real-time communication layer |
| QR codes | Customer table access |

## Requirements

To develop and run the application, install:

- Flutter SDK
- Dart SDK, included with Flutter
- Android Studio or the Android SDK command-line tools
- Android device or Android emulator
- USB cable for physical-device testing

Check your development environment:

```bash
flutter doctor
```

Check connected devices:

```bash
flutter devices
```

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/tapwait-waiter.git
cd tapwait-waiter
```

Replace `YOUR_USERNAME` with your GitHub username.

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the application

Connect an Android phone with USB debugging enabled, authorize the computer, and run:

```bash
flutter run
```

Select the connected Android device if prompted.

### 4. Test the demo

1. Open the TapWait app.
2. Tap **Trigger Test Alert**.
3. Confirm that the request appears and the phone vibrates if supported.
4. Tap **Accept Request**.
5. Confirm that the acceptance status appears.
6. Tap **Reset Demo** to repeat the test.

> The initial demo triggers its alert locally. It does not yet receive requests from the customer website or backend.

## Build an Android APK

Build a release APK with:

```bash
flutter build apk --release
```

The generated APK will be located at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Transfer the APK to your Android phone and install it. Android may require you to authorize installation from the source used to transfer the file.

## Vibration and Notifications

Vibration behavior depends on Android device capabilities, system settings, permissions, and application state.

The initial demo tests vibration while the app is open. Background and terminated-app alerts will be implemented through push notifications in a later phase.

Firebase Cloud Messaging credentials must remain on the backend. Never include server credentials in the Flutter application or commit private service-account keys to GitHub.

## Planned Backend Integration

The Flutter app will eventually communicate with a Node.js backend that:

- Authenticates waiters.
- Registers device notification tokens.
- Stores customer requests in MongoDB.
- Sends notifications to eligible waiters.
- Ensures each request can be accepted by only one waiter.
- Exposes request status to the customer website.

## Security

- Authenticate staff before exposing waiter requests.
- Authorize every request acceptance on the server.
- Keep database credentials and Firebase server credentials private.
- Validate customer requests and table identifiers.
- Avoid storing unnecessary customer information.
- Protect API endpoints against unauthorized requests.

## Contributing

Contributions, suggestions, and bug reports are welcome. Please open an issue before making significant architectural changes.
