# Realistic Cat Game Test Runner (PowerShell)
# Run with: .\run-tests.ps1

Write-Host "🐱 Realistic Cat Game Test Runner" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Check if Lune is installed
$lunePath = Get-Command lune -ErrorAction SilentlyContinue
if (-not $lunePath) {
    Write-Host "❌ Lune is not installed. Please install it from:" -ForegroundColor Red
    Write-Host "   https://lune.sh" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Quick install:" -ForegroundColor Yellow
    Write-Host "  iwr https://github.com/lune-org/lune/releases/latest/download/lune-windows-x86_64.zip -OutFile lune.zip" -ForegroundColor Gray
    Write-Host "  Expand-Archive lune.zip -DestinationPath ." -ForegroundColor Gray
    Write-Host "  Move lune.exe to a directory in PATH" -ForegroundColor Gray
    exit 1
}

Write-Host "✅ Lune version: $(lune --version)" -ForegroundColor Green

# Check if Wally packages are installed
if (-not (Test-Path "Packages") -or -not (Test-Path "DevPackages")) {
    Write-Host "📦 Installing Wally packages..." -ForegroundColor Yellow
    wally install
}

Write-Host "✅ Dependencies checked" -ForegroundColor Green

# Run tests
Write-Host ""
Write-Host "🚀 Running tests..." -ForegroundColor Cyan
Write-Host "------------------" -ForegroundColor Cyan

lune run scripts/test-runner.lua

$EXIT_CODE = $LASTEXITCODE

Write-Host ""
Write-Host "=================================" -ForegroundColor Cyan
if ($EXIT_CODE -eq 0) {
    Write-Host "✅ All tests passed!" -ForegroundColor Green
} else {
    Write-Host "❌ Tests failed with exit code: $EXIT_CODE" -ForegroundColor Red
}

exit $EXIT_CODE