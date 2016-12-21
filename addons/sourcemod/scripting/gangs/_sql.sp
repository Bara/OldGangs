public void SQL_GetGangMemberCount(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl != null)
	{
		if (error[0])
		{
			Gangs_LogFile(_, ERROR, "(TQuery_Gang) Query failed: %s", error);
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

public void SQL_CheckName(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (error[0])
	{
		Gangs_LogFile(_, ERROR, "(SQL_CheckName) Query failed: %s", error);
		CloseHandle(pack);
		return;
	}
		
	char newname[MAX_NAME_LENGTH];

	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	ReadPackString(pack, newname, sizeof(newname));
	CloseHandle(pack);
	
	if (!Gangs_IsClientValid(client) )
		return;
	
	if (hndl != null)
	{
		while(SQL_FetchRow(hndl))
		{
			char sSName[MAX_NAME_LENGTH];
			SQL_FetchString(hndl, 0, sSName, sizeof(sSName));
			
			if(!StrEqual(newname, sSName, true))
			{
				UpdateNameInCache(client, newname);
				
				char sQuery[512], sEName[MAX_NAME_LENGTH];
				SQL_EscapeString(g_hDatabase, newname, sEName, sizeof(sEName));
				Format(sQuery, sizeof(sQuery), "UPDATE `gangs_members` SET `PlayerName` = '%s' WHERE `CommunityID` = '%s'", sEName, g_sClientID[client]);
				SQLQuery(sQuery);
			}
		}
	}
}
