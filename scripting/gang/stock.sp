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
	
	Format(sQuery, sizeof(sQuery), "CREATE TABLE IF NOT EXISTS `gang_members` (`GangID` int(11) NOT NULL DEFAULT '0', `CommunityID` varchar(65) NOT NULL DEFAULT '', `AccessLevel` int(11) NOT NULL DEFAULT '0', PRIMARY KEY (`CommunityID`), UNIQUE KEY `CommunityID` (`CommunityID`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
	SQLQuery(sQuery);
	
	Format(sQuery, sizeof(sQuery), "CREATE TABLE IF NOT EXISTS `gang_skills` (`GangID` int(11) NOT NULL DEFAULT '0', `SkillID` int(11) NOT NULL DEFAULT '0', `Level` int(11) NOT NULL DEFAULT '0') ENGINE=InnoDB DEFAULT CHARSET=utf8;");
	SQLQuery(sQuery);
}

stock bool CheckGangName(int client, const char[] sArg)
{
	char sRegex[128];
	g_cGangCreateRegex.GetString(sRegex, sizeof(sRegex));
	Handle hRegex = CompileRegex(sRegex);
	
	if(MatchRegex(hRegex, sArg) != 1)
	{
		PrintToChat(client, "Der Gang Name enthält verbotene Zeichen!");
		return false;
	}
	
	if (strlen(sArg) < g_cGangCreateMinLen.IntValue)
	{
		PrintToChat(client, "Der Gang Name ist zu kurz!");
		return false;
	}
	
	if (strlen(sArg) > g_cGangCreateMaxLen.IntValue)
	{
		PrintToChat(client, "Der Gang Name ist zu lang!");
		return false;
	}
	
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		if (StrEqual(iGang[sGangName], sArg, false))
		{
			PrintToChat(client, "Der Gang Name wird bereits genutzt!");
			return false;
		}
	}
	
	if(!CanCreateGang(client))
	{
		ReplyToCommand(client, "Sie sind bereits in einer Gang!");
		return false;
	}
	
	return true;
}

stock bool CanCreateGang(int client)
{
	if(!g_bIsInGang[client] && g_iClientGang[client] == 0)
		return true;
	return false;
}

stock void Gang_EraseClientArray(int client)
{
	if(g_bIsInGang[client])
	{
		for (int i = 0; i < g_aCacheGangMembers.Length; i++)
		{
			int iGang[Cache_Gang_Members];
			g_aCacheGangMembers.GetArray(i, iGang[0]);
	
			if (iGang[iGangID] == g_iClientGang[client])
			{
				g_aCacheGangMembers.Erase(i);
				break;
			}
		}
	}
}

stock void Gang_PushClientArray(int client)
{
	char sQuery[512];
	
	GetClientAuthId(client, AuthId_SteamID64, g_sClientID[client], sizeof(g_sClientID[]));
	
	Format(sQuery, sizeof(sQuery), "SELECT GangID, CommunityID, AccessLevel FROM gang_members WHERE CommunityID = '%s'", g_sClientID[client]);
	SQL_TQuery(g_hDatabase, TQuery_GangMembers, sQuery, GetClientUserId(client), DBPrio_Low);
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
	
	Format(sQuery, sizeof(sQuery), "SELECT GangID, GangName, Points, Chat, Prefix, PrefixColor, MaxMembers FROM gang");
	SQL_TQuery(g_hDatabase, TQuery_Gang, sQuery, _, DBPrio_Low);
	
	Format(sQuery, sizeof(sQuery), "SELECT GangID, SkillID, Level FROM gang_skills");
	SQL_TQuery(g_hDatabase, TQuery_GangSkills, sQuery, _, DBPrio_Low);
	
	Format(sQuery, sizeof(sQuery), "SELECT SkillID, SkillName, MaxLevel FROM skills");
	SQL_TQuery(g_hDatabase, TQuery_Skills, sQuery, _, DBPrio_Low);
}

stock void CreateGang(int client, const char[] gang)
{
	char sQuery[512];
	Format(sQuery, sizeof(sQuery), "INSERT INTO `gang` (`GangName`) VALUES ('%s')", gang);

	Handle hDP = CreateDataPack();
	WritePackCell(hDP, GetClientUserId(client));
	WritePackString(hDP, gang);
	SQL_TQuery(g_hDatabase, SQL_CreateGang, sQuery, hDP);
}

stock void AddClientToGang(int client, int gang)
{
	char sQuery[512];
	Format(sQuery, sizeof(sQuery), "INSERT INTO `gang_members` (`GangID`, `CommunityID`, `AccessLevel`) VALUES ('%d', '%s', '6')", g_iClientGang[client], g_sClientID[client]);
	SQL_TQuery(g_hDatabase, SQL_UpdateGangMembers, sQuery, GetClientUserId(client));
}

