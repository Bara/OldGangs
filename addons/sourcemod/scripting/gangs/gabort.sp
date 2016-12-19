public Action Command_AbortGang(int client, int args)
{
	if(g_iInvited[client] > 0 || g_hInviteTimer[client] != null)
	{
		g_iInvited[client] = false;
		g_hInviteTimer[client] = null;
	}
	
	if(g_bInRename[client] && g_hRenameTimer[client] != null)
	{
		g_bInRename[client] = false;
		g_hRenameTimer[client] = null;
		
		CPrintToChat(client, "Rename process aborted");
	}
}