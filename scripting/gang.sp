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
	g_hGangLeft = CreateGlobalForward("Gang_OnGangLeft", ET_Ignore, Param_Cell, Param_Cell);
	g_hGangDelete = CreateGlobalForward("Gang_OnGangDelete", ET_Ignore, Param_Cell, Param_Cell, Param_String);
	g_hGangRename = CreateGlobalForward("Gang_OnGangRename", ET_Ignore, Param_Cell, Param_Cell, Param_String, Param_String);
	
	CreateNative("Gang_IsClientInGang", Native_IsClientInGang);
	CreateNative("Gang_GetClientAccessLevel", Native_GetClientAccessLevel);
	CreateNative("Gang_GetClientGang", Native_GetClientGang);
	CreateNative("Gang_ClientLeftGang", Native_LeftClientGang);
	CreateNative("Gang_CreateClientGang", Native_CreateClientGang);
	CreateNative("Gang_DeleteClientGang", Native_DeleteClientGang);
	CreateNative("Gang_OpenClientGang", Native_OpenClientGang);
	CreateNative("Gang_RenameClientGang", Native_RenameClientGang);
	
	CreateNative("Gang_GetGangName", Native_GetGangName);
	CreateNative("Gang_GetGangPoints", Native_GetGangPoints);
	CreateNative("Gang_GetGangMaxMembers", Native_GetGangMaxMembers);
	CreateNative("Gang_GetGangMembersCount", Native_GetGangMembersCount);
	CreateNative("Gang_GetOnlinePlayerCount", Native_GetOnlinePlayerCount);
	
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
	
	// CreateGang
	g_cGangCreateEnable = CreateConVar("gang_create_enable", "1", "Enable \"Create Gang\"?", _, true, 0.0, true, 1.0);
	g_cGangCreateMinLen = CreateConVar("gang_create_min_length", "3", "Minimum length of gang name", _, true, 3.0, true, 8.0);
	g_cGangCreateMaxLen = CreateConVar("gang_create_max_length", "8", "Maximum length of gang name", _, true, 3.0, true, 8.0);
	g_cGangCreateRegex =  CreateConVar("gang_create_regex", "^[a-zA-Z0-9]+$", "Allowed characters in gang name");
	
	//RenameGang
	g_cGangRenameEnable = CreateConVar("gang_rename_enable", "1", "Enable \"Rename Gang\"?", _, true, 0.0, true, 1.0);
	g_cGangRenameRank = CreateConVar("gang_rename_rank", "6", "What rank is required?", _, true, 1.0, true, 6.0);
	g_cGangRenameCost = CreateConVar("gang_rename_cost", "2000", "How much costs this?");
	
	// General settings
	g_cGangMenuDisplayTime = CreateConVar("gang_menu_display_time", "15", "How long should be open the menu? (time will replaced every time)");
	
	AutoExecConfig();
	
	// sm_gang <NO ARGS>
	RegConsoleCmd("sm_gang", Command_Gang);
	
	// sm_creategang <GANG NAME>
	RegConsoleCmd("sm_creategang", Command_CreateGang);
	
	// sm_listgang <NO ARGS>
	RegConsoleCmd("sm_listgang", Command_ListGang);
	
	// sm_leftgang <NO ARGS>
	RegConsoleCmd("sm_leftgang", Command_LeftGang);
	
	// sm_deletegang <NO ARGS>
	RegConsoleCmd("sm_deletegang", Command_DeleteGang);
	
	// sm_renamegang <NEW GANG NAME>
	RegConsoleCmd("sm_renamegang", Command_RenameGang);
}

public void OnClientPutInServer(int client)
{
	Gang_PushClientArray(client);
}

public void OnClientDisconnect(int client)
{
	Gang_EraseClientArray(client);
}
