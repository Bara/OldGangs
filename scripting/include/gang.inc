#if defined _gang_included
 #endinput
#endif
#define _gang_included

enum ELOG_LEVEL
{
	DEFAULT = 0,
	TRACE,
	DEBUG,
	INFO,
	WARN,
	ERROR
};

#define GANG_NAME "Gang - "
#define GANG_AUTHOR "Bara"
#define GANG_DESCRIPTION "Coming soon..."
#define GANG_VERSION "1.0.0-dev"
#define GANG_URL "git.tf/Bara"

#define GANG_LEADER 6
#define GANG_COLEADER 5
#define GANG_SKILLER 4
#define GANG_INVITER 3
#define GANG_MEMBER 2
#define GANG_TRIAL 1

#define LoopClients(%1) for(int %1 = 1; %1 <= MaxClients; %1++) if(IsClientInGame(%1))

char g_sELogLevel[6][32] = {
	"default",
	"trace",
	"debug",
	"info",
	"warn",
	"error"
};

stock bool Gang_IsLoaded()
{
	return LibraryExists("gang");
}

stock void Gang_CheckGame()
{
	if(GetEngineVersion() != Engine_CSGO && GetEngineVersion() != Engine_CSS)
	{
		SetFailState("This plugin is for CSGO/CSS only.");
	}
}

stock void Log_File(const char[] path = "gang", const char[] file = "core", ELOG_LEVEL level = INFO, const char[] format, any ...)
{
	char sPath[PLATFORM_MAX_PATH + 1];
	char sLevelPath[PLATFORM_MAX_PATH + 1];
	char sFile[PLATFORM_MAX_PATH + 1];
	char sBuffer[1024];

	if(StrEqual(path, "", false))
	{
		BuildPath(Path_SM, sPath, sizeof(sPath), "logs");
	}
	else
	{
		BuildPath(Path_SM, sPath, sizeof(sPath), "logs/%s", path);
		
		if(!DirExists(sPath))
		{
			CreateDirectory(sPath, 755);
		}
	}

	if(level < TRACE || level > ERROR)
	{
		Format(sLevelPath, sizeof(sLevelPath), "%s", sPath);
	}
	else
	{
		Format(sLevelPath, sizeof(sLevelPath), "%s/%s", sPath, g_sELogLevel[level]);
	}

	
	if(!DirExists(sLevelPath))
	{
		CreateDirectory(sLevelPath, 755);
	}
	
	char sDate[32];
	FormatTime(sDate, sizeof(sDate), "%Y-%m-%d", GetTime());
	Format(sFile, sizeof(sFile), "%s/%s_%s.log", sLevelPath, file, sDate);

	VFormat(sBuffer, sizeof(sBuffer), format, 5);

	LogToFile(sFile, sBuffer);
}

forward void Gang_OnSQLConnected(Handle database);
forward void Gang_OnGangCreated(int client, int gangid);
forward void Gang_OnGangLeft(int client, int gangid);
forward void Gang_OnGangDelete(int client, int gangid, const char[] gangname);
forward void Gang_OnGangRename(int client, int gangid, const char[] oldgangname, const char[] newgangname);

native bool Gang_IsClientInGang(int client);
native int Gang_GetClientLevel(int client);
native int Gang_GetClientGang(int client);
native void Gang_ClientLeftGang(int client);
native void Gang_CreateClientGang(int client, const char[] gangname);
native void Gang_DeleteClientGang(int client, int gangid);
native void Gang_OpenClientGang(int client);
native void Gang_RenameClientGang(int client, int gangid, const char[] gangname);

native void Gang_GetName(int gangid, const char[] name, int maxlength);
native int Gang_GetPoints(int gangid);
native int Gang_AddPoints(int gangid, int points);
native int Gang_RemovePoints(int gangid, int points);
native int Gang_GetMaxMembers(int gangid);
native int Gang_GetMembersCount(int gangid);
native int Gang_GetOnlinePlayers(int gangid);

public SharedPlugin __pl_gang =
{
	name = "gang",
	file = "gang.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN

public __pl_gang_SetNTVOptional()
{
	MarkNativeAsOptional("Gang_IsClientInGang");
	MarkNativeAsOptional("Gang_GetClientLevel");
	MarkNativeAsOptional("Gang_GetClientGang");
	MarkNativeAsOptional("Gang_ClientLeftGang");
	MarkNativeAsOptional("Gang_CreateClientGang");
	MarkNativeAsOptional("Gang_DeleteClientGang");
	MarkNativeAsOptional("Gang_OpenClientGang");
	MarkNativeAsOptional("Gang_RenameClientGang");
	
	MarkNativeAsOptional("Gang_GetName");
	MarkNativeAsOptional("Gang_GetPoints");
	MarkNativeAsOptional("Gang_AddPoints");
	MarkNativeAsOptional("Gang_RemovePoints");
	MarkNativeAsOptional("Gang_GetMaxMembers");
	MarkNativeAsOptional("Gang_GetMembersCount");
	MarkNativeAsOptional("Gang_GetOnlinePlayers");
}
#endif