stock void AddGangToArray(int GangID, const char[] sGang)
{
	int iGang[Cache_Gang];

	iGang[iGangID] = GangID;
	Format(iGang[sGangName], 64, "%s", sGang);
	iGang[iPoints] = 0;
	iGang[bChat] = false;
	iGang[bPrefix] = false;
	Format(iGang[sPrefixColor], 64, "");
	iGang[iMaxMembers] = 2;
	iGang[iMembers] = 1;

	Log_File(_, _, DEBUG, "[AddGangToArray] GangID: %d - GangName: %s - Points: %d - Chat: %d - Prefix: %d - PrefixColor: %s - MaxMembers: %d", iGang[iGangID], iGang[sGangName], iGang[iPoints], iGang[bChat], iGang[bPrefix], iGang[sPrefixColor], iGang[iMaxMembers]);

	g_aCacheGang.PushArray(iGang[0]);
}

stock void RemoveClientFromGang(int client, int gangid)
{
	if(!Gang_IsClientInGang(client))
	{
		ReplyToCommand(client, "Sie sind in keiner Gang!");
		return;
	}
	
	if(Gang_GetClientAccessLevel(client) > 5)
	{
		ReplyToCommand(client, "Sie können diesen nicht als Founder ausführen!");
		return;
	}
	
	Gang_EraseClientArray(client);
	
	char sQuery[256];
	Format(sQuery, sizeof(sQuery), "DELETE FROM gang_members WHERE CommunityID = '%s' AND GangID = '%d'", g_sClientID[client], g_iClientGang[client]);
	SQLQuery(sQuery);
	
	char sGang[64];
	Gang_GetGangName(gangid, sGang, sizeof(sGang));
	Log_File(_, _, INFO, "\"%N\" hat die Gang \"%s\" verlassen!", client, sGang);
	
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		if (iGang[iGangID] == gangid)
		{
			int count = iGang[iMembers] - 1;
			g_aCacheGang.Set(i, count, _:iMembers);

			Log_File(_, _, DEBUG, "(RemoveClientFromGang) GangID: %d - Members: %d", gangid, count);

			break;
		}
	}
	
	Call_StartForward(g_hGangLeft);
	Call_PushCell(client);
	Call_PushCell(gangid);
	Call_Finish();
}

stock void DeleteGang(int client, int gangid)
{
	char sGang[64];
	Gang_GetGangName(gangid, sGang, sizeof(sGang));
	
	PrintToChatAll("%N hat die Gang \"%s\" gelöscht!", client, sGang);
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if(g_iClientGang[i] == gangid)
		{
			Gang_EraseClientArray(i);
			g_bIsInGang[i] = false;
			g_iClientGang[i] = 0;
		}
	}
	
	DeleteGangEntries(gangid);
	
	Call_StartForward(g_hGangDelete);
	Call_PushCell(client);
	Call_PushCell(gangid);
	Call_PushString(sGang);
	Call_Finish();
}

stock void DeleteGangEntries(int gangid)
{
	char sQuery[256];
	
	Format(sQuery, sizeof(sQuery), "DELETE FROM gang WHERE GangID = '%d'", gangid);
	SQLQuery(sQuery);
	
	Format(sQuery, sizeof(sQuery), "DELETE FROM gang_members WHERE GangID = '%d'", gangid);
	SQLQuery(sQuery);
	
	Format(sQuery, sizeof(sQuery), "DELETE FROM gang_skills WHERE GangID = '%d'", gangid);
	SQLQuery(sQuery);
	
	RemoveGangFromArray(gangid);
}

stock void RemoveGangFromArray(int gangid)
{
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		if (iGang[iGangID] == gangid)
		{
			g_aCacheGang.Erase(i);
			break;
		}
	}
}

stock bool IsClientFounder(int client, int gangid)
{
	char sComID[64];
	GetClientAuthId(client, AuthId_SteamID64, sComID, sizeof(sComID));
	
	if(g_bIsInGang[client])
	{
		for (int i = 0; i < g_aCacheGangMembers.Length; i++)
		{
			int iGang[Cache_Gang_Members];
			g_aCacheGangMembers.GetArray(i, iGang[0]);
	
			if (StrEqual(iGang[sCommunityID], sComID, false) && iGang[iAccessLevel] == 6)
			{
				return true;
			}
		}
	}
	return false;
}

stock void OpenClientGang(int client)
{
	char sGang[64], sTitle[64];
	Gang_GetGangName(Gang_GetClientGang(client), sGang, sizeof(sGang));
	Format(sTitle, sizeof(sTitle), "%s - Main", sGang);
	
	Menu menu = new Menu(Menu_GangMain);
	menu.SetTitle(sTitle);
	menu.AddItem("info", "Information");
	menu.ExitButton = true;
	menu.Display(client, g_cGangMenuDisplayTime.IntValue);
}

