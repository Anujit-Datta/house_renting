# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with this repository.

## Project Overview

**Rentify** is a Flutter-based house renting mobile application with a multi-role authentication system (Tenant, Landlord, Admin). It connects to a Laravel REST API backend for property listings, rental requests, contracts, payments, messaging, and more.

### Technology Stack
- **Framework**: Flutter (Dart SDK ^3.9.2) - **Installed via FVM** (Flutter Version Manager)
- **State Management**: GetX ^4.7.3
- **HTTP Client**: http ^1.6.0
- **Storage**: shared_preferences ^2.5.4
- **File Picker**: file_picker ^8.0.0
- **Backend API**: Laravel 11.31 at `https://rentify-laravel-ee2c76906f53.herokuapp.com/api`

---

## Common Commands

### Development (Using FVM)
```bash
# Use FVM to run Flutter commands
fvm flutter pub get

# Run the app
fvm flutter run

# Run with hot reload
fvm flutter run --auto-selection

# Run on specific device
fvm flutter run -d <device_id>
```

### Build
```bash
# Build Android APK
fvm flutter build apk

# Build Android App Bundle
fvm flutter build appbundle

# Build iOS
fvm flutter build ios
```

### Code Quality
```bash
# Run all tests
fvm flutter test

# Analyze code
fvm flutter analyze

# Format code
fvm flutter format .

# Check for outdated dependencies
fvm flutter pub outdated
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

### Controller Initialization Pattern (CRITICAL)

**NEVER initialize controllers in the `build()` method** - this causes infinite rebuilds and state loss:
```dart
// ❌ WRONG - Controller recreated on every rebuild
@override
Widget build(BuildContext context) {
  final controller = Get.put(AddPropertyController());
  return Scaffold(...);
}

// ✅ CORRECT - Initialize once in initState
class _MyWidgetState extends State<MyWidget> {
  late final MyController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(MyController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(...);
  }
}
```

### Checkbox State Management

Checkboxes MUST use individual RxBool observables (not controller-level aggregations):
```dart
// In controller
final isBachelor = false.obs;
final isFamily = false.obs;
final isSublet = false.obs;
final isCommercial = false.obs;

// In screen - wrapped in Obx
Obx(() => _buildCheckboxRow('Bachelor', controller.isBachelor))
```

**Don't use a single loading state** for multiple independent buttons - each button needs its own `RxBool` loading state.

### Navigation After Logout

**CRITICAL**: Reset controller state when logging out to prevent infinite loading:
```dart
Future<void> logout() async {
  // Clear auth data
  await prefs.remove('auth_token');

  // Reset PropertyController state BEFORE navigation
  if (Get.isRegistered<PropertyController>()) {
    final propertyController = Get.find<PropertyController>();
    propertyController.properties.clear();
    propertyController.isLoading.value = false;
    propertyController.errorMessage.value = '';
  }

  Get.offAll(() => const GuestHomeScreen());
}
```

### Controllers Must Start With `isLoading = false`

Never initialize controllers with `isLoading = true.obs` - this causes infinite loading indicators:
```dart
// ❌ WRONG
final RxBool isLoading = true.obs;

// ✅ CORRECT
final RxBool isLoading = false.obs;
```

### Property ID Type Handling

**Property.id is ALWAYS a String** from the API, but Laravel expects integers:
```dart
// From API response
String propertyId = property.id;  // e.g., "123"

// When calling delete/update APIs that expect int
await ApiService().deleteProperty(int.parse(propertyId));
```

### Boolean Field Submission

When sending boolean fields to Laravel, send them as booleans (not strings):
```dart
final propertyData = {
  'parking': parkingAvailable.value,  // ✅ bool
  'furnished': furnished.value,        // ✅ bool
  'featured': isFeatured.value,        // ✅ bool
  'available': propertyStatus.value == 'For Rent',  // ✅ bool
};
```

Laravel validation expects `'field' => 'boolean'` for these fields.

### Model Field Parsing - Available Checkbox

The `available` field in Property.fromJson has a critical pattern - it does NOT default to true:
```dart
// ✅ CORRECT - Only true if explicitly true
available: json['available'] == true || json['available'] == 1,

