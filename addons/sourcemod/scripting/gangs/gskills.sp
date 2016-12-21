stock void ShowSkills(int client)
{
	char sGang[32];
	int count = 0;
	char sSkill[12], sSkillID[12];
	int iGangGangSkills[Cache_Gangs_Skills];
	
	Menu menu = new Menu(Menu_GangSkillList);
	Format(sGang, sizeof(sGang), "%s - Skills", g_sGang[g_iClientGang[client]]); // TODO: Translations
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
			OpenClientGang(client);
	if (action == MenuAction_End)
		delete menu;
}
