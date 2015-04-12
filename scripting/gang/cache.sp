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

public void TQuery_Gang(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl != null)
	{
		if (error[0])
		{
			LogToFile("gang", "core", ERROR, "(TQuery_Gang) Query failed: %s", error);
			return;
		}
		
		while(SQL_FetchRow(hndl))
		{
			int iGang[Cache_Gang];

			iGang[iGangID] = SQL_FetchInt(hndl, 0);
			SQL_FetchString(hndl, 1, iGang[sGangName], 64);
			iGang[iPoints] = SQL_FetchInt(hndl, 2);
			iGang[bChat] = bool:SQL_FetchInt(hndl, 3);
			iGang[bPrefix] = bool:SQL_FetchInt(hndl, 4);
			SQL_FetchString(hndl, 5, iGang[sPrefixColor], 64);
			iGang[iMaxMembers] = SQL_FetchInt(hndl, 6);

			Log_File(_, _, DEBUG, "[TQuery_Gang] GangID: %d - GangName: %s - Points: %d - Chat: %d - Prefix: %d - PrefixColor: %s - MaxMembers: %d", iGang[iGangID], iGang[sGangName], iGang[iPoints], iGang[bChat], iGang[bPrefix], iGang[sPrefixColor], iGang[iMaxMembers]);

			g_aCacheGang.PushArray(iGang[0]);
		}
	}
}

public void TQuery_GangMembers(Handle owner, Handle hndl, const char[] error, any userid)
{
	int client = GetClientOfUserId(userid);
	
	if(!IsClientInGame(client))
		return;
	
	if (hndl != null)
	{
		if (error[0])
		{
			LogToFile("gang", "core", ERROR, "(TQuery_GangMembers) Query failed: %s", error);
			return;
		}
		
		while(SQL_FetchRow(hndl))
		{
			if(SQL_FetchInt(hndl, 0) > 0)
			{
				int iGang[Cache_Gang_Members];

				iGang[iGangID] = SQL_FetchInt(hndl, 0);
				SQL_FetchString(hndl, 1, iGang[sCommunityID], 64);
				iGang[iAccessLevel] = SQL_FetchInt(hndl, 2);
				
				Log_File(_, _, DEBUG, "[TQuery_GangMembers] GangID: %d - CommunityID: %s - AccessLevel: %d", iGang[iGangID], iGang[sCommunityID], iGang[iAccessLevel]);
	
				g_aCacheGang.PushArray(iGang[0]);
				
				if(iGang[iGangID] > 0)
				{
					g_bIsInGang[client] = true;
					g_iClientGang[client] = iGang[iGangID];
				}
			}
			else
				g_bIsInGang[client] = false;
		}
	}
}

public void TQuery_GangSkills(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl != null)
	{
		if (error[0])
		{
			LogToFile("gang", "core", ERROR, "(TQuery_GangSkills) Query failed: %s", error);
			return;
		}
		
		while(SQL_FetchRow(hndl))
		{
			int iGang[Cache_Gang_Skills];

			iGang[iGangID] = SQL_FetchInt(hndl, 0);
			iGang[iSkillID] = SQL_FetchInt(hndl, 1);
			iGang[iLevel] = SQL_FetchInt(hndl, 2);
			
			Log_File(_, _, DEBUG, "[TQuery_GangSkills] GangID: %d - SkillID: %d - iLevel: %d", iGang[iGangID], iGang[iSkillID], iGang[iLevel]);

			g_aCacheGang.PushArray(iGang[0]);
		}
	}
}

public void TQuery_Skills(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl != null)
	{
		if (error[0])
		{
			LogToFile("gang", "core", ERROR, "(TQuery_Skills) Query failed: %s", error);
			return;
		}
		
		while(SQL_FetchRow(hndl))
		{
			int iGang[Cache_Skills];

			iGang[iSkillID] = SQL_FetchInt(hndl, 0);
			SQL_FetchString(hndl, 1, iGang[sSkillName], 64);
			iGang[iMaxLevel] = SQL_FetchInt(hndl, 2);
			
			Log_File(_, _, DEBUG, "[TQuery_Skills] GangID: %d - SkillName: %s - Chat: %d", iGang[iSkillID], iGang[sSkillName], iGang[iMaxLevel]);

			g_aCacheGang.PushArray(iGang[0]);
		}
	}
}