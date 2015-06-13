public int Menu_GangList(Menu panel, MenuAction action, int client, int param)
{
	if(action == MenuAction_End)
	{
		CloseHandle(panel);
	}
}

public int Panel_MainMenu(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_End)
		CloseHandle(menu);
}
