# Repo Notes

- Primary app lives in `flutter_2048/`. Run Flutter commands from that directory, not the repo root.
- Root `README.md` is accurate about scope: this repo's active product is the Flutter 2048 app, with Android as the main target. `.docs/05-09/` holds product/release notes, not executable app config.

# Commands

- Install deps: `flutter pub get`
- Run locally: `flutter run`
- Analyze: `flutter analyze`
- Run the current test file only: `flutter test test/widget_test.dart`
- Release APK: `flutter build apk --release`

# Structure

- App entrypoint is `flutter_2048/lib/main.dart`; it wires `ThemeProvider` and `GameProvider` via `MultiProvider`.
- Game logic and persistence live in `flutter_2048/lib/providers/game_provider.dart`.
- Theme persistence lives in `flutter_2048/lib/providers/theme_provider.dart`.
- UI is split between `flutter_2048/lib/screens/` and `flutter_2048/lib/components/`.

# Verified Quirks

- `GameProvider` loads `SharedPreferences` asynchronously in its constructor, then calls `initGame()`. On the first frame, `grid` can still be empty; guard UI/tests that index into `grid` until initialization completes.
- `flutter analyze` is currently not clean: `flutter_2048/analysis_options.yaml` includes `package:flutter_lints/flutter.yaml`, but `flutter_lints` is not in `dev_dependencies`.
- `flutter test test/widget_test.dart` currently fails and is stale. It still expects Flutter's default counter app and also triggers the empty-grid startup issue, so do not treat that failure as a regression unless you changed startup/test behavior.
- Persistence keys are repo behavior: `grid_size`, `best_score_<size>`, `vibration_enabled`, and `dark_mode`. Renaming them changes saved user state.
