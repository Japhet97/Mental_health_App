# Add Firewall Rules for Tithandizane Helpline Apps
# Run this as Administrator: Right-click PowerShell -> Run as Administrator

Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Adding Windows Firewall Rules for Tithandizane" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "❌ ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please:" -ForegroundColor Yellow
    Write-Host "1. Right-click PowerShell" -ForegroundColor White
    Write-Host "2. Select 'Run as Administrator'" -ForegroundColor White
    Write-Host "3. Run this script again" -ForegroundColor White
    Write-Host ""
    pause
    exit 1
}

Write-Host "✅ Running as Administrator" -ForegroundColor Green
Write-Host ""

# Remove existing rules if they exist
Write-Host "🔧 Removing old rules (if any)..." -ForegroundColor Cyan
netsh advfirewall firewall delete rule name="Tithandizane API" 2>$null
netsh advfirewall firewall delete rule name="YONECO API" 2>$null
netsh advfirewall firewall delete rule name="YONECO Web" 2>$null
Write-Host ""

# Add API port rule
Write-Host "➕ Adding firewall rule for API (Port 8001)..." -ForegroundColor Cyan
$result = netsh advfirewall firewall add rule name="Tithandizane API" dir=in action=allow protocol=TCP localport=8001
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ API firewall rule added successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to add API firewall rule" -ForegroundColor Red
}
Write-Host ""

# Add Web port rule
Write-Host "➕ Adding firewall rule for Web (Port 5173)..." -ForegroundColor Cyan
$result = netsh advfirewall firewall add rule name="Tithandizane Web" dir=in action=allow protocol=TCP localport=5173
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Web firewall rule added successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to add Web firewall rule" -ForegroundColor Red
}
Write-Host ""

# Verify rules were added
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Verifying Firewall Rules" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Write-Host "Tithandizane API Rule:" -ForegroundColor Cyan
netsh advfirewall firewall show rule name="Tithandizane API"
Write-Host ""

Write-Host "Tithandizane Web Rule:" -ForegroundColor Cyan
netsh advfirewall firewall show rule name="Tithandizane Web"
Write-Host ""

Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  ✅ Firewall Configuration Complete!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Your mobile device should now be able to connect to:" -ForegroundColor Yellow
Write-Host "  • API: http://102.223.95.28:8001" -ForegroundColor White
Write-Host "  • Web: http://102.223.95.28:5173" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Make sure API is running (port 8001)" -ForegroundColor White
Write-Host "2. Connect your phone to the same Wi-Fi" -ForegroundColor White
Write-Host "3. Run the Flutter app with: flutter run" -ForegroundColor White
Write-Host ""

pause
