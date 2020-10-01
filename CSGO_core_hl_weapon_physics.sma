#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>
#include <engine>

#pragma tabsize 0

//#define Half_Life	// hl || cs/csz	

#define BREAKABLE_REFLECT	// "func_breakable" take dmg on monsters touch (&players)
//#define PUSH_MONSTERS	// push monsters on physics touch

//#define ADMIN_FLAGS ADMIN_IMMUNITY	// Admin Flags For - Menu Using, Can Be - (ADMIN_IMMUNITY | ADMIN_BAN) ...

#define SOUNDS_ON	// enable sounds
#define WEAPON_THROWING_ON	// enable weapon throwing (RECOMMENDED! :D)
#define SPRITE "sprites/arrow1.spr"	// sprite - WEAPON_THROWING_ON
//#define TRAILS_ON	// add trail to throwing entity - WEAPON_THROWING_ON

// Works only in: Cs/Csz
#if !defined Half_Life

//#define zBot_on_server	// enable this if you have zBot on server! (works on "cs/csz" ONLY!) *NEED`s* - "hamsandwich_zBot_FIX" - PLUGIN!
//#define CLCMD_COMMAND 	"hl_WeaponPhysics_Menu"	// Create Menu

//#define ARMOURY_ENTITY_RANDOMIZER	// enable armoury entity randomizer
//#define PHYSICS_RENDERING	// enable rendering	
#define SHOOT_GRENADES_ON	// enable grenades shooting Works in Cs - Csz Only!
//#define MESSAGE_ON	// enable messages Works in Cs - Csz Only! (shoot grenades)

// Plugin values
#define VECTOR_SUB 				2.5		// vector sub value - [2], when ground check
#define SEARCHING_RADIUS 		5.0		// in aiming point
#define MAX_REFLECT_A_VELOCITY	192.0	// [0] && [2]
#define MAX_VELOCITY_MULTIPLE	2.5		// [0] && [1] - multiple, when angled(ground has angles) iEntity take dmg
#define MAX_DAMAGE_RECEIVED 	255.0
#define AVAILABLE_MOVETYPE		(1 << MOVETYPE_TOSS) // can be - (1 << MOVETYPE_TOSS | 1 << MOVETYPE_FLY) ...
#define MAX_REFLECT_VELOCITY 	192.0 	// max jump power (axis[2])
#define DAMAGE_DIVIDER 			0.032 	// damage multiple, on received damaged by shot
#define SOUND_HIT				0.5 	// volume
#define SOUND_TOUCH				0.25 	// volume
#define GROUND_TRACE_RESULT   	0.65 	// high angle ground - [2]
#define BLOCK_SOUND_BY_SPEED	128.0 	// min speed(vector_length) to emit sound (on touch)

// Entity data slot
#define PEV_DATA_SLOT pev_iuser2	// hl_extensions -> data, contain touch counts
#define PEV_GROUND_TYPE pev_iuser3	// ground type info -> '4' values, look -> // Ground type
#define PEV_JUMP_REDUCE pev_iuser4	// add velocity or not, depend from: 1)ground type 2)attacker
#define PEV_GROUND_DATA pev_vuser3	// entity ground data - contain ground trace result -> TR_vecPlaneNormal

// Linux diff
#define BROKEN_GLASS_LINUX_OFFSET 4
#define WEAPON_IN_BOX_LINUX_OFFSET 4
#define WEAPON_COUNT_LINUX_OFFSET 4

// Reflect
#define COUNTS_TO_RESET 6 // counts to enable hl_extensions code (physics reflect)

/*

	PRIVATE DATA - DO NOT MODIFY ! (below)

*/

// Some Const
#define GET_FULL_DATA 1

// (1 << 25) - O_O unknown dmg type
#define DMG_UNKNOWN 0x1000000 

// Plugin flags
#define flag_WPN_Mod 1
#define flag_Precache_OFF 2
#define flag_Glass_Status 4

// Grenade Type
#define FLASH_GRENADE 0x0
#define SMOKE_GRENADE 0x1a
#define HE_GRENADE 0x19

#define _class_Empty 0
#define _class_Change 1
#define _class_Blocked 2

// Entity type
#define is_Player 1
#define is_Monster 2
#define is_Breakable 4
#define is_Physics 8

// Check
#define _SpeedVectorCheck 0
#define _SpeedVectorMultiple 1
#define _DamageMultiple 2

// Ground type
#define Ground_Vertical 1
#define Ground_Horizontal 2
#define Ground_Angle_High 4
#define Ground_Angle 8

enum
{
	_Weapon_Mp5Navy = 0,
	_Weapon_Tmp,
	_Weapon_P90,
	_Weapon_Mac10,
	_Weapon_Ak47,
	_Weapon_Sg552,
	_Weapon_M4a1,
	_Weapon_Aug,
	_Weapon_Scout,
	_Weapon_G3sg1,
	_Weapon_Awp,
	_Weapon_M3,
	_Weapon_Xm1014,
	_Weapon_M249,
	_Weapon_Flashbang,
	_Weapon_Hegrenade,
	_Item_Kevlar,
	_Item_Assaultsuit,
	_Weapon_Smokegrenade,
	
	_All_Weapons
};

const _Bit_Weapon_Mp5Navy = 1 << _Weapon_Mp5Navy;
const _Bit_Weapon_Tmp = 1 << _Weapon_Tmp;
const _Bit_Weapon_P90 = 1 << _Weapon_P90;
const _Bit_Weapon_Mac10 = 1 << _Weapon_Mac10;
const _Bit_Weapon_Ak47 = 1 << _Weapon_Ak47;
const _Bit_Weapon_Sg552 = 1 << _Weapon_Sg552;
const _Bit_Weapon_M4a1 = 1 << _Weapon_M4a1;
const _Bit_Weapon_Aug = 1 << _Weapon_Aug;
const _Bit_Weapon_Scout = 1 << _Weapon_Scout;
const _Bit_Weapon_G3sg1 = 1 << _Weapon_G3sg1;
const _Bit_Weapon_Awp = 1 << _Weapon_Awp;
const _Bit_Weapon_M3 = 1 << _Weapon_M3;
const _Bit_Weapon_Xm1014 = 1 << _Weapon_Xm1014;
const _Bit_Weapon_M249 = 1 << _Weapon_M249;
const _Bit_Weapon_Flashbang = 1 << _Weapon_Flashbang;
const _Bit_Weapon_Hegrenade = 1 << _Weapon_Hegrenade;
const _Bit_Item_Kevlar = 1 << _Item_Kevlar;
const _Bit_Item_Assaultsuit = 1 << _Item_Assaultsuit;
const _Bit_Weapon_Smokegrenade = 1 << _Weapon_Smokegrenade;

const g_iConstBitAllWeapons =
(
		_Bit_Weapon_Mp5Navy
	| 
		_Bit_Weapon_Tmp 
	| 
		_Bit_Weapon_P90 
	| 
		_Bit_Weapon_Mac10 
	| 
		_Bit_Weapon_Ak47 
	| 
		_Bit_Weapon_Sg552 
	| 
		_Bit_Weapon_M4a1 
	| 
		_Bit_Weapon_Aug 
	| 
		_Bit_Weapon_Scout 
	| 
		_Bit_Weapon_G3sg1 
	| 
		_Bit_Weapon_Awp 
	| 
		_Bit_Weapon_M3 
	| 
		_Bit_Weapon_Xm1014 
	| 
		_Bit_Weapon_M249
	| 
		_Bit_Weapon_Flashbang 
	| 
		_Bit_Weapon_Hegrenade 
	| 
		_Bit_Item_Kevlar 
	| 
		_Bit_Item_Assaultsuit 
	| 
		_Bit_Weapon_Smokegrenade
);

