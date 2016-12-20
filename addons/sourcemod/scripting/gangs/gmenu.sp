public Action Command_Gang(int client, int args)
{
	if (!Gangs_IsClientValid(client) )
		return Plugin_Handled;
	
	if(args > 0)
	{
		ReplyToCommand(client, "Syntax: sm_gang"); // TODO: Translation
		return Plugin_Handled;
	}
	
	OpenClientGang(client);
	
	return Plugin_Handled;
}

public int Native_OpenClientGang(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!Gangs_IsClientValid(client) )
		return;
	
	OpenClientGang(client);
}

stock void OpenClientGang(int client)
{
	if (!g_bIsInGang[client])
	{
		PrintToChat(client, "You aren't in a gang"); // TODO: Translation
		return;
	}
	
	char sTitle[64], sPoints[32], sOnline[32];
	
	int points = Gangs_GetPoints(g_iClientGang[client]);
	int online = Gangs_GetOnlinePlayers(g_iClientGang[client]);
	int members = Gangs_GetMembersCount(g_iClientGang[client]);
	int maxmembers = Gangs_GetMaxMembers(g_iClientGang[client]);
	
	Format(sPoints, sizeof(sPoints), "Points: %d", points); // TODO: Translation
	Format(sOnline, sizeof(sOnline), "Online: %d/%d/%d", online, members, maxmembers); // TODO: Translation
	
	Format(sTitle, sizeof(sTitle), "%s - Main\n%s\n%s\n \n", g_sGang[g_iClientGang[client]], sPoints, sOnline); // TODO: Translation
	
	Menu menu = new Menu(Menu_GangMenu);
	
	menu.SetTitle(sTitle);
	
	menu.AddItem("skills", "Skills"); // TODO: Translation
	menu.AddItem("members", "Members"); // TODO: Translation
	
	if(Gangs_GetClientLevel(client) == GANGS_LEADER)
		menu.AddItem("settings", "Settings"); // TODO: Translation
	else
		menu.AddItem("leftgang", "Left Gang"); // TODO: Translation
	
	menu.ExitButton = true;
	
	menu.Display(client, g_cGangMenuDisplayTime.IntValue);
}

public int Menu_GangMenu(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char sParam[32];
		menu.GetItem(param, sParam, sizeof(sParam));
		
		if(StrEqual(sParam, "members", false))
			ShowMembers(client);
		
		if(StrEqual(sParam, "skills", false))
			ShowSkills(client);
		
		if(StrEqual(sParam, "settings", false))
			ShowSettings(client);
		
		if(StrEqual(sParam, "leftgang", false))
			ShowLeftGangMenu(client);
	}
	if (action == MenuAction_End)
		delete menu;
}

stock void ShowMembers(int client)
{
	char sGang[32], sRang[18], sName[MAX_NAME_LENGTH], sSteam[64];
	
	GetClientAuthId(client, AuthId_SteamID64, sSteam, sizeof(sSteam));
	
	Menu menu = new Menu(Menu_GangMembers);
	Format(sGang, sizeof(sGang), "%s - Members", g_sGang[g_iClientGang[client]]); // TODO: Translations
	menu.SetTitle(sGang);
	
	if(g_cGangInviteMenuEnable.BoolValue)
	{
		int iGLevel = Gangs_GetClientLevel(client);
		
		if(iGLevel == GANGS_LEADER || iGLevel == GANGS_INVITER)
			menu.AddItem("invite", "Invite player");
	}
	
	for (int i = 0; i < g_aCacheGangMembers.Length; i++)
	{
		// TODO: Add new menu for offline gang members (maybe a new array?)
		int iGangMembers[Cache_Gangs_Members];
		g_aCacheGangMembers.GetArray(i, iGangMembers[0]);
		
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
		
		if(Gangs_GetClientLevel(client) < GANGS_LEADER || StrEqual(sSteam, iGangMembers[sCommunityID]))
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
		{
			ShowInvitePlayers(client);
		}
	}
	if (action == MenuAction_Cancel)
		if(param == MenuCancel_ExitBack)
			OpenClientGang(client);
	if (action == MenuAction_End)
		delete menu;
}

stock void ShowSkills(int client)
{
	char sGang[32];
	int count = 0;
	char sSkill[12], sSkillID[12];
	int iGangGangSkills[Cache_Gangs_Skills];
	
	Menu menu = new Menu(Menu_GangSkillList);
	Format(sGang, sizeof(sGang), "%s - Skills", g_sGang[g_iClientGang[client]]); // TODO: Translations
	menu.SetTitle(sGang);
	for (int i = 0; i < g_aCacheGangSkills.Length; i++)
	{
		g_aCacheGangSkills.GetArray(i, iGangGangSkills[0]);
		
		if(iGangGangSkills[iSkillID] > 0)
		{
			count++;
			Format(sSkill, sizeof(sSkill), "%d", iGangGangSkills[iSkillID]);
			Format(sSkillID, sizeof(sSkillID), "%d", iGangGangSkills[iSkillID]);
			menu.AddItem(sSkillID, sSkill);
		}
	}

	if(count == 0)
	{
		menu.AddItem("noskill", "No skills found!", ITEMDRAW_DISABLED);
	}
	
	menu.ExitBackButton = true;
	menu.ExitButton = false;
	menu.Display(client, g_cGangMenuDisplayTime.IntValue);
}

public int Menu_GangSkillList(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Cancel)
		if(param == MenuCancel_ExitBack)
			OpenClientGang(client);
	if (action == MenuAction_End)
		delete menu;
}