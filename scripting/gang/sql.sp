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
	Call_PushCell(_:g_hDatabase);
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
	Format(sQuery, sizeof(sQuery), "SELECT GangID FROM gang WHERE GangName ='%s'", sGang);
	
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
		ReplyToCommand(client, "Die Gang konnte nicht gegründet werden...");
		return;
	}
	
	char sGang[64];
	Gang_GetGangName(g_iClientGang[client], sGang, sizeof(sGang));
	
	PrintToChatAll("%N hat die Gang \"%s\" gegründet!", client, sGang);
	
	Log_File(_, _, INFO, "\"%N\" hat die Gang \"%s\" gegründet!", client, sGang);
	
	Gang_PushClientArray(client);
	
	Call_StartForward(g_hGangCreated);
	Call_PushCell(client);
	Call_PushCell(g_iClientGang[client]);
	Call_Finish();
}
