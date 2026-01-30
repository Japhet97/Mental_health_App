# YONECO Mobile Build Setup Script
# This script automates the process of building APKs for mobile devices

Write-Host "=== YONECO Mobile Build Setup ===" -ForegroundColor Green
Write-Host ""

# Step 1: Get PC IP Address
Write-Host "Step 1: Finding your PC's IP address..." -ForegroundColor Cyan
$ipAddress = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Wi-Fi*" | Where-Object {$_.IPAddress -notlike "169.*"} | Select-Object -First 1).IPAddress

if (-not $ipAddress) {
    $ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.*"} | Select-Object -First 1).IPAddress
}

Write-Host "Your PC IP Address: $ipAddress" -ForegroundColor Yellow
Write-Host ""

# Ask user to confirm or enter custom IP
$useIP = Read-Host "Use this IP address? (Y/N)"
if ($useIP -eq "N" -or $useIP -eq "n") {
    $ipAddress = Read-Host "Enter your PC's IP address"
}

$apiUrl = "http://${ipAddress}:8080"
Write-Host "API URL will be: $apiUrl" -ForegroundColor Green
Write-Host ""

# Step 2: Update Client App Config
Write-Host "Step 2: Updating Client App configuration..." -ForegroundColor Cyan
$clientConfigPath = "yoneco_app\lib\config\app_config.dart"
$clientConfig = @"
class AppConfig {
  // API Configuration
  // Updated for mobile network access
  // Current PC IP: $ipAddress
  
  static const String apiBaseUrl = "$apiUrl";
  
  // WebSocket Configuration
  static const String wsScheme = "ws";
  
  static String get httpUrl => apiBaseUrl;
  
  static String get wsBaseUrl => apiBaseUrl.replaceFirst("http", wsScheme);
  
  static String getWebSocketUrl(int sessionId, String token) {
    return "`$wsBaseUrl/ws/session/`$sessionId?token=`$token";
  }
}
"@
Set-Content -Path $clientConfigPath -Value $clientConfig
Write-Host "✓ Client app configured" -ForegroundColor Green
Write-Host ""

# Step 3: Update Counsellor App Config
Write-Host "Step 3: Updating Counsellor App configuration..." -ForegroundColor Cyan
$counsellorConfigPath = "yoneco_counsellor_app\lib\config\app_config.dart"
$counsellorConfig = @"
class AppConfig {
  // API Configuration
  // Updated for mobile network access
  // Current PC IP: $ipAddress
  
  static const String apiBaseUrl = "$apiUrl";
  
  // WebSocket Configuration
  static const String wsScheme = "ws";
  
  static String get httpUrl => apiBaseUrl;
  
  static String get wsBaseUrl => apiBaseUrl.replaceFirst("http", wsScheme);
  
  static String getCounsellorWebSocketUrl(String token) {
    return "`$wsBaseUrl/ws/counselors?token=`$token";
  }
  
  static String getSessionWebSocketUrl(int sessionId, String token) {
    return "`$wsBaseUrl/ws/session/`$sessionId?token=`$token";
  }
}
"@
Set-Content -Path $counsellorConfigPath -Value $counsellorConfig
Write-Host "✓ Counsellor app configured" -ForegroundColor Green
Write-Host ""

# Step 4: Configure Windows Firewall
Write-Host "Step 4: Configuring Windows Firewall..." -ForegroundColor Cyan
Write-Host "Checking if firewall rule exists..." -ForegroundColor Yellow

try {
    $existingRule = Get-NetFirewallRule -DisplayName "YONECO API" -ErrorAction SilentlyContinue
    if ($existingRule) {
        Write-Host "Firewall rule already exists" -ForegroundColor Yellow
    } else {
        Write-Host "Creating firewall rule (requires admin)..." -ForegroundColor Yellow
        New-NetFirewallRule -DisplayName "YONECO API" -Direction Inbound -Protocol TCP -LocalPort 8080 -Action Allow -ErrorAction Stop
        Write-Host "✓ Firewall rule created" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠ Could not create firewall rule. Please run as Administrator or manually allow port 8080" -ForegroundColor Red
}
Write-Host ""

# Step 5: Build APKs
$buildApps = Read-Host "Build APKs now? (Y/N)"
if ($buildApps -eq "Y" -or $buildApps -eq "y") {
    # Build Client App
    Write-Host "Step 5a: Building Client App..." -ForegroundColor Cyan
    Set-Location "yoneco_app"
    Write-Host "Cleaning..." -ForegroundColor Yellow
    flutter clean | Out-Null
    Write-Host "Getting dependencies..." -ForegroundColor Yellow
    flutter pub get
    Write-Host "Building APK (this may take several minutes)..." -ForegroundColor Yellow
    flutter build apk --release
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Client App built successfully!" -ForegroundColor Green
        Write-Host "APK Location: yoneco_app\build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Yellow
    } else {
        Write-Host "✗ Client App build failed" -ForegroundColor Red
    }
    Write-Host ""
    
    Set-Location ".."
    
    # Build Counsellor App
    Write-Host "Step 5b: Building Counsellor App..." -ForegroundColor Cyan
    Set-Location "yoneco_counsellor_app"
    Write-Host "Cleaning..." -ForegroundColor Yellow
    flutter clean | Out-Null
    Write-Host "Getting dependencies..." -ForegroundColor Yellow
    flutter pub get
    Write-Host "Building APK (this may take several minutes)..." -ForegroundColor Yellow
    flutter build apk --release
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Counsellor App built successfully!" -ForegroundColor Green
        Write-Host "APK Location: yoneco_counsellor_app\build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Yellow
    } else {
        Write-Host "✗ Counsellor App build failed" -ForegroundColor Red
    }
    Write-Host ""
    
    Set-Location ".."
}

# Summary
Write-Host ""
Write-Host "=== Setup Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Start the API:" -ForegroundColor White
Write-Host "   cd python_api" -ForegroundColor Gray
Write-Host "   python -m uvicorn main:app --host 0.0.0.0 --port 8080 --reload" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Install APKs on your Android device:" -ForegroundColor White
Write-Host "   - Client App: yoneco_app\build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Gray
Write-Host "   - Counsellor App: yoneco_counsellor_app\build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Test API connection from mobile browser:" -ForegroundColor White
Write-Host "   Visit: $apiUrl/docs" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Make sure all devices are on the same WiFi network!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Test Credentials:" -ForegroundColor Cyan
Write-Host "  Counsellor:" -ForegroundColor White
Write-Host "    Email: dr.smith@yoneco.org" -ForegroundColor Gray
Write-Host "    Password: password123" -ForegroundColor Gray
Write-Host ""
Write-Host "For detailed instructions, see MOBILE_BUILD_GUIDE.md" -ForegroundColor Yellow
Write-Host ""
