 #include <amxmodx>
 #include <amxmisc>
 
 #pragma tabsize 0
 
#define PLUGIN "Win Manager"
#define VERSION "1.0"
#define AUTHOR "AsuStar"
 
#define CSW_KNIFE	29
#define CSW_SHIELD	2
#define DEFAULT_FOV	90
 
#define INI_FILE "Win_Manager.ini"
 
 new Array:t_win_sound, Array:ct_win_sound
 new Array:win_sprite, Array:win_sprite_txt
 
 new cmd_buffer[256]
 
 new bool:can_show, win_state
 
 enum _:ROUND_STATS 
 {
 	WIN_T = 1,
	WIN_CT,
	WIN_NONE
}

new g_block_win_msg, g_block_win_sound, Float:task_time
 
 public plugin_precache()
 {
 	t_win_sound = ArrayCreate(64, 1)
	ct_win_sound = ArrayCreate(64, 1)
	win_sprite = ArrayCreate(64, 1)
	win_sprite_txt = ArrayCreate(64, 1)
	
	load_config_file()
	
	new i, buffer[128], temp_string[256]
	
	precache_generic("sprites/640hud11.spr")
	precache_generic("sprites/640hud10.spr")
	precache_generic("sprites/640hud7.spr")
	
	for(i = 0; i < ArraySize(win_sprite); i++)
	{
		ArrayGetString(win_sprite, i, temp_string, sizeof(temp_string))
		formatex(buffer, charsmax(buffer), "sprites/%s", temp_string)
		precache_generic(buffer)
	}
	
	for(i = 0; i < ArraySize(win_sprite_txt); i++)
	{
		ArrayGetString(win_sprite_txt, i, temp_string, sizeof(temp_string))
		copy(cmd_buffer, charsmax(cmd_buffer), temp_string)
		replace(cmd_buffer, charsmax(cmd_buffer), ".txt", "")
		
		formatex(buffer, charsmax(buffer), "sprites/%s", temp_string)
		precache_generic(buffer)
	}
	
	if(g_block_win_sound == 1)
	{
		for(i = 0; i < ArraySize(t_win_sound); i++)
		{
			ArrayGetString(t_win_sound, i, temp_string, sizeof(temp_string))
	
			if(equal(temp_string[strlen(temp_string) - 4], ".mp3"))
			{
				format(buffer, charsmax(buffer), "sound/%s", temp_string)
				precache_generic(buffer)
			} 
			else 
			{
				precache_sound(temp_string)
			}
		}
	
		for(i = 0; i < ArraySize(ct_win_sound); i++)
		{
			ArrayGetString(ct_win_sound, i, temp_string, sizeof(temp_string))
	
			if(equal(temp_string[strlen(temp_string) - 4], ".mp3"))
			{
				format(buffer, charsmax(buffer), "sound/%s", temp_string)
				precache_generic(buffer)
			} 
			else 
			{
				precache_sound(temp_string)
			}
		}
	}
}

 
 public plugin_init()
 {
 	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_clcmd(cmd_buffer, "FakeSwitch")
	
	register_message(get_user_msgid("TextMsg"), "message_SendText")
	register_event("HLTV", "event_new_round", "a", "1=0", "2=0")
	
	register_event("SendAudio", "Event_CTWin","a","2=%!MRAD_ctwin")
	register_event("SendAudio", "Event_TerroristWin","a","2=%!MRAD_terwin")
	
	register_message(get_user_msgid("WeaponList"), "need_to_block")
	register_message(get_user_msgid("CurWeapon"), "need_to_block")
	register_message(get_user_msgid("ForceCam"), "need_to_block")
	register_message(get_user_msgid("SetFOV"), "need_to_block")
	register_message(get_user_msgid("HideWeapon"), "need_to_block")
}

public event_new_round()
{
	win_state = WIN_NONE
	
	if(can_show)
	{
		can_show = false
		
		Msg_HideWeapon(0)
	
		Msg_WeaponList("weapon_knife", -1, -1, -1, -1, 2, 1, CSW_KNIFE, 0)
		Msg_CurWeapon(0, 0, 0)
	}
}
	
public FakeSwitch(id)
{
	engclient_cmd(id, "weapon_shield")
}

public Event_CTWin()
{
	win_state = WIN_CT
	ShowSprite()
	
	if(g_block_win_sound == 1)
	{
		static temp_string[128]
		ArrayGetString(ct_win_sound, random_num(0, ArraySize(ct_win_sound) - 1), temp_string, sizeof(temp_string))
		return PLUGIN_HANDLED
	}
	else return PLUGIN_CONTINUE
	
	return PLUGIN_CONTINUE
	
	
}

public Event_TerroristWin()
{
	win_state = WIN_T
	ShowSprite()
	
	if(g_block_win_sound == 1)
	{
		static temp_string[128]
		ArrayGetString(t_win_sound, random_num(0, ArraySize(t_win_sound) - 1), temp_string, sizeof(temp_string))
		return PLUGIN_HANDLED
	}
	else return PLUGIN_CONTINUE
	
	return PLUGIN_CONTINUE
}

public need_to_block()
{
	if(can_show)
	return PLUGIN_HANDLED
	
	return PLUGIN_CONTINUE
}

public ShowSprite()
{
	can_show = true
	set_task(task_time, "sendWeapon")
}

