#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <fun>
#include <cstrike>
#include <engine>


#define PLUGIN "Deathrun Shop Menu"
#define VERSION "3.0"
#define AUTHOR "bbb"

new g_szMenuName[ ] = "\w|\rDeathrun\w Shop|";

new health_sound[] = "misc/health.wav"
new invizi_sound[] = "misc/invisup.wav"
new speed_sound[] = "misc/speed.wav"


new Tag[] = "!v[Deathrun Shop]:!g"

new bool:Speeds[33]
new blink,health,armor

public plugin_init()
{
	register_plugin(PLUGIN,VERSION,AUTHOR)
	
	//Comenzi in chat
	register_clcmd("say /shop","cmd_shop")
	register_clcmd("say /ctshop","cmd_shop")
	register_clcmd("say_team /shop","cmd_shop")
	register_clcmd("say_team /ctshop","cmd_shop")
	register_clcmd("say shop","cmd_shop")
	register_clcmd("say_team shop","cmd_shop")
	
	//Hamuri
	RegisterHam(Ham_Spawn, "player", "HAM_Spawn_Post", 1)
	
	RegisterHam(Ham_Item_PreFrame,"player","PreFrame_Post",1)
	
	blink = get_user_msgid("BlinkAcct")
	
}
public plugin_precache()
{
	precache_sound(health_sound)
	precache_sound(invizi_sound)
	precache_sound(speed_sound)
	
	health = precache_model("sprites/health.spr")
	armor = precache_model("sprites/armor.spr")

}
public client_connect(id)
{
	Speeds[id] = false
}
public client_disconnect(id)
{
	Speeds[id] = false
}

public HAM_Spawn_Post(id) 
{
	Speeds[id] = false
}

public cmd_shop(id)
{
	if(is_user_connected(id) && is_user_alive(id) && cs_get_user_team(id) == CS_TEAM_CT)
	{
		shop(id)
	}
	else if(!is_user_alive(id) && cs_get_user_team(id) == CS_TEAM_CT || cs_get_user_team(id) == CS_TEAM_SPECTATOR)
	{
		ColorChat(id,"%s Nu poti folosi shopul cand esti mort",Tag)
	}
	return PLUGIN_HANDLED
}

