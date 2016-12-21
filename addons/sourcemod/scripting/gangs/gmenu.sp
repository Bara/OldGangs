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
	
	if(g_iClientLevel[client] == GANGS_LEADER)
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