#if defined SOUNDS_ON
new const g_sTouchSounds[][] =
{
	"misc/wp_touch1.wav",
	"misc/wp_touch2.wav",
	"misc/wp_touch3.wav"
};
	
new const g_sHitSounds[][] =
{
	"misc/wp_bullet1.wav",
	"misc/wp_bullet2.wav",
	"misc/wp_bullet3.wav",
	"misc/wp_bullet4.wav"
};
#endif		
	
new const Float:g_fReduceSpeed[][] = // Change physics jump reflect
{
	// X : Y : Z
		
	{0.25, 0.25, 0.25}, // Ground_Vertical
	{0.5, 0.5, 0.35}, // Ground_Horizontal
	{0.0, 0.0, 0.5}, // Ground_Angle_High
	{0.32, 0.32, 0.32} // Ground_Angle
};	
	
new const Float:g_fMultiple[3][3] = // Reflect Dependency
{
	// 1 - _SpeedVectorCheck
	// 2 - _SpeedVectorMultiple
	// 3 - _DamageMultiple
	
	{32.0, 0.075, 0.1},		// Player
	{32.0, 0.075, 0.25},	// Monster
	{7.5, 0.1, 0.1}			// Breakable
};

new 

g_iMaxPlayers,
g_iMaxPlayersSizeOf,
g_iPluginFlags,
g_iBitAlive,
Trie:g_TrieBlockedClasses,
Float:g_fMaxDamageMultiple,
Float:g_fClientDamage[32],
g_iClientEntity[32],
g_iClientMenuChoice[32],
cvar_PhysicsEntitySpawnGravity;

#if !defined Half_Life
new 

HamHook:g_HamSpawnPostOFF,
Trie:g_TrieWeaponPos,
g_iArmouryEntityCounter = 0;

#if defined SHOOT_GRENADES_ON
new g_iClientGrenade[32];
#endif

#if defined ARMOURY_ENTITY_RANDOMIZER
new 

g_iRandomWeapons_Enum[_All_Weapons],
g_iWeaponsCounter,
cvar_iWeaponsCount,
cvar_iWeaponsCountCheck,
HamHook:g_HamSpawnPreOFF,
g_iBitWeaponList,
g_sMapName[64];
#endif
#endif

#if defined WEAPON_THROWING_ON
new cvar_WeaponThrowSpeedMultiple;

#if defined TRAILS_ON
new g_SpriteTrail;
#endif
#endif

#if defined SOUNDS_ON
const g_iPrecacheHitSoundSizeOf = sizeof g_sHitSounds;
const g_iPrecacheTouchSoundSizeOf = sizeof g_sTouchSounds;	
#endif

#define _PlayerEntity(%1) (0 < %1 < g_iMaxPlayersSizeOf)
#define _PlayerEntityAlive(%1) ((0 < %1 < g_iMaxPlayersSizeOf) && bit_alive(%1))

#define IndexFix(%1) (%1 - 1)

#define _Flag_Add(%1) (g_iPluginFlags |= _:%1)
#define _Flag_Sub(%1) (g_iPluginFlags &= _:~%1)
#define _Flag_Exists(%1) (g_iPluginFlags & _:%1)
#define _Flag_NOT_Exists(%1) (1 << %1 & ~g_iPluginFlags)

#define PLUGIN  "hl_weapon_physics"
#define VERSION "0.6" // 23.07.2012
#define AUTHOR  "Turanga_Leela"

#define bit_alive_NOT(%1) (1 << (%1 - 1) & ~g_iBitAlive)
#define bit_alive_add(%1) (g_iBitAlive |= 1 << (%1 - 1))
#define bit_alive_sub(%1) (g_iBitAlive &= ~(1 << (%1 - 1)))
#define bit_alive(%1) (g_iBitAlive & 1 << (%1 - 1))

public plugin_init()
{
	_Flag_Add(flag_Precache_OFF);
	
	g_fMaxDamageMultiple = (Float:DAMAGE_DIVIDER * Float:MAX_DAMAGE_RECEIVED);
	g_iMaxPlayersSizeOf = (g_iMaxPlayers = get_maxplayers()) + 1;

	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_event("DeathMsg", "On_Client_Death", "a");
	
	RegisterHam(Ham_Spawn, "player", "On_Client_Spawn", 1);
	
// <====================>
	
#if defined BREAKABLE_REFLECT

	RegisterHam(Ham_Touch, "func_breakable", "On_Breakable_Touch_Post", 1);
	
#endif	

// <====================>

#if defined WEAPON_THROWING_ON

	cvar_WeaponThrowSpeedMultiple = register_cvar("hl_ThrowSpeedMultiple", "13");

#endif

// <====================>
	
#if !defined Half_Life	

	DisableHamForward(g_HamSpawnPostOFF);
	register_logevent("On_New_Round", 2, "1=Round_Start");
	
#if defined ARMOURY_ENTITY_RANDOMIZER
	
	register_clcmd(CLCMD_COMMAND, "Call_Menu");

	if(g_iArmouryEntityCounter)
	{
		On_New_Round();
	}
	
	else
	{
		DisableHamForward(g_HamSpawnPreOFF);
	}
	
#endif	
	
#if defined SHOOT_GRENADES_ON

	RegisterHam(Ham_TraceAttack, "grenade", "TraceAttack_Post", 1);
	
#endif	
	
	register_forward(FM_TraceLine, "Trace_Line_Pre", 0);
	
#else // Fix Half-Life - Trace_Line

	register_forward(FM_TraceLine, "Trace_Line_Post", 1);
	
#endif
}

