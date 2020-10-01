#include <amxmodx>
#include <fun>
#include <cstrike>

#define PLUGIN "Glow Menu"
#define VERSION "1.0"
#define AUTHOR "AsuStar"

#pragma tabsize 0

new const Tag[] = "!v[Glow Menu]:!g"

new glow_rendering

new bool:Ramane_sau_nu_glow[33]

public plugin_init()
{
	register_plugin(PLUGIN,VERSION,AUTHOR)
	
	register_clcmd("say","cmd_glow")
	register_clcmd("say_team","cmd_glow")
	glow_rendering = register_cvar("glow_value","25")
	
	set_task(120.0, "Show", _, _, _, "b", 0)
}

public client_connect(id)
{
	Ramane_sau_nu_glow[id] = false
}
public Show(id)
{
	ColorChat(0,"%s Daca vrei sa ai glow scrie in chat!v /glow!g sau!v /meniuglow!g (Reclama)",Tag)
}
public client_disconnect(id)
{
	Ramane_sau_nu_glow[id] = false
}

public cmd_glow(id)
{
	new Say[192]
	read_args(Say,sizeof(Say) -1)
	
	if((contain(Say,"/glow") != -1 || contain(Say,"/glowmenu") != -1 || contain(Say,"/meniuglow") != -1 || contain(Say,"glowmenu") != -1 || contain(Say,"meniuglow") != -1))
	{
	 	Glow_Menu_id(id)
	}
}

public Glow_Menu_id(id)
{
	if(is_user_alive(id))
	{
		new menu = menu_create("\yGlow\w Meniu\r","sub_menu")
		menu_additem(menu,"\rGlow\w Rosu","1",0)
		menu_additem(menu,"\rGlow\w Albastru","2",0)
		menu_additem(menu,"\rGlow\w Verde","3",0)
		menu_additem(menu,"\rGlow\w Galben","4",0)
		menu_additem(menu,"\rGlow\w Albastru deschis","5",0)
		menu_additem(menu,"\rGlow\w Roz","6",0)
		menu_additem(menu,"\rGlow\w Maro","7",0)
		menu_additem(menu,"\rGlow\w Rosu inchis","8",0)
		menu_additem(menu,"\rGlow\w Portocaliu","9",0)
		menu_additem(menu,"\rGlow\w Off","10",0)
	
		menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
		menu_display(id, menu, 0)
	}
	else if(!(is_user_alive(id)))
	{
		ColorChat(id,"%s Nu poti accesa!v Meniul Glow!g cat timp esti mort!",Tag)
	}
	return PLUGIN_CONTINUE
}

