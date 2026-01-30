# Quick Fix - Install Tailwind CSS
Write-Host "🎨 Installing Tailwind CSS..." -ForegroundColor Cyan
Write-Host ""

cd admin-dashboard-vue

# Install Tailwind
npm install -D tailwindcss postcss autoprefixer

Write-Host ""
Write-Host "✅ Tailwind installed!" -ForegroundColor Green
Write-Host ""
Write-Host "Now restart the dev server:" -ForegroundColor Yellow
Write-Host "  npm run dev" -ForegroundColor White
Write-Host ""
