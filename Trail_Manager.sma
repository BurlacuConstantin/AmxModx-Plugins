#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>

#pragma tabsize 0

#define PLUGIN "Trail Manager"
#define VERSION "0.2"
#define AUTHOR "AsuStar"

#define INI_FILE "Trail_Manager.ini"

#define MAX_ITEMS_FOR_SECTION 	5
#define MAX_ITEMS_FOR_INFO 	2

#define TRAIL_UNIQUE_ID 1432

new Array:menu_item_name, Array:spr_location, Array:spr_life, Array:spr_size, Array:spr_brightness
new Array:spr_id
new items_num = 0


new dns[40], Float:task_time

enum _: ent_data
{
	bool:active_trail,
	trail_type,
	szRed,
	szGreen,
	szBlue
}

new user_data[33][ent_data]


public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_clcmd("say","say_handler")
	register_clcmd("say_team","say_handler")
	
	register_concmd("ColorTypeRGB", "GetColor")
	
	RegisterHam(Ham_Spawn, "player", "PlayerSpawn", 1)
}

public plugin_precache()
{
	menu_item_name	= ArrayCreate(64, 1)
	spr_location	= ArrayCreate(64, 1)
	spr_life	= ArrayCreate(64, 1)
	spr_size	= ArrayCreate(64, 1)
	spr_brightness	= ArrayCreate(64, 1)
	spr_id 		= ArrayCreate(64, 1)
	
	load_config_file()
	
	new temp_string[512]
	
	for(new i = 0; i < ArraySize(spr_location); i++)
	{
		ArrayGetString(spr_location, i, temp_string, sizeof(temp_string))
		precache_model(temp_string)
		ArrayPushCell(spr_id, precache_model(temp_string))
	}
}

public plugin_end()
{
	ArrayDestroy(menu_item_name)
	ArrayDestroy(spr_location)
	ArrayDestroy(spr_life)
	ArrayDestroy(spr_size)
	ArrayDestroy(spr_brightness)
}

public client_connect(id)
{
	user_data[id][active_trail] = false
}

public client_disconnect(id)
{
	user_data[id][active_trail] = false
}

public PlayerSpawn(id)
{
	if(!is_user_alive(id))
	return HAM_IGNORED
	
	remove_task(id+TRAIL_UNIQUE_ID)
	
	if(user_data[id][active_trail])
	{
		set_task(task_time, "create_beam", id + TRAIL_UNIQUE_ID, _, _, "b")
		return HAM_SUPERCEDE
	}
	
	return HAM_IGNORED
}

public create_beam(id)
{
	id -= TRAIL_UNIQUE_ID
	
	if(!is_user_alive(id) || user_data[id][active_trail] == false)
	{
		remove_task(id+TRAIL_UNIQUE_ID)
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_KILLBEAM)
		write_short(id)
		message_end()
	}
	else
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BEAMFOLLOW)	
		write_short(id)
		write_short(ArrayGetCell(spr_id, user_data[id][trail_type]))
		write_byte(ArrayGetCell(spr_life, user_data[id][trail_type]))
		write_byte(ArrayGetCell(spr_size, user_data[id][trail_type]))
		write_byte(user_data[id][szRed])
		write_byte(user_data[id][szGreen])
		write_byte(user_data[id][szBlue])
		write_byte(ArrayGetCell(spr_brightness, user_data[id][trail_type]))
		message_end()
	}

}

public say_handler(id)
{
	static args[192]
	read_args(args, charsmax(args))

	if(!args[0])
	return PLUGIN_CONTINUE
	
	remove_quotes(args[0])
	
	if(equal(args, "/trail", strlen("/trail")))
	{
		showTrail(id)
		return PLUGIN_CONTINUE
	}
	else if(equal(args, "stop trail", strlen("stop trail")) || equal(args, "/stop trail", strlen("/stop trail")))
	{
		user_data[id][active_trail] = false
		
		remove_task(id+TRAIL_UNIQUE_ID)
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_KILLBEAM)
		write_short(id)
		message_end()
		
		ColorChat(id, "!g[%s]!y Your trail has been deactivated !", PLUGIN)
		return PLUGIN_CONTINUE
	}
	
	return PLUGIN_CONTINUE
}

