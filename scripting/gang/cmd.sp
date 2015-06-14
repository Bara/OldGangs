public Action Command_Gang(int client, int args)
{
	if (client < 1 || !IsClientInGame(client) )
		return Plugin_Handled;
	
	if(args > 0)
	{
		PrintToChat(client, "HAX! Dein Daten werden zur Sicherheit gespeichert."); // TODO: Translation
		return Plugin_Handled;
	}
	
	Gang_OpenClientGang(client);
	
	return Plugin_Handled;
}

public Action Command_RenameGang(int client, int args)
{
	if (client < 1 || !IsClientInGame(client) )
		return Plugin_Handled;
	
	if(!g_cGangRenameEnable.BoolValue)
	{
		PrintToChat(client, "Es können derzeit keine Gangs umbenannt werden!"); // TODO: Translation
		return Plugin_Handled;
	}
	
	if(args < 1)
	{
		PrintToChat(client, "Syntax: sm_renamegang <Name>"); // TODO: Translation
		return Plugin_Handled;
	}
	
	char sArg[64];
	GetCmdArgString(sArg, sizeof(sArg));
	
	Gang_RenameClientGang(client, Gang_GetClientGang(client), sArg);
	return Plugin_Handled;
}

public Action Command_LeftGang(int client, int args)
{
	if (client < 1 || !IsClientInGame(client) )
		return Plugin_Handled;
	
	Gang_ClientLeftGang(client);
	
	return Plugin_Handled;
}
