$PATH_TO_ZROK="C:\path\to\zrok\zrok.exe"
$PATH_TO_JAVA="C:\path\to\java\java.exe"
$SERVER_HOME = "C:\path\to\minecraft\server"
$SERVER_JAR = "minecraft_server.1.20.4.jar"
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

do {
    if (Test-Path $PATH_TO_JAVA -PathType Leaf) {
        break
    } else {
        Write-Host -ForegroundColor Red "==== PATH_TO_JAVA incorrect! ===="
        Write-Host -ForegroundColor Red "(update PATH_TO_JAVA in this script to avoid seeing this message)"
        
        $PATH_TO_JAVA = Read-Host "Enter the correct path"
    }
} while ($true)

do {
    if (Test-Path $SERVER_HOME -PathType Container) {
        break
    } else {
        Write-Host -ForegroundColor Red "==== SERVER_HOME incorrect! ===="
        Write-Host -ForegroundColor Red "(update SERVER_HOME in this script to avoid seeing this message)"
        
        $SERVER_HOME = Read-Host "Enter the correct path to your server's home"
    }
} while ($true)


$eulaOK = Select-String -Path "$SERVER_HOME\eula.txt" -Pattern "eula=true"
if ($eulaOK -ne $null)
{
    echo Contains String
}
else
{
    Write-Host "=============================================="
    Write-Host "== eula file contents =="
    Write-Host "=============================================="
    Get-Content -Path "$SERVER_HOME\eula.txt" -Raw
    Write-Host "=============================================="
    Write-Host ""
    Write-Host -ForegroundColor Red "Error: You haven't accepted the Minecraft server eula.txt!"
    return
}

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

$minecraftProcess = Start-Process -FilePath "$PATH_TO_JAVA" `
    -ArgumentList "-Xmx${MAX_MEMORY_MB}M", `
                  "-Xms${INITIAL_MEMORY_MB}M", `
                  "-jar", `
                  "$SERVER_HOME\$SERVER_JAR", `
                  "nogui" `
    -WorkingDirectory $SERVER_HOME `
    -PassThru

while (-not (Test-NetConnection -ComputerName $MINECRAFT_SERVER_IP -Port $MINECRAFT_SERVER_PORT -InformationLevel Quiet)) {
    Write-Host "Waiting for port $MINECRAFT_SERVER_PORT to respond..."
    Start-Sleep -Seconds 5
}

Write-Host "Port $MINECRAFT_SERVER_PORT is now open. Starting zrok share"

Start-Process -FilePath "$PATH_TO_ZROK" `
    -ArgumentList "share reserved $RESERVED_SHARE" `
    -PassThru

Write-Host ""
Write-Host ""
Write-Host "Minecraft server is now running. zrok share reserved is running..."
Write-Host "To stop, click in each window. Press 'ctrl-c' and wait for the window to disappear"
Write-Host ""
Write-Host ""