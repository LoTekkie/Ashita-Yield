**Author:** [Sjshovan (LoTekkie)](https://github.com/LoTekkie)  
**Version:** v0.9.0


# Yield

> An Ashita v4 addon that allows you to track and edit gathering metrics within a simple GUI in Final Fantasy 11 Online.

*I AM CURRENTLY PORTING THIS ADDON TO Ashita4. THERE ARE NO STABLE RELEASES AT THIS TIME*

<img src="https://i.postimg.cc/rsWfXXN8/yield-1-0-1.png..." data-canonical-src="https://i.postimg.cc/rsWfXXN8/yield-1-0-1.png" width="175" height="350" />
<img src="https://i.postimg.cc/3RkL1Dy0/yield-1-0-2.png..." data-canonical-src="https://i.postimg.cc/3RkL1Dy0/yield-1-0-2.png" width="400" height="350" />
<img src="https://i.postimg.cc/FKWW0xKQ/yield-1-0-3.png..." data-canonical-src="https://i.postimg.cc/FKWW0xKQ/yield-1-0-3.png" width="400" height="350" />
<img src="https://i.postimg.cc/bJ4mBNbC/yield-1-0-4.png..." data-canonical-src="https://i.postimg.cc/bJ4mBNbC/yield-1-0-4.png" width="400" height="350" />
<img src="https://i.postimg.cc/pVnGnzbg/yield-1-0-5.png..." data-canonical-src="https://i.postimg.cc/pVnGnzbg/yield-1-0-5.png" width="400" height="350" />
<img src="https://i.postimg.cc/Fs5Pbzh1/yield-1-0-6.png..." data-canonical-src="https://i.postimg.cc/Fs5Pbzh1/yield-1-0-6.png" width="400" height="350" />  

### Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Upgrading](#upgrading)
- [Aliases](#aliases)
- [Usage](#usage)
- [Commands](#commands)
- [Support](#support)
- [Change Log](#change-log)
- [Known Issues](#known-issues)
- [TODOs](#todos)
- [License](#license)

___
### Prerequisites
1. [Final Fantasy 11 Online](http://www.playonline.com/ff11us/index.shtml)
2. [Ashita v3](https://www.ashitaxi.com/)

___
### Installation

**Ashita:**   
1. Navigate to the `Addons` section on the left.
2. Locate the `Yield` addon.
3. Click the flashing download button near the upper-right corner.

**Manual:**
1. Navigate to <https://github.com/LoTekkie/Ashita-Yield>.
2. Click on `Releases`. 
3. Click on the `Source code (zip)` link within the latest release to download.
4. Extract the zipped folder to `Ashita_v4/addons/`.
5. Rename the folder to remove the version tag (`-v0.9.0`). The folder should be named `Yield`.

**Autoloading:**   

By default you will need to manually load this addon each time you restart the game.
To autoload Yield so that it is always ready for use upon entering the game, follow these steps:

1. Navigate to the `Ashita_v4/scripts/` directory.
2. Open the `Default.txt` file.
3. Locate the `Load Common Addons` section.
4. add the following line: `/addon load yield`.

___
### Upgrading

If you have a previous installation of Yield and you are installing manually, follow the steps below to ensure you don't encounter any issues.   

1. Exit out of Final Fantasy XI.
2. Install latest version of Yield.
3. Delete your /settings folder.
4. Load Finaly Fantasy XI.
5. Load Yield.

___
### Aliases
The following aliases are available to Yield commands:    

**yield:** yld  
**unload:** u  
**reload:** r  
**find:** f  
**about:** a  
**help:** h  
 
 ___
### Usage

Manually load the addon by using the following command:
    
    /addon load yield  
    
___    
### Commands

**help**

Displays available Yield commands. Below are the equivalent ways of calling the command:

    /yield help
    /yld help
    /yield h
    /yld h
    
**unload**

Unloads the Yield addon. Below are the equivalent ways of calling the command:
    
    /yield unload
    /yld unload
    /yield u
    /yld u
    
**reload**

Reloads the Yield addon. Below are the equivalent ways of calling the command:
    
    /yield reload
    /yld reload
    /yield r
    /yld r

**find**

Positions the Yield window to the top left corner of your screen. Below are the equivalent ways of calling the command:
    
    /yield find
    /yld find
    /yield f
    /yld f


**about**

Displays information about the Yield addon. Below are the equivalent ways of calling the command:
    
    /yield about
    /yld about
    /yield a
    /yld a
    
___
### Support
**Having Issues with this addon?**
* Please let me know here: [https://github.com/LoTekkie/Ashita-Yield/issues/new](https://github.com/LoTekkie/Ashita-Yield/issues/new).
  
**Have something to say?**
* Send me some feedback here: <Sjshovan@Gmail.com>

**Want to stay in the loop with my work?**
* You can follow me at: <https://twitter.com/Sjshovan>

**Wanna toss a coin to your modder?**
* You can do so here: <https://www.Paypal.me/Sjshovan>  
**OR**
* For Gil donations: I play on HorizonXI private server! (<https://horizonxi.com/>) My in-game name is LoTekkie.

___
### Change Log

**v0.9.0a** - 11/28/2022  
- Initial upload.
___
### Known Issues

- **Issue:** Game window resizing causes the cursor position to change making GUI interaction difficult.
- **Issue:** Yield window size changes causes fonts to scale strangely.

___    
### TODOs
- **TODO:** Cleanup code, re-write some areas to improve performance/readability.
___

### License

Copyright © 2022, [Sjshovan (LoTekkie)](https://github.com/LoTekkie).
Released under the [BSD License](LICENSE).

***