public sendWeapon()
{
	if(!can_show) 
	return PLUGIN_HANDLED
	
	switch(win_state)
	{
		case WIN_CT:
		{
			Msg_WeaponList(cmd_buffer, -1, -1, -1, -1, 0, 11, CSW_SHIELD, 0)
		}
		case WIN_T:
		{
			Msg_WeaponList(cmd_buffer, -1, -1, -1, -1, 0, 11, CSW_SHIELD, 0)
		}
	}
	
	Msg_HideWeapon(64) // hide crosshair
	Msg_SetFOV(DEFAULT_FOV - 1)
	
	can_show = false;
	
	switch(win_state)
	{
		case WIN_CT: Msg_CurWeapon(1, 2, -1)
		case WIN_T:  Msg_CurWeapon(64, 2, -1)
	}
	
	can_show = true
	
	Msg_SetFOV(DEFAULT_FOV)
	
	return PLUGIN_HANDLED
}

public message_SendText(msgid, dest, id)
{
	if(g_block_win_msg != 1)
	return PLUGIN_CONTINUE
	
	if(!id  && (get_msg_arg_int(1) == print_center || get_msg_arg_int(1) == print_notify)) 
	{
		new szMessage[32]
		get_msg_arg_string(2, szMessage, charsmax(szMessage))
		
		if(equal(szMessage, "#CTs_Win") || equal(szMessage, "#Terrorists_Win") || equal(szMessage, "#Bomb_Planted") | equal(szMessage, "#Bomb_Defused") || equal(szMessage, "#Target_Bombed"))
		{			
			return PLUGIN_HANDLED
		}
		
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}

public load_config_file()
{
	new path[64]
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, INI_FILE)
	
	// File not present
	if(!file_exists(path))
	{
		new error[100]
		formatex(error, sizeof(error) - 1, "[%s]:Fisierul %s nu a fost detectat!",PLUGIN, INI_FILE)
		set_fail_state(error)
		return
	}
	
		// Set up some vars to hold parsing info
	new linedata[1024], key[64], value[960], section
	
	// Open customization file for reading
	new file = fopen(path, "rt")
	
	while (file && !feof(file))
	{
		// Read one line at a time
		fgets(file, linedata, charsmax(linedata))
		
		// Replace newlines with a null character to prevent headaches
		replace(linedata, charsmax(linedata), "^n", "")
		
		// Blank line or comment
		if (!linedata[0] || linedata[0] == ';') continue;
		
		// New section starting
		if (linedata[0] == '[')
		{
			section++
			continue;
		}
	
		// Get key and value(s)
		strtok(linedata, key, charsmax(key), value, charsmax(value), '=')

		// Trim spaces
		trim(key)
		trim(value)

		switch (section)
		{
			case 1:
			{
				if(equal(key, "REPLACE_WIN_SOUND"))
				{
					g_block_win_sound = str_to_num(value)
				}
				if(equal(key, "BLOCK_WIN_MSG"))
				{
					g_block_win_msg = str_to_num(value)
				}
				if(equal(key, "SHOW_DELAY"))
				{
					task_time = str_to_float(value)
				}
			}
			case 2:
			{
				if(equal(key, "T_WIN_SOUND"))
				{
					// Parse sounds
					while(value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(t_win_sound, key)
					}
				}
				if(equal(key, "CT_WIN_SOUND"))
				{
					// Parse sounds
					while(value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(ct_win_sound, key)
					}
				}
				if(equal(key, "WIN_SPRITE"))
				{
					ArrayPushString(win_sprite, value)
				}
				if(equal(key, "WIN_SPRITE_TXT"))
				{
					ArrayPushString(win_sprite_txt, value)
				}
			}
		}
	}
	if(file) fclose(file)
}

stock Msg_WeaponList(const WeaponName[],PrimaryAmmoID,PrimaryAmmoMaxAmount,SecondaryAmmoID,SecondaryAmmoMaxAmount,SlotID,NumberInSlot,WeaponID,Flags)
{
	message_begin(MSG_ALL, get_user_msgid("WeaponList"), .player = 0);
	{
		write_string(WeaponName);
		write_byte(PrimaryAmmoID);
		write_byte(PrimaryAmmoMaxAmount);
		write_byte(SecondaryAmmoID);
		write_byte(SecondaryAmmoMaxAmount);
		write_byte(SlotID);
		write_byte(NumberInSlot);
		write_byte(WeaponID);
		write_byte(Flags);
	}
	message_end();
}

stock Msg_CurWeapon(IsActive,WeaponID,ClipAmmo)
{		
	message_begin(MSG_ALL, get_user_msgid("CurWeapon"), .player = 0);
	{
		write_byte(IsActive);
		write_byte(WeaponID);
		write_byte(ClipAmmo);
	}
	message_end();
}

stock Msg_SetFOV(Degrees)
{
	message_begin(MSG_ALL, get_user_msgid("SetFOV"), .player = 0);
	{
		write_byte(Degrees);
	}
	message_end();
}

stock Msg_HideWeapon(Flags)
{
	message_begin(MSG_ALL, get_user_msgid("HideWeapon"), .player = 0);
	{
		write_byte(Flags);
	}
	message_end();
}

stock PlaySound(const sound[])
{
	if(equal(sound[strlen(sound)-4], ".mp3"))
	{
		client_cmd(0, "mp3 play ^"sound/%s^"", sound)
	}
	else
	{
		client_cmd(0, "spk ^"%s^"", sound)
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1048\\ f0\\ fs16 \n\\ par }
*/
