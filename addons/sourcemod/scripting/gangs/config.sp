stock void CreateConfig()
{
	// CreateGang
	g_cGangCreateEnable = CreateConVar("gangs_create_enable", "1", "Enable \"Create Gang\"?", _, true, 0.0, true, 1.0);
	g_cGangCreate3rdEnable = CreateConVar("gangs_create_3rd_enable", "1", "Enable \"Create Gang\" for 3rd-party-plugins?", _, true, 0.0, true, 1.0);
	g_cGangCreateMinLen = CreateConVar("gangs_create_min_length", "3", "Minimum length of gang name", _, true, 3.0, true, 8.0);
	g_cGangCreateMaxLen = CreateConVar("gangs_create_max_length", "8", "Maximum length of gang name", _, true, 3.0, true, 8.0);
	g_cGangCreateRegex =  CreateConVar("gangs_create_regex", "^[a-zA-Z0-9]+$", "Allowed characters in gang name");
	
	//RenameGang
	g_cGangRenameEnable = CreateConVar("gangs_rename_enable", "1", "Enable \"Rename Gang\"?", _, true, 0.0, true, 1.0);
	g_cGangRenameRank = CreateConVar("gangs_rename_rank", "6", "What rank is required?", _, true, 1.0, true, 6.0);
	g_cGangRenameCost = CreateConVar("gangs_rename_cost", "2000", "How much costs this? (0 = DISABLED)");
	g_cGangRenameTime = CreateConVar("gangs_rename_time", "20.0", "Time in seconds for rename per menu");
	
	// PointsGang
	g_cGangPointsEnable = CreateConVar("gangs_points_enable", "1", "Enable \"Earning Points\"?", _, true, 0.0, true, 1.0);
	g_cGangPointsBots = CreateConVar("gangs_points_bots", "1", "Get points for killing bots?");
	g_cGangPointsKill = CreateConVar("gangs_points_kill", "1", "How much points for a \"normal kill\"?");
	g_cGangPointsKnife = CreateConVar("gangs_points_knife", "2", "How much points for a \"knife kill\"?");
	g_cGangPointsGrenade = CreateConVar("gangs_points_grenade", "2", "How much points for a \"grenade kill\"?");
	g_cGangPointsAssists = CreateConVar("gangs_points_assist", "1", "How much points for a \"assist kill\"?");
	g_cGangPointsHeadshot = CreateConVar("gangs_points_headshot", "1",  "How much extra points for a \"headshot kill\"?");
	g_cGangPointsPistol = CreateConVar("gangs_points_pistol", "1", "How much extra points for a \"kill with pistol\"?");
	g_cGangPointsHostageFollow = CreateConVar("gangs_points_hostage_follows", "1", "How much points for \"hostage_follows\"?");
	g_cGangPointsHostageRescue = CreateConVar("gangs_points_hostage_rescued", "2", "How much points for \"hostage_rescued\"?");
	g_cGangPointsBombPlanted = CreateConVar("gangs_points_bomb_planted", "1", "How much points for \"bomb_planted\"?");
	g_cGangPointsBombExploded = CreateConVar("gangs_points_bomb_exploded", "2", "How much points for \"bomb_exploded\"?");
	g_cGangPointsBombDefused = CreateConVar("gangs_points_bomb_defused", "3", "How much points for \"bomb_defused\"?");
	g_cGangPointsVipEscape = CreateConVar("gangs_points_vip_escaped", "2", "How much points for \"vip_escaped\"?");
	g_cGangPointsVipKilled = CreateConVar("gangs_points_vip_killed", "2", "How much points for \"vip_killed\"?");
	
	// Chat stuff
	g_cEnableGangChat = CreateConVar("gangs_enable_chat_prefix", "1", "Enable \"Gang Ghat\"?", _, true, 0.0, true, 1.0);
	g_cEnableGangPrefix = CreateConVar("gangs_enable_chat_prefix", "1", "Add a prefix to players name", _, true, 0.0, true, 1.0);
	
	// Invite
	g_cGangInviteEnable = CreateConVar("gang_invite_enable", "1", "Enable \"Invites\"?", _, true, 0.0, true, 1.0);
	g_cGangInviteTime = CreateConVar("gang_invite_time", "20.0", "Time in seconds to accept/decline a invite");
	
	// General settings
	g_cGangMenuDisplayTime = CreateConVar("gangs_menu_display_time", "15", "How long should be open the menu? (time will replaced every time)");
	
	AutoExecConfig();
}
