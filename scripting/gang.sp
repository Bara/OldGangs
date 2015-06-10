#pragma semicolon 1
#pragma newdecls required

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
	CreateNative("Gang_AddGangPoints", Native_AddGangPoints);
	CreateNative("Gang_RemoveGangPoints", Native_RemoveGangPoints);
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
	
	// PointsGang
	g_cGangPointsEnable = CreateConVar("gang_points_enable", "1", "Enable \"Earning Points\"?");
	g_cGangPointsBots = CreateConVar("gang_points_bots", "1", "Get points for killing bots?");
	g_cGangPointsKill = CreateConVar("gang_points_kill", "1", "How much points for a \"normal kill\"?");
	g_cGangPointsKnife = CreateConVar("gang_points_knife", "2", "How much points for a \"knife kill\"?");
	g_cGangPointsGrenade = CreateConVar("gang_points_grenade", "2", "How much points for a \"grenade kill\"?");
	g_cGangPointsAssists = CreateConVar("gang_points_assist", "1", "How much points for a \"assist kill\"?");
	g_cGangPointsHeadshot = CreateConVar("gang_points_headshot", "1",  "How much extra points for a \"headshot kill\"?");
	g_cGangPointsPistol = CreateConVar("gang_points_pistol", "1", "How much extra points for a \"kill with pistol\"?");
	g_cGangPointsHostageFollow = CreateConVar("gang_points_hostage_follows", "1", "How much points for \"hostage_follows\"?");
	g_cGangPointsHostageRescue = CreateConVar("gang_points_hostage_rescued", "2", "How much points for \"hostage_rescued\"?");
	g_cGangPointsBombPlanted = CreateConVar("gang_points_bomb_planted", "1", "How much points for \"bomb_planted\"?");
	g_cGangPointsBombExploded = CreateConVar("gang_points_bomb_exploded", "2", "How much points for \"bomb_exploded\"?");
	g_cGangPointsBombDefused = CreateConVar("gang_points_bomb_defused", "3", "How much points for \"bomb_defused\"?");
	g_cGangPointsVipEscape = CreateConVar("gang_points_vip_escaped", "2", "How much points for \"vip_escaped\"?");
	g_cGangPointsVipKilled = CreateConVar("gang_points_vip_killed", "2", "How much points for \"vip_killed\"?");
	
	// General settings
	g_cGangMenuDisplayTime = CreateConVar("gang_menu_display_time", "15", "How long should be open the menu? (time will replaced every time)");
	
	AutoExecConfig();
	
	// Commands
	RegConsoleCmd("sm_gang", Command_Gang);
	RegConsoleCmd("sm_creategang", Command_CreateGang);
	RegConsoleCmd("sm_listgang", Command_ListGang);
	RegConsoleCmd("sm_leftgang", Command_LeftGang);
	RegConsoleCmd("sm_deletegang", Command_DeleteGang);
	RegConsoleCmd("sm_renamegang", Command_RenameGang);
	
	//Events
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("bomb_planted", Event_BombPlanted);
	HookEvent("bomb_exploded", Event_BombExploded);
	HookEvent("bomb_defused", Event_BombDefused);
	HookEvent("hostage_follows", Event_HostageFollow);
	HookEvent("hostage_rescued", Event_HostageRescued);
	HookEvent("vip_escaped", Event_VipEscape);
	HookEvent("vip_killed", Event_VipKilled);
}

public void OnClientPutInServer(int client)
{
	Gang_PushClientArray(client);
}

public void OnClientDisconnect(int client)
{
	Gang_EraseClientArray(client);
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("attacker"));
	int victim = GetClientOfUserId(event.GetInt("userid"));
	bool headshot = event.GetBool("headshot");
	char sWeapon[64];
	event.GetString("weapon", sWeapon, sizeof(sWeapon));
	
	if(g_cGangPointsEnable.BoolValue && IsClientInGame(client) && IsClientInGame(victim) && !IsFakeClient(client) && Gang_IsClientInGang(client))
	{
		if((IsFakeClient(victim) && g_cGangPointsBots.BoolValue))
		{
			if(GetClientTeam(client) != GetClientTeam(victim))
			{
				int points = 0;
				
				if(headshot)
					points += g_cGangPointsHeadshot.IntValue;
				
				if(IsWeaponSecondary(sWeapon))
					points += g_cGangPointsPistol.IntValue;
				else if(IsWeaponKnife(sWeapon))
					points += g_cGangPointsKnife.IntValue;
				else if(IsWeaponGrenade(sWeapon))
					points += g_cGangPointsGrenade.IntValue;
				else
					points += g_cGangPointsKill.IntValue;
				
				Gang_AddGangPoints(Gang_GetClientGang(client), points);
				
				if(GetEngineVersion() == Engine_CSGO)
				{
					int assister = GetClientOfUserId(event.GetInt("assister"));
					
					if(IsClientInGame(assister) && !IsFakeClient(assister) && (GetClientTeam(assister) != GetClientTeam(victim)))
					{
						int apoints = 0;
					
						if(headshot)
							apoints += g_cGangPointsHeadshot.IntValue;
						
						apoints += g_cGangPointsAssists.IntValue;
						
						Gang_AddGangPoints(Gang_GetClientGang(assister), apoints);
					}
				}
			}
		}
	}
}

public Action Event_BombPlanted(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if(g_cGangPointsEnable.BoolValue && IsClientInGame(client))
	{
		Gang_AddGangPoints(Gang_GetClientGang(client), g_cGangPointsBombPlanted.IntValue);
	}
}

public Action Event_BombExploded(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if(g_cGangPointsEnable.BoolValue && IsClientInGame(client))
	{
		Gang_AddGangPoints(Gang_GetClientGang(client), g_cGangPointsBombExploded.IntValue);
	}
}

public Action Event_BombDefused(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if(g_cGangPointsEnable.BoolValue && IsClientInGame(client))
	{
		Gang_AddGangPoints(Gang_GetClientGang(client), g_cGangPointsBombDefused.IntValue);
	}
}

public Action Event_HostageFollow(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if(g_cGangPointsEnable.BoolValue && IsClientInGame(client))
	{
		Gang_AddGangPoints(Gang_GetClientGang(client), g_cGangPointsHostageFollow.IntValue);
	}
}

public Action Event_HostageRescued(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if(g_cGangPointsEnable.BoolValue && IsClientInGame(client))
	{
		Gang_AddGangPoints(Gang_GetClientGang(client), g_cGangPointsHostageRescue.IntValue);
	}
}

public Action Event_VipEscape(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if(g_cGangPointsEnable.BoolValue && IsClientInGame(client))
	{
		Gang_AddGangPoints(Gang_GetClientGang(client), g_cGangPointsVipEscape.IntValue);
	}
}

public Action Event_VipKilled(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if(g_cGangPointsEnable.BoolValue && IsClientInGame(client))
	{
		Gang_AddGangPoints(Gang_GetClientGang(client), g_cGangPointsVipKilled.IntValue);
	}
}
