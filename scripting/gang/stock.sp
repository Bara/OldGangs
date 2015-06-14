stock void Gang_SQLConnect()
{
	if (!SQL_CheckConfig("gang"))
	{
		Log_File(_, _, ERROR, "(Gang_SQLConnect) Database failure: Couldn't find Database entry \"gang\"");
		return;
	}
	SQL_TConnect(Gang_Connected, "gang");
}

stock void Gang_CreateTables()
{
	char sQuery[1024];
	
	Format(sQuery, sizeof(sQuery), "CREATE TABLE IF NOT EXISTS `gang` (`GangID` int(11) NOT NULL AUTO_INCREMENT, `GangName` varchar(65) NOT NULL DEFAULT '', `Points` int(11) NOT NULL DEFAULT '0', `Chat` tinyint(4) NOT NULL DEFAULT '0', `Prefix` tinyint(4) NOT NULL DEFAULT '0', `PrefixColor` varchar(65) NOT NULL DEFAULT 'GREEN', `MaxMembers` int(11) NOT NULL DEFAULT '2', PRIMARY KEY (`GangID`, `GangName`), UNIQUE KEY `GangName` (`GangName`), UNIQUE KEY `GangID` (`GangID`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
	SQLQuery(sQuery);
	
	Format(sQuery, sizeof(sQuery), "CREATE TABLE IF NOT EXISTS `skills` (`SkillID` int(11) NOT NULL AUTO_INCREMENT, `SkillName` varchar(65) NOT NULL DEFAULT '', `MaxLevel` int(11) NOT NULL DEFAULT '0', PRIMARY KEY (`SkillID`), UNIQUE KEY `SkillID` (`SkillID`), UNIQUE KEY `SkillName` (`SkillName`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
	SQLQuery(sQuery);
	
	Format(sQuery, sizeof(sQuery), "CREATE TABLE IF NOT EXISTS `gang_members` (`GangID` int(11) NOT NULL DEFAULT '0', `CommunityID` varchar(65) NOT NULL DEFAULT '', `PlayerName` varchar(255) NOT NULL DEFAULT '', `AccessLevel` int(11) NOT NULL DEFAULT '0', PRIMARY KEY (`CommunityID`), UNIQUE KEY `CommunityID` (`CommunityID`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
	SQLQuery(sQuery);
	
	Format(sQuery, sizeof(sQuery), "CREATE TABLE IF NOT EXISTS `gang_skills` (`GangID` int(11) NOT NULL DEFAULT '0', `SkillID` int(11) NOT NULL DEFAULT '0', `Level` int(11) NOT NULL DEFAULT '0') ENGINE=InnoDB DEFAULT CHARSET=utf8;");
	SQLQuery(sQuery);
}

stock bool CanCreateGang(int client)
{
	if(!g_bIsInGang[client] && g_iClientGang[client] == 0)
		return true;
	return false;
}

stock void Gang_CreateCache()
{
	if(g_aCacheGang != null)
		g_aCacheGang.Clear();
	
	if(g_aCacheGangMembers != null)
		g_aCacheGangMembers.Clear();
	
	if(g_aCacheGangSkills != null)
		g_aCacheGangSkills.Clear();
	
	if(g_aCacheSkills != null)
		g_aCacheSkills.Clear();
	
	g_aCacheGang =         new ArrayList(sizeof(g_iCacheGang));
	g_aCacheGangMembers =  new ArrayList(sizeof(g_iCacheGangMembers));
	g_aCacheGangSkills =   new ArrayList(sizeof(g_iCacheGangSkills));
	g_aCacheSkills =       new ArrayList(sizeof(g_iCacheSkills));
}

stock void Gang_FillCache()
{
	char sQuery[512];
	
	Format(sQuery, sizeof(sQuery), "SELECT GangID, GangName, Points, Chat, Prefix, PrefixColor, MaxMembers FROM `gang`");
	SQL_TQuery(g_hDatabase, TQuery_Gang, sQuery, _, DBPrio_Low);
	
	Format(sQuery, sizeof(sQuery), "SELECT GangID, SkillID, Level FROM `gang_skills`");
	SQL_TQuery(g_hDatabase, TQuery_GangSkills, sQuery, _, DBPrio_Low);
	
	Format(sQuery, sizeof(sQuery), "SELECT SkillID, SkillName, MaxLevel FROM `skills`");
	SQL_TQuery(g_hDatabase, TQuery_Skills, sQuery, _, DBPrio_Low);
}

stock void RemoveClientFromGang(int client, int gangid)
{
	if(!Gang_IsClientInGang(client))
	{
		ReplyToCommand(client, "Sie sind in keiner Gang."); // TODO: Translation
		return;
	}
	
	if(Gang_GetClientLevel(client) > 5)
	{
		ReplyToCommand(client, "Sie können diesen nicht als Founder ausführen."); // TODO: Translation
		return;
	}
	
	Gang_EraseClientArray(client);
	
	char sQuery[256];
	Format(sQuery, sizeof(sQuery), "DELETE FROM `gang_members` WHERE `CommunityID` = '%s' AND `GangID` = '%d'", g_sClientID[client], g_iClientGang[client]);
	SQLQuery(sQuery);
	
	char sGang[64];
	Gang_GetName(gangid, sGang, sizeof(sGang));
	Log_File(_, _, INFO, "\"%L\" hat die Gang \"%s\" verlassen!", client, sGang); // TODO: Translation
	
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		if (iGang[iGangID] == gangid)
		{
			int count = iGang[iMembers] - 1;
			g_aCacheGang.Set(i, count, view_as<int>(iMembers));

			Log_File(_, _, DEBUG, "(RemoveClientFromGang) GangID: %d - Members: %d", gangid, count);

			break;
		}
	}
	
	Call_StartForward(g_hGangLeft);
	Call_PushCell(client);
	Call_PushCell(gangid);
	Call_Finish();
}

stock void OpenClientGang(int client)
{
	int GangID = Gang_GetClientGang(client);
	
	char sGang[64], sTitle[64], sPoints[32], sOnline[32];
	
	Gang_GetName(GangID, sGang, sizeof(sGang));
	int points = Gang_GetPoints(GangID);
	int online = Gang_GetOnlinePlayers(GangID);
	int members = Gang_GetMembersCount(GangID);
	
	Format(sPoints, sizeof(sPoints), "Points: %d", points); // TODO: Translation
	Format(sOnline, sizeof(sOnline), "Online: %d/%d", online, members); // TODO: Translation
	
	Format(sTitle, sizeof(sTitle), "%s\n \n%s\n \n%s\n ", sGang, sPoints, sOnline); // TODO: Translation
	
	Menu menu = new Menu(Menu_GangMenu);
	
	menu.SetTitle(sTitle);
	
	menu.AddItem("skills", "Skills");
	if(Gang_GetClientLevel(client) == GANG_LEADER)
	{
		menu.AddItem("members", "Members");
		menu.AddItem("settings", "Settings\n ");
	}	
	else
	{
		menu.AddItem("members", "Members\n ");
	}
	
	if(Gang_GetClientLevel(client) < GANG_LEADER)
	{
		menu.AddItem("leftgang", "Left Gang\n ");
	}
	menu.ExitButton = true;
	
	menu.Display(client, g_cGangMenuDisplayTime.IntValue);
}

stock int GetOnlinePlayerCount(int gangid)
{
	int count = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			if(Gang_GetClientGang(i) == gangid)
			{
				count++;
			}
		}
	}
	
	return count;
}

