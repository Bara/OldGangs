public Native_IsClientInGang(Handle plugin, int numParams)
{
	return g_bIsInGang[GetNativeCell(1)];
}

public Native_GetClientGang(Handle plugin, int numParams)
{
	return g_iClientGang[GetNativeCell(1)];
}

public Native_GetGangName(Handle plugin, int numParams)
{
	char sName[64];
	int gangid = GetNativeCell(1);
	
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		if (iGang[iGangID] == gangid)
		{
			strcopy(sName, sizeof(sName), iGang[sGangName]);
			break;
		}
	}

	SetNativeString(2, sName, GetNativeCell(3), false);
}

public Native_GetClientAccessLevel(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	char sBuffer[64];
	GetClientAuthId(client, AuthId_SteamID64, sBuffer, sizeof(sBuffer));
	
	for (int i = 0; i < g_aCacheGangMembers.Length; i++)
	{
		int iGangMembers[Cache_Gang_Members];
		g_aCacheGangMembers.GetArray(i, iGangMembers[0]);
		
		if(StrEqual(sBuffer, iGangMembers[sCommunityID], false))
		{
			return iGangMembers[iAccessLevel];
		}
		break;
	}
	return -1;
}

public Native_DeleteClientGang(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	RemoveClientFromGang(client, Gang_GetClientGang(client));
	
	g_bIsInGang[client] = false;
	g_iClientGang[client] = 0;
}

public Native_CreateClientGang(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if(client < 1 || !IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_ABORTED, "Client %d is invalid!");
		return;
	}
	
	char sGang[64];
	GetNativeString(2, sGang, sizeof(sGang));
	
	if(!CheckGangName(client, sGang))
	{
		PrintToChat(client, "Die Gang (%s) konnte nicht erstellt werden!");
		return;
	}
	
	CreateGang(client, sGang);
}
	