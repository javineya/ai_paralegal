# Copilot Instructions for AI Paralegal Flutter Project

<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

## Project Overview
This is a Flutter cross-platform application designed to work on both Windows and iOS platforms. The project is focused on AI paralegal functionality.

## Development Guidelines

### Platform Support
- **Primary Platforms**: Windows and iOS
- **Architecture**: Cross-platform with platform-specific implementations when needed
- **UI Framework**: Flutter with Material Design and Cupertino widgets

### Code Style
- Follow Flutter and Dart best practices
- Use meaningful variable and function names
- Implement proper error handling
- Write comprehensive documentation
- Use dependency injection for better testability

### Platform-Specific Considerations
- Use `Platform.isWindows` and `Platform.isIOS` for platform detection
- Implement Cupertino widgets for iOS-specific UI elements
- Use Material widgets for Windows and general cross-platform UI
- Handle platform-specific file operations and system integrations

### Dependencies
- Prefer packages that support both Windows and iOS
- Use `platform_interface` pattern for platform-specific functionality
- Keep dependencies minimal and well-maintained

### Testing
- Write unit tests for business logic
- Include widget tests for UI components
- Test platform-specific functionality on both target platforms
