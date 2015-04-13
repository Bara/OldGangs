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
	
	char sArg[64];
	GetCmdArgString(sArg, sizeof(sArg));
	
	if(!CheckGangName(client, sArg))
		return Plugin_Handled;
	
	ReplyToCommand(client, "Sie könnten diese Gang (%s) erstellen, aber das wäre noch zu früh... :(", sArg);
	return Plugin_Handled;
}

public bool CheckGangName(int client, const char[] sArg)
{
	char sRegex[128];
	g_cGangRegex.GetString(sRegex, sizeof(sRegex));
	Handle hRegex = CompileRegex(sRegex);
	
	if(MatchRegex(hRegex, sArg) != 1)
	{
		ReplyToCommand(client, "Ihr Gang Name enthält verbotene Zeichen!");
		return false;
	}
	
	if (strlen(sArg) < g_cGangMinLen.IntValue)
	{
		ReplyToCommand(client, "Der Gang Name ist zu kurz!");
		return false;
	}
	
	if (strlen(sArg) > g_cGangMaxLen.IntValue)
	{
		ReplyToCommand(client, "Der Gang Name ist zu lang!");
		return false;
	}
	
	if(!CanCreateGang(client))
	{
		ReplyToCommand(client, "Sie sind bereits in einer Gang!");
		return false;
	}
	
	return true;
}

stock bool CanCreateGang(int client)
{
	if(!g_bIsInGang[client] && g_iClientGang[client] == 0)
		return true;
	return false;
}