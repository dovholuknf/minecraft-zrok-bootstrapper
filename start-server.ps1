$PATH_TO_ZROK="C:\work\git\bitbucket\dovholuk\dev_stuff\helper-scripts\windows\zrok.exe"
$PATH_TO_JAVA="C:\Program Files\OpenJDK\jdk-21.0.1\bin\java.exe"
$SERVER_HOME = "C:\temp\minecraft"
$SERVER_JAR = "minecraft_server.1.20.4.jar"
$INITIAL_MEMORY_MB = 1024
$MAX_MEMORY_MB = 1024
$MINECRAFT_SERVER_IP = "127.0.0.1"
$MINECRAFT_SERVER_PORT = 25565

# Convert JSON content to a PowerShell object
$jsonObject = Get-Content -Path "$env:USERPROFILE\.zrok\environment.json" -Raw | ConvertFrom-Json

# get the name of your identity
$zid = $jsonObject.ziti_identity

# Strip anything not alphanumeric
$RESERVED_SHARE = (($zid -replace '[^a-zA-Z0-9]', '') + "minecraft").ToLower()

# Convert JSON to PowerShell object
$jsonObject = Invoke-Expression "zrok overview" | ConvertFrom-Json

$targetEnvironment = $jsonObject.environments | Where-Object { $_.environment.zId -eq $zid }

if ($targetEnvironment) {
    $shares = $targetEnvironment.shares | Where-Object { $_.token -eq $RESERVED_SHARE }

    if ($shares) {
        Write-Host "Found share with token $RESERVED_SHARE in environment $zid. No need to reserve..."
    } else {
        Write-Host "Reserving share: $RESERVED_SHARE"
		& "$PATH_TO_ZROK reserve private $MINECRAFT_SERVER_IP:$MINECRAFT_SERVER_PORT --backend-mode tcpTunnel --unique-name $RESERVED_SHARE"
    }
} else {
	Write-Host "UNEXPECTED. Trying to reserve share: $RESERVED_SHARE"
	& "$PATH_TO_ZROK reserve private $MINECRAFT_SERVER_IP:$MINECRAFT_SERVER_PORT --backend-mode tcpTunnel --unique-name $RESERVED_SHARE"
}

$minecraftProcess = Start-Process -FilePath "$PATH_TO_JAVA" `
    -ArgumentList "-Xmx${MAX_MEMORY_MB}M", `
                  "-Xms${INITIAL_MEMORY_MB}M", `
                  "-jar", `
                  "$SERVER_HOME\$SERVER_JAR", `
                  "nogui" `
    -WorkingDirectory $SERVER_HOME `
    -PassThru

while (-not (Test-NetConnection -ComputerName $targetHost -Port $targetPort -InformationLevel Quiet)) {
    Write-Host "Waiting for port $targetPort to respond..."
    Start-Sleep -Seconds 5
}

Write-Host "Port $targetPort is now open. Starting zrok share"

Start-Process -FilePath "zrok" `
    -ArgumentList "share reserved $RESERVED_SHARE" `
    -PassThru

Write-Host ""
Write-Host ""
Write-Host "Minecraft server is now running. zrok share reserved is running..."
Write-Host "To stop, click in each window. Press 'ctrl-c' and wait for the window to disappear"
Write-Host ""
Write-Host ""













