stock void PushClientArray(int client)
{
	char sQuery[512];

	Format(sQuery, sizeof(sQuery), "SELECT GangID, CommunityID, PlayerName, AccessLevel, Muted FROM `gangs_members` WHERE `CommunityID` = '%s'", g_sClientID[client]);
	SQL_TQuery(g_hDatabase, TQuery_GangMembers, sQuery, GetClientUserId(client), DBPrio_High);
}

stock void UpdateClientOnlineState(int client, bool status)
{
	for (int i = 0; i < g_aCacheGangMembers.Length; i++)
	{
		int iGang[Cache_Gangs_Members];
		g_aCacheGangMembers.GetArray(i, iGang[0]);

		if (StrEqual(iGang[sCommunityID], g_sClientID[client]))
		{
			int itmpGang[Cache_Gang];
			
			itmpGang[iGangID] = iGang[iGangID];
			strcopy(itmpGang[sCommunityID], 64, iGang[sCommunityID]);
			strcopy(itmpGang[sPlayerN], 64, iGang[sPlayerN]);
			itmpGang[iAccessLevel] = iGang[iAccessLevel];
			itmpGang[bMuted] = iGang[bMuted];
			itmpGang[bOnline] = status;

			Gangs_LogFile(_, DEBUG, "(UpdateClientOnlineState) Player: %N - Old Status: %d - New Status: %d", client, iGang[bOnline], itmpGang[bOnline]);
			
			if(itmpGang[bOnline])
			{
				g_bIsInGang[client] = true;
				g_iClientGang[client] = itmpGang[iGangID];
				g_iClientLevel[client] = itmpGang[iAccessLevel];
				g_bClientMuted[client] = itmpGang[bMuted];
			}
			else
			{
				g_bIsInGang[client] = false;
				g_iClientGang[client] = 0;
				g_iClientLevel[client] = GANGS_NONE;
				g_bClientMuted[client] = false;
			}
			
			g_aCacheGangMembers.Erase(i);
			g_aCacheGangMembers.PushArray(itmpGang[0]);
			
			SortADTArrayCustom(g_aCacheGangMembers, Sort_GangMembers);
			
			break;
		}
	}
}

stock void UpdateClientMuteState(const char[] communityid, bool status)
{
	for (int i = 0; i < g_aCacheGangMembers.Length; i++)
	{
		int iGang[Cache_Gangs_Members];
		g_aCacheGangMembers.GetArray(i, iGang[0]);

		if (StrEqual(iGang[sCommunityID], communityid))
		{
			int itmpGang[Cache_Gang];
			
			itmpGang[iGangID] = iGang[iGangID];
			strcopy(itmpGang[sCommunityID], 64, iGang[sCommunityID]);
			strcopy(itmpGang[sPlayerN], 64, iGang[sPlayerN]);
			itmpGang[iAccessLevel] = iGang[iAccessLevel];
			itmpGang[bMuted] = status;
			itmpGang[bOnline] = iGang[bOnline];
			
			Gangs_LogFile(_, DEBUG, "(UpdateClientMuteState) Player: %s - Old Status: %d - New Status: %d", itmpGang[sPlayerN], iGang[bMuted], itmpGang[bMuted]);
			
			if(status)
				CPrintToGang(iGang[iGangID], "[%s] %s is now muted!", g_sGang[iGang[iGangID]], iGang[sPlayerN]);
			else
				CPrintToGang(iGang[iGangID], "[%s] %s is no longer muted!", g_sGang[iGang[iGangID]], iGang[sPlayerN]);
			
			g_aCacheGangMembers.Erase(i);
			g_aCacheGangMembers.PushArray(itmpGang[0]);
			
			SortADTArrayCustom(g_aCacheGangMembers, Sort_GangMembers);
			
			int target = FindClientByCommunityID(communityid);
			if(Gangs_IsClientValid(target))
				g_bClientMuted[target] = status;
			
			Call_StartForward(g_hGangMute);
			Call_PushString(communityid);
			Call_PushString(itmpGang[sPlayerN]);
			Call_PushCell(itmpGang[iGangID]);
			Call_PushCell(status);
			Call_Finish();
			
			break;
		}
	}
}

stock void ErasePlayerArray(const char[] communityid)
{
	for (int i = 0; i < g_aCacheGangMembers.Length; i++)
	{
		int iGang[Cache_Gangs_Members];
		g_aCacheGangMembers.GetArray(i, iGang[0]);

		if (StrEqual(iGang[sCommunityID], communityid))
		{
			g_aCacheGangMembers.Erase(i);
			break;
		}
	}
}

stock bool CanCreateGang(int client)
{
	if(!g_bIsInGang[client] && g_iClientGang[client] == 0)
		return true;
	return false;
}

void SQLQuery(char[] sQuery)
{
	Handle hPack = CreateDataPack();
	WritePackString(hPack, sQuery);
	SQL_TQuery(g_hDatabase, SQL_Callback, sQuery, hPack);
}

public void SQL_Callback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (error[0])
	{
		Gangs_LogFile(_, ERROR, "(SQL_Callback) Query failed: %s", error);
		return;
	}
}

stock void ClearGangsArrays()
{
	if (g_aCacheGang != null)
		g_aCacheGang.Clear();
	if (g_aCacheGangMembers != null)
		g_aCacheGangMembers .Clear();
	if (g_aCacheGangSkills != null)
		g_aCacheGangSkills.Clear();
	if (g_aCacheSkills != null)
		g_aCacheSkills.Clear();
		
	g_aCacheGang = new ArrayList();
	g_aCacheGangMembers = new ArrayList();
	g_aCacheGangSkills = new ArrayList();
	g_aCacheSkills = new ArrayList();
}

stock int FindClientByCommunityID(const char[] communityid)
{
	LoopClients(i)
	{
		if(StrEqual(communityid, g_sClientID[i]))
		{
			return i;
		}
	}
	
	return -1;
}

public int Sort_GangMembers(int i, int j, Handle array, Handle hndl)
{
	int tmpPlayer[Cache_Gangs_Members];
	int tmpPlayer2[Cache_Gangs_Members];

	g_aCacheGangMembers.GetArray(i, tmpPlayer[0]);
	g_aCacheGangMembers.GetArray(j, tmpPlayer2[0]);
	if (tmpPlayer[iAccessLevel] > tmpPlayer2[iAccessLevel])
		return -1;
	else if(tmpPlayer[iAccessLevel] < tmpPlayer2[iAccessLevel])
		return 1;
	return 0;
}
