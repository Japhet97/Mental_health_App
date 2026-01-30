# YONECO Mobile Configuration Helper
# This script helps you quickly change the API configuration for different platforms

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('web', 'android-emulator', 'ios-simulator', 'physical-device')]
    [string]$Platform,
    
    [Parameter(Mandatory=$false)]
    [string]$IpAddress
)

$clientConfigPath = "D:\Projects\yomehe\yoneco_app\lib\config\app_config.dart"
$counsellorConfigPath = "D:\Projects\yomehe\yoneco_counsellor_app\lib\config\app_config.dart"

function Update-ConfigFile {
    param(
        [string]$FilePath,
        [string]$NewUrl
    )
    
    $content = Get-Content $FilePath -Raw
    $content = $content -replace 'static const String apiBaseUrl = ".*";', "static const String apiBaseUrl = `"$NewUrl`";"
    Set-Content $FilePath -Value $content
    Write-Host "✅ Updated: $FilePath" -ForegroundColor Green
}

Write-Host "`n🔧 YONECO Mobile Configuration Helper`n" -ForegroundColor Cyan

switch ($Platform) {
    'web' {
        $url = "http://localhost:8080"
        Write-Host "📱 Platform: Web Browser" -ForegroundColor Yellow
    }
    'android-emulator' {
        $url = "http://10.0.2.2:8080"
        Write-Host "📱 Platform: Android Emulator" -ForegroundColor Yellow
    }
    'ios-simulator' {
        $url = "http://localhost:8080"
        Write-Host "📱 Platform: iOS Simulator" -ForegroundColor Yellow
    }
    'physical-device' {
        if (-not $IpAddress) {
            Write-Host "❌ Error: IP address required for physical device" -ForegroundColor Red
            Write-Host "Usage: .\configure-mobile.ps1 -Platform physical-device -IpAddress YOUR_IP" -ForegroundColor Yellow
            Write-Host "`nTo find your IP:" -ForegroundColor Cyan
            Write-Host "  Windows: ipconfig" -ForegroundColor White
            Write-Host "  Mac/Linux: ifconfig`n" -ForegroundColor White
            exit 1
        }
        $url = "http://$IpAddress:8080"
        Write-Host "📱 Platform: Physical Device" -ForegroundColor Yellow
    }
}

Write-Host "🌐 API URL: $url`n" -ForegroundColor Cyan

# Update both apps
Update-ConfigFile -FilePath $clientConfigPath -NewUrl $url
Update-ConfigFile -FilePath $counsellorConfigPath -NewUrl $url

Write-Host "`n✨ Configuration Complete!`n" -ForegroundColor Green

Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Ensure API is running:" -ForegroundColor White
Write-Host "   cd D:\Projects\yomehe\python_api" -ForegroundColor Gray
Write-Host "   python -m uvicorn main:app --reload --host 0.0.0.0 --port 8080`n" -ForegroundColor Gray

Write-Host "2. Run Client App:" -ForegroundColor White
Write-Host "   cd D:\Projects\yomehe\yoneco_app" -ForegroundColor Gray
Write-Host "   flutter run`n" -ForegroundColor Gray

Write-Host "3. Run Counsellor App (new terminal):" -ForegroundColor White
Write-Host "   cd D:\Projects\yomehe\yoneco_counsellor_app" -ForegroundColor Gray
Write-Host "   flutter run`n" -ForegroundColor Gray

Write-Host "💡 Tip: After running 'flutter run', press 'R' to hot restart if needed`n" -ForegroundColor Yellow
