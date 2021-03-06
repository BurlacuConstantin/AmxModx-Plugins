//Plugin generat de @bbb

#include <amxmodx>
#include <fun>
#include <cstrike>
#include <hamsandwich>
#include <fakemeta>

#define PLUGIN "Dr_VIP"
#define VERSION "2.5"
#define AUTHOR "bbb"

#define VIP_ACCES ADMIN_LEVEL_H

#pragma tabsize 0


#define MAX_KNIFE_SNDS 9

#define SHOW_CHAT_VIPS


new original_sounds_knife[MAX_KNIFE_SNDS][] =
{
"weapons/knife_deploy1.wav",
"weapons/knife_hit1.wav",
"weapons/knife_hit2.wav",
"weapons/knife_hit3.wav",
"weapons/knife_hit4.wav",
"weapons/knife_hitwall1.wav",
"weapons/knife_slash1.wav",
"weapons/knife_slash2.wav",
"weapons/knife_stab.wav"
}


new remplace_sounds_knife[MAX_KNIFE_SNDS][] =
{
"axe_model/knife_deploy1.wav",
"axe_model/knife_hit1.wav",
"axe_model/knife_hit2.wav",
"axe_model/knife_hit3.wav",
"axe_model/knife_hit4.wav",
"axe_model/knife_hitwall1.wav",
"axe_model/knife_slash1.wav",
"axe_model/knife_slash2.wav",
"axe_model/knife_stab.wav"
}

new v_Battle[64] = "models/Battle/v_battle.mdl"

new p_Battle[64] = "models/Battle/p_battle.mdl"

new VIP_CONNECT[] = "misc/vip_online.wav"

new VIP_DISCONNECT[] = "misc/vip_offline.wav"

new Tag[] ="!v[Deathrun VIP]:!g"

new bool:GiveSpeed[33]
new bool:Nu_mai_ai_voie[33]
new bool:NU_MAI_POTI_FOLOSI[33]
new bool:BattleAxe[33]

new maxplayers
new gmsgSayText

static const COLOR[] = "^x04"

public plugin_init()
{
	register_plugin(PLUGIN,VERSION,AUTHOR)
	
	register_clcmd("say /drvip","cmd_vip")
	register_clcmd("say /vmenu","cmd_vip")
	register_clcmd("say_team /drvip","cmd_vip")
	register_clcmd("say_team /vmenu","cmd_vip")
	register_clcmd("say /vipshop","cmd_vip")
	register_clcmd("say_team /vipshop","cmd_vip")
	
	register_clcmd("say","clcmd_say")
	register_clcmd("say_team","clcmd_sayteam")
	
	#if defined SHOW_CHAT_VIPS
	register_clcmd("say /vips","cmd_vips")
	register_clcmd("say vips","cmd_vips")
	register_clcmd("say /vip","cmd_vips")
	register_clcmd("say vip","cmd_vips")
	register_clcmd("say_team /vips","cmd_vips")
	register_clcmd("say_team vips","cmd_vips")
	register_clcmd("say_team /vip","cmd_vips")
	register_clcmd("say_team vip","cmd_vips")
	
	maxplayers = get_maxplayers()
	gmsgSayText = get_user_msgid("SayText")
	#endif
	
	RegisterHam(Ham_Spawn, "player", "Spawn", 1)
	
	register_event( "CurWeapon", "event_CurWeapon", "be", "1=1" )
	
	RegisterHam(Ham_Item_PreFrame,"player","PreFrame_Post",1)
	
	RegisterHam ( Ham_TakeDamage, "player", "Player_TakeDamage" )
	
	register_forward(FM_EmitSound, "sound_emit")
	
	register_event("ResetHUD", "resetModel", "b")
	
	set_task(60.0, "ShowMessage", _, _, _, "b", 0)
	
}
public plugin_precache()
{
	precache_model("models/player/vip_skin/vip_skin.mdl")
	precache_model("models/player/smith/smith.mdl")
	
	precache_model(v_Battle)
	precache_model(p_Battle)
	
	for(new i = 0; i < MAX_KNIFE_SNDS; i++)
	precache_sound(remplace_sounds_knife[i])
	
	precache_sound(VIP_CONNECT)
	precache_sound(VIP_DISCONNECT)
}

public ShowMessage(id)
{
	new HOSTNAME[64]
	get_cvar_string("hostname",HOSTNAME,sizeof(HOSTNAME) -1)
	
	ColorChat(0,"!v[%s]!g Pentru a vedea!v vipi online!g scrie in chat!v /vips",HOSTNAME)
}

public client_connect(id)
{
	GiveSpeed[id] = false
	Nu_mai_ai_voie[id] = false
	NU_MAI_POTI_FOLOSI[id] = false
	BattleAxe[id] = false
	
	if(get_user_flags(id) & VIP_ACCES)
	{
		new name[32]
		get_user_name(id,name,31)
		
		ColorChat(0,"%s Vipu-l!v %s!g s-a conectat pe server!",Tag,name)
	}
}


