# SCASA Flutter App - Deployment Guide

This guide covers the steps required to deploy the SCASA Flutter app to production.

## Prerequisites

- Flutter SDK 3.10.0 or higher
- Android Studio / Xcode (for mobile builds)
- Apple Developer Account (for iOS)
- Google Play Console account (for Android)
- Firebase project (for analytics and crash reporting)
- Supabase project with production credentials

## Environment Setup

### 1. Environment Variables

Create a `.env` file in the root directory:

```bash
cp .env.example .env
```

Edit `.env` with your production values:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-production-anon-key
ENVIRONMENT=production
SENTRY_DSN=your-sentry-dsn (optional)
```

### 2. Android Keystore Setup

1. Generate a keystore:
   ```bash
   keytool -genkey -v -keystore ~/scasa-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias scasa-key
   ```

2. Create `android/key.properties`:
   ```properties
   storePassword=your-keystore-password
   keyPassword=your-key-password
   keyAlias=scasa-key
   storeFile=../scasa-keystore.jks
   ```

3. Move keystore to android directory:
   ```bash
   mv ~/scasa-keystore.jks android/
   ```

See [android/KEYSTORE_SETUP.md](android/KEYSTORE_SETUP.md) for detailed instructions.

### 3. iOS Code Signing

1. Open project in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Configure signing:
   - Select Runner project
   - Go to Signing & Capabilities
   - Select your team
   - Enable "Automatically manage signing"

See [ios/SIGNING_SETUP.md](ios/SIGNING_SETUP.md) for detailed instructions.

## Building for Production

### Android

#### Build APK
```bash
flutter build apk --release
```

#### Build App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS

#### Build for Device
```bash
flutter build ios --release
```

#### Archive for App Store
1. Open Xcode: `open ios/Runner.xcworkspace`
2. Select Product > Archive
3. Distribute App to App Store Connect

### Web

```bash
flutter build web --release
```

Output: `build/web/`

## Deployment Steps

### Android (Google Play Store)

1. **Prepare App Bundle**
   - Build app bundle (see above)
   - Ensure version number is incremented in `pubspec.yaml`

2. **Create Release in Play Console**
   - Go to Google Play Console
   - Select your app
   - Go to Production > Create new release
   - Upload the `.aab` file
   - Add release notes
   - Review and roll out

3. **Testing**
   - Use Internal Testing track first
   - Test on multiple devices
   - Verify all features work

### iOS (App Store)

1. **Prepare Archive**
   - Build and archive in Xcode
   - Ensure version number is incremented

2. **Upload to App Store Connect**
   - Use Xcode Organizer or Transporter
   - Wait for processing to complete

3. **Submit for Review**
   - Go to App Store Connect
   - Fill in app information
   - Submit for review

### Web Deployment

1. **Build Web App**
   ```bash
   flutter build web --release
   ```

2. **Deploy to Hosting**
   - Firebase Hosting:
     ```bash
     firebase deploy --only hosting
     ```
   - Netlify/Vercel:
     - Connect repository
     - Set build command: `flutter build web --release`
     - Set publish directory: `build/web`

## Post-Deployment Checklist

- [ ] Verify app works on production environment
- [ ] Check analytics are tracking correctly
- [ ] Verify crash reporting is working
- [ ] Test all critical user flows
- [ ] Monitor error logs
- [ ] Check app performance metrics
- [ ] Verify push notifications (if applicable)
- [ ] Test on multiple devices/OS versions

## Monitoring

### Analytics
- Check Firebase Analytics dashboard for user behavior
- Monitor key events and conversions

### Crash Reporting
- Monitor Sentry dashboard for crashes and errors
- Set up alerts for critical issues

### Performance
- Monitor app performance metrics
- Check for memory leaks
- Monitor API response times

## Rollback Procedure

If issues are detected:

1. **Android**
   - Create new release with previous version
   - Upload and roll out immediately

2. **iOS**
   - Submit expedited review request if critical
   - Or wait for standard review process

3. **Web**
   - Revert to previous deployment
   - Or deploy hotfix immediately

## Troubleshooting

### Common Issues

1. **Build fails with signing errors**
   - Verify keystore configuration
   - Check key.properties file

2. **iOS build fails**
   - Verify code signing setup
   - Check provisioning profiles

3. **Environment variables not loading**
   - Ensure .env file exists
   - Check .env is in .gitignore
   - Verify AppConfig.load() is called

4. **Analytics not working**
   - Verify Firebase is initialized
   - Check Firebase configuration files

## Support

For issues or questions:
- Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- Review [ARCHITECTURE.md](ARCHITECTURE.md)
- Contact development team

