#include <amxmodx>
#include <fakemeta>
#include <engine>
#include <hamsandwich>
#include <dhudmessage>

#define PLUGIN  "CSGO DEATH CAM"
#define VERSION "1.0"
#define AUTHOR  "Sugisaki"

#define CLASS 	"ent_camara"

#define CAMERA_MODEL 	"models/arcticorangeT.mdl"
#define CAMERA_MINS Float: { -10.0, -10.0, 0.0 }
#define CAMERA_MAXS Float: { 10.0, 10.0, 25.0 }
#define CAMERA_KILL_SOUND "csgo/death_cam.wav"

new killer[33]
new las_obs[33]

new Float:g_freeze_origin[33][33][3]
new g_freeze_sequence[33][33]
new g_freeze_frame[33][33]
new g_freeze_framerate[33][33]
new Float:g_freeze_angles[33][33][3]
new g_freeze_gaitsequence[33][33]
new g_freeze_weaponmodel[33][33]

new bool:g_bfreeze[33]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_think(CLASS, "pfn_camera_think")
	register_event("DeathMsg", "pfn_death", "a")
	register_forward(FM_AddToFullPack, "AddToFullPack", 1)
	register_event("TextMsg", "pfn_unfreeze", "b", "2&#Spec_Mode")
	RegisterHam(Ham_Spawn, "player", "OnSpawnPlayer", 1)
	register_touch("player", CLASS, "OnTouchCamera")
	//register_forward(FM_EmitSound, "fw_EmitSound")
}
public plugin_precache()
{
	precache_model(CAMERA_MODEL)
	precache_sound(CAMERA_KILL_SOUND)
}

pfn_SpawnCamera(id, target)
{
	if(!is_user_connected(target))
		return

	freeze_map(id)
	new ent = create_entity("info_target")

	if(!is_valid_ent(ent))
	{
		//client_print(id, print_chat, "Error create entity")
		return
	}
	new Float:origin[3], Float:angles[3], Float:o2[3]
	entity_get_vector(target, EV_VEC_origin, o2)
	entity_get_vector(id, EV_VEC_origin, origin)
	//entity_get_vector(id, EV_VEC_v_angle, angles)
	//angles[0] = angles[0] * -1.0
	entity_set_model(ent, CAMERA_MODEL)
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_NOCLIP)
	entity_set_string(ent, EV_SZ_classname, CLASS)
	entity_set_int(ent, EV_INT_solid, SOLID_TRIGGER)
	entity_set_vector(ent, EV_VEC_origin, origin)
	entity_set_vector(ent, EV_VEC_angles, angles)
	entity_set_edict(ent, EV_ENT_owner, id)
	
	
	//set aim
	entity_set_aim(ent, o2)
	// set speed
	set_speed(ent, calculate_speed(id, target), o2)
	//
	attach_view(id, ent);
	entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.001)
	set_task(1.2, "pfn_remove_ent", id)

	//PERF1337
	new target_name[32]
	get_user_name(target, target_name, charsmax(target_name))
	set_dhudmessage(.red = 100, .green = 50, .blue = 0, .x = -1.0, .y = -1.0, .effects = 0, 
	.fxtime = 1.5, .holdtime = 1.1, .fadeintime = 0.1, .fadeouttime = 0.2)
	show_dhudmessage(id, "%s", target_name)
	//
}
public pfn_remove_ent(id)
{
	remove_task(id)
	
	new ent = find_ent_by_owner(-1, CLASS, id)
	
	if(is_valid_ent(ent))
	{
		remove_entity(ent)
		pfn_unfreeze(id)
	}
}
public pfn_camera_think(e)
{
	if(!is_valid_ent(e))
	{
		return;
	}

	if(get_entity_distance(e, killer[entity_get_edict(e, EV_ENT_owner)]) < 100)
	{
		entity_set_vector(e, EV_VEC_velocity, Float:{0.0,0.0,0.0})
	}
	entity_set_float(e, EV_FL_nextthink, halflife_time() + 0.001)
}
public pfn_test(id)
{
	new players[32], count
	get_players(players, count, "ae", "TERRORIST")
	new t = players[random(count)];
	ExecuteHam(Ham_TakeDamage, id, t, t, 101.0, DMG_BULLET);
}

