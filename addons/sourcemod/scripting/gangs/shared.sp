stock void Gangs_PushClientArray(int client)
{
	char sQuery[512];
	if(GetClientAuthId(client, AuthId_SteamID64, g_sClientID[client], sizeof(g_sClientID[])))
	{
		Format(sQuery, sizeof(sQuery), "SELECT GangID, CommunityID, PlayerName, AccessLevel FROM `gang_members` WHERE `CommunityID` = '%s'", g_sClientID[client]);
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
