#pragma semicolon 1

#include <sourcemod>
#include <gang>
#include <regex>

#define PLUGIN_AUTHOR "Bara"
#define PLUGIN_VERSION "1.0.0-dev"

#include "gang/global.sp"
#include "gang/cache.sp"
#include "gang/sql.sp"
#include "gang/native.sp"
#include "gang/cmd.sp"
#include "gang/stock.sp"
#include "gang/menu.sp"

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	g_hSQLConnected = CreateGlobalForward("Gang_OnSQLConnected", ET_Ignore, Param_Cell);
	g_hGangCreated = CreateGlobalForward("Gang_OnGangCreated", ET_Ignore, Param_Cell, Param_Cell);
	
	CreateNative("Gang_IsClientInGang", Native_IsClientInGang);
	CreateNative("Gang_GetClientGang", Native_GetClientGang);
	CreateNative("Gang_GetGangName", Native_GetGangName);
	
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
	
	g_cGangCreate = CreateConVar("gang_create_gang", "1", "Enable \"Create Gang\"?", _, true, 0.0, true, 1.0);
	g_cGangMinLen = CreateConVar("gang_create_min_length", "3", "Minimum length of gang name", _, true, 3.0, true, 8.0);
	g_cGangMaxLen = CreateConVar("gang_create_max_length", "8", "Maximum length of gang name", _, true, 3.0, true, 8.0);
	g_cGangRegex =  CreateConVar("gang_create_regex", "^[a-zA-Z0-9]+$", "Allowed characters in gang name");
	
	AutoExecConfig();
	
	RegConsoleCmd("sm_creategang", Command_CreateGang);
	RegConsoleCmd("sm_listgang", Command_ListGang);
}

public void OnClientPutInServer(int client)
{
	Gang_PushClientArray(client);
}

public void OnClientDisconnect(int client)
{
	Gang_EraseClientArray(client);
}
