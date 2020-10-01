
#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <engine>
#include <hamsandwich>

#define PLUGIN "NPC Zombie"
#define VERSION "2.0"
#define AUTHOR "AsuStar"

#define ZB_CLASSNAME "npc_zombie"
#define TASK_ATTACK 323423

new const zombie_model[] = "models/player/tank_zombi_host/tank_zombi_host.mdl"

new bool:g_deadnpc[256]

new const zombie_hurt[][] =  
{ 
    "l4d/zombi_hurt_02.wav", 
    "l4d/zombi_hurt_01.wav" 
}

new const zombie_die[][] = 
{ 
    "l4d/zombi_die1.wav", 
    "l4d/zombi_die2.wav"
}

new const zombie_attack_sound[][] =
{
	"l4d/zombi_attack_1.wav",
	"l4d/zombi_attack_2.wav",
	"l4d/zombi_attack_3.wav"
}

new spr_blood_drop,spr_blood_spray
new pev_victim = pev_enemy

public plugin_init()
{
	register_plugin(PLUGIN,VERSION,AUTHOR)

	register_clcmd("npc","cmd_npc")
	
	register_think(ZB_CLASSNAME, "fw_zb_think")
	
	RegisterHam(Ham_Killed, "info_target", "fw_zb_killed")
	
	//register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")
}

public plugin_precache()
{
	precache_model(zombie_model)
	
	for(new i = 0;i < sizeof(zombie_die);i++)
	precache_sound(zombie_die[i])
	
	for(new i = 0;i < sizeof(zombie_hurt);i++)
	precache_sound(zombie_hurt[i])
	
	for(new i = 0;i < sizeof(zombie_attack_sound);i++)
	precache_sound(zombie_attack_sound[i])
	
	spr_blood_drop = precache_model("sprites/blood.spr")
	spr_blood_spray = precache_model("sprites/bloodspray.spr")
}


public plugin_cfg()
{
	Load_Npc()
}

public cmd_npc(id)
{
	if(get_user_flags(id) & ADMIN_IMMUNITY)
	{
		new menu = menu_create("NPC:Meniul Principal", "Menu_Handler")
		
		menu_additem(menu, "Creaza NPC", "1")
		menu_additem(menu, "Sterge NPC", "2")
		menu_additem(menu, "Salveaza locatia NPC-urilor", "3")
		menu_additem(menu, "Sterge toate NPC-urile", "4")
		
		menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
		
		menu_display(id, menu)
	}
	else
	{
		client_print(id,print_console,"[Left4dead]:Nu ai acces la aceasta comanda!")
		ColorChat(id,"!v[Left4dead]!g:Nu ai acces la aceasta comanda!")
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public Menu_Handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	
	new info[6], szName[64]
	new access, callback
	
	menu_item_getinfo(menu, item, access, info, charsmax(info), szName, charsmax(szName), callback);
	
	new key = str_to_num(info)
	
	switch(key)
	{
		case 1:
		{
			Create_Npc(id)
		}
		case 2:
		{
			new iEnt, body, szClassname[32]
			get_user_aiming(id, iEnt, body)
			
			if (is_valid_ent(iEnt)) 
			{
				entity_get_string(iEnt, EV_SZ_classname, szClassname, charsmax(szClassname));
				
				if (equal(szClassname,ZB_CLASSNAME)) 
				{
					remove_entity(iEnt)
				}
				
			}
		}
		case 3:
		{
			Save_Npc()
			
			ColorChat(id,"!v[Left4dead NPC]!g:Originile NPC-urilor au fost salvate cu succes!")
		}
		case 4:
		{
			remove_entity_name(ZB_CLASSNAME)
			
			ColorChat(id,"!v[Left4dead NPC]!g:Toate NPC-urile au fost sterse!")
		}
	}
	menu_display(id, menu)
	
	return PLUGIN_HANDLED
}

Create_Npc(id, Float:flOrigin[3]= { 0.0, 0.0, 0.0 }, Float:flAngle[3]= { 0.0, 0.0, 0.0 } )
{
	//Create an entity using type 'info_target'
	new ent = create_entity("info_target")
	
	//Set our entity to have a classname so we can filter it out later
	entity_set_string(ent, EV_SZ_classname, ZB_CLASSNAME)
		
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
    
	entity_set_string(ent, EV_SZ_classname, ZB_CLASSNAME)
	entity_set_model(ent, zombie_model)
	entity_set_int(ent, EV_INT_solid, 2)
    
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_PUSHSTEP)

	entity_set_float(ent, EV_FL_animtime, get_gametime())
	entity_set_float(ent, EV_FL_framerate, 1.0)
	entity_set_float(ent, EV_FL_gravity, 1.0)
    
	set_pev(ent, pev_victim, 0)
    
	entity_set_byte(ent, EV_BYTE_controller1, 125)
	entity_set_byte(ent, EV_BYTE_controller2, 125)
	entity_set_byte(ent, EV_BYTE_controller3, 125)
	entity_set_byte(ent, EV_BYTE_controller4, 125)
    
	new Float:maxs[3] = {16.0, 16.0, 36.0}
	new Float:mins[3] = {-16.0, -16.0, -36.0}
	entity_set_size(ent, mins, maxs)
    
	Util_PlayAnimation(ent,1, 1.0)
    
	entity_set_float(ent,EV_FL_nextthink, halflife_time() + 0.01)
	drop_to_floor(ent)
    
	RegisterHamFromEntity(Ham_TakeDamage, ent, "fw_zb_takedmg")
	//RegisterHamFromEntity(Ham_Killed, ent, "fw_zb_killed")
	RegisterHamFromEntity(Ham_TraceAttack,ent,"fw_zb_blood")
	
	g_deadnpc[ent] = false
    
	return 1
}

