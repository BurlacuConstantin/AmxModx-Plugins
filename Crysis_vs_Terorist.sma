#include <amxmodx>
#include <fun>
#include <cstrike>
#include <fakemeta>
#include <engine>
#include <hamsandwich>

#define PLUGIN "Crysis vs Terorist v1.0"
#define VERSION "1.0"
#define AUTHOR "bbb"

#pragma tabsize 0

new Knife[64] = "models/Crysis_Mod/v_superknife.mdl"
new grvknife[64] = "models/Crysis_Mod/v_gravknife.mdl"
new invzknife[64] = "models/Crysis_Mod/v_invzknife.mdl"

new RoundStartSound[] = "misc/RoundStart.wav"


new Tagu[] = "!v[Crysis]:!g"

new g_last_ct,g_iMsgTeamInfo,g_iMsgSayText,g_iMaxplayers,CreateHud

new bool:iknife[33],gknife[33],sknife[33],dknife[33],g_bConnected[33]

new Sounds[7] []=
{
	"misc/error.wav",
	"misc/error2.wav",
	"misc/power.wav",
	"misc/maximum_armor.wav",
	"misc/maximum_health.wav",
	"misc/shop_open.wav",
	"misc/health_armor.wav"
}

new Winsounds[6] []=
{
	"misc/ctwin.wav",
	"misc/ctwin2.wav",
	"misc/ctwin3.wav",
	"misc/twin.wav",
	"misc/twin2.wav",
	"misc/twin3.wav"
}

enum Color 
{
	NORMAL = 1,
	GREEN,
	RED,
	BLUE
}

new TeamName[ ][ ] = 
{
	"",
	"TERRORIST",
	"CT",
	"SPECTATOR"
}

new SpawnSound[] = "misc/energy.wav"
new CurrentWeaponSoundknife[] = "misc/clock.wav"
new max_speed[] = "misc/max_speed.wav"
new Armor,Health

new const ModelPlayer[] = "halo_ct"


public plugin_init()
{
	register_plugin(PLUGIN,VERSION,AUTHOR)
	
	register_event("HLTV","RoundStart","a","1=0","2=0")
	
	RegisterHam(Ham_Spawn,"player","Spawn",1)
	
	register_event("DeathMsg","DeathMsgEvent","a")
	
	RegisterHam(Ham_Killed,"player","fw_PlayerKilled")
	
	register_event("CurWeapon","CurrentWeapon","be","1=1")
	
	RegisterHam ( Ham_TakeDamage, "player", "Player_TakeDamage" )
	
	register_forward( FM_GetGameDescription, "GameDesc" )
	
	register_event("SendAudio","TeroWin","a","2=%!MRAD_terwin")
	
    	register_event("SendAudio","CtWin","a","2=%!MRAD_ctwin")
	
	
	register_clcmd("say /menu","cmd_menu")
	register_clcmd("say menu","cmd_menu")
	register_clcmd("say_team /menu","cmd_menu")
	register_clcmd("say_team menu","cmd_menu")
	register_concmd("menu","cmd_menu")
	
	register_concmd("choseteam","block")
	
	g_iMsgTeamInfo   = get_user_msgid( "TeamInfo" )
	g_iMsgSayText    = get_user_msgid( "SayText" )
	g_iMaxplayers    = get_maxplayers()
	CreateHud = CreateHudSyncObj()
	
}
public plugin_precache()
{
	new buffer[128]
	
	precache_model(Knife)
	precache_model(invzknife)
	precache_model(grvknife)
	
	precache_sound(SpawnSound)
	precache_sound(CurrentWeaponSoundknife)
	precache_sound(max_speed)
	precache_sound(RoundStartSound)
	
	formatex(buffer,sizeof(buffer) -1,"models/player/%s/%s.mdl",ModelPlayer,ModelPlayer)
	precache_model(buffer)
	
	
	Armor = precache_model("sprites/armor.spr")
	Health = precache_model("sprites/health.spr")
	
	
	for(new i = 0;i < sizeof(Sounds);i++)
	engfunc(EngFunc_PrecacheSound,Sounds[i])
	
	for(new a = 0;a < sizeof(Winsounds);a++)
	engfunc(EngFunc_PrecacheSound,Winsounds[a])
}
public client_putinserver(id)
{
	set_task(0.3,"Set",id)
}
public Set(id)
{
	cs_set_user_team(id,CS_TEAM_T)
}
public client_connect(id)
{
	client_cmd(id,"bind c menu")
	
	iknife[id] = false
	gknife[id] = false
	sknife[id] = false
	dknife[id] = false
}