stock bool CheckGangRename(int client, const char[] sGang)
{
	char sRegex[128];
	g_cGangCreateRegex.GetString(sRegex, sizeof(sRegex));
	Handle hRegex = CompileRegex(sRegex);
	
	if(MatchRegex(hRegex, sGang) != 1)
	{
		PrintToChat(client, "Der Gang Name enthält verbotene Zeichen."); // TODO: Translation
		return false;
	}
	
	if (strlen(sGang) < g_cGangCreateMinLen.IntValue)
	{
		PrintToChat(client, "Der Gang Name ist zu kurz."); // TODO: Translation
		return false;
	}
	
	if (strlen(sGang) > g_cGangCreateMaxLen.IntValue)
	{
		PrintToChat(client, "Der Gang Name ist zu lang."); // TODO: Translation
		return false;
	}
	
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		if (StrEqual(iGang[sGangName], sGang, false))
		{
			PrintToChat(client, "Der Gang Name wird bereits genutzt."); // TODO: Translation
			return false;
		}
	}
	
	int GangID = Gang_GetClientGang(client);
	
	char sOGang[64];
	Gang_GetName(GangID, sOGang, sizeof(sOGang));
	
	if(StrEqual(sOGang, sGang, false))
	{
		ReplyToCommand(client, "Der Gang Name muss sich unterscheiden."); // TODO: Translation
		return false;
	}
	
	if(CanCreateGang(client))
	{
		ReplyToCommand(client, "Sie sind in keiner Gang."); // TODO: Translation
		return false;
	}
	
	if(Gang_GetClientLevel(client) < g_cGangRenameRank.IntValue)
	{
		ReplyToCommand(client, "Sie besitzen nicht die Rechte um eine Gang umzubenennen.");
		return false;
	}
	
	if(Gang_GetPoints(GangID) < g_cGangRenameCost.IntValue)
	{
		ReplyToCommand(client, "Die Gang verfügt über nicht genug Punkte um sie umzubenennen.");
		return false;
	}
	return true;
}

