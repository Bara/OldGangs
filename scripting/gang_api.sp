#pragma semicolon 1

#include <sourcemod>
#include <gang>

Handle g_hDatabase;

public Plugin myinfo = 
{
	name = "Gang - API Test",
	author = "Bara",
	description = "",
	version = "1.0.0",
	url = ""
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_gangapi", Command_GangAPI);
}

public void Gang_OnSQLConnected(Handle database)
{
	PrintToServer("(Gang_OnSQLConnected) Gang_OnSQLConnected called!");
	
	g_hDatabase = CloneHandle(database);
	
	PrintToServer("(Gang_OnSQLConnected) database: %d - g_hDatabase: %d", database, g_hDatabase);
}

public void Gang_OnGangCreated(int client, int iGang)
{
	PrintToChat(client, "(Gang_OnGangCreated) Gang_IsClientInGang - %d", Gang_IsClientInGang(client));
	PrintToChat(client, "(Gang_OnGangCreated) Gang ID - %d", iGang);
	
	char sName[64];
	Gang_GetGangName(iGang, sName, sizeof(sName));
	
	if(StrEqual(sName, "", false))
	{
		Format(sName, sizeof(sName), "keine Gang");
	}
	
	PrintToChat(client, "(Gang_OnGangCreated) Gang_GetGangName - %s", sName);
}

public void Gang_OnGangRename(int client, int iGang, const char[] oldname, const char[] newname)
{
	PrintToChat(client, "(Gang_OnGangRename) Gang ID - %d", iGang);
	PrintToChat(client, "(Gang_OnGangCreated) OldName: - %s", oldname);
	PrintToChat(client, "(Gang_OnGangCreated) NewName: - %s", newname);
}

public void Gang_OnGangLeft(int client, int iGang)
{
	PrintToChat(client, "(Gang_OnGangLeft) Gang_IsClientInGang - %d", Gang_IsClientInGang(client));
	PrintToChat(client, "(Gang_OnGangLeft) Gang ID - %d", iGang);
	
	char sName[64];
	Gang_GetGangName(iGang, sName, sizeof(sName));
	
	if(StrEqual(sName, "", false))
	{
		Format(sName, sizeof(sName), "keine Gang");
	}
	
	PrintToChat(client, "(Gang_OnGangLeft) Gang_GetGangName - %s", sName);
}

public void Gang_OnGangDelete(int client, int iGang, const char[] sGang)
{
	PrintToChat(client, "(Gang_OnGangDelete) Gang_IsClientInGang - %d", Gang_IsClientInGang(client));
	PrintToChat(client, "(Gang_OnGangDelete) Gang ID - %d", iGang);
	PrintToChat(client, "(Gang_OnGangDelete) Gang Name - %s", sGang);
}

public Action Command_GangAPI(int client, int args)
{
	PrintToChat(client, "(Command_GangAPI) Gang_IsClientInGang - %d", Gang_IsClientInGang(client));
	
	int iGang = Gang_GetClientGang(client);
	PrintToChat(client, "(Command_GangAPI) Gang_GetClientGang - %d", iGang);
	
	char sName[64];
	Gang_GetGangName(iGang, sName, sizeof(sName));
	
	if(StrEqual(sName, "", false))
	{
		Format(sName, sizeof(sName), "keine Gang");
	}
	
	PrintToChat(client, "(Command_GangAPI) Gang_GetGangName - %s", sName);
	
	return Plugin_Continue;
}
