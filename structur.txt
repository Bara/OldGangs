Database:
        skills                      - SkillID, Name, MaxLevel
        gangs                       - GangID, Name, Chat, Prefix, PrefixColor, MaxMembers, 
        gangs_members               - GangID, CommunityID, AccessLevel
        gangs_skills                - GangID, SkillID, Level
        

Commands:
        sm_gang                      - Create gang
        sm_deletegang                - Delete a gang (only for founder)
        sm_leftgang                  - Left gang (for all except founder)
        sm_g                         - Gang Chat
        sm_listgangs                 - List of all gangs
        sm_gangadmin                 - Admin command to edit all gangs
        sm_renamegang                - Rename a gang
        sm_creategang                - Create a gang


Configs:
        gang_enable                  - Enable the whole gang system?
        gang_debug                   - Log all actions/events/...?

        gang_admin_flag	             - To access the command "sm_gangadmin"
        
        gang_points_system           - Enable the point system?
        gang_points_players          - How players needed to get gang points?
        gang_points_gang_players     - How gang players needed to get gang points?
        gang_points_kill             - How much points per kill?
        gang_points_headshot         - How much extra points per headshot?
        gang_points_pistol_kill      - How much extra points per pistol kill?
        gang_points_pistol_headshot  - How much extra points per pistol headshot?
        gang_points_knife            - How much extra points per knife?
        gang_points_assists          - How much points for a assists kill?
        gang_points_assists_headshot - How much extra points for a assists headshot?
        gang_points_bomb_plant       - How much points per bomb plant?
        gang_points_bomb_defuse      - How much points per bomb defuse?
        gang_points_bomb_explode     - How much points per bomb explode?
        gang_points_hostage_follow   - How much points per followed hostage?
        gang_points_hostage_rescue   - How much points per rescued hostage?
        
        gang_create_gang             - Enable registration system?
        gang_create_price            - How much credits cost a gang?
        gang_create_name_min         - Minimum length of gang name
        gang_create_name_max         - Maximum length of gang name
        gang_create_regex            - Allowed characters

        gang_rename_gang             - Enable rename system?
        gang_rename_price            - How much credits cost a gang rename?

        gang_chat_gang               - Enable gang chat system?
        gang_chat_price              - How much credits cost a gang chat?
        
        gang_member_start            - How much members can join the after create?
        gang_member_max              - How much members can join max. the gang?
        gang_member_upgrade          - How much members can join after upgrade (base + X)?
        gang_member_upgrade_price    - How much costs a member upgrade?
        
        gang_prefix_gang             - Enable prefix system?
        gang_prefix_price            - How much costs prefix?
        gang_prefix_global           - Insert a gang prefix before a name?
        gang_prefix_colors           - Default colors after buying prefix

Gang rangs:
        Leader                       - Access to all
        CoLeader                     - Access to all (but can't kick leader and admins)
        Skiller                      - Gang Chat, Upgrade skills
        Inviter                      - Gang Chat, Inviter players
        Member                       - Gang Chat
        Trial                        - Gang Chat


Gang Menu:
	|-------------------|
	| Name              |
	|-------------------|
	| Points: 14151     |
	|-------------------|
	| Online: 2  	    |
	|-------------------|
	| Skills            |
	| Members           |
	| (L)Gang Settings  |
	|-------------------|
	| Left Gang         |
	|-------------------|
	| Close             |
	|-------------------|

	
	
		Gang Menu - Skills
			|-------------------|
			|(Lvl/Max.)Skill 1  |
			|(Lvl/Max.)Skill 2  |
			|(Lvl/Max.)Skill 3  |
			| ...               |
			|-------------------|
			| Back              |
			| Close             |
			|-------------------|
				
				Gang Menu - Skills - (L)(S)Manage - (Lvl/Max.)Skill 1/2/3.
					|-------------------|
					| Upgrade           |
					| Downgrade 	    |
					|-------------------|
					| Back              |
					| Close             |
					|-------------------|
					
					
					
		Gang Menu - Members:
			|-------------------|
			| Members: 2/4/Max  |
			|-------------------|
			| (Lvl/Max)Member 1 |
			| (Lvl/Max)Member 2 |
			| (Lvl/Max)Member 3 |
			| ...               |
			|-------------------|
			| Back              |
			| Close             |
			|-------------------| 
				
				Gang Menu - Members - (L)Manage - (Lvl/Max)Member 1/2/3...
					|-------------------|
					| Upgrade           |
					| Degrade           |
					| Kick              |
					|-------------------|
					| Back              |
					| Close             |
					|-------------------|
					
					
					
		Gang Menu - Gang Settings	
			|-------------------|
			| Rename Gang       |
			| Delete Gang       |
			| Mute Member       |
			| Prefix Color      |
			|-------------------|
			| Buy Gang Chat     |
			| Buy Prefix        |
			|-------------------|
			| Back              |
			| Close             |
			|-------------------|
				
				Gang Menu - Gang Settings - Gang Chat - Mute
					|-------------------|
					| (Lvl/Max)Member 1 |
					| (Lvl/Max)Member 2 |
					| (Lvl/Max)Member 3 |
					| ...               |
					|-------------------|
					| Back              |
					| Close             |
					|-------------------|
				
				
				Gang Menu - Gang Settings - Buy Prefix
					|-------------------|
					| Red               |
					| Blue              |
					| Pink              |
					| ...               |
					|-------------------|
					| Back              |
					| Close             |
					|-------------------|
					
					
						
		Gang Menu - Left Gang
			|-------------------|
			| Really ?!         |	
			|-------------------|
			| Yes !             |
			| No, sry !         |
			|-------------------|