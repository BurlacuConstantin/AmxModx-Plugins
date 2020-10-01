#include <amxmodx>

#define ZOMBIE_ESCAPE

#if defined ZOMBIE_ESCAPE
	#tryinclude <zombie_escape>
	
	#if !defined _zombie_escape_included
		#assert zombie_escape.inc library required!
	#endif
#endif

#define PLUGIN "Game Rezults"
#define VERSION "0.4"
#define AUTHOR "AsuStar"


#if defined _zombie_escape_included
new iNumberInfect[33]
#endif

public plugin_init()
{
	register_plugin(PLUGIN,VERSION,AUTHOR)
}

public client_connect(id)
{
	#if defined _zombie_escape_included
	iNumberInfect[id] = 0
	#endif
}

public client_disconnect(id)
{
	#if defined _zombie_escape_included
	iNumberInfect[id] = 0
	#endif
}

#if defined _zombie_escape_included
public ze_gamestart(START_ZOMBIE_APPEAR)
{
	for(new i = 0;i < get_maxplayers();i++)
	{
		iNumberInfect[i] = 0
	}
}
#endif

#if defined _zombie_escape_included
public ze_user_infected(id, infector)
{	
	if(!is_user_alive(infector))
		return

	iNumberInfect[infector]++
}
#endif

#if defined _zombie_escape_included
public ze_roundend(winteam)
{
	if(winteam == ZE_TEAM_ZOMBIE)
	{
		for(new i = 0;i < get_maxplayers();i++)
		{
			if(is_user_alive(i) && ze_is_user_zombie(i))
			{
				ShowRezults(i)
			}
		}	
	}
}
#endif
				
	
stock ShowRezults(id)
{
	new Name[32],Buffer[1024],Len,MapName[64]

	get_user_name(id,Name,charsmax(Name))
	get_mapname(MapName,charsmax(MapName))
	
	Len = formatex(Buffer,charsmax(Buffer),"<body bgcolor=#000000><font color=#7b68ee><pre>")
	
	Len+= formatex(Buffer[Len],charsmax(Buffer) - Len,"<center><img src=^"http://s16.postimg.org/oz1vf12g5/l4d_kill_2.jpg^"</center>")
	
	Len+= formatex(Buffer[Len],charsmax(Buffer) - Len,"<div align =^"left^"><font size=^"2^" color=^"#FFFFFF^"><B>Nume:</B><font size=^"2^" color=^"#FF0000^"><B>%s</B></div>",Name)
	Len+= formatex(Buffer[Len],charsmax(Buffer) - Len,"<div align =^"left^"><font size=^"2^" color=^"#FFFFFF^"><B>Harta curenta:</B><font size=^"2^" color=^"#FF0000^"><B>%s</B></div>",MapName)
	Len+= formatex(Buffer[Len],charsmax(Buffer) - Len,"<div align =^"left^"><font size=^"2^" color=^"#FFFFFF^"><B>Infectii:</B></B><font size=^"2^" color=^"#FF0000^"><B>Ai infectat<font size=^"3^" color=^"33FF00^"> %d <font size=^"2^" color=^"#FF0000^">jucatori</B></div>",iNumberInfect[id])
	//Len+= formatex(Buffer[Len],charsmax(Buffer) - Len,"<div align =^"left^"><font size=^"2^" color=^"#FFFFFF^"><B>Timp Ramas:</B></B><font size=^"2^" color=^"#FF0000^"><B>%d</B></div>",get_timeleft())

	show_motd(id,Buffer,"Game Rezults")
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
