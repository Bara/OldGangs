public Action Command_ListGang(int client, int args)
{
	if (!Gangs_IsClientValid(client) )
		return Plugin_Handled;
	
	Menu menu = new Menu(Menu_GangList);
	menu.SetTitle("Gangs list"); // TODO: Translations
	
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		menu.AddItem("", iGang[sGangName], ITEMDRAW_DISABLED);
	}
	
	menu.ExitButton = true;
	menu.Display(client, g_cGangMenuDisplayTime.IntValue);
	
	return Plugin_Handled;
}

public int Menu_GangList(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_End)
		CloseHandle(menu);
}
