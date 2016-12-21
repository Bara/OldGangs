public Action Command_RenameGang(int client, int args)
{
	if (!Gangs_IsClientValid(client) )
		return Plugin_Handled;
	
	if(!g_cGangRenameEnable.BoolValue)
	{
		ReplyToCommand(client, "Gang Renaming is currently disabled!"); // TODO: Translation
		return Plugin_Handled;
	}
	
	if(args != 1)
	{
		ReplyToCommand(client, "Syntax: sm_renamegang <Name>"); // TODO: Translation
		return Plugin_Handled;
	}
	
	char sArg[64];
	GetCmdArgString(sArg, sizeof(sArg));
	
	RenameGang(client, g_iClientGang[client], sArg);
	return Plugin_Handled;
}

public int Native_RenameClientGang(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int gangid = GetNativeCell(2);
	
	char sGang[64];
	GetNativeString(3, sGang, sizeof(sGang));
	
	if (!Gangs_IsClientValid(client) )
		return;
	
	RenameGang(client, gangid, sGang);
}

stock bool CheckGangRename(int client, const char[] sGang)
{
	char sRegex[128];
	g_cGangCreateRegex.GetString(sRegex, sizeof(sRegex));
	Handle hRegex = CompileRegex(sRegex);
	
	if(MatchRegex(hRegex, sGang) != 1)
	{
		CPrintToChat(client, "Forbidden chars in gang name"); // TODO: Translation
		return false;
	}
	
	if (strlen(sGang) < g_cGangCreateMinLen.IntValue)
	{
		CPrintToChat(client, "Gang name is too short"); // TODO: Translation
		return false;
	}
	
	if (strlen(sGang) > g_cGangCreateMaxLen.IntValue)
	{
		CPrintToChat(client, "Gang name is too long"); // TODO: Translation
		return false;
	}
	
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		if (StrEqual(iGang[sGangName], sGang, false))
		{
			CPrintToChat(client, "Gang name already in use"); // TODO: Translation
			return false;
		}
	}
	
	if(StrEqual(g_sGang[g_iClientGang[client]], sGang, false))
	{
		CPrintToChat(client, "Gang name must be different"); // TODO: Translation
		return false;
	}
	
	if(g_iClientLevel[client] < g_cGangRenameRank.IntValue)
	{
		CPrintToChat(client, "You've not enough access to do this");
		return false;
	}
	
	if(!g_cGangPointsEnable.BoolValue && g_cGangRenameCost.IntValue > 0 && Gangs_GetPoints(g_iClientGang[client]) < g_cGangRenameCost.IntValue)
	{
		CPrintToChat(client, "Gang hasn't enough points for rename");
		return false;
	}
	return true;
}

stock void RenameGang(int client, int gangid, const char[] newgangname)
{
	if(!CheckGangRename(client, newgangname))
		return;

	char sQuery[512];
	Format(sQuery, sizeof(sQuery), "UPDATE `gangs` SET `GangName` = '%s' WHERE `GangID` = '%d'", newgangname, gangid); // Add new table -> logs
	
	Handle hDP = CreateDataPack();
	WritePackCell(hDP, GetClientUserId(client));
	WritePackCell(hDP, gangid);
	WritePackString(hDP, g_sGang[gangid]);
	WritePackString(hDP, newgangname);
	SQL_TQuery(g_hDatabase, SQL_RenameGang, sQuery, hDP);
}

public void SQL_RenameGang(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (error[0])
	{
		Gangs_LogFile(_, ERROR, "(SQL_RenameGang) Query failed: %s", error);
		CloseHandle(pack);
		return;
	}
		
	char oldgangname[64], newgangname[64];

	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	int gangid = ReadPackCell(pack);
	ReadPackString(pack, oldgangname, sizeof(oldgangname));
	ReadPackString(pack, newgangname, sizeof(newgangname));
	CloseHandle(pack);
	
	CPrintToChatAll("%N renamed %s to %s!", client, oldgangname, newgangname); // TODO: Translation
	Gangs_LogFile(_, INFO, "\"%L\" renamed %s to %s!", client, oldgangname, newgangname); // TODO: Translation
	
	Format(g_sGang[gangid], sizeof(g_sGang[]), "%s", newgangname);
	
	CloseRenameProcess(client);
	
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		if (iGang[iGangID] == gangid)
		{
			int itmpGang[Cache_Gang];
			
			itmpGang[iGangID] = iGang[iGangID];
			strcopy(itmpGang[sGangName], 64, newgangname);
			itmpGang[iPoints] = iGang[iPoints];
			itmpGang[bChat] = iGang[bChat];
			itmpGang[bPrefix] = iGang[bPrefix];
			strcopy(itmpGang[sPrefixColor], 64, iGang[sPrefixColor]);
			itmpGang[iMaxMembers] = iGang[iMaxMembers];
			itmpGang[iMembers] = iGang[iMembers];

			Gangs_LogFile(_, DEBUG, "(SQL_RenameGang) GangID: %d - OldGangName: %s - NewGangName: %s", gangid, oldgangname, newgangname);

			g_aCacheGang.Erase(i);
			g_aCacheGang.PushArray(itmpGang[0]);
			break;
		}
	}
	
	Call_StartForward(g_hGangRename);
	Call_PushCell(client);
	Call_PushCell(gangid);
	Call_PushString(oldgangname);
	Call_PushString(newgangname);
	Call_Finish();
}

stock void RenameGangMenu(int client)
{
	float fTime = g_cGangRenameTime.FloatValue;
	
	g_hRenameTimer[client] = CreateTimer(fTime, Timer_RenameEnd, GetClientUserId(client));
	g_bInRename[client] = true;
	
	CPrintToChat(client, "You have %.2f seconds to enter a new gang name!", fTime);
}

public Action Timer_RenameEnd(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	
	if (Gangs_IsClientValid(client) )
	{
		g_bInRename[client] = false;
		
		CPrintToChat(client, "Time to rename is over!");
	}
	
	g_hRenameTimer[client] = null;
	return Plugin_Stop;
}

stock void CloseRenameProcess(int client)
{
	if(g_hRenameTimer[client] != null)
		KillTimer(g_hRenameTimer[client]);
	
	g_hRenameTimer[client] = null;
	g_bInRename[client] = false;
}