stock void RenameGang(int client, int gangid, const char[] newgangname)
{
	char sQuery[512];
	Format(sQuery, sizeof(sQuery), "UPDATE `gang` SET `GangName` = '%s' WHERE `GangID` = '%d'", newgangname, gangid);
	
	char oldgangname[64];
	Gang_GetName(gangid, oldgangname, sizeof(oldgangname));
	
	Handle hDP = CreateDataPack();
	WritePackCell(hDP, GetClientUserId(client));
	WritePackCell(hDP, gangid);
	WritePackString(hDP, oldgangname);
	WritePackString(hDP, newgangname);
	SQL_TQuery(g_hDatabase, SQL_RenameGang, sQuery, hDP);
}

stock int AddGangPoints(int gangid, int points)
{
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		if (iGang[iGangID] == gangid)
		{
			int tmp_iPoints = iGang[iPoints] + points;
			g_aCacheGang.Set(i, tmp_iPoints, view_as<int>(iPoints));
			
			char sQuery[512];
			Format(sQuery, sizeof(sQuery), "UPDATE `gang` SET `Points`= '%d' WHERE `GangID` = '%d'", tmp_iPoints, gangid);
			SQLQuery(sQuery);
			
			return tmp_iPoints;
		}
	}
	return 0;
}

stock int RemoveGangPoints(int gangid, int points)
{
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		if (iGang[iGangID] == gangid)
		{
			int tmp_iPoints = iGang[iPoints] - points;
			g_aCacheGang.Set(i, tmp_iPoints, view_as<int>(iPoints));
			
			char sQuery[512];
			Format(sQuery, sizeof(sQuery), "UPDATE `gang` SET `Points` = '%d' WHERE `GangID` = '%d'", tmp_iPoints, gangid);
			SQLQuery(sQuery);
			
			return tmp_iPoints;
		}
	}
	return 0;
}

stock bool IsWeaponSecondary(const char[] sWeapon)
{
	if(	StrContains(sWeapon[7], "glock", false) || 
		StrContains(sWeapon[7], "p228", false) || 
		StrContains(sWeapon[7], "p250", false) || 
		StrContains(sWeapon[7], "cz75a", false) || 
		StrContains(sWeapon[7], "usp", false) || 
		StrContains(sWeapon[7], "usp_silencer", false) || 
		StrContains(sWeapon[7], "fiveseven", false) || 
		StrContains(sWeapon[7], "deagle", false) || 
		StrContains(sWeapon[7], "elite", false) || 
		StrContains(sWeapon[7], "tec9", false) || 
		StrContains(sWeapon[7], "hkp2000", false))
	{
		return true;
	}
	return false;
}

stock bool IsWeaponKnife(const char[] sWeapon)
{
	if(	StrContains(sWeapon[7], "knife", false) || 
		StrContains(sWeapon[7], "bayonet", false))
	{
		return true;
	}
	return false;
}

stock bool IsWeaponGrenade(const char[] sWeapon)
{
	if(	StrContains(sWeapon[7], "smokegrenade", false) || 
		StrContains(sWeapon[7], "hegrenade", false) || 
		StrContains(sWeapon[7], "flashbang", false) || 
		StrContains(sWeapon[7], "decoy", false))
	{
		return true;
	}
	return false;
}

stock void CheckName(int client, const char[] newname)
{
	char sQuery[512];
	Format(sQuery, sizeof(sQuery), "SELECT PlayerName FROM `gang_members` WHERE `CommunityID` = '%s'", g_sClientID[client]);
	
	Handle hPack = CreateDataPack();
	WritePackCell(hPack, GetClientUserId(client));
	WritePackString(hPack, newname);
	SQL_TQuery(g_hDatabase, SQL_CheckName, sQuery, hPack);
}

stock void UpdateNameInCache(int client, const char[] newname)
{
	for (int i = 0; i < g_aCacheGangMembers.Length; i++)
	{
		int iGangMembers[Cache_Gang_Members];
		g_aCacheGangMembers.GetArray(i, iGangMembers[0]);

		if(StrEqual(iGangMembers[sCommunityID], g_sClientID[client], true))
		{
			int itmpGang[Cache_Gang_Members];
			
			itmpGang[iGangID] = iGangMembers[iGangID];
			strcopy(itmpGang[sCommunityID], 64, g_sClientID[client]);
			strcopy(itmpGang[sPlayerN], MAX_NAME_LENGTH, newname);
			itmpGang[iAccessLevel] = iGangMembers[iAccessLevel];

			Log_File(_, _, DEBUG, "(UpdateNameInCache) GangID: %d - CommunityID: %s - PlayerName: %s - AccessLevel: %d", itmpGang[iGangID], itmpGang[sCommunityID], itmpGang[sPlayerN], itmpGang[iAccessLevel]);

			g_aCacheGangMembers.Erase(i);
			g_aCacheGangMembers.PushArray(itmpGang[0]);
			break;
		}
	}
}
