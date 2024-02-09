This repository is meant to help people use `zrok` to run Minecraft.

### Prerequisites
* download/install/start Minecraft server somewhere (accept the eula etc)
* download [the latest zrok for windows](https://github.com/openziti/zrok/releases/latest) (currently zrok_0.4.23_windows_amd64.tar.gz)
* use windows explorer (win11+) or 7zip or something to ungzip and untar the download
* put the zrok.exe somewhere you can find, for example `c:\minecraft\zrok.exe`
* invite yourself to zrok using: `zrok invite`. see https://docs.zrok.io/docs/getting-started/#generating-an-invitation

### On the Minecraft server:
* `zrok enable` the server. see [Enabling Your zrok Environment](https://docs.zrok.io/docs/getting-started/#enabling-your-zrok-environment)
* download: [the start-server script](https://raw.githubusercontent.com/dovholuknf/minecraft-zrok-bootstrapper/main/start-server.ps1)
* edit the script and update the PATH_TO_ZROK with the location of your zrok.exe
* run `start-server.ps1` (the script is not signed, research this if you don't understand it):

      powershell.exe -ExecutionPolicy Bypass -File start-server.ps1

* after `zrok` starts, there will be a private token that you need to distribute to the people you want to allow to access the Minecraft server:
* ![image](https://github.com/dovholuknf/minecraft-zrok-bootstrapper/assets/46322585/8bdc6d16-5569-43f8-b6a5-c96653b35a5d)

### On the Minecraft clients:
* `zrok enable` the client. see [Enabling Your zrok Environment](https://docs.zrok.io/docs/getting-started/#enabling-your-zrok-environment)
* download [the start-client script](https://raw.githubusercontent.com/dovholuknf/minecraft-zrok-bootstrapper/main/start-client.ps1)
* update the start-client script and update the PATH_TO_ZROK with the location of your zrok.exe
* run `start-client.ps1` (the script is not signed, research this if you don't understand it):

	  powershell.exe -ExecutionPolicy Bypass -File start-client.ps1
* when the `start-client.ps1` script executes, you'll be prompted to enter the secret token from the server:
  ![image](https://github.com/dovholuknf/minecraft-zrok-bootstrapper/assets/46322585/7dfb8105-4f81-4345-a2c1-ad19b6f43ca2)

### YouTube Video Overview:
[<img src="https://img.youtube.com/vi/Sq43hp6n9rE/hqdefault.jpg">](https://youtu.be/Sq43hp6n9rE)
