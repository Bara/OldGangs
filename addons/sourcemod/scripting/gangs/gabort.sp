public Action Command_AbortGang(int client, int args)
{
	if(g_iInvited[client] > 0 || g_hInviteTimer[client] != null)
		CloseInviteProcess(client);
	
	if(g_bInRename[client] || g_hRenameTimer[client] != null)
		CloseRenameProcess(client);
}