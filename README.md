**Author:** [Sjshovan (LoTekkie)](https://github.com/LoTekkie)  
**Version:** v0.9.0a


# Yield

> An Ashita v3 addon that allows you to track and edit gathering metrics within a simple GUI in Final Fantasy 11 Online.


### Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
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
4. Extract the zipped folder to `Ashita_v3/addons/`.
5. Rename the folder to remove the version tag (`-v0.9.0a`). The folder should be named `Yield`.

**Autoloading:**   

By default you will need to manually load this addon each time you restart the game.
To autoload Yield so that it is always ready for use upon entering the game, follow these steps:

1. Navigate to the `Ashita_v3/scripts/` directory.
2. Open the `Default.txt` file.
3. Locate the `Load Common Addons` section.
4. add the following line: `/addon load yield`.

___
### Aliases
The following aliases are available to Yield commands:    

**yield:** yld  
**unload:** u  
**reload:** r  
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

**about**

Displays information about the Yield addon. Below are the equivalent ways of calling the command:
    
    /yield about
    /yld about
    /yield a
    /yld a
    
___
### Support
**Having Issues with this addon?**
* Please let me know [here](https://github.com/LoTekkie/Ashita-Yield/issues/new).
  
**Have something to say?**
* Send me some feedback here: <Sjshovan@Gmail.com>

**Want to stay in the loop with my work?**
* You can follow me at: <https://twitter.com/Sjshovan>

**Wanna toss a coin to your modder?**
* You can do so here: <https://www.Paypal.me/Sjshovan>  

___
### Change Log    

**v0.9.0a** - 6/19/2021
- Initial upload
___
### Known Issues

- **Issue:** Window resizing causes the cursor position to change making GUI interaction difficult.

___    
### TODOs

- **TODO:** Add the rest of the gathering types
- **TODO:** Add the sound alerts functionality
- **TODO:** Cleanup code, re-write to improve performance/readability
___

### License

Copyright © 2021, [Sjshovan (LoTekkie)](https://github.com/LoTekkie).
Released under the [BSD License](LICENSE).

***