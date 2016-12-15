public Action Command_GangChat(int client, int args)
{
	if(!Gangs_IsClientInGang(client))
		return Plugin_Handled;
	
	char sText[MAX_MESSAGE_LENGTH];
	char sBuffer[MAX_MESSAGE_LENGTH];
	
	int iGang = Gangs_GetClientGang(client);
	int iLength = g_cGangCreateMaxLen.IntValue += 1;
	char[] sGang = new char[iLength];
	
	Gangs_GetName(iGang, sGang, iLength);
	
	for (int i = 1; i <= args; i++)
	{
		GetCmdArg(i, sBuffer, sizeof(sBuffer));
		Format(sText, sizeof(sText), "%s %s", sText , sBuffer);
	}
	
	LoopClients(i)
		if(Gangs_IsClientInGang(i) && Gangs_GetClientGang(i) == iGang)
			if(strlen(sText) > 2)
				CPrintToChat(i, "{darkred}[%s] {darkblue}%N\x01: %s", sGang, client, sText);
	
	return Plugin_Continue;
}

public Action OnChatMessage(int& author, ArrayList recipients, char[] flagstring, char[] name, char[] message, bool& processcolors, bool& removecolors)
{
	if(!Gangs_IsClientInGang(author))
		return Plugin_Continue;
	
	int iGang = Gangs_GetClientGang(author);
	int iLength = g_cGangCreateMaxLen.IntValue += 1;
	char[] sGang = new char[iLength];
	
	Gangs_GetName(iGang, sGang, iLength);
	Format(name, MAXLENGTH_NAME, "{darkred}[%s] {darkblue}%s", sGang, name);
	CFormatColor(name, MAXLENGTH_NAME);
	
	return Plugin_Changed;
}
