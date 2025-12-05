# Windows PowerShell verification script
Write-Host "🪟 Windows Test Setup Verification" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Check if Lune is installed
Write-Host "1. Checking Lune installation..." -ForegroundColor Yellow
$luneVersion = & lune --version 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Lune is installed" -ForegroundColor Green
    Write-Host "   Version: $luneVersion" -ForegroundColor Gray
} else {
    Write-Host "   ❌ Lune not found in PATH" -ForegroundColor Red
    Write-Host "   Download from: https://lune.sh" -ForegroundColor Yellow
    Write-Host "   Add to PATH or use full path to lune.exe" -ForegroundColor Yellow
    exit 1
}

# Check current directory
Write-Host ""
Write-Host "2. Checking current directory..." -ForegroundColor Yellow
$currentDir = Get-Location
Write-Host "   Current directory: $currentDir" -ForegroundColor Gray

# Check critical files
Write-Host ""
Write-Host "3. Checking critical files..." -ForegroundColor Yellow
$filesToCheck = @(
    "src/sum.lua",
    "scripts/windows-test-runner.lua",
    "scripts/simple-test-runner.lua",
    "src/__tests__/sum.spec.lua"
)

$allFilesExist = $true
foreach ($file in $filesToCheck) {
    if (Test-Path $file) {
        Write-Host "   ✅ $file" -ForegroundColor Green
        $fullPath = Resolve-Path $file
        Write-Host "        Path: $fullPath" -ForegroundColor DarkGray
    } else {
        Write-Host "   ❌ $file" -ForegroundColor Red
        $allFilesExist = $false
    }
}

# Check directory structure
Write-Host ""
Write-Host "4. Checking directory structure..." -ForegroundColor Yellow
$directories = @(
    "src",
    "src/__tests__",
    "scripts",
    "src/ReplicatedStorage/SharedSource/Utilities"
)

foreach ($dir in $directories) {
    if (Test-Path $dir) {
        Write-Host "   ✅ $dir/" -ForegroundColor Green
    } else {
        Write-Host "   ❌ $dir/" -ForegroundColor Red
        $allFilesExist = $false
    }
}

# Test file reading
Write-Host ""
Write-Host "5. Testing file reading..." -ForegroundColor Yellow
$testFile = "src/sum.lua"
if (Test-Path $testFile) {
    try {
        $content = Get-Content $testFile -Raw -ErrorAction Stop
        Write-Host "   ✅ Can read $testFile" -ForegroundColor Green
        $fileSize = $content.Length
        Write-Host "   File size: $fileSize bytes" -ForegroundColor Gray
        
        # Show first line (trimmed)
        $firstLine = $content -split "`n" | Select-Object -First 1
        $firstLine = $firstLine.Trim()
        if ($firstLine.Length -gt 50) {
            $firstLine = $firstLine.Substring(0, 47) + "..."
        }
        Write-Host "   First line: $firstLine" -ForegroundColor Gray
    } catch {
        Write-Host "   ❌ Cannot read $testFile" -ForegroundColor Red
        Write-Host "   Error: $_" -ForegroundColor DarkRed
        $allFilesExist = $false
    }
} else {
    Write-Host "   ❌ $testFile not found" -ForegroundColor Red
    $allFilesExist = $false
}

# Summary
Write-Host ""
Write-Host "🎯 Verification Summary" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan

if ($allFilesExist) {
    Write-Host "✅ All critical checks passed" -ForegroundColor Green
    Write-Host "✅ File system access works" -ForegroundColor Green
    Write-Host "" -ForegroundColor Gray
    Write-Host "🚀 Ready to run Windows test runner!" -ForegroundColor Cyan
    Write-Host "" -ForegroundColor Gray
    Write-Host "Run this command:" -ForegroundColor Yellow
    Write-Host "  lune run scripts/windows-test-runner.lua" -ForegroundColor White
    Write-Host "" -ForegroundColor Gray
    Write-Host "Or try the simple runner:" -ForegroundColor Yellow
    Write-Host "  lune run scripts/simple-test-runner.lua" -ForegroundColor White
    exit 0
} else {
    Write-Host "❌ Some issues found" -ForegroundColor Red
    Write-Host "" -ForegroundColor Gray
    Write-Host "📋 Common Windows issues:" -ForegroundColor Yellow
    Write-Host "1. File paths - Use forward slashes (/) not backslashes (\\)" -ForegroundColor Gray
    Write-Host "2. File permissions - Check if files are readable" -ForegroundColor Gray
    Write-Host "3. Current directory - Run from project root" -ForegroundColor Gray
    Write-Host "4. Lune PATH - Make sure lune.exe is in PATH" -ForegroundColor Gray
    Write-Host "" -ForegroundColor Gray
    Write-Host "💡 Try running PowerShell as Administrator" -ForegroundColor Yellow
    Write-Host "💡 Check file paths with: Get-ChildItem -Recurse" -ForegroundColor Yellow
    exit 1
}