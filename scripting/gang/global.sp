enum Cache_Gang
{
	iGangID,
	String:sGangName[64],
	bool:bChat,
	bool:bPrefix,
	String:sPrefixColor[64],
	iMaxMembers
};

enum Cache_Gang_Members
{
	iGangID,
	String:sCommunityID[64],
	iAccessLevel
};

enum Cache_Gang_Skills
{
	iGangID,
	iSkillID,
	iLevel
};

enum Cache_Skills
{
	iSkillID,
	String:sSkillName[64],
	iMaxLevel
}

// Cache
int g_iCacheGang[Cache_Gang];
ArrayList g_aCacheGang = null;

int g_iCacheGangMembers[Cache_Gang_Members];
ArrayList g_aCacheGangMembers = null;

int g_iCacheGangSkills[Cache_Gang_Skills];
ArrayList g_aCacheGangSkills = null;

int g_iCacheSkills[Cache_Skills];
ArrayList g_aCacheSkills = null;

// Database
Handle g_hDatabase;
Handle g_hSQLConnected;
