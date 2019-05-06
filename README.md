# JAM_Commands 
- Some useful commands.

### Requirements
* [JAM_Base](https://github.com/JustAnotherModder/JAM)

## Download & Installation

### Manually
- Download https://github.com/JustAnotherModder/JAM_Commands/archive/master.zip
- Extract the JAM_Commands folder (and its contents) into your `JAM` folder, inside of your `resources` directory.
- Open `__resource.lua` in your `JAM` folder.
- Add the files to their respective locations, like so :

```
client_scripts {
	'JAM_Main.lua',
  'JAM_Client.lua',
	'JAM_Utilities.lua',

  -- Commands
	'JAM_Commands/JAM_Commands.lua',
}
```
