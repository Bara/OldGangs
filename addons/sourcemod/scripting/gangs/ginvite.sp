stock void ShowInvitePlayers(int client)
{
	char sGang[32];
	int GangID = Gangs_GetClientGang(client);
	Gangs_GetName(GangID, sGang, sizeof(sGang));
	
	Menu menu = new Menu(Menu_GangInvite);
	Format(sGang, sizeof(sGang), "%s - Invite", sGang); // TODO: Translations
	menu.SetTitle(sGang);
	
	char sUserID[12], sName[MAX_NAME_LENGTH];
	int iUserID = -1;
	
	LoopClients(i)
	{
		if(!g_bIsInGang[i] && g_iInvited[i] == -1)
		{
			iUserID = GetClientUserId(i);
			IntToString(iUserID, sUserID, sizeof(sUserID));
			GetClientName(i, sName, sizeof(sName));
			menu.AddItem(sUserID, sName);
		}
	}
	
	menu.ExitBackButton = true;
	menu.ExitButton = false;
	menu.Display(client, g_cGangMenuDisplayTime.IntValue);
}

public int Menu_GangInvite(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char sParam[32];
		menu.GetItem(param, sParam, sizeof(sParam));
		int target = GetClientOfUserId(StringToInt(sParam));
		
		if(target > 0 && IsClientInGame(target))
		{
			if(!g_bIsInGang[target] || g_iInvited[target] != -1)
			{
				CPrintToChat(client, "%N was already invited!", target);
			}
			else
			{
				float fTime = g_cGangInviteTime.FloatValue;
				
				g_iInvited[target] = g_iClientGang[client];
				
				char sGang[64];
				Gangs_GetName(g_iClientGang[client], sGang, sizeof(sGang));
				
				CPrintToChat(client, "You've invited %N to %s!", target, sGang);
				
				CPrintToChat(target, "You was invited by %N in his gang %N!", client, sGang);
				CPrintToChat(target, "You can accept this request with typing \"accept\" in chat...");
				CPrintToChat(target, "or decline this request with typing \"decline\" in chat...");
				CPrintToChat(target, "or wait %.2f seconds until the invite will expired.", fTime); // TODO: Add g_cGangInviteTime
				
				g_hInviteTimer[client] = CreateTimer(fTime, Timer_InviteExpire, GetClientUserId(client));
			}
			Gangs_OpenClientGang(client);
		}
	}
	if (action == MenuAction_Cancel)
		if(param == MenuCancel_ExitBack)
			OpenClientGang(client);
	if (action == MenuAction_End)
		delete menu;
}

public Action Timer_InviteExpire(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	
	if(client > 0 && IsClientInGame(client) && !g_hInviteTimer[client])
	{
		char sGang[64];
		Gangs_GetName(g_iInvited[client], sGang, sizeof(sGang));
		
		CPrintToChat(client, "Invite for %s expired!", sGang);
		
		g_iInvited[client] = -1;
	}
	
	g_hInviteTimer[client] = null;
	return Plugin_Stop;
}

stock void AddClientToGang(int client, int gang)
{
	char sQuery[512], sName[MAX_NAME_LENGTH], sEName[MAX_NAME_LENGTH];
	
	GetClientName(client, sName, sizeof(sName));
	SQL_EscapeString(g_hDatabase, sName, sEName, sizeof(sEName));
	
	Format(sQuery, sizeof(sQuery), "INSERT INTO `gangs_members` (`GangID`, `CommunityID`, `PlayerName`, `AccessLevel`) VALUES ('%d', '%s', '%s', '1')", g_iInvited[client], g_sClientID[client], sEName);
	SQL_TQuery(g_hDatabase, SQL_InsertPlayer, sQuery, GetClientUserId(client));
}

public void SQL_InsertPlayer(Handle owner, Handle hndl, const char[] error, any userid)
{
	if (error[0])
	{
		Log_File(_, _, ERROR, "(SQL_Callback) Query failed: %s", error);
		return;
	}
	
	int client = GetClientOfUserId(userid);
	
	if(!IsClientInGame(client))
		return;
		
	g_bIsInGang[client] = true;
	g_iClientGang[client] = g_iInvited[client];
	g_iInvited[client] = -1;
	
	char sGang[64];
	Gangs_GetName(g_iClientGang[client], sGang, sizeof(sGang));
	
	CPrintToChatAll("%N joined the gang %s!", client, sGang); // TODO: Translation
	
	Log_File(_, _, INFO, "\"%L\" joined the gang %s!", client, sGang); // TODO: Translation
	
	Gangs_PushClientArray(client);
	
	Call_StartForward(g_hGangClientJoined);
	Call_PushCell(client);
	Call_PushCell(g_iClientGang[client]);
	Call_Finish();
}