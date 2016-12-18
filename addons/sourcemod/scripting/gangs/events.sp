public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("attacker"));
	int victim = GetClientOfUserId(event.GetInt("userid"));
	bool headshot = event.GetBool("headshot");
	char sWeapon[64];
	event.GetString("weapon", sWeapon, sizeof(sWeapon));
	
	if(g_cGangPointsEnable.BoolValue && IsClientInGame(client) && IsClientInGame(victim) && !IsFakeClient(client) && Gangs_IsClientInGang(client))
	{
		if((IsFakeClient(victim) && g_cGangPointsBots.BoolValue))
		{
			if(GetClientTeam(client) != GetClientTeam(victim))
			{
				int points = 0;
				
				if(headshot)
					points += g_cGangPointsHeadshot.IntValue;
				
				if(IsWeaponSecondary(sWeapon))
					points += g_cGangPointsPistol.IntValue;
				else if(IsWeaponKnife(sWeapon))
					points += g_cGangPointsKnife.IntValue;
				else if(IsWeaponGrenade(sWeapon))
					points += g_cGangPointsGrenade.IntValue;
				else
					points += g_cGangPointsKill.IntValue;
				
				Gangs_AddPoints(g_iClientGang[client] points);
				
				if(GetEngineVersion() == Engine_CSGO)
				{
					int assister = GetClientOfUserId(event.GetInt("assister"));
					
					if(IsClientInGame(assister) && !IsFakeClient(assister) && (GetClientTeam(assister) != GetClientTeam(victim)))
					{
						int apoints = 0;
					
						if(headshot)
							apoints += g_cGangPointsHeadshot.IntValue;
						
						apoints += g_cGangPointsAssists.IntValue;
						
						Gangs_AddPoints(g_iClientGang[assister], apoints);
					}
				}
			}
		}
	}
}

public Action Event_BombPlanted(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if(g_cGangPointsEnable.BoolValue && IsClientInGame(client))
	{
		Gangs_AddPoints(g_iClientGang[client], g_cGangPointsBombPlanted.IntValue);
	}
}

public Action Event_BombExploded(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if(g_cGangPointsEnable.BoolValue && IsClientInGame(client))
	{
		Gangs_AddPoints(g_iClientGang[client], g_cGangPointsBombExploded.IntValue);
	}
}

public Action Event_BombDefused(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if(g_cGangPointsEnable.BoolValue && IsClientInGame(client))
	{
		Gangs_AddPoints(g_iClientGang[client], g_cGangPointsBombDefused.IntValue);
	}
}

public Action Event_HostageFollow(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if(g_cGangPointsEnable.BoolValue && IsClientInGame(client))
	{
		Gangs_AddPoints(g_iClientGang[client], g_cGangPointsHostageFollow.IntValue);
	}
}

public Action Event_HostageRescued(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if(g_cGangPointsEnable.BoolValue && IsClientInGame(client))
	{
		Gangs_AddPoints(g_iClientGang[client], g_cGangPointsHostageRescue.IntValue);
	}
}

public Action Event_VipEscape(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if(g_cGangPointsEnable.BoolValue && IsClientInGame(client))
	{
		Gangs_AddPoints(g_iClientGang[client], g_cGangPointsVipEscape.IntValue);
	}
}

public Action Event_VipKilled(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if(g_cGangPointsEnable.BoolValue && IsClientInGame(client))
	{
		Gangs_AddPoints(g_iClientGang[client], g_cGangPointsVipKilled.IntValue);
	}
}

public Action Event_ChangeName(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	char newname[MAX_NAME_LENGTH];
	
	event.GetString("newname", newname, sizeof(newname));
	CheckName(client, newname);
}