public pfn_death()
{
	new k = read_data(1)
	new v = read_data(2)
	if(!k || (!is_user_connected(k) || v == k) && !can_see_fm(v, k))
		    		return

	killer[v] = k
	message_begin(MSG_ONE_UNRELIABLE, SVC_DIRECTOR, .player = v)
	write_byte(strlen( CAMERA_KILL_SOUND ) + 6) // command length in bytes; null termination + write_byte() + write_long() gives +6
	write_byte(DRC_CMD_SOUND)
	write_string(CAMERA_KILL_SOUND)
	write_long(VOL_NORM)    // float value or VOL_NORM (i.e. 1.0)
	message_end()
	
	set_task(0.1, "dead_post", v)
		
}
public dead_post(id)
{
	if(!is_user_connected(id) || is_user_bot(id))
		return 

	set_pev(id, pev_iuser1, 0) // OBS_NONE IS 0
	las_obs[id] = pev(id, pev_iuser1);
	pfn_SpawnCamera(id, killer[id])
}

public AddToFullPack(es, e, ent, host, hostflags, player, pSet)
{
	if(!player)
	{
		return
	}
	if(g_bfreeze[host])
	{
		set_es(es, ES_Angles, g_freeze_angles[host][ent])
		set_es(es, ES_Origin, g_freeze_origin[host][ent])
		set_es(es, ES_Sequence, g_freeze_sequence[host][ent])
		set_es(es, ES_Frame, g_freeze_framerate[host][ent])
		set_es(es, ES_FrameRate, g_freeze_framerate[host][ent])
		set_es(es, ES_GaitSequence, g_freeze_gaitsequence[host][ent])
		set_es(es, ES_WeaponModel, g_freeze_weaponmodel[host][ent])
	}
}

freeze_map(id)
{
	static szWM[60]
	for(new i = 1; i <= get_maxplayers() ; i++)
	{
		if(!is_user_connected(i))
		{
			continue;
		}
		entity_get_vector(i, EV_VEC_origin, g_freeze_origin[id][i])
		g_freeze_sequence[id][i] = entity_get_int(i, EV_INT_sequence)
		g_freeze_frame[id][i] = entity_get_int(id, EV_FL_frame)
		g_freeze_framerate[id][i] = entity_get_int(id, EV_FL_framerate)
		entity_get_vector(i, EV_VEC_angles, g_freeze_angles[id][i])
		g_freeze_gaitsequence[id][i] = entity_get_int(i, EV_INT_gaitsequence)
		entity_get_string(i, EV_SZ_weaponmodel, szWM, charsmax(szWM))
		g_freeze_weaponmodel[id][i] = engfunc(EngFunc_ModelIndex, szWM);
	}
	g_bfreeze[id] = true
}
public pfn_unfreeze(id)
{
	g_bfreeze[id] = false
	attach_view(id, id)
}
public client_putinserver(id)
{
	g_bfreeze[id] = false
}
public OnSpawnPlayer(id)
{
	if(!is_user_alive(id))
	{
		return
	}
	pfn_unfreeze(id)
}
stock Float:calculate_speed(u1, u2)
{
	return (float(get_entity_distance(u1, u2)) / 0.3)

}
public OnTouchCamera(ted, ter)
{
	new id = pev(ter, pev_owner)
	if(ted == killer[id])
	{
		entity_set_vector(ter, EV_VEC_velocity, Float:{0.0,0.0,0.0})
	}
}


