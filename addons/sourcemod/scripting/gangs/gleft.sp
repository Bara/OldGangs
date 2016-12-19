public Action Command_LeftGang(int client, int args)
{
	if (!Gangs_IsClientValid(client) )
		return Plugin_Handled;
	
	RemoveClientFromGang(client, g_iClientGang[client]);
	
	return Plugin_Handled;
}

public int Native_LeftClientGang(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	RemoveClientFromGang(client, g_iClientGang[client]);
	
	g_bIsInGang[client] = false;
	g_iClientGang[client] = 0;
}

stock void RemoveClientFromGang(int client, int gangid)
{
	if(!Gangs_IsClientInGang(client))
	{
		ReplyToCommand(client, "You aren't in a gang"); // TODO: Translation
		return;
	}
	
	if(Gangs_GetClientLevel(client) > 5)
	{
		ReplyToCommand(client, "You can't run this command as owner"); // TODO: Translation
		return;
	}
	
	Gangs_EraseClientArray(client);
	
	char sQuery[256];
	Format(sQuery, sizeof(sQuery), "DELETE FROM `gangs_members` WHERE `CommunityID` = '%s' AND `GangID` = '%d'", g_sClientID[client], g_iClientGang[client]);
	SQLQuery(sQuery);
	
	char sGang[64];
	Gangs_GetName(gangid, sGang, sizeof(sGang));
	CPrintToChatAll("\"%L\" left %s!", client, sGang); // TODO: Translation
	Log_File(_, _, INFO, "\"%L\" left %s!", client, sGang); // TODO: Translation
	
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		if (iGang[iGangID] == gangid)
		{
			int count = iGang[iMembers] - 1;
			g_aCacheGang.Set(i, count, view_as<int>(iMembers));

			Log_File(_, _, DEBUG, "(RemoveClientFromGang) GangID: %d - Members: %d", gangid, count);

			break;
		}
	}
	
	Call_StartForward(g_hGangLeft);
	Call_PushCell(client);
	Call_PushCell(gangid);
	Call_Finish();
}
