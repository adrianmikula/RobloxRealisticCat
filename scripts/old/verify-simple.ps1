# Simple Windows verification script
Write-Host "🪟 Simple Windows Verification"
Write-Host "============================="
Write-Host ""

# Check Lune
Write-Host "1. Checking Lune..."
try {
    $luneVersion = lune --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Lune is installed: $luneVersion" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Lune not found" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "   ❌ Lune not found" -ForegroundColor Red
    exit 1
}

# Check current directory
Write-Host ""
Write-Host "2. Current directory:" -ForegroundColor Yellow
Write-Host "   $(Get-Location)" -ForegroundColor Gray

# Check if we're in the right place
Write-Host ""
Write-Host "3. Checking project files..." -ForegroundColor Yellow

$requiredFiles = @(
    "src/sum.lua",
    "scripts/windows-test-runner.lua",
    "scripts/simple-test-runner.lua"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "   ✅ $file" -ForegroundColor Green
    } else {
        Write-Host "   ❌ $file (missing)" -ForegroundColor Red
    }
}

# Test Lua execution
Write-Host ""
Write-Host "4. Testing Lua execution..." -ForegroundColor Yellow

$testScript = @"
print("Testing Lua execution...")
print("1 + 2 = " .. (1 + 2))
print("Hello from Lune!")
"@

$testScript | Out-File -FilePath "test-lune.lua" -Encoding UTF8
lune test-lune.lua 2>$null

if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Lua execution works" -ForegroundColor Green
} else {
    Write-Host "   ❌ Lua execution failed" -ForegroundColor Red
}

Remove-Item "test-lune.lua" -ErrorAction SilentlyContinue

# Test file reading
Write-Host ""
Write-Host "5. Testing file reading..." -ForegroundColor Yellow

if (Test-Path "src/sum.lua") {
    $testReadScript = @"
local fs = require("fs")
local code = fs.readFile("src/sum.lua")
local chunk = load(code, "sum.lua", "t", {})
local sum = chunk()
print("sum(1, 2) = " .. sum(1, 2))
if sum(1, 2) == 3 then
    print("✅ File reading works!")
else
    print("❌ File reading failed")
end
"@

    $testReadScript | Out-File -FilePath "test-read.lua" -Encoding UTF8
    lune test-read.lua 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ File reading works" -ForegroundColor Green
    } else {
        Write-Host "   ❌ File reading failed" -ForegroundColor Red
    }
    
    Remove-Item "test-read.lua" -ErrorAction SilentlyContinue
} else {
    Write-Host "   ⚠️ src/sum.lua not found (skipping)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎯 Verification Complete" -ForegroundColor Cyan
Write-Host "======================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "• Run tests: scripts\run-tests.bat" -ForegroundColor White
Write-Host "• Or: lune run scripts/windows-test-runner.lua" -ForegroundColor White
Write-Host ""
Write-Host "If you see errors, check:" -ForegroundColor Yellow
Write-Host "1. Lune is in PATH" -ForegroundColor Gray
Write-Host "2. You're in project root" -ForegroundColor Gray
Write-Host "3. Files exist at expected paths" -ForegroundColor Gray
Write-Host ""
Write-Host "Happy testing! 🧪" -ForegroundColor Cyan