# Restart API on Port 6000
Write-Host "`n🔧 Restarting Tithandizane API..." -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Yellow

# Find process using port 6000
Write-Host "`n1. Checking port 8080..." -ForegroundColor Yellow
$process = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -First 1

if ($process) {
    Write-Host "   Found process: $process" -ForegroundColor White
    Write-Host "   Stopping old API process..." -ForegroundColor Yellow
    try {
        Stop-Process -Id $process -Force
        Start-Sleep -Seconds 2
        Write-Host "   ✅ Old process stopped" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠️  Could not stop process. Please run PowerShell as Administrator" -ForegroundColor Red
        Write-Host "   Or manually close the old API window" -ForegroundColor Yellow
        pause
    }
} else {
    Write-Host "   ✅ Port 6000 is free" -ForegroundColor Green
}

# Start API
Write-Host "`n2. Starting API server..." -ForegroundColor Yellow
Set-Location "D:\Projects\yomehe\python_api"

Write-Host "`n" -NoNewline
Write-Host "🚀 API Starting on http://0.0.0.0:6000" -ForegroundColor Green
Write-Host "   Docs: http://localhost:8080/docs" -ForegroundColor Cyan
Write-Host "`n" + "=" * 60 -ForegroundColor Yellow
Write-Host ""

# Use python3.13 explicitly
.\venv\Scripts\python.exe -m uvicorn main:app --reload --host 0.0.0.0 --port 8080