public plugin_precache()
{	
	if(!file_exists("addons/amxmodx/configs/hl_weapon_physics.ini"))
	{
		
#if !defined Half_Life
		
		if(!write_file("addons/amxmodx/configs/hl_weapon_physics.ini", "// Print bellow blocked classes^n ^ngrenade^n"))
		
#else	
	
		if(!write_file("addons/amxmodx/configs/hl_weapon_physics.ini", "// Print bellow blocked classes^n"))
		
#endif

		{
			set_fail_state("FATAL ERROR: Can't Read Config");
			
			return;
		}
	}
	
#if !defined Half_Life

	g_TrieWeaponPos = TrieCreate();

	EnableHamForward(g_HamSpawnPostOFF = RegisterHam(Ham_Spawn, "armoury_entity", "Armoury_Entity_Spawn_Post", 1));
	
#if defined ARMOURY_ENTITY_RANDOMIZER

	new sMapName[32];
	
	get_mapname(sMapName, charsmax(sMapName));
	formatex(g_sMapName, charsmax(g_sMapName), "%s%s%s", "maps/", sMapName, "_hl_WeaponPhysics.ini");
		
	if(!file_exists(g_sMapName))
	{
		if(!write_file(g_sMapName, ""))
		{
			set_fail_state("FATAL ERROR -> Cant Create Config File!");
				
			return;
		}
	}
			
	new 
			
	line_len,
	value;
		
	read_file(g_sMapName, 0, sMapName, charsmax(sMapName), line_len);
			
	switch((value = str_to_num(sMapName)))
	{
		case 0:
		{
			new sConfigLine[32];
					
			num_to_str((g_iBitWeaponList = g_iConstBitAllWeapons), sConfigLine, charsmax(sConfigLine));
					
			write_file(g_sMapName, sConfigLine, 0);
		}
			
		default:
		{
			g_iBitWeaponList = value;
		}
	}
	
	Armoury_Entity_Change();

	cvar_iWeaponsCount = register_cvar("hl_ArmouryEntityCount", "1");
	cvar_iWeaponsCountCheck = get_pcvar_num(cvar_iWeaponsCount);
	
	Check_Armoury_Entity_Cvar();
	
	EnableHamForward(g_HamSpawnPreOFF = RegisterHam(Ham_Spawn, "armoury_entity", "Armoury_Entity_Spawn_Pre", 0));
	
#endif
#endif	

	cvar_PhysicsEntitySpawnGravity = register_cvar("hl_PhysicsDefaultGravity", "2.0");
	
#if defined TRAILS_ON && defined WEAPON_THROWING_ON

	g_SpriteTrail = precache_model(SPRITE);
	
#endif
	g_TrieBlockedClasses = TrieCreate();
	
	register_forward(FM_SetModel, "Set_Model_Post", 1);

#if defined ARMOURY_ENTITY_RANDOMIZER && !defined Half_Life

	line_len = 0;
	
#else

#if  !defined ARMOURY_ENTITY_RANDOMIZER

	new line_len = 0;
	
#endif
#endif	

	new
	
	line = 0,
	string[32]
	
#if defined SOUNDS_ON	
	,
	i;
#else
	;
#endif
	
	while(read_file("addons/amxmodx/configs/hl_weapon_physics.ini", line++, string, charsmax(string), line_len))
	{
		if(!string[0] || equali(string, "//", 2))
		{
			continue;
		}
		
		TrieSetCell(g_TrieBlockedClasses, string, _class_Blocked);
	}

#if defined SOUNDS_ON	

	for(i = 0; i < g_iPrecacheTouchSoundSizeOf; i++)
	{
		precache_sound(g_sTouchSounds[i]);
	}
	
	for(i = 0; i < g_iPrecacheHitSoundSizeOf; i++)
	{
		precache_sound(g_sHitSounds[i]);
	}
	
#endif
}

public Touch_Post(iEntity, iTouched)
{
	static 
	
	iTouchedFlags,
	iEntFlags;
	
	if(pev_valid(iEntity))
	{
		if(!iTouched)
		{
			return Enable_Physics(iEntity);
		}
		
		iEntFlags = ((pev(iEntity, pev_flags) & FL_ONGROUND) | is_Physics);
		
		if(iTouched > g_iMaxPlayers)
		{
			if(pev_valid(iTouched))
			{
				if(!(iTouchedFlags = Get_Entity_Flags(iTouched)))
				{
					if(pev(iTouched, pev_solid) & SOLID_BSP)
					{
						return Enable_Physics(iEntity);
					}
					
					return HAM_IGNORED;
				}
				
				switch(iTouchedFlags & is_Physics)
				{
					case 0:
					{
						static iParam;
						
						switch(iTouchedFlags & is_Breakable)
						{
							case 0:
							{
								iParam = is_Monster >> 0x1;	
							}
								
							default:
							{
								iParam = is_Breakable >> 0x1;	
								
								Enable_Physics(iEntity);
							}
						}
#if defined PUSH_MONSTERS							
						return Touch_Extension_Check(iEntity, iTouched, iEntFlags, iTouchedFlags, iParam);
#else
						return Touch_Extension_Check(iEntity, iTouched, iEntFlags, iParam);
#endif						
					}
						
					default:
					{
						if(iEntFlags ^ iTouchedFlags) // Physics Reflect :D
						{
							static 
				
							Float:fInflictorData[3],
							Float:fTouchedData[3],
							Float:fDifference[3],
							iCounter;
					
							switch((iCounter = pev(iEntity, PEV_DATA_SLOT)))
							{
								case COUNTS_TO_RESET:
								{
									set_pev(iEntity, PEV_DATA_SLOT, 0);
								}
					
								default:
								{
									set_pev(iEntity, PEV_DATA_SLOT, ++iCounter);
								
									return HAM_IGNORED;
								}
							}
					
							pev(iEntity, pev_origin, fTouchedData);
							pev(iTouched, pev_origin, fInflictorData);

							if(get_distance_f(fTouchedData, fInflictorData) < 16.0)
							{	
								fDifference[0] = float(random_num(64, 96));
					
								if(random(2))
								{
									fDifference[0] = -fDifference[0];
								}
					
								fDifference[1] = float(random_num(64, 96));
					
								if(random(2))
								{
									fDifference[1] = -fDifference[1];
								}
					
								fDifference[2] = float(random_num(32, 96));
				
								if(random(2))
								{
									set_pev(iTouched, pev_velocity, fDifference);
								}
								
								fDifference[0] = -fDifference[0];
								fDifference[1] = -fDifference[1];
								
								if(random(2))
								{
									set_pev(iEntity, pev_velocity, fDifference);
								}
								
								fDifference[0] *= random_float(1.25, 2.75);
								fDifference[1] *= random_float(1.25, 2.75);
								
								if(random(2))
								{
									fDifference[0] = -fDifference[0];
								}
								
								if(random(2))
								{
									fDifference[1] = -fDifference[1];
								}
								
								set_pev(iEntity, pev_avelocity, fDifference);
#if defined SOUNDS_ON					
								engfunc(EngFunc_EmitSound, iEntity, CHAN_AUTO, g_sHitSounds[random(g_iPrecacheHitSoundSizeOf)], Float:SOUND_HIT, ATTN_NORM, 0, PITCH_NORM);
#endif							
							}
							
							return HAM_HANDLED;
						}
					}
				}
			}
		}
		
		else if(bit_alive(iTouched))
		{
			
#if defined PUSH_MONSTERS		

			Touch_Extension_Check(iEntity, iTouched, iEntFlags, is_Player, 0);
			
#else		
	
			Touch_Extension_Check(iEntity, iTouched, iEntFlags, 0);
			
#endif

		}
	}
	
	return HAM_IGNORED;
}

#if !defined Half_Life
#if defined ARMOURY_ENTITY_RANDOMIZER
public Menu_Config(id, Menu, Item)
{
	if(Item == MENU_EXIT)
	{
		menu_destroy(Menu);
		
		return PLUGIN_HANDLED;
	}
	
	new 
	
	s_Data[6], 
	s_Name[16], 
	i_Access, 
	i_Callback,
	i;
	
	menu_item_getinfo(Menu, Item, i_Access, s_Data, charsmax(s_Data), s_Name, charsmax(s_Name), i_Callback);

	new i_Key = str_to_num(s_Data);
	
	new BitValues[5];
	
	switch(g_iClientMenuChoice[IndexFix(id)])
	{
		case 1:
		{
			switch(i_Key)
			{
				case 6:
				{
					i = 2;
				}
				
				default:
				{
					i = 1;
					
					BitValues =
					{
						_Bit_Weapon_Awp,
						_Bit_Weapon_G3sg1,
						_Bit_Weapon_Scout,
				
						_Bit_Weapon_Xm1014,
						_Bit_Weapon_M3
					};
				}
			}
		}
		
		case 2:
		{
			switch(i_Key)
			{
				case 6:
				{
					i = 1;	
				}
				
				case 7:
				{
					i = 3;
				}
				
				default:
				{
					i = 2;
					
					BitValues =
					{
						_Bit_Weapon_Aug,
						_Bit_Weapon_Sg552,
						_Bit_Weapon_M4a1,
						_Bit_Weapon_Ak47,
						_Bit_Weapon_M249
					};
				}
			}
		}
		
		case 3:
		{
			switch(i_Key)
			{
				case 5:
				{
					i = 2;
				}
				
				case 6:
				{
					i = 4;	
				}
				
				default:
				{
					i = 3;
					
					BitValues =
					{
						_Bit_Weapon_P90,
						_Bit_Weapon_Mp5Navy,
						_Bit_Weapon_Mac10,
						_Bit_Weapon_Tmp,
						0
					};
				}
			}
		}
		
		case 4:
		{
			switch(i_Key)
			{
				case 6:
				{
					i = 3;	
				}
				
				default:
				{
					i = 4;	
					
					BitValues =
					{
						_Bit_Weapon_Hegrenade,
						_Bit_Weapon_Flashbang,
						_Bit_Weapon_Smokegrenade,
						_Bit_Item_Kevlar,
						_Bit_Item_Assaultsuit
					};
				}
			}
		}
	}
	
	if(i_Key < 6 && BitValues[i_Key - 1])
	{
		enum
		{
			iMassiveSize = 31
		};
		
		g_iBitWeaponList ^= BitValues[i_Key - 1];
		
		new sConfigLine[iMassiveSize + 1];
		
		num_to_str(g_iBitWeaponList, sConfigLine, iMassiveSize);
		
		write_file(g_sMapName, sConfigLine, 0);
	}
	
	Main_Menu(id, i);
		
	return PLUGIN_HANDLED;
}

