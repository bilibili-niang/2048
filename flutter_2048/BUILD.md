# 极简数字 2048 - 构建与发布

本文档说明本项目的常见运行与打包方式。

## 1. 本地调试

项目目录：

```powershell
cd D:\flutter\flutter_2048
```

安装依赖：

```powershell
flutter pub get
```

Windows 调试运行：

```powershell
flutter run -d windows
```

Android 调试运行：

```powershell
flutter run -d android
```

## 2. Release APK 打包

### 方式 A：一键脚本（推荐）

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build-apk.ps1
```

### 方式 B：手动命令

```powershell
flutter clean
flutter pub get
flutter build apk --release
```

产物默认位置：

- `build\app\outputs\flutter-apk\app-release.apk`

## 3. Android 签名配置（上架必需）

项目已支持读取 `android/key.properties` 自动进行 release 签名。

步骤：

1. 复制模板：
   - `android/key.properties.example` -> `android/key.properties`
2. 填写你自己的 keystore 信息：
   - `storeFile`
   - `storePassword`
   - `keyAlias`
   - `keyPassword`

注意：

- 若 `android/key.properties` 不存在或字段不全，会自动回退到 debug 签名，仅用于开发测试，不可用于 Google Play 正式发布。

## 4. CI 流程

仓库包含 `.github/workflows/flutter-ci.yml`，默认在 push / PR 时执行：

- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter build apk --release`

## 5. 常见故障处理

### Kotlin incremental cache 相关异常

项目已在 `android/gradle.properties` 中加入稳定性设置：

- `kotlin.incremental=false`
- `kotlin.compiler.execution.strategy=in-process`

若仍遇到缓存/守护进程问题，可执行：

```powershell
cd android
.\gradlew --stop
cd ..
flutter clean
flutter pub get
flutter build apk --release
```

### 识别不到 flutter 命令

- 检查 Flutter `bin` 是否已加入用户 `Path`
- 关闭并重新打开终端
- 在新终端执行 `flutter --version` 验证
