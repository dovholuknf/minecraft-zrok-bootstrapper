$PATH_TO_ZROK="C:\work\git\bitbucket\dovholuk\dev_stuff\helper-scripts\windows\zrok.exe"
$PRIVATE_ACCESS_TOKEN = Read-Host "Enter the private access token"

Start-Process -FilePath "$PATH_TO_ZROK" `
    -ArgumentList "access private $PRIVATE_ACCESS_TOKEN --bind 127.0.0.1:25564" `
    -PassThru