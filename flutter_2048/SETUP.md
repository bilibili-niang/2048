# 极简数字 2048 - 开发环境搭建

本文档用于在 Windows 上快速完成 Flutter 2048 项目的本地开发环境配置。

## 1. 推荐版本

- Flutter SDK: `3.41.9-stable`（已在当前项目验证）
- Dart SDK: 随 Flutter SDK 自带（当前约 `3.11.x`）
- Android SDK: `C:\runtime\android-sdk`
- JDK: Android Studio 自带 JBR（推荐）
  - `C:\Program Files\Android\Android Studio\jbr`

## 2. 环境变量（用户级）

建议使用用户级变量，便于多项目复用。

- `ANDROID_HOME=C:\runtime\android-sdk`
- `ANDROID_SDK_ROOT=C:\runtime\android-sdk`
- `Path` 追加 Flutter：
  - `C:\runtime\flutter_windows_3.41.9-stable\flutter\bin`

提示：若在新开的 `cmd` / PowerShell 仍识别不到 `flutter`，重开终端或注销后再试。

## 3. 项目本地配置

项目路径：`D:\flutter\flutter_2048`

Android 本地 SDK 映射（已提交）：

- 文件：`android/local.properties`
- 关键项：`sdk.dir=C:\\runtime\\android-sdk`

## 4. 首次初始化

在项目根目录执行：

```powershell
flutter doctor -v
flutter pub get
flutter doctor --android-licenses
```

## 5. 常见检查项

- `flutter doctor -v` 无关键红字错误
- `flutter devices` 能看到目标设备（Windows/Android）
- Android Studio 已安装必需 SDK 组件（platform-tools、build-tools、cmdline-tools）

## 6. 目录建议

建议将可复用运行时统一放在 `C:\runtime`，例如：

- `C:\runtime\flutter_windows_3.41.9-stable`
- `C:\runtime\android-sdk`

这样多个 Flutter 项目可共享同一套 SDK，便于维护和升级。
