# ===== ASCII LOGO =====
$logo = @"
RRRRR    AAA   N   N V   V Y   Y X   X
R    R  A   A  NN  N V   V  Y Y   X X 
RRRRR   AAAAA  N N N V   V   Y     X  
R   R   A   A  N  NN  V V    Y    X X 
R    R  A   A  N   N   V     Y   X   X

      R A N V Y X S T O R E
"@

# ===== GRADIENT COLORS =====
$colors = @(
    "Green",
    "Green",
    "Green"
)

# ===== SHOW LOGO (LEFT + GRADIENT + TYPE EFFECT) =====
function Show-Logo {
    Clear-Host

    $lines = $logo -split "`n"
    $colorIndex = 0

    foreach ($line in $lines) {
        $color = $colors[$colorIndex % $colors.Count]

        foreach ($char in $line.ToCharArray()) {
            Write-Host -NoNewline $char -ForegroundColor $color
            Start-Sleep -Milliseconds 1   # ปรับความเร็วได้
        }

        Write-Host ""
        $colorIndex++
    }
}

# ===== TYPE TEXT =====
function Type-Text($text, $color="White", $speed=3) {
    foreach ($char in $text.ToCharArray()) {
        Write-Host -NoNewline $char -ForegroundColor $color
        Start-Sleep -Milliseconds $speed
    }
    Write-Host ""
}

# ===== FAKE LOADING (CUSTOM BAR) =====
function Fake-Loading($text) {
    Write-Host ""
    Type-Text $text "Yellow" 2

    $barLength = 30
    for ($i = 0; $i -le $barLength; $i++) {
        $percent = [int](($i / $barLength) * 100)
        $bar = ("#" * $i).PadRight($barLength, "-")

        Write-Host -NoNewline "`r[$bar] $percent%" -ForegroundColor Green
        Start-Sleep -Milliseconds (Get-Random -Min 20 -Max 60)
    }

    Write-Host ""
}

# ===== CLEAN PRINT =====
function Print-Success($text) {
    Write-Host "[+] $text" -ForegroundColor Green
}

function Print-Error($text) {
    Write-Host "[-] $text" -ForegroundColor Red
}

# ===== START =====
Show-Logo

Write-Host ""
Write-Host "Enter License Key : " -NoNewline -ForegroundColor White
$key = Read-Host

# ===== KeyAuth =====
$appName  = "PWShell"
$ownerId  = "igr22xSE8H"
$version  = "1.0"
$apiUrl   = "https://keyauth.win/api/1.2/"

Fake-Loading "Connecting to server..."

$initBody = "type=init&ver=$version&name=$appName&ownerid=$ownerId"
$initResp = Invoke-RestMethod -Uri $apiUrl -Method Post -Body $initBody -ContentType "application/x-www-form-urlencoded"

if (-not $initResp.success) {
    Print-Error "Init failed"
    exit
}

$sessionId = $initResp.sessionid
$hwid = (Get-WmiObject Win32_ComputerSystemProduct).UUID

Fake-Loading "Verifying license..."

$licBody = "type=license&key=$([Uri]::EscapeDataString($key))&hwid=$([Uri]::EscapeDataString($hwid))&sessionid=$sessionId&name=$appName&ownerid=$ownerId"
$licResp = Invoke-RestMethod -Uri $apiUrl -Method Post -Body $licBody -ContentType "application/x-www-form-urlencoded"

if (-not $licResp.success) {
    Print-Error "Invalid key"
    exit
}

Print-Success "Login success"

# ===== INSTALL =====
Fake-Loading "Preparing installation..."

$lghubPath = "C:\Program Files\LGHUB"

if (-not (Test-Path $lghubPath)) {
    Print-Error "Logitech G HUB not found"
    exit
}

$dest = Join-Path $lghubPath "version.dll"

# kill process เงียบ ๆ
Get-Process -Name "lghub*" | Stop-Process -Force

Start-Sleep -Milliseconds 500

# remove ของเก่า
if (Test-Path $dest) {
    Remove-Item $dest -Force
}

Fake-Loading "Installing..."

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Reflexeiei885/test/refs/heads/main/version.dll" -OutFile $dest | Out-Null

# ===== DONE =====
Write-Host ""
Print-Success "Installed successfully"
Write-Host "Path: $dest" -ForegroundColor Gray

Start-Sleep -Seconds 5