public Call_Menu(id)
{
	if(get_user_flags(id) & (ADMIN_FLAGS))
	{
		Main_Menu(id, 1);
	}
}
#endif

public On_New_Round()
{
#if defined ARMOURY_ENTITY_RANDOMIZER

	cvar_iWeaponsCountCheck = get_pcvar_num(cvar_iWeaponsCount);
	
	Check_Armoury_Entity_Cvar();
	
#endif	

	if(g_iArmouryEntityCounter)
	{
		
#if defined ARMOURY_ENTITY_RANDOMIZER	
	
		Armoury_Entity_Change();
		
#endif		
	
		new
		
		sWeaponIndex[6],
		Float:fOriginFix[3],
		i;
		
		while((i = fm_find_ent_by_class(i, "armoury_entity")))
		{
			if(pev_valid(i))
			{
				num_to_str(i, sWeaponIndex, charsmax(sWeaponIndex));
				TrieGetArray(g_TrieWeaponPos, sWeaponIndex, fOriginFix, 3);
			
				if(fOriginFix[0] || fOriginFix[1] || fOriginFix[2])
				{
					
#if defined ARMOURY_ENTITY_RANDOMIZER			
		
					ExecuteHamB(Ham_Spawn, i);
					
#endif					

					set_pev(i, pev_origin, fOriginFix);
					
					engfunc(EngFunc_DropToFloor, i);
					ExecuteHamB(Ham_Touch, i, 0);
				}	
			}
		}
	}
}

public Armoury_Entity_Spawn_Post(iEntity) // Enabled on - "plugin_precache" :: Disabled on - "plugin_init"
{
	if(pev_valid(iEntity))
	{
		Change_Rendering(iEntity);
		
#if !defined ARMOURY_ENTITY_RANDOMIZER	
	
		if(_Flag_NOT_Exists(flag_Precache_OFF))
		{
			g_iArmouryEntityCounter++;
		}
		
#endif		

		enum
		{
			iMassiveSize = 5
		};
		
		new 
		
		Float:fOriginFix[3],
		sWeaponIndex[iMassiveSize + 1];
		
		pev(iEntity, pev_origin, fOriginFix);

		num_to_str(iEntity, sWeaponIndex, iMassiveSize);
		TrieSetArray(g_TrieWeaponPos, sWeaponIndex, fOriginFix, 3);
	}
}
#endif

public client_disconnect(id)
{
	bit_alive_sub(id);
}

public On_Client_Spawn(id)
{
	bit_alive_add(id);
}

public On_Client_Death()
{
	bit_alive_sub(read_data(2));
}

public Take_Damage_Pre(iEntity, inflictor, idattacker, Float:fDamage, iDamagebits)
{
	if(fDamage < 1.0)
	{
		fDamage = 1.0;
	}
	
	static 

	Float:fTemp[3],

	iAgressor,
	iMaxMultiple,
	iParam;

	if(pev_valid(iEntity) && ((iAgressor = Get_Entity_Data(inflictor)) || (iAgressor = Get_Entity_Data(idattacker))))
	{
		if(fDamage > Float:MAX_DAMAGE_RECEIVED)
		{
			fDamage = Float:MAX_DAMAGE_RECEIVED;
		}
		
		enum
		{
			iDataVertical = 0,
			iDataHorizontal,
			iDataAngleHigh,
			iDataAngle
		}
		
		switch(pev(iEntity, PEV_GROUND_TYPE))
		{
			case iDataVertical, iDataHorizontal:
			{
				iParam = 0;	
			}
			
			case iDataAngleHigh, iDataAngle:
			{
				iParam = 1;	
			}
			
			default:
			{
				SetHamParamFloat(4, 0.0);
	
				return HAM_HANDLED;
			}
		}
		
		Make_Vectors(iAgressor, iEntity, fDamage, iDamagebits, fTemp, iParam);	
		
		if(fDamage < 32.0)
		{
			iMaxMultiple = 16;
		}
		
		else if(fDamage < 64.0)
		{
			iMaxMultiple = 12;
		}
		
		else if(fDamage < 96.0)
		{
			iMaxMultiple = 8;
		}
		
		else
		{
			iMaxMultiple = 4;
		}
		
		fTemp[1] = random_float(-fDamage, fDamage) * random_num(2, iMaxMultiple);
		
		if(fTemp[0] > Float:MAX_REFLECT_A_VELOCITY)
		{
			fTemp[0] = Float:MAX_REFLECT_A_VELOCITY;
		}
		
		else if(fTemp[0] < -Float:MAX_REFLECT_A_VELOCITY)
		{
			fTemp[0] = -Float:MAX_REFLECT_A_VELOCITY;
		}
		
		if(fTemp[2] > Float:MAX_REFLECT_A_VELOCITY)
		{
			fTemp[2] = Float:MAX_REFLECT_A_VELOCITY;
		}
		
		else if(fTemp[2] < -Float:MAX_REFLECT_A_VELOCITY)
		{
			fTemp[2] = -Float:MAX_REFLECT_A_VELOCITY;
		}
		
		static Float:fEntAngles[3];
		
		pev(iEntity, pev_angles, fEntAngles);
		
		xs_vec_add(fEntAngles, fTemp, fTemp);
		
		fTemp[1] *= 0.75;
		fTemp[2] *= random_float(0.5, 0.75);
		fTemp[0] *= random_float(0.5, 0.75);
		
		set_pev(iEntity, pev_avelocity, fTemp);
		
#if defined SOUNDS_ON	
	
		engfunc(EngFunc_EmitSound, iEntity, CHAN_AUTO, g_sHitSounds[random(g_iPrecacheHitSoundSizeOf)], Float:SOUND_HIT, ATTN_NORM, 0, PITCH_NORM);
		
#endif		

		SetHamParamFloat(4, 0.0);
	
		return HAM_HANDLED;
	}
	
	return HAM_IGNORED;
}

