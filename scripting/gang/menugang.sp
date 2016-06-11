public Action Command_Gang(int client, int args)
{
	if (client < 1 || !IsClientInGame(client) )
		return Plugin_Handled;
	
	if(args > 0)
	{
		ReplyToCommand(client, "Syntax: sm_gang"); // TODO: Translation
		return Plugin_Handled;
	}
	
	Gang_OpenClientGang(client);
	
	return Plugin_Handled;
}

public int Native_OpenClientGang(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (client < 1 || !IsClientInGame(client))
		return;
	
	if (!g_bIsInGang[client])
	{
		PrintToChat(client, "Sie sind in keiner Gang!"); // TODO: Translation
		return;
	}
	
	OpenClientGang(client);
}


stock void OpenClientGang(int client)
{
	int GangID = Gang_GetClientGang(client);
	
	char sGang[64], sTitle[64], sPoints[32], sOnline[32];
	
	Gang_GetName(GangID, sGang, sizeof(sGang));
	int points = Gang_GetPoints(GangID);
	int online = Gang_GetOnlinePlayers(GangID);
	int members = Gang_GetMembersCount(GangID);
	int maxmembers = Gang_GetMaxMembers(GangID);
	
	Format(sPoints, sizeof(sPoints), "Points: %d", points); // TODO: Translation
	Format(sOnline, sizeof(sOnline), "Online: %d/%d/%d", online, members, maxmembers); // TODO: Translation
	
	Format(sTitle, sizeof(sTitle), "%s\n%s\n%s\n \n", sGang, sPoints, sOnline); // TODO: Translation
	
	Menu menu = new Menu(Menu_GangMenu);
	
	menu.SetTitle(sTitle);
	
	menu.AddItem("skills", "Skills"); // TODO: Translation
	menu.AddItem("members", "Members"); // TODO: Translation
	
	if(Gang_GetClientLevel(client) == GANG_LEADER)
		menu.AddItem("settings", "Settings"); // TODO: Translation
	else
		menu.AddItem("leftgang", "Left Gang\n "); // TODO: Translation
	
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
	}
	if (action == MenuAction_End)
		delete menu;
}

stock void ShowMembers(int client)
{
	char sGang[12], sRang[18], sName[MAX_NAME_LENGTH], sSteam[64];
	int GangID = Gang_GetClientGang(client);
	Gang_GetName(GangID, sGang, sizeof(sGang));
	
	GetClientAuthId(client, AuthId_SteamID64, sSteam, sizeof(sSteam));
	
	Menu menu = new Menu(Menu_GangMembers);
	menu.SetTitle(sGang);
	for (int i = 0; i < g_aCacheGangMembers.Length; i++)
	{
		int iGangMembers[Cache_Gang_Members];
		g_aCacheGangMembers.GetArray(i, iGangMembers[0]);
		
		if(iGangMembers[iAccessLevel] == GANG_LEADER)
			Gang_GetRangName(GANG_LEADER, sRang, sizeof(sRang));
		else if(iGangMembers[iAccessLevel] == GANG_COLEADER)
			Gang_GetRangName(GANG_COLEADER, sRang, sizeof(sRang));
		else if(iGangMembers[iAccessLevel] == GANG_SKILLER)
			Gang_GetRangName(GANG_SKILLER, sRang, sizeof(sRang));
		else if(iGangMembers[iAccessLevel] == GANG_INVITER)
			Gang_GetRangName(GANG_INVITER, sRang, sizeof(sRang));
		else if(iGangMembers[iAccessLevel] == GANG_MEMBER)
			Gang_GetRangName(GANG_MEMBER, sRang, sizeof(sRang));
		else if(iGangMembers[iAccessLevel] == GANG_TRIAL)
			Gang_GetRangName(GANG_TRIAL, sRang, sizeof(sRang));
	
		Format(sName, sizeof(sName), "[%s] %s", sRang, iGangMembers[sPlayerN]);
		
		if(Gang_GetClientLevel(client) < GANG_LEADER || StrEqual(sSteam, iGangMembers[sCommunityID]))
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
	if (action == MenuAction_Cancel)
		if(param == MenuCancel_ExitBack)
			Gang_OpenClientGang(client);
	if (action == MenuAction_End)
		delete menu;
}

stock void ShowSkills(int client)
{
	char sGang[12];
	int GangID = Gang_GetClientGang(client);
	int count = 0;
	char sSkill[12], sSkillID[12];
	int iGangGangSkills[Cache_Gang_Skills];
	
	Gang_GetName(GangID, sGang, sizeof(sGang));
	Menu menu = new Menu(Menu_GangSkillList);
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
			Gang_OpenClientGang(client);
	if (action == MenuAction_End)
		delete menu;
}