public fw_zb_blood(iEnt, attacker, Float: damage, Float: direction[3], trace, damageBits)
{
	new Float: end[3]
	get_tr2(trace, TR_vecEndPos, end);
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BLOODSPRITE)
	engfunc(EngFunc_WriteCoord, end[0])
	engfunc(EngFunc_WriteCoord, end[1])
	engfunc(EngFunc_WriteCoord, end[2])
	write_short(spr_blood_spray)
	write_short(spr_blood_drop)
	write_byte(247)
	write_byte(random_num(1, 5))
	message_end()
}

public fw_zb_takedmg(victim, inflictor, attacker, Float:damage, damagebits)
{
	emit_sound(victim, CHAN_VOICE, zombie_hurt[random(sizeof zombie_hurt)], VOL_NORM,ATTN_NORM, 0, PITCH_NORM)
}

public fw_zb_killed(ent)
{
	new className[32]
	entity_get_string(ent, EV_SZ_classname, className, charsmax(className))
	
	if(!equali(className, ZB_CLASSNAME))
		return HAM_IGNORED
		
	g_deadnpc[ent] = true
	
	remove_task(ent+TASK_ATTACK)
		
	Util_PlayAnimation(ent, 102, 1.0)	
		
	entity_set_int(ent, EV_INT_solid, SOLID_NOT)
	
	entity_set_float(ent, EV_FL_takedamage, 0.0)
	
	set_task(5.0, "remove_temp_zb", ent)
	
	return HAM_SUPERCEDE
}

public remove_temp_zb(ent)
{
    remove_entity(ent)
}

