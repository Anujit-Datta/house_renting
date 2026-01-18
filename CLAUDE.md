# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Rentify** is a Flutter-based house renting mobile application with a multi-role authentication system (Tenant, Landlord, Admin). It connects to a Laravel REST API backend for property listings, rental requests, contracts, payments, messaging, and more.

### Technology Stack
- **Framework**: Flutter (Dart SDK ^3.9.2)
- **State Management**: GetX ^4.7.3
- **HTTP Client**: http ^1.6.0
- **Storage**: shared_preferences ^2.5.4
- **File Picker**: file_picker ^8.0.0
- **Backend API**: Laravel 11.31 at `https://rentify-laravel-ee2c76906f53.herokuapp.com/api`

---

## Common Commands

### Development
```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run with hot reload
flutter run --auto-selection

# Run on specific device
flutter run -d <device_id>
```

### Build
```bash
# Build Android APK
flutter build apk

# Build Android App Bundle
flutter build appbundle

# Build iOS
flutter build ios
```

### Code Quality
```bash
# Run all tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format .

# Check for outdated dependencies
flutter pub outdated
```

---

## Architecture & Code Organization

### Directory Structure
```
lib/
├── main.dart                          # App entry point, controller binding
├── models.dart                        # Data models (Contract, Payment, RentalRequest)
├── theme/
│   ├── app_theme.dart                 # Light/dark theme definitions
│   └── theme_manager.dart             # Theme switching logic
├── utils/
│   └── api_constants.dart             # API base URL configuration
├── services/
│   ├── api_service.dart               # Singleton API client (ALL API calls)
│   └── property_service.dart          # Property-specific service wrapper
├── controllers/
│   ├── auth_controller.dart           # Authentication state & login/logout
│   ├── property_controller.dart       # Property listing & details
│   ├── rental_requests_controller.dart # Rental request CRUD
│   ├── contract_controller.dart       # Contract management
│   ├── payment_controller.dart        # Payment processing
│   ├── message_controller.dart        # Chat/messaging
│   ├── notification_controller.dart   # User notifications
│   ├── support_ticket_controller.dart # Support tickets
│   ├── tenant_controller.dart         # Tenant-specific data
│   ├── landlord_controller.dart       # Landlord-specific data
│   ├── add_property_controller.dart   # Property creation
│   ├── landlord_wallet_controller.dart # Landlord wallet
│   └── theme_controller.dart          # Theme mode management
├── screens/
│   ├── auth_screen.dart               # Login/signup with role tabs
│   ├── guest_home_screen.dart         # Not logged in - browse properties
│   ├── tenant_home_screen.dart        # Logged-in tenant dashboard
│   ├── landlord_home_screen.dart      # Logged-in landlord dashboard
│   ├── property_details_screen.dart   # Individual property view
│   ├── add_property_screen.dart       # Landlord add property form
│   ├── rental_requests_screen.dart    # View/manage rental requests
│   ├── contract_screen.dart           # View/sign contracts
│   ├── payment_screen.dart            # Payment history
│   ├── tenant/pay_rent_screen.dart    # Make a payment
│   ├── tenant/wallet_screen.dart      # Wallet balance & transactions
│   ├── messages_screen.dart           # Conversation list
│   ├── chat_screen.dart               # Individual chat
│   ├── notifications_screen.dart      # Notifications list
│   └── support_tickets_screen.dart    # Support ticket management
└── widgets/
    ├── custom_app_bar.dart            # Reusable app bar
    ├── property_card.dart             # Property listing card
    ├── rental_application_dialog.dart  # Rental request form dialog
    ├── login_form.dart                # Login form widget
    ├── signup_form.dart               # Signup form widget
    ├── advanced_filters_dialog.dart   # Property filter dialog
    └── edit_property_dialog.dart      # Edit property dialog
```

---

## Key Architecture Patterns

### State Management with GetX

**All controllers** extend `GetxController` and use observable variables (`Rx<T>`):
```dart
final RxBool isLoading = false.obs;
final Rxn<User> currentUser = Rxn<User>();
```

**Accessing controllers** (must be registered in `main.dart`):
```dart
final authController = Get.find<AuthController>();
```

