#include < amxmodx >
#include < engine >
#include < fakemeta >
 
 
new const
        PLUGIN_NAME     [ ] = "Thunder on C4",
        PLUGIN_VERSION  [ ] = "0.0.1",
        PLUGIN_AUTHOR   [ ] = "CryWolf";
 
 
// Create your own thunder ?
new const thunder_lights [ ] [ ] =
{
        "azazazazaz", "bcdefedcijklmlkjihgfedcb"
};
 
// Personal thunder sounds
new const sound_thunder [ ] [ ] =
{
        "de_torn/torn_thndrstrike.wav" , "ambience/thunder_clap.wav"
};
 
#define SOUND_MAX_LENGTH 64
#define LIGHTS_MAX_LENGTH 32
 
new Array:g_thunder_lights;
new Array:g_sound_thunder;
 
#define TASK_THUNDER    100
#define TASK_THUNDER_LIGHTS 200
#define TASKID1         1324687358
 
new g_ThunderLightIndex, g_ThunderLightMaxLen;
new g_ThunderLight [ LIGHTS_MAX_LENGTH ];
 
new cvar_lighting, cvar_thunder_time;
new cvar_triggered_lights;
new cvar_thunder;
 
 
public plugin_precache ( )
{
        g_thunder_lights = ArrayCreate(LIGHTS_MAX_LENGTH, 1);
        g_sound_thunder = ArrayCreate(SOUND_MAX_LENGTH, 1);
       
        new index;
        if (ArraySize(g_thunder_lights) == 0)
        {
                for (index = 0; index < sizeof thunder_lights; index++)
                        ArrayPushString(g_thunder_lights, thunder_lights[index]);
        }
        if (ArraySize(g_sound_thunder) == 0)
        {
                for (index = 0; index < sizeof sound_thunder; index++)
                        ArrayPushString(g_sound_thunder, sound_thunder[index]);
        }
       
        new sound[SOUND_MAX_LENGTH];
        for (index = 0; index < ArraySize(g_sound_thunder); index++)
        {
                ArrayGetString(g_sound_thunder, index, sound, charsmax(sound));
                precache_sound(sound);
        }
}
 
public plugin_init ( )
{
        register_plugin ( PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR );
       
        register_logevent ( "FunC_BmbPlanted", 3, "2=Planted_The_Bomb" );
        register_logevent ( "FunC_RoundEnd", 2, "1=Round_End" );
	register_event ( "HLTV", "round_start", "a", "1=0", "2=0" )
	register_event ( "TextMsg", "bomb_planted", "a", "2&%!MRAD_BOMBPL" )
       
        cvar_thunder            = register_cvar ( "amx_thunder", "1" );
       
        cvar_lighting           = register_cvar ( "amx_lighting", "f" );
        cvar_thunder_time       = register_cvar ( "amx_thunder_time", "5" );
        cvar_triggered_lights   = register_cvar ( "amx_triggered_lights", "1" );
       
        set_cvar_num ( "sv_skycolor_r", 0 );
        set_cvar_num ( "sv_skycolor_g", 0 );
        set_cvar_num ( "sv_skycolor_b", 0 );
}
public bomb_planted ( ) set_lights("a")
public plugin_cfg ( )
{
        server_cmd ( "mp_playerid 1" );
        FunC_RoundStart ( );
}

public round_start ( ) set_lights( "#OFF" )

public FunC_RoundStart ( )
{
	if (!get_pcvar_num(cvar_triggered_lights))
                set_task ( 0.1, "remove_lights" );
	
	if ( task_exists ( TASKID1 ) )
	{
		remove_task ( TASK_THUNDER_LIGHTS );
		remove_task ( TASK_THUNDER );
		remove_task ( TASKID1 );
	}
}
 
public FunC_BmbPlanted ( )
{
        if ( get_pcvar_num ( cvar_thunder ) ) {
                set_task ( 1.0, "lighting_task", TASKID1, _, _, "b", _ );
        }
}
 
public FunC_RoundEnd ( )
{
        if ( task_exists ( TASKID1 ) )
        {
                set_task ( 0.1, "remove_lights" );
               
                remove_task ( TASK_THUNDER_LIGHTS );
                remove_task ( TASK_THUNDER );
                remove_task ( TASKID1 );
        }
}
 
public lighting_task( )
{
        new lighting[2];
        get_pcvar_string(cvar_lighting, lighting, charsmax(lighting));
       
        if (get_pcvar_float(cvar_thunder_time) > 0.0 && !task_exists(TASK_THUNDER) && !task_exists(TASK_THUNDER_LIGHTS))
        {
                g_ThunderLightIndex = 0
                ArrayGetString(g_thunder_lights, random_num(0, ArraySize(g_thunder_lights) - 1), g_ThunderLight, charsmax(g_ThunderLight))
                g_ThunderLightMaxLen = strlen(g_ThunderLight)
                set_task(get_pcvar_float(cvar_thunder_time), "thunder_task", TASK_THUNDER)
        }
       
        if (!task_exists(TASK_THUNDER_LIGHTS))
                engfunc(EngFunc_LightStyle, 0, lighting)
}
 
// Thunder task
public thunder_task()
{
        if (g_ThunderLightIndex == 0)
        {      
                static sound[SOUND_MAX_LENGTH]
                ArrayGetString(g_sound_thunder, random_num(0, ArraySize(g_sound_thunder) - 1), sound, charsmax(sound))
                PlaySoundToClients(sound)
               
                set_task(0.1, "thunder_task", TASK_THUNDER_LIGHTS, _, _, "b")
        }
       
        new lighting[2]
        lighting[0] = g_ThunderLight[g_ThunderLightIndex]
        engfunc(EngFunc_LightStyle, 0, lighting)
       
        g_ThunderLightIndex++
       
        if (g_ThunderLightIndex >= g_ThunderLightMaxLen)
        {
                remove_task(TASK_THUNDER_LIGHTS)
                lighting_task()
        }
}
 
// Plays a sound on clients
PlaySoundToClients(const sound[])
{
        if (equal(sound[strlen(sound)-4], ".mp3"))
                client_cmd(0, "mp3 play ^"sound/%s^"", sound)
        else
                client_cmd(0, "spk ^"%s^"", sound)
}
 
public remove_lights()
{
       set_lights( "#OFF" );
}