public client_disconnect(id)
{
	GiveSpeed[id] = false
	Nu_mai_ai_voie[id] = false
	NU_MAI_POTI_FOLOSI[id] = false
	BattleAxe[id] = false
	
	if(get_user_flags(id) & VIP_ACCES)
	{
		new name[32]
		get_user_name(id,name,31)
		
		ColorChat(0,"%s Vipu-l!v %s!g s-a deconectat de pe server!",Tag,name)
	}
	
}
public Spawn(id)
{
	GiveSpeed[id] = false
	Nu_mai_ai_voie[id] = false
	NU_MAI_POTI_FOLOSI[id] = false
	BattleAxe[id] = false
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
	menu_additem(menu,"\r800 \wHP\r","1",0)
	menu_additem(menu,"\wViteza \r800","2",0)
	menu_additem(menu,"\wNoclip \r10 sec","3",0)
	menu_additem(menu,"\wRiffles\r","4",0)
	menu_additem(menu,"\wShield\r","5",0)
	menu_additem(menu,"\wMachine Gun\r","6",0)
	menu_additem(menu,"\wGrenade pack \r15","7",0)
	menu_additem(menu,"\wBattle Axe\r x5 Dmg","8",0)
	
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
			ColorChat(id,"%s Ai primit Speed 800",Tag)
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
		case 8:
		{
			if(BattleAxe[id] == true)
			{
				ColorChat(id,"%s Ai deja Battle Axe",Tag)
				return PLUGIN_HANDLED
			}
			
			give_item(id,"weapon_knife")
			BattleAxe[id] = true
			set_pev(id,pev_viewmodel2,v_Battle)
			set_pev(id,pev_weaponmodel2,p_Battle)
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
public event_CurWeapon(id)
{
	new Arma = read_data(2)
	
	if(BattleAxe[id] == true && Arma == CSW_KNIFE)
	{
		set_pev(id,pev_viewmodel2,v_Battle)
		set_pev(id,pev_weaponmodel2,p_Battle)
	}
}

public Player_TakeDamage( iVictim, iInflictor, iAttacker, Float:fDamage, iDamageBits )
{
	if(is_user_alive(iAttacker) && BattleAxe[iAttacker] == true)
	{
	if(iInflictor == iAttacker && get_user_weapon(iAttacker) == CSW_KNIFE)
	{
		SetHamParamFloat( 4, fDamage * 8);
		return HAM_HANDLED
	}
	}
	return HAM_HANDLED
}

public sound_emit(id, channel, sample[], Float:volume, Float:attenuation, fFlags, pitch)
{
	if(is_user_alive(id) && BattleAxe[id] == true)
	{
	if(equal(sample, original_sounds_knife[0]))
	{
	emit_sound(id,channel, remplace_sounds_knife[0], volume, attenuation, fFlags, pitch)
	return FMRES_SUPERCEDE
	}
	
	if(equal(sample, original_sounds_knife[1]))
	{
	emit_sound(id,channel, remplace_sounds_knife[1], volume, attenuation, fFlags, pitch)
	return FMRES_SUPERCEDE
	}
	
	if(equal(sample, original_sounds_knife[2]))
	{
	emit_sound(id,channel, remplace_sounds_knife[2], volume, attenuation, fFlags, pitch)
	return FMRES_SUPERCEDE
	}
	
	if(equal(sample, original_sounds_knife[3]))
	{
	emit_sound(id,channel, remplace_sounds_knife[3], volume, attenuation, fFlags, pitch)
	return FMRES_SUPERCEDE
	}
	
	if(equal(sample, original_sounds_knife[4]))
	{
	emit_sound(id,channel, remplace_sounds_knife[4], volume, attenuation, fFlags, pitch)
	return FMRES_SUPERCEDE
	}
	
	if(equal(sample, original_sounds_knife[5]))
	{
	emit_sound(id,channel, remplace_sounds_knife[5], volume, attenuation, fFlags, pitch)
	return FMRES_SUPERCEDE
	}
	
	if(equal(sample, original_sounds_knife[6]))
	{
	emit_sound(id,channel, remplace_sounds_knife[6], volume, attenuation, fFlags, pitch)
	return FMRES_SUPERCEDE
	}
	
	if(equal(sample, original_sounds_knife[7]))
	{
	emit_sound(id,channel, remplace_sounds_knife[7], volume, attenuation, fFlags, pitch)
	return FMRES_SUPERCEDE
	}
	
	if(equal(sample, original_sounds_knife[8]))
	{
	emit_sound(id,channel, remplace_sounds_knife[8], volume, attenuation, fFlags, pitch)
	return FMRES_SUPERCEDE
	}
	}
	return PLUGIN_HANDLED
}

public clcmd_say(id)
{
	if(is_user_bot(id))
	return PLUGIN_CONTINUE
	
	static ArgChat[192]
	read_args(ArgChat,sizeof(ArgChat) -1)
	remove_quotes(ArgChat)
	
	if(equali(ArgChat,""))
	return PLUGIN_CONTINUE
	
	static Name[32]
	get_user_name(id,Name,sizeof(Name) -1)
	
	if(is_user_alive(id) && get_user_flags(id) && read_flags("t"))
	{
		switch(cs_get_user_team(id))
		{
			case CS_TEAM_CT:ColorChat(0,"!v[V.I.P] %s:!g %s",Name,ArgChat)
			case CS_TEAM_T:ColorChat(0,"!v[V.I.P] %s:!g %s",Name,ArgChat)
			case CS_TEAM_SPECTATOR:ColorChat(0,"!g(MORT)!e (Spectator)!v [V.I.P] %s:!g %s",Name,ArgChat)
		}
	}
	else if(!is_user_alive(id) && get_user_flags(id) && read_flags("t"))
	{
		switch(cs_get_user_team(id))
		{
			case CS_TEAM_CT:ColorChat(0,"!g%s!v [V.I.P] %s:!g %s",is_user_alive(id) ? "" : "(MORT)",Name,ArgChat)
			case CS_TEAM_T:ColorChat(0,"!g%s!v [V.I.P] %s:!g %s",is_user_alive(id) ? "" : "(MORT)",Name,ArgChat)
			case CS_TEAM_SPECTATOR:ColorChat(0,"!g(MORT)!e (Spectator)!v [V.I.P] %s:!g %s",Name,ArgChat)
		}
	}
	return PLUGIN_HANDLED_MAIN
}

public clcmd_sayteam(id)
{
	if(is_user_bot(id))
	return PLUGIN_CONTINUE
	
	static ArgChat[192]
	read_args(ArgChat,sizeof(ArgChat) -1)
	remove_quotes(ArgChat)
	
	if(equali(ArgChat,""))
	return PLUGIN_CONTINUE
	
	static Name[32]
	get_user_name(id,Name,sizeof(Name) -1)
	
	static iPlayers[32]
	static iNum
	
	get_players(iPlayers,iNum,"ch")
	
	if(!iNum)
	return PLUGIN_CONTINUE
	
	static Player,i
	
	if(is_user_alive(id) && get_user_flags(id) && read_flags("t"))
	{
		for( i = 0;i < iNum;i++)
		{
			Player = iPlayers[i]
			
			if(cs_get_user_team(id) == cs_get_user_team(Player))
			{
				switch(cs_get_user_team(id))
				{
					case CS_TEAM_CT:ColorChat(Player,"!v[V.I.P]!e (Counter-Terorist)!v %s:!g %s",Name,ArgChat)
					case CS_TEAM_T:ColorChat(Player,"!v[V.I.P]!e (Terorist)!v %s:!g %s",Name,ArgChat)
					case CS_TEAM_SPECTATOR:ColorChat(Player,"!g(MORT)!e (Spectator)!v [V.I.P]!v %s:!g %s",Name,ArgChat)
				}
			}
		}
	}
	else if(!is_user_alive(id) && get_user_flags(id) && read_flags("t"))
	{
		for ( i = 0;i < iNum;i++)
		{
			Player = iPlayers[i]
			
			if(cs_get_user_team(id) == cs_get_user_team(Player))
			{
				switch(cs_get_user_team(id))
				{
					case CS_TEAM_CT:ColorChat(Player,"!g %s!v [V.I.P]!e (Counter-Terorist)!v %s:!g %s",is_user_alive(id) ? "" : "(MORT)",Name,ArgChat)
					case CS_TEAM_T:ColorChat(Player,"!g %s!v [V.I.P]!e (Terorist)!v %s:!g %s",is_user_alive(id) ? "" : "(MORT)",Name,ArgChat)
					case CS_TEAM_SPECTATOR:ColorChat(Player,"!g (MORT)!e (Spectator)!v [V.I.P]!v %s:!g %s",Name,ArgChat)
				}
			}
		}
	}
	return PLUGIN_HANDLED_MAIN
}
#if defined SHOW_CHAT_VIPS
public cmd_vips(id)
{
	set_task(0.1,"Vips_print",id)
}
#endif

#if defined SHOW_CHAT_VIPS
public Vips_print(user)
{
	new vipsname[33][32]
	new message[256]
	new id, count, x, len
	
	for(id = 1 ; id <= maxplayers ; id++)
		if(is_user_connected(id))
			if(get_user_flags(id) &	VIP_ACCES)
					get_user_name(id, vipsname[count++], 31)
					
			len = format(message, 255, "%s Vips Online: ",COLOR)
			if(count > 0) {
				for(x = 0 ; x < count ; x++) {
					len += format(message[len], 255-len, "%s%s ", vipsname[x], x < (count-1) ? ", ":"")
					if(len > 96 ) {
						print_message(user, message)
						len = format(message, 255, "%s ",COLOR)
					}
				}
				print_message(user, message)
			}
			else {
				len += format(message[len], 255-len, "Nici un vip online.")
				print_message(user, message)
	}
}

print_message(id, msg[]) {
	message_begin(MSG_ONE, gmsgSayText, {0,0,0}, id)
	write_byte(id)
	write_string(msg)
	message_end()
}
#endif
	
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
