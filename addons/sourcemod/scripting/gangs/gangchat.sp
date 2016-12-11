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
			PrintToChat(i, "[%s] %N: %s", sGang, client, sText);
	
	return Plugin_Continue;
}