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
	
	ReplyToCommand(client, "Die Gang (%s) wird gegründet...", sArg);
	
	CreateGang(client, sArg);
	return Plugin_Handled;
}
