public Action Command_CreateGang(int client, int args)
{
	PrintToChat(client, "CommunityID - %s", g_sClientID[client]);
	
	if(!g_cGangCreate.BoolValue)
	{
		ReplyToCommand(client, "Es können derzeit keine Gangs erstellt werden!");
		return Plugin_Handled;
	}
	
	if(args < 1)
	{
		ReplyToCommand(client, "Syntax: sm_creategang <Name>");
		return Plugin_Handled;
	}
	
	char sArg[64], sRegex[128];
	GetCmdArgString(sArg, sizeof(sArg));
	g_cGangRegex.GetString(sRegex, sizeof(sRegex));
	
	Handle hRegex = CompileRegex(sRegex);
	if(MatchRegex(hRegex, sArg) != 1)
	{
		ReplyToCommand(client, "Ihr Gang Name enthält verbotene Zeichen!");
		return Plugin_Handled;
	}
	
	if (strlen(sArg) < g_cGangMinLen.IntValue)
	{
		ReplyToCommand(client, "Der Gang Name ist zu kurz!");
		return Plugin_Handled;
	}
	
	if (strlen(sArg) > g_cGangMaxLen.IntValue)
	{
		ReplyToCommand(client, "Der Gang Name ist zu lang!");
		return Plugin_Handled;
	}
	
	if(CanCreateGang(client))
		ReplyToCommand(client, "Sie könnten diese Gang (%s) erstellen, aber das wäre noch zu früh... :(", sArg);
	else
		ReplyToCommand(client, "Sie sind bereits in einer Gang!");
	return Plugin_Handled;	
}

stock bool CanCreateGang(int client)
{
	if(!g_bIsInGang[client] && g_iClientGang[client] == 0)
		return true;
	return false;
}