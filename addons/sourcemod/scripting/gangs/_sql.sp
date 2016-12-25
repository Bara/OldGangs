public void SQL_GetGangMemberCount(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl != null)
	{
		if (error[0])
		{
			Gangs_LogFile(_, ERROR, "(SQL_GetGangMemberCount) Query failed: %s", error);
			return;
		}
		
		int count = 0;
		int gangid = data;
		
		while(SQL_FetchRow(hndl))
		{
			if(SQL_FetchInt(hndl, 0) == gangid)
				count++;
		}

		for (int i = 0; i < g_aCacheGang.Length; i++)
		{
			int iGang[Cache_Gang];
			g_aCacheGang.GetArray(i, iGang[0]);
	
			if (iGang[iGangID] == gangid)
			{
				g_aCacheGang.Set(i, count, view_as<int>(iMembers));

				Gangs_LogFile(_, DEBUG, "(SQL_GetGangMemberCount) GangID: %d - Members: %d", iGang[iGangID], count);
				break;
			}
		}
	}
}

public void SQL_GangsMembersCache(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (hndl != null)
	{
		if (error[0])
		{
			Gangs_LogFile(_, ERROR, "(SQL_GangsMembersCache) Query failed: %s", error);
			return;
		}
		
		int iGang[Cache_Gangs_Members];
		
		while(SQL_FetchRow(hndl))
		{
			iGang[iGangID] = SQL_FetchInt(hndl, 0);
			SQL_FetchString(hndl, 1, iGang[sCommunityID], 64);
			SQL_FetchString(hndl, 2, iGang[sPlayerN], MAX_NAME_LENGTH);
			iGang[iAccessLevel] = SQL_FetchInt(hndl, 3);
			iGang[bMuted] = view_as<bool>(SQL_FetchInt(hndl, 4));
			
			if(Gangs_IsClientValid(FindClientByCommunityID(iGang[sCommunityID])))
			{
				iGang[bOnline] = true;
			}
			else
			{
				iGang[bOnline] = false;
			}
			
			g_aCacheGangMembers.PushArray(iGang[0]);
			
			Gangs_LogFile(_, DEBUG, "(SQL_GangsMembersCache) GangID: %d - Player: %s - CommunityID: %s - AccessLevel: %d - Muted: %d", iGang[iGangID], iGang[sCommunityID], iGang[sPlayerN], iGang[iAccessLevel], iGang[bMuted]);
		}
		SortADTArrayCustom(g_aCacheGangMembers, Sort_GangMembers);
	}
}
