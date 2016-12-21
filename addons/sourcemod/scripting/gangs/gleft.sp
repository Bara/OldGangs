public Action Command_LeftGang(int client, int args)
{
	if (!Gangs_IsClientValid(client) )
		return Plugin_Handled;
	
	ShowLeftGangMenu(client);
	
	return Plugin_Handled;
}

public int Native_LeftClientGang(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	RemoveClientFromGang(client, g_iClientGang[client]);
	
	g_bIsInGang[client] = false;
	g_iClientGang[client] = 0;
	g_iClientLevel[client] = GANGS_NONE;
}

stock void ShowLeftGangMenu(int client)
{
	char sGang[64];
	
	Menu menu = new Menu(Menu_GangLeft);
	Format(sGang, sizeof(sGang), "You're sure to left %s?", g_sGang[g_iClientGang[client]]); // TODO: Translations
	
	menu.SetTitle(sGang);
	menu.AddItem("yes", "Yes, I'm sure!");
	menu.AddItem("no", "No, it was a mistake...");
	menu.Display(client, g_cGangMenuDisplayTime.IntValue);
}

public int Menu_GangLeft(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char sParam[32];
		menu.GetItem(param, sParam, sizeof(sParam));
		
		if(StrEqual(sParam, "yes", false))
		{
			RemoveClientFromGang(client, g_iClientGang[client]);
		}
		else if(StrEqual(sParam, "no", false))
		{
			CPrintToChat(client, "Okay, maybe next time.");
		}
	}
	if (action == MenuAction_End)
		delete menu;
}

stock void RemoveClientFromGang(int client, int gangid)
{
	if(!g_bIsInGang[client])
	{
		CPrintToChat(client, "You aren't in a gang"); // TODO: Translation
		return;
	}
	
	if(g_iClientLevel[client] >= GANGS_LEADER)
	{
		CPrintToChat(client, "You can't run this command as owner"); // TODO: Translation
		return;
	}
	
	EraseClientArray(client);
	g_bIsInGang[client] = false;
	g_iClientGang[client] = 0;
	g_iClientLevel[client] = GANGS_NONE;
	
	char sQuery[256];
	Format(sQuery, sizeof(sQuery), "DELETE FROM `gangs_members` WHERE `CommunityID` = '%s' AND `GangID` = '%d'", g_sClientID[client], g_iClientGang[client]);
	SQLQuery(sQuery);
	
	CPrintToChatAll("%N left %s!", client, g_sGang[gangid]); // TODO: Translation
	Gangs_LogFile(_, INFO, "\"%L\" left %s!", client, g_sGang[gangid]); // TODO: Translation
	
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		if (iGang[iGangID] == gangid)
		{
			int count = iGang[iMembers] - 1;
			g_aCacheGang.Set(i, count, view_as<int>(iMembers));

			Gangs_LogFile(_, DEBUG, "(RemoveClientFromGang) GangID: %d - Members: %d", gangid, count);

			break;
		}
	}
	
	Call_StartForward(g_hGangLeft);
	Call_PushCell(client);
	Call_PushCell(gangid);
	Call_Finish();
}
