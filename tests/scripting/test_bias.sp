/*
	Test plugin for generating some statistics about sequential ghost spawn positions.
	Usage:
		- Place the corresponding BSP files in the server's maps folder
		- Changelevel to one of the BSPs you want to test
		- Add 2 bots to the server with bot_add (requires sv_cheats 1), so the ghost will spawn
		- Set the NUM_GHOST_SPAWN_POINTS preprocessor constant to the number matching that map
		- Recompile and place this plugin in the server's SourceMod plugins path
		- Reload this plugin if it doesn't auto-activate
		- Wait until tests completion (progress shown in the server's console output)
		- The generated dataset will be written in the server's "NeotokyoSource" root folder
*/

#include <sourcemod>
#include <sdktools>

static Handle file = null;

// Number of rounds to simulate.
// This will take 1/tickrate * NUM_ITERATIONS / 60 minutes to complete.
#define NUM_ITERATIONS 100000

#define NUM_GHOST_SPAWN_POINTS 16
#assert NUM_GHOST_SPAWN_POINTS % 2 == 0 // assuming even number of spawns

float ghostpos[NUM_GHOST_SPAWN_POINTS][3] = {
#if NUM_GHOST_SPAWN_POINTS == 2
	{ -498.459991, -1028.829956, 1.000000 },
	{ -498.459991, -1156.829956, 1.000000 },
#endif
#if NUM_GHOST_SPAWN_POINTS == 4
	{ -370.459991, -1028.829956, 1.000000 },
	{ -498.459991, -1028.829956, 1.000000 },
	{ -370.459991, -1156.829956, 1.000000 },
	{ -498.459991, -1156.829956, 1.000000 },
#endif
#if NUM_GHOST_SPAWN_POINTS == 6
	{ -242.460006, -1028.829956, 1.000000 },
	{ -370.459991, -1028.829956, 1.000000 },
	{ -498.459991, -1028.829956, 1.000000 },
	{ -242.460006, -1156.829956, 1.000000 },
	{ -370.459991, -1156.829956, 1.000000 },
	{ -498.459991, -1156.829956, 1.000000 },
#endif
#if NUM_GHOST_SPAWN_POINTS == 8
	{ -114.459999, -1028.829956, 1.000000 },
	{ -242.460006, -1028.829956, 1.000000 },
	{ -370.459991, -1028.829956, 1.000000 },
	{ -498.459991, -1028.829956, 1.000000 },
	{ -114.459999, -1156.829956, 1.000000 },
	{ -242.460006, -1156.829956, 1.000000 },
	{ -370.459991, -1156.829956, 1.000000 },
	{ -498.459991, -1156.829956, 1.000000 },
#endif
#if NUM_GHOST_SPAWN_POINTS == 16
	{ 141.539993, -900.825988, 1.000000 },
	{ 13.540300, -900.825988, 1.000000 },
	{ -114.459999, -900.825988, 1.000000 },
	{ -242.460006, -900.825988, 1.000000 },
	{ 141.539993, -1028.829956, 1.000000 },
	{ 13.540300, -1028.829956, 1.000000 },
	{ -114.459999, -1028.829956, 1.000000 },
	{ -242.460006, -1028.829956, 1.000000 },
	{ -370.459991, -1028.829956, 1.000000 },
	{ -498.459991, -1028.829956, 1.000000 },
	{ 141.539993, -1156.829956, 1.000000 },
	{ 13.540300, -1156.829956, 1.000000 },
	{ -114.459999, -1156.829956, 1.000000 },
	{ -242.460006, -1156.829956, 1.000000 },
	{ -370.459991, -1156.829956, 1.000000 },
	{ -498.459991, -1156.829956, 1.000000 },
#endif
};

public void OnPluginStart()
{
	if (!HookEventEx("game_round_start", Event_RoundStart, EventHookMode_Post))
	{
		SetFailState("Failed to hook round start");
	}
}

public void OnMapStart()
{
	char mapbuff[PLATFORM_MAX_PATH];
	GetCurrentMap(mapbuff, sizeof(mapbuff));
	// Assuming map name format of ghostspawn_<n>.bsp, where <n> == NUM_GHOST_SPAWN_POINTS
	if (StrContains(mapbuff, "ghostspawn_") != 0)
	{
		SetFailState("Unsupported map file");
	}

	char timebuff[32];
	FormatTime(timebuff, sizeof(timebuff), "%F %H:%M:%S");
	PrintToServer("- %s Ghost spawn position simulation for %d ghost spawns start! %d iterations, ETA: %d minutes",
		timebuff,
		NUM_GHOST_SPAWN_POINTS,
		NUM_ITERATIONS,
		RoundToNearest(GetTickInterval() * NUM_ITERATIONS / 60));
}