**Observing state changes** with `Obx()` or `GetX<>`:
```dart
GetX<AuthController>(
  builder: (controller) => Text(controller.currentUser?.name ?? 'Guest'),
)
```

### API Layer - Singleton Pattern

**ApiService** (`lib/services/api_service.dart`) is a singleton that handles ALL HTTP requests:
- Uses Bearer token from SharedPreferences for authentication
- Automatic token injection via `_getHeaders()`
- Returns `Map<String, dynamic>` or throws exceptions
- 90+ API methods implemented (see IMPLEMENTATION_PLAN.md)

**Usage pattern**:
```dart
final response = await _apiService.login(email, password);
if (response['success'] == true) {
  // Handle success
}
```

### Controller Pattern

Controllers follow this standard structure:
1. **Observables**: `RxList<T>`, `RxBool isLoading`, `RxString errorMessage`
2. **API Service instance**: `final ApiService _apiService = ApiService();`
3. **Fetch methods**: `fetchXxx()` - load data from API
4. **Action methods**: `createXxx()`, `updateXxx()`, `deleteXxx()`
5. **Getters**: Computed properties like `pendingItems`, `completedItems`

**Example** (from `rental_requests_controller.dart`):
```dart
class RentalRequestController extends GetxController {
  final RxList<RentalRequest> rentalRequests = <RentalRequest>[].obs;
  final RxBool isLoading = false.obs;
  final ApiService _apiService = ApiService();

  Future<void> fetchRentalRequests() async {
    try {
      isLoading(true);
      final response = await _apiService.getRentalRequests();
      // Parse and update observable list
    } catch (e) {
      // Handle error
    } finally {
      isLoading(false);
    }
  }
}
```

### Authentication Flow

**Role-based routing** in `main.dart`:
1. `AuthController.isAuthCheckComplete` - Shows loading until auth status determined
2. If logged in, route based on `currentUser.role`:
   - `tenant` → `TenantHomeScreen`
   - `landlord` → `LandlordHomeScreen`
   - `admin` → (not implemented)
3. If not logged in → `GuestHomeScreen`

**User model** (`lib/controllers/auth_controller.dart`):
```dart
class User {
  final int id;
  final String name;
  final String email;
  final String role;      // 'tenant', 'landlord', 'admin'
  final String? photoUrl;
  final String? token;
}
```

**Auth persistence**:
- Token stored in SharedPreferences: `auth_token`
- User data stored in SharedPreferences: `user_data`
- Both loaded on app startup in `_checkLoginStatus()`

### Theme System

**Dual theme support** (light/dark):
- `ThemeController` manages `themeMode` observable
- `AppTheme` class defines `lightTheme` and `darkTheme`
- Primary color: `#FFFF7F50` (Coral/Orange)
- Toggle via `themeController.toggleTheme()`

---

## Development Guidelines

### Adding a New Feature

1. **Add API method to ApiService** (`lib/services/api_service.dart`):
   ```dart
   Future<Map<String, dynamic>> newFeature() async {
     final url = '${ApiConstants.baseUrl}/new-endpoint';
     final headers = await _getHeaders();
     final response = await http.get(Uri.parse(url), headers: headers);
     if (response.statusCode == 200) {
       return json.decode(response.body);
     } else {
       throw Exception('Failed: ${response.body}');
     }
   }
   ```

2. **Create or update controller** (`lib/controllers/xxx_controller.dart`):
   - Extend `GetxController`
   - Add observables for state
   - Inject `ApiService`
   - Implement fetch/action methods
   - Register in `main.dart` if new

3. **Create or update screen** (`lib/screens/xxx_screen.dart`):
   - Use `GetX<ControllerName>` to observe state
   - Show loading indicator when `controller.isLoading.value`
   - Show errors via `Get.snackbar()`
   - Call controller methods for actions

4. **Update routing** if needed:
   - Add navigation in existing screens
   - Update `main.dart` for auth-based routing

### Auto-filling User Data in Forms

When creating forms that need logged-in user info:
```dart
// In widget State
late final AuthController _authController;
late final TextEditingController _nameController;

@override
void initState() {
  super.initState();
  _authController = Get.find<AuthController>();
  final user = _authController.currentUser;
  _nameController = TextEditingController(text: user?.name ?? '');
}
```