public fw_zb_think(ent)
{
    if(!is_valid_ent(ent))
     return FMRES_IGNORED
        
    new victim = FindClosesEnemy(ent)
    new Float:Origin[3], Float:VicOrigin[3], Float:distance
    
    pev(ent, pev_origin, Origin)
    pev(victim, pev_origin, VicOrigin)
    
    distance = get_distance_f(Origin, VicOrigin)

    if(g_deadnpc[ent] == true)
     return PLUGIN_HANDLED
    
    if(distance <= 60.0)
    {
        zombie_attack(ent, victim)
        entity_set_float(ent, EV_FL_nextthink, get_gametime() + 2.5)
    } else {
        
        if(pev(ent,pev_sequence) != 4)
            Util_PlayAnimation(ent, 4, 1.0)
            
        new Float:Ent_Origin[3], Float:Vic_Origin[3]
        
        pev(ent, pev_origin, Ent_Origin)
        pev(victim, pev_origin, Vic_Origin)
        
        npc_turntotarget(ent, Ent_Origin, victim, Vic_Origin)
        hook_ent(ent, victim)
        
        entity_set_float(ent, EV_FL_nextthink, get_gametime() + 0.1)
    }
    
    return FMRES_HANDLED
}

public zombie_attack(ent, victim)
{
    new Float:Ent_Origin[3], Float:Vic_Origin[3]
    
    pev(ent, pev_origin, Ent_Origin)
    pev(victim, pev_origin, Vic_Origin)
    
    npc_turntotarget(ent, Ent_Origin, victim, Vic_Origin)
    
    Util_PlayAnimation(ent, 76, 1.0)
    ExecuteHam(Ham_TakeDamage, victim, 0, victim, random_float(5.0, 10.0), DMG_BULLET)  
    emit_sound(ent, CHAN_VOICE,zombie_attack_sound[random(sizeof zombie_attack_sound)],  VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
    
    remove_task(ent+TASK_ATTACK)
    set_task(1.0, "stop_attack", ent+TASK_ATTACK)
}

public stop_attack(ent)
{
    ent -= TASK_ATTACK
    
    Util_PlayAnimation(ent,1,1.0)

    remove_task(ent+TASK_ATTACK)
}

Load_Npc()
{
	//Get the correct filepath and mapname
	new szConfigDir[256], szFile[256], szNpcDir[256];
	
	get_configsdir(szConfigDir, charsmax(szConfigDir));
	
	new szMapName[32];
	get_mapname(szMapName, charsmax(szMapName));
	
	formatex(szNpcDir, charsmax(szNpcDir),"%s/Left4dead_Npc", szConfigDir);
	formatex(szFile, charsmax(szFile),  "%s/%s.cfg", szNpcDir, szMapName);
		
	//If the filepath does not exist then we will make one
	if(!dir_exists(szNpcDir))
	{
		mkdir(szNpcDir);
	}
	
	//If the map config file does not exist we will make one
	if(!file_exists(szFile))
	{
		write_file(szFile, "");
	}
	
	//Variables to store when reading our file
	new szFileOrigin[3][32]
	new sOrigin[128], sAngle[128];
	new Float:fOrigin[3], Float:fAngles[3];
	new iLine, iLength, sBuffer[256];
	
	//When we are reading our file...
	while(read_file(szFile, iLine++, sBuffer, charsmax(sBuffer), iLength))
	{
		//Move to next line if the line is commented
		if((sBuffer[0]== ';') || !iLength)
			continue;
		
		//Split our line so we have origin and angle. The split is the vertical bar character
		strtok(sBuffer, sOrigin, charsmax(sOrigin), sAngle, charsmax(sAngle), '|', 0);
				
		//Store the X, Y and Z axis to our variables made earlier
		parse(sOrigin, szFileOrigin[0], charsmax(szFileOrigin[]), szFileOrigin[1], charsmax(szFileOrigin[]), szFileOrigin[2], charsmax(szFileOrigin[]));
		
		fOrigin[0] = str_to_float(szFileOrigin[0]);
		fOrigin[1] = str_to_float(szFileOrigin[1]);
		fOrigin[2] = str_to_float(szFileOrigin[2]);
				
		//Store the yawn angle
		fAngles[1] = str_to_float(sAngle[1]);
		
		//Create our NPC
		Create_Npc(0, fOrigin, fAngles)
		
		//Keep reading the file until the end
	}
}

public Save_Npc()
{
	//Variables
	new szConfigsDir[256], szFile[256], szNpcDir[256];
	
	//Get the configs directory.
	get_configsdir(szConfigsDir, charsmax(szConfigsDir));
	
	//Get the current map name
	new szMapName[32];
	get_mapname(szMapName, charsmax(szMapName));
	
	//Format 'szNpcDir' to ../configs/NPC
	formatex(szNpcDir, charsmax(szNpcDir),"%s/Left4dead_Npc", szConfigsDir);
	//Format 'szFile to ../configs/NPC/mapname.cfg
	formatex(szFile, charsmax(szFile), "%s/%s.cfg", szNpcDir, szMapName);
		
	//If there is already a .cfg for the current map. Delete it
	if(file_exists(szFile))
		delete_file(szFile);
	
	//Variables
	new iEnt = -1, Float:fEntOrigin[3], Float:fEntAngles[3];
	new sBuffer[256];
	
	//Scan and find all of my custom ents
	while( ( iEnt = find_ent_by_class(iEnt, ZB_CLASSNAME) ) )
	{
		//Get the entities' origin and angle
		entity_get_vector(iEnt, EV_VEC_origin, fEntOrigin);
		entity_get_vector(iEnt, EV_VEC_angles, fEntAngles);
		
		//Format the line of one custom ent.
		formatex(sBuffer, charsmax(sBuffer), "%d %d %d | %d", floatround(fEntOrigin[0]), floatround(fEntOrigin[1]), floatround(fEntOrigin[2]), floatround(fEntAngles[1]));
		
		//Finally write to the mapname.cfg file and move on to the next line
		write_file(szFile, sBuffer, -1);
		
		//We are currentlying looping to find all custom ents on the map. If found another ent. Do the above till there is none.
	}
	
}

public npc_turntotarget(ent, Float:Ent_Origin[3], target, Float:Vic_Origin[3]) 
{
    if(target) 
    {
        new Float:newAngle[3]
        entity_get_vector(ent, EV_VEC_angles, newAngle)
        new Float:x = Vic_Origin[0] - Ent_Origin[0]
        new Float:z = Vic_Origin[1] - Ent_Origin[1]

        new Float:radians = floatatan(z/x, radian)
        newAngle[1] = radians * (180 / 3.14)
        if (Vic_Origin[0] < Ent_Origin[0])
            newAngle[1] -= 180.0
        
        entity_set_vector(ent, EV_VEC_angles, newAngle)
    }
}

public hook_ent(ent, victim)
{
    new Float:fl_Velocity[3]
    new Float:VicOrigin[3], Float:EntOrigin[3]

    pev(ent, pev_origin, EntOrigin)
    pev(victim, pev_origin, VicOrigin)
    
    new Float:distance_f = get_distance_f(EntOrigin, VicOrigin)

    if (distance_f > 60.0)
    {
        new Float:fl_Time = distance_f / 100.0

        fl_Velocity[0] = (VicOrigin[0] - EntOrigin[0]) / fl_Time
        fl_Velocity[1] = (VicOrigin[1] - EntOrigin[1]) / fl_Time
        fl_Velocity[2] = (VicOrigin[2] - EntOrigin[2]) / fl_Time
    } else
    {
        fl_Velocity[0] = 0.0
        fl_Velocity[1] = 0.0
        fl_Velocity[2] = 0.0
    }

    entity_set_vector(ent, EV_VEC_velocity, fl_Velocity)
}

stock bool:IsValidTarget(iTarget)
{
    if (!iTarget || !(1<= iTarget <= get_maxplayers()) || !is_user_connected(iTarget) || !is_user_alive(iTarget))
        return false
    return true
}

public FindClosesEnemy(entid)
{
    new Float:Dist
    new Float:maxdistance=4000.0
    new indexid=0    
    for(new i=1;i<=get_maxplayers();i++){
        if(is_user_alive(i) && is_valid_ent(i) && can_see_fm(entid, i))
        {
            Dist = entity_range(entid, i)
            if(Dist <= maxdistance)
            {
                maxdistance=Dist
                indexid=i
                
                return indexid
            }
        }    
    }    
    return 0
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
