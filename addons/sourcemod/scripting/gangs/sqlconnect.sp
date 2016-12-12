stock void Gangs_SQLConnect()
{
	if (!SQL_CheckConfig("gang"))
	{
		Log_File(_, _, ERROR, "(Gangs_SQLConnect) Database failure: Couldn't find Database entry \"gang\"");
		return;
	}
	SQL_TConnect(Gangs_Connected, "gang");
}

public void Gangs_Connected(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		if (error[0])
		{
			Log_File(_, _, ERROR, "(Gangs_Connected) Connection to database failed!: %s", error);
			return;
		}
	}

	g_hDatabase = CloneHandle(hndl);

	Gangs_CreateTables();

	SQL_SetCharset(g_hDatabase, "utf8");
	
	Gangs_FillCache();

	Call_StartForward(g_hSQLConnected);
	Call_PushCell(view_as<Handle>(g_hDatabase));
	Call_Finish();
}

stock void Gangs_CreateTables()
{
	char sQuery[1024];
	
	Format(sQuery, sizeof(sQuery), "CREATE TABLE IF NOT EXISTS `gangs` (`GangID` int(11) NOT NULL AUTO_INCREMENT, `GangName` varchar(65) NOT NULL DEFAULT '', `Points` int(11) NOT NULL DEFAULT '0', `Chat` tinyint(4) NOT NULL DEFAULT '0', `Prefix` tinyint(4) NOT NULL DEFAULT '0', `PrefixColor` varchar(65) NOT NULL DEFAULT 'GREEN', `MaxMembers` int(11) NOT NULL DEFAULT '2', PRIMARY KEY (`GangID`, `GangName`), UNIQUE KEY `GangName` (`GangName`), UNIQUE KEY `GangID` (`GangID`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
	SQLQuery(sQuery);
	
	Format(sQuery, sizeof(sQuery), "CREATE TABLE IF NOT EXISTS `skills` (`SkillID` int(11) NOT NULL AUTO_INCREMENT, `SkillName` varchar(65) NOT NULL DEFAULT '', `MaxLevel` int(11) NOT NULL DEFAULT '0', PRIMARY KEY (`SkillID`), UNIQUE KEY `SkillID` (`SkillID`), UNIQUE KEY `SkillName` (`SkillName`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
	SQLQuery(sQuery);
	
	Format(sQuery, sizeof(sQuery), "CREATE TABLE IF NOT EXISTS `gangs_members` (`GangID` int(11) NOT NULL DEFAULT '0', `CommunityID` varchar(65) NOT NULL DEFAULT '', `PlayerName` varchar(255) NOT NULL DEFAULT '', `AccessLevel` int(11) NOT NULL DEFAULT '0', PRIMARY KEY (`CommunityID`), UNIQUE KEY `CommunityID` (`CommunityID`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
	SQLQuery(sQuery);
	
	Format(sQuery, sizeof(sQuery), "CREATE TABLE IF NOT EXISTS `gangs_skills` (`GangID` int(11) NOT NULL DEFAULT '0', `SkillID` int(11) NOT NULL DEFAULT '0', `Level` int(11) NOT NULL DEFAULT '0') ENGINE=InnoDB DEFAULT CHARSET=utf8;");
	SQLQuery(sQuery);
}

stock void Gangs_FillCache()
{
	char sQuery[512];
	
	Format(sQuery, sizeof(sQuery), "SELECT GangID, GangName, Points, Chat, Prefix, PrefixColor, MaxMembers FROM `gangs`");
	SQL_TQuery(g_hDatabase, TQuery_Gang, sQuery, _, DBPrio_Low);
	
	Format(sQuery, sizeof(sQuery), "SELECT GangID, SkillID, Level FROM `gangs_skills`");
	SQL_TQuery(g_hDatabase, TQuery_GangSkills, sQuery, _, DBPrio_Low);
	
	Format(sQuery, sizeof(sQuery), "SELECT SkillID, SkillName, MaxLevel FROM `skills`");
	SQL_TQuery(g_hDatabase, TQuery_Skills, sQuery, _, DBPrio_Low);
}

public void TQuery_Gang(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl != null)
	{
		if (error[0])
		{
			Log_File(_, _, ERROR, "(TQuery_Gang) Query failed: %s", error);
			return;
		}
		
		while(SQL_FetchRow(hndl))
		{
			int iGang[Cache_Gang];

			iGang[iGangID] = SQL_FetchInt(hndl, 0);
			SQL_FetchString(hndl, 1, iGang[sGangName], 64);
			iGang[iPoints] = SQL_FetchInt(hndl, 2);
			iGang[bChat] = view_as<bool>(SQL_FetchInt(hndl, 3));
			iGang[bPrefix] = view_as<bool>(SQL_FetchInt(hndl, 4));
			SQL_FetchString(hndl, 5, iGang[sPrefixColor], 64);
			iGang[iMaxMembers] = SQL_FetchInt(hndl, 6);
			iGang[iMembers] = 0;
			
			Log_File(_, _, DEBUG, "[TQuery_Gang] GangID: %d - GangName: %s - Points: %d - Chat: %d - Prefix: %d - PrefixColor: %s - MaxMembers: %d", iGang[iGangID], iGang[sGangName], iGang[iPoints], iGang[bChat], iGang[bPrefix], iGang[sPrefixColor], iGang[iMaxMembers]);
			
			g_aCacheGang.PushArray(iGang[0]);
			
			char sQuery[256];
			Format(sQuery, sizeof(sQuery), "SELECT GangID FROM `gangs_members` WHERE `GangID` = '%d'", iGang[iGangID]);
			SQL_TQuery(g_hDatabase, SQL_GetGangMemberCount, sQuery, iGang[iGangID], DBPrio_Low);
		}
	}
}

public void TQuery_GangSkills(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl != null)
	{
		if (error[0])
		{
			Log_File(_, _, ERROR, "(TQuery_GangSkills) Query failed: %s", error);
			return;
		}
		
		while(SQL_FetchRow(hndl))
		{
			int iGang[Cache_Gangs_Skills];

			iGang[iGangID] = SQL_FetchInt(hndl, 0);
			iGang[iSkillID] = SQL_FetchInt(hndl, 1);
			iGang[iLevel] = SQL_FetchInt(hndl, 2);
			
			Log_File(_, _, DEBUG, "[TQuery_GangSkills] GangID: %d - SkillID: %d - iLevel: %d", iGang[iGangID], iGang[iSkillID], iGang[iLevel]);

			g_aCacheGangSkills.PushArray(iGang[0]);
		}
	}
}

public void TQuery_Skills(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl != null)
	{
		if (error[0])
		{
			Log_File(_, _, ERROR, "(TQuery_Skills) Query failed: %s", error);
			return;
		}
		
		while(SQL_FetchRow(hndl))
		{
			int iGang[Cache_Skills];

			iGang[iSkillID] = SQL_FetchInt(hndl, 0);
			SQL_FetchString(hndl, 1, iGang[sSkillName], 64);
			iGang[iMaxLevel] = SQL_FetchInt(hndl, 2);
			
			Log_File(_, _, DEBUG, "[TQuery_Skills] GangID: %d - SkillName: %s - Chat: %d", iGang[iSkillID], iGang[sSkillName], iGang[iMaxLevel]);

			g_aCacheSkills.PushArray(iGang[0]);
		}
	}
}
