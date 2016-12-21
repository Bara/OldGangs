stock void ShowMembers(int client)
{
	char sGang[32], sRang[18], sName[MAX_NAME_LENGTH];
	
	Menu menu = new Menu(Menu_GangMembers);
	Format(sGang, sizeof(sGang), "%s - Members", g_sGang[g_iClientGang[client]]); // TODO: Translations
	menu.SetTitle(sGang);
	
	if(g_cGangInviteMenuEnable.BoolValue)
	{
		int iGLevel = g_iClientLevel[client];
		
		if(iGLevel == GANGS_LEADER || iGLevel == GANGS_INVITER)
			menu.AddItem("invite", "Invite player");
	}
	
	menu.AddItem("offline", "Offline players");
	
	for (int i = 0; i < g_aCacheGangMembers.Length; i++)
	{
		int iGangMembers[Cache_Gangs_Members];
		g_aCacheGangMembers.GetArray(i, iGangMembers[0]);
		
		if(!iGangMembers[bOnline])
			continue;
		
		if(iGangMembers[iAccessLevel] == GANGS_LEADER)
			Gangs_GetRangName(GANGS_LEADER, sRang, sizeof(sRang));
		else if(iGangMembers[iAccessLevel] == GANGS_COLEADER)
			Gangs_GetRangName(GANGS_COLEADER, sRang, sizeof(sRang));
		else if(iGangMembers[iAccessLevel] == GANGS_SKILLER)
			Gangs_GetRangName(GANGS_SKILLER, sRang, sizeof(sRang));
		else if(iGangMembers[iAccessLevel] == GANGS_INVITER)
			Gangs_GetRangName(GANGS_INVITER, sRang, sizeof(sRang));
		else if(iGangMembers[iAccessLevel] == GANGS_MEMBER)
			Gangs_GetRangName(GANGS_MEMBER, sRang, sizeof(sRang));
		else if(iGangMembers[iAccessLevel] == GANGS_TRIAL)
			Gangs_GetRangName(GANGS_TRIAL, sRang, sizeof(sRang));
	
		Format(sName, sizeof(sName), "[%s] %s", sRang, iGangMembers[sPlayerN]);
		
		if(g_iClientLevel[client] < GANGS_LEADER || StrEqual(g_sClientID[client], iGangMembers[sCommunityID]))
			menu.AddItem("", sName, ITEMDRAW_DISABLED);
		else
			menu.AddItem(iGangMembers[sCommunityID], sName);
	}
	
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
		
		if(StrEqual(sParam, "offline", false))
			ShowOfflineMembers(client);
	}
	if (action == MenuAction_Cancel)
		if(param == MenuCancel_ExitBack)
			OpenClientGang(client);
	if (action == MenuAction_End)
		delete menu;
}

stock void ShowOfflineMembers(int client)
{
	char sGang[32], sRang[18], sName[MAX_NAME_LENGTH];
	
	Menu menu = new Menu(Menu_GangMembersOffline);
	Format(sGang, sizeof(sGang), "%s - Offline Members", g_sGang[g_iClientGang[client]]); // TODO: Translations
	menu.SetTitle(sGang);
	
	for (int i = 0; i < g_aCacheGangMembers.Length; i++)
	{
		int iGangMembers[Cache_Gangs_Members];
		g_aCacheGangMembers.GetArray(i, iGangMembers[0]);
		
		if(iGangMembers[bOnline])
			continue;
		
		if(iGangMembers[iAccessLevel] == GANGS_LEADER)
			Gangs_GetRangName(GANGS_LEADER, sRang, sizeof(sRang));
		else if(iGangMembers[iAccessLevel] == GANGS_COLEADER)
			Gangs_GetRangName(GANGS_COLEADER, sRang, sizeof(sRang));
		else if(iGangMembers[iAccessLevel] == GANGS_SKILLER)
			Gangs_GetRangName(GANGS_SKILLER, sRang, sizeof(sRang));
		else if(iGangMembers[iAccessLevel] == GANGS_INVITER)
			Gangs_GetRangName(GANGS_INVITER, sRang, sizeof(sRang));
		else if(iGangMembers[iAccessLevel] == GANGS_MEMBER)
			Gangs_GetRangName(GANGS_MEMBER, sRang, sizeof(sRang));
		else if(iGangMembers[iAccessLevel] == GANGS_TRIAL)
			Gangs_GetRangName(GANGS_TRIAL, sRang, sizeof(sRang));
	
		Format(sName, sizeof(sName), "[%s] %s", sRang, iGangMembers[sPlayerN]);
		
		if(g_iClientLevel[client] < GANGS_LEADER || StrEqual(g_sClientID[client], iGangMembers[sCommunityID]))
			menu.AddItem("", sName, ITEMDRAW_DISABLED);
		else
			menu.AddItem(iGangMembers[sCommunityID], sName);
	}
	
	menu.ExitBackButton = true;
	menu.ExitButton = false;
	menu.Display(client, g_cGangMenuDisplayTime.IntValue);
}

public int Menu_GangMembersOffline(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Cancel)
		if(param == MenuCancel_ExitBack)
			ShowMembers(client);
	if (action == MenuAction_End)
		delete menu;
}