public Set_Model_Post(iEntity, const sModel[])
{
	if(iEntity > g_iMaxPlayers && pev_valid(iEntity) && (1 << pev(iEntity, pev_movetype) & _:(AVAILABLE_MOVETYPE)))
	{
		new 
		
		classname[32],
		value = 0;
		
		pev(iEntity, pev_classname, classname, charsmax(classname));
		TrieGetCell(g_TrieBlockedClasses, classname, value);
		
		if(!value)
		{
			TrieSetCell(g_TrieBlockedClasses, classname, _class_Change);
			
			RegisterHamFromEntity(Ham_TraceAttack, iEntity, "TraceAttack_Post", 1);
			RegisterHamFromEntity(Ham_TakeDamage, iEntity, "Take_Damage_Pre", 0);
			RegisterHamFromEntity(Ham_Touch, iEntity, "Touch_Post", 1);
			
			value = _class_Change;
		}
		
		if(value & _class_Change)
		{
			new Float:fCvarGravityValue = get_pcvar_float(cvar_PhysicsEntitySpawnGravity);
			
			if(fCvarGravityValue < 0.0)
			{
				fCvarGravityValue = -fCvarGravityValue;
			}
			
			set_pev(iEntity, pev_health, 111.0);
			set_pev(iEntity, pev_takedamage, DAMAGE_YES);
			set_pev(iEntity, pev_movetype, MOVETYPE_BOUNCE);
			set_pev(iEntity, pev_gravity, fCvarGravityValue);
			
#if defined WEAPON_THROWING_ON	
			new Owner = 0;
			
			if(_PlayerEntity((Owner = pev(iEntity, pev_owner))))
#else
			if(_PlayerEntity(pev(iEntity, pev_owner)))
#endif
			{
#if defined WEAPON_THROWING_ON				
				new Float:Aiming[3];
				
				if(bit_alive(Owner))
				{
					new Float:fMultiple;
					
					velocity_by_aim(Owner, random_num(16, 32), Aiming);
				
					if((fMultiple = float(get_pcvar_num(cvar_WeaponThrowSpeedMultiple))) > 0.0 && get_user_oldbutton(Owner) & IN_USE && equali(classname, "weaponbox", 9))
					{
						xs_vec_mul_scalar(Aiming, fMultiple, Aiming);	
#if defined TRAILS_ON
						Entity_Trail(iEntity);
#endif
					}
				
					set_pev(iEntity, pev_basevelocity, Aiming);

				}
#else
				new Float:Aiming[3];
#endif
#if defined PHYSICS_RENDERING			
				Change_Rendering(iEntity);
#endif			
				Aiming[0] = random_float(-255.0, 255.0);
				Aiming[1] = random_float(-255.0, 255.0);
				Aiming[2] = random_float(-255.0, 255.0);
				
				set_pev(iEntity, pev_avelocity, Aiming);	
			}
		}
	}
}

#if !defined Half_Life
public Trace_Line_Pre(Float:start[3], Float:end[3], iNoMonsters, entToSkip, trace)
#else
public Trace_Line_Post(Float:start[3], Float:end[3], iNoMonsters, entToSkip, trace)
#endif
{
	if(_PlayerEntityAlive(entToSkip))
	{
		static 
		
		Float:endpt[3], 
		tr, 
		i,
		result;
		
		get_tr2(trace, TR_vecEndPos, endpt);
		
#if defined SHOOT_GRENADES_ON && !defined Half_Life	
		while((i = fm_find_ent_by_class(i, "grenade")))
		{
			if(pev_valid(i) && pev(i, pev_dmgtime))
			{
				engfunc(EngFunc_TraceModel, start, endpt, HULL_HEAD, i, tr);
			
				if(i == get_tr2(tr, TR_pHit))
				{				
					set_tr2(trace, TR_pHit, (g_iClientGrenade[IndexFix(entToSkip)] = i));
				
					break;
				}
			}
			
			g_iClientGrenade[IndexFix(entToSkip)] = 0;
		}
		
		if(!g_iClientGrenade[IndexFix(entToSkip)])
		{
#endif	
			while((i = engfunc(EngFunc_FindEntityInSphere, i, endpt, Float:SEARCHING_RADIUS)))
			{
				if(i > g_iMaxPlayers && pev_valid(i) && pev(i, pev_movetype) == MOVETYPE_BOUNCE)
				{
					engfunc(EngFunc_TraceModel, start, end, HULL_HEAD, i, tr);
		
					if((((result = get_tr2(tr, TR_pHit)) == i) || (result < 0 && Extension_Check(entToSkip, i, endpt))))
					{
						set_tr2(trace, TR_pHit, (g_iClientEntity[IndexFix(entToSkip)] = i));
						
						continue;
					}
				
					g_iClientEntity[IndexFix(entToSkip)] = 0;
					g_fClientDamage[IndexFix(entToSkip)] = 0.0;
				}
			
				else
				{
					g_iClientEntity[IndexFix(entToSkip)] = 0;
					g_fClientDamage[IndexFix(entToSkip)] = 0.0;
				}
			}
#if defined SHOOT_GRENADES_ON && !defined Half_Life			
		}
#endif
	}
}

public TraceAttack_Post(ent, idattacker, Float:damage, Float:direction[3], tracehandle, damagebits)
{	
	if(_PlayerEntity(idattacker))
	{
		if(!(damagebits & DMG_BULLET))
		{
			g_iClientEntity[IndexFix(idattacker)] = 0;
			g_fClientDamage[IndexFix(idattacker)] = 0.0;
			
			return;
		}
		
		g_fClientDamage[IndexFix(idattacker)] = damage;
		
#if !defined Half_Life && defined SHOOT_GRENADES_ON
		if(g_iClientGrenade[IndexFix(idattacker)] == ent && pev_valid(ent) && pev(ent, pev_dmgtime))
		{
			new deploy = 0;
			
			switch(get_pdata_int(ent, 114))
			{
				case FLASH_GRENADE:
				{
					if(!get_pdata_int(ent, 96))
					{						
						deploy = 0x1;						
					}
				}
							
				case HE_GRENADE:
				{
					deploy = 0x2;						
				}
							
				case SMOKE_GRENADE:
				{				
					set_pev(ent, pev_flags, pev(ent, pev_flags) | FL_ONGROUND);
					
					deploy = 0x3;
				}
			}
		
			if(deploy)
			{
#if defined MESSAGE_ON						
				enum
				{
					iMassiveSize = 31
				};
				
				new Name[iMassiveSize + 1];
					
				new const grenade_id[][] =
				{
					"FlashBang",
					"HEGrenade",
					"SmokeGrenade"
				};

				get_user_name(idattacker, Name, iMassiveSize);	
				client_print(0, print_chat, "%c%s%s %s %s%s%c %s", '[', Name, "]:", " HIT -", " `", grenade_id[deploy - 1], '`', "O_o!");
				
#endif		

				set_pev(ent, pev_dmgtime, 0.0);
				dllfunc(DLLFunc_Think, ent);
				
				g_iClientGrenade[IndexFix(idattacker)] = 0;
			}
		}
#endif
	}
}

#if defined zBot_on_server
public zBot_change_data(id, zBot_alive, zBot_in_game)
{
	if(id > 0 && 1 << (id - 1) & zBot_alive)
	{
		On_Client_Spawn(id);
	}
}
#endif

#if defined ARMOURY_ENTITY_RANDOMIZER
public Armoury_Entity_Spawn_Pre(ent)
{
	if(pev_valid(ent))	
	{
		if(_Flag_NOT_Exists(flag_Precache_OFF))
		{
			g_iArmouryEntityCounter++;
		}
	
		set_pdata_int(ent, 34, g_iWeaponsCounter ? g_iRandomWeapons_Enum[random(g_iWeaponsCounter)] : 0, _:WEAPON_IN_BOX_LINUX_OFFSET);
		set_pdata_int(ent, 35, cvar_iWeaponsCountCheck, _:WEAPON_COUNT_LINUX_OFFSET);
	}
}
#endif

