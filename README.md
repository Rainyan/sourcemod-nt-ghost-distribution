# sourcemod-nt-ghost-distribution
SourceMod plugin for Neotokyo that uniformly distributes the ghost spawn locations.

## TL;DR
* Compile the plugin in `addons/sourcemod/scripting`, and move the compiled .smx file to your server.
* Copy the `addons/sourcemod/gamedata/neotokyo/uniform_ghosts.txt` to your server.

## Background
Ghost spawns in NT approximately follow the pattern: `(prev_ghost_spawn_index + RandomInt(1,3)) % num_ghost_spawns`.

This means that for ghost spawn *G*, and *n* amount of ghost spawns total, the next chosen ghost spawn will always follow the pattern of:
```
random stride (1-3)          1     2     3
                      ┌──────↓─────↓─────↓
spawn index           | G   G+1   G+2   G+3   G+4   G+5   (...)   G+n |
```

While the PRNG used is uniform, limiting the random output to a stride of 1-3 means the overall spawn frequency is not.
The effect this will have on ghost distribution aggravates as the amount of total spawn points increases:

<table>
<tr>
  <td>
    <p>2 ghosts</p>
    <img alt="2 ghosts" src="https://github.com/Rainyan/sourcemod-nt-ghost-distribution/assets/6595066/f5acb305-2c3c-4668-8255-69d3e76141af" />
  </td>
  <td>
    <p>4 ghosts</p>
    <img alt="4 ghosts" src="https://github.com/Rainyan/sourcemod-nt-ghost-distribution/assets/6595066/d64fc500-213d-42e4-a94e-475854f25edc" />
  </td>
</tr>
<tr>
  <td>
    <p>6 ghosts</p>
    <img alt="6 ghosts" src="https://github.com/Rainyan/sourcemod-nt-ghost-distribution/assets/6595066/60bf262e-8015-45fd-a1d0-c29f0bac26b0" />
  </td>
  <td>
    <p>8 ghosts</p>
    <img alt="8 ghosts" src="https://github.com/Rainyan/sourcemod-nt-ghost-distribution/assets/6595066/48f53b86-2b0e-4701-9204-a8eb9f716b4f" />
  </td>
</tr>
<tr>
  <td>
    <p>16 ghosts</p>
    <img alt="16 ghosts" src="https://github.com/Rainyan/sourcemod-nt-ghost-distribution/assets/6595066/1bf1bdf3-9edb-4dcc-a564-bcad19c873af" />
  </td>
</tr>
</table>

This plugin patches the selection function to choose a uniformly random ghost spawnpoint:
![ghostspawn_sim_16_ghosts](https://github.com/Rainyan/sourcemod-nt-ghost-distribution/assets/6595066/8fb3083d-033f-41d2-b63a-4c075a795629)