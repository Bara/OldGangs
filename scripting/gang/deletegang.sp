public Action Command_DeleteGang(int client, int args)
{
	if (client < 1 || !IsClientInGame(client) )
		return Plugin_Handled;
	
	Gang_DeleteClientGang(client, Gang_GetClientGang(client));
	
	return Plugin_Handled;
}

public int Native_DeleteClientGang(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int gangid = GetNativeCell(2);
	
	if (client < 1 || !IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_ABORTED, "Client %d is invalid!");
		return;
	}
	
	if (!g_bIsInGang[client])
	{
		ThrowNativeError(SP_ERROR_ABORTED, "Sie sind in keiner Gang!"); // TODO: Translation
		return;
	}
	
	if(Gang_GetClientLevel(client) < GANG_LEADER)
	{
		ThrowNativeError(SP_ERROR_ABORTED, "Sie sind nicht Leader der Gang!"); // TODO: Translation
		return;
	}
	
	DeleteGang(client, gangid);
}

stock void DeleteGang(int client, int gangid)
{
	char sGang[64];
	Gang_GetName(gangid, sGang, sizeof(sGang));
	
	PrintToChatAll("\"%L\" hat die Gang \"%s\" gelöscht!", client, sGang); // TODO: Translation
	Log_File(_, _, INFO, "\"%L\" hat die Gang \"%s\" gelöscht!", client, sGang); // TODO: Translation
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if(g_iClientGang[i] == gangid)
		{
			Gang_EraseClientArray(i);
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
	
	Format(sQuery, sizeof(sQuery), "DELETE FROM `gang` WHERE `GangID` = '%d'", gangid);
	SQLQuery(sQuery);
	
	Format(sQuery, sizeof(sQuery), "DELETE FROM `gang_members` WHERE `GangID` = '%d'", gangid);
	SQLQuery(sQuery);
	
	Format(sQuery, sizeof(sQuery), "DELETE FROM `gang_skills` WHERE `GangID` = '%d'", gangid);
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
