#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <engine>
#include <hamsandwich>

#define PLUGIN "WayPoint NPC Test"
#define VERSION "0.1"
#define AUTHOR "AsuStar"

#pragma tabsize 0

#define ZM_CLASSNAME "waypoint_npc"

new g_zombie_model[] = "models/player/zombie_test.mdl"

new g_beam,id

public plugin_init()
{
	register_plugin(PLUGIN,VERSION,AUTHOR)
	
	
	register_clcmd("say /make","cmd_make")
	
	register_think(ZM_CLASSNAME, "fw_zm_think")
	
}

public plugin_precache()
{
	precache_model(g_zombie_model)
	
	g_beam = precache_model("sprites/zbeam2.spr")
}

public cmd_make(id)
{
	Create_Npc(id)
}

Create_Npc(id, Float:flOrigin[3]= { 0.0, 0.0, 0.0 }, Float:flAngle[3]= { 0.0, 0.0, 0.0 } )
{
	//Create an entity using type 'info_target'
	new ent = create_entity("info_target")
	
	//Set our entity to have a classname so we can filter it out later
	entity_set_string(ent, EV_SZ_classname, ZM_CLASSNAME)
		
	//If a player called this function
	if(id)
	{
		//Retrieve the player's origin
		entity_get_vector(id, EV_VEC_origin, flOrigin)
		//Set the origin of the NPC to the current players location
		entity_set_origin(ent, flOrigin);
		//Increase the Z-Axis by 80 and set our player to that location so they won't be stuck
		flOrigin[2] += 80.0;
		entity_set_origin(id, flOrigin);
		
		//Retrieve the player's  angle
		entity_get_vector(id, EV_VEC_angles, flAngle)
		//Make sure the pitch is zeroed out
		flAngle[0] = 0.0
		//Set our NPC angle based on the player's angle
		entity_set_vector(ent, EV_VEC_angles, flAngle)
	}
	//If we are reading from a file
	else 
	{
		//Set the origin and angle based on the values of the parameters
		entity_set_origin(ent, flOrigin)
		entity_set_vector(ent, EV_VEC_angles, flAngle)
	}

	if(!pev_valid(ent))
	return HAM_HANDLED
	
	entity_set_float(ent, EV_FL_takedamage, 1.0)
	
	entity_set_float(ent,EV_FL_maxspeed, 250.0)
	
	entity_set_float(ent, EV_FL_health, 100.0)
    
	entity_set_string(ent, EV_SZ_classname, ZM_CLASSNAME)
	entity_set_model(ent, g_zombie_model)
	entity_set_int(ent, EV_INT_solid, 2)
    
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_PUSHSTEP)
	

	entity_set_float(ent, EV_FL_animtime, get_gametime())
	entity_set_float(ent, EV_FL_framerate, 1.0)
	entity_set_float(ent, EV_FL_gravity, 1.0)

    
	entity_set_byte(ent, EV_BYTE_controller1, 125)
	entity_set_byte(ent, EV_BYTE_controller2, 125)
	entity_set_byte(ent, EV_BYTE_controller3, 125)
	entity_set_byte(ent, EV_BYTE_controller4, 125)
    
	new Float:maxs[3] = {16.0, 16.0, 36.0}
	new Float:mins[3] = {-16.0, -16.0, -36.0}
	entity_set_size(ent, mins, maxs)
    
	Util_PlayAnimation(ent,1, 1.0)
    
	entity_set_float(ent,EV_FL_nextthink, halflife_time() + 0.5)
	drop_to_floor(ent)
}

public fw_zm_think(ent)
{
	if(!is_valid_ent(ent))
	return FMRES_IGNORED
	
	new Float:EntOrigin[3],VictimOrigin[3]
	
	pev(ent,pev_origin,EntOrigin)
	
	 for( new i = 1;i <= get_maxplayers();i++)
	{
		if(is_valid_ent(i) && is_user_alive(i))
		{
			pev(i,pev_origin,VictimOrigin)
			
			id = i
		}
	}
	
	//hook_to_origin(ent,VictimOrigin)
	
	if(ent_in_view(ent,id) == 1)
	{
		message_begin(MSG_ALL,SVC_TEMPENTITY)
		write_byte(TE_BEAMPOINTS)
		engfunc(EngFunc_WriteCoord,EntOrigin[0])
		engfunc(EngFunc_WriteCoord,EntOrigin[1])
		engfunc(EngFunc_WriteCoord,EntOrigin[2])
		engfunc(EngFunc_WriteCoord,VictimOrigin[0])
		engfunc(EngFunc_WriteCoord,VictimOrigin[1])
		engfunc(EngFunc_WriteCoord,VictimOrigin[2])
		write_short(g_beam)
		write_byte(1)	// starting frame
		write_byte(1)	// frame rate in 0.1's
		write_byte(5)	// life in 0.1's
		write_byte(20)	// line width in 0.1's
		write_byte(0)	// noise amplitude in 0.01's
		write_byte(0)	// Red
		write_byte(255)	// Green
		write_byte(0)	// Blue
		write_byte(255)	// brightness
		write_byte(0)	// scroll speed in 0.1's
		message_end()
	}
	
	entity_set_float(ent,EV_FL_nextthink, halflife_time() + 0.010)
}

