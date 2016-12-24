#pragma semicolon 1

#include <sourcemod>
#include <gangs>
#include <multicolors>

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
	if(!Gangs_Loaded())
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
	CPrintToChat(client, "(Gangs_OnGangCreated) Gangs_IsClientInGang - %d", Gangs_IsClientInGang(client));
	CPrintToChat(client, "(Gangs_OnGangCreated) Gang ID - %d", iGang);
	
	char sName[64];
	Gangs_GetName(iGang, sName, sizeof(sName));
	
	if(StrEqual(sName, "", false))
	{
		Format(sName, sizeof(sName), "keine Gang");
	}
	
	CPrintToChat(client, "(Gangs_OnGangCreated) Gangs_GetName - %s", sName);
}

public void Gangs_OnGangRename(int client, int iGang, const char[] oldname, const char[] newname)
{
	CPrintToChat(client, "(Gangs_OnGangRename) Gang ID - %d", iGang);
	CPrintToChat(client, "(Gangs_OnGangCreated) OldName: - %s", oldname);
	CPrintToChat(client, "(Gangs_OnGangCreated) NewName: - %s", newname);
}

public void Gangs_OnGangLeft(const char[] communityid, const char[] name, int gangid)
{
	CPrintToChatAll("(Gangs_OnGangLeft) CommunityID - %s", communityid);
	CPrintToChatAll("(Gangs_OnGangLeft) Name - %s", name);
	CPrintToChatAll("(Gangs_OnGangLeft) Gang ID - %d", gangid);
	
	char sName[64];
	Gangs_GetName(gangid, sName, sizeof(sName));
	
	if(StrEqual(sName, "", false))
		Format(sName, sizeof(sName), "keine Gang");
	
	CPrintToChatAll("(Gangs_OnGangLeft) Gangs_GetName - %s", sName);
}

public void Gangs_OnGangDelete(int client, int iGang, const char[] sGang)
{
	CPrintToChat(client, "(Gangs_OnGangDelete) Gangs_IsClientInGang - %d", Gangs_IsClientInGang(client));
	CPrintToChat(client, "(Gangs_OnGangDelete) Gang ID - %d", iGang);
	CPrintToChat(client, "(Gangs_OnGangDelete) Gang Name - %s", sGang);
}

public Action Command_GangAPI(int client, int args)
{
	if (!Gangs_IsClientValid(client) )
		return Plugin_Handled;
	
	CPrintToChat(client, "(Command_GangAPI) Gangs_IsClientInGang - %d", Gangs_IsClientInGang(client));
	
	int iGang = Gangs_GetClientGang(client);
	CPrintToChat(client, "(Command_GangAPI) Gangs_GetClientGang - %d", iGang);
	
	char sName[64];
	Gangs_GetName(iGang, sName, sizeof(sName));
	
	if(StrEqual(sName, "", false))
	{
		Format(sName, sizeof(sName), "keine Gang");
	}
	
	CPrintToChat(client, "(Command_GangAPI) Gangs_GetName - %s", sName);
	
	return Plugin_Continue;
}

public void Gangs_OnClientJoinedGang(int client, int gangid)
{
	char sGang[64];
	Gangs_GetName(gangid, sGang, sizeof(sGang));
	
	CPrintToChatAll("(Gangs_OnClientJoinedGang) Client: %N - GangID: %d - Gang: %s", client, gangid, sGang);
}
