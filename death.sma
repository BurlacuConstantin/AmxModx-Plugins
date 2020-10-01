#include <amxmodx>
#include <cstrike>

new sprite

public plugin_init()
{
	register_plugin("ZM - Death Effect","0.1","bbb")
	
	register_event("DeathMsg","EventDeathMsg", "a" )
}

public plugin_precache()
{
	sprite = precache_model("sprites/show_dead.spr")
}

public EventDeathMsg()
{
	new killer = read_data(1)
	new id = read_data(2)
	
	if(id != killer && cs_get_user_team(id) == CS_TEAM_T)
	{
		new origin[3]
		get_user_origin(id,origin)
		
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY,origin,id)
		write_byte(TE_EXPLOSION)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2])
		write_short(sprite)
		write_byte(10)
		write_byte(5)
		write_byte(TE_EXPLFLAG_NOSOUND)
		message_end()
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
