/*

	Done (need tests)
		- Create
		- Delete
		- Rename
		- Left
		- new mainmenu
		- Renamed some natives
		
		- List all gangs
		- Natives
		- Forwards

	ToDo:
		- Menu Designs
		- Create Gang via. Store (alongub)
		- Rename (not sure)
		- Invite System (more cvars, max members, ...)
		- Points System (not sure)
		- List all online gangs

*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <gang>
#include <regex>

#include "gang/global.sp"
#include "gang/config.sp"

// old structur
#include "gang/cache.sp"
#include "gang/sql.sp"
#include "gang/native.sp"
#include "gang/cmd.sp"
#include "gang/stock.sp"
#include "gang/menu.sp"

// new structur
#include "gang/shared.sp"
#include "gang/creategang.sp"
#include "gang/listgang.sp"
#include "gang/deletegang.sp"

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
				
				Gang_AddPoints(Gang_GetClientGang(client), points);
				
				if(GetEngineVersion() == Engine_CSGO)
				{
					int assister = GetClientOfUserId(event.GetInt("assister"));
					
					if(IsClientInGame(assister) && !IsFakeClient(assister) && (GetClientTeam(assister) != GetClientTeam(victim)))
					{
						int apoints = 0;
					
						if(headshot)
							apoints += g_cGangPointsHeadshot.IntValue;
						
						apoints += g_cGangPointsAssists.IntValue;
						
						Gang_AddPoints(Gang_GetClientGang(assister), apoints);
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
		Gang_AddPoints(Gang_GetClientGang(client), g_cGangPointsBombPlanted.IntValue);
	}
}

public Action Event_BombExploded(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if(g_cGangPointsEnable.BoolValue && IsClientInGame(client))
	{
		Gang_AddPoints(Gang_GetClientGang(client), g_cGangPointsBombExploded.IntValue);
	}
}

public Action Event_BombDefused(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if(g_cGangPointsEnable.BoolValue && IsClientInGame(client))
	{
		Gang_AddPoints(Gang_GetClientGang(client), g_cGangPointsBombDefused.IntValue);
	}
}

public Action Event_HostageFollow(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if(g_cGangPointsEnable.BoolValue && IsClientInGame(client))
	{
		Gang_AddPoints(Gang_GetClientGang(client), g_cGangPointsHostageFollow.IntValue);
	}
}

public Action Event_HostageRescued(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if(g_cGangPointsEnable.BoolValue && IsClientInGame(client))
	{
		Gang_AddPoints(Gang_GetClientGang(client), g_cGangPointsHostageRescue.IntValue);
	}
}

public Action Event_VipEscape(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if(g_cGangPointsEnable.BoolValue && IsClientInGame(client))
	{
		Gang_AddPoints(Gang_GetClientGang(client), g_cGangPointsVipEscape.IntValue);
	}
}

public Action Event_VipKilled(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if(g_cGangPointsEnable.BoolValue && IsClientInGame(client))
	{
		Gang_AddPoints(Gang_GetClientGang(client), g_cGangPointsVipKilled.IntValue);
	}
}

public Action Event_ChangeName(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	char newname[MAX_NAME_LENGTH];
	
	event.GetString("newname", newname, sizeof(newname));
	CheckName(client, newname);
}

