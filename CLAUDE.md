# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Rentify** is a Flutter-based house renting application with a multi-role authentication system. The app currently implements authentication screens for three user roles: Tenant, Landlord, and Admin.

### Technology Stack
- **Framework**: Flutter (Dart SDK ^3.9.2)
- **Material Design**: Uses Material 3 with dark theme
- **Primary Package Dependencies**:
  - `cupertino_icons`: ^1.0.8 - iOS-style icons
  - `file_picker`: ^8.0.0 - File selection for document uploads

## Common Commands

### Development
```bash
# Install dependencies
flutter pub get

# Run the app in development mode
flutter run

# Run on specific device
flutter run -d <device_id>

# Run with hot reload enabled (default)
flutter run --auto-selection
```

### Build
```bash
# Build Android APK
flutter build apk

# Build Android App Bundle
flutter build appbundle

# Build iOS
flutter build ios

# Build for specific platforms
flutter build web
flutter build windows
flutter build macos
flutter build linux
```

### Testing & Quality
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage

# Analyze code for issues
flutter analyze

# Format code
flutter format .

# Check for outdated dependencies
flutter pub outdated
```

## Architecture & Code Organization

### Directory Structure
```
lib/
├── main.dart              # App entry point, theme configuration
├── screens/
│   └── auth_screen.dart   # Authentication screen with role tabs
└── widgets/
    ├── login_form.dart    # Login form component
    └── signup_form.dart   # Signup form with file uploads & password strength
```

### Key Architecture Patterns

**Screen-Widget Separation**: Screens handle layout and navigation logic, while widgets contain reusable form components.

**State Management**: Currently uses `StatefulWidget` with local state. No external state management (Provider, Riverpod, Bloc) is implemented yet.

**Role-Based Authentication**: The app supports three user roles selected via tabs:
- Tenant
- Landlord
- Admin

The selected role is passed to form widgets and affects authentication flow.

### Theme Configuration

The app uses a consistent dark theme defined in `main.dart`:
- **Primary Color**: `#FFFF7F50` (Coral/Orange) - used for buttons, active states, and links
- **Background**: Black (`#FF000000`)
- **Surface**: `#FF1E1E1E` - cards and elevated surfaces
- **Input Background**: `#FF2C2C2C` - text fields and dropdowns

Theme is applied globally via `ThemeData` in MaterialApp, including:
- `inputDecorationTheme` - consistent input field styling
- `elevatedButtonTheme` - button appearance with 8px border radius

### Component Patterns

**Animated Form Switching**: Uses `AnimatedSwitcher` with `ValueKey` for smooth login/signup form transitions in `auth_screen.dart:108-121`.

**File Upload Pattern**: Implemented in `signup_form.dart:313-366` using the `file_picker` package. Pattern includes:
- Label display
- "Choose File" button
- Selected filename display
- Callback for file selection

**Password Strength Indicator**: Real-time password validation in `signup_form.dart:26-46` with visual feedback using `LinearProgressIndicator` and color coding (red/orange/green).

### Authentication Features

**Login Form** (`login_form.dart`):
- Email/Username field
- Password field with visibility toggle
- "Remember me" checkbox
- "Forgot password?" link
- Role-aware login

**Signup Form** (`signup_form.dart`):
- Username with availability indicator (mock)
- Email field
- Country code selector (+880 BD, +1 US)
- Phone number field
- NID (National ID) number
- NID front/back document uploads
- Password with strength indicator
- Confirm password with visibility toggle
- Terms & conditions checkbox
- Verification method selector (Email/SMS)

## Development Notes

### Adding New Screens
1. Create screen in `lib/screens/`
2. Update `main.dart` to add routing
3. Follow existing theme patterns using `Theme.of(context)`

### Adding New Form Widgets
1. Create widget in `lib/widgets/`
2. Accept `role` parameter if role-specific behavior needed
3. Use `TextFormField` with consistent `InputDecoration` from theme
4. Implement validation and state management locally

### File Upload Implementation
When adding new file upload features, follow the pattern in `signup_form.dart`:
- Use `FilePicker.platform.pickFiles()` from the `file_picker` package
- Handle null results when user cancels
- Update local state and trigger UI rebuild with `setState()`

### Styling Guidelines
- Use theme colors: `const Color(0xFFFF7F50)` for primary actions
- Maintain 8px border radius for consistency
- Use `SizedBox(height: 16)` for standard vertical spacing
- Follow Material 3 design principles
- All text fields should use the global `inputDecorationTheme`
