<<<<<<< HEAD
# Balik Kampung Mode — updated Flutter source

## Apply to your existing project
1. Make a backup of your current project folder.
2. Replace your existing `lib/main.dart` with the `lib/main.dart` in this package.
3. Keep your existing `android/` and `ios/` folders. They are generated platform scaffolding and are not replaced by this source update.
4. In the project root, run:

```powershell
flutter clean
flutter pub get
flutter analyze
flutter run -d chrome
```

The bottom navigation places **Profile at the far right**. The sign-in action is labelled **Sign In**. Visible occurrences of the words requested for removal have been removed.

## Important
This package includes the updated Dart source, pubspec, and web files. It does not include Android/iOS generated platform folders because those already exist in your local project and should be preserved.

The app uses local prototype authentication and in-memory app state; it is not connected to a production authentication server or real IoT hardware. Do not treat illustrative readings as live sensor measurements.

The source has not been compiled in this environment because the Flutter/Dart SDK is unavailable here. Run `flutter analyze` and `flutter run -d chrome` on your Windows machine to verify it in your installed Flutter environment.
=======
# Balik_Kampung_Mode_Application
Flutter application for Balik Kampung Mode – ENT600 NPD Project
>>>>>>> 0ac6034efb6e76c225e4db31b8c03c8407caff2b
