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
	
	Format(sQuery, sizeof(sQuery), "CREATE TABLE IF NOT EXISTS `gang` (`GangID` int(11) NOT NULL AUTO_INCREMENT, `GangName` varchar(65) NOT NULL DEFAULT '', `Points` int(11) NOT NULL DEFAULT '0', `Chat` tinyint(4) NOT NULL DEFAULT '0', `Prefix` tinyint(4) NOT NULL DEFAULT '0', `PrefixColor` varchar(65) NOT NULL DEFAULT '', `MaxMembers` int(11) NOT NULL DEFAULT '2', PRIMARY KEY (`GangID`, `GangName`), UNIQUE KEY `GangName` (`GangName`), UNIQUE KEY `GangID` (`GangID`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
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
	g_cGangRegex.GetString(sRegex, sizeof(sRegex));
	Handle hRegex = CompileRegex(sRegex);
	
	if(MatchRegex(hRegex, sArg) != 1)
	{
		ReplyToCommand(client, "Ihr Gang Name enthält verbotene Zeichen!");
		return false;
	}
	
	if (strlen(sArg) < g_cGangMinLen.IntValue)
	{
		ReplyToCommand(client, "Der Gang Name ist zu kurz!");
		return false;
	}
	
	if (strlen(sArg) > g_cGangMaxLen.IntValue)
	{
		ReplyToCommand(client, "Der Gang Name ist zu lang!");
		return false;
	}
	
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		if (StrEqual(iGang[sGangName], sArg, false))
		{
			ReplyToCommand(client, "Der Gang Name wird bereits genutzt!");
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

	Log_File(_, _, DEBUG, "[AddGangToArray] GangID: %d - GangName: %s - Points: %d - Chat: %d - Prefix: %d - PrefixColor: %s - MaxMembers: %d", iGang[iGangID], iGang[sGangName], iGang[iPoints], iGang[bChat], iGang[bPrefix], iGang[sPrefixColor], iGang[iMaxMembers]);

	g_aCacheGang.PushArray(iGang[0]);
}