public shop(id)
{
	new szMenuName[ 64 ];
	formatex( szMenuName, sizeof ( szMenuName ) -1, "%s^n\wCash:\r[%i]", g_szMenuName, cs_get_user_money( id ) );
	new shopmenu = menu_create(szMenuName, "sub_shop");
	new iMoney = cs_get_user_money(id);
	if( iMoney >= 10000)
	{
	menu_additem(shopmenu, "\wDeagle\r   [10.000$]", "1",0);
	}
	else
	{
	menu_additem(shopmenu, "\dDeagle\d   [10.000$]", "1",0);
	}
	if( iMoney >=  1500)
	{
	menu_additem(shopmenu, "\wHeGrenade\r   [1.500$]","2",0);
	}
	else
	{
	menu_additem(shopmenu, "\dHeGrenade\d   [1.500$]","2",0);
	}
	if( iMoney >=  1000)
	{
	menu_additem(shopmenu, "\wFlashBang\r   [1.000$]","3",0);
	}
	else
	{
	menu_additem(shopmenu, "\dFlashBang\d   [1.000$]","3",0);
	}
	if( iMoney >= 2000)
	{
	menu_additem(shopmenu, "\wFrostGrenade\r   [2.000$]","4",0);
	}
	else
	{
	menu_additem(shopmenu, "\dFrostGrenade\d   [2.000$]","4",0);
	}
	if( iMoney >= 3000)
	{
	menu_additem(shopmenu, "\w+ 100 HP\r   [3.000$]","5",0);
	}
	else
	{
	menu_additem(shopmenu, "\d+ 100 HP\d   [3.000$]","5",0);
	}
	if( iMoney >= 1500)
	{
	menu_additem(shopmenu, "\w+ 50 AP\r   [1.500$]","6",0);
	}
	else
	{
	menu_additem(shopmenu, "\d+ 50 AP\d   [1.500$]","6",0);
	}
	if( iMoney >= 5000)
	{
	menu_additem(shopmenu, "\wSpeed (1 Round)\r   [5.000$]","7",0);
	}
	else
	{
	menu_additem(shopmenu, "\dSpeed (1 Round)\d   [5.000$]","7",0);
	}
	if( iMoney >= 13000)
	{
	menu_additem(shopmenu, "\wNoclip (5 sec)\r   [13.000$]","8",0);
	}
	else
	{
	menu_additem(shopmenu, "\dNoclip (5 sec)\d   [13.000$]","8",0);
	}
	if( iMoney >= 16000)
	{
	menu_additem(shopmenu, "\wInvizibilitate (1 Round)\r  [16.000$]","9",0)
	}
	else 
	{
	menu_additem(shopmenu, "\dInvizibilitate (1 Round)\d  [16.000$]","9",0)
	}
	
	menu_setprop(shopmenu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, shopmenu, 0);
}
public sub_shop(id, shopmenu, item) 
{
	if (item == MENU_EXIT)
	{
		menu_destroy(shopmenu);
   		remove_task(id);
		return PLUGIN_HANDLED;
	}
	new Data[7], Name[64];
	new Access, Callback;
	menu_item_getinfo(shopmenu, item, Access, Data,5, Name, 63, Callback);
	
	new Key = str_to_num(Data);
	
	switch (Key)
	{
		case 1:
		{
			new iMoney = cs_get_user_money(id) - 10000;
			if( iMoney < 0 )
			{
				Show_blink(id)
				ColorChat(id,"%s Fonduri insuficiente",Tag)
				return PLUGIN_HANDLED
			}
			else if(user_has_weapon(id,CSW_DEAGLE))
			{
				ColorChat(id,"%s Ai deja Deagle.",Tag)
				return PLUGIN_HANDLED
			}
			
			give_item(id, "weapon_deagle")
			cs_set_user_bpammo(id, CSW_DEAGLE, 300)
			cs_set_user_money(id, cs_get_user_money(id) - 10000)
			ColorChat(id,"%s Ai cumparat Deagle.",Tag)
		}
		case 2:
		{
			new iMoney = cs_get_user_money(id) -1500;
			if(iMoney < 0 )
			{
				Show_blink(id)
				ColorChat(id,"%s Fonduri insuficiente",Tag)
				return PLUGIN_HANDLED
			}
			else if(user_has_weapon(id,CSW_HEGRENADE))
			{
				ColorChat(id,"%s Ai deja HeGrenade.",Tag)
				return PLUGIN_HANDLED
			}
			
			give_item(id, "weapon_hegrenade")
			cs_set_user_money(id, cs_get_user_money(id) - 1500)
			ColorChat(id,"%s Ai cumparat HeGrenade.",Tag)

		}
		case 3:
		{
			new iMoney = cs_get_user_money(id) - 1000;
			if(iMoney < 0)
			{
				Show_blink(id)
				ColorChat(id,"%s Fonduri insuficiente",Tag)
				return PLUGIN_HANDLED
			}
			else if(user_has_weapon(id,CSW_FLASHBANG))
			{
				ColorChat(id,"%s Ai deja FlashBang.",Tag)
				return PLUGIN_HANDLED
			}
			
			give_item(id, "weapon_flashbang")
			cs_set_user_bpammo(id,CSW_FLASHBANG,2)
			cs_set_user_money(id, cs_get_user_money(id) - 1000)
			ColorChat(id,"%s Ai cumparat FlashBang.",Tag)
		}
		case 4:
		{
			new iMoney = cs_get_user_money(id) - 2000;
			if(iMoney < 0)
			{
				Show_blink(id)
				ColorChat(id,"%s Fonduri insuficiente",Tag)
				return PLUGIN_HANDLED
			}
			else if(user_has_weapon(id,CSW_SMOKEGRENADE))
			{
				ColorChat(id,"%s Ai deja FrostGrenade.",Tag)
				return PLUGIN_HANDLED
			}
			
			give_item(id, "weapon_smokegrenade")
			cs_set_user_money(id,cs_get_user_money(id) - 2000)
			ColorChat(id,"%s Ai cumparat FrostGrenade.",Tag)
		}
		case 5:
		{
			new iMoney = cs_get_user_money(id) - 3000;
			if(iMoney < 0)
			{
				Show_blink(id)
				ColorChat(id,"%s Fonduri insuficiente",Tag)
				return PLUGIN_HANDLED
			}
			else
			{
			set_user_health(id,get_user_health(id) + 100)
			cs_set_user_money(id,cs_get_user_money(id) - 3000)
			ColorChat(id,"%s Ai cumparat +100 HP.",Tag)
			set_sprite(id)
			emit_sound(id, CHAN_ITEM,health_sound, 0.6, ATTN_NORM, 0, PITCH_NORM) 
			}
		}
		case 6:
		{
			new iMoney = cs_get_user_money(id) - 1500;
			if(iMoney < 0)
			{
				Show_blink(id)
				ColorChat(id,"%s Fonduri insuficiente",Tag)
				return PLUGIN_HANDLED
			}
			else
			{
			set_user_armor(id,get_user_armor(id) + 50)
			cs_set_user_money(id,cs_get_user_money(id) - 1500)
			ColorChat(id,"%s Ai cumparat +50 AP.",Tag)
			set_armor(id)
			emit_sound(id, CHAN_ITEM,health_sound, 0.6, ATTN_NORM, 0, PITCH_NORM) 
			}
		}
		case 7:
		{
			
			new iMoney = cs_get_user_money(id) - 5000;
			if(iMoney < 0)
			{
				Show_blink(id)
				ColorChat(id,"%s Fonduri insuficiente",Tag)
				return PLUGIN_HANDLED
			}
			else if(Speeds[id] == true)
			{
				ColorChat(id,"%s Ai deja Speed.",Tag)
				return PLUGIN_HANDLED
			}
			
			Speeds[id] = true;
			set_user_maxspeed(id,600.0)
			ColorChat(id,"%s Ai cumparat Speed pentru o tura.",Tag)
			cs_set_user_money(id,cs_get_user_money(id) - 5000)
			emit_sound(id, CHAN_ITEM,speed_sound, 0.6, ATTN_NORM, 0, PITCH_NORM) 
			
		}
		case 8:
		{
			new iMoney = cs_get_user_money(id) - 13000;
			if(iMoney < 0)
			{
				Show_blink(id)
				ColorChat(id,"%s Fonduri insuficiente",Tag)
				return PLUGIN_HANDLED
			}
			
			set_user_noclip(id,1)
			cs_set_user_money(id,cs_get_user_money(id) - 13000)
			ColorChat(id,"%s Ai cumparat noclip timp de 5 secunde",Tag)
			set_task(5.0,"remove",id)
		}
		case 9:
		{
			new iMoney = cs_get_user_money(id) - 16000;
			if(iMoney < 0)
			{
				Show_blink(id)
				ColorChat(id,"%s Fonduri insuficiente",Tag)
				return PLUGIN_HANDLED
			}
			
			set_entity_visibility(id, 0)
			cs_set_user_money(id,cs_get_user_money(id) - 16000)
			ColorChat(id,"%s Ai cumparat invizibilitate o tura",Tag)
			emit_sound(id, CHAN_ITEM,invizi_sound, 0.6, ATTN_NORM, 0, PITCH_NORM) 
		}
	}
	menu_destroy(shopmenu)
	return PLUGIN_HANDLED
}
public remove(id)
{
	remove_task(id)
	set_user_noclip(id,0)
	ColorChat(id,"%s Cele 5 secunde de noclip sau terminat",Tag)
}
	
public PreFrame_Post(id)
{
	if(Speeds[id])
	{
		set_user_maxspeed(id,600.0)
	}
}

public set_sprite(victim)
{
	new Origin[3]
	get_user_origin(victim,Origin)
	
	health_sprite(Origin)
}

health_sprite(Origin[3])
{
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_SPRITE)
	write_coord(Origin[0]) 
	write_coord(Origin[1]) 
	write_coord(Origin[2]+=30)
	write_short(health)
	write_byte(8)
	write_byte(255)
	message_end()
}
public set_armor(victim)
{
	new origin[3]
	get_user_origin(victim,origin)
	
	armor_sprite(origin)
}

armor_sprite(origin[3])
{
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_SPRITE)
	write_coord(origin[0]) 
	write_coord(origin[1]) 
	write_coord(origin[2]+=30)
	write_short(armor)
	write_byte(8)
	write_byte(255)
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

stock Show_blink(id)
{
	message_begin(MSG_ONE_UNRELIABLE,blink,.player = id)
	{
		write_byte(2)
	}
	message_end()
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
