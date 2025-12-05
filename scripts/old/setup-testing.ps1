# PowerShell script to set up testing environment
Write-Host "🚀 Setting Up Windows Testing Environment" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Function to check if a command exists
function Test-Command {
    param($command)
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'stop'
    try {
        if (Get-Command $command) {
            return $true
        }
    } catch {
        return $false
    } finally {
        $ErrorActionPreference = $oldPreference
    }
}

# Check prerequisites
Write-Host "1. Checking prerequisites..." -ForegroundColor Yellow

# Check Lune
if (Test-Command "lune") {
    $luneVersion = & lune --version 2>$null
    Write-Host "   ✅ Lune: $luneVersion" -ForegroundColor Green
} else {
    Write-Host "   ❌ Lune not found" -ForegroundColor Red
    Write-Host "   Download from: https://lune.sh" -ForegroundColor Yellow
    Write-Host "   Extract and add to PATH" -ForegroundColor Yellow
}

# Check Node.js/npm (optional)
if (Test-Command "npm") {
    $npmVersion = & npm --version 2>$null
    Write-Host "   ✅ npm: $npmVersion" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  npm not found (optional)" -ForegroundColor Yellow
}

# Check Wally (optional)
if (Test-Command "wally") {
    Write-Host "   ✅ Wally found" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Wally not found (optional)" -ForegroundColor Yellow
}

# Check project structure
Write-Host ""
Write-Host "2. Checking project structure..." -ForegroundColor Yellow

$requiredDirs = @("src", "src/__tests__", "scripts")
foreach ($dir in $requiredDirs) {
    if (Test-Path $dir) {
        Write-Host "   ✅ $dir/" -ForegroundColor Green
    } else {
        Write-Host "   ❌ $dir/ missing" -ForegroundColor Red
    }
}

# Check critical files
Write-Host ""
Write-Host "3. Checking critical files..." -ForegroundColor Yellow

$criticalFiles = @(
    "src/sum.lua",
    "scripts/windows-test-runner.lua",
    "scripts/simple-test-runner.lua",
    "scripts/run-tests.bat",
    "scripts/windows-verify.ps1"
)

foreach ($file in $criticalFiles) {
    if (Test-Path $file) {
        Write-Host "   ✅ $file" -ForegroundColor Green
    } else {
        Write-Host "   ❌ $file missing" -ForegroundColor Red
    }
}

# Create test directory if it doesn't exist
Write-Host ""
Write-Host "4. Setting up test directory..." -ForegroundColor Yellow
if (-not (Test-Path "src/__tests__")) {
    Write-Host "   Creating src/__tests__ directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path "src/__tests__" -Force | Out-Null
    Write-Host "   ✅ Created src/__tests__" -ForegroundColor Green
} else {
    Write-Host "   ✅ Test directory exists" -ForegroundColor Green
}

# Create example test if none exist
Write-Host ""
Write-Host "5. Checking for test files..." -ForegroundColor Yellow
$testFiles = Get-ChildItem "src/__tests__" -Filter "*.spec.lua" -ErrorAction SilentlyContinue
if ($testFiles.Count -eq 0) {
    Write-Host "   No test files found, creating example..." -ForegroundColor Yellow
    
    $exampleTest = @"
local JestGlobals = require("@DevPackages/JestGlobals")
local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect

describe("Example Test", function()
    it("should pass basic arithmetic", function()
        expect(1 + 1).toBe(2)
    end)
    
    it("should handle strings", function()
        expect("hello" .. " world").toBe("hello world")
    end)
end)
"@
    
    $exampleTest | Out-File -FilePath "src/__tests__/example.spec.lua" -Encoding UTF8
    Write-Host "   ✅ Created example test: src/__tests__/example.spec.lua" -ForegroundColor Green
} else {
    Write-Host "   Found $($testFiles.Count) test files:" -ForegroundColor Green
    foreach ($file in $testFiles) {
        Write-Host "     - $($file.Name)" -ForegroundColor Gray
    }
}

# Summary
Write-Host ""
Write-Host "🎯 Setup Summary" -ForegroundColor Cyan
Write-Host "================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Available commands:" -ForegroundColor Yellow
Write-Host "  • Verify setup:    powershell -ExecutionPolicy Bypass -File scripts/windows-verify.ps1" -ForegroundColor White
Write-Host "  • Run tests:       scripts\run-tests.bat" -ForegroundColor White
Write-Host "  • Run simple:      lune run scripts/simple-test-runner.lua" -ForegroundColor White
Write-Host "  • Run Windows:     lune run scripts/windows-test-runner.lua" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Run verification: scripts\windows-verify.ps1" -ForegroundColor Gray
Write-Host "2. Run tests: scripts\run-tests.bat" -ForegroundColor Gray
Write-Host "3. Write your own tests in src/__tests__/" -ForegroundColor Gray
Write-Host ""
Write-Host "Documentation:" -ForegroundColor Yellow
Write-Host "• docs/testing/WINDOWS_TESTING_GUIDE.md" -ForegroundColor Gray
Write-Host "• docs/testing/CLI_TESTING_GUIDE.md" -ForegroundColor Gray
Write-Host ""
Write-Host "Happy testing! 🧪" -ForegroundColor Cyan