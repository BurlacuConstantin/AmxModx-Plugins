#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <cstrike>

#define PLUGIN "CS:GO Model Changer"
#define VERSION "0.6"
#define AUTHOR "AsuStar"

#define CONFIG_FILE "CSGO_PlayerModels.ini"

#pragma tabsize 0


new Array:Player_Model,Array:Player_Modelindex,Array:Player_Model2,Array:Player_Modelindex2
new bool:player_model_locked[33]

//========================================================================================================

public plugin_init()
{
	register_plugin(PLUGIN,VERSION,AUTHOR)
	
	register_forward(FM_SetClientKeyValue, "fw_SetClientKeyValue")
	register_event("HLTV", "event_new_round", "a", "1=0", "2=0") 	
}
//========================================================================================================



//========================================================================================================

public plugin_end()
{
	ArrayDestroy(Player_Model)
	ArrayDestroy(Player_Modelindex)
	ArrayDestroy(Player_Model2)
	ArrayDestroy(Player_Modelindex2)
}

public plugin_precache()
{
	Player_Model = ArrayCreate(64, 1)
	Player_Model2 = ArrayCreate(64, 1)
	
	Player_Modelindex = ArrayCreate(1, 1)
	Player_Modelindex2 = ArrayCreate(1, 1)
	
	load_config_file()
	
	//server_print("models : %d %d", ArraySize(Player_Model), ArraySize(Player_Model2))
	
	new i, buffer[128], temp_string[256]
	
	
	for(i = 0; i < ArraySize(Player_Model); i++)
	{
		ArrayGetString(Player_Model, i, temp_string, sizeof(temp_string))
		formatex(buffer, sizeof(buffer), "models/player/%s/%s.mdl", temp_string, temp_string)
		
		ArrayPushCell(Player_Modelindex, precache_model(buffer))

		formatex(buffer, sizeof(buffer), "models/player/%s/%sT.mdl", temp_string, temp_string);
		
		if(file_exists(buffer))
		ArrayPushCell(Player_Modelindex, precache_model(buffer))
	}
	
	for(i = 0; i < ArraySize(Player_Model2); i++)
	{
		ArrayGetString(Player_Model2, i, temp_string, sizeof(temp_string))
		formatex(buffer, sizeof(buffer), "models/player/%s/%s.mdl", temp_string, temp_string)
		
		ArrayPushCell(Player_Modelindex2, precache_model(buffer))

		formatex(buffer, sizeof(buffer), "models/player/%s/%sT.mdl", temp_string, temp_string);
		
		if(file_exists(buffer))
		ArrayPushCell(Player_Modelindex2, precache_model(buffer))
	}
	
}
//========================================================================================================


//========================================================================================================
public load_config_file()
{
	new path[64]
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/csgo/%s", path, CONFIG_FILE)
	
	// File not present
	if(!file_exists(path))
	{
		new error[100]
		formatex(error, sizeof(error) - 1, "[CS:GO Model Changer]:Fisierul CSGO_ModelsPlayers.ini nu a fost detectat!")
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
				if(equal(key, "CT_MODELS"))
				{
					// Parse sounds
					while(value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(Player_Model, key)
					}
				}
				if(equal(key, "TERO_MODELS"))
				{
					// Parse sounds
					while(value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(Player_Model2, key)
					}
				}
			}
		}
	}
	if(file) fclose(file)
}
//========================================================================================================

//========================================================================================================

public fw_SetClientKeyValue(id, const infobuffer[], const key[])
{
	if(player_model_locked[id] && equal(key, "model"))
	return FMRES_SUPERCEDE
	
	return FMRES_HANDLED
}

public client_PostThink(id)
{
	if(is_user_connected(id) && is_user_alive(id) && !player_model_locked[id])
	{
		set_user_model(id)
	}
}

public client_disconnect(id)
{
	player_model_locked[id] = false;
}


public event_new_round()
{
	new Players[32],iNum
	get_players(Players,iNum, "a")
	
	for(new i = 0;i < iNum;i++)
	{
		new id = Players[i]
		player_model_locked[id] = false
		
	}
}

//========================================================================================================


//========================================================================================================
public Model_Changer(id)
{
	if(!is_user_connecting(id) && is_user_alive(id))
	{
		set_user_model(id)
	}
}
//========================================================================================================


//========================================================================================================
public set_user_model(id)
{
	static model[128], random_one
	
	switch(get_user_team(id))
	{
		case 1:
		{
			random_one = random_num(0, ArraySize(Player_Model2) - 1)
			ArrayGetString(Player_Model2, random_one, model, charsmax(model))
	
			//cs_set_user_model(id, model)
			engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer,id),"model",model)
			player_model_locked[id] = true
		}
		case 2:
		{
			random_one = random_num(0, ArraySize(Player_Model) - 1)
			ArrayGetString(Player_Model, random_one, model, charsmax(model))
	
			//cs_set_user_model(id, model)
			engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer,id),"model",model)
			player_model_locked[id] = true
		}
	}
}
//========================================================================================================		
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1048\\ f0\\ fs16 \n\\ par }
*/
