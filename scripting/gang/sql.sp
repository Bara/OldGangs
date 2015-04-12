stock void Gang_SQLConnect()
{
	if (!SQL_CheckConfig("gang"))
	{
		LogToFile("gang", "core", ERROR, "(Gang_SQLConnect) Database failure: Couldn't find Database entry \"gang\"");
		return;
	}
	SQL_TConnect(Gang_Connected, "gang");
}

public void Gang_Connected(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		if (error[0])
		{
			LogToFile("gang", "core", ERROR, "(Gang_Connected) Connection to database failed!: %s", error);
			return;
		}
	}

	g_hDatabase = CloneHandle(hndl);

	// Gang_CreateTables();

	SQLQuery("SET NAMES \"UTF8\"");

	Call_StartForward(g_hSQLConnected);
	Call_PushCell(_:g_hDatabase);
	Call_Finish();
}

SQLQuery(char[] sQuery)
{
	Handle hPack = CreateDataPack();
	WritePackString(hPack, sQuery);
	SQL_TQuery(g_hDatabase, SQL_Callback, sQuery, hPack);
}

public SQL_Callback(Handle owner, Handle hndl, const char[] error, any data)
{
	if (error[0])
	{
		LogToFile("gang", "core", ERROR, "(SQL_Callback) Query failed: %s", error);
		return;
	}
}