public client_disconnect(id)
{
	iknife[id] = false
	gknife[id] = false
	sknife[id] = false
	dknife[id] = false
}

public Spawn(id)
{
	iknife[id] = false
	gknife[id] = false
	sknife[id] = false
	dknife[id] = false
	
	if(id == g_last_ct)
	{
		cs_reset_user_model(id)
	}
	
	if(is_user_alive(id) && cs_get_user_team(id) == CS_TEAM_CT)
	{
		emit_sound(id, CHAN_ITEM,SpawnSound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	return PLUGIN_CONTINUE
	
}
public DeathMsgEvent()
{
	new id = read_data(2)
	
	iknife[id] = false
	gknife[id] = false
	sknife[id] = false
	dknife[id] = false
}

public fw_PlayerKilled(victim, attacker, shouldgib)
{
	iknife[victim] = false
	gknife[victim] = false
	sknife[victim] = false
	dknife[victim] = false
}
public block(id) return PLUGIN_HANDLED_MAIN

public CurrentWeapon(id)
{
	if(is_user_alive(id) && cs_get_user_team(id) == CS_TEAM_CT)
	{
	new Arma = get_user_weapon(id)
	
	if(iknife[id] && Arma == CSW_KNIFE)
	{
		set_pev(id, pev_viewmodel2,invzknife)
		
		message_begin(MSG_ONE,get_user_msgid("StatusIcon"),{0,0,0},id)
		write_byte(2)
		write_string("dmg_rad")
		write_byte(255)
		write_byte(255)
		write_byte(0)
		message_end()
		
		emit_sound(id, CHAN_ITEM,CurrentWeaponSoundknife, 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		set_entity_visibility(id,0)
	}
	else if(!(iknife[id] && Arma == CSW_KNIFE))
	{
		message_begin(MSG_ONE,get_user_msgid("StatusIcon"),{0,0,0},id)
		write_byte(0)
		write_string("dmg_rad")
		write_byte(255)
		write_byte(255)
		write_byte(0)
		message_end()
		
		set_entity_visibility(id,1)
	}
	
	if(gknife[id] && Arma == CSW_KNIFE)
	{
		set_pev(id, pev_viewmodel2,grvknife)
		
		message_begin(MSG_ONE,get_user_msgid("StatusIcon"),{0,0,0},id)
		write_byte(2)
		write_string("dmg_rad")
		write_byte(255)
		write_byte(255)
		write_byte(0)
		message_end()
		
		emit_sound(id, CHAN_ITEM,CurrentWeaponSoundknife, 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		set_user_gravity(id,0.2)
	}
	else if(!(gknife[id] && Arma == CSW_KNIFE))
	{
		message_begin(MSG_ONE,get_user_msgid("StatusIcon"),{0,0,0},id)
		write_byte(0)
		write_string("dmg_rad")
		write_byte(255)
		write_byte(255)
		write_byte(0)
		message_end()
		
		set_user_gravity(id)
	}
	
	if(sknife[id] && Arma == CSW_KNIFE)
	{
		set_pev(id, pev_viewmodel2,Knife)
		
		message_begin(MSG_ONE,get_user_msgid("StatusIcon"),{0,0,0},id)
		write_byte(2)
		write_string("dmg_rad")
		write_byte(255)
		write_byte(255)
		write_byte(0)
		message_end()
		
		emit_sound(id, CHAN_ITEM,max_speed, 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		set_user_maxspeed(id,800.0)
	}
	else if(!(sknife[id] && Arma == CSW_KNIFE))
	{
		message_begin(MSG_ONE,get_user_msgid("StatusIcon"),{0,0,0},id)
		write_byte(0)
		write_string("dmg_rad")
		write_byte(255)
		write_byte(255)
		write_byte(0)
		message_end()
		
		set_user_maxspeed(id,250.0)
	}
	
	if(dknife[id] && Arma == CSW_KNIFE)
	{
		set_pev(id, pev_viewmodel2,Knife)
		
		message_begin(MSG_ONE,get_user_msgid("StatusIcon"),{0,0,0},id)
		write_byte(2)
		write_string("dmg_rad")
		write_byte(255)
		write_byte(255)
		write_byte(0)
		message_end()
		
		emit_sound(id, CHAN_ITEM,CurrentWeaponSoundknife, 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	else if(!(dknife[id] && Arma == CSW_KNIFE))
	{
		message_begin(MSG_ONE,get_user_msgid("StatusIcon"),{0,0,0},id)
		write_byte(0)
		write_string("dmg_rad")
		write_byte(255)
		write_byte(255)
		write_byte(0)
		message_end()
	}
		
	if(Arma == CSW_HEGRENADE)
	{
		message_begin(MSG_ONE,get_user_msgid("StatusIcon"),{0,0,0},id)
		write_byte(1)  // status (0=hide, 1=show, 2=flash)
		write_string("dmg_heat") // sprite name
		write_byte(255) //R
		write_byte(0) //G
		write_byte(0) //B
		message_end()
	}
	else if(!(Arma == CSW_HEGRENADE))
	{
		message_begin(MSG_ONE,get_user_msgid("StatusIcon"),{0,0,0},id)
		write_byte(0)
		write_string("dmg_heat")
		write_byte(255)
		write_byte(0)
		write_byte(0)
		message_end()
	}
	
	if(Arma == CSW_FLASHBANG)
	{
		message_begin(MSG_ONE,get_user_msgid("StatusIcon"),{0,0,0},id)
		write_byte(1)
		write_string("dmg_shock")
		write_byte(255)
		write_byte(255)
		write_byte(255)
		message_end()
	}
	else if(!(Arma == CSW_FLASHBANG))
	{
		message_begin(MSG_ONE,get_user_msgid("StatusIcon"),{0,0,0},id)
		write_byte(0)
		write_string("dmg_shock")
		write_byte(255)
		write_byte(255)
		write_byte(255)
		message_end()
	}
	
	
	if(Arma == CSW_SMOKEGRENADE)
	{
		message_begin(MSG_ONE,get_user_msgid("StatusIcon"),{0,0,0},id)
		write_byte(1)
		write_string("dmg_cold")
		write_byte(0)
		write_byte(255)
		write_byte(255)
		message_end()
	}
	else if(!(Arma == CSW_SMOKEGRENADE))
	{
		message_begin(MSG_ONE,get_user_msgid("StatusIcon"),{0,0,0},id)
		write_byte(0)
		write_string("dmg_cold")
		write_byte(0)
		write_byte(0)
		write_byte(255)
		message_end()
	}
	
	}
	return PLUGIN_CONTINUE
}
	
public RoundStart()
{
	new i,Players[32],iNum
	get_players(Players,iNum)
	
	if(iNum <= 1)
	return PLUGIN_CONTINUE

	for(i = 0;i < iNum;i++)
	{
		new players = Players[i]
		
		if(cs_get_user_team(players) == CS_TEAM_CT)
		{
			cs_set_user_team(players,CS_TEAM_T)
		}
	}
	
	new random_player, CsTeams:Team
	while((random_player = Players[random_num(0,iNum -1)]) == g_last_ct) { }
	
	//g_last_ct = random_player
	
	Team = cs_get_user_team(random_player)
	
	if(Team == CS_TEAM_T || Team == CS_TEAM_CT)
	{
		cs_set_user_team(random_player,CS_TEAM_CT)
		cs_set_user_money(random_player,cs_get_user_money(random_player) + 18000)
		give_item(random_player,"weapon_hegrenade")
		give_item(random_player,"weapon_flashbang")
		give_item(random_player,"weapon_smokegrenade")
		cs_set_user_bpammo(random_player,CSW_FLASHBANG,2)
		
		cs_set_user_model(random_player,ModelPlayer)
		
		new name[32]
		get_user_name(random_player,name,sizeof(name) -1)
		
		for(new a = 0;a < iNum;a++)
		{
			ColorChatr(Players[a],RED,"[Crysis]:\YEL Sa ales noul Crysis care este %s",name)
			client_cmd(Players[a],"spk %s",RoundStartSound)
		}
		
	}
	g_last_ct = random_player
	
	return PLUGIN_CONTINUE
}

public cmd_menu(id)
{
	if(is_user_alive(id) && cs_get_user_team(id) == CS_TEAM_CT)
	{
		Shop(id)
	}
	else if(cs_get_user_team(id) == CS_TEAM_T || cs_get_user_team(id) == CS_TEAM_SPECTATOR)
	{
		ColorChat(id,"%s Trebuie sa fi!e Crisys!g pentru a folosi acest meniu!",Tagu)
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}
	
public Shop(id)
{
	emit_sound(id, CHAN_ITEM,Sounds[5], 1.0, ATTN_NORM, 0, PITCH_NORM)
	new MeniuName[64]
	formatex(MeniuName,sizeof(MeniuName) -1,"\wCrisys Menu^nCash:[\r%i\w]",cs_get_user_money(id))
	new ct = menu_create(MeniuName,"sub_crys")
	new i = cs_get_user_money(id)
	if(i >= 5000)
	{
		menu_additem(ct,"\wInvizibility Knife\r 5.000$","1",0)
	}
	else
	{
		menu_additem(ct,"\dInvizibility Knife\d 5.000$","1",0)
	}
	if(i >= 4000)
	{
		menu_additem(ct,"\wGravity Knife\r 4.000$","2",0)
	}
	else
	{
		menu_additem(ct,"\dGravity Knife\d 4.000$","2",0)
	}
	if(i >= 4000)
	{
		menu_additem(ct,"\wSpeed Knife\r 4.000$","3",0)
	}
	else
	{
		menu_additem(ct,"\dSpeed Knife\d 4.000$","3",0)
	}
	if(i >= 3000)
	{
		menu_additem(ct,"\wDamage Knife\r 3.000$","4",0)
	}
	else
	{
		menu_additem(ct,"\dDamage Knife\d 3.000$","4",0)
	}
	if(i >= 2500)
	{
		menu_additem(ct,"\wHeGrenade\r 2.500$","5",0)
	}
	else
	{
		menu_additem(ct,"\dHeGrenade\d 2.500$","5",0)
	}
	if(i >= 1500)
	{
		menu_additem(ct,"\wFlashBang\r 1.500$","6",0)
	}
	else
	{
		menu_additem(ct,"\dFlashBang\d 1.500$","6",0)
	}
	if(i >= 1000)
	{
		menu_additem(ct,"\wSmokeGrenade\r 1.000$","7",0)
	}
	else
	{
		menu_additem(ct,"\dSmokeGrenade\d 1.000$","7",0)
	}
	if(i >= 2500)
	{
		menu_additem(ct,"\w+50 HP\r 2.500$","8",0)
	}
	else
	{
		menu_additem(ct,"\d+50 HP\d 2.500$","8",0)
	}
	if(i >= 1500)
	{
		menu_additem(ct,"\w+100 AP\r 1.500$","9",0)
	}
	else
	{
		menu_additem(ct,"\d+100 AP\d 1.500$","9",0)
	}
	
	menu_setprop(ct, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, ct, 0)
}
	
public sub_crys(id,ct,item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(ct)
   		remove_task(id)
		return PLUGIN_HANDLED
	}
	new Data[7], Name[64]
	new Access, Callback
	menu_item_getinfo(ct, item, Access, Data,5, Name, 63, Callback)
	
	new Key = str_to_num(Data)
	
	switch (Key)
	{
		case 1:
		{
			new i = cs_get_user_money(id) - 5000
			if(i < 0)
			{
				ColorChat(id,"%s Fonduri insuficiente",Tagu)
				emit_sound(id, CHAN_ITEM,Sounds[0], 1.0, ATTN_NORM, 0, PITCH_NORM)
				show_blink(id)
				return PLUGIN_HANDLED
			}
			else if(iknife[id])
			{
				ColorChat(id,"%s Ai deja invizibility knife",Tagu)
				emit_sound(id, CHAN_ITEM,Sounds[1], 1.0, ATTN_NORM, 0, PITCH_NORM)
				return HAM_IGNORED
			}
			else
			{
				iknife[id] = true
				gknife[id] = false
				sknife[id] = false
				dknife[id] = false
				
				set_pev(id, pev_viewmodel2,invzknife)
				
				cs_set_user_money(id,cs_get_user_money(id) - 5000)
				ColorChat(id,"%s Ai cumparat invizibility knife",Tagu)
				emit_sound(id, CHAN_ITEM,Sounds[2], 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
		}
		case 2:
		{
			new i = cs_get_user_money(id) - 4000
			if(i < 0)
			{
				ColorChat(id,"%s Fonduri insuficiente",Tagu)
				emit_sound(id, CHAN_ITEM,Sounds[0], 1.0, ATTN_NORM, 0, PITCH_NORM)
				show_blink(id)
				return PLUGIN_HANDLED
			}
			else if(gknife[id])
			{
				ColorChat(id,"%s Ai deja gravity knife",Tagu)
				emit_sound(id, CHAN_ITEM,Sounds[1], 1.0, ATTN_NORM, 0, PITCH_NORM)
				return HAM_IGNORED
			}
			else
			{
				gknife[id] = true
				sknife[id] = false
				dknife[id] = false
				iknife[id] = false
				
				set_pev(id, pev_viewmodel2,grvknife)
				
				cs_set_user_money(id,cs_get_user_money(id) - 4000)
				ColorChat(id,"%s Ai cumparat gravity knife",Tagu)
				emit_sound(id, CHAN_ITEM,Sounds[2], 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
		}
		case 3:
		{
			new i = cs_get_user_money(id) - 3000
			if(i < 0)
			{
				ColorChat(id,"%s Fonduri insuficiente",Tagu)
				emit_sound(id, CHAN_ITEM,Sounds[0], 1.0, ATTN_NORM, 0, PITCH_NORM)
				show_blink(id)
				return PLUGIN_HANDLED
			}
			else if(sknife[id])
			{
				ColorChat(id,"%s Ai deja speed knife",Tagu)
				emit_sound(id, CHAN_ITEM,Sounds[1], 1.0, ATTN_NORM, 0, PITCH_NORM)
				return HAM_IGNORED
			}
			else
			{
				sknife[id] = true
				dknife[id] = false
				iknife[id] = false
				gknife[id] = false
				
				set_pev(id, pev_viewmodel2,Knife)
				
				cs_set_user_money(id,cs_get_user_money(id) - 3000)
				ColorChat(id,"%s Ai cumparat speed knife",Tagu)
				emit_sound(id, CHAN_ITEM,Sounds[2], 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
		}
		case 4:
		{
			new i = cs_get_user_money(id) - 3000
			if(i < 0)
			{
				ColorChat(id,"%s Fonduri insuficiente",Tagu)
				emit_sound(id, CHAN_ITEM,Sounds[0], 1.0, ATTN_NORM, 0, PITCH_NORM)
				show_blink(id)
				return PLUGIN_HANDLED
			}
			else if(dknife[id])
			{
				ColorChat(id,"%s Ai deja damage knife",Tagu)
				emit_sound(id, CHAN_ITEM,Sounds[1], 1.0, ATTN_NORM, 0, PITCH_NORM)
				return HAM_IGNORED
			}
			else
			{
				dknife[id] = true
				sknife[id] = false
				gknife[id] = false
				iknife[id] = false
				
				set_pev(id, pev_viewmodel2,Knife)
				
				cs_set_user_money(id,cs_get_user_money(id) - 3000)
				ColorChat(id,"%s Ai cumparat damage knife",Tagu)
				emit_sound(id, CHAN_ITEM,Sounds[2], 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
		}
		case 5:
		{
			new i = cs_get_user_money(id) - 2500
			if(i < 0)
			{
				ColorChat(id,"%s Fonduri insuficiente",Tagu)
				emit_sound(id, CHAN_ITEM,Sounds[0], 1.0, ATTN_NORM, 0, PITCH_NORM)
				show_blink(id)
				return PLUGIN_HANDLED
			}
			else if(user_has_weapon(id,CSW_HEGRENADE))
			{
				ColorChat(id,"%s Ai deja hegrenade",Tagu)
				emit_sound(id, CHAN_ITEM,Sounds[1], 1.0, ATTN_NORM, 0, PITCH_NORM)
				return PLUGIN_HANDLED
			}
			else
			{
				give_item(id,"weapon_hegrenade")
				cs_set_user_money(id,cs_get_user_money(id) - 2500)
				ColorChat(id,"%s Ai cumarat hegrenade",Tagu)
			}
		}
		case 6:
		{
			new i = cs_get_user_money(id) - 1500
			if(i < 0)
			{
				ColorChat(id,"%s Fonduri insuficiente",Tagu)
				emit_sound(id, CHAN_ITEM,Sounds[0], 1.0, ATTN_NORM, 0, PITCH_NORM)
				show_blink(id)
				return PLUGIN_HANDLED
			}
			else if(user_has_weapon(id,CSW_FLASHBANG))
			{
				ColorChat(id,"%s Ai deja flashbang",Tagu)
				emit_sound(id, CHAN_ITEM,Sounds[1], 1.0, ATTN_NORM, 0, PITCH_NORM)
				return PLUGIN_HANDLED
			}
			else
			{
				give_item(id,"weapon_flashbang")
				cs_set_user_bpammo(id,CSW_FLASHBANG,2)
				cs_set_user_money(id,cs_get_user_money(id) - 1500)
				ColorChat(id,"%s Ai cumparat flashbang",Tagu)
			}
		}
		case 7:
		{
			new i = cs_get_user_money(id) - 1000
			if(i < 0)
			{
				ColorChat(id,"%s Fonduri insuficiente",Tagu)
				emit_sound(id, CHAN_ITEM,Sounds[0], 1.0, ATTN_NORM, 0, PITCH_NORM)
				show_blink(id)
				return PLUGIN_HANDLED
			}
			else if(user_has_weapon(id,CSW_SMOKEGRENADE))
			{
				ColorChat(id,"%s Ai deja smokegrenade",Tagu)
				emit_sound(id, CHAN_ITEM,Sounds[1], 1.0, ATTN_NORM, 0, PITCH_NORM)
				return PLUGIN_HANDLED
			}
			else
			{
				give_item(id,"weapon_smokegrenade")
				cs_set_user_money(id,cs_get_user_money(id) - 1000)
				ColorChat(id,"%s Ai cumparat smokegrenade",Tagu)
			}
		}
		case 8:
		{
			new i = cs_get_user_money(id) - 2500
			if(i < 0)
			{
				ColorChat(id,"%s Fonduri insuficiente",Tagu)
				emit_sound(id, CHAN_ITEM,Sounds[0], 1.0, ATTN_NORM, 0, PITCH_NORM)
				show_blink(id)
				return PLUGIN_HANDLED
			}
			else
			{
			new Health = get_user_health(id)
			if(Health >= 200)
			{
				ColorChat(id,"%s Ai ajuns la limita de HP",Tagu)
				emit_sound(id, CHAN_ITEM,Sounds[4], 1.0, ATTN_NORM, 0, PITCH_NORM)
				return PLUGIN_HANDLED
			}
			else
			{
				set_user_health(id,min(get_user_health(id) + 50,200))
				cs_set_user_money(id,cs_get_user_money(id) - 2500)
				ColorChat(id,"%s Ai cumparat!e +50 HP",Tagu)
				emit_sound(id, CHAN_ITEM,Sounds[6], 1.0, ATTN_NORM, 0, PITCH_NORM)
				health_sprite(id)
			}
			}
		}
		case 9:
		{
			new i = cs_get_user_money(id) - 1500
			if(i < 0)
			{
				ColorChat(id,"%s Fonduri insuficiente",Tagu)
				emit_sound(id, CHAN_ITEM,Sounds[0], 1.0, ATTN_NORM, 0, PITCH_NORM)
				show_blink(id)
				return PLUGIN_HANDLED
			}
			else
			{
			new Armor = get_user_armor(id)
			if(Armor >= 200)
			{
				ColorChat(id,"%s Ai ajunst la limita de AP",Tagu)
				emit_sound(id, CHAN_ITEM,Sounds[3], 1.0, ATTN_NORM, 0, PITCH_NORM)
				return PLUGIN_HANDLED
			}
			else
			{
				set_user_armor(id,min(get_user_armor(id) + 100,200))
				cs_set_user_money(id,cs_get_user_money(id) - 1500)
				ColorChat(id,"%s Ai cumparat!e + 100 AP",Tagu)
				emit_sound(id, CHAN_ITEM,Sounds[6], 1.0, ATTN_NORM, 0, PITCH_NORM)
				armor_sprite(id)
			}
			}
		}
	}
	return PLUGIN_CONTINUE
}

public Player_TakeDamage(iVictim, iInflictor, iAttacker, Float:fDamage, iDamageBits)
{
	if(dknife[iAttacker] && is_user_alive(iAttacker) && iInflictor == iAttacker && get_user_weapon(iAttacker) == CSW_KNIFE)
	{
		SetHamParamFloat( 4, fDamage * 50.0 )
		return HAM_HANDLED
	}
	return HAM_HANDLED
}
				
public armor_sprite(id)
{
	new Origin[3]
	get_user_origin(id,Origin)
	
	set_armor_sprite(Origin)
}
public health_sprite(id)
{
	new origin[3]
	get_user_origin(id,origin)
	
	set_health_sprite(origin)
}

set_armor_sprite(Origin[3])
{
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_SPRITE)
	write_coord(Origin[0]) 
	write_coord(Origin[1]) 
	write_coord(Origin[2]+=30)
	write_short(Armor)
	write_byte(8)
	write_byte(255)
	message_end()
}

set_health_sprite(origin[3])
{
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_SPRITE)
	write_coord(origin[0]) 
	write_coord(origin[1]) 
	write_coord(origin[2]+=30)
	write_short(Health)
	write_byte(8)
	write_byte(255)
	message_end()
}
public TeroWin()
{
	set_hudmessage(255, 0, 0, 0.3, 0.33, 0, 6.0, 6.0)
	ShowSyncHudMsg(0,CreateHud,"Crisys a fost invins teroristii au preluat controlul!")
	
	new iPlayers[32],iNum
	get_players(iPlayers,iNum,"c")
	
	for(new i = 0;i < iNum;i++)
	{
		if(is_user_connected(iPlayers[i]))
		{
			ShakeScreen(iPlayers[i],3.0)
    			FadeScreen(iPlayers[i],3.0, 0, 0, 230, 160)
			
			new random_sound = random_num(1,3)
			
			switch(random_sound)
			{
				case 1:client_cmd(iPlayers[i],"spk %s",Winsounds[3])
				case 2:client_cmd(iPlayers[i],"spk %s",Winsounds[4])
				case 3:client_cmd(iPlayers[i],"spk %s",Winsounds[5])
			}
		}
	}
}

public CtWin()
{
	set_hudmessage(42, 255, 255, 0.3, 0.33, 0, 6.0, 6.0)
	ShowSyncHudMsg(0,CreateHud,"Teroristii au fost invinsi Crisys a salvat lumea!")
	
	new iPlayers[32],num
	get_players(iPlayers,num)
	
	for(new i = 0;i < num;i++)
	{
		if(is_user_connected(iPlayers[i]))
		{
			ShakeScreen(iPlayers[i],3.0)
    			FadeScreen(iPlayers[i],3.0, 0, 0, 230, 160)
			
			new random_sound = random_num(1,3)
			
			switch(random_sound)
			{
				case 1:client_cmd(iPlayers[i],"spk %s",Winsounds[0])
				case 2:client_cmd(iPlayers[i],"spk %s",Winsounds[1])
				case 3:client_cmd(iPlayers[i],"spk %s",Winsounds[2])
			}
		}
	}
}

public ShakeScreen( id, const Float:seconds )
{
    	message_begin( MSG_ONE, get_user_msgid( "ScreenShake" ), { 0, 0, 0 }, id );
    	write_short( floatround( 4096.0 * seconds, floatround_round ) );
    	write_short( floatround( 4096.0 * seconds, floatround_round ) );
    	write_short( 1<<13 );
    	message_end( );
}

public FadeScreen( id, const Float:seconds, const red, const green, const blue, const alpha )
{      
    	message_begin( MSG_ONE, get_user_msgid( "ScreenFade" ), _, id );
    	write_short( floatround( 4096.0 * seconds, floatround_round ) );
    	write_short( floatround( 4096.0 * seconds, floatround_round ) );
    	write_short( 0x0000 );
    	write_byte( red );
    	write_byte( green );
    	write_byte( blue );
    	write_byte( alpha );
    	message_end( );
}
	
public GameDesc()
{
	forward_return(FMV_STRING,PLUGIN)
	
	return HAM_SUPERCEDE
}
	
stock show_blink(id)
{
	message_begin(MSG_ONE_UNRELIABLE,get_user_msgid("BlinkAcct"),.player = id)
	{
		write_byte(2)
	}
	message_end()
}			

stock ColorChat( const id, const input[ ], any:... )
{
new count = 1, players[ 32 ]

static msg[ 191 ]
vformat( msg, 190, input, 3 )

replace_all( msg, 190, "!v", "^4" ) //- verde
replace_all( msg, 190, "!g", "^1" ) //- galben
replace_all( msg, 190, "!e", "^3" ) //- echipa
replace_all( msg, 190, "!n", "^0" ) //- normal

if( id ) players[ 0 ] = id; else get_players( players, count, "ch" )
{
for( new i = 0; i < count; i++ )
{
if( is_user_connected( players[ i ] ) )
{
message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "SayText" ), _, players[ i ] )
write_byte( players[ i ] );
write_string( msg );
message_end( );
}
}
}
}

				
ColorChatr( id, Color:type, const szMessage[], {Float,Sql,Result,_}:... ) {
	if( !get_playersnum( ) ) return;
	
	new message[256];
	
	switch( type ) {
		case NORMAL: message[0] = 0x01;
		case GREEN: message[0] = 0x04;
		default: message[0] = 0x03;
	}
	
	vformat( message[ 1 ], 251, szMessage, 4 );
	
	message[ 192 ] = '^0';
	
	replace_all( message, 191, "\YEL", "^1" );
	replace_all( message, 191, "\GRN", "^4" );
	replace_all( message, 191, "\TEM", "^3" );
	
	new iTeam, ColorChange, index, MSG_Type;
	
	if( id ) {
		MSG_Type = MSG_ONE_UNRELIABLE;
		index = id;
	} else {
		index = CC_FindPlayer();
		MSG_Type = MSG_BROADCAST;
	}
	
	iTeam = get_user_team( index );
	ColorChange = CC_ColorSelection(index, MSG_Type, type);

	CC_ShowColorMessage(index, MSG_Type, message);
	
	if( ColorChange )
		CC_Team_Info(index, MSG_Type, TeamName[iTeam]);
}

CC_ShowColorMessage( id, type, message[] ) {
	message_begin( type, g_iMsgSayText, _, id );
	write_byte( id );	
	write_string( message );
	message_end( );	
}

CC_Team_Info( id, type, team[] ) {
	message_begin( type, g_iMsgTeamInfo, _, id );
	write_byte( id );
	write_string( team );
	message_end( );
	
	return 1;
}

CC_ColorSelection( index, type, Color:Type ) {
	switch( Type ) {
		case RED: return CC_Team_Info( index, type, TeamName[ 1 ] );
		case BLUE: return CC_Team_Info( index, type, TeamName[ 2 ] );
	}
	
	return 0;
}

CC_FindPlayer( ) {
	for( new i = 1; i <= g_iMaxplayers; i++ )
		if( g_bConnected[ i ] )
			return i;
	
	return -1;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1048\\ f0\\ fs16 \n\\ par }
*/