### Dialog Pattern for Forms

**Critical**: Dialogs that submit data must:
1. Accept required data as constructor parameters (e.g., `propertyId`)
2. Inject controllers via `Get.find<ControllerName>()`
3. Use `TextEditingController` for all form fields
4. Implement proper validation
5. Call controller API methods on submit
6. Show loading state during submission
7. Use `Get.snackbar()` for success/error feedback
8. Close dialog with `Get.back()` on success

**Example** (`rental_application_dialog.dart`):
```dart
class RentalApplicationDialog extends StatefulWidget {
  final String propertyId;  // Required parameter
  const RentalApplicationDialog({super.key, required this.propertyId});
}

// In State
late final AuthController _authController;
late final RentalRequestController _rentalRequestController;

@override
void initState() {
  super.initState();
  _authController = Get.find<AuthController>();
  _rentalRequestController = Get.find<RentalRequestController>();
  // Initialize text controllers with user data
}

Future<void> _submitApplication() async {
  setState(() => _isSubmitting = true);
  try {
    await _rentalRequestController.createRentalRequest(requestData);
    Get.back();
    Get.snackbar('Success', 'Message');
  } catch (e) {
    Get.snackbar('Error', e.toString());
  } finally {
    setState(() => _isSubmitting = false);
  }
}
```

### Error Handling Pattern

**Standard error handling**:
```dart
try {
  isLoading(true);
  final response = await _apiService.someMethod();
  if (response['success'] == true && response['data'] != null) {
    // Process data
  } else {
    throw Exception(response['message'] ?? 'Failed');
  }
} catch (e) {
  errorMessage.value = e.toString();
  print('Error: $e');
  rethrow;  // Re-throw for UI to handle
} finally {
  isLoading(false);
}
```

**Show user feedback**:
```dart
Get.snackbar(
  'Error',
  'Failed to complete action',
  backgroundColor: Colors.red,
  colorText: Colors.white,
  snackPosition: SnackPosition.BOTTOM,
);
```

---

## Project-Specific Constraints

### Database
- **DO NOT modify database schema** - Shared with raw PHP project
- All Laravel APIs must work with existing `house_renting` database
- No migrations are used in Laravel project

### Property ID Type
- **Property.id is a String** from API (from `PropertyController`)
- When passing to APIs that expect int, use: `int.parse(propertyId)`

### User Model Limitations
- `User` model in `AuthController` does NOT include phone number
- Phone must be collected separately in forms

### Controller Registration
All controllers must be registered in `main.dart` BEFORE `runApp()`:
```dart
void main() {
  Get.put(ThemeController());
  Get.put(AuthController());
  Get.put(PropertyController());
  // ... all other controllers
  runApp(const MyApp());
}
```

---

## Key Files Reference

| File | Purpose | Important Notes |
|------|---------|-----------------|
| `main.dart` | App entry, controller binding | Role-based routing logic |
| `lib/services/api_service.dart` | ALL API calls | Singleton pattern, 90+ methods |
| `lib/controllers/auth_controller.dart` | Auth state | User model, token management |
| `lib/utils/api_constants.dart` | API base URL | Heroku backend URL |
| `lib/theme/app_theme.dart` | Theme definitions | Primary color #FFFF7F50 |
| `IMPLEMENTATION_PLAN.md` | Project tracking | Progress log, API status |
| `FLUTTER_API_STATUS_ANALYSIS.md` | API documentation | Working vs non-working APIs |

---

## Important: Implementation Status

This is an ACTIVE project with ongoing development. See:
- **IMPLEMENTATION_PLAN.md** - Full progress log, task lists
- **FLUTTER_API_STATUS_ANALYSIS.md** - API implementation status (90+ methods)

**Recent fixes** (Session 3):
- RentalApplicationDialog now auto-fills user data and submits to API
- PropertyDetailsScreen passes propertyId to dialog

**Remaining high-priority tasks**:
- Create ForgotPasswordScreen
- Create ProfileEditScreen
- Verify MyReviewsScreen API connection
