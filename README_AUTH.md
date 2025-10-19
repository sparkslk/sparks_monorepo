# Sparks Mobile App - Authentication Setup

This mobile app is designed to work with the Sparks Next.js backend. Follow these steps to set up authentication.

## Backend Setup

1. **Start your Next.js backend server:**
   ```bash
   cd sparks-nextjs
   npm run dev
   ```
   The backend should be running on `http://localhost:3000`

2. **Update the mobile app's `.env` file:**
   ```
   API_BASE_URL=http://localhost:3000
   ENVIRONMENT=development
   ```

## Mobile App Features

### 1. Email/Password Authentication
- **Login**: Uses your backend's NextAuth credentials provider
- **Signup**: Creates new users with roles (NORMAL_USER, PARENT_GUARDIAN, THERAPIST)
- **Password Requirements**: Minimum 8 characters

### 2. Google Sign-In (Optional - Not Implemented Yet)
- **Status**: Placeholder implementation
- **TODO**: Requires proper Google OAuth setup and integration
- **Current Behavior**: Shows "not implemented" message to users

### 3. User Roles
The signup form includes role selection:
- **Normal User**: Regular app user
- **Parent/Guardian**: For parents managing children
- **Therapist**: For healthcare providers

## Google Sign-In Setup (Optional)

To enable Google Sign-In, you need to:

1. **Get Google OAuth credentials:**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a project or select existing one
   - Enable Google Sign-In API
   - Create OAuth 2.0 credentials

2. **Configure Android (if testing on Android):**
   Add your SHA-1 fingerprint to Google Cloud Console:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

3. **Update environment variables:**
   Add your web client ID to `.env`:
   ```
   GOOGLE_WEB_CLIENT_ID=your-web-client-id.googleusercontent.com
   ```

## API Endpoints Used

The mobile app connects to these backend endpoints:

- `POST /api/auth/callback/credentials` - Email/password login
- `POST /api/auth/signup` - User registration
- `POST /api/auth/signin/google` - Google sign-in
- `POST /api/auth/signout` - Logout
- `GET /api/profile` - User profile data

## Testing

1. **Start the backend:**
   ```bash
   cd sparks-nextjs
   npm run dev
   ```

2. **Run the mobile app:**
   ```bash
   cd Sparks_Mobile
   flutter run
   ```

3. **Test scenarios:**
   - Create a new account with different roles
   - Login with existing credentials
   - Test Google Sign-In (if configured)
   - Verify logout functionality

## Security Features

- **Secure Storage**: User tokens stored using Flutter Secure Storage
- **Session Management**: Automatic token handling for API requests
- **Environment Configuration**: Separate development and production URLs

## Troubleshooting

### Common Issues:

1. **Connection errors**: Ensure backend is running on correct port
2. **CORS issues**: Your NextAuth configuration should handle mobile requests
3. **Google Sign-In errors**: Verify OAuth configuration and SHA-1 fingerprints

### Debug Mode:
The app includes debug logging for development. Check the console output for API response details.

## Next Steps

1. Configure your production backend URL in `.env`
2. Set up proper Google OAuth credentials
3. Test the authentication flow
4. Add additional API endpoints as needed
5. Implement role-based navigation and features

## File Structure

```
lib/
├── services/
│   ├── api_service.dart          # Main API service
│   ├── api_config.dart           # Configuration
│   ├── auth_provider.dart        # Authentication state management
│   └── google_signin_service.dart # Google Sign-In integration
├── screens/
│   └── welcome/
│       ├── login_screen.dart     # Login UI
│       ├── signup_screen.dart    # Registration UI
│       └── ...
└── main.dart                     # App entry point
```

The authentication system is now ready to work with your existing Next.js backend!