#if defined BREAKABLE_REFLECT
public On_Breakable_Touch_Post(iEntity, id)
{
	static 
	
	iAgressor,
	iFlags;
	
	if(pev_valid(iEntity) && (!(iFlags = pev(iEntity, pev_spawnflags)) || iFlags & ~SF_BREAK_TRIGGER_ONLY) && (iAgressor = Get_Entity_Data(id, GET_FULL_DATA)))
	{
		if(iAgressor < 0 || iAgressor & is_Monster)
		{
			static 
		
			Float:fVelocity[3],
			Float:fVector;
		
			pev(id, pev_velocity, fVelocity);
			
			if((fVector = (vector_length(fVelocity) * g_fMultiple[2][_SpeedVectorMultiple])) > g_fMultiple[2][_SpeedVectorCheck])
			{
				ExecuteHamB(Ham_TakeDamage, iEntity, id, id, fVector * g_fMultiple[2][_DamageMultiple], DMG_GENERIC);
			
				return HAM_HANDLED;
			}
		}
	}
	
	return HAM_IGNORED;
}
#endif

stock Get_Velocity_Vector(iTarget, iSource, Float:fPower, Float:fOrigin_Result[3])
{
	static
	
	Float:fOrigin_Source[3],
	Float:fOrigin_Target[3],
	Float:fResult,
	i;
	
	if(fPower < 1.0)
	{
		fPower = 1.0;
	}
	
	pev(iSource, pev_origin, fOrigin_Source);
	pev(iTarget, pev_origin, fOrigin_Target);
	
	xs_vec_sub(fOrigin_Target, fOrigin_Source, fOrigin_Result);
	xs_vec_normalize(fOrigin_Result, fOrigin_Result);

	if((fResult = (204.8 - (get_distance_f(fOrigin_Source, fOrigin_Target) * 0.025))) < 32.0)
	{
		fResult = 32.0;
	}

	fResult *= fPower;
	
	fOrigin_Result[0] *= fResult;
	fOrigin_Result[1] *= fResult;

	if(fOrigin_Result[2] < 0.0)
	{
		fOrigin_Result[2] = -fOrigin_Result[2];
	}
	
	fOrigin_Result[2] = (fOrigin_Result[2] * fResult * 0.64);
	
	enum
	{
		iMassiveSize = 6
	};

	static const Float:const_fMultiple[iMassiveSize] = {512.0, 256.0, 224.0, 192.0, 160.0, 128.0};
	
	static const const_iMultiple[iMassiveSize][2] =
	{
		{256, 512},
		{224, 256},
		{192, 224},
		{160, 192},
		{128, 160},
		{112, 128}	
	};
	
	enum
	{
		iFirstNum = 0,
		iSecondNum
	};
	
	i = iMassiveSize;
	
	while(i)
	{
		if(fOrigin_Result[2] < const_fMultiple[--i])
		{
			fOrigin_Result[2] = float(random_num(const_iMultiple[i][iFirstNum], const_iMultiple[i][iSecondNum]));
			
			return;
		}
	}
	
	fOrigin_Result[2] = 512.0;
}

stock Get_Entity_Flags(index)
{
	enum
	{
		iMassiveSize = 31
	};
	
	static 
	
	sClass[iMassiveSize + 1],
	iBack;
	
	iBack = 0;
	
	switch(pev(index, pev_movetype))
	{
		case MOVETYPE_PUSH:
		{
			if(pev(index, pev_takedamage))
			{				
				pev(index, pev_classname, sClass, iMassiveSize);
			
				if(equali(sClass, "func_breakable", 14))
				{
					iBack = is_Breakable;
				}
			}	
		}
					
		case MOVETYPE_STEP, MOVETYPE_FLY:
		{
			if(FL_MONSTER & pev(index, pev_flags) && !pev(index, pev_deadflag))
			{
				iBack = is_Monster;
			}	
		}
		
		case MOVETYPE_BOUNCE:
		{
			iBack = is_Physics;
		}
	}
				
	if(iBack & ~is_Breakable)
	{
		iBack |= (pev(index, pev_flags) & FL_ONGROUND);
	}
	
	return iBack;
}

stock Get_Entity_Data(index, iMode = 0)
{
	if(_PlayerEntity(index))
	{
		if(bit_alive(index))
		{
			return -index;
		}
	}
	
	else if(pev_valid(index))
	{
		if(iMode)
		{
			return Get_Entity_Flags(index);
		}
		
		else
		{
			return index;
		}
	}
	
	return 0;
}

#if defined ARMOURY_ENTITY_RANDOMIZER
stock Armoury_Entity_Change()
{
	new i;
	
	g_iWeaponsCounter = 0;
	
	for(i = 0; i < _All_Weapons; i++)
	{
		if(g_iBitWeaponList & 1 << i)
		{
			g_iRandomWeapons_Enum[g_iWeaponsCounter++] = i;
		}
	}
}

stock Check_Armoury_Entity_Cvar()
{
	if(cvar_iWeaponsCountCheck < 0)
	{
		cvar_iWeaponsCountCheck = -cvar_iWeaponsCountCheck;
	}
		
	if(cvar_iWeaponsCountCheck > 32)
	{
		cvar_iWeaponsCountCheck = 32;
	}
		
	else if(!cvar_iWeaponsCountCheck)
	{
		cvar_iWeaponsCountCheck = 1;
	}
}
#endif

