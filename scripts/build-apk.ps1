param(
    [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

$ErrorActionPreference = "Stop"

Write-Host "==> Flutter 2048 Release APK Build" -ForegroundColor Cyan
Write-Host "ProjectRoot: $ProjectRoot"

Set-Location $ProjectRoot

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw "flutter command not found. Please add Flutter bin to PATH."
}

$defaultAndroidSdk = "C:\runtime\android-sdk"
$defaultJbr = "C:\Program Files\Android\Android Studio\jbr"

if ([string]::IsNullOrWhiteSpace($env:ANDROID_HOME) -or -not (Test-Path $env:ANDROID_HOME)) {
    if (Test-Path $defaultAndroidSdk) {
        $env:ANDROID_HOME = $defaultAndroidSdk
    }
}
if ([string]::IsNullOrWhiteSpace($env:ANDROID_SDK_ROOT) -or -not (Test-Path $env:ANDROID_SDK_ROOT)) {
    if (Test-Path $defaultAndroidSdk) {
        $env:ANDROID_SDK_ROOT = $defaultAndroidSdk
    }
}
if ([string]::IsNullOrWhiteSpace($env:JAVA_HOME) -or -not (Test-Path $env:JAVA_HOME)) {
    if (Test-Path $defaultJbr) {
        $env:JAVA_HOME = $defaultJbr
    }
}

Write-Host "==> Toolchain"
flutter --version

Write-Host "==> Environment"
Write-Host "ANDROID_HOME=$env:ANDROID_HOME"
Write-Host "ANDROID_SDK_ROOT=$env:ANDROID_SDK_ROOT"
Write-Host "JAVA_HOME=$env:JAVA_HOME"

if (Test-Path ".\android\gradlew.bat") {
    Write-Host "==> Stop Gradle daemons"
    Set-Location ".\android"
    .\gradlew.bat --stop | Out-Host
    Set-Location $ProjectRoot
}

Write-Host "==> flutter clean"
flutter clean

Write-Host "==> flutter pub get"
flutter pub get

Write-Host "==> flutter build apk --release"
flutter build apk --release

$apkPath = Join-Path $ProjectRoot "build\app\outputs\flutter-apk\app-release.apk"
if (Test-Path $apkPath) {
    $distDir = Join-Path $ProjectRoot "dist"
    if (-not (Test-Path $distDir)) {
        New-Item -ItemType Directory -Path $distDir | Out-Null
    }
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $distApk = Join-Path $distDir "minimal-2048-release-$timestamp.apk"
    Copy-Item -Path $apkPath -Destination $distApk -Force

    Write-Host "Build succeeded." -ForegroundColor Green
    Write-Host "APK (original): $apkPath" -ForegroundColor Green
    Write-Host "APK (dist): $distApk" -ForegroundColor Green
} else {
    throw "Build completed but APK not found at expected path: $apkPath"
}
