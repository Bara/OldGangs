stock void Gang_SQLConnect()
{
	if (!SQL_CheckConfig("gang"))
	{
		Log_File(_, _, ERROR, "(Gang_SQLConnect) Database failure: Couldn't find Database entry \"gang\"");
		return;
	}
	SQL_TConnect(Gang_Connected, "gang");
}

public void Gang_Connected(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		if (error[0])
		{
			Log_File(_, _, ERROR, "(Gang_Connected) Connection to database failed!: %s", error);
			return;
		}
	}

	g_hDatabase = CloneHandle(hndl);

	Gang_CreateTables();

	SQLQuery("SET NAMES \"UTF8\"");
	
	Gang_FillCache();

	Call_StartForward(g_hSQLConnected);
	Call_PushCell(_:g_hDatabase);
	Call_Finish();
}

Gang_CreateTables()
{
	char sQuery[1024];
	
	Format(sQuery, sizeof(sQuery), "CREATE TABLE IF NOT EXISTS `gang` (`GangID` int(11) NOT NULL AUTO_INCREMENT, `GangName` varchar(65) NOT NULL DEFAULT '', `Points` int(11) NOT NULL DEFAULT '0', `Chat` tinyint(4) NOT NULL DEFAULT '0', `Prefix` tinyint(4) NOT NULL DEFAULT '0', `PrefixColor` varchar(65) NOT NULL DEFAULT '', `MaxMembers` int(11) NOT NULL DEFAULT '2', PRIMARY KEY (`GangID`, `GangName`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
	SQLQuery(sQuery);
	
	Format(sQuery, sizeof(sQuery), "CREATE TABLE IF NOT EXISTS `skills` (`SkillID` int(11) NOT NULL AUTO_INCREMENT, `SkillName` varchar(65) NOT NULL DEFAULT '', `MaxLevel` int(11) NOT NULL DEFAULT '0', PRIMARY KEY (`SkillID`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
	SQLQuery(sQuery);
	
	Format(sQuery, sizeof(sQuery), "CREATE TABLE IF NOT EXISTS `gang_members` (`GangID` int(11) NOT NULL DEFAULT '0', `CommunityID` varchar(65) NOT NULL DEFAULT '', `AccessLevel` int(11) NOT NULL DEFAULT '0') ENGINE=InnoDB DEFAULT CHARSET=utf8;");
	SQLQuery(sQuery);
	
	Format(sQuery, sizeof(sQuery), "CREATE TABLE IF NOT EXISTS `gang_skills` (`GangID` int(11) NOT NULL DEFAULT '0', `SkillID` int(11) NOT NULL DEFAULT '0', `Level` int(11) NOT NULL DEFAULT '0') ENGINE=InnoDB DEFAULT CHARSET=utf8;");
	SQLQuery(sQuery);
}

SQLQuery(char[] sQuery)
{
	Handle hPack = CreateDataPack();
	WritePackString(hPack, sQuery);
	SQL_TQuery(g_hDatabase, SQL_Callback, sQuery, hPack);
}

public SQL_Callback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (error[0])
	{
		LogToFile("gang", "core", ERROR, "(SQL_Callback) Query failed: %s", error);
		return;
	}
}
