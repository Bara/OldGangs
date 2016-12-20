public int Native_IsClientInGang(Handle plugin, int numParams)
{
	return g_bIsInGang[GetNativeCell(1)];
}

public int Native_GetClientGang(Handle plugin, int numParams)
{
	return g_iClientGang[GetNativeCell(1)];
}

public int Native_GetGangName(Handle plugin, int numParams)
{
	char sName[64];
	strcopy(sName, sizeof(sName), g_sGang[GetNativeCell(1)]);
	SetNativeString(2, sName, GetNativeCell(3), false);
}

public int Native_GetClientAccessLevel(Handle plugin, int numParams)
{
	return g_iClientLevel[GetNativeCell(1)];
}

public int Native_GetGangMaxMembers(Handle plugin, int numParams)
{
	int gangid = GetNativeCell(1);
	
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		if (iGang[iGangID] == gangid)
		{
			return iGang[iMaxMembers];
		}
	}
	return 0;
}

public int Native_GetGangMembersCount(Handle plugin, int numParams)
{
	int gangid = GetNativeCell(1);
	
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		if (iGang[iGangID] == gangid)
		{
			return iGang[iMembers];
		}
	}
	return 0;
}

public int Native_GetOnlinePlayerCount(Handle plugin, int numParams)
{
	int gangid = GetNativeCell(1);
	
	return GetOnlinePlayerCount(gangid);
}

public int Native_GetGangPoints(Handle plugin, int numParams)
{
	int gangid = GetNativeCell(1);
	
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		if (iGang[iGangID] == gangid)
		{
			return iGang[iPoints];
		}
	}
	return 0;
}

public int Native_AddGangPoints(Handle plugin, int numParams)
{
	int gangid = GetNativeCell(1);
	int points = GetNativeCell(2);
	
	return AddGangPoints(gangid, points);
}

public int Native_RemoveGangPoints(Handle plugin, int numParams)
{
	int gangid = GetNativeCell(1);
	int points = GetNativeCell(2);
	
	return RemoveGangPoints(gangid, points);
}

public int Native_GetRangName(Handle plugin, int numParams)
{
	char sName[64];
	int rang = GetNativeCell(1);
	
	// TODO: Translations
	if(rang == GANGS_LEADER)
		Format(sName, sizeof(sName), "Leader");
	else if(rang == GANGS_COLEADER)
		Format(sName, sizeof(sName), "CoLeader");
	else if(rang == GANGS_SKILLER)
		Format(sName, sizeof(sName), "Skiller");
	else if(rang == GANGS_INVITER)
		Format(sName, sizeof(sName), "Inviter");
	else if(rang == GANGS_MEMBER)
		Format(sName, sizeof(sName), "Member");
	else if(rang == GANGS_TRIAL)
		Format(sName, sizeof(sName), "Trial");

	SetNativeString(2, sName, GetNativeCell(3), false);
}