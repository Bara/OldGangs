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
	
}

public void Gang_OnSQLConnected(Handle database)
{
	PrintToServer("Gang_OnSQLConnected called!");
	
	g_hDatabase = CloneHandle(database);
	
	PrintToServer("database: %d - g_hDatabase: %d", database, g_hDatabase);
}