stock hook_to_origin(ent,Float:Origin[3])
{
	new Float:Eorigin[3],Velocity[3]
	
	pev(ent,pev_origin,Eorigin)
	
	new Float:distance_f = get_distance_f(Eorigin,Origin)
	
	if(distance_f > 60.0)
	{
		 new Float:fl_Time = distance_f / 200.0
		 
		 Velocity[0] = (Origin[0] - Eorigin[0]) / fl_Time
		 Velocity[1] = (Origin[1] - Eorigin[1]) / fl_Time
		 Velocity[2] = (Origin[2] - Eorigin[2]) / fl_Time
	}
	
	entity_set_vector(ent,EV_VEC_velocity, Velocity)
	Util_PlayAnimation(ent, 4, 1.0)
}

/*
public Check_WayPoints(ent)
{	
	new EntOrigin[3],VictimOrigin[3]
	
	pev(ent,pev_origin,EntOrigin)
	
	 for( new i = 1;i <= get_maxplayers();i++)
	{
		if(is_valid_ent(i) && is_user_alive(i))
		{
			pev(i,pev_origin,VictimOrigin)
		}
	}
	
	message_begin(MSG_ALL,SVC_TEMPENTITY)
	write_byte(TE_BEAMPOINTS)
	engfunc(EngFunc_WriteCoord,EntOrigin[0])
	engfunc(EngFunc_WriteCoord,EntOrigin[1])
	engfunc(EngFunc_WriteCoord,EntOrigin[2])
	engfunc(EngFunc_WriteCoord,VictimOrigin[0])
	engfunc(EngFunc_WriteCoord,VictimOrigin[1])
	engfunc(EngFunc_WriteCoord,VictimOrigin[2])
	write_short(g_beam)
	write_byte(1)	// starting frame
	write_byte(1)	// frame rate in 0.1's
	write_byte(5)	// life in 0.1's
	write_byte(20)	// line width in 0.1's
	write_byte(0)	// noise amplitude in 0.01's
	write_byte(0)	// Red
	write_byte(255)	// Green
	write_byte(0)	// Blue
	write_byte(255)	// brightness
	write_byte(0)	// scroll speed in 0.1's
	message_end()
	
}
*/


stock ent_in_view( iStartEnt, iEndEnt )
{
    new Float:fStartOrigin[3]
    entity_get_vector( iStartEnt, EV_VEC_origin, fStartOrigin )

    new Float:fEndOrigin[3]
    entity_get_vector( iEndEnt, EV_VEC_origin, fEndOrigin )

    new Float:vReturn[3]
    new iHitEnt = trace_line( iStartEnt, fStartOrigin, fEndOrigin, vReturn )

    // Check if Obstruction Hit is an Ent

    while ( iHitEnt > 0 )
    {
        if ( iHitEnt == iEndEnt )
            return ( 1 )

        entity_get_vector( iHitEnt, EV_VEC_origin, fStartOrigin )
        iHitEnt = trace_line( iHitEnt, fStartOrigin, fEndOrigin, vReturn )	
    }

    // Check if Return / End Origin are the same

    if ( !vector_distance( vReturn, fEndOrigin ) )
        return ( 1 )

    return ( 0 )
}













stock Util_PlayAnimation(index, sequence, Float: framerate = 1.0)
{
	entity_set_float(index, EV_FL_animtime, get_gametime())
	entity_set_float(index, EV_FL_framerate,  framerate)
	entity_set_float(index, EV_FL_frame, 0.0)
	entity_set_int(index, EV_INT_sequence, sequence)
} 

stock DirectedVec(Float:start[3],Float:end[3],Float:reOri[3])
{
    new Float:v3[3]
    v3[0]=start[0]-end[0]
    v3[1]=start[1]-end[1]
    v3[2]=start[2]-end[2]
    new Float:vl = vector_length(v3)
    reOri[0] = v3[0] / vl
    reOri[1] = v3[1] / vl
    reOri[2] = v3[2] / vl
}


/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
