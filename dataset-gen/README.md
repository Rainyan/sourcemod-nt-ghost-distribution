## Generating the dataset

### Prerequisites
- [Hammer/SDK setup for Neotokyo](https://steamcommunity.com/sharedfiles/filedetails/?id=282059949)
- [SRCDS setup for Neotokyo](https://steamcommunity.com/sharedfiles/filedetails/?id=281433778), together with [SourceMod](https://github.com/alliedmodders/sourcemod/) installation

### Steps
- Compile the VMFs from `mapsrc` & place the corresponding BSP files in the SRCDS maps folder
- Launch the SRCDS
- `changelevel <mapname>` to one of the BSPs you wish to test
- Add 2 bots to the server with `bot_add` (requires `sv_cheats 1`), so the ghost will spawn
- In the SRCDS plugin source code, set the `NUM_GHOST_SPAWN_POINTS` preprocessor constant to the number matching that map
- Recompile the plugin, and place it in the server's SourceMod plugins path (typically at `NeotokyoSource/addons/sourcemod/plugins` from server root dir)
  - Alternatively, you may use [an online compiler](https://www.sourcemod.net/compiler.php) to skip installing the build tools locally
  - For more detailed information about compiling plugins, please refer to the [AlliedModders Wiki](https://wiki.alliedmods.net/Compiling_SourceMod_Plugins)
- (Re)load the plugin with `sm plugins refresh; sm plugins reload test_bias;`
- Wait until tests completion (progress shown in the server's console output)
- The generated dataset will be written in the server's `NeotokyoSource` folder
- Move the dataset to the `dataset` folder, in this document's folder

Example of how the SRCDS output should look whilst generating the dataset:

![test_bias](https://github.com/Rainyan/sourcemod-nt-ghost-distribution/assets/6595066/cd120483-a251-415a-a99a-c35cf6391cc0)

## Generating the images

### Prerequisites
- [Python](https://www.python.org/) version 3.10-3.14
  - Newer/older Python versions may or may not be compatible, you can try this by adjusting the `requires-python` value in the `pyproject.toml` manually
- The [uv package manager](https://docs.astral.sh/uv/)

### Steps

```bash
uv run main.py
```

- Adjust the Python script variables as required
- The resulting images will be generated in the `images` folder
