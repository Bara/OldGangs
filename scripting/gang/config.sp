stock void CreateConfig()
{
	// CreateGang
	g_cGangCreateEnable = CreateConVar("gang_create_enable", "1", "Enable \"Create Gang\"?", _, true, 0.0, true, 1.0);
	g_cGangCreateMinLen = CreateConVar("gang_create_min_length", "3", "Minimum length of gang name", _, true, 3.0, true, 8.0);
	g_cGangCreateMaxLen = CreateConVar("gang_create_max_length", "8", "Maximum length of gang name", _, true, 3.0, true, 8.0);
	g_cGangCreateRegex =  CreateConVar("gang_create_regex", "^[a-zA-Z0-9]+$", "Allowed characters in gang name");
	
	//RenameGang
	g_cGangRenameEnable = CreateConVar("gang_rename_enable", "1", "Enable \"Rename Gang\"?", _, true, 0.0, true, 1.0);
	g_cGangRenameRank = CreateConVar("gang_rename_rank", "6", "What rank is required?", _, true, 1.0, true, 6.0);
	g_cGangRenameCost = CreateConVar("gang_rename_cost", "2000", "How much costs this?");
	
	// PointsGang
	g_cGangPointsEnable = CreateConVar("gang_points_enable", "1", "Enable \"Earning Points\"?");
	g_cGangPointsBots = CreateConVar("gang_points_bots", "1", "Get points for killing bots?");
	g_cGangPointsKill = CreateConVar("gang_points_kill", "1", "How much points for a \"normal kill\"?");
	g_cGangPointsKnife = CreateConVar("gang_points_knife", "2", "How much points for a \"knife kill\"?");
	g_cGangPointsGrenade = CreateConVar("gang_points_grenade", "2", "How much points for a \"grenade kill\"?");
	g_cGangPointsAssists = CreateConVar("gang_points_assist", "1", "How much points for a \"assist kill\"?");
	g_cGangPointsHeadshot = CreateConVar("gang_points_headshot", "1",  "How much extra points for a \"headshot kill\"?");
	g_cGangPointsPistol = CreateConVar("gang_points_pistol", "1", "How much extra points for a \"kill with pistol\"?");
	g_cGangPointsHostageFollow = CreateConVar("gang_points_hostage_follows", "1", "How much points for \"hostage_follows\"?");
	g_cGangPointsHostageRescue = CreateConVar("gang_points_hostage_rescued", "2", "How much points for \"hostage_rescued\"?");
	g_cGangPointsBombPlanted = CreateConVar("gang_points_bomb_planted", "1", "How much points for \"bomb_planted\"?");
	g_cGangPointsBombExploded = CreateConVar("gang_points_bomb_exploded", "2", "How much points for \"bomb_exploded\"?");
	g_cGangPointsBombDefused = CreateConVar("gang_points_bomb_defused", "3", "How much points for \"bomb_defused\"?");
	g_cGangPointsVipEscape = CreateConVar("gang_points_vip_escaped", "2", "How much points for \"vip_escaped\"?");
	g_cGangPointsVipKilled = CreateConVar("gang_points_vip_killed", "2", "How much points for \"vip_killed\"?");
	
	// General settings
	g_cGangMenuDisplayTime = CreateConVar("gang_menu_display_time", "15", "How long should be open the menu? (time will replaced every time)");
	
	AutoExecConfig();
}
