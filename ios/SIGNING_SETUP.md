# iOS Code Signing Setup Guide

## Prerequisites

1. Apple Developer Account (required for production builds)
2. Xcode installed on macOS
3. Valid provisioning profiles and certificates

## Setup Steps

### 1. Open Project in Xcode

```bash
open ios/Runner.xcworkspace
```

### 2. Configure Signing & Capabilities

1. Select the **Runner** project in the navigator
2. Select the **Runner** target
3. Go to **Signing & Capabilities** tab
4. Check **Automatically manage signing**
5. Select your **Team** from the dropdown
6. Xcode will automatically generate provisioning profiles

### 3. For Manual Signing (if needed)

If you prefer manual signing:

1. Uncheck **Automatically manage signing**
2. Select your **Provisioning Profile**
3. Select your **Signing Certificate**

### 4. Update Bundle Identifier

The bundle identifier is currently set to: `com.scasa.scasaFlutterApp`

To change it:
1. Select **Runner** target
2. Go to **General** tab
3. Update **Bundle Identifier** if needed

### 5. Build for Release

```bash
flutter build ios --release
```

### 6. Archive for App Store

1. Open Xcode
2. Select **Product > Archive**
3. Once archived, use **Distribute App** to upload to App Store Connect

## Important Notes

- Code signing must be done on macOS
- You need an active Apple Developer Program membership ($99/year)
- Provisioning profiles expire and need to be renewed
- TestFlight requires proper code signing setup

## Troubleshooting

### Common Issues

1. **"No signing certificate found"**
   - Go to Xcode > Preferences > Accounts
   - Add your Apple ID
   - Download certificates

2. **"Provisioning profile doesn't match"**
   - Update bundle identifier to match your App ID
   - Regenerate provisioning profile

3. **"Code signing is required"**
   - Ensure you're using a physical device or have proper provisioning for simulator
   - Check that your developer account is active

