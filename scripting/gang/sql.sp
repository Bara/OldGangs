public void Gang_Connected(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		if (error[0])
		{
			Log_File(_, _, ERROR, "(Gang_Connected) Connection to database failed!: %s", error);
			return;
		}
	}

	g_hDatabase = CloneHandle(hndl);

	Gang_CreateTables();

	SQL_SetCharset(g_hDatabase, "utf8");
	
	Gang_FillCache();

	Call_StartForward(g_hSQLConnected);
	Call_PushCell(view_as<Handle>(g_hDatabase));
	Call_Finish();
}

void SQLQuery(char[] sQuery)
{
	Handle hPack = CreateDataPack();
	WritePackString(hPack, sQuery);
	SQL_TQuery(g_hDatabase, SQL_Callback, sQuery, hPack);
}

public void SQL_Callback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (error[0])
	{
		Log_File("gang", "core", ERROR, "(SQL_Callback) Query failed: %s", error);
		return;
	}
}

public void SQL_CreateGang(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (error[0])
	{
		Log_File("gang", "core", ERROR, "(SQL_CreateGang) Query failed: %s", error);
		CloseHandle(pack);
		return;
	}
		
	char sGang[64];

	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	ReadPackString(pack, sGang, sizeof(sGang));
	CloseHandle(pack);

	char sQuery[512];
	Format(sQuery, sizeof(sQuery), "SELECT GangID FROM `gang` WHERE `GangName` ='%s'", sGang);
	
	Handle hPack = CreateDataPack();
	WritePackCell(hPack, GetClientUserId(client));
	WritePackString(hPack, sGang);
	SQL_TQuery(g_hDatabase, SQL_SaveClientGangID, sQuery, hPack, DBPrio_Low);
}

public void SQL_SaveClientGangID(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (error[0])
	{
		Log_File("gang", "core", ERROR, "(SQL_SaveClientGangID) Query failed: %s", error);
		return;
	}
	
	char sGang[64];

	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	ReadPackString(pack, sGang, sizeof(sGang));
	CloseHandle(pack);

	if(!IsClientInGame(client))
		return;
	
	if (hndl != null)
	{
		while(SQL_FetchRow(hndl))
		{
			if(SQL_FetchInt(hndl, 0) > 0)
			{
				AddGangToArray(SQL_FetchInt(hndl, 0), sGang);
				Log_File(_, _, INFO, "Gang \"%s\" wurde erstellt!", client, sGang); // TODO: Translation
				g_iClientGang[client] = SQL_FetchInt(hndl, 0);
				AddClientToGang(client, g_iClientGang[client]);
			}
			else
			{
				g_bIsInGang[client] = false;
				g_iClientGang[client] = 0;
			}
		}
	}
}

public void SQL_UpdateGangMembers(Handle owner, Handle hndl, const char[] error, any userid)
{
	if (error[0])
	{
		Log_File("gang", "core", ERROR, "(SQL_Callback) Query failed: %s", error);
		return;
	}
	
	int client = GetClientOfUserId(userid);
	
	if(!IsClientInGame(client))
		return;
		
	g_bIsInGang[client] = true;
	
	if(g_iClientGang[client] < 1 && !g_bIsInGang[client])
	{
		ReplyToCommand(client, "Die Gang konnte nicht gegründet werden..."); // TODO: Translation
		return;
	}
	
	char sGang[64];
	Gang_GetGangName(g_iClientGang[client], sGang, sizeof(sGang));
	
	PrintToChatAll("%N hat die Gang \"%s\" gegründet!", client, sGang); // TODO: Translation
	
	Log_File(_, _, INFO, "\"%N\" hat die Gang \"%s\" gegründet!", client, sGang); // TODO: Translation
	
	Gang_PushClientArray(client);
	
	Call_StartForward(g_hGangCreated);
	Call_PushCell(client);
	Call_PushCell(g_iClientGang[client]);
	Call_Finish();
}

public void SQL_GetGangMemberCount(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl != null)
	{
		if (error[0])
		{
			Log_File("gang", "core", ERROR, "(TQuery_Gang) Query failed: %s", error);
			return;
		}
		
		int count = 0;
		int gangid = data;
		
		while(SQL_FetchRow(hndl))
		{
			if(SQL_FetchInt(hndl, 0) == gangid)
				count++;
		}

		for (int i = 0; i < g_aCacheGang.Length; i++)
		{
			int iGang[Cache_Gang];
			g_aCacheGang.GetArray(i, iGang[0]);
	
			if (iGang[iGangID] == gangid)
			{
				g_aCacheGang.Set(i, count, view_as<int>(iMembers));

				Log_File(_, _, DEBUG, "(SQL_GetGangMemberCount) GangID: %d - Members: %d", iGang[iGangID], count);
				break;
			}
		}
	}
}

public void SQL_RenameGang(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (error[0])
	{
		Log_File("gang", "core", ERROR, "(SQL_RenameGang) Query failed: %s", error);
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
	
	PrintToChatAll("%N hat die Gang (%s) in %s umbenannt!", client, oldgangname, newgangname); // TODO: Translation
	
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

			Log_File(_, _, DEBUG, "(SQL_RenameGang) GangID: %d - OldGangName: %s - NewGangName: %s", gangid, oldgangname, newgangname);

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

public void SQL_CheckName(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (error[0])
	{
		Log_File("gang", "core", ERROR, "(SQL_CheckName) Query failed: %s", error);
		CloseHandle(pack);
		return;
	}
		
	char newname[64];

	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	ReadPackString(pack, newname, sizeof(newname));
	CloseHandle(pack);
	
	if(client < 1 || !IsClientInGame(client))
		return;
	
	if (hndl != null)
	{
		while(SQL_FetchRow(hndl))
		{
			char sSName[MAX_NAME_LENGTH];
			SQL_FetchString(hndl, 0, sSName, sizeof(sSName));
			
			if(!StrEqual(newname, sSName, true))
			{
				UpdateNameInCache(client, newname);
				
				char sQuery[512], sEName[MAX_NAME_LENGTH];
				SQL_EscapeString(g_hDatabase, newname, sEName, sizeof(sEName));
				Format(sQuery, sizeof(sQuery), "UPDATE `gang_members` SET `PlayerName` = '%s' WHERE `CommunityID` = '%d'", sEName, g_sClientID[client]);
				SQLQuery(sQuery);
			}
		}
	}
}