// CHR ENGINE
stock entity_set_aim(ent,const Float:origin2[3],bone=0)
{
	if(!pev_valid(ent))
		return 0;

	static Float:origin[3]
	origin[0] = origin2[0]
	origin[1] = origin2[1]
	origin[2] = origin2[2]

	static Float:ent_origin[3], Float:angles[3]

	if(bone)
		engfunc(EngFunc_GetBonePosition,ent,bone,ent_origin,angles)
	else
		pev(ent,pev_origin,ent_origin)

	origin[0] -= ent_origin[0]
	origin[1] -= ent_origin[1]
	origin[2] -= ent_origin[2]

	static Float:v_length
	v_length = vector_length(origin)

	static Float:aim_vector[3]
	aim_vector[0] = origin[0] / v_length
	aim_vector[1] = origin[1] / v_length
	aim_vector[2] = origin[2] / v_length

	static Float:new_angles[3]
	vector_to_angle(aim_vector,new_angles)

	new_angles[0] *= -1

	if(new_angles[1]>180.0) new_angles[1] -= 360
	if(new_angles[1]<-180.0) new_angles[1] += 360
	if(new_angles[1]==180.0 || new_angles[1]==-180.0) new_angles[1]=-179.999999

	set_pev(ent,pev_angles,new_angles)
	set_pev(ent,pev_fixangle,1)

	return 1;
}
set_speed(ent, Float:speed, Float:origin[3])
{
	static Float:origin1[3]
	pev(ent,pev_origin,origin1)

	static Float:new_velo[3]

	new_velo[0] = origin[0] - origin1[0]
	new_velo[1] = origin[1] - origin1[1]
	new_velo[2] = origin[2] - origin1[2]

	new Float:y
	y = new_velo[0]*new_velo[0] + new_velo[1]*new_velo[1] + new_velo[2]*new_velo[2]

	new Float:x
	if(y) x = floatsqroot(speed*speed / y)

	new_velo[0] *= x
	new_velo[1] *= x
	new_velo[2] *= x

	if(speed<0.0)
	{
		new_velo[0] *= -1
		new_velo[1] *= -1
		new_velo[2] *= -1
	}

	set_pev(ent,pev_velocity,new_velo)
}

public bool:can_see_fm(entindex1, entindex2)
{
    if (!entindex1 || !entindex2)
        return false

    if (pev_valid(entindex1) && pev_valid(entindex1))
    {
        new flags = pev(entindex1, pev_flags)
        if (flags & EF_NODRAW || flags & FL_NOTARGET)
        {
            return false
        }

        new Float:lookerOrig[3]
        new Float:targetBaseOrig[3]
        new Float:targetOrig[3]
        new Float:temp[3]

        pev(entindex1, pev_origin, lookerOrig)
        pev(entindex1, pev_view_ofs, temp)
        lookerOrig[0] += temp[0]
        lookerOrig[1] += temp[1]
        lookerOrig[2] += temp[2]

        pev(entindex2, pev_origin, targetBaseOrig)
        pev(entindex2, pev_view_ofs, temp)
        targetOrig[0] = targetBaseOrig [0] + temp[0]
        targetOrig[1] = targetBaseOrig [1] + temp[1]
        targetOrig[2] = targetBaseOrig [2] + temp[2]

        engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0) //  checks the had of seen player
        if (get_tr2(0, TraceResult:TR_InOpen) && get_tr2(0, TraceResult:TR_InWater))
        {
            return false
        } 
        else 
        {
            new Float:flFraction
            get_tr2(0, TraceResult:TR_flFraction, flFraction)
            if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
            {
                return true
            }
            else
            {
                targetOrig[0] = targetBaseOrig [0]
                targetOrig[1] = targetBaseOrig [1]
                targetOrig[2] = targetBaseOrig [2]
                engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0) //  checks the body of seen player
                get_tr2(0, TraceResult:TR_flFraction, flFraction)
                if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
                {
                    return true
                }
                else
                {
                    targetOrig[0] = targetBaseOrig [0]
                    targetOrig[1] = targetBaseOrig [1]
                    targetOrig[2] = targetBaseOrig [2] - 17.0
                    engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0) //  checks the legs of seen player
                    get_tr2(0, TraceResult:TR_flFraction, flFraction)
                    if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
                    {
                        return true
                    }
                }
            }
        }
    }
    return false
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1048\\ f0\\ fs16 \n\\ par }
*/
