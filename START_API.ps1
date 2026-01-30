# Start Tithandizane Helpline API
# Simple script to start the backend API

Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Starting Tithandizane Helpline API" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Get local IP address
$ip = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Wi-Fi*","Ethernet*" | Where-Object {$_.IPAddress -notlike "169.*"} | Select-Object -First 1).IPAddress

if ($ip) {
    Write-Host "✅ Your Computer IP: $ip" -ForegroundColor Green
    Write-Host ""
    Write-Host "Apps should connect to: http://${ip}:8080" -ForegroundColor Yellow
    Write-Host ""
} else {
    Write-Host "⚠️  Could not detect IP address" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "Starting API server on port 8080..." -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Gray
Write-Host ""
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Change to API directory and start server
Set-Location -Path "$PSScriptRoot\python_api"
.\venv\Scripts\python.exe -m uvicorn main:app --reload --host 0.0.0.0 --port 8080
