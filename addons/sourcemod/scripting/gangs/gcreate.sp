public Action Command_CreateGang(int client, int args)
{
	if (!Gangs_IsClientValid(client) )
		return Plugin_Handled;
	
	if(!g_cGangCreateEnable.BoolValue)
	{
		CPrintToChat(client, "Gang creation is currently disabled"); // TODO: Translation
		return Plugin_Handled;
	}
	
	if(args < 1)
	{
		CPrintToChat(client, "Syntax: sm_creategang <Name>"); // TODO: Translation
		return Plugin_Handled;
	}
	
	char sArg[64];
	GetCmdArgString(sArg, sizeof(sArg));
	
	CreateGang(client, sArg);
	return Plugin_Handled;
}

public int Native_CreateClientGang(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!Gangs_IsClientValid(client) )
		return;
	
	char sGang[64];
	GetNativeString(2, sGang, sizeof(sGang));
	
	if(!g_cGangCreate3rdEnable.BoolValue)
	{
		CPrintToChat(client, "Gang creation by 3rd-party-plugins is currently disabled"); // TODO: Translation
		return;
	}
	
	CreateGang(client, sGang);
}

stock bool CheckGangName(int client, const char[] sArg)
{
	char sRegex[128];
	g_cGangCreateRegex.GetString(sRegex, sizeof(sRegex));
	Handle hRegex = CompileRegex(sRegex);
	
	if(MatchRegex(hRegex, sArg) != 1)
	{
		CPrintToChat(client, "Forbidden chars in gang name"); // TODO: Translation
		return false;
	}
	
	if (strlen(sArg) < g_cGangCreateMinLen.IntValue)
	{
		CPrintToChat(client, "Gang name is too short"); // TODO: Translation
		return false;
	}
	
	if (strlen(sArg) > g_cGangCreateMaxLen.IntValue)
	{
		CPrintToChat(client, "Gang name is too long"); // TODO: Translation
		return false;
	}
	
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		if (StrEqual(iGang[sGangName], sArg, false))
		{
			CPrintToChat(client, "Gang name already in use"); // TODO: Translation
			return false;
		}
	}
	
	if(!CanCreateGang(client))
	{
		ReplyToCommand(client, "You already in a gang"); // TODO: Translation
		return false;
	}
	
	return true;
}

stock void CreateGang(int client, const char[] gang)
{
	if(!CheckGangName(client, gang))
	{
		CPrintToChat(client, "Creation of %s failed!", gang); // TODO: Translation
		return;
	}

	char sQuery[512];
	Format(sQuery, sizeof(sQuery), "INSERT INTO `gangs` (`GangName`) VALUES ('%s')", gang);

	Handle hDP = CreateDataPack();
	WritePackCell(hDP, GetClientUserId(client));
	WritePackString(hDP, gang);
	SQL_TQuery(g_hDatabase, SQL_CreateGang, sQuery, hDP);
}

public void SQL_CreateGang(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (error[0])
	{
		Log_File(_, _, ERROR, "(SQL_CreateGang) Query failed: %s", error);
		CloseHandle(pack);
		return;
	}
		
	char sGang[64];

	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	ReadPackString(pack, sGang, sizeof(sGang));
	CloseHandle(pack);

	char sQuery[512];
	Format(sQuery, sizeof(sQuery), "SELECT GangID FROM `gangs` WHERE `GangName` ='%s'", sGang);
	
	Handle hPack = CreateDataPack();
	WritePackCell(hPack, GetClientUserId(client));
	WritePackString(hPack, sGang);
	SQL_TQuery(g_hDatabase, SQL_SaveClientGangID, sQuery, hPack, DBPrio_Low);
}

public void SQL_SaveClientGangID(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (error[0])
	{
		Log_File(_, _, ERROR, "(SQL_SaveClientGangID) Query failed: %s", error);
		return;
	}
	
	char sGang[64];

	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	ReadPackString(pack, sGang, sizeof(sGang));
	CloseHandle(pack);

	if (!Gangs_IsClientValid(client) )
		return;
	
	if (hndl != null)
	{
		while(SQL_FetchRow(hndl))
		{
			if(SQL_FetchInt(hndl, 0) > 0)
			{
				AddGangToArray(SQL_FetchInt(hndl, 0), sGang);
				Log_File(_, _, INFO, "\"%L\" created %s!", client, sGang); // TODO: Translation
				g_iClientGang[client] = SQL_FetchInt(hndl, 0);
				AddOwnerToGang(client, g_iClientGang[client]);
			}
			else
			{
				g_bIsInGang[client] = false;
				g_iClientGang[client] = 0;
			}
		}
	}
}

