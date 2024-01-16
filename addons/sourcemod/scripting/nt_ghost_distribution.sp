#include <sourcemod>
#include <dhooks>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "0.1.0"


public Plugin myinfo = {
	name = "NT Ghost Distribution",
	description = "Uniformly distribute ghost spawn positions",
	author = "Rain",
	version = PLUGIN_VERSION,
	url = "https://github.com/Rainyan/sourcemod-nt-ghost-distribution"
};

public void OnPluginStart()
{
	GameData gd = LoadGameConfigFile("neotokyo/ghost_distribution");
	if (!gd)
	{
		SetFailState("Failed to load GameData");
	}
	DynamicDetour dd = DynamicDetour.FromConf(gd, "Fn_GetGhostSpawnSpot");
	if (!dd)
	{
		SetFailState("Failed to create dynamic detour");
	}
	if (!dd.Enable(Hook_Pre, GetGhostSpawnSpot))
	{
		SetFailState("Failed to detour");
	}
	delete dd;
	delete gd;
}

MRESReturn GetGhostSpawnSpot(Address pThis, DHookReturn hReturn)
{
	int n_spawns = LoadFromAddress(pThis + view_as<Address>(0x258), NumberType_Int32);
	int array_index = GetURandomInt() % n_spawns;
	StoreToAddress(pThis + view_as<Address>(0x260), array_index, NumberType_Int32);
	Address ghost_spawnpoints_array = LoadFromAddress(pThis + view_as<Address>(0x24C), NumberType_Int32);
	Address offset = view_as<Address>(array_index * 4); // nth pointer
	hReturn.Value = LoadFromAddress(ghost_spawnpoints_array + offset, NumberType_Int32);
	return MRES_Supercede;
}