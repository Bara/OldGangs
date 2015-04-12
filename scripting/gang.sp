#pragma semicolon 1

#include <sourcemod>
#include <gang>

#define PLUGIN_AUTHOR "Bara"
#define PLUGIN_VERSION "1.0.0-dev"

#include "gang/global.sp"
#include "gang/cache.sp"
#include "gang/sql.sp"
#include "gang/native.sp"

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	g_hSQLConnected = CreateGlobalForward("Gang_OnSQLConnected", ET_Ignore, Param_Cell);
	
	CreateNative("Gang_IsClientInGang", IsClientInGang);
	
	RegPluginLibrary("gang");
	
	return APLRes_Success;
}

public Plugin myinfo = 
{
	name = "Gang - Core",
	author = PLUGIN_AUTHOR,
	description = "",
	version = PLUGIN_VERSION,
	url = "gang.ovh"
};

public void OnPluginStart()
{
	Gang_CheckGame();
	Gang_CreateCache();
	Gang_SQLConnect();
}

public void OnClientPutInServer(int client)
{
	char sQuery[512];
	
	GetClientAuthId(client, AuthId_SteamID64, g_sClientID[client], sizeof(g_sClientID[]));
	
	Format(sQuery, sizeof(sQuery), "SELECT GangID, CommunityID, AccessLevel FROM gang_members WHERE CommunityID = '%s'", g_sClientID[client]);
	SQL_TQuery(g_hDatabase, TQuery_GangMembers, sQuery, GetClientUserId(client), DBPrio_Low);
}

public void OnClientDisconnect(int client)
{
	Gang_EraseClientArray(client);
}
