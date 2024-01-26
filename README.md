This repository is meant to help people use `zrok` to run Minecraft.

### Prerequisites
* download/install/start Minecraft server somewhere (accept the eula etc)
* download [the latest zrok for windows](https://github.com/openziti/zrok/releases/latest) (currently zrok_0.4.23_windows_amd64.tar.gz)
* use windows explorer (win11+) or 7zip or something to ungzip and untar the download
* put the zrok.exe somewhere you can find, for example `c:\minecraft\zrok.exe`
* invite yourself to zrok using: `zrok invite`

### On the Minecraft server:
* download: [the start-server script](https://raw.githubusercontent.com/dovholuknf/minecraft-zrok-bootstrapper/main/start-server.ps1)
* edit the script and update the PATH_TO_ZROK with the location of your zrok.exe
* run `start-server.ps1` (the script is not signed, research this if you don't understand it):

      powershell.exe -ExecutionPolicy Bypass -File start-server.ps1

### On the Minecraft clients:
* download [the start-client script](https://raw.githubusercontent.com/dovholuknf/minecraft-zrok-bootstrapper/main/start-client.ps1)
* update the start-client sciprt with the path to zrok
* run `start-client.ps1` (the script is not signed, research this if you don't understand it):

	  powershell.exe -ExecutionPolicy Bypass -File start-client.ps1
	  