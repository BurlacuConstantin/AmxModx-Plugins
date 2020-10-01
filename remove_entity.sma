#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

new const PLUGIN[]	= "Map Entity Remover",
	 VERSION[]	= "1.2",
	  AUTHOR[]	= "Fuffy";

new gEntityID;

new bool:remover_on[33];

new g_acces;
new g_auto_remover;

public plugin_init( )
{
	register_plugin
	(
		.plugin_name = PLUGIN, 
		.version     = VERSION, 
		.author      = AUTHOR
	)

	register_forward( FM_Touch, "WeaponTCH" );

	register_clcmd( "say /remover", "RemoverBool" );
	register_clcmd( "say_team /remover", "RemoverBool" );

	g_acces = register_cvar( "amx_ent_remover_acces", "bcdef" );
	g_auto_remover = register_cvar( "amx_ent_auto_remover", "0" );
}

public WeaponTCH( Entity, Client )
{
	if (!pev_valid(Entity) || !pev_valid(Client) || !is_user_alive(Client))
		return FMRES_IGNORED;

	new Access[41]
	get_pcvar_string( g_acces, Access, charsmax( Access ) );

	if( has_all_flags( Client,  Access ) && remover_on[ Client ] == true )
	{
		new menu = menu_create( "\r[ \yAdmin Entity Remover \r] \gDo you wanna remove this entity?", "menu_handler" );

		menu_additem( menu, "\gYes", "", 0 );
		menu_additem( menu, "\gNo", "", 0 );

		menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );

		menu_display( Client, menu, 0 );

		gEntityID = Entity;
	}
 
	return FMRES_IGNORED;
}

public menu_handler( id, menu, item )
{
	switch( item )
	{
		case 0:
		{
			client_print( id, print_center, "You have removed this entity!" );

			if( pev_valid( gEntityID ) )
            			engfunc( EngFunc_RemoveEntity, gEntityID );

			menu_destroy( menu );
			return PLUGIN_HANDLED;
		}

		case 1:
		{
			menu_destroy( menu );
			return PLUGIN_HANDLED;
		}

	}
	return PLUGIN_HANDLED;
}
public client_putinserver( id )
{
	new Access[41]
	get_pcvar_string( g_acces, Access, charsmax( Access ) );

	if( get_pcvar_num( g_auto_remover ) > 0 && has_all_flags( id, Access ) )
	{
		remover_on[ id ] = true;
	}
	else
	{
		remover_on[ id ] = false;
	}
}

public RemoverBool( const id )
{
	new Access[41]
	get_pcvar_string( g_acces, Access, charsmax( Access ) );

	if( !has_all_flags( id,  Access ) )
	{
		client_print( id, print_chat, "You have no access to this command!" );
		return PLUGIN_HANDLED;
	}

	if( !remover_on[ id ] )
	{
		remover_on[ id ] = true;
		client_print( id, print_chat, "You have activated entity remover!" );
		return PLUGIN_HANDLED;
	}

	else
	{
		remover_on[ id ] = false;
		client_print( id, print_chat, "You have deactivated entity remover!" );
		return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}