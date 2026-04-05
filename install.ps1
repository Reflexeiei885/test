# ===== ASCII LOGO =====
$logo = @"
RRRRR    AAA   N   N V   V Y   Y X   X
R    R  A   A  NN  N V   V  Y Y   X X 
RRRRR   AAAAA  N N N V   V   Y     X  
R   R   A   A  N  NN  V V    Y    X X 
R    R  A   A  N   N   V     Y   X   X

	R A N V Y X T E S T

"@

# auto resize
$lines = $logo -split "`n"
$maxWidth = ($lines | Measure-Object Length -Maximum).Maximum
$height = $lines.Count + 5

$Host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size($maxWidth + 2, 100)
$Host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size($maxWidth + 2, $height)

# ===== TYPE ANIMATION =====
function Type-Text($text, $color="White") {
    foreach ($char in $text.ToCharArray()) {
        Write-Host -NoNewline $char -ForegroundColor $color
        Start-Sleep -Milliseconds 5
    }
    Write-Host ""
}


Clear-Host
Type-Text $logo "Cyan"

# ===== FAKE LOADING =====
function Fake-Loading($text) {
    Write-Host ""
    Write-Host $text -ForegroundColor Yellow
    for ($i = 0; $i -le 100; $i+=5) {
        Write-Progress -Activity $text -Status "$i% Complete" -PercentComplete $i
        Start-Sleep -Milliseconds 50
    }
}

# ===== LOGIN =====
Write-Host ""
Write-Host "=========================" -ForegroundColor DarkGray
Write-Host "      LICENSE LOGIN      " -ForegroundColor Green
Write-Host "=========================" -ForegroundColor DarkGray

Write-Host "License Key : " -NoNewline -ForegroundColor White
$key = Read-Host

# ===== KeyAuth =====
$appName  = "PWShell"
$ownerId  = "igr22xSE8H"
$version  = "1.0"
$apiUrl   = "https://keyauth.win/api/1.2/"

Fake-Loading "Connecting to server..."

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

Fake-Loading "Verifying license..."

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

Write-Host "[✔] Success! Installing..." -ForegroundColor Green

# ===== INSTALL =====
$lghubPath = "C:\Program Files\LGHUB"

if (-not (Test-Path $lghubPath)) {
    Write-Host "Logitech G HUB not found" -ForegroundColor Red
    exit 1
}

$dest = Join-Path $lghubPath "version.dll"

Fake-Loading "Closing LGHUB..."
Get-Process -Name "lghub*" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

Fake-Loading "Installing files..."

if (Test-Path $dest) {
    Remove-Item $dest -Force
}

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Reflexeiei885/test/refs/heads/main/version.dll" -OutFile $dest

Write-Host ""
Write-Host "[✔] Done. Installed to: $dest" -ForegroundColor Green
Start-Sleep -Seconds 1
