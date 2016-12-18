stock void ShowSettings(int client)
{
	char sGang[12];
	Gangs_GetName(g_iClientGang[client], sGang, sizeof(sGang));
	
	Menu menu = new Menu(Menu_GangSettings);
	Format(sGang, sizeof(sGang), "%s - Settings", sGang); // TODO: Translations
	menu.SetTitle(sGang);
	menu.AddItem("rename", "Rename");
	menu.ExitBackButton = true;
	menu.ExitButton = false;
	menu.Display(client, g_cGangMenuDisplayTime.IntValue);
}

public int Menu_GangSettings(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char sParam[32];
		menu.GetItem(param, sParam, sizeof(sParam));
		
		if(StrEqual(sParam, "rename", false))
		{
			RenameGangMenu(client);
			OpenClientGang(client);
		}
	}
	if (action == MenuAction_Cancel)
		if(param == MenuCancel_ExitBack)
			OpenClientGang(client);
	if (action == MenuAction_End)
		delete menu;
}