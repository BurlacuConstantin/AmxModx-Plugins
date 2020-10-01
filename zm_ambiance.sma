#include <amxmodx>
#include <cstrike>
#include <fakemeta>

#define TIME_FOR_SOUNDS 15.0

new zombie_coming[13] []=
{
	"misc/zm_1.wav",
	"misc/zm_2.wav",
	"misc/zm_3.wav",
	"misc/z1.wav",
	"misc/z2.wav",
	"misc/z3.wav",
	"misc/z4.wav",
	"misc/z5.wav",
	"misc/z6.wav",
	"misc/z7.wav",
	"misc/z8.wav",
	"misc/z9.wav",
	"misc/z10.wav"
}

public plugin_init()
{
	register_plugin("Zombie Ambiance","0.2","bbb")
	
	register_event("HLTV","Play_Sounds","a","1=0","2=0")
	
	register_logevent( "Event_RoundEnd", 2, "1=Round_End" )
}

public plugin_precache()
{
	for(new i = 0;i < sizeof(zombie_coming);i++)
	engfunc(EngFunc_PrecacheSound,zombie_coming[i])
}	

public Play_Sounds()
{
	new Players[32],Num
	get_players(Players,Num)
	
	for(new i = 0;i < Num;i++)
	{
		for(new a = 0;a < sizeof(zombie_coming);a++)
		{
			set_task(TIME_FOR_SOUNDS,"play_zombie_sounds",Players[i],_, _, "b", _ )
		}
	}
	return PLUGIN_CONTINUE
}

public Event_RoundEnd()
{
	new iPlayers[32],iNum
	get_players(iPlayers,iNum)
	
	for(new i = 0;i < iNum;i++)
	{
		remove_task(iPlayers[i])
	}
	return PLUGIN_CONTINUE
}

public play_zombie_sounds(Players)
{
	if(is_user_alive(Players) && cs_get_user_team(Players) == CS_TEAM_T)
	{
	new id = Players
	
	new random = random_num(0,12)
	switch(random)
	{
		case 0:emit_sound(id, CHAN_ITEM,zombie_coming[0], 1.0, ATTN_NORM, 0, PITCH_NORM)
		case 1:emit_sound(id, CHAN_ITEM,zombie_coming[3], 1.0, ATTN_NORM, 0, PITCH_NORM)
		case 2:emit_sound(id, CHAN_ITEM,zombie_coming[1], 1.0, ATTN_NORM, 0, PITCH_NORM)
		case 3:emit_sound(id, CHAN_ITEM,zombie_coming[4], 1.0, ATTN_NORM, 0, PITCH_NORM)
		case 4:emit_sound(id, CHAN_ITEM,zombie_coming[2], 1.0, ATTN_NORM, 0, PITCH_NORM)
		case 5:emit_sound(id, CHAN_ITEM,zombie_coming[5], 1.0, ATTN_NORM, 0, PITCH_NORM)
		case 6:emit_sound(id, CHAN_ITEM,zombie_coming[6], 1.0, ATTN_NORM, 0, PITCH_NORM)
		case 7:emit_sound(id, CHAN_ITEM,zombie_coming[7], 1.0, ATTN_NORM, 0, PITCH_NORM)
		case 8:emit_sound(id, CHAN_ITEM,zombie_coming[8], 1.0, ATTN_NORM, 0, PITCH_NORM)
		case 9:emit_sound(id, CHAN_ITEM,zombie_coming[9], 1.0, ATTN_NORM, 0, PITCH_NORM)
		case 10:emit_sound(id, CHAN_ITEM,zombie_coming[10], 1.0, ATTN_NORM, 0, PITCH_NORM)
		case 11:emit_sound(id, CHAN_ITEM,zombie_coming[11], 1.0, ATTN_NORM, 0, PITCH_NORM)
		case 12:emit_sound(id, CHAN_ITEM,zombie_coming[12], 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	}
}
		
	
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1048\\ f0\\ fs16 \n\\ par }
*/
