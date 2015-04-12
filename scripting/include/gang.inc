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

new String:g_sELogLevel[6][32] = {
	"default",
	"trace",
	"debug",
	"info",
	"warn",
	"error"
};

stock void Gang_CheckGame()
{
	if(GetEngineVersion() != Engine_CSGO && GetEngineVersion() != Engine_CSS)
	{
		SetFailState("This plugin is for CSGO/CSS only.");
	}
}

stock void Log_File(const char[] path, const char[] file, ELOG_LEVEL:level = INFO, const char[] format, any:...)
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
	FormatTime(sDate, sizeof(sDate), "Y-m-d");
	Format(sFile, sizeof(sFile), "%s/%s_%s.log", sLevelPath, file, date);

	VFormat(sBuffer, sizeof(sBuffer), format, 5);

	LogToFile(sFile, sBuffer);
}

forward void Gang_OnSQLConnected(Handle database);

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
	// MarkNativeAsOptional("<NATIVE>");
}
#endif