stock Main_Menu(id, iMode)
{
	enum
	{
		iMassiveSize = 31
	};
	
	new sMenuTitle[iMassiveSize + 1];
	
	formatex(sMenuTitle, iMassiveSize, "%s%d%c%d%c", "\r#Armoury Entity List [", (g_iClientMenuChoice[IndexFix(id)] = iMode), '/', 4, ']');
	
	new iMenu = menu_create(sMenuTitle, "Menu_Config");
	
	switch(iMode)
	{
		case 1:
		{
			menu_additem(iMenu, g_iBitWeaponList & _Bit_Weapon_Awp ? "\wAwp -> [ON]" : "\wAwp -> [OFF]", "1");
			menu_additem(iMenu, g_iBitWeaponList & _Bit_Weapon_G3sg1 ? "\wG3sg1 -> [ON]" : "\wG3sg1 -> [OFF]", "2");
			menu_additem(iMenu, g_iBitWeaponList & _Bit_Weapon_Scout ? "\wScout -> [ON]" : "\wScout -> [OFF]", "3");
			
			menu_addblank(iMenu, 0);
			
			menu_additem(iMenu, g_iBitWeaponList & _Bit_Weapon_Xm1014 ? "\wXm1014 -> [ON]" : "\wXm1014 -> [OFF]", "4");
			menu_additem(iMenu, g_iBitWeaponList & _Bit_Weapon_M3 ? "\wM3 -> [ON]" : "\wM3 -> [OFF]", "5");
			
			menu_addblank(iMenu, 0);
			
			menu_additem(iMenu, "\wNext ->", "6");
		}
		
		case 2:
		{
			menu_additem(iMenu, g_iBitWeaponList & _Bit_Weapon_Aug ? "\wAug -> [ON]" : "\wAug -> [OFF]", "1");
			menu_additem(iMenu, g_iBitWeaponList & _Bit_Weapon_Sg552 ? "\wSg552 -> [ON]" : "\wSg552 -> [OFF]", "2");
			menu_additem(iMenu, g_iBitWeaponList & _Bit_Weapon_M4a1 ? "\wM4a1 -> [ON]" : "\wM4a1 -> [OFF]", "3");
			menu_additem(iMenu, g_iBitWeaponList & _Bit_Weapon_Ak47 ? "\wAk47 -> [ON]" : "\wAk47 -> [OFF]", "4");
			menu_additem(iMenu, g_iBitWeaponList & _Bit_Weapon_M249 ? "\wM249 -> [ON]" : "\wM249 -> [OFF]", "5");
			
			menu_addblank(iMenu, 0);
		
			menu_additem(iMenu, "\wBack <-", "6");	
			
			menu_addblank(iMenu, 0);
			
			menu_additem(iMenu, "\wNext ->", "7");
		}
		
		case 3:
		{
			menu_additem(iMenu, g_iBitWeaponList & _Bit_Weapon_P90 ? "\wP90 -> [ON]" : "\wP90 -> [OFF]", "1");
			menu_additem(iMenu, g_iBitWeaponList & _Bit_Weapon_Mp5Navy ? "\wMp5Navy -> [ON]" : "\wMp5Navy -> [OFF]", "2");
			menu_additem(iMenu, g_iBitWeaponList & _Bit_Weapon_Mac10 ? "\wMac10 -> [ON]" : "\wMac10 -> [OFF]", "3");
			menu_additem(iMenu, g_iBitWeaponList & _Bit_Weapon_Tmp ? "\wTmp -> [ON]" : "\wTmp -> [OFF]", "4");
			
			menu_addblank(iMenu, 0);
		
			menu_additem(iMenu, "\wBack <-", "5");
			
			menu_addblank(iMenu, 0);
			
			menu_additem(iMenu, "\wNext ->", "6");
		}
	
		case 4:
		{
			menu_additem(iMenu, g_iBitWeaponList & _Bit_Weapon_Hegrenade ? "\wHegrenade -> [ON]" : "\wHegrenade -> [OFF]", "1");
			menu_additem(iMenu, g_iBitWeaponList & _Bit_Weapon_Flashbang ? "\wFlashbang -> [ON]" : "\wFlashbang -> [OFF]", "2");
			menu_additem(iMenu, g_iBitWeaponList & _Bit_Weapon_Smokegrenade ? "\wSmokegrenade -> [ON]" : "\wSmokegrenade -> [OFF]", "3");
		
			menu_addblank(iMenu, 0);
			
			menu_additem(iMenu, g_iBitWeaponList & _Bit_Item_Kevlar ? "\wKevlar -> [ON]" : "\wKevlar -> [OFF]", "4");
			menu_additem(iMenu, g_iBitWeaponList & _Bit_Item_Assaultsuit ? "\wAssaultsuit -> [ON]" : "\wAssaultsuit -> [OFF]", "5");
			
			menu_addblank(iMenu, 0);
		
			menu_additem(iMenu, "\wBack <-", "6");
		}
	}
	
	menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, iMenu, 0);
	
	return PLUGIN_CONTINUE;
}

stock Make_Vectors(&iAgressor, iEntity, Float:fDamage, iDamagebits, Float:fTemp[3], iMode = 0)
{
	static 
	
	Float:fDmgCheck,	
	Float:fOriginFix,	
	Float:fCheckOrigin[3],
	Float:fDifference[3],
	Float:fGroundData[3],
	Float:fGravityCheckFirst,
	Float:fGravityCheckSecond,
	
	bool:X_axis,
	bool:Y_axis,
	bool:bExplosion = false;
	
	if(iAgressor < 0)
	{
		fOriginFix = 32.0;
		
		switch(g_iClientEntity[IndexFix((iAgressor = -iAgressor))] ^ iEntity)
		{
			case 0:
			{
				fDmgCheck = g_fClientDamage[IndexFix(iAgressor)] * Float:DAMAGE_DIVIDER;
			}
				
			default:
			{
				fDmgCheck = fDamage * Float:DAMAGE_DIVIDER;
			}
		}	
	}
				
	else
	{
		fOriginFix = 0.0;
		
		if(iDamagebits & (DMG_UNKNOWN | DMG_BLAST)) 
		{
			bExplosion = true;
			
			fDmgCheck = fDamage;
		}
					
		else
		{
			bExplosion = false;
			
			fDmgCheck = fDamage * Float:DAMAGE_DIVIDER;
		}
	}
	
	if(fDmgCheck < 1.1)
	{
		fDmgCheck = random_float(1.1, 1.64);
	}
					
	else if(fDmgCheck > g_fMaxDamageMultiple)
	{
		fDmgCheck = g_fMaxDamageMultiple;
	}
		
	if(iMode) // if Entity is on Ground that has Angles
	{					
		pev(iAgressor, pev_origin, fCheckOrigin);
		pev(iEntity, pev_origin, fDifference);
		
		if((fCheckOrigin[2] - fOriginFix) < fDifference[2])
		{
			if(bExplosion)
			{
				bExplosion = false;
				
				Get_Velocity_Vector(iEntity, iAgressor, fDmgCheck, fTemp);
				
				set_pev(iEntity, pev_velocity, fTemp);
				set_pev(iEntity, PEV_JUMP_REDUCE, 1);
				
				return;
			}
			
			pev(iEntity, pev_gravity, fGravityCheckFirst);
					
			fGravityCheckFirst *= 32;
			fGravityCheckSecond = fGravityCheckFirst * 2;
					
			if((fTemp[2] = random_float(fDamage / 2, fDamage)) < fGravityCheckFirst)
			{
				fTemp[2] = fGravityCheckFirst;
			}
				
			else if(fTemp[2] > fGravityCheckSecond)
			{
				fTemp[2] = fGravityCheckSecond;
			}
				
			pev(iEntity, PEV_GROUND_DATA, fGroundData);
					
			X_axis = (fGroundData[0] != 0.000000);	
			Y_axis = (fGroundData[1] != 0.000000);
						
			if(X_axis && Y_axis)
			{
				fTemp[0] = fGroundData[0] * fDamage * random_float(1.1, 2.5);
				fTemp[1] = fGroundData[1] * fDamage * random_float(1.1, 2.5);
			}
						
			else if(X_axis)
			{
				fTemp[0] = fGroundData[0] * fDamage * random_float(1.1, 2.5);
				fTemp[1] = fDamage * random_float(-Float:MAX_VELOCITY_MULTIPLE, Float:MAX_VELOCITY_MULTIPLE);
			}
					
			else if(Y_axis)
			{
				fTemp[0] = fDamage * random_float(-Float:MAX_VELOCITY_MULTIPLE, Float:MAX_VELOCITY_MULTIPLE);
				fTemp[1] = fGroundData[1] * fDamage * random_float(1.1, 2.5);
			}	
				
			else
			{
				return;
			}
					
			set_pev(iEntity, pev_velocity, fTemp);
			
			return;
		}
	}

	Get_Velocity_Vector(iEntity, iAgressor, fDmgCheck, fTemp);
	
	set_pev(iEntity, pev_velocity, fTemp);
}

