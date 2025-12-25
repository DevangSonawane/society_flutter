# SCASA Flutter App - Troubleshooting Guide

## Common Issues and Solutions

### Build Issues

#### Android Build Fails

**Issue**: Build fails with signing errors

**Solution**:
1. Verify `android/key.properties` exists and is correctly configured
2. Ensure keystore file exists at the path specified
3. Check keystore passwords are correct
4. Verify keystore alias matches configuration

**Issue**: Gradle sync fails

**Solution**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

#### iOS Build Fails

**Issue**: Code signing errors

**Solution**:
1. Open project in Xcode: `open ios/Runner.xcworkspace`
2. Select Runner target
3. Go to Signing & Capabilities
4. Select your team
5. Enable "Automatically manage signing"

**Issue**: Pod install fails

**Solution**:
```bash
cd ios
pod deintegrate
pod install
cd ..
```

### Runtime Issues

#### App Crashes on Startup

**Issue**: Environment variables not loaded

**Solution**:
1. Ensure `.env` file exists in root directory
2. Verify `AppConfig.load()` is called in `main.dart`
3. Check `.env` file format is correct
4. Ensure `.env` is in assets in `pubspec.yaml`

**Issue**: Supabase initialization fails

**Solution**:
1. Verify `SUPABASE_URL` and `SUPABASE_ANON_KEY` in `.env`
2. Check internet connection
3. Verify Supabase project is active
4. Check Supabase dashboard for service status

#### Navigation Issues

**Issue**: White screen after navigation

**Solution**:
1. Check route is registered in `main.dart`
2. Verify screen widget is properly implemented
3. Check for errors in console
4. Ensure `MainScaffold` is handling the route correctly

**Issue**: Drawer doesn't open

**Solution**:
1. Verify `ScaffoldState` key is set
2. Check drawer widget is properly configured
3. Ensure touch events are not blocked

### Data Issues

#### Data Not Loading

**Issue**: API calls fail

**Solution**:
1. Check internet connection
2. Verify Supabase credentials
3. Check RLS policies in Supabase
4. Review error logs in console
5. Check Supabase dashboard for API errors

**Issue**: Cache not working

**Solution**:
1. Verify Hive is initialized: `await HiveService.initialize()`
2. Check cache service is being used
3. Verify cache keys are correct
4. Clear cache and retry: `await CacheService.clearAllCache()`

#### Offline Sync Issues

**Issue**: Changes not syncing

**Solution**:
1. Check sync queue: `await SyncService.getSyncStatus()`
2. Manually trigger sync: `await SyncService.processSyncQueue()`
3. Verify network connection
4. Check sync queue for failed items

### Authentication Issues

#### Login Fails

**Issue**: Invalid credentials error

**Solution**:
1. Verify email/password are correct
2. Check user exists in Supabase Auth
3. Verify email is confirmed (if email confirmation is enabled)
4. Check Supabase Auth settings

**Issue**: Session not persisting

**Solution**:
1. Verify `_restoreSession()` is called in `AuthNotifier`
2. Check secure storage is working
3. Verify Supabase session is valid
4. Check for logout calls

### Performance Issues

#### App is Slow

**Solution**:
1. Check for unnecessary rebuilds
2. Verify images are optimized
3. Check for memory leaks
4. Review performance metrics
5. Use Flutter DevTools for profiling

#### High Memory Usage

**Solution**:
1. Check for image caching issues
2. Verify lists are using `ListView.builder`
3. Check for memory leaks in providers
4. Review cached data size

### Testing Issues

#### Tests Fail

**Issue**: Mock setup issues

**Solution**:
1. Run `flutter pub run build_runner build` to generate mocks
2. Verify mock setup is correct
3. Check test dependencies are added
4. Ensure test helpers are imported

**Issue**: Integration tests fail

**Solution**:
1. Verify integration test setup
2. Check test device/emulator is running
3. Ensure app is built: `flutter build apk --debug`
4. Check test timeout settings

### Environment Issues

#### Environment Variables Not Working

**Solution**:
1. Ensure `.env` file exists
2. Verify `flutter_dotenv` is in dependencies
3. Check `.env` is in assets
4. Verify `AppConfig.load()` is called before use
5. Restart app after changing `.env`

#### Different Behavior in Production

**Solution**:
1. Check `ENVIRONMENT` variable is set correctly
2. Verify production credentials are used
3. Check feature flags
4. Review environment-specific code paths

## Debugging Tips

### Enable Debug Logging

Set log level in `LoggerService`:
```dart
LoggerService.debug('Debug message');
LoggerService.info('Info message');
LoggerService.warning('Warning message');
LoggerService.error('Error message', error, stackTrace);
```

### Check Logs

- **Development**: Check console output
- **Production**: Check Sentry dashboard
- **Analytics**: Check Firebase Analytics

### Use Flutter DevTools

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### Network Debugging

Use Supabase dashboard to:
- View API requests
- Check database queries
- Monitor real-time subscriptions
- Review error logs

## Getting Help

1. Check this troubleshooting guide
2. Review [ARCHITECTURE.md](ARCHITECTURE.md) for system overview
3. Check [API_DOCUMENTATION.md](API_DOCUMENTATION.md) for API issues
4. Review error logs in Sentry
5. Contact development team

## Reporting Issues

When reporting issues, include:
- Flutter version: `flutter --version`
- Device/OS information
- Steps to reproduce
- Error messages/logs
- Screenshots (if applicable)
- Expected vs actual behavior

