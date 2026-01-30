# Quick Mobile Test Script
# Run this to verify everything is configured correctly

Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  📱 YONECO Mobile Connection Test" -ForegroundColor Yellow
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# 1. Check Wi-Fi Connection
Write-Host "1️⃣  Checking Wi-Fi Connection..." -ForegroundColor Cyan
$wifi = Get-NetIPAddress -InterfaceAlias "Wi-Fi 2" -AddressFamily IPv4 -ErrorAction SilentlyContinue
if ($wifi) {
    Write-Host "   ✅ Wi-Fi Connected" -ForegroundColor Green
    Write-Host "   IP: $($wifi.IPAddress)" -ForegroundColor White
    $pcIP = $wifi.IPAddress
} else {
    Write-Host "   ❌ Wi-Fi Not Connected" -ForegroundColor Red
    $pcIP = Read-Host "   Enter your PC's IP address"
}

$wifiInfo = netsh wlan show interfaces | Select-String "SSID" | Select-Object -First 1
Write-Host "   Network: $wifiInfo" -ForegroundColor White
Write-Host ""

# 2. Check if API is running
Write-Host "2️⃣  Checking if API is running on port 8001..." -ForegroundColor Cyan
$apiProcess = netstat -ano | Select-String ":8001" | Select-String "LISTENING"
if ($apiProcess) {
    Write-Host "   ✅ API is running on port 8001" -ForegroundColor Green
} else {
    Write-Host "   ❌ API is NOT running!" -ForegroundColor Red
    Write-Host "   Start it with: cd python_api && python3.13 -m uvicorn main:app --reload --host 0.0.0.0 --port 8001" -ForegroundColor Yellow
}
Write-Host ""

# 3. Test API locally
Write-Host "3️⃣  Testing API from localhost..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8001/health" -TimeoutSec 5
    Write-Host "   ✅ API responds locally: $($response.status)" -ForegroundColor Green
} catch {
    Write-Host "   ❌ API not responding locally" -ForegroundColor Red
}
Write-Host ""

# 4. Test API from network IP
Write-Host "4️⃣  Testing API from network IP ($pcIP)..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "http://${pcIP}:8001/health" -TimeoutSec 5
    Write-Host "   ✅ API responds from network: $($response.status)" -ForegroundColor Green
} catch {
    Write-Host "   ❌ API not accessible from network IP" -ForegroundColor Red
    Write-Host "   This is likely a firewall issue!" -ForegroundColor Yellow
}
Write-Host ""

# 5. Check firewall rules
Write-Host "5️⃣  Checking firewall rules..." -ForegroundColor Cyan
$apiRule = Get-NetFirewallRule -DisplayName "YONECO API" -ErrorAction SilentlyContinue
$webRule = Get-NetFirewallRule -DisplayName "YONECO Web" -ErrorAction SilentlyContinue

if ($apiRule) {
    Write-Host "   ✅ YONECO API firewall rule exists" -ForegroundColor Green
} else {
    Write-Host "   ❌ YONECO API firewall rule NOT found" -ForegroundColor Red
    Write-Host "   Run: add-firewall-rules.ps1 as Administrator" -ForegroundColor Yellow
}

if ($webRule) {
    Write-Host "   ✅ YONECO Web firewall rule exists" -ForegroundColor Green
} else {
    Write-Host "   ❌ YONECO Web firewall rule NOT found" -ForegroundColor Red
}
Write-Host ""

# 6. Test port connectivity
Write-Host "6️⃣  Testing port 8001 connectivity..." -ForegroundColor Cyan
$portTest = Test-NetConnection -ComputerName $pcIP -Port 8001 -WarningAction SilentlyContinue
if ($portTest.TcpTestSucceeded) {
    Write-Host "   ✅ Port 8001 is accessible" -ForegroundColor Green
} else {
    Write-Host "   ❌ Port 8001 is NOT accessible" -ForegroundColor Red
    Write-Host "   Check firewall settings!" -ForegroundColor Yellow
}
Write-Host ""

# 7. Check app configurations
Write-Host "7️⃣  Checking app configurations..." -ForegroundColor Cyan
$clientConfig = Get-Content "D:\Projects\yomehe\yoneco_app\lib\config\app_config.dart" | Select-String "apiBaseUrl"
$counsellorConfig = Get-Content "D:\Projects\yomehe\yoneco_counsellor_app\lib\config\app_config.dart" | Select-String "apiBaseUrl"
$webConfig = Get-Content "D:\Projects\yomehe\yoneco-web\.env" | Select-String "VITE_API_BASE_URL"

Write-Host "   Client App: $clientConfig" -ForegroundColor White
Write-Host "   Counsellor App: $counsellorConfig" -ForegroundColor White
Write-Host "   Web App: $webConfig" -ForegroundColor White

if ($clientConfig -match $pcIP -and $counsellorConfig -match $pcIP -and $webConfig -match $pcIP) {
    Write-Host "   ✅ All configs match PC IP" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Some configs may not match PC IP ($pcIP)" -ForegroundColor Yellow
}
Write-Host ""

# Summary
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  📋 SUMMARY" -ForegroundColor Yellow
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Your PC IP Address: $pcIP" -ForegroundColor White
Write-Host "Wi-Fi Network: Yoneco Wifi" -ForegroundColor White
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Make sure your PHONE is connected to: Yoneco Wifi" -ForegroundColor White
Write-Host ""
Write-Host "2. Open browser on your phone and visit:" -ForegroundColor White
Write-Host "   http://${pcIP}:8001/health" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. If you see {`"status`":`"healthy`"}, run Flutter app:" -ForegroundColor White
Write-Host "   cd yoneco_app && flutter run" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. If browser doesn't work, run as Administrator:" -ForegroundColor White
Write-Host "   .\add-firewall-rules.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

pause
