#include <amxmodx>

new StatusIcon

public plugin_init()
{
	register_plugin("Grenade StatusIcon","0.3","AsuStar")
	
	register_event ( "CurWeapon", "CurrenWeapon", "be", "1=1" )

	StatusIcon = get_user_msgid("StatusIcon")
}

public CurrenWeapon(id)
{
	new Arma = read_data(2)
	
	if(Arma == CSW_HEGRENADE)
	{
		message_begin(MSG_ONE,StatusIcon,{0,0,0},id)
		write_byte(1)  // status (0=hide, 1=show, 2=flash)
		write_string("dmg_heat") // sprite name
		write_byte(255) //R
		write_byte(0) //G
		write_byte(0) //B
		message_end()
	}
	else if(!(Arma == CSW_HEGRENADE))
	{
		message_begin(MSG_ONE,StatusIcon,{0,0,0},id)
		write_byte(0)
		write_string("dmg_heat")
		write_byte(255)
		write_byte(0)
		write_byte(0)
		message_end()
	}
	
	
	if(Arma == CSW_FLASHBANG)
	{
		message_begin(MSG_ONE,StatusIcon,{0,0,0},id)
		write_byte(1)
		write_string("dmg_shock")
		write_byte(255)
		write_byte(255)
		write_byte(255)
		message_end()
	}
	else if(!(Arma == CSW_FLASHBANG))
	{
		message_begin(MSG_ONE,StatusIcon,{0,0,0},id)
		write_byte(0)
		write_string("dmg_shock")
		write_byte(255)
		write_byte(255)
		write_byte(255)
		message_end()
	}
	
	
	if(Arma == CSW_SMOKEGRENADE)
	{
		message_begin(MSG_ONE,StatusIcon,{0,0,0},id)
		write_byte(1)
		write_string("dmg_cold")
		write_byte(0)
		write_byte(255)
		write_byte(255)
		message_end()
	}
	else if(!(Arma == CSW_SMOKEGRENADE))
	{
		message_begin(MSG_ONE,StatusIcon,{0,0,0},id)
		write_byte(0)
		write_string("dmg_cold")
		write_byte(0)
		write_byte(0)
		write_byte(255)
		message_end()
	}
	
	return PLUGIN_CONTINUE
}
			
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1048\\ f0\\ fs16 \n\\ par }
*/
