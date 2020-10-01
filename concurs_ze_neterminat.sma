#include <amxmodx>
#include <settings_util>
#include <ColorChat>

#define PLUGIN "[ZE] Contest"
#define VERSION "0.1"
#define AUTHOR "AsuStar"

#define CONFIG_FILE "concurs.ini"

native get_user_infections(id)
native get_user_escapes(id)

new Array:key_code

new user_code[33], bool: has_code[33]

new loc1, loc2, loc3

public plugin_init()
{
	register_clcmd("say /concurs", "cmd_concurs")
	register_clcmd("say_team /concurs", "cmd_concurs")
	
	register_event("HLTV", "inceput_de_runda", "a", "1=0", "2=0")
	
}

public plugin_precache()
{
	key_code = ArrayCreate(64, 1)
	
	Setting_Load_StringArray(CONFIG_FILE, "SETTINGS", "KEY_CODE", key_code)
	
	loc1 = Setting_Load_Int(CONFIG_FILE, "SETTINGS", "NUMBER_1_PROPERTIES")
	loc2 = Setting_Load_Int(CONFIG_FILE, "SETTINGS", "NUMBER_2_PROPERTIES")
	loc3 = Setting_Load_Int(CONFIG_FILE, "SETTINGS", "NUMBER_3_PROPERTIES")
}

public plugin_end()
{
	ArrayDestroy(key_code)
}

public cmd_concurs(id)
{
	ColorChat(id, GREEN, "[ZE Concurs]^x01: Tasteaza^x03 /rank^x01 pentru a-ti vedea statisticile")
	ColorChat(id, GREEN, "[ZE Concurs]^x01: Pentru concurs, viziteaza www.wargods.ro sectiunea^x03 Ze.WarGods.Ro^x01!")
	
	return PLUGIN_CONTINUE
}

public inceput_de_runda()
{
	new iplayers[32], num, id, buff[128], buff2[128]
	get_players(iplayers, num, "ch")
	
	for(new i = 0; i < num; i++)
	{
		id = iplayers[i]
		
		if(get_user_escapes(id) >= loc1 && get_user_infections(id) >= loc1)
		{
			user_code[id] = ArrayGetString(key_code, Get_RandomArray(key_code), buff, sizeof(buff) - 1)
			has_code[id] = true
		}
		else if(get_user_escapes(id) >= loc2 &&
			
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