#if defined PUSH_MONSTERS
stock Touch_Extension_Check(iEntity, iTouched, iEntFlags, iTouchedFlags, iMode)
#else
stock Touch_Extension_Check(iEntity, iTouched, iEntFlags, iMode)
#endif
{
	if(iEntFlags & ~FL_ONGROUND)
	{
		static 
	
		Float:fVelReverse[3],
		Float:fVelocity[3],
		Float:fVector,
		iAttacker,
		Float:fDamage;
	
		if((iAttacker = Get_Entity_Data(pev(iEntity, pev_owner))))
		{
			if(iAttacker < 0)
			{
				if((iAttacker = -iAttacker) == iTouched)
				{
					return HAM_IGNORED;
				}
			}
		}

		else
		{
			iAttacker = iEntity;
		}
		
		pev(iEntity, pev_velocity, fVelocity);
		
		fDamage = Float:((fVector = (vector_length(fVelocity) * g_fMultiple[iMode][_SpeedVectorMultiple])) * g_fMultiple[iMode][_DamageMultiple]);
		
		if(fVector > g_fMultiple[iMode][_SpeedVectorCheck])
		{
		
#if defined PUSH_MONSTERS		

			if(iTouchedFlags & (is_Monster | is_Player))
			{
				Get_Velocity_Vector(iTouched, iEntity, fDamage * 0.1, fVelocity);
				
				set_pev(iTouched, pev_velocity, fVelocity);
			}
			
#endif	

			ExecuteHamB(Ham_TakeDamage, iTouched, iEntity, iAttacker, fDamage, DMG_GENERIC);
		}
		
		if(1 << pev(iEntity, pev_solid) & (1 << SOLID_TRIGGER | 1 << SOLID_BBOX))
		{
			switch(1 << iMode & is_Breakable)
			{
				case 0:
				{
					fVelReverse[0] = 0.0;
					fVelReverse[1] = 0.0;
				}
				
				default:
				{
					static Float:Check_Ground[3];
					
					pev(iEntity, PEV_GROUND_DATA, Check_Ground);
			
					if((pev(iTouched, pev_health) > 0.0) || (0.0 < Check_Ground[2] < 1.0))
					{
						fVelReverse[0] = fVelocity[0];
						fVelReverse[1] = fVelocity[1];
					}
					
					else
					{
						fVelReverse[0] = -fVelocity[0];
						fVelReverse[1] = -fVelocity[1];
					}
				}	
			}
			
			fVelReverse[2] = fVelocity[2];
			
			set_pev(iEntity, pev_velocity, fVelReverse);
		}
		
		return HAM_HANDLED;
	}
	
	return HAM_IGNORED;
}

stock Entity_Trail(iEntity, iColors[3] = {0, 0, 0})
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	
	write_byte(TE_BEAMFOLLOW);
	write_short(iEntity);
	write_short(g_SpriteTrail);
	write_byte(5);
	write_byte(2);
	write_byte(iColors[0] ? iColors[0] : random(256));
	write_byte(iColors[1] ? iColors[1] : random(256));
	write_byte(iColors[2] ? iColors[2] : random(256));
	write_byte(255);		
	
	message_end();
}

stock Change_Rendering(iEntity, iColors[3] = {0, 0, 0})
{
	new Float:f_Colors[3];
				
	f_Colors[0] = iColors[0] ? float(iColors[0]) : float(random(256));
	f_Colors[1] = iColors[1] ? float(iColors[1]) : float(random(256));
	f_Colors[2] = iColors[2] ? float(iColors[2]) : float(random(256));
			
	set_pev(iEntity, pev_renderfx, kRenderFxGlowShell);
	set_pev(iEntity, pev_rendercolor, f_Colors);
	set_pev(iEntity, pev_rendermode, kRenderNormal);
	set_pev(iEntity, pev_renderamt, 24.0);
}

stock bool:Extension_Check(iEntToSkip, iEntity, Float:fEnd[3])
{
	static Float:fOrigin[3];
					
	pev(iEntToSkip, pev_origin, fOrigin);
	pev(iEntity, pev_origin, fEnd);
			
	return bool:(get_distance_f(fEnd, fOrigin) > 2.5);
}

stock Enable_Physics(iEntity)
{
	static
	
	Float:f_destination[3],
	Float:f_velocity[3],
	Float:f_angles_2[3],
	Float:f_forward[3],
	Float:f_origin[3],
	Float:f_vector[3],
	Float:f_trace[3],
	iGround,
	trace,
	_i;

	pev(iEntity, pev_origin, f_origin);
	xs_vec_sub(f_origin, Float:{0.0, 0.0, Float:VECTOR_SUB}, f_destination);
		
	engfunc(EngFunc_TraceLine, f_origin, f_destination, IGNORE_MONSTERS | IGNORE_MISSILE, iEntity, trace);
		
	get_tr2(trace, TR_vecPlaneNormal, f_trace);
		
	if(!f_trace[2])
	{
		_i = (iGround = Ground_Vertical);
	}
		
	else if(f_trace[2] == 1.0)
	{
		_i = (iGround = Ground_Horizontal);
	}
		
	else if(0.0 < f_trace[2] <= Float:GROUND_TRACE_RESULT)
	{
		_i = (iGround = Ground_Angle_High);
	}
		
	else if(f_trace[2] > Float:GROUND_TRACE_RESULT)
	{
		_i = (iGround = Ground_Angle) - 0x1;
	}
		
	else
	{
		return HAM_IGNORED;
	}
		
	set_pev(iEntity, PEV_GROUND_DATA, f_trace);
	pev(iEntity, pev_velocity, f_velocity);
	
	_i >>= 0x1;
	
	set_pev(iEntity, PEV_GROUND_TYPE, _i);
	
#if defined SOUNDS_ON		
	if(vector_length(f_velocity) > Float:BLOCK_SOUND_BY_SPEED)
	{
		engfunc(EngFunc_EmitSound, iEntity, CHAN_AUTO, g_sTouchSounds[random(g_iPrecacheTouchSoundSizeOf)], Float:SOUND_TOUCH, ATTN_NORM, 0, PITCH_NORM);
	}
#endif	
	
	f_velocity[0] *= g_fReduceSpeed[_i][0];
	f_velocity[1] *= g_fReduceSpeed[_i][1];
	f_velocity[2] *= g_fReduceSpeed[_i][2];
	
	if(pev(iEntity, PEV_JUMP_REDUCE))
	{
		set_pev(iEntity, PEV_JUMP_REDUCE, 0);
		
		f_velocity[0] *= random_float(1.1, 2.0);
		f_velocity[1] *= random_float(1.1, 2.0);
		f_velocity[2] *= random_float(1.1, 2.0);
	}
		
	if(f_velocity[2] > Float:MAX_REFLECT_VELOCITY)
	{
		f_velocity[2] = Float:MAX_REFLECT_VELOCITY;
	}
		
	else if(f_velocity[2] < -Float:MAX_REFLECT_VELOCITY)
	{
		f_velocity[2] = -Float:MAX_REFLECT_VELOCITY;
	}
		
	set_pev(iEntity, pev_velocity, f_velocity);	
		
	#define f_a_velocity f_velocity
		
	f_a_velocity[0] = random_float(-f_a_velocity[0], f_a_velocity[0]);
	f_a_velocity[1] = random_float(-f_a_velocity[1], f_a_velocity[1]);
	f_a_velocity[2] = random_float(f_a_velocity[2] / -2, f_a_velocity[2] / 2);
		
	set_pev(iEntity, pev_avelocity, f_a_velocity);	
		
	#define f_angles_1 f_velocity
	#define f_right f_origin
		
	if(iGround & ~Ground_Vertical)
	{		
		pev(iEntity, pev_angles, f_angles_1);
		angle_vector(f_angles_1, ANGLEVECTOR_FORWARD, f_vector);

		xs_vec_cross(f_vector, f_trace, f_right);
		xs_vec_cross(f_trace, f_right, f_forward);

		vector_to_angle(f_forward, f_angles_1);
		vector_to_angle(f_right, f_angles_2);

		f_angles_1[2] = -f_angles_2[0];
			
		set_pev(iEntity, pev_angles, f_angles_1);
	}
	
	return HAM_HANDLED;
}
#endif