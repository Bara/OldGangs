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
	
	Format(sPoints, sizeof(sPoints), "Points: %d", points); // TODO: Translation
	Format(sOnline, sizeof(sOnline), "Online: %d/%d", online, members); // TODO: Translation
	
	Format(sTitle, sizeof(sTitle), "%s\n \n%s\n \n%s\n ", sGang, sPoints, sOnline); // TODO: Translation
	
	Menu menu = new Menu(Menu_GangMenu);
	
	menu.SetTitle(sTitle);
	
	menu.AddItem("skills", "Skills");
	if(Gang_GetClientLevel(client) == GANG_LEADER)
	{
		menu.AddItem("members", "Members");
		menu.AddItem("settings", "Settings\n ");
	}	
	else
	{
		menu.AddItem("members", "Members\n ");
	}
	
	if(Gang_GetClientLevel(client) < GANG_LEADER)
	{
		menu.AddItem("leftgang", "Left Gang\n ");
	}
	menu.ExitButton = true;
	
	menu.Display(client, g_cGangMenuDisplayTime.IntValue);
}

public int Menu_GangMenu(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_End)
		CloseHandle(menu);
}

