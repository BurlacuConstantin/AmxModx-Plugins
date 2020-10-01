#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
	new const VERSION[] = "1.1.1"
	const MAX_ENTSARRAYS_SIZE = 64
	new g_bitGonnaExplode[MAX_ENTSARRAYS_SIZE]
#define SetGrenadeExplode(%1)        g_bitGonnaExplode[%1>>5] |=  1<<(%1 & 31)
#define ClearGrenadeExplode(%1)    g_bitGonnaExplode[%1>>5] &= ~( 1 << (%1 & 31) )
#define WillGrenadeExplode(%1)    g_bitGonnaExplode[%1>>5] &   1<<(%1 & 31)
	const XTRA_OFS_PLAYER = 5
const m_iTeam = 114
#define cs_get_user_team_index(%1)    get_pdata_int(%1, m_iTeam, XTRA_OFS_PLAYER)
	new Float:g_flCurrentGameTime, g_iCurrentFlasher, g_iCurrentFlashBang
	new mp_friendlyfire
	new g_iMaxPlayers
#define IsPlayer(%1)    ( 1 <= %1 <= g_iMaxPlayers )
	public plugin_init()
{
    register_plugin("Anti Flashbang Bug", VERSION, "Numb / ConnorMcLeod")
    
    RegisterHam(Ham_Think, "grenade", "Ham__CGrenade_Think__Pre")
    
    register_forward(FM_FindEntityInSphere, "Fm__FindEntityInSphere__Pre")
	    mp_friendlyfire = get_cvar_pointer("mp_friendlyfire")
	    g_iMaxPlayers = get_maxplayers()
}
	public Ham__CGrenade_Think__Pre( iEnt )
{
    static Float:flGameTime, Float:flDmgTime, iOwner
    flGameTime = get_gametime()
    pev(iEnt, pev_dmgtime, flDmgTime)
    if(    flDmgTime <= flGameTime
    &&    get_pdata_int(iEnt, 114) == 0 // has a bit when is HE or SMOKE
    &&    !(get_pdata_int(iEnt, 96) & (1<<8)) // has this bit when is c4
    &&    IsPlayer( (iOwner = pev(iEnt, pev_owner)) )    ) // if no owner grenade gonna be removed from world
    {
        if( ~WillGrenadeExplode(iEnt) ) // grenade gonna explode on next think
        {
            SetGrenadeExplode( iEnt )
        }
        else
        {
            ClearGrenadeExplode( iEnt )
            g_flCurrentGameTime = flGameTime
            g_iCurrentFlasher = iOwner
            g_iCurrentFlashBang = iEnt
        }
    }
}
	public Fm__FindEntityInSphere__Pre(iStartEnt, Float:fVecOrigin[3], Float:flRadius)
{
    const Float:FLASHBANG_SEARCH_RADIUS = 1500.0
    if(    flRadius == FLASHBANG_SEARCH_RADIUS
    &&    get_gametime() == g_flCurrentGameTime    )
    {
        new id = iStartEnt, Float:fVecPlayerEyeOrigin[3], Float:flFraction, friendlyfire = get_pcvar_num(mp_friendlyfire)
	        while( IsPlayer( (id=engfunc(EngFunc_FindEntityInSphere, id, fVecOrigin, flRadius)) ) )
        {
            if( is_user_alive(id) )
            {
                pev(id, pev_origin, fVecPlayerEyeOrigin)
                fVecPlayerEyeOrigin[2] += ((pev(id, pev_flags) & FL_DUCKING) ? 12.0 : 18.0)
	                engfunc(EngFunc_TraceLine, fVecOrigin, fVecPlayerEyeOrigin, DONT_IGNORE_MONSTERS, g_iCurrentFlashBang, 0)
	                get_tr2(0, TR_flFraction, flFraction)
	                if( flFraction < 1.0 && get_tr2(0, TR_pHit) == id )
                {
                    engfunc(EngFunc_TraceLine, fVecPlayerEyeOrigin, fVecOrigin, DONT_IGNORE_MONSTERS, id, 0)
                    get_tr2(0, TR_flFraction, flFraction)
                    if(    flFraction == 1.0
                    &&    (    friendlyfire
                //        ||    id == g_iCurrentFlasher
                        ||    cs_get_user_team_index(id) != cs_get_user_team_index(g_iCurrentFlasher)    ) )
                    {
                        forward_return(FMV_CELL, id)
                        return FMRES_SUPERCEDE
                    }
                }
            }
        }
        forward_return(FMV_CELL, 0)
        return FMRES_SUPERCEDE
    }
    return FMRES_IGNORED
} 