public showTrail(id)
{
	if(!is_user_connected(id))
		return
		
	new szform[128]
	formatex(szform, charsmax(szform), "\wChoose a trail type \d(\y%s\d)\w :", dns)
	new menu = menu_create(szform, "trail_handler")
	
	new szName[256], szcolor[256]
	new itemnum[3]
	
	
	for(new i = 1; i < items_num + 1; i++)
	{
		ArrayGetString(menu_item_name, i - 1, szName, charsmax(szName))
		
		formatex(szcolor, charsmax(szcolor), "\w%s\r", szName)
		
		num_to_str(i, itemnum, charsmax(itemnum))
		menu_additem(menu, szcolor, itemnum)
	}
	

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu, 0)
}

public trail_handler(id, menu, key)
{
	if(key == MENU_EXIT || !is_user_connected(id))
	{
		menu_destroy(menu)
   		remove_task(id)
		return PLUGIN_HANDLED
	}
	
	new Data[7], Name[64]
	new Access, Callback
	menu_item_getinfo(menu, key, Access, Data,5, Name, 63, Callback)
	
	new num = str_to_num(Data)
	
	client_cmd(id, "messagemode ColorTypeRGB")
	
	user_data[id][trail_type] = num - 1
	
	menu_destroy(menu)
	return PLUGIN_HANDLED
}

