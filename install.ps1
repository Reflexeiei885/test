Write-Host "License Key : " -NoNewline -ForegroundColor White
$key = Read-Host

# เช็ค key กับ KeyAuth
$appName  = "PWShell"
$ownerId  = "igr22xSE8H"
$version  = "1.0"
$apiUrl   = "https://keyauth.win/api/1.2/"

# Init session
$initBody = "type=init&ver=$version&name=$appName&ownerid=$ownerId"
try {
    $initResp = Invoke-RestMethod -Uri $apiUrl -Method Post -Body $initBody -ContentType "application/x-www-form-urlencoded"
} catch {
    Write-Host "Connection failed." -ForegroundColor Red
    exit 1
}

if ($initResp.success -ne $true) {
    Write-Host "Init failed." -ForegroundColor Red
    exit 1
}

$sessionId = $initResp.sessionid
$hwid = (Get-WmiObject Win32_ComputerSystemProduct).UUID

# Verify license
$licBody = "type=license&key=$([Uri]::EscapeDataString($key))&hwid=$([Uri]::EscapeDataString($hwid))&sessionid=$sessionId&name=$appName&ownerid=$ownerId"
try {
    $licResp = Invoke-RestMethod -Uri $apiUrl -Method Post -Body $licBody -ContentType "application/x-www-form-urlencoded"
} catch {
    Write-Host "Connection failed." -ForegroundColor Red
    exit 1
}

if ($licResp.success -ne $true) {
    Write-Host "Invalid key." -ForegroundColor Red
    exit 1
}

Write-Host "Success! Installing..." -ForegroundColor Green

# ติดตั้งไปที่ LGHUB
$lghubPath = "C:\Program Files\LGHUB"

if (-not (Test-Path $lghubPath)) {
    Write-Host "Logitech G HUB not found at: $lghubPath" -ForegroundColor Red
    exit 1
}

$dest = Join-Path $lghubPath "version.dll"

# ปิด LGHUB
Get-Process -Name "lghub*" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# ลบไฟล์เก่า
if (Test-Path $dest) {
    Remove-Item $dest -Force
}

# โหลดใหม่
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Reflexeiei885/test/refs/heads/main/version.dll" -OutFile $dest

Write-Host "Done. Installed to: $dest" -ForegroundColor Green
