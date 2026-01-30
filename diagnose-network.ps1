# Complete Network Diagnostic for Mobile Connection
# Run this to identify the exact issue

Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  🔍 COMPLETE NETWORK DIAGNOSTIC" -ForegroundColor Yellow
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Get Wi-Fi IP
$wifiIP = (Get-NetIPAddress -InterfaceAlias "Wi-Fi 2" -AddressFamily IPv4).IPAddress

Write-Host "PC NETWORK CONFIGURATION:" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Wi-Fi IP: $wifiIP" -ForegroundColor White
Write-Host "Network: Yoneco Wifi" -ForegroundColor White
Write-Host "Valid Phone IP Range: 102.223.95.0 - 102.223.95.31" -ForegroundColor White
Write-Host ""

# Check firewall status
Write-Host "FIREWALL STATUS:" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
$firewallProfiles = Get-NetFirewallProfile
foreach ($profile in $firewallProfiles) {
    $status = if ($profile.Enabled) { "ENABLED ❌" } else { "DISABLED ✅" }
    Write-Host "$($profile.Name): $status" -ForegroundColor $(if ($profile.Enabled) { "Red" } else { "Green" })
}
Write-Host ""

# Check network profile (Public/Private)
Write-Host "NETWORK CATEGORY:" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
$netProfile = Get-NetConnectionProfile | Where-Object {$_.Name -eq "Yoneco Wifi"}
if ($netProfile) {
    Write-Host "Category: $($netProfile.NetworkCategory)" -ForegroundColor White
    if ($netProfile.NetworkCategory -eq "Public") {
        Write-Host "⚠️  WARNING: Network is set to Public" -ForegroundColor Yellow
        Write-Host "This may block incoming connections even with firewall off!" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "To fix, run as Administrator:" -ForegroundColor Cyan
        Write-Host "Set-NetConnectionProfile -Name 'Yoneco Wifi' -NetworkCategory Private" -ForegroundColor White
    } else {
        Write-Host "✅ Network category is Private (good)" -ForegroundColor Green
    }
} else {
    Write-Host "Network profile not found" -ForegroundColor Red
}
Write-Host ""

# Check port 8001 listeners
Write-Host "PORT 8001 LISTENERS:" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
$listeners = Get-NetTCPConnection -LocalPort 8001 -State Listen
foreach ($listener in $listeners) {
    $process = Get-Process -Id $listener.OwningProcess -ErrorAction SilentlyContinue
    Write-Host "Address: $($listener.LocalAddress):$($listener.LocalPort)" -ForegroundColor White
    Write-Host "Process: $($process.ProcessName) (PID: $($listener.OwningProcess))" -ForegroundColor White
    Write-Host ""
}

# Test local connectivity
Write-Host "CONNECTIVITY TESTS:" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

Write-Host "1. Testing localhost:8001..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8001/health" -TimeoutSec 3
    Write-Host "   ✅ localhost works: $($response.status)" -ForegroundColor Green
} catch {
    Write-Host "   ❌ localhost failed" -ForegroundColor Red
}

Write-Host "2. Testing 127.0.0.1:8001..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "http://127.0.0.1:8001/health" -TimeoutSec 3
    Write-Host "   ✅ 127.0.0.1 works: $($response.status)" -ForegroundColor Green
} catch {
    Write-Host "   ❌ 127.0.0.1 failed" -ForegroundColor Red
}

Write-Host "3. Testing Wi-Fi IP ($wifiIP):8001..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "http://${wifiIP}:8001/health" -TimeoutSec 3
    Write-Host "   ✅ Wi-Fi IP works: $($response.status)" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Wi-Fi IP failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "4. Testing port connectivity..." -ForegroundColor Cyan
$portTest = Test-NetConnection -ComputerName $wifiIP -Port 8001 -WarningAction SilentlyContinue
if ($portTest.TcpTestSucceeded) {
    Write-Host "   ✅ Port 8001 is reachable" -ForegroundColor Green
} else {
    Write-Host "   ❌ Port 8001 is NOT reachable" -ForegroundColor Red
}
Write-Host ""

# Check for common blocking issues
Write-Host "POTENTIAL BLOCKERS:" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

# Check for VPN
$vpnConnections = Get-VpnConnection -AllUserConnection -ErrorAction SilentlyContinue
if ($vpnConnections | Where-Object {$_.ConnectionStatus -eq "Connected"}) {
    Write-Host "❌ VPN is connected - this may block access" -ForegroundColor Red
} else {
    Write-Host "✅ No active VPN" -ForegroundColor Green
}

# Check for third-party security software
$antivirusProducts = Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntiVirusProduct -ErrorAction SilentlyContinue
if ($antivirusProducts) {
    Write-Host "⚠️  Antivirus/Security software detected:" -ForegroundColor Yellow
    foreach ($av in $antivirusProducts) {
        Write-Host "   - $($av.displayName)" -ForegroundColor White
    }
    Write-Host "These may have their own firewalls!" -ForegroundColor Yellow
} else {
    Write-Host "✅ No third-party security software detected" -ForegroundColor Green
}
Write-Host ""

Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  📱 PHONE TESTING INSTRUCTIONS" -ForegroundColor Yellow
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "CRITICAL CHECKLIST:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Phone connected to: Yoneco Wifi ☐" -ForegroundColor White
Write-Host "2. Phone NOT on mobile data ☐" -ForegroundColor White
Write-Host "3. Phone IP in range: 102.223.95.0 - 102.223.95.31 ☐" -ForegroundColor White
Write-Host "   (Check in phone's Wi-Fi settings)" -ForegroundColor Gray
Write-Host ""

Write-Host "TEST FROM PHONE:" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Open phone browser and visit:" -ForegroundColor White
Write-Host "http://${wifiIP}:8001/health" -ForegroundColor Cyan
Write-Host ""
Write-Host "Expected result:" -ForegroundColor White
Write-Host '{"status":"healthy","service":"yoneco-api"}' -ForegroundColor Green
Write-Host ""

Write-Host "IF BROWSER TEST FAILS:" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "1. Check router settings for AP Isolation (disable it)" -ForegroundColor White
Write-Host "2. Try changing network category to Private (see above)" -ForegroundColor White
Write-Host "3. Try connecting both devices via USB and use ADB reverse:" -ForegroundColor White
Write-Host "   adb reverse tcp:8001 tcp:8001" -ForegroundColor Cyan
Write-Host "   Then use localhost:8001 in app configs" -ForegroundColor Cyan
Write-Host ""

Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

pause
