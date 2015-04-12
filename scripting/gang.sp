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
	CreateNative("Gang_GetClientGang", GetClientGang);
	CreateNative("Gang_GetGangName", GetGangName);
	
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
	
	RegConsoleCmd("sm_creategang", Command_CreateGang);
}

public void OnClientPutInServer(int client)
{
	Gang_PushClientArray(client);
}

public void OnClientDisconnect(int client)
{
	Gang_EraseClientArray(client);
}

public Action Command_CreateGang(int client, int args)
{
	PrintToChat(client, "CommunityID - %s", g_sClientID[client]);
	if(!g_bIsInGang[client] && g_iClientGang[client] == 0)
	{
		PrintToChat(client, "Sie könnten eine Gang erstellen, aber das wäre noch zu früh... :(");
	}
	else
	{
		PrintToChat(client, "Sie sind bereits in einer Gang!");
	}
}
