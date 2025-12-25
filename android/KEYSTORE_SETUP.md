# Android Keystore Setup Guide

## Creating a Keystore

To create a production keystore for signing your Android app, run the following command:

```bash
keytool -genkey -v -keystore ~/scasa-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias scasa-key
```

This will prompt you for:
- A password for the keystore
- A password for the key
- Your name and organization details

## Setting up key.properties

1. Copy the example file:
   ```bash
   cp android/key.properties.example android/key.properties
   ```

2. Edit `android/key.properties` and fill in your actual values:
   ```
   storePassword=your-keystore-password
   keyPassword=your-key-password
   keyAlias=scasa-key
   storeFile=../scasa-keystore.jks
   ```

3. Move your keystore file to the android directory:
   ```bash
   mv ~/scasa-keystore.jks android/
   ```

## Important Notes

- **Never commit** `key.properties` or the keystore file to version control
- Keep backups of your keystore file in a secure location
- If you lose the keystore, you won't be able to update your app on the Play Store
- Store the keystore password securely (use a password manager)

## Building Release APK

After setting up the keystore, you can build a release APK:

```bash
flutter build apk --release
```

Or an App Bundle for Play Store:

```bash
flutter build appbundle --release
```

