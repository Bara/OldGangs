public Action Command_AbortGang(int client, int args)
{
	if(g_bInRename[client] && g_hRenameTimer[client] != null)
	{
		g_bInRename[client] = false;
		g_hRenameTimer[client] = null;
		
		CPrintToChat(client, "Rename process aborted");
	}
}