stock void OpenClientGangInfo(int client)
{
	int gangid = Gang_GetClientGang(client);
	
	char sGang[64], sTitle[64], sPoints[64], sOnline[64], sMembers[64], sMaxMembers[64];
	Gang_GetGangName(gangid, sGang, sizeof(sGang));
	
	Format(sTitle, sizeof(sTitle), "%s - Information", sGang);
	Format(sPoints, sizeof(sPoints), "Points: %d", Gang_GetGangPoints(gangid));
	Format(sOnline, sizeof(sOnline), "Online: %d", Gang_GetOnlinePlayerCount(gangid));
	Format(sMembers, sizeof(sMembers), "Members: %d", Gang_GetGangMembersCount(gangid));
	Format(sMaxMembers, sizeof(sMaxMembers), "Max. Members: %d", Gang_GetGangMaxMembers(gangid));
	
	Menu menu = new Menu(Menu_GangMain);
	menu.SetTitle(sTitle);
	menu.AddItem("", sPoints, ITEMDRAW_DISABLED);
	menu.AddItem("", sOnline, ITEMDRAW_DISABLED);
	menu.AddItem("", sMembers, ITEMDRAW_DISABLED);
	menu.AddItem("", sMaxMembers, ITEMDRAW_DISABLED);
	menu.ExitBackButton = true;
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
		PrintToChat(client, "Der Gang Name enthält verbotene Zeichen!");
		return false;
	}
	
	if (strlen(sGang) < g_cGangCreateMinLen.IntValue)
	{
		PrintToChat(client, "Der Gang Name ist zu kurz!");
		return false;
	}
	
	if (strlen(sGang) > g_cGangCreateMaxLen.IntValue)
	{
		PrintToChat(client, "Der Gang Name ist zu lang!");
		return false;
	}
	
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		if (StrEqual(iGang[sGangName], sGang, false))
		{
			PrintToChat(client, "Der Gang Name wird bereits genutzt!");
			return false;
		}
	}
	
	char sOGang[64];
	Gang_GetGangName(Gang_GetClientGang(client), sOGang, sizeof(sOGang));
	
	if(StrEqual(sOGang, sGang, false))
	{
		PrintToChat(client, "Der Gang muss sich unterscheiden!");
		return false;
	}
	
	if(CanCreateGang(client))
	{
		ReplyToCommand(client, "Sie sind in keiner Gang!");
		return false;
	}
	
	// TODO: Check gang points and g_cGangRenameCost
	
	return true;
}

stock void RenameGang(int client, int gangid, const char[] newgangname)
{
	char sQuery[512];
	Format(sQuery, sizeof(sQuery), "UPDATE gang SET `GangName`=%s WHERE `GangID`='%d'", newgangname, gangid);
	
	char oldgangname[64];
	Gang_GetGangName(gangid, oldgangname, sizeof(oldgangname));
	
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
			g_aCacheGang.Set(i, tmp_iPoints, _:iPoints);
			
			char sQuery[512];
			Format(sQuery, sizeof(sQuery), "UPDATE gang SET `Points`=%d WHERE `GangID`='%d'", tmp_iPoints, gangid);
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
			g_aCacheGang.Set(i, tmp_iPoints, _:iPoints);
			
			char sQuery[512];
			Format(sQuery, sizeof(sQuery), "UPDATE gang SET `Points`=%d WHERE `GangID`='%d'", tmp_iPoints, gangid);
			SQLQuery(sQuery);
			
			return tmp_iPoints;
		}
	}
	return 0;
}

stock bool IsWeaponSecondary(const char[] sWeapon)
{
	if(	StrContains(sWeapon, "glock", false) || 
		StrContains(sWeapon, "p228", false) || 
		StrContains(sWeapon, "p250", false) || 
		StrContains(sWeapon, "cz75a", false) || 
		StrContains(sWeapon, "usp", false) || 
		StrContains(sWeapon, "usp_silencer", false) || 
		StrContains(sWeapon, "fiveseven", false) || 
		StrContains(sWeapon, "deagle", false) || 
		StrContains(sWeapon, "elite", false) || 
		StrContains(sWeapon, "tec9", false) || 
		StrContains(sWeapon, "hkp2000", false))
	{
		return true;
	}
	return false;
}

stock bool IsWeaponKnife(const char[] sWeapon)
{
	if(	StrContains(sWeapon, "knife", false) || 
		StrContains(sWeapon, "bayonet", false))
	{
		return true;
	}
	return false;
}

stock bool IsWeaponGrenade(const char[] sWeapon)
{
	if(	StrContains(sWeapon, "smokegrenade", false) || 
		StrContains(sWeapon, "hegrenade", false) || 
		StrContains(sWeapon, "flashbang", false) || 
		StrContains(sWeapon, "decoy", false))
	{
		return true;
	}
	return false;
}
