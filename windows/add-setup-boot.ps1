#Requires -RunAsAdministrator
$ErrorActionPreference = 'Stop'
$Letter = 'S'   # Setup volume letter only — no colon
$Log = Join-Path $PSScriptRoot 'setup-boot.log'

function Write-Log([string]$Message) {
    $line = '{0}  {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    Write-Host $line
    Add-Content -Path $Log -Value $line
}

try {
    if (Test-Path $Log) { Remove-Item $Log -Force }
    Write-Log "Setup volume: ${Letter}:"

    $bootWim = "${Letter}:\sources\boot.wim"
    $bootSdi = "${Letter}:\boot\boot.sdi"
    $bootx64 = "${Letter}:\efi\boot\bootx64.efi"

    foreach ($path in @($bootWim, $bootSdi, $bootx64)) {
        if (-not (Test-Path $path)) {
            throw "Missing $path — copy the FULL Windows ISO contents to ${Letter}: first."
        }
        Write-Log "Found $path"
    }

    # Locale-safe: pull {guid} out of bcdedit text with a regex
    function Invoke-Bcd([string[]]$BcdArgs) {
        Write-Log ("bcdedit " + ($BcdArgs -join ' '))
        $out = & bcdedit.exe @BcdArgs 2>&1 | ForEach-Object { "$_" }
        $out | ForEach-Object { Write-Log $_ }
        return ($out -join "`n")
    }

    function Get-GuidFromBcdOutput([string]$Text) {
        $m = [regex]::Match($Text, '\{[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\}')
        if (-not $m.Success) { throw "Could not find a GUID in bcdedit output:`n$Text" }
        return $m.Value
    }

    $idFile = Join-Path $PSScriptRoot 'setup-boot-id.txt'
    if (Test-Path $idFile) {
        $old = (Get-Content $idFile -Raw).Trim()
        if ($old -match '^\{[0-9a-fA-F-]+\}$') {
            Invoke-Bcd @('/delete', $old, '/cleanup') | Out-Null
        }
    }

    Invoke-Bcd @('/create', '{ramdiskoptions}', '/d', 'Ramdisk options') | Out-Null
    Invoke-Bcd @('/set', '{ramdiskoptions}', 'ramdisksdidevice', "partition=${Letter}:") | Out-Null
    Invoke-Bcd @('/set', '{ramdiskoptions}', 'ramdisksdipath', '\boot\boot.sdi') | Out-Null

    $created = Invoke-Bcd @('/create', '/d', 'Windows 11 Setup', '/application', 'osloader')
    $id = Get-GuidFromBcdOutput $created
    Write-Log "Using boot entry $id"
    Set-Content -Path $idFile -Value $id -Encoding ascii

    Invoke-Bcd @('/set', $id, 'device', "ramdisk=[${Letter}:]\sources\boot.wim,{ramdiskoptions}") | Out-Null
    Invoke-Bcd @('/set', $id, 'osdevice', "ramdisk=[${Letter}:]\sources\boot.wim,{ramdiskoptions}") | Out-Null
    Invoke-Bcd @('/set', $id, 'path', '\Windows\System32\Boot\winload.efi') | Out-Null
    Invoke-Bcd @('/set', $id, 'systemroot', '\Windows') | Out-Null
    Invoke-Bcd @('/set', $id, 'detecthal', 'Yes') | Out-Null
    Invoke-Bcd @('/set', $id, 'winpe', 'Yes') | Out-Null
    Invoke-Bcd @('/displayorder', $id, '/addlast') | Out-Null
    Invoke-Bcd @('/timeout', '10') | Out-Null

    Write-Log 'OK — reboot and choose "Windows 11 Setup".'
    Write-Log "Log file: $Log"
}
catch {
    Write-Log ("ERROR: " + $_.Exception.Message)
    Write-Host ''
    Write-Host 'Failed. Full log:' $Log -ForegroundColor Red
    exit 1
}
