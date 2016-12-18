public Action Command_DeleteGang(int client, int args)
{
	if (client < 1 || !IsClientInGame(client) )
		return Plugin_Handled;
	
	Gangs_DeleteClientGang(client, Gangs_GetClientGang(client));
	
	return Plugin_Handled;
}

public int Native_DeleteClientGang(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int gangid = GetNativeCell(2);
	
	if (client < 1 || !IsClientInGame(client))
	{
		return;
	}
	
	if (!g_bIsInGang[client])
	{
		CPrintToChat(client, "You aren't in a gang!"); // TODO: Translation
		return;
	}
	
	if(Gangs_GetClientLevel(client) < GANGS_LEADER)
	{
		CPrintToChat(client, "Just the owner can do this!"); // TODO: Translation
		return;
	}
	
	DeleteGang(client, gangid);
}

stock void DeleteGang(int client, int gangid)
{
	char sGang[64];
	Gangs_GetName(gangid, sGang, sizeof(sGang));
	
	CPrintToChatAll("\"%L\" deleted %s!", client, sGang); // TODO: Translation
	Log_File(_, _, INFO, "\"%L\" deleted %s!", client, sGang); // TODO: Translation
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if(g_iClientGang[i] == gangid)
		{
			Gangs_EraseClientArray(i);
			g_bIsInGang[i] = false;
			g_iClientGang[i] = 0;
		}
	}
	
	DeleteGangEntries(gangid);
	
	Call_StartForward(g_hGangDelete);
	Call_PushCell(client);
	Call_PushCell(gangid);
	Call_PushString(sGang);
	Call_Finish();
}

stock void DeleteGangEntries(int gangid)
{
	char sQuery[256];
	
	Format(sQuery, sizeof(sQuery), "DELETE FROM `gangs` WHERE `GangID` = '%d'", gangid);
	SQLQuery(sQuery);
	
	Format(sQuery, sizeof(sQuery), "DELETE FROM `gangs_members` WHERE `GangID` = '%d'", gangid);
	SQLQuery(sQuery);
	
	Format(sQuery, sizeof(sQuery), "DELETE FROM `gangs_skills` WHERE `GangID` = '%d'", gangid);
	SQLQuery(sQuery);
	
	RemoveGangFromArray(gangid);
}

stock void RemoveGangFromArray(int gangid)
{
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		if (iGang[iGangID] == gangid)
		{
			g_aCacheGang.Erase(i);
			break;
		}
	}
}
