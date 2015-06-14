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
			Format(sQuery, sizeof(sQuery), "SELECT GangID FROM `gang_members` WHERE `GangID` = '%d'", iGang[iGangID]);
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
			int iGang[Cache_Gang_Skills];

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
