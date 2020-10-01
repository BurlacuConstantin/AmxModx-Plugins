//Plugin generat de @bbb

#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <cstrike>
#include <hamsandwich>
#include <fakemeta>

#define PLUGIN "Dr_VIP"
#define VERSION "0.1"
#define AUTHOR "bbb"

#define VIP_ACCES ADMIN_IMMUNITY

#pragma tabsize 0

new Tag[] ="!v[Deathrun VIP]:!g"

new bool:GiveSpeed[33]
new bool:Nu_mai_ai_voie[33]
new bool:NU_MAI_POTI_FOLOSI[33]

public plugin_init()
{
	register_plugin(PLUGIN,VERSION,AUTHOR)
	
	register_clcmd("say /drvip","cmd_vip")
	register_clcmd("say /vmenu","cmd_vip")
	register_clcmd("say_team /drvip","cmd_vip")
	register_clcmd("say_team /vmenu","cmd_vip")
	register_clcmd("say /vipshop","cmd_vip")
	register_clcmd("say_team /vipshop","cmd_vip")
	
	RegisterHam(Ham_Spawn, "player", "Spawn", 1)
	
	RegisterHam(Ham_Item_PreFrame,"player","PreFrame_Post",1)
	
	register_event("ResetHUD", "resetModel", "b")
	
}
public plugin_precache()
{
	precache_model("models/player/vip_skin/vip_skin.mdl")
	precache_model("models/player/smith/smith.mdl")
}
public client_connect(id)
{
	GiveSpeed[id] = false
	Nu_mai_ai_voie[id] = false
	NU_MAI_POTI_FOLOSI[id] = false
}
public client_disconnect(id)
{
	GiveSpeed[id] = false
	Nu_mai_ai_voie[id] = false
	NU_MAI_POTI_FOLOSI[id] = false
}
public Spawn(id)
{
	GiveSpeed[id] = false
	Nu_mai_ai_voie[id] = false
	NU_MAI_POTI_FOLOSI[id] = false
}
public resetModel(id)
{
	if(is_user_connect_vip(id))
	{
		new CsTeams:userTeam = cs_get_user_team(id)
		  if (userTeam == CS_TEAM_T) {
                        cs_set_user_model(id, "vip_skin")
                        return 1;
		  }
		 else if(userTeam == CS_TEAM_CT) {
			cs_set_user_model(id, "smith")
                        return 1;
			}
		}
        else 
	{
		cs_reset_user_model(id)
	}
        return 0;
}
	

public cmd_vip(id)
{
	if(is_user_alive(id) && get_user_flags(id) & VIP_ACCES)
	{
		vip_menu(id)
	}
	else if(!is_user_alive(id) && get_user_flags(id) & VIP_ACCES)
	{
		ColorChat(id,"%s Nu poti deschide meniul cand esti mort!",Tag)
		return PLUGIN_HANDLED
	}
	else if(!(get_user_flags(id) & VIP_ACCES))
	{
		ColorChat(id,"%s Nu ai acces la acest meniu.",Tag)
	}
	return PLUGIN_HANDLED
}

public vip_menu(id)
{
	new menu = menu_create("\r[V.I.P]\w Shop","sub_menu")
	menu_additem(menu,"\w800 HP\r","1",0)
	menu_additem(menu,"\wViteza 700\r","2",0)
	menu_additem(menu,"\wNoclip 10 sec\r","3",0)
	menu_additem(menu,"\wRiffles\r","4",0)
	menu_additem(menu,"\wShield\r","5",0)
	menu_additem(menu,"\wMachine Gun\r","6",0)
	menu_additem(menu,"\wGrenade pack 15","7",0)
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu, 0)
}

