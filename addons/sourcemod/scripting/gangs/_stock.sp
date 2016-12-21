stock void CreateGangsCache()
{
	if(g_aCacheGang != null)
		g_aCacheGang.Clear();
	
	if(g_aCacheGangMembers != null)
		g_aCacheGangMembers.Clear();
	
	if(g_aCacheGangSkills != null)
		g_aCacheGangSkills.Clear();
	
	if(g_aCacheSkills != null)
		g_aCacheSkills.Clear();
	
	g_aCacheGang =         new ArrayList(sizeof(g_iCacheGang));
	g_aCacheGangMembers =  new ArrayList(sizeof(g_iCacheGangMembers));
	g_aCacheGangSkills =   new ArrayList(sizeof(g_iCacheGangSkills));
	g_aCacheSkills =       new ArrayList(sizeof(g_iCacheSkills));
}

stock int GetOnlinePlayerCount(int gangid)
{
	int count = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (Gangs_IsClientValid(i) )
		{
			if(g_iClientGang[i] == gangid)
			{
				count++;
			}
		}
	}
	
	return count;
}

stock int AddGangPoints(int gangid, int points)
{
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		if (iGang[iGangID] == gangid)
		{
			int tmp_iPoints = iGang[iPoints] + points;
			g_aCacheGang.Set(i, tmp_iPoints, view_as<int>(iPoints));
			
			char sQuery[512];
			Format(sQuery, sizeof(sQuery), "UPDATE `gangs` SET `Points`= '%d' WHERE `GangID` = '%d'", tmp_iPoints, gangid);
			SQLQuery(sQuery);
			
			return tmp_iPoints;
		}
	}
	return 0;
}

stock int RemoveGangPoints(int gangid, int points)
{
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		if (iGang[iGangID] == gangid)
		{
			int tmp_iPoints = iGang[iPoints] - points;
			g_aCacheGang.Set(i, tmp_iPoints, view_as<int>(iPoints));
			
			char sQuery[512];
			Format(sQuery, sizeof(sQuery), "UPDATE `gangs` SET `Points` = '%d' WHERE `GangID` = '%d'", tmp_iPoints, gangid);
			SQLQuery(sQuery);
			
			return tmp_iPoints;
		}
	}
	return 0;
}

stock bool IsWeaponSecondary(const char[] sWeapon)
{
	if(	StrContains(sWeapon[7], "glock", false) || 
		StrContains(sWeapon[7], "p228", false) || 
		StrContains(sWeapon[7], "p250", false) || 
		StrContains(sWeapon[7], "cz75a", false) || 
		StrContains(sWeapon[7], "usp", false) || 
		StrContains(sWeapon[7], "usp_silencer", false) || 
		StrContains(sWeapon[7], "fiveseven", false) || 
		StrContains(sWeapon[7], "deagle", false) || 
		StrContains(sWeapon[7], "elite", false) || 
		StrContains(sWeapon[7], "tec9", false) || 
		StrContains(sWeapon[7], "hkp2000", false))
	{
		return true;
	}
	return false;
}

stock bool IsWeaponKnife(const char[] sWeapon)
{
	if(	StrContains(sWeapon[7], "knife", false) || 
		StrContains(sWeapon[7], "bayonet", false))
	{
		return true;
	}
	return false;
}

stock bool IsWeaponGrenade(const char[] sWeapon)
{
	if(	StrContains(sWeapon[7], "smokegrenade", false) || 
		StrContains(sWeapon[7], "hegrenade", false) || 
		StrContains(sWeapon[7], "flashbang", false) || 
		StrContains(sWeapon[7], "decoy", false))
	{
		return true;
	}
	return false;
}

stock void CheckName(int client, const char[] newname)
{
	char sQuery[512];
	Format(sQuery, sizeof(sQuery), "SELECT PlayerName FROM `gangs_members` WHERE `CommunityID` = '%s'", g_sClientID[client]);
	
	Handle hPack = CreateDataPack();
	WritePackCell(hPack, GetClientUserId(client));
	WritePackString(hPack, newname);
	SQL_TQuery(g_hDatabase, SQL_CheckName, sQuery, hPack);
}

stock void UpdateNameInCache(int client, const char[] newname)
{
	for (int i = 0; i < g_aCacheGangMembers.Length; i++)
	{
		int iGangMembers[Cache_Gangs_Members];
		g_aCacheGangMembers.GetArray(i, iGangMembers[0]);

		if(StrEqual(iGangMembers[sCommunityID], g_sClientID[client], true))
		{
			int itmpGang[Cache_Gangs_Members];
			
			itmpGang[iGangID] = iGangMembers[iGangID];
			strcopy(itmpGang[sCommunityID], 64, g_sClientID[client]);
			strcopy(itmpGang[sPlayerN], MAX_NAME_LENGTH, newname);
			itmpGang[iAccessLevel] = iGangMembers[iAccessLevel];
			itmpGang[bOnline] = true;

			Gangs_LogFile(_, DEBUG, "(UpdateNameInCache) GangID: %d - CommunityID: %s - PlayerName: %s - AccessLevel: %d", itmpGang[iGangID], itmpGang[sCommunityID], itmpGang[sPlayerN], itmpGang[iAccessLevel]);

			g_aCacheGangMembers.Erase(i);
			g_aCacheGangMembers.PushArray(itmpGang[0]);
			break;
		}
	}
}
