public int Menu_GangList(Menu panel, MenuAction action, int client, int param)
{
	if(action == MenuAction_End)
	{
		CloseHandle(panel);
	}
}

public int Menu_GangMain(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char sInfo[32];
		GetMenuItem(menu, param, sInfo, sizeof(sInfo));
		
		if (StrEqual(sInfo, "info", false))
			OpenClientGangInfo(client);
	}
	else if (action == MenuAction_End)
		CloseHandle(menu);
}
