stock void Gangs_PushClientArray(int client)
{
	char sQuery[512];
	if(GetClientAuthId(client, AuthId_SteamID64, g_sClientID[client], sizeof(g_sClientID[])))
	{
		Format(sQuery, sizeof(sQuery), "SELECT GangID, CommunityID, PlayerName, AccessLevel FROM `gangs_members` WHERE `CommunityID` = '%s'", g_sClientID[client]);
		SQL_TQuery(g_hDatabase, TQuery_GangMembers, sQuery, GetClientUserId(client), DBPrio_High);
	}
}

stock void Gangs_EraseClientArray(int client)
{
	if(g_bIsInGang[client])
	{
		for (int i = 0; i < g_aCacheGangMembers.Length; i++)
		{
			int iGang[Cache_Gangs_Members];
			g_aCacheGangMembers.GetArray(i, iGang[0]);
	
			if (iGang[iGangID] == g_iClientGang[client])
			{
				g_aCacheGangMembers.Erase(i);
				break;
			}
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
		Log_File(_, _, ERROR, "(SQL_Callback) Query failed: %s", error);
		return;
	}
}

stock void Gangs_ClearArray()
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