stock void AddGangToArray(int GangID, const char[] sGang)
{
	int iGang[Cache_Gang];

	iGang[iGangID] = GangID;
	Format(iGang[sGangName], 64, "%s", sGang);
	iGang[iPoints] = 0;
	iGang[bChat] = false;
	iGang[bPrefix] = false;
	Format(iGang[sPrefixColor], 64, "");
	iGang[iMaxMembers] = 2;
	iGang[iMembers] = 1;

	Log_File(_, _, DEBUG, "[AddGangToArray] GangID: %d - GangName: %s - Points: %d - Chat: %d - Prefix: %d - PrefixColor: %s - MaxMembers: %d", iGang[iGangID], iGang[sGangName], iGang[iPoints], iGang[bChat], iGang[bPrefix], iGang[sPrefixColor], iGang[iMaxMembers]);

	g_aCacheGang.PushArray(iGang[0]);
}

stock void AddOwnerToGang(int client, int gang)
{
	char sQuery[512], sName[MAX_NAME_LENGTH], sEName[MAX_NAME_LENGTH];
	
	GetClientName(client, sName, sizeof(sName));
	SQL_EscapeString(g_hDatabase, sName, sEName, sizeof(sEName));
	
	Format(sQuery, sizeof(sQuery), "INSERT INTO `gangs_members` (`GangID`, `CommunityID`, `PlayerName`, `AccessLevel`) VALUES ('%d', '%s', '%s', '6')", gang, g_sClientID[client], sEName);
	SQL_TQuery(g_hDatabase, SQL_InsertOwner, sQuery, GetClientUserId(client));
}

public void SQL_InsertOwner(Handle owner, Handle hndl, const char[] error, any userid)
{
	if (error[0])
	{
		Log_File(_, _, ERROR, "(SQL_Callback) Query failed: %s", error);
		return;
	}
	
	int client = GetClientOfUserId(userid);
	
	if (!Gangs_IsClientValid(client) ))
		return;
		
	g_bIsInGang[client] = true;
	
	if(g_iClientGang[client] < 1 && !g_bIsInGang[client])
	{
		ReplyToCommand(client, "Creation of %s failed"); // TODO: Translation
		return;
	}
	
	char sGang[64];
	Gangs_GetName(g_iClientGang[client], sGang, sizeof(sGang));
	
	CPrintToChatAll("%N created %s!", client, sGang); // TODO: Translation
	
	Log_File(_, _, INFO, "\"%L\" created %s!", client, sGang); // TODO: Translation
	
	Gangs_PushClientArray(client);
	
	Call_StartForward(g_hGangCreated);
	Call_PushCell(client);
	Call_PushCell(g_iClientGang[client]);
	Call_Finish();
}

public void TQuery_GangMembers(Handle owner, Handle hndl, const char[] error, any userid)
{
	int client = GetClientOfUserId(userid);
	
	if (!Gangs_IsClientValid(client) )
		return;
	
	if (hndl != null)
	{
		if (error[0])
		{
			Log_File(_, _, ERROR, "(TQuery_GangMembers) Query failed: %s", error);
			return;
		}
		
		while(SQL_FetchRow(hndl))
		{
			if(SQL_FetchInt(hndl, 0) > 0)
			{
				int iGang[Cache_Gangs_Members];
				char sCName[MAX_NAME_LENGTH], sSName[MAX_NAME_LENGTH];
				GetClientName(client, sCName, sizeof(sCName));
				
				iGang[iGangID] = SQL_FetchInt(hndl, 0);
				SQL_FetchString(hndl, 1, iGang[sCommunityID], 64);
				SQL_FetchString(hndl, 2, sSName, sizeof(sSName));
				iGang[iAccessLevel] = SQL_FetchInt(hndl, 3);
				
				// currentname != sqlname
				if(!StrEqual(sCName, sSName, true))
				{
					// Insert new name in cache
					strcopy(iGang[sPlayerN], MAX_NAME_LENGTH, sCName);
					
					// Update name in database
					char sQuery[512], sCEName[MAX_NAME_LENGTH];
					SQL_EscapeString(g_hDatabase, sCName, sCEName, sizeof(sCEName));
					Format(sQuery, sizeof(sQuery), "UPDATE `gangs_members` SET `PlayerName` = '%s' WHERE `CommunityID` = '%s'", sCEName, iGang[sCommunityID]);
					SQLQuery(sQuery);
				}
				else
					strcopy(iGang[sPlayerN], MAX_NAME_LENGTH, sSName);
				
				Log_File(_, _, DEBUG, "[TQuery_GangMembers] GangID: %d - CommunityID: %s - PlayerName: %s - AccessLevel: %d", iGang[iGangID], iGang[sCommunityID], iGang[sPlayerN], iGang[iAccessLevel]);
	
				g_aCacheGangMembers.PushArray(iGang[0]);
				
				if(iGang[iGangID] > 0)
				{
					g_bIsInGang[client] = true;
					g_iClientGang[client] = iGang[iGangID];
				}
			}
			else
				g_bIsInGang[client] = false;
		}
	}
}
