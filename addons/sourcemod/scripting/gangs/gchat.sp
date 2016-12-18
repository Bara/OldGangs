public Action Command_GangChat(int client, int args)
{
	if(g_cEnableGangChat.BoolValue)
	{
		PrintToChat(client, "Gang chat is currently disabled!"); // TODO: Translation
		return Plugin_Handled;
	}
	
	if(!Gangs_IsClientInGang(client))
		return Plugin_Handled;
	
	char sText[MAX_MESSAGE_LENGTH];
	char sBuffer[MAX_MESSAGE_LENGTH];
	
	int iLength = g_cGangCreateMaxLen.IntValue += 1;
	char[] sGang = new char[iLength];
	
	Gangs_GetName(g_iClientGang[client], sGang, iLength);
	
	for (int i = 1; i <= args; i++)
	{
		GetCmdArg(i, sBuffer, sizeof(sBuffer));
		Format(sText, sizeof(sText), "%s %s", sText , sBuffer);
	}
	
	LoopClients(i)
		if(Gangs_IsClientInGang(i) && g_iClientGang[i] == g_iClientGang[client])
			if(strlen(sText) > 2)
				CPrintToChat(i, "{darkred}[%s] {darkblue}%N\x01: %s", sGang, client, sText);
	
	return Plugin_Continue;
}

public Action OnChatMessage(int& author, ArrayList recipients, char[] flagstring, char[] name, char[] message, bool& processcolors, bool& removecolors)
{
	if(g_bInRename[author])
	{
		if(CheckGangRename(author, message))
		{
			RenameGang(author, g_iClientGang[author], message);
			
			g_bInRename[author] = false;
			g_hRenameTimer[author] = null;
		}
		
		return Plugin_Handled;
	}
	
	if(g_cEnableGangPrefix.BoolValue)
		return Plugin_Continue;
	
	if(!Gangs_IsClientInGang(author))
		return Plugin_Continue;
	
	int iLength = g_cGangCreateMaxLen.IntValue += 1;
	char[] sGang = new char[iLength];
	
	Gangs_GetName(g_iClientGang[author], sGang, iLength);
	Format(name, MAXLENGTH_NAME, "{darkred}[%s] {darkblue}%s\x01", sGang, name);
	CFormatColor(name, MAXLENGTH_NAME);
	
	return Plugin_Changed;
}
