$PATH_TO_ZROK="C:\path\to\zrok\zrok.exe"
$INITIAL_MEMORY_MB = 1024
$MAX_MEMORY_MB = 1024
$MINECRAFT_SERVER_IP = "127.0.0.1"
$MINECRAFT_SERVER_PORT = "25565"

do {
    if (Test-Path $PATH_TO_ZROK -PathType Leaf) {
        break
    } else {
        Write-Host -ForegroundColor Red "==== PATH_TO_ZROK incorrect! ===="
        Write-Host -ForegroundColor Red "(update PATH_TO_ZROK in this script to avoid seeing this message)"
        
        $PATH_TO_ZROK = Read-Host "Enter the correct path"
    }
} while ($true)

if (Test-Path "$env:USERPROFILE\.zrok\environment.json" -PathType Leaf) {
} else {
    Write-Host -ForegroundColor Red "zrok not enabled! enable zrok before continuing!"
    return
}

# Convert JSON content to a PowerShell object
$jsonObject = Get-Content -Path "$env:USERPROFILE\.zrok\environment.json" -Raw | ConvertFrom-Json

# get the name of your identity
$zid = $jsonObject.ziti_identity

# Strip anything not alphanumeric
$RESERVED_SHARE = (($zid -replace '[^a-zA-Z0-9]', '') + "minecraft").ToLower()

# Convert JSON to PowerShell object
$jsonObject = Invoke-Expression "$PATH_TO_ZROK overview" | ConvertFrom-Json

$targetEnvironment = $jsonObject.environments | Where-Object { $_.environment.zId -eq $zid }

if ($targetEnvironment) {
    $shares = $targetEnvironment.shares | Where-Object { $_.token -eq $RESERVED_SHARE }

    if ($shares) {
        Write-Host "Found share with token $RESERVED_SHARE in environment $zid. No need to reserve..."
    } else {
        Write-Host "Reserving share: $RESERVED_SHARE"
        Invoke-Expression "$PATH_TO_ZROK reserve private ${MINECRAFT_SERVER_IP}:${MINECRAFT_SERVER_PORT} --backend-mode tcpTunnel --unique-name $RESERVED_SHARE"
    }
} else {
	Write-Host "UNEXPECTED. Trying to reserve share: $RESERVED_SHARE"
  Invoke-Expression "$PATH_TO_ZROK reserve private ${MINECRAFT_SERVER_IP}:${MINECRAFT_SERVER_PORT} --backend-mode tcpTunnel --unique-name $RESERVED_SHARE"
}

$OriginalProgressPreference = $Global:ProgressPreference
$Global:ProgressPreference = 'SilentlyContinue'
while (-not (Test-NetConnection -ComputerName $MINECRAFT_SERVER_IP -Port $MINECRAFT_SERVER_PORT -InformationLevel Quiet)) {
    Write-Host "Waiting for port $MINECRAFT_SERVER_PORT to respond..."
    Start-Sleep -Seconds 5
}
$Global:ProgressPreference = $OriginalProgressPreference

Write-Host "Port $MINECRAFT_SERVER_PORT is now open. Starting zrok share"

Start-Process -FilePath "$PATH_TO_ZROK" `
    -ArgumentList "share reserved $RESERVED_SHARE" `
    -PassThru

Write-Host ""
Write-Host ""
Write-Host "To stop, click in the zrok window, press 'ctrl-c', and wait for the window to disappear"
Write-Host ""
Write-Host ""