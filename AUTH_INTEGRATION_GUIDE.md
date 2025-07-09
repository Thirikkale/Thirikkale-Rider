# Thirikkale Rider App - Authentication Integration Guide

## Overview

This guide explains how to use the updated `AuthProvider` with the integrated API configuration for a complete rider signup and authentication flow.

## Key Components

### 1. AuthProvider (`lib/core/providers/auth_provider.dart`)

The enhanced AuthProvider handles the complete authentication flow:

- **Phone verification** with Firebase OTP
- **Backend user existence check**
- **User registration** with backend
- **Login** for existing users
- **Profile management**
- **State management** throughout the auth flow

### 2. API Configuration (`lib/core/config/api_config.dart`)

Contains all endpoint configurations:
- Base URLs for your Spring Boot backend
- Authentication endpoints
- Rider-specific endpoints
- Header configurations

### 3. User Model (`lib/models/user_model.dart`)

Combined user and rider model for simplified state management.

## Authentication Flow

### Step 1: Phone Number Entry
```dart
final authProvider = Provider.of<AuthProvider>(context, listen: false);

await authProvider.sendOTP(
  phoneNumber: '+94771234567',
  onCodeSent: (verificationId, resendToken) {
    // Navigate to OTP screen
  },
  onVerificationFailed: (error) {
    // Show error message
  },
);
```

### Step 2: OTP Verification
```dart
final success = await authProvider.verifyOTP('123456');
if (success) {
  // OTP verified, proceed to user check
}
```

### Step 3: User Existence Check
```dart
final userExists = await authProvider.checkUserExists();
if (userExists) {
  // User logged in, navigate to main app
} else {
  // User needs registration
}
```

### Step 4: User Registration (if needed)
```dart
final success = await authProvider.registerUser(
  firstName: 'John',
  lastName: 'Doe',
  email: 'john@example.com',
);
if (success) {
  // Registration successful, user is now logged in
}
```

### Step 5: Profile Updates (optional)
```dart
final success = await authProvider.updateProfile(
  email: 'newemail@example.com',
  emergencyContactName: 'Emergency Contact',
  emergencyContactPhone: '+94771234568',
);
```

## AuthState Management

The provider uses an enum `AuthState` to track the current state:

- `initial` - Starting state
- `phoneEntered` - Phone number entered
- `otpSent` - OTP sent to phone
- `otpVerified` - OTP verified successfully
- `checkingUser` - Checking if user exists in backend
- `userExists` - User found and logged in
- `userNotExists` - User needs registration
- `registering` - Registration in progress
- `loggedIn` - User successfully logged in
- `error` - Error occurred

## Usage in Widgets

### Basic Usage
```dart
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    switch (authProvider.authState) {
      case AuthState.initial:
        return PhoneEntryWidget();
      case AuthState.otpSent:
        return OTPVerificationWidget();
      case AuthState.userNotExists:
        return RegistrationWidget();
      case AuthState.loggedIn:
        return MainAppWidget();
      default:
        return LoadingWidget();
    }
  },
)
```

### Error Handling
```dart
if (authProvider.errorMessage != null) {
  SnackbarHelper.showErrorSnackBar(
    context,
    authProvider.errorMessage!,
  );
}
```

### Loading States
```dart
if (authProvider.isLoading) {
  return const CircularProgressIndicator();
}
```

## Backend Configuration

### 1. Update API Base URL

In `lib/core/config/api_config.dart`, update the base URL:

```dart
static const String baseUrl = 'http://YOUR_BACKEND_IP:8081/user-service/api/v1';
```

### 2. Expected Backend Endpoints

#### Registration Endpoint: `POST /riders/register`
**Request Headers:**
```
Content-Type: application/json
Authorization: Bearer <firebase_id_token>
```

**Request Body:**
```json
{
  "phoneNumber": "+94771234567",
  "firstName": "John",
  "lastName": "Doe",
  "email": "john@example.com",
  "firebaseUid": "firebase_user_id"
}
```

**Response (Success):**
```json
{
  "token": "backend_jwt_token",
  "user": {
    "userId": "user_id",
    "phoneNumber": "+94771234567",
    "firstName": "John",
    "lastName": "Doe",
    "email": "john@example.com",
    "totalRides": 0,
    "createdAt": "2025-01-01T00:00:00Z"
  }
}
```

#### Login Endpoint: `POST /riders/login`
**Request Headers:**
```
Content-Type: application/json
Authorization: Bearer <firebase_id_token>
```

**Request Body:**
```json
{
  "phoneNumber": "+94771234567",
  "firebaseUid": "firebase_user_id"
}
```

**Response (Success):**
```json
{
  "token": "backend_jwt_token",
  "user": {
    "userId": "user_id",
    "phoneNumber": "+94771234567",
    "firstName": "John",
    "lastName": "Doe",
    "email": "john@example.com",
    "totalRides": 5,
    "createdAt": "2025-01-01T00:00:00Z"
  }
}
```

**Response (User Not Found):**
```
HTTP Status: 404
```

## Testing the Integration

### 1. Use the Demo Screen

Add the demo screen to your app for testing:

```dart
// In your main.dart or routing
MaterialPageRoute(
  builder: (context) => const SignupFlowDemo(),
)
```

### 2. Test Network Connectivity

Ensure your Flutter app can reach your backend:

```bash
# Test from your device/emulator
curl http://YOUR_BACKEND_IP:8081/user-service/api/v1/health
```

### 3. Verify Firebase Configuration

Ensure Firebase is properly configured:
- `google-services.json` (Android)
- `GoogleService-Info.plist` (iOS)
- Firebase Authentication enabled
- Phone authentication enabled

## Common Issues and Solutions

### 1. Network Issues

**Problem:** Cannot reach backend from device
**Solution:** 
- Use your computer's IP address instead of `localhost`
- Ensure firewall allows connections
- Test API endpoints with Postman/curl

### 2. Firebase Token Issues

**Problem:** Invalid Firebase tokens
**Solution:**
- Verify Firebase project configuration
- Check that phone authentication is enabled
- Ensure correct API keys

### 3. CORS Issues

**Problem:** CORS errors in web
**Solution:**
- Configure CORS in your Spring Boot backend
- Add allowed origins for your Flutter web app

### 4. Authentication Flow Issues

**Problem:** User gets stuck in certain states
**Solution:**
- Use `authProvider.resetToPhoneEntry()` to reset
- Check backend response formats
- Verify error handling

## Production Considerations

### 1. Security
- Remove debug print statements
- Use HTTPS in production
- Implement proper token refresh
- Add request/response encryption

### 2. Error Handling
- Implement comprehensive error messages
- Add retry mechanisms
- Handle network timeouts

### 3. User Experience
- Add loading animations
- Implement proper navigation flow
- Add offline support

### 4. Performance
- Implement token caching
- Add request debouncing
- Optimize network calls

## Example Integration

Check `lib/features/authenctication/screens/signup_flow_demo.dart` for a complete example of how to integrate all the authentication features.

This demo shows:
- Complete signup flow
- Error handling
- State management
- User feedback
- Profile management

## Next Steps

1. **Test the complete flow** using the demo screen
2. **Update your backend** to match the expected API format
3. **Integrate with your existing screens** using the updated AuthProvider
4. **Add profile completion steps** (emergency contact, gender detection, payment)
5. **Implement additional features** like profile photo upload and gender verification

## Support

For issues or questions about this integration:
1. Check the console logs for error details
2. Verify network connectivity
3. Test API endpoints independently
4. Review the AuthProvider state transitions