// This has been verified to be evenly distributed amongst all capzones over 10k iterations,
// ie. all spawnpoints will receive 1/num_spawns percent of the spawns within rounding error.
// However, the sequential favourable spawns are not, which is the more interesting thing
// to measure from this plugin's data.
public void OnGameFrame()
{
	ServerCommand("neo_restart_this 1");
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	int ghost_edict = -1;
	int num_ghosts_found;
	int i;
	char buffer[32];
	for (i = MaxClients + 1; i < GetMaxEntities(); ++i)
	{
		if (!IsValidEdict(i) || !GetEdictClassname(i, buffer, sizeof(buffer)))
		{
			continue;
		}
		if (!StrEqual(buffer, "weapon_ghost"))
		{
			continue;
		}
		num_ghosts_found += 1;
		if (num_ghosts_found > 1)
		{
			SetFailState("Found multiple ghosts");
		}
		ghost_edict = i;
	}
	if (ghost_edict == -1)
	{
		SetFailState("Couldn't find the ghost!");
	}

	float pos[3];
	GetEntPropVector(ghost_edict, Prop_Data, "m_vecOrigin", pos);

	for (i = 0; i < sizeof(ghostpos); ++i)
	{
		// Ghost seems to spawn 32 units above the point.
		// Adding slight offset to compensate for IEEE 754 representation inaccuracy.
		if (VectorsEqual(pos, ghostpos[i], 32.1))
		{
			LogStreak(i);
			LogGhostSpawnPosition(i);
			return;
		}
	}

	SetFailState(
		"Failed to find the corresponding spawn point for ghost location: %f %f %f",
		pos[0], pos[1], pos[2]
	);
}

void LogGhostSpawnPosition(int index)
{
	static int iteration = 0;
	static int spawn_count[NUM_GHOST_SPAWN_POINTS];
	spawn_count[index] += 1;
	int total;

	for (int i = 0; i < sizeof(spawn_count); ++i)
	{
		total += spawn_count[i];
	}

	if (iteration >= NUM_ITERATIONS)
	{
		if (file != INVALID_HANDLE)
		{
			WriteFileString(file, "\0", false); // null terminator
			CloseHandle(file);
		}
		char pluginname[PLATFORM_MAX_PATH];
		GetPluginFilename(INVALID_HANDLE, pluginname, sizeof(pluginname));
		PrintToServer("- Total: %f", total);
		PrintToServer("- Stats:");
		for (int i = 0; i < sizeof(spawn_count); ++i)
		{
			PrintToServer("  - Spawn %d: %d (%f %%)", i, spawn_count[i], spawn_count[i] / total);
		}
		PrintToServer("- Done; unloading the test plugin now.");
		ServerCommand("sm plugins unload %s", pluginname);
	}

	iteration += 1;
	// Display progress in one percent increments, so it doesn't completely spam the server stdout
	if (iteration % (NUM_ITERATIONS / 100) == 0)
	{
		PrintToServer("- Progress: %d %%", RoundToNearest((float(iteration) / NUM_ITERATIONS) * 100));
	}
}

void LogStreak(int index)
{
	// Choosing arbitrarily to represent the lower half of spawns for one team,
	// and the upper half for the other, because actual spawns don't matter for the data set.
	// This assumes an even number of ghost spawns, total, and a scenario where
	// exactly half of the spawns favour each team. Obviously this is not the case for all
	// real maps, but point of this simulation is to test the sequential distribution
	// between the pseudorandomly chosen spawns.
	int midpoint = NUM_GHOST_SPAWN_POINTS / 2;
	int favours = index < midpoint ? 0 : 1;

	if (file == null)
	{
		char filename[PLATFORM_MAX_PATH];
		// The Python data visualization script expects this exact filename format.
		Format(filename, sizeof(filename),
			"test_probabilities_streak_%dghost.txt",
			NUM_GHOST_SPAWN_POINTS);
		if (FileExists(filename))
		{
			SetFailState("File already exists: \"%s\"", filename);
		}
		file = OpenFile(filename, "a");
		if (file == null)
		{
			SetFailState("Failed to open file");
		}
	}

	static int nth_call = 0;
	nth_call += 1;
	static int last_favours = -1;
	static int streak = 0;

#define MAX_NUMBER_STRLEN 6 // strlen(str(NUM_ITERATIONS))
	// Allocate for 100th of the worst-case total data, because not enough stack for the whole thing.
	static char buffer[
		NUM_ITERATIONS *
		((NUM_GHOST_SPAWN_POINTS + 1) *
		(MAX_NUMBER_STRLEN + 1) + 1) / 100
	];

	if (last_favours == -1)
	{
		streak = 1;
	}
	else if (last_favours != favours)
	{
		char smallbuff[32];
		// Note that the Python data visualization script assumes this format,
		// so if you change this, it'll need tweaking, also.
		Format(smallbuff, sizeof(smallbuff), "%d\n", streak);
		if (StrCat(buffer, sizeof(buffer), smallbuff) == 0)
		{
			SetFailState("Failed to write to buffer");
		}
		streak = 1;
	}
	else
	{
		++streak;
	}

	last_favours = favours;
	// Stagger the writes in one percent increments
	if (nth_call % (NUM_ITERATIONS / 100) == 0)
	{
		WriteFileString(file, buffer, false);
		// Zero the buffer after write, to be safe. Probably overkill but whatever.
		for (int i = 0; i < sizeof(buffer); ++i)
		{
			buffer[i] = 0;
		}
	}
}

stock bool VectorsEqual(const float v1[3], const float v2[3], const float max_ulps = 0.0)
{
    // Needs to exactly equal.
    if (max_ulps == 0) {
        return v1[0] == v2[0] && v1[1] == v2[1] && v1[2] == v2[2];
    }
    // Allow an inaccuracy of size max_ulps.
    else {
        if (FloatAbs(v1[0] - v2[0]) > max_ulps) { return false; }
        if (FloatAbs(v1[1] - v2[1]) > max_ulps) { return false; }
        if (FloatAbs(v1[2] - v2[2]) > max_ulps) { return false; }
        return true;
    }
}