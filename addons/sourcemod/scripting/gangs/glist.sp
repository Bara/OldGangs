public Action Command_ListGang(int client, int args)
{
	if (!Gangs_IsClientValid(client) )
		return Plugin_Handled;
	
	Menu mMenu = new Menu(Menu_GangList);
	mMenu.SetTitle("Gangs list"); // TODO: Translations
	
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		mMenu.AddItem("", iGang[sGangName], ITEMDRAW_DISABLED);
	}
	
	mMenu.ExitButton = true;
	mMenu.Display(client, 0);
	
	return Plugin_Handled;
}

public int Menu_GangList(Menu panel, MenuAction action, int client, int param)
{
	if(action == MenuAction_End)
		CloseHandle(panel);
}
