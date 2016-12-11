public Action Command_GangChat(int client, int args)
{
	if(!Gang_IsClientInGang(client))
		return Plugin_Handled;
	
	char sText[MAX_MESSAGE_LENGTH];
	char sBuffer[MAX_MESSAGE_LENGTH];
	
	int iGang = Gang_GetClientGang(client);
	int iLength = g_cGangCreateMaxLen.IntValue += 1;
	char[] sGang = new char[iLength];
	
	Gang_GetName(iGang, sGang, iLength);
	
	for (int i = 1; i <= args; i++)
	{
		GetCmdArg(i, sBuffer, sizeof(sBuffer));
		Format(sText, sizeof(sText), "%s %s", sText , sBuffer);
	}
	
	LoopClients(i)
		if(Gang_IsClientInGang(i) && Gang_GetClientGang(i) == iGang)
			PrintToChat(i, "[%s] %N: %s", sGang, client, sText);
	
	return Plugin_Continue;
}