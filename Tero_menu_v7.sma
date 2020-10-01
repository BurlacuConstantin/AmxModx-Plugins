//Plugin generat de @AsuStar

#include <amxmodx>
#include <cstrike>
#include <hamsandwich>
#include <fun>
#include <engine>

#define PLUGIN "Tero's Menu"
#define VERSION "0.7"
#define AUTHOR "AsuStar"

new bool:ShowSpeed[33]

new Tag[] ="!v[Deathrun]:!g"


public plugin_init()
{
	RegisterHam(Ham_Spawn, "player", "Respawn_Player", 1)
	
	RegisterHam(Ham_Item_PreFrame,"player","PreFrame_Post",1)
}

public client_connect(id)
{
	ShowSpeed[id] = false
}

public client_disconnect(id)
{
	ShowSpeed[id] = false
}

public Respawn_Player(id)
{
	
	ShowSpeed[id] = false
	
	if(is_user_alive(id) && cs_get_user_team(id) == CS_TEAM_T)
	{
		Menus(id)
		strip_user_weapons(id)
		give_item(id,"weapon_knife")
	}
}

public Menus(id)
{
	new menu = menu_create("\rMeniu Terorist","sub_menu")
	menu_additem(menu,"\wInvizibilitate\y [Invizibil Complet]\r","1",0)
	menu_additem(menu,"\wGravitate Mare\y [600]\r","2",0)
	menu_additem(menu,"\wViteza Mare\y [600]\r","3",0)
	menu_additem(menu,"\wMulte FlashBang\y [15]\r","4",0)
	menu_additem(menu,"\wMulte Grenazi\y [5]\r","5",0)
	menu_additem(menu,"\wDeagle \y [7 Gloante]\r","6",0)
	menu_additem(menu,"\wHP Mult\y [+200]\r","7",0)
	
	menu_display(id,menu, 0)
}

public sub_menu(id,menu,item)
{
	if (item == MENU_EXIT || !is_user_alive(id) || cs_get_user_team(id) == CS_TEAM_CT)
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
			set_entity_visibility(id, 0)
			ColorChat(id,"%s Ai ales Invizibilitate completa",Tag)
		}
		case 2:
		{
			set_user_gravity(id,0.3)
		}
		case 3:
		{
			ShowSpeed[id] = true
			set_user_maxspeed(id,600.0)
			ColorChat(id,"%s Ai ales Viteza",Tag)
		}
		case 4:
		{
			give_item(id,"weapon_flashbang")
			cs_set_user_bpammo(id,CSW_FLASHBANG,15)
			ColorChat(id,"% Ai ales 15 FlashBang",Tag)
		}
		case 5:
		{
			give_item(id,"weapon_hegrenade")
			cs_set_user_bpammo(id,CSW_HEGRENADE,5)
			ColorChat(id,"%s Ai ales 5 Grenazi",Tag)
		}
		case 6:
		{
			give_item(id,"weapon_deagle")
			ColorChat(id,"%s Ai ales Deagle",Tag)
		}
		case 7:
		{
			new Health = get_user_health(id)
			set_user_health(id,Health + 200)
			ColorChat(id,"%s Ai ales 8000 HP",Tag)
			
			set_hudmessage(85, 255, 255, 0.0, -1.0, 0, 6.0, 6.0)
			show_hudmessage(0, "Tero a devenit un monstru cu +200HP")
		}
	}
	return PLUGIN_HANDLED
}

public PreFrame_Post(id)
{
	if(ShowSpeed[id])
	{
		set_user_maxspeed(id,600.0)
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

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
