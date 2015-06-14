public Action Command_ListGang(int client, int args)
{
	if (client < 1 || !IsClientInGame(client) )
		return Plugin_Handled;
	
	Menu mMenu = new Menu(Menu_GangList);
	mMenu.SetTitle("Gang list"); // TODO: Translations
	
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
