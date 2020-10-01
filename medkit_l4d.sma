#include <amxmodx>
#include <fun>
#include <fakemeta_util>
#include <fakemeta>
#include <hamsandwich>
#include <engine>

#define new_classname "medickit"

new health_count[33]

new const v_model[] = "models/l4d/v_medkit.mdl"
new const p_model[] = "models/l4d/p_medkit.mdl"
new const w_model[] = "models/l4d/w_medkit.mdl"
new const healting[] = "l4d/healing.wav"

public plugin_init()
{
	register_clcmd("say /c4","cmd_c4")
	
	register_touch(new_classname, "player", "touch_medkit")
	register_event("DeathMsg", "Death", "a")
	register_event("CurWeapon","CurrentWeapon","be","1=1")
	register_clcmd("drop","drop_medkit")
}

public plugin_precache()
{
	precache_model(v_model)
	precache_model(p_model)
	precache_model(w_model)
	precache_sound(healting)
}

public cmd_c4(id)
{
	give_item(id,"weapon_c4")
}

public CurrentWeapon(id)
{
	if(!is_user_alive(id))
	return PLUGIN_CONTINUE
	
	new weapon = get_user_weapon(id)
	
	if(weapon == CSW_C4)
	{
		set_pev(id,pev_viewmodel2,v_model)
		set_pev(id,pev_weaponmodel2,p_model)
	}
	
	return PLUGIN_HANDLED
}

public drop_medkit(id)
{
	new weapon = get_user_weapon(id)
	
	if(weapon == CSW_C4)
	{
	fm_strip_user_gun(id,CSW_C4)
	
	
	new Float:fVelocity[3], Float:fOrigin[3]
	entity_get_vector(id,EV_VEC_origin,fOrigin)
	VelocityByAim(id,34,fVelocity)
	
	fOrigin[0] += fVelocity[0]
	fOrigin[1] += fVelocity[1]
	
	VelocityByAim(id, 300, fVelocity)
	
	new ent = create_entity("info_target")
	entity_set_string(ent,EV_SZ_classname,new_classname)
	entity_set_model(ent,w_model)
	entity_set_int(ent,EV_INT_movetype, MOVETYPE_TOSS)
	entity_set_int(ent,EV_INT_solid, SOLID_TRIGGER)
	entity_set_vector(ent,EV_VEC_origin, fOrigin)
	entity_set_vector(ent,EV_VEC_velocity, fVelocity)
	entity_set_float(ent,EV_FL_nextthink, halflife_time() + 0.01)
	}
	return PLUGIN_HANDLED
}

public Death()
{
	new id = read_data(2)
	
	new Float:fVelocity[3], Float:fOrigin[3]
	entity_get_vector(id,EV_VEC_origin, fOrigin)
	VelocityByAim(id,34,fVelocity)
	
	fOrigin[0] += fVelocity[0]
	fOrigin[1] += fVelocity[1]

	VelocityByAim(id, 300, fVelocity)
	
	new ent = create_entity("info_target")
	entity_set_string(ent,EV_SZ_classname,new_classname)
	entity_set_model(ent,w_model)
	entity_set_int(ent,EV_INT_movetype, MOVETYPE_TOSS)
	entity_set_int(ent,EV_INT_solid, SOLID_TRIGGER)
	entity_set_vector(ent,EV_VEC_origin, fOrigin)
	entity_set_vector(ent,EV_VEC_velocity, fVelocity)
	entity_set_float(ent,EV_FL_nextthink, halflife_time() + 0.01)
}

public touch_medkit(ent,id)
{
	give_item(id,"weapon_c4")
	remove_entity(ent)
}

public client_PreThink(id)
{
	new weapon = get_user_weapon(id)
	
	if(weapon == CSW_C4)
	{
		if(get_user_button(id) & IN_ATTACK && get_user_oldbutton(id) & IN_ATTACK)
		{
			if(health_count[id] == 1)
				return
	
			health_count[id]++
			emit_sound(id,CHAN_WEAPON,healting,1.0,ATTN_NORM,0,PITCH_NORM)
			set_user_maxspeed(id,1.0)
			MsgBarTime(id,2)
			set_task(3.0,"Give_Health",id)
		}
	}
}

public Give_Health(id)
{
	
	set_user_maxspeed(id,250.0)
	ham_strip_weapon(id,"weapon_c4")
	set_user_health(id,get_user_health(id) + 50)
	set_task(2.0,"Reset_Variable",id)
}

public Reset_Variable(id)
{
	health_count[id] = 0
}

stock ham_strip_weapon(id,weapon[])
{
    if(!equal(weapon,"weapon_",7)) return 0;

    new wId = get_weaponid(weapon);
    if(!wId) return 0;

    new wEnt;
    while((wEnt = engfunc(EngFunc_FindEntityByString,wEnt,"classname",weapon)) && pev(wEnt,pev_owner) != id) {}
    if(!wEnt) return 0;

    if(get_user_weapon(id) == wId) ExecuteHamB(Ham_Weapon_RetireWeapon,wEnt);

    if(!ExecuteHamB(Ham_RemovePlayerItem,id,wEnt)) return 0;
    ExecuteHamB(Ham_Item_Kill,wEnt);

    set_pev(id,pev_weapons,pev(id,pev_weapons) & ~(1<<wId));

    // this block should be used for Counter-Strike:
    /*if(wId == CSW_C4)
    {
        cs_set_user_plant(id,0,0);
        cs_set_user_bpammo(id,CSW_C4,0);
    }
    else if(wId == CSW_SMOKEGRENADE || wId == CSW_FLASHBANG || wId == CSW_HEGRENADE)
        cs_set_user_bpammo(id,wId,0);*/

    return 1;
}

stock MsgBarTime(id,iBarScale) 
{
	message_begin(MSG_ONE,get_user_msgid("BarTime"),_,id)
	write_short(iBarScale)
	message_end()
}
	
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
