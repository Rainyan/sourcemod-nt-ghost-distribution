# sourcemod-nt-ghost-distribution
SourceMod plugin for Neotokyo that uniformly distributes the ghost spawn locations.

Also check out the [alternative plugin for controlled ghost spawn sequences](https://github.com/softashell/nt-sourcemod-plugins/blob/master/scripting/nt_ghost_spawn_bias.sp)!
See the [FAQ](#faq) section for details on the differences between these two plugins.

## Build instructions
* Compile the plugin in `addons/sourcemod/scripting`, and move the compiled .smx file to your server.
* Copy the file in `addons/sourcemod/gamedata/neotokyo` to your server (create the "neotokyo" folder in gamedata, if it doesn't exist).

**If you're using SourceMod older than 1.11**, you also need a version of the [DHooks extension](https://forums.alliedmods.net/showpost.php?p=2588686) compatible with your SM version.

## FAQ
* What?
  * Default NT ghost spawns are not evenly random. This plugin fixes it.
* Does this plugin eliminate streaks of unlucky ghost spawns?
  * No. Just as with coin flipping, streaks are possible.
* The ghost spawned in the same location twice in a row!
  * This is intended–all results are equally likely, including getting the same exact spawn twice.
* What's the diffence between this and the [*nt_ghost_spawn_bias*](https://github.com/softashell/nt-sourcemod-plugins/blob/master/scripting/nt_ghost_spawn_bias.sp) plugin?
  * This plugin is focused on ensuring uniform distribution and nothing more.
    Soft's plugin implements a controlled bias of *n* same ghost spawns in a row, which can be used to
    play "sides" for the same ghost spawn point.
* Should I use both plugins?
  * The plugins won't interfere with each other, but if you wish to use Soft's plugin,
    you don't need this plugin.

## Background
*(optional reading, in case you're curious about the details)*

In Neotokyo, the ghost spawn selection is implemented as:

```asm
push    3
push    1
call    edx                             ; get random int in 1-3 range
mov     esi, eax
add     esi, [edi+260h]                 ; add index of previous ghost spawn to the random index
mov     eax, [edi+258h]                 ; number of ghost spawns
cmp     esi, eax
jl      short get_array_at_index_offset
sub     esi, eax                        ; modulo wrap
```

Or, in pseudocode:
`(prev_ghost_spawn_index + RandomInt(1,3)) % num_ghost_spawns`.

This means that for ghost spawn *G*, and *n* amount of ghost spawns total, the next chosen ghost spawn will (excluding the modulo wrap) follow the pattern of:
```
random stride (1-3)          1     2     3  ← next ghost spawn guaranteed to be one of these 3
                        ┌────↓─────↓─────↓
spawn index             G   G+1   G+2   G+3   G+4   G+5   (...)   Gₙ |
```

While the PRNG used is uniform, limiting the random output to a stride of 1-3 means the overall spawn frequency is not.
You could liken this to a dice that always rolled the previous roll plus 1, 2, or 3; if you just rolled a two, you know the next throw must result in either 2+1 (3), 2+2 (4), or 2+3 (5);
it is impossible for your next dice roll to be a 1, 2 or 6!
With a uniformly distributed (*"fair"*) dice, any previous rolls should not affect the current throw, and all 6 possible results should be equally likely.

This bias can be visualized by simulating a large number of NT rounds, and recording the ghost spawn positions' distribution.
A *"favourable ghost spawn"* in this instance is arbitrarily chosen as exactly half of the total spawn points, to demonstrate the effect of the bias.

Note the recorded distribution (blue) skewing to the right, away from the expected distribution (red), as the number of ghost spawn points increases:

<table>
<tr>
  <td>
    <p>2 possible ghost spawn positions</p>
    <img alt="2 ghosts" src="https://github.com/Rainyan/sourcemod-nt-ghost-distribution/assets/6595066/f5acb305-2c3c-4668-8255-69d3e76141af" />
  </td>
  <td>
    <p>4 possible ghost spawn positions</p>
    <img alt="4 ghosts" src="https://github.com/Rainyan/sourcemod-nt-ghost-distribution/assets/6595066/d64fc500-213d-42e4-a94e-475854f25edc" />
  </td>
</tr>
<tr>
  <td>
    <p>6 possible ghost spawn positions</p>
    <img alt="6 ghosts" src="https://github.com/Rainyan/sourcemod-nt-ghost-distribution/assets/6595066/60bf262e-8015-45fd-a1d0-c29f0bac26b0" />
  </td>
  <td>
    <p>8 possible ghost spawn positions</p>
    <img alt="8 ghosts" src="https://github.com/Rainyan/sourcemod-nt-ghost-distribution/assets/6595066/48f53b86-2b0e-4701-9204-a8eb9f716b4f" />
  </td>
</tr>
<tr>
  <td>
    <p>16 possible ghost spawn positions</p>
    <img alt="16 ghosts" src="https://github.com/Rainyan/sourcemod-nt-ghost-distribution/assets/6595066/1bf1bdf3-9edb-4dcc-a564-bcad19c873af" />
  </td>
</tr>
</table>

This plugin patches the selection function to choose uniformly from all possible locations–the blue line overlaps with the expected distribution in red:

![ghostspawn_sim_16_ghosts](https://github.com/Rainyan/sourcemod-nt-ghost-distribution/assets/6595066/8fb3083d-033f-41d2-b63a-4c075a795629)

If you want to verify the difference yourself, the simulation related stuff is also included in the repo, in the "tests" folder.
