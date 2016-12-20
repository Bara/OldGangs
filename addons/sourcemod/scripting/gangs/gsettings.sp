stock void ShowSettings(int client)
{
	char sGang[32];
	int GangID = Gangs_GetClientGang(client);
	Gangs_GetName(GangID, sGang, sizeof(sGang));
	
	Menu menu = new Menu(Menu_GangSettings);
	Format(sGang, sizeof(sGang), "%s - Settings", sGang); // TODO: Translations
	menu.SetTitle(sGang);
	
	if(!g_bInRename[client])
		menu.AddItem("rename", "Rename");
	else
		menu.AddItem("rename", "Rename (in progress)", ITEMDRAW_DISABLED);
	
	if(Gangs_GetClientLevel(client) == GANGS_LEADER)
		menu.AddItem("delete", "Delete");
	
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
			if(!g_bInRename[client])
				RenameGangMenu(client);
			else
				CPrintToChat(client, "Rename process already running!");
			
			ShowSettings(client);
		}
		else if(StrEqual(sParam, "delete", false))
			ShowDeleteGangMenu(client);
	}
	if (action == MenuAction_Cancel)
		if(param == MenuCancel_ExitBack)
			OpenClientGang(client);
	if (action == MenuAction_End)
		delete menu;
}