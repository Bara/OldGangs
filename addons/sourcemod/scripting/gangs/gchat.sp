public Action Command_GangChat(int client, int args)
{
	if(!g_cEnableGangChat.BoolValue)
	{
		CPrintToChat(client, "Gang chat is currently disabled!"); // TODO: Translation
		return Plugin_Handled;
	}
	
	if(!g_bIsInGang[client])
		return Plugin_Handled;
	
	char sText[MAX_MESSAGE_LENGTH];
	char sBuffer[MAX_MESSAGE_LENGTH];
	
	for (int i = 1; i <= args; i++)
	{
		GetCmdArg(i, sBuffer, sizeof(sBuffer));
		Format(sText, sizeof(sText), "%s %s", sText , sBuffer);
	}
	
	LoopClients(i)
		if(g_bIsInGang[i] && !g_bClientMuted[client] && g_iClientGang[i] == g_iClientGang[client])
			if(strlen(sText) > 2)
				CPrintToChat(i, "[Gang] {darkred}[%s] {darkblue}%N\x01: %s", g_sGang[g_iClientGang[client]], client, sText);
	
	return Plugin_Continue;
}

public Action OnChatMessage(int& author, ArrayList recipients, char[] flagstring, char[] name, char[] message, bool& processcolors, bool& removecolors)
{
	if(!g_cEnableGangPrefix.BoolValue)
		return Plugin_Continue;
	
	if(!g_bIsInGang[author])
		return Plugin_Continue;

	Format(name, MAXLENGTH_NAME, "{darkred}[%s] {darkblue}%s\x01", g_sGang[g_iClientGang[author]], name);
	CFormatColor(name, MAXLENGTH_NAME);
	
	return Plugin_Changed;
}

public Action Command_Say(int client, const char[] command, int argc)
{
	if(IsChatTrigger() || (g_iInvited[client] <= 0 && !g_bInRename[client]))
	{
		return Plugin_Continue;
	}
	else if(g_iInvited[client] > 0)
	{
		char sMessage[12];
		GetCmdArgString(sMessage, sizeof(sMessage));
		StripQuotes(sMessage);
		
		if(StrEqual(sMessage, "accept", false))
		{
			AddClientToGang(client, g_iInvited[client]);
			return Plugin_Handled;
		}
		else if(StrEqual(sMessage, "decline", false))
		{
			Command_AbortGang(client, 0);
			CPrintToChatAll("%N declined the invite for the gang %s", client, g_sGang[g_iInvited[client]]);
			return Plugin_Handled;
		}
		else
			return Plugin_Continue;
	}
	else if (g_bInRename[client])
	{
		int iLength = g_cGangCreateMaxLen.IntValue + 1;
		char[] sNewName = new char[iLength];
		
		GetCmdArgString(sNewName, iLength);
		StripQuotes(sNewName);
		
		if(CheckGangRename(client, sNewName))
		{
			RenameGang(client, g_iClientGang[client], sNewName);
			ShowSettings(client);
			CloseRenameProcess(client);
		}
		
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}
