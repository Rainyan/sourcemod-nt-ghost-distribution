## Generating the dataset

### Prerequisites
- [Hammer/SDK setup for Neotokyo](https://steamcommunity.com/sharedfiles/filedetails/?id=282059949)
- [SRCDS setup for Neotokyo](https://steamcommunity.com/sharedfiles/filedetails/?id=281433778), together with [SourceMod](https://github.com/alliedmodders/sourcemod/) installation

### Steps
- Compile the VMFs from `mapsrc` & place the corresponding BSP files in the server's maps folder
- Changelevel to one of the BSPs you want to test
- Add 2 bots to the server with `bot_add` (requires `sv_cheats 1`), so the ghost will spawn
- Set the `NUM_GHOST_SPAWN_POINTS` preprocessor constant to the number matching that map
- Recompile and place the plugin in the server's SourceMod plugins path
- (Re)load the plugin with `sm plugins refresh`.
- Wait until tests completion (progress shown in the server's console output)
- The generated dataset will be written in the server's `NeotokyoSource` root folder
- Move the dataset to this relative path's `dataset` folder

Example SRCDS output whilst generating:

![test_bias](https://github.com/Rainyan/sourcemod-nt-ghost-distribution/assets/6595066/cd120483-a251-415a-a99a-c35cf6391cc0)

## Generating the images

```bash
# Python 3 or compatible required.
pip install -U pipenv
pipenv install .
pipenv run pip install -r requirements
pipenv run python visualize.py
```

Adjust the Python script variables as required.