public sub_menu(id,menu,item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu);
   		remove_task(id);
		return PLUGIN_HANDLED;
	}
	new Data[7], Name[64];
	new Access, Callback;
	menu_item_getinfo(menu, item, Access, Data,5, Name, 63, Callback);
	
	new Key = str_to_num(Data);
	
	switch (Key)
	{
		case 1:
		{
			if(Nu_mai_ai_voie[id] == true)
			{
				ColorChat(id,"%s Ai ales deja HP tura asta",Tag)
				return PLUGIN_HANDLED
			}
			
			Nu_mai_ai_voie[id] = true
			new heal = get_user_health(id)
			set_user_health(id,heal + 800)
			ColorChat(id,"%s Ai primit +800HP",Tag)
		}
		case 2:
		{
			if(GiveSpeed[id] == true)
			{
				ColorChat(id,"%s Ai deja Speed",Tag)
				return PLUGIN_HANDLED
			}
			
			GiveSpeed[id] = true
			set_user_maxspeed(id,800.0)
			ColorChat(id,"%s Ai primit Speed 700",Tag)
		}
		case 3:
		{
			if(NU_MAI_POTI_FOLOSI[id] == true)
			{
				ColorChat(id,"%s Nu mai poti folosi noclip tura asta",Tag)
				return PLUGIN_HANDLED
			}
			
			NU_MAI_POTI_FOLOSI[id] = true
			set_user_noclip(id,1)
			ColorChat(id,"%s Ai luat no clip",Tag)
			set_task(10.0,"No",id)
		}
		case 4:
		{
			give_item(id,"weapon_ak47")
			give_item(id,"weapon_m4a1")
			give_item(id,"weapon_galil")
			give_item(id,"weapon_awp")
			give_item(id,"weapon_famas")
			give_item(id,"weapon_scout")
			give_item(id,"weapon_aug")
			give_item(id,"weapon_sg550")
			give_item(id,"weapon_sg552")
			cs_set_user_bpammo(id,CSW_AK47,5000)
			cs_set_user_bpammo(id,CSW_M4A1,5000)
			cs_set_user_bpammo(id,CSW_GALI,5000)
			cs_set_user_bpammo(id,CSW_AWP,5000)
			cs_set_user_bpammo(id,CSW_FAMAS,5000)
			cs_set_user_bpammo(id,CSW_SCOUT,5000)
			cs_set_user_bpammo(id,CSW_AUG,5000)
			cs_set_user_bpammo(id,CSW_SG552,5000)
			cs_set_user_bpammo(id,CSW_SG550,5000)
			ColorChat(id,"%s Ai primit riffles",Tag)
		}
		case 5:
		{
			give_item(id,"weapon_shield")
			ColorChat(id,"%s Ai primit Shield",Tag)
		}
		case 6:
		{
			if(user_has_weapon(id,CSW_M249))
			{
				ColorChat(id,"%s Ai deja Machine Gun",Tag)
				return PLUGIN_HANDLED
			}
			
			give_item(id,"weapon_m249")
			cs_set_user_bpammo(id,CSW_M249,5000)
			ColorChat(id,"%s Ai primit Machine Gun",Tag)
		}
		case 7:
		{
			if(user_has_weapon(id,CSW_HEGRENADE))
			{
				ColorChat(id,"%s Ai deja Grenada",Tag)
				return PLUGIN_HANDLED
			}
			
			give_item(id,"weapon_hegrenade")
			cs_set_user_bpammo(id,CSW_HEGRENADE,15)
			ColorChat(id,"%s Ai primit Grenade pack",Tag)
		}
	}
	return PLUGIN_HANDLED
}
public No(id)
{
	remove_task(id)
	set_user_noclip(id,0)
	ColorChat(id,"%s Cele 10 secunde de noclip sau terminat",Tag)
}
public PreFrame_Post(id)
{
	if(GiveSpeed[id])
	{
		set_user_maxspeed(id,800.0)
	}
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
stock bool:is_user_connect_vip( id )
{
	if( get_user_flags( id ) & VIP_ACCES)
		return true;

	return false;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
