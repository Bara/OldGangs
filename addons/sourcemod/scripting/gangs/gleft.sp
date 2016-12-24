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
	
	RemovePlayerFromGang(g_sClientID[client]);
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
			RemovePlayerFromGang(g_sClientID[client]);
		}
		else if(StrEqual(sParam, "no", false))
		{
			CPrintToChat(client, "Okay, maybe next time.");
		}
	}
	if (action == MenuAction_End)
		delete menu;
}

stock void RemovePlayerFromGang(const char[] communityid)
{
	char sName[MAX_NAME_LENGTH];
	int level = -1;
	int gangid = -1;
	bool bFound = false;
	
	for (int i = 0; i < g_aCacheGangMembers.Length; i++)
	{
		int iGangMembers[Cache_Gangs_Members];
		g_aCacheGangMembers.GetArray(i, iGangMembers[0]);
		
		if(StrEqual(communityid, iGangMembers[sCommunityID]))
		{
			gangid = iGangMembers[iGangID];
			level = iGangMembers[iAccessLevel];
			
			strcopy(sName, sizeof(sName), iGangMembers[sPlayerN]);
			
			bFound = true;
			
			break;
		}
	}
	
	if(!bFound)
	{
		return;
	}
	
	if(level >= GANGS_LEADER)
	{
		return;
	}
	
	ErasePlayerArray(communityid);
	
	
	char sQuery[256];
	Format(sQuery, sizeof(sQuery), "DELETE FROM `gangs_members` WHERE `CommunityID` = '%s' AND `GangID` = '%d'", communityid, gangid);
	SQLQuery(sQuery);
	
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
	
	int client = FindClientByCommunityID(communityid);
	if(Gangs_IsClientValid(client))
	{
		CPrintToChatAll("%N left %s!", client, g_sGang[gangid]); // TODO: Translation
		Gangs_LogFile(_, INFO, "\"%s\" left %s!", client, g_sGang[gangid]); // TODO: Translation
		g_bIsInGang[client] = false;
		g_iClientGang[client] = 0;
		g_iClientLevel[client] = GANGS_NONE;
	}
	else
	{
		CPrintToChatAll("%s left %s!", sName, g_sGang[gangid]); // TODO: Translation
		Gangs_LogFile(_, INFO, "\"%s\" left %s!", sName, g_sGang[gangid]); // TODO: Translation
	}
	
	Call_StartForward(g_hGangLeft);
	Call_PushString(communityid);
	Call_PushString(sName);
	Call_PushCell(gangid);
	Call_Finish();
}
