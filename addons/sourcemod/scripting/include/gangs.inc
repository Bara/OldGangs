#if defined _gangs_included
 #endinput
#endif
#define _gangs_included

enum ELOG_LEVEL
{
	DEFAULT = 0,
	TRACE,
	DEBUG,
	INFO,
	WARN,
	ERROR
};

#define GANGS_NAME "Gangs - "
#define GANGS_AUTHOR "Bara"
#define GANGS_DESCRIPTION "Coming soon..."
#define GANGS_VERSION "1.0.0-dev"
#define GANGS_URL "github.com/Bara20/Gangs"

#define GANGS_LEADER 6
#define GANGS_COLEADER 5
#define GANGS_SKILLER 4
#define GANGS_INVITER 3
#define GANGS_MEMBER 2
#define GANGS_TRIAL 1

#define LoopClients(%1) for(int %1 = 1; %1 <= MaxClients; %1++) if(IsClientInGame(%1))

char g_sELogLevel[6][32] = {
	"default",
	"trace",
	"debug",
	"info",
	"warn",
	"error"
};

stock bool Gangs_Loaded()
{
	return LibraryExists("gangs");
}

stock void Gangs_CheckGame()
{
	if(GetEngineVersion() != Engine_CSGO && GetEngineVersion() != Engine_CSS)
	{
		SetFailState("This plugin is for CSGO/CSS only.");
	}
}

stock void Log_File(const char[] path = "gangs", const char[] file = "core", ELOG_LEVEL level = INFO, const char[] format, any ...)
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

forward void Gangs_OnSQLConnected(Handle database);
forward void Gangs_OnGangCreated(int client, int gangid);
forward void Gangs_OnGangLeft(int client, int gangid);
forward void Gangs_OnGangDelete(int client, int gangid, const char[] gangname);
forward void Gangs_OnGangRename(int client, int gangid, const char[] oldgangname, const char[] newgangname);

native bool Gangs_IsClientInGang(int client);
native int Gangs_GetClientLevel(int client);
native int Gangs_GetClientGang(int client);
native void Gangs_ClientLeftGang(int client);
native void Gangs_CreateClientGang(int client, const char[] gangname);
native void Gangs_DeleteClientGang(int client, int gangid);
native void Gangs_OpenClientGang(int client);
native void Gangs_RenameClientGang(int client, int gangid, const char[] gangname);
native void Gangs_GetRangName(int rang, const char[] name, int maxlength);

native void Gangs_GetName(int gangid, const char[] name, int maxlength);
native int Gangs_GetPoints(int gangid);
native int Gangs_AddPoints(int gangid, int points);
native int Gangs_RemovePoints(int gangid, int points);
native int Gangs_GetMaxMembers(int gangid);
native int Gangs_GetMembersCount(int gangid);
native int Gangs_GetOnlinePlayers(int gangid);

public SharedPlugin __pl_gang =
{
	name = "Gangs - Core",
	file = "gangs.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN

public __pl_gangs_SetNTVOptional()
{
	MarkNativeAsOptional("Gangs_IsClientInGang");
	MarkNativeAsOptional("Gangs_GetClientLevel");
	MarkNativeAsOptional("Gangs_GetClientGang");
	MarkNativeAsOptional("Gangs_ClientLeftGang");
	MarkNativeAsOptional("Gangs_CreateClientGang");
	MarkNativeAsOptional("Gangs_DeleteClientGang");
	MarkNativeAsOptional("Gangs_OpenClientGang");
	MarkNativeAsOptional("Gangs_RenameClientGang");
	MarkNativeAsOptional("Gangs_GetRangName");
	
	MarkNativeAsOptional("Gangs_GetName");
	MarkNativeAsOptional("Gangs_GetPoints");
	MarkNativeAsOptional("Gangs_AddPoints");
	MarkNativeAsOptional("Gangs_RemovePoints");
	MarkNativeAsOptional("Gangs_GetMaxMembers");
	MarkNativeAsOptional("Gangs_GetMembersCount");
	MarkNativeAsOptional("Gangs_GetOnlinePlayers");
}
#endif