// ❌ WRONG - This was causing issues
available: json['available'] == true || json['available'] == 1 || json['available'] == null,
```

If the field is null in the database, it should be `false`, not `true`. This is important for edit dialogs that read from `widget.property.available`.

---

## Adding a New Feature

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

## Critical Bug Fixes (Recent Sessions)

### Issue: Checkboxes Not Working in Add Property
**Root Cause**: Controller initialized in `build()` method, recreating on every rebuild
**Fix**: Move controller initialization to `initState()` with `late final` pattern
**File**: `lib/screens/add_property_screen.dart`

### Issue: Available Checkbox Always Checked in Edit Dialog
**Root Cause**:
1. Hardcoded default value `bool _available = true;`
2. Not reading from `widget.property.available` in `initState()`
3. Property.fromJson had `|| json['available'] == null` causing null to default to true
**Fix**:
- Use `late bool _available;` and initialize in `initState()`
- Set `_available = widget.property.available;` in initState
- Remove `|| json['available'] == null` from Property.fromJson
**Files**: `lib/widgets/edit_property_dialog.dart`, `lib/controllers/property_controller.dart`

### Issue: Featured Checkbox Not Being Submitted
**Root Cause**: `'featured': isFeatured.value` was missing from propertyData map
**Fix**: Add `'featured': isFeatured.value,` to submission data
**File**: `lib/controllers/add_property_controller.dart`

### Issue: Guest Page Infinite Loading After Logout
**Root Cause**:
1. PropertyController initialized with `isLoading = true.obs`
2. Controller state not reset on logout
3. GetX reusing same controller instance with corrupted state
**Fix**:
- Change to `isLoading = false.obs`
- Reset controller state in AuthController.logout()
**Files**: `lib/controllers/property_controller.dart`, `lib/controllers/auth_controller.dart`

### Issue: Property Type Dropdown Always Shows "Apartment"
**Root Cause**: API returns lowercase (e.g., "apartment") but dropdown compares to capitalized list
**Fix**: Convert to lowercase before comparison, then capitalize for display
**File**: `lib/widgets/edit_property_dialog.dart`

---

## Laravel Backend - Logging Patterns

All Laravel API endpoints use comprehensive logging for debugging:
- **Store (Create)**: Logs user info, request data, image uploads, success with featured/available/parking/furnished values
- **Update**: Logs user info, property_id, request data, image updates
- **Destroy (Delete)**: Logs user info, property_id, ownership checks, image deletions

**Example from PropertyController.php**:
```php
\Log::info('Property creation request received', [
    'user_id' => Auth::id(),
    'user_email' => Auth::user()?->email,
    'request_data' => $request->except(['image']),
]);

\Log::info('Property created successfully', [
    'property_id' => $property->id,
    'property_name' => $property->property_name,
    'featured' => $property->featured ?? 'not set',
    'available' => $property->available ?? 'not set',
    'parking' => $property->parking ?? 'not set',
    'furnished' => $property->furnished ?? 'not set',
]);
```

Logs are stored in `storage/logs/laravel.log` and can be viewed with:
```bash
tail -f rentify_laravel/storage/logs/laravel.log
```

---

## Important: Implementation Status

This is an ACTIVE project with ongoing development. See:
- **IMPLEMENTATION_PLAN.md** - Full progress log, task lists
- **FLUTTER_API_STATUS_ANALYSIS.md** - API implementation status (90+ methods)

**Recent fixes** (Current Session):
- Fixed controller initialization causing checkbox state loss
- Fixed available/featured checkbox submission and display
- Fixed guest page infinite loading after logout
- Implemented delete property functionality
- Fixed property type dropdown not reading backend value
- Added comprehensive Laravel logging for debugging

**Remaining high-priority tasks**:
- Create ForgotPasswordScreen
- Create ProfileEditScreen
- Verify MyReviewsScreen API connection
