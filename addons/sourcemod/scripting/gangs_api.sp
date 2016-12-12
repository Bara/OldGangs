#pragma semicolon 1

#include <sourcemod>
#include <gangs>

Handle g_hDatabase;

public Plugin myinfo = 
{
	name = GANGS_NAME ... "API Test",
	author = GANGS_AUTHOR,
	description = GANGS_DESCRIPTION,
	version = GANGS_VERSION,
	url = GANGS_URL
};

public void OnPluginStart()
{
	if(Gangs_Loaded())
		SetFailState("Gangs not loaded!");
	
	RegConsoleCmd("sm_gangapi", Command_GangAPI);
}

public void Gangs_OnSQLConnected(Handle database)
{
	PrintToServer("(Gangs_OnSQLConnected) Gangs_OnSQLConnected called!");
	
	g_hDatabase = CloneHandle(database);
	
	PrintToServer("(Gangs_OnSQLConnected) database: %d - g_hDatabase: %d", database, g_hDatabase);
}

public void Gangs_OnGangCreated(int client, int iGang)
{
	PrintToChat(client, "(Gangs_OnGangCreated) Gangs_IsClientInGang - %d", Gangs_IsClientInGang(client));
	PrintToChat(client, "(Gangs_OnGangCreated) Gang ID - %d", iGang);
	
	char sName[64];
	Gangs_GetName(iGang, sName, sizeof(sName));
	
	if(StrEqual(sName, "", false))
	{
		Format(sName, sizeof(sName), "keine Gang");
	}
	
	PrintToChat(client, "(Gangs_OnGangCreated) Gangs_GetName - %s", sName);
}

public void Gangs_OnGangRename(int client, int iGang, const char[] oldname, const char[] newname)
{
	PrintToChat(client, "(Gangs_OnGangRename) Gang ID - %d", iGang);
	PrintToChat(client, "(Gangs_OnGangCreated) OldName: - %s", oldname);
	PrintToChat(client, "(Gangs_OnGangCreated) NewName: - %s", newname);
}

public void Gangs_OnGangLeft(int client, int iGang)
{
	PrintToChat(client, "(Gangs_OnGangLeft) Gangs_IsClientInGang - %d", Gangs_IsClientInGang(client));
	PrintToChat(client, "(Gangs_OnGangLeft) Gang ID - %d", iGang);
	
	char sName[64];
	Gangs_GetName(iGang, sName, sizeof(sName));
	
	if(StrEqual(sName, "", false))
	{
		Format(sName, sizeof(sName), "keine Gang");
	}
	
	PrintToChat(client, "(Gangs_OnGangLeft) Gangs_GetName - %s", sName);
}

public void Gangs_OnGangDelete(int client, int iGang, const char[] sGang)
{
	PrintToChat(client, "(Gangs_OnGangDelete) Gangs_IsClientInGang - %d", Gangs_IsClientInGang(client));
	PrintToChat(client, "(Gangs_OnGangDelete) Gang ID - %d", iGang);
	PrintToChat(client, "(Gangs_OnGangDelete) Gang Name - %s", sGang);
}

public Action Command_GangAPI(int client, int args)
{
	if(client < 1 || !IsClientInGame(client))
		return Plugin_Handled;
	
	PrintToChat(client, "(Command_GangAPI) Gangs_IsClientInGang - %d", Gangs_IsClientInGang(client));
	
	int iGang = Gangs_GetClientGang(client);
	PrintToChat(client, "(Command_GangAPI) Gangs_GetClientGang - %d", iGang);
	
	char sName[64];
	Gangs_GetName(iGang, sName, sizeof(sName));
	
	if(StrEqual(sName, "", false))
	{
		Format(sName, sizeof(sName), "keine Gang");
	}
	
	PrintToChat(client, "(Command_GangAPI) Gangs_GetName - %s", sName);
	
	return Plugin_Continue;
}