public GetColor(id)
{
	if(!is_user_connected(id))
	return PLUGIN_HANDLED
		
	new szDat[32], val[32], zRed[4], zGreen[4], zBlue[4]
	new iRed, iGreen, iBlue
	read_args(szDat, charsmax(szDat))
	remove_quotes(szDat)
	
	if(!(strlen(szDat) > 0))
	return PLUGIN_HANDLED


	if(strlen(szDat) < 5 || strlen(szDat) > 11)
	{
		ColorChat(id, "!g[%s]!y You need to type!t RGB!y color (ex !g255!y 000!t 255!y) !", PLUGIN)
		return PLUGIN_HANDLED
	}
	else
	{
		for(new i = 0; i < strlen(szDat); i++)
		{
			if(!isdigit(szDat[i]) && szDat[i] != ' ')
			{
				ColorChat(id, "!g[%s]!y You can only use numbers !", PLUGIN)
				return PLUGIN_HANDLED
			}
		}
		
		strtok(szDat, zRed, charsmax(zRed), val, charsmax(val), ' ')
		strtok(val, zGreen, charsmax(zGreen), szDat, charsmax(szDat), ' ')
		copy(zBlue, charsmax(zBlue), szDat)
		
		
		iRed = str_to_num(zRed)
		iGreen = str_to_num(zGreen)
		iBlue = str_to_num(zBlue)
		
		if(iRed == 0 && iGreen == 0 && iBlue == 0)
		{
			ColorChat(id, "!g[%s]!y You cannot have a black trail !", PLUGIN)
			return PLUGIN_HANDLED
		}
		else
		{
			if(iRed > 255) iRed = 255
			if(iGreen > 255) iGreen = 255
			if(iBlue > 255) iBlue = 255
			
			user_data[id][szRed] = iRed
			user_data[id][szGreen] = iGreen
			user_data[id][szBlue] = iBlue
			user_data[id][active_trail] = true
			ColorChat(id, "!g[%s]!y Your trail has beed set !t%d!y |!g %d!y |!t %d!y !", PLUGIN, iRed, iGreen, iBlue)
			
			if(!task_exists(id+TRAIL_UNIQUE_ID))
			{
				set_task(task_time, "create_beam", id + TRAIL_UNIQUE_ID, _, _, "b")
			}
			else
			{
				remove_task(id+TRAIL_UNIQUE_ID)
				message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
				write_byte(TE_KILLBEAM)
				write_short(id)
				message_end()
				
				set_task(task_time, "create_beam", id + TRAIL_UNIQUE_ID, _, _, "b")
			}
			
			
			return PLUGIN_HANDLED
		}
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
		formatex(error, sizeof(error) - 1, "[%s]:Error (0), could't find the file %s !",PLUGIN, INI_FILE)
		set_fail_state(error)
		return
	}
	
	new linedata[1024], key[128], value[960], txtNum, szFormat[200]
	// get file size in lines
	new szSize = file_size(path, 1)
	
	for(new i = 0; i < szSize; i++)
	{
		// read line
		read_file(path, i, linedata, charsmax(linedata), txtNum)
		
		// replace ^n with nothing
		replace(linedata, charsmax(linedata), "^n", "")
		
		// get rid of black line or comment line
		if(!linedata[0] || linedata[0] == ';' || (linedata[0] == '/' && linedata[1] == '/')) continue
		
		if(linedata[0] == '[' && linedata[1] != 'i' && linedata[2] != 'n' && linedata[3] != 'f')
		{
			items_num++
			
			for(new a = 1; a < MAX_ITEMS_FOR_SECTION + 1; a++)
			{
				read_file(path, i + a, linedata, charsmax(linedata), txtNum)
				
				// replace ^n with nothing
				replace(linedata, charsmax(linedata), "^n", "")
				
				// get rid of black line or comment line
				if(linedata[0] == ';' || (linedata[0] == '/' && linedata[1] == '/'))
				{
					formatex(szFormat, charsmax(szFormat), "[%s]:Error (1), the lines from file are incorect, line - %d !", PLUGIN, i+a)
					set_fail_state(szFormat)
					
				}
				
				// break the string in two 
				strtok(linedata, key, charsmax(key), value, charsmax(value), '=')
				
				// get rid of spaces
				trim(key)
				trim(value)
				// check for real value
				if(value[0] != 0)
				{
					if(equal(key, "ITEM_NAME"))
					{
						ArrayPushString(menu_item_name, value)
					}
					if(equal(key, "SPR_LOCATION"))
					{
						ArrayPushString(spr_location, value)
					}
					if(equal(key, "TRAIL_LIFE"))
					{
						ArrayPushCell(spr_life, str_to_num(value))
					}
					if(equal(key, "TRAIL_SIZE"))
					{
						ArrayPushCell(spr_size, str_to_num(value))
					}
					if(equal(key, "TRAIL_BRIGHTNESS"))
					{
						new a = str_to_num(value)
						
						if(a > 200)
						{
							a = 200
							ArrayPushCell(spr_brightness, a)
						}
						else
						{
							ArrayPushCell(spr_brightness, str_to_num(value))
						}
					}
				}
				else
				{
					formatex(szFormat, charsmax(szFormat), "[%s]:Error (2), null value on line - %d !", PLUGIN, i+a)
					set_fail_state(szFormat)
				}
			}
		}

		if(linedata[0] == '[' && linedata[1] == 'i' && linedata[2] == 'n' && linedata[3] == 'f')
		{
			for(new a = 1; a < MAX_ITEMS_FOR_INFO + 1; a++)
			{
				read_file(path, i + a, linedata, charsmax(linedata), txtNum)
				
				replace(linedata, charsmax(linedata), "^n", "")
				
				// get rid of black line or comment line
				if(linedata[0] == ';' || (linedata[0] == '/' && linedata[1] == '/'))
				{
					formatex(szFormat, charsmax(szFormat), "[%s]:Error (3), the lines from file are incorect, line - %d !", PLUGIN, i+a)
					set_fail_state(szFormat)
					
				}
			
				// break the string in two 
				strtok(linedata, key, charsmax(key), value, charsmax(value), '=')
				
				// get rid of spaces
				trim(key)
				trim(value)
			
				if(value[0] != 0)
				{
					if(equal(key, "SRV_DNS"))
					{
						formatex(dns, charsmax(dns), "%s", value)
					}
					if(equal(key, "TASK_TIME"))
					{
						task_time = str_to_float(value)
					}
				}
				else
				{
					formatex(szFormat, charsmax(szFormat), "[%s]:Error (4), null value on line - %d !", PLUGIN, i)
					set_fail_state(szFormat)
				}
			}
		}
		
	}
}

stock ColorChat(const id, const input[], any:...)
{
	new Count = 1, Players[32];
	static Msg[191];
	vformat(Msg, 190, input, 3);
	
	replace_all(Msg, 190, "!g", "^4");
	replace_all(Msg, 190, "!y", "^1");
	replace_all(Msg, 190, "!t", "^3");

	if(id) Players[0] = id; else get_players(Players, Count, "ch");
	{
		for (new i = 0; i < Count; i++)
		{
			if (is_user_connected(Players[i]))
			{
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, Players[i]);
				write_byte(Players[i]);
				write_string(Msg);
				message_end();
			}
		}
	}
	return PLUGIN_HANDLED
}
