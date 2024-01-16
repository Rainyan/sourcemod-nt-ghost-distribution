Generating the dataset:

		- Compile the VMFs from mapsrc & place the corresponding BSP files in the server's maps folder
		- Changelevel to one of the BSPs you want to test
		- Add 2 bots to the server with bot_add (requires sv_cheats 1), so the ghost will spawn
		- Set the NUM_GHOST_SPAWN_POINTS preprocessor constant to the number matching that map
		- Recompile and place the plugin in the server's SourceMod plugins path
		- Reload the plugin if it doesn't auto-activate
		- Wait until tests completion (progress shown in the server's console output)
		- The generated dataset will be written in the server's "NeotokyoSource" root folder
		- Move the dataset to this relative path's dataset folder.

Generating the images:

```
pip install -U pipenv
pipenv install .
pipenv run pip install -r requirements
pipenv run python visualize.py
```

Adjust the Python script variables as required.
