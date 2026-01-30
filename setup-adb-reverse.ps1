# ADB Reverse Setup for YONECO Apps
# This bypasses all network/firewall issues by using USB connection

Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  📱 ADB REVERSE SETUP (USB Method)" -ForegroundColor Yellow
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Write-Host "This method uses USB instead of Wi-Fi - GUARANTEED TO WORK!" -ForegroundColor Green
Write-Host ""

# Check if ADB is available
Write-Host "1️⃣  Checking for ADB..." -ForegroundColor Cyan
$adbPath = where.exe adb 2>$null
if ($adbPath) {
    Write-Host "   ✅ ADB found: $adbPath" -ForegroundColor Green
} else {
    Write-Host "   ❌ ADB not found in PATH" -ForegroundColor Red
    Write-Host "   Looking in Flutter SDK..." -ForegroundColor Yellow
    
    $flutterPath = where.exe flutter 2>$null
    if ($flutterPath) {
        $flutterDir = Split-Path -Parent $flutterPath
        $adbPath = Join-Path $flutterDir "..\bin\cache\artifacts\engine\android-arm-release\adb.exe"
        if (Test-Path $adbPath) {
            Write-Host "   ✅ Found ADB in Flutter: $adbPath" -ForegroundColor Green
        }
    }
    
    if (-not $adbPath -or -not (Test-Path $adbPath)) {
        Write-Host ""
        Write-Host "   ADB not found! Install it:" -ForegroundColor Red
        Write-Host "   1. Download Android Platform Tools from:" -ForegroundColor White
        Write-Host "      https://developer.android.com/studio/releases/platform-tools" -ForegroundColor Cyan
        Write-Host "   2. Extract to C:\platform-tools" -ForegroundColor White
        Write-Host "   3. Run: setx PATH `"`$env:PATH;C:\platform-tools`"" -ForegroundColor White
        Write-Host ""
        pause
        exit 1
    }
}
Write-Host ""

# Check devices
Write-Host "2️⃣  Checking for connected devices..." -ForegroundColor Cyan
& $adbPath devices
Write-Host ""

Write-Host "If no device listed:" -ForegroundColor Yellow
Write-Host "  1. Connect phone via USB" -ForegroundColor White
Write-Host "  2. Enable USB debugging on phone" -ForegroundColor White
Write-Host "  3. Accept the authorization popup on phone" -ForegroundColor White
Write-Host ""
$continue = Read-Host "Device connected? (y/n)"
if ($continue -ne 'y') {
    Write-Host "Connect device and run this script again" -ForegroundColor Yellow
    pause
    exit 0
}
Write-Host ""

# Setup port forwarding
Write-Host "3️⃣  Setting up ADB reverse for port 8001..." -ForegroundColor Cyan
& $adbPath reverse tcp:8001 tcp:8001
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Port 8001 forwarded successfully!" -ForegroundColor Green
} else {
    Write-Host "   ❌ Failed to setup port forwarding" -ForegroundColor Red
    pause
    exit 1
}
Write-Host ""

Write-Host "4️⃣  Setting up ADB reverse for port 5173 (web)..." -ForegroundColor Cyan
& $adbPath reverse tcp:5173 tcp:5173
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Port 5173 forwarded successfully!" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Port 5173 forwarding failed (web app may not work)" -ForegroundColor Yellow
}
Write-Host ""

# List current reverse forwards
Write-Host "5️⃣  Verifying reverse forwards..." -ForegroundColor Cyan
& $adbPath reverse --list
Write-Host ""

Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  ✅ ADB REVERSE SETUP COMPLETE!" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Write-Host "📝 IMPORTANT NEXT STEPS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "The app configs are ALREADY set to use localhost!" -ForegroundColor Green
Write-Host "Just run the Flutter app now:" -ForegroundColor White
Write-Host ""
Write-Host "For Client App:" -ForegroundColor Cyan
Write-Host "  cd D:\Projects\yomehe\yoneco_app" -ForegroundColor White
Write-Host "  flutter run" -ForegroundColor White
Write-Host ""
Write-Host "For Counsellor App:" -ForegroundColor Cyan
Write-Host "  cd D:\Projects\yomehe\yoneco_counsellor_app" -ForegroundColor White
Write-Host "  flutter run" -ForegroundColor White
Write-Host ""

Write-Host "⚠️  KEEP USB CONNECTED while using the app!" -ForegroundColor Yellow
Write-Host ""
Write-Host "To remove port forwarding later:" -ForegroundColor Gray
Write-Host "  adb reverse --remove-all" -ForegroundColor Gray
Write-Host ""

pause
