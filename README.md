# AI Paralegal

A cross-platform Flutter application designed for Windows and iOS platforms, providing AI-powered paralegal assistance.

## Platform Support

This project is specifically configured for:
- **Windows Desktop** - Native Windows application
- **iOS** - Native iOS application

## Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- For Windows development: Visual Studio 2022 with C++ tools
- For iOS development: Xcode 14+ (macOS required)

### Development Setup

1. **Clone and setup:**
   ```bash
   flutter pub get
   ```

2. **Run on Windows:**
   ```bash
   flutter run -d windows
   ```

3. **Run on iOS:**
   ```bash
   flutter run -d ios
   ```

### Project Structure
```
lib/
├── main.dart              # Application entry point
├── models/                # Data models
├── services/              # Business logic and API services
├── screens/               # UI screens
├── widgets/               # Reusable UI components
└── utils/                 # Utility functions and helpers
```

## Features
- Cross-platform compatibility (Windows & iOS)
- Modern Material Design and Cupertino UI elements
- AI-powered paralegal assistance
- Platform-specific optimizations

## Development Resources
- [Flutter Documentation](https://docs.flutter.dev/)
- [Windows Desktop Development](https://docs.flutter.dev/platform-integration/windows/building)
- [iOS Development Guide](https://docs.flutter.dev/platform-integration/ios)
