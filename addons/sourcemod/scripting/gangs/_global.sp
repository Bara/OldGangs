enum Cache_Gang
{
	iGangID = 0,
	String:sGangName[64],
	iPoints,
	bool:bChat,
	bool:bPrefix,
	String:sPrefixColor[64],
	iMaxMembers,
	iMembers
};

enum Cache_Gangs_Members
{
	iGangID = 0,
	String:sCommunityID[64],
	String:sPlayerN[MAX_NAME_LENGTH],
	iAccessLevel,
	bool:bMuted,
	bool:bOnline
};

enum Cache_Gangs_Skills
{
	iGangID = 0,
	iSkillID,
	iLevel
};

enum Cache_Skills
{
	iSkillID = 0,
	String:sSkillName[64],
	iMaxLevel
}

// Cache
int g_iCacheGang[Cache_Gang];
ArrayList g_aCacheGang = null;

int g_iCacheGangMembers[Cache_Gangs_Members];
ArrayList g_aCacheGangMembers = null;

int g_iCacheGangSkills[Cache_Gangs_Skills];
ArrayList g_aCacheGangSkills = null;

int g_iCacheSkills[Cache_Skills];
ArrayList g_aCacheSkills = null;

// Database
Handle g_hDatabase;

// Save gang names
char g_sGang[128][64];

// Fowards
Handle g_hSQLConnected = null;
Handle g_hGangCreated = null;
Handle g_hGangLeft = null;
Handle g_hGangDelete = null;
Handle g_hGangRename = null;
Handle g_hGangClientJoined = null;

// Client stuff
char g_sClientID[MAXPLAYERS + 1][64];
bool g_bIsInGang[MAXPLAYERS + 1] =  { false, ... };
int g_iClientGang[MAXPLAYERS + 1] =  { 0, ... };
int g_iClientLevel[MAXPLAYERS + 1] =  { 0, ... };

// Cvars
// CreateGang
ConVar g_cGangCreateEnable = null;
ConVar g_cGangCreateMinLen = null;
ConVar g_cGangCreateMaxLen = null;
ConVar g_cGangCreateRegex = null;

// RenameGang
// TODO: Rename Cooldown in days (we need a column in gangs LastRename)
ConVar g_cGangRenameEnable = null;
ConVar g_cGangRenameRank = null;
ConVar g_cGangRenameCost = null;
ConVar g_cGangRenameTime = null; // for menu

// PointsGang
ConVar g_cGangPointsEnable = null; // Global
ConVar g_cGangCreate3rdEnable = null;
ConVar g_cGangPointsBots = null; // Global
ConVar g_cGangPointsKill = null;
ConVar g_cGangPointsKnife = null;
ConVar g_cGangPointsGrenade = null;
ConVar g_cGangPointsAssists = null;
ConVar g_cGangPointsHeadshot = null;
ConVar g_cGangPointsPistol = null; 
ConVar g_cGangPointsHostageFollow = null; // Main
ConVar g_cGangPointsHostageRescue = null; // Main
ConVar g_cGangPointsBombPlanted = null; // Main
ConVar g_cGangPointsBombExploded = null; // Main
ConVar g_cGangPointsBombDefused = null; // Main
ConVar g_cGangPointsVipEscape = null; // Main
ConVar g_cGangPointsVipKilled = null; // Main

// Invite
ConVar g_cGangInviteMenuEnable = null;
ConVar g_cGangInviteCommandEnable = null;
ConVar g_cGangInviteTime = null;

// Chat stuff
ConVar g_cEnableGangChat = null;
ConVar g_cEnableGangPrefix = null;

// General settings
ConVar g_cGangMenuDisplayTime = null;

// Rename
Handle g_hRenameTimer[MAXPLAYERS + 1] =  { null, ... };
bool g_bInRename[MAXPLAYERS + 1] =  { false, ... };

// Invite
Handle g_hInviteTimer[MAXPLAYERS + 1] =  { null, ... };
int g_iInvited[MAXPLAYERS + 1] =  { -1, ... }; // Gang ID
