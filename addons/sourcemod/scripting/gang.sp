#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <gang>
#include <regex>

// 3rd includes
#include <multicolors>

#include "gang/global.sp"
#include "gang/config.sp"
#include "gang/events.sp"
#include "gang/sqlconnect.sp"

// old structur
#include "gang/sql.sp"
#include "gang/native.sp"
#include "gang/stock.sp"

// new structur
#include "gang/shared.sp"
#include "gang/creategang.sp"
#include "gang/listgang.sp"
#include "gang/leftgang.sp"
#include "gang/menugang.sp"
#include "gang/deletegang.sp"
#include "gang/renamegang.sp"
#include "gang/gangchat.sp"

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	g_hSQLConnected = CreateGlobalForward("Gang_OnSQLConnected", ET_Ignore, Param_Cell);
	g_hGangCreated = CreateGlobalForward("Gang_OnGangCreated", ET_Ignore, Param_Cell, Param_Cell);
	g_hGangLeft = CreateGlobalForward("Gang_OnGangLeft", ET_Ignore, Param_Cell, Param_Cell);
	g_hGangDelete = CreateGlobalForward("Gang_OnGangDelete", ET_Ignore, Param_Cell, Param_Cell, Param_String);
	g_hGangRename = CreateGlobalForward("Gang_OnGangRename", ET_Ignore, Param_Cell, Param_Cell, Param_String, Param_String);
	
	CreateNative("Gang_IsClientInGang", Native_IsClientInGang);
	CreateNative("Gang_GetClientLevel", Native_GetClientAccessLevel);
	CreateNative("Gang_GetClientGang", Native_GetClientGang);
	CreateNative("Gang_ClientLeftGang", Native_LeftClientGang);
	CreateNative("Gang_CreateClientGang", Native_CreateClientGang);
	CreateNative("Gang_DeleteClientGang", Native_DeleteClientGang);
	CreateNative("Gang_OpenClientGang", Native_OpenClientGang);
	CreateNative("Gang_RenameClientGang", Native_RenameClientGang);
	CreateNative("Gang_GetRangName", Native_GetRangName);
	
	CreateNative("Gang_GetName", Native_GetGangName);
	CreateNative("Gang_GetPoints", Native_GetGangPoints);
	CreateNative("Gang_AddPoints", Native_AddGangPoints);
	CreateNative("Gang_RemovePoints", Native_RemoveGangPoints);
	CreateNative("Gang_GetMaxMembers", Native_GetGangMaxMembers);
	CreateNative("Gang_GetMembersCount", Native_GetGangMembersCount);
	CreateNative("Gang_GetOnlinePlayers", Native_GetOnlinePlayerCount);
	
	RegPluginLibrary("gang");
	
	return APLRes_Success;
}

public Plugin myinfo = 
{
	name = GANG_NAME ... "Core",
	author = GANG_AUTHOR,
	description = GANG_DESCRIPTION,
	version = GANG_VERSION,
	url = GANG_URL
};

public void OnPluginStart()
{
	Gang_CheckGame();
	Gang_CreateCache();
	Gang_SQLConnect();
	
	CreateConfig();
	
	RegConsoleCmd("sm_gang", Command_Gang);
	RegConsoleCmd("sm_g", Command_GangChat);
	RegConsoleCmd("sm_creategang", Command_CreateGang);
	RegConsoleCmd("sm_listgang", Command_ListGang);
	RegConsoleCmd("sm_leftgang", Command_LeftGang);
	RegConsoleCmd("sm_deletegang", Command_DeleteGang);
	RegConsoleCmd("sm_renamegang", Command_RenameGang);
	
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("bomb_planted", Event_BombPlanted);
	HookEvent("bomb_exploded", Event_BombExploded);
	HookEvent("bomb_defused", Event_BombDefused);
	HookEvent("hostage_follows", Event_HostageFollow);
	HookEvent("hostage_rescued", Event_HostageRescued);
	HookEvent("vip_escaped", Event_VipEscape);
	HookEvent("vip_killed", Event_VipKilled);
	HookEvent("player_changename", Event_ChangeName);
}

public void OnClientPutInServer(int client)
{
	Format(g_sClientID[client], sizeof(g_sClientID[]), "0");
	Gang_PushClientArray(client);
}

public void OnClientDisconnect(int client)
{
	Gang_EraseClientArray(client);
	Format(g_sClientID[client], sizeof(g_sClientID[]), "0");
}