public sub_menu(id,menu,item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu)
   		remove_task(id)
		return PLUGIN_HANDLED
	}
	new Data[7], Name[64]
	new Access, Callback
	menu_item_getinfo(menu, item, Access, Data,5, Name, 63, Callback)
	
	new Key = str_to_num(Data)
	
	switch (Key)
	{
		case 1:
		{
			if(Ramane_sau_nu_glow[id] == true)
			{
				ColorChat(id,"%s Ai deja!v Glow!g rosu",Tag)
				return PLUGIN_HANDLED
			}
			
			Ramane_sau_nu_glow[id] = true
			set_user_rendering(id,kRenderFxGlowShell,255,0,0,kRenderNormal,get_pcvar_num(glow_rendering))
			ColorChat(id,"%s Ai ales!v Glow!g rosu",Tag)
		}
		case 2:
		{
			if(Ramane_sau_nu_glow[id] == true)
			{
				ColorChat(id,"%s Ai deja!v Glow!g albastru",Tag)
				return PLUGIN_HANDLED
			} 
			
			Ramane_sau_nu_glow[id] = true
			set_user_rendering(id,kRenderFxGlowShell,0,0,255,kRenderNormal,get_pcvar_num(glow_rendering))
			ColorChat(id,"%s Ai ales!v Glow!g albastru",Tag)
		}
		case 3:
		{
			if(Ramane_sau_nu_glow[id] == true)
			{
				ColorChat(id,"%s Ai deja!v Glow!g verde",Tag)
				return PLUGIN_HANDLED
			} 
			
			Ramane_sau_nu_glow[id] = true
			set_user_rendering(id,kRenderFxGlowShell,0,255,0,kRenderNormal,get_pcvar_num(glow_rendering))
			ColorChat(id,"%s Ai ales!v Glow!g verde",Tag)
		}
		case 4:
		{
			if(Ramane_sau_nu_glow[id] == true)
			{
				ColorChat(id,"%s Ai deja!v Glow!g glaben",Tag)
				return PLUGIN_HANDLED
			}
			
			Ramane_sau_nu_glow[id] = true
			set_user_rendering(id,kRenderFxGlowShell,255,255,0,kRenderNormal,get_pcvar_num(glow_rendering))
			ColorChat(id,"%s Ai ales!v Glow!g galben",Tag)
		}
		case 5:
		{
			if(Ramane_sau_nu_glow[id] == true)
			{
				ColorChat(id,"%s Ai deja!v Glow!g albastru deschis",Tag)
				return PLUGIN_HANDLED
			}
			
			Ramane_sau_nu_glow[id] = true
			set_user_rendering(id,kRenderFxGlowShell,0,255,255,kRenderNormal,get_pcvar_num(glow_rendering))
			ColorChat(id,"%s Ai ales!v Glow!g albastru deschis",Tag)
		}
		case 6:
		{
			if(Ramane_sau_nu_glow[id] == true)
			{
				ColorChat(id,"%s Ai deja!v Glow!g roz",Tag)
				return PLUGIN_HANDLED
			}
			
			Ramane_sau_nu_glow[id] = true
			set_user_rendering(id,kRenderFxGlowShell,255,0,212,kRenderNormal,get_pcvar_num(glow_rendering))
			ColorChat(id,"%s Ai ales!v Glow!g roz",Tag)
		}
		case 7:
		{
			if(Ramane_sau_nu_glow[id] == true)
			{
				ColorChat(id,"%s Ai deja!v Glow!g maro",Tag)
				return PLUGIN_HANDLED
			}
			
			Ramane_sau_nu_glow[id] = true
			set_user_rendering(id,kRenderFxGlowShell,165,42,42,kRenderNormal,get_pcvar_num(glow_rendering))
			ColorChat(id,"%s Ai ales!v Glow!g maro",Tag)
		}
		case 8:
		{
			if(Ramane_sau_nu_glow[id] == true)
			{
				ColorChat(id,"%s Ai deja!v Glow!g rosu inchis",Tag)
				return PLUGIN_HANDLED
			}
			
			Ramane_sau_nu_glow[id] = true
			set_user_rendering(id,kRenderFxGlowShell,139,0,0,kRenderNormal,get_pcvar_num(glow_rendering))
			ColorChat(id,"%s Ai ales!v Glow!g rosu inchis",Tag)
		}
		case 9:
		{
			if(Ramane_sau_nu_glow[id] == true)
			{
				ColorChat(id,"%s Ai deja!v Glow!g portocaliu",Tag)
				return PLUGIN_HANDLED
			}
			
			Ramane_sau_nu_glow[id] = true
			set_user_rendering(id,kRenderFxGlowShell,255,165,0,kRenderNormal,get_pcvar_num(glow_rendering))
			ColorChat(id,"%s Ai ales!v Glow!g portocaliu",Tag)
		}
		case 10:
		{
			if(Ramane_sau_nu_glow[id] == false)
			{
				ColorChat(id,"%s Nu ai!v Glow!g pe care sa il dezactivezi!",Tag)
				return PLUGIN_HANDLED
			}
			
			Ramane_sau_nu_glow[id] = false
			set_user_rendering(id)
			ColorChat(id,"%s Ti-ai dezactivat!v Glow-ul",Tag)
		}
	}
	return PLUGIN_CONTINUE
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
