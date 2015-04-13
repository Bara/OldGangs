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
	RegConsoleCmd("sm_gangapi", Command_IsInGang);
}

public void Gang_OnSQLConnected(Handle database)
{
	PrintToServer("Gang_OnSQLConnected called!");
	
	g_hDatabase = CloneHandle(database);
	
	PrintToServer("database: %d - g_hDatabase: %d", database, g_hDatabase);
}

public Action Command_IsInGang(int client, int args)
{
	PrintToChat(client, "Gang_IsClientInGang - %d", Gang_IsClientInGang(client));
	
	int iGang = Gang_GetClientGang(client);
	PrintToChat(client, "Gang_GetClientGang - %d", Gang_GetClientGang(client));
	
	char sName[64];
	Gang_GetGangName(iGang, sName, sizeof(sName));
	
	if(StrEqual(sName, "", false))
	{
		Format(sName, sizeof(sName), "keine Gang");
	}
	
	PrintToChat(client, "Gang_GetClientName - %s", sName);
	
	return Plugin_Continue;
}
