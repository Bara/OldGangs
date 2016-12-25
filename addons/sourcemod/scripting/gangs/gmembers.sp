stock void ShowMembers(int client, bool online = true)
{
	char sGang[32], sRang[18], sName[MAX_NAME_LENGTH];
	
	Menu menu = new Menu(Menu_GangMembers);
	Format(sGang, sizeof(sGang), "%s - Members", g_sGang[g_iClientGang[client]]); // TODO: Translations
	menu.SetTitle(sGang);
	
	if(online)
	{
		if(g_cGangInviteMenuEnable.BoolValue)
		{
			int iGLevel = g_iClientLevel[client];
			
			if(iGLevel == GANGS_LEADER || iGLevel == GANGS_INVITER)
				menu.AddItem("invite", "Invite player");
		}
		
		menu.AddItem("offline", "Offline players");
	}
	
	for (int i = 0; i < g_aCacheGangMembers.Length; i++)
	{
		int iGangMembers[Cache_Gangs_Members];
		g_aCacheGangMembers.GetArray(i, iGangMembers[0]);
		
		if(online)
		{
			if(!iGangMembers[bOnline])
				continue;
		}
		else
		{
			if(iGangMembers[bOnline])
				continue;
		}
		
		for (int j = GANGS_TRIAL; j <= GANGS_LEADER; j++)
			{
				if(iGangMembers[iAccessLevel] == j)
				{
					Gangs_GetRangName(j, sRang, sizeof(sRang));
					break;
				}
			}
	
		Format(sName, sizeof(sName), "[%s] %s", sRang, iGangMembers[sPlayerN]);
		
		if(StrEqual(g_sClientID[client], iGangMembers[sCommunityID]) || iGangMembers[iAccessLevel] == GANGS_LEADER || (g_iClientLevel[client] == GANGS_COLEADER && iGangMembers[iAccessLevel] < g_iClientLevel[client]))
			menu.AddItem("", sName, ITEMDRAW_DISABLED);
		else
			menu.AddItem(iGangMembers[sCommunityID], sName);
	}
	
	char sBuffer[32];
	IntToString(online, sBuffer, sizeof(sBuffer));
	
	PushMenuCell(menu, "bOnline", online);
	
	menu.ExitBackButton = true;
	menu.ExitButton = false;
	menu.Display(client, g_cGangMenuDisplayTime.IntValue);
}

public int Menu_GangMembers(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char sParam[32];
		menu.GetItem(param, sParam, sizeof(sParam));
		
		if(StrEqual(sParam, "invite", false))
			ShowInvitePlayers(client);
		else if(StrEqual(sParam, "offline", false))
			ShowMembers(client, false);
		else
			ShowPlayerDetails(client, sParam);
	}
	if (action == MenuAction_Cancel)
	{
		bool online = view_as<bool>(GetMenuCell(menu, "bOnline"));
		
		if(param == MenuCancel_ExitBack)
		{
			if(online)
				OpenClientGang(client);
			else
				ShowMembers(client);
		}
	}
	if (action == MenuAction_End)
		delete menu;
}

stock void ShowPlayerDetails(int client, const char[] communityid)
{
	char sGang[MAX_NAME_LENGTH + 32], sRang[18], sName[MAX_NAME_LENGTH];
	int level = -1;
	bool muted = false;
	bool found = false;
	
	for (int i = 0; i < g_aCacheGangMembers.Length; i++)
	{
		int iGangMembers[Cache_Gangs_Members];
		g_aCacheGangMembers.GetArray(i, iGangMembers[0]);
		
		if(StrEqual(communityid, iGangMembers[sCommunityID]))
		{
			level = iGangMembers[iAccessLevel];
			muted = iGangMembers[bMuted];
			
			for (int j = GANGS_TRIAL; j <= GANGS_LEADER; j++)
			{
				if(level == j)
				{
					Gangs_GetRangName(j, sRang, sizeof(sRang));
					break;
				}
			}
			
			strcopy(sName, sizeof(sName), iGangMembers[sPlayerN]);
			
			found = true;
			
			break;
		}
	}
	
	if(!found)
	{
		CPrintToChat(client, "We can't find any player with this communityid ...");
		ShowMembers(client);
		return;
	}
	
	Menu menu = new Menu(Menu_GangMembersManage);
	Format(sGang, sizeof(sGang), "%s - Manage user\n%s - %s", g_sGang[g_iClientGang[client]], sName, sRang); // TODO: Translations
	menu.SetTitle(sGang);
	
	menu.AddItem("kick", "Kick");
	
	if(muted)
		menu.AddItem("unmute", "Unmute");
	else
		menu.AddItem("mute", "Mute");
	
	PushMenuString(menu, "targetID", communityid);
	PushMenuString(menu, "targetName", sName);
	
	menu.ExitBackButton = true;
	menu.ExitButton = false;
	menu.Display(client, g_cGangMenuDisplayTime.IntValue);
}

public int Menu_GangMembersManage(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char sParam[32];
		menu.GetItem(param, sParam, sizeof(sParam));
		
		char sTarget[32], sName[MAX_NAME_LENGTH];
		GetMenuString(menu, "targetID", sTarget, sizeof(sTarget));
		GetMenuString(menu, "targetName", sName, sizeof(sName));
		
		if(StrEqual(sParam, "kick", false))
			RemovePlayerFromGang(sTarget, true, client);
	}
	
	if (action == MenuAction_Cancel)
	{
		if(param == MenuCancel_ExitBack)
			ShowMembers(client);
	}
	
	if (action == MenuAction_End)
		delete menu;
}
