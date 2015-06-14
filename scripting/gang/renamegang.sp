public Action Command_RenameGang(int client, int args)
{
	if (client < 1 || !IsClientInGame(client) )
		return Plugin_Handled;
	
	if(!g_cGangRenameEnable.BoolValue)
	{
		ReplyToCommand(client, "Es können derzeit keine Gangs umbenannt werden!"); // TODO: Translation
		return Plugin_Handled;
	}
	
	if(args != 1)
	{
		ReplyToCommand(client, "Syntax: sm_renamegang <Name>"); // TODO: Translation
		return Plugin_Handled;
	}
	
	char sArg[64];
	GetCmdArgString(sArg, sizeof(sArg));
	
	Gang_RenameClientGang(client, Gang_GetClientGang(client), sArg);
	return Plugin_Handled;
}
