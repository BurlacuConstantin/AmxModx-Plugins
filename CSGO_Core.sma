#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <fun>
#include <engine>
#include <nvault>
#include <dhudmessage>

#pragma tabsize 0

#define MAX_SKINS 50
#define CONFIG_FILE "CSGO.ini"

new PLUGIN[] =  "CSGO Remake"
new VERSION[] = "0.2"
new AUTHOR[] =  "Deroid / AsuStar"

#define PointsMin 3
#define PointsMax 8
#define Drop 10 //default 10
#define MarkMin 25

new const TAG[] = "CSGO Remake"

new WeaponNames[MAX_SKINS][32], WeaponMdls[MAX_SKINS][48], Weapons[MAX_SKINS], WeaponDrop[MAX_SKINS], AllWeapon
new UsingWeapon[3][33], uWeapon[MAX_SKINS][33], Chest[33], pKey[33], Points[33], Rang[33], Kills[33]
new aThing[33], aTarget[33], aPoints[33]
new MenuMod[33]
new WeaponinMarket[33], inMarket[33], MarketPoints[33], Choosen[33]
new SavedPassword[33][32], bool:Loged[33], Password[33][32]
new DefaultSkin[31][32], NeedKills[30], Rangs[30][32]

new g_vault_save, g_vault_register


new const eWeapon[][] =
{
	"weapon_famas", "weapon_usp", "weapon_awp", "weapon_mp5navy", "weapon_m3", "weapon_m4a1",
	"weapon_deagle", "weapon_ak47", "weapon_knife", "weapon_flashbang", "weapon_hegrenade",
	"weapon_smokegrenade", "weapon_c4"
};

public plugin_precache()
{	
	AllWeapon++
	load_config_file(true)	
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_clcmd("say /menu", "MenuOpen")
	register_clcmd("say /reg", "RegMenu")
	register_clcmd("say_team /menu", "MenuOpen")
	register_clcmd("say_team /reg", "RegMenu")
	
	register_clcmd("say /rang", "cmd_rang")
	register_clcmd("say /keys", "cmd_keys")
	register_clcmd("say /chest", "cmd_chest")
	
	register_concmd("Cost", "MarketCost");
	register_concmd("Gift", "GiftPoint");
	register_concmd("UserPassword", "PlayerPassword");
	
	g_vault_save = nvault_open("csgo_save_stats")
	g_vault_register = nvault_open("csgo_user_register")
	
	if(g_vault_save == -1 || g_vault_register == -1)
	{
		new error[100]
		formatex(error, charsmax(error), "[%s]: Nu s-au putut accesa fisierele nvault !", TAG)
		set_fail_state(error)
		return
	}
	
	register_clcmd("say", "Say")
	register_clcmd("say_team", "Say")
	
	register_forward(FM_ClientUserInfoChanged, "NameChange")
	
	//RegisterHam(Ham_Spawn, "player", "PlayerSpawn", 1)
	
	for(new i; i < sizeof(eWeapon); i++)
	{
		RegisterHam(Ham_Item_Deploy, eWeapon[i], "WeaponSwitch", 1);
	}
	
	register_event("HLTV", "round_start", "a", "1=0", "2=0")
	
	register_forward(FM_GetGameDescription,"GameDescription")
}

public cmd_rang(id)
{
	Rang[id]++
}

public cmd_keys(id)
{
	pKey[id]++
}

public cmd_chest(id)
{
	Chest[id]++
}

public plugin_end()
{
	nvault_close(g_vault_register)
	nvault_close(g_vault_save)
}


public plugin_natives()
{
	register_native("csgo_get_user_points", "csgo_get_points", 1)
	register_native("csgo_set_user_points", "csgo_set_points", 1)
	
	register_native("csgo_get_user_chests", "csgo_get_chests", 1)
	register_native("csgo_set_user_chests", "csgo_set_chests", 1)
	
	register_native("csgo_get_user_keys", "csgo_get_keys", 1)
	register_native("csgo_set_user_keys", "csgo_set_keys", 1)
	
	register_native("csgo_is_user_logged", "csgo_check_user_logged", 1)
}

public csgo_get_points(id)
{
	return Points[id]
}

public csgo_set_points(id, ammount)
{
	Points[id] = ammount
}

public csgo_get_chests(id)
{
	return Chest[id]
}

public csgo_set_chests(id, ammount)
{
	Chest[id] = ammount
}

public csgo_get_keys(id)
{
	return pKey[id]
}

public csgo_set_keys(id, ammount)
{
	pKey[id] = ammount
}

public csgo_check_user_logged(id)
{
	return Loged[id]
}

public GameDescription()
{
	static GameName[64]
	formatex(GameName, charsmax(GameName), "%s %s", PLUGIN, VERSION)
	
	forward_return(FMV_STRING, GameName)
	return FMRES_SUPERCEDE
}

public client_putinserver(id)
{
	Kills[id]  = Rang[id] = Points[id] = Choosen[id] = pKey[id] = Chest[id] = 0
	
	for(new i = 0; i < AllWeapon; i++)
		uWeapon[i][id] = 0
		
	retrieve_data(id)
	
	Password[id] = "";
	SavedPassword[id] = "";
	
	Loged[id] = false
}

public Say(id)
{
	/*
	if(Loged[id])
	{
		new chat[200], name[32], cchat[200]
		read_args(chat, charsmax(chat))
		remove_quotes(chat)
		get_user_name(id, name, charsmax(name))
	
		if(strlen(chat) > 1)
		{
			formatex(cchat, charsmax(cchat), "!g[%s] !t%s!y: %s", Rangs[Rang[id]], name, chat)
		}
		
		ColorChat(0, "%s", cchat)
	}
	
	return PLUGIN_HANDLED_MAIN
	*/
	
	new Chat[190], Name[32], cChat[190]; //256
	read_args(Chat, charsmax(Chat));
	remove_quotes(Chat);
	get_user_name(id, Name, 31);
	
	if(strlen(Chat) > 1)
	{
		formatex(cChat, charsmax(cChat), "^4[%s] ^3%s^1: %s", Rangs[Rang[id]], Name, Chat);
	}
	
	ColorChat(0,"!t%s", cChat);
	return PLUGIN_HANDLED_MAIN;
}

public client_death(killer, victim)
{
	if(killer == victim)
	return PLUGIN_HANDLED
	
	Kills[killer]++
	
	if(Rang[killer] < sizeof(Rangs))
	{
		if(Kills[killer] >= NeedKills[Rang[killer]])
			Rang[killer]++
	}
	
	save_data(killer)
	
	return PLUGIN_CONTINUE
}

public WeaponSwitch(Weapon) 
{
	new id = get_pdata_cbase(Weapon, 41, 4)
	new wid = cs_get_weapon_id(Weapon)
	
	if(id > 32 || id < 1)
	 return HAM_SUPERCEDE
	
	for(new i = 1; i < AllWeapon; i++)
	{
		if(i == UsingWeapon[0][id])
		{
			if(wid == Weapons[i])
			{
				set_pev(id, pev_viewmodel2, WeaponMdls[i]);
				return HAM_SUPERCEDE;
			}
		}
		else if(i == UsingWeapon[1][id])
		{
			if(wid == Weapons[i])
			{
				set_pev(id, pev_viewmodel2, WeaponMdls[i]);
				return HAM_SUPERCEDE;
			}
		}
		else if(i == UsingWeapon[2][id])
		{
			if(wid == Weapons[i])
			{
				set_pev(id, pev_viewmodel2, WeaponMdls[i]);
				return HAM_SUPERCEDE;
			}
		}
		
	}
	if(ValidMdl(DefaultSkin[wid]))
	{
		set_pev(id, pev_viewmodel2, DefaultSkin[wid]);
	}
	
	return HAM_IGNORED
}

public MenuOpen(id)
{
	if(!Loged[id])
	{
		RegMenu(id)
		return
	}
	else
	{
		MenuMod[id] = 0
		Menu(id)
	}
}

public Menu(id)
{
	if(!Loged[id])
	{
		RegMenu(id)
		return
	}
	
	new szMenu, line[128]
	
	if(MenuMod[id] == -2)
	{
		formatex(line, charsmax(line), "\d[\w%s\d]\w Your Skins", PLUGIN)
		szMenu = menu_create(line, "MenuHandler")
		
		new string[32], all
		
		for(new i = 1; i < AllWeapon; i++)
		{
			if(uWeapon[i][id] == 0)
			         continue;
		
			num_to_str(i, string, charsmax(string))
			formatex(line, charsmax(line), "\r%s \d|\y (%d)", WeaponNames[i], uWeapon[i][id]);
			menu_additem(szMenu, line, string)
			all++
		}
		
		if(Chest[id] > 0)
		{
			formatex(line, charsmax(line), "\rChests \d|\y (%d)", Chest[id]);
			menu_additem(szMenu, line, "101")
			all++
		}
		if(pKey[id] > 0)
		{
			formatex(line, charsmax(line), "\rKeys \d|\y (%d)", pKey[id]);
			menu_additem(szMenu, line, "102")
			all++
		}
		if(all == 0)
		{
			MenuMod[id] = 0
			Menu(id)
		}
	}
	else if(MenuMod[id] == -1)
	{
		formatex(line, charsmax(line), "\d[\w%s\d]\w Your Skins", PLUGIN)
		szMenu = menu_create(line, "MenuHandler")
		
		new string[32], all
		
		for(new i = 1; i < AllWeapon; i++)
		{
			if(uWeapon[i][id] == 0)
			         continue;
		
			num_to_str(i, string, charsmax(string))
			formatex(line, charsmax(line), "\r%s \d|\y (%d)", WeaponNames[i], uWeapon[i][id]);
			menu_additem(szMenu, line, string)
			all++
		}
		
		if(Chest[id] > 0)
		{
			formatex(line, charsmax(line), "\rChests \d|\y (%d)", Chest[id]);
			menu_additem(szMenu, line, "101")
			all++
		}
		if(pKey[id] > 0)
		{
			formatex(line, charsmax(line), "\rKeys \d|\y (%d)", pKey[id]);
			menu_additem(szMenu, line, "102")
			all++
		}
		if(all == 0)
		{
			MenuMod[id] = 0
			Menu(id)
		}
	}
	else if(MenuMod[id] == 0)
	{
		formatex(line, charsmax(line), "\d[\w%s\d]\n\rYou have\w %d\r$ and \w%d\r kills", PLUGIN, Points[id], Kills[id])
		szMenu = menu_create(line, "MenuHandler")
		
		formatex(line, charsmax(line), "\wSkins")
		menu_additem(szMenu, line, "1")
		
		if(!inMarket[id])
		{
			formatex(line, charsmax(line), "\wChest Open & Buy")
			menu_additem(szMenu, line, "2")
		}
		else
		{
			formatex(line, charsmax(line), "\wChest Open & Buy \d[Take it back your item in market]")
			menu_additem(szMenu, line, "0")
		}
		
		formatex(line, charsmax(line), "\wMarket")
		menu_additem(szMenu, line, "3")
		
		if(!inMarket[id])
		{
			formatex(line, charsmax(line), "\wDustBin")
			menu_additem(szMenu, line, "4")
		}
		else
		{
			formatex(line, charsmax(line), "\wDustBin \d[Take it back your item in market]")
			menu_additem(szMenu, line, "0")
		}
		
		if(!inMarket[id])
		{
			formatex(line, charsmax(line), "\wGift^n^n\rNext rang:\d %s^n\yKills: \r%d\d/\r%d", Rangs[Rang[id] + 1], Kills[id], NeedKills[Rang[id]])
			menu_additem(szMenu, line, "5")
		}
		else
		{
			formatex(line, charsmax(line), "\wGift \d[Take it back your item in market]^n^n\rNext rang:\d %s^n\yKills: \r%d\d/\r%d", Rangs[Rang[id] + 1], Kills[id], NeedKills[Rang[id]])
			menu_additem(szMenu, line, "0")
		}
	}
	else if(MenuMod[id] == 1)
	{
		formatex(line, charsmax(line), "\d[\w%s\d]\w Your Skins", PLUGIN)
		szMenu = menu_create(line, "MenuHandler")
		
		new string[32], all
		
		for(new i = 1; i < AllWeapon; i++)
		{
			if(uWeapon[i][id] == 0)
				continue
				
			formatex(string, charsmax(string), "%d %d", i, Weapons[i])
			formatex(line, charsmax(line), "\r%s \d|\y (%d)", WeaponNames[i], uWeapon[i][id]);
			menu_additem(szMenu, line, string)
			all++
		}
		
		if(all == 0)
		{
			MenuMod[id] = 0
			Menu(id)
		}
	}
	else if(MenuMod[id] == 2)
	{
		formatex(line, charsmax(line), "\d[\w%s\d]\w Chest Open", PLUGIN)
		szMenu = menu_create(line, "MenuHandler")
		formatex(line, charsmax(line), "\dChest open^n\y   Chest: \r%d^n\y   Key:\r %d", Chest[id], pKey[id])
		menu_additem(szMenu, line, "1")
	}
	else if(MenuMod[id] == 3)
	{
		formatex(line, charsmax(line), "\d[\w%s\d]\w Marketplace", PLUGIN)
		szMenu = menu_create(line, "MenuHandler")
		
		new string[32], all
		
		if(!inMarket[id])
		{
			for(new i = 1; i < AllWeapon; i++)
			{
				if(i == WeaponinMarket[id] && uWeapon[i][id] > 0)
				{
					formatex(line, charsmax(line), "\rItem:\d %s^n\yCost:\d %d\r$", WeaponNames[i], MarketPoints[id])
					all++
				}
			}
			
			if(all == 0)
			{
				formatex(line, charsmax(line), "\dChoose something!")
				menu_additem(szMenu, line, "-1")
			}
		}
		
		if(!inMarket[id])
			formatex(line, charsmax(line), "\rGo^n")
		else
			formatex(line, charsmax(line), "\dTake it back^n")
			
		menu_additem(szMenu, line, "0")
		
		new name[32]
		
		for(new i = 0; i < get_maxplayers(); i++)
		{
			if(!is_user_connected(i))
				continue
				
			if(inMarket[i] && MarketPoints[i] > 0)
			{
				num_to_str(i, string, charsmax(string))
				
				get_user_name(i, name, charsmax(name))
				
				if(WeaponinMarket[i] && (101 != WeaponinMarket[i] || 102 == WeaponinMarket[i]))
				{
					formatex(line, charsmax(line), "\r%s \d|\y %s \d| \rCost:\y %d\r$", name, WeaponNames[WeaponinMarket[i]], MarketPoints[i])
					menu_additem(szMenu, line, string)
				}
			}
		}
	}
	else if(MenuMod[id] == 4)
	{
		formatex(line, charsmax(line), "\d[\w%s\d]\w Dustbin")
		szMenu = menu_create(line, "MenuHandler")
		
		new string[32], all
		
		for(new i = 1; i < AllWeapon; i++)
		{
			if(uWeapon[i][id] == 0)
				continue
				
			num_to_str(i, string, charsmax(string))
			formatex(line, charsmax(line), "\r%s \d|\y (%d)", WeaponNames[i], uWeapon[i][id])
			menu_additem(szMenu, line, string)
			all++
		}
		if(all == 0)
		{
			MenuMod[id] = 0;
			Menu(id)
		}
	}
	else if(MenuMod[id] == 5)
	{
		formatex(line, charsmax(line), "\d[\w%s\d]\w Gift")
		szMenu = menu_create(line, "MenuHandler")
		
		new all, name[32], string[32]
		get_user_name(aTarget[id], name, charsmax(name))
		
		if(aTarget[id] > 0 && is_user_alive(aTarget[id]))
		{
			formatex(line, charsmax(line), "\rTarget: \d%s", name)
			menu_additem(szMenu, line, "-1")
			
			for(new i = 1; i < AllWeapon; i++)
			{
				if(i == aThing[id] && uWeapon[i][id] > 0)
				{
					formatex(line, charsmax(line), "\rGift: \d%s", WeaponNames[i])
					menu_additem(szMenu, line, "-2")
					all++
				}
			}
			
			if(aThing[id] == 0 && all == 0)
			{
				formatex(line, charsmax(line) , "\dChoose something!")
				menu_additem(szMenu, line, "-2")
			}
			
			formatex(line, charsmax(line), "\rPoint:\d %d", aPoints[id])
			menu_additem(szMenu, line, "-4")
			formatex(line, charsmax(line), "\rGo")
			menu_additem(szMenu, line, "-3")
		}
		else
		{
			for(new i = 0; i < get_maxplayers(); i++)
			{
				if(is_user_alive(i))
				{
					get_user_name(i, name, charsmax(name))
					num_to_str(i, string, charsmax(string))
					menu_additem(szMenu, name, string)
				}
			}
		}
	}
	menu_display(id, szMenu)
}
				

public MenuHandler(id, szMenu, Key)
{
	if(Key == MENU_EXIT)
	{
		MenuMod[id] = 0;
		menu_destroy(szMenu)
		return PLUGIN_HANDLED
	}
	
	new aMenu[2], Data[4][32], sKey[32], Name[32], mName[32]
	menu_item_getinfo(szMenu, Key, aMenu[0], Data[0], 31, Data[1], 31, aMenu[1])
	
	parse(Data[0], sKey, charsmax(sKey))
	Key = str_to_num(sKey)
	
	if(MenuMod[id] == -2)
	{
		aThing[id] = Key
		MenuMod[id] = 5
		Menu(id)
		return PLUGIN_HANDLED
	}
	if(MenuMod[id] == -1)
	{
		MenuMod[id] = 3
		WeaponinMarket[id] = Key
		client_cmd(id, "messagemode Cost")
		Menu(id)
		return PLUGIN_HANDLED
	}
	else if(MenuMod[id] == 0)
	{
		MenuMod[id] = Key
		Menu(id)
		return PLUGIN_HANDLED
	}
	else if(MenuMod[id] == 1)
	{
		parse(Data[0], Data[2], 31, Data[3], 31)
		
		if(str_to_num(Data[3]) == 16 || str_to_num(Data[3]) == 26)
			UsingWeapon[1][id] = str_to_num(Data[2])
		else if(str_to_num(Data[3]) == 29)
			UsingWeapon[2][id] = str_to_num(Data[2])
		else
			UsingWeapon[0][id] = str_to_num(Data[2])
		return PLUGIN_HANDLED;
	}
	else if(MenuMod[id] == 2)
	{
		if(Key == 1)
		{
			if(Chest[id] > 0 && pKey[id] > 0)
			{
				Chest[id]--
				pKey[id]--
				//0ChestOpen(id) functie de afisare in motd
				Menu(id)
				return PLUGIN_HANDLED
			}
		}
	}
	else if(MenuMod[id] == 3)
	{
		if(Key == -1)
		{
			MenuMod[id] = -1
			Menu(id);
			return PLUGIN_HANDLED;
		}
		else if(Key == 0)
		{
			if(inMarket[id])
				inMarket[id] = false
			else if(MarketPoints[id] > 0)
			{
				get_user_name(id, Name, charsmax(Name))
				
				ColorChat(0, "!g[%s]:!t %s!y unladen a %s skin to market in %d!t$!y!", TAG, Name, WeaponNames[WeaponinMarket[id]], MarketPoints[id])
				inMarket[id] = true
			}
			Menu(id)
			return PLUGIN_HANDLED
		}
		else if(inMarket[Key] && Points[id] >= MarketPoints[Key])
		{
			get_user_name(Key, Name, charsmax(Name))
			get_user_name(id, mName, charsmax(mName))
			
			if(WeaponinMarket[Key] < 101)
			{
				ColorChat(0, "!g[%s]:!t %s!y bought a!t %s!y skin in %d!t $!y from !v%s!y!",TAG, mName, WeaponNames[WeaponinMarket[Key]], MarketPoints[Key], Name)
				uWeapon[WeaponinMarket[Key]][id]++
				uWeapon[WeaponinMarket[Key]][Key]--
			}

			Points[Key] += MarketPoints[Key]
			Points[id] -= MarketPoints[Key]
			//Save(Key)
			save_data(Key)
			//Save(id)
			save_data(id)
			inMarket[Key] = false
			MarketPoints[Key] = 0
			WeaponinMarket[Key] = 0
			MenuMod[id] = 0
		}
	}
	else if(MenuMod[id] == 4)
	{
		uWeapon[Key][id]--
		Menu(id)
		//Save(id)
		save_data(id)
		return PLUGIN_HANDLED
	}
	else if(MenuMod[id] == 5)
	{
		if(Key == -1)
		{
			aTarget[id] = 0;
		}
		if(Key == -2)
		{
			MenuMod[id] = -2
		}
		if(Key == -3)
		{
			if(uWeapon[aThing[id]][id] > 0)
			{
				uWeapon[aThing[id]][aTarget[id]]++
				uWeapon[aThing[id]][id]--
				Points[aTarget[id]] += aPoints[id]
				Points[id] -= aPoints[id]
				//Save(aTarget[id])
				//Save(id)
				save_data(aTarget[id])
				save_data(id)
				MenuMod[id] = 0
				aThing[id] = 0
				aTarget[id] = 0
				aPoints[id] = 0
				ColorChat(id, "!g[%s]:!y Successful gift giving!", TAG)
			}
		}
		if(Key == -4)
		{
			client_cmd(id, "messagemode Gift");
		}
		if(Key > 0)
			aTarget[id] = Key
		Menu(id)
		return PLUGIN_HANDLED
	}
	MenuMod[id] = 0;
	return PLUGIN_CONTINUE
}

public RegMenu(id)
{
	new string[128], name[32]
	formatex(string, charsmax(string), "\d[\w%s\d]\w \rRegistration\y Menu", PLUGIN)
	new szMenu = menu_create(string, "rMenuHandler")
	
	get_user_name(id, name, charsmax(name))
	
	formatex(string, charsmax(string), "\wAccount:\d %s", name)
	menu_additem(szMenu, string, "0")
	
	if(!Registered(id))
	{
		formatex(string, charsmax(string), "\wPassword:\d %s^n", Password[id])
		menu_additem(szMenu, string, "1")
		
		if(strlen(Password[id]) > 4)
		{
			formatex(string, charsmax(string), "\wRegister")
			menu_additem(szMenu, string, "2")
		}
		else
		{
			formatex(string, charsmax(string), "\dRegister")
			menu_additem(szMenu, string, "0")
		}
	}
	else
	{
		if(!Loged[id])
		{
			formatex(string, charsmax(string), "\wPassword:\d %s^n", Password[id])
			menu_additem(szMenu, string, "1")
			
			if(equal(SavedPassword[id], Password[id]))
			{
				formatex(string, charsmax(string), "Login!")
				menu_additem(szMenu, string, "3")
			}
			else
			{
				formatex(string, charsmax(string), "Login!")
				menu_additem(szMenu, string, "0")
			}
		}
		else
		{
			formatex(string, charsmax(string), "Logout")
			menu_additem(szMenu, string, "-1")
		}
	}
	menu_display(id, szMenu)
}

public rMenuHandler(id, szMenu, item)
{	
	if(item == MENU_EXIT)
	{
		menu_destroy(szMenu)
		return;
	}
	
	new data[9], name[64], Key;
	new access, callback;
	menu_item_getinfo(szMenu, item, access, data, charsmax(data), name, charsmax(name), callback)
	
	Key = str_to_num(data)
	
	if(Key == -1)
		ToLogout(id)
	if(Key == 0)
		RegMenu(id)
	if(Key == 1)
	{
		client_cmd(id, "messagemode UserPassword");
		RegMenu(id)
	}
	if(Key == 2)
	{
		ColorChat(id, "!g[%s]:!y Successful registration! [Your PW: !t%s!y]", TAG, Password[id])
		Register(id, Password[id])
		copy(SavedPassword[id], 31, Password[id])
		Loged[id] = true
		Menu(id)
	}
	if(Key == 3)
	{
		if(equal(SavedPassword[id], Password[id])) 
		{
			Loged[id] = true;
			ColorChat(id, "!g[%s]:!y Successful Login!", TAG);
			Menu(id)
		}
	}
}

public ToLogout(id)
{
	if(Loged[id])
	{
		Loged[id] = false
		Password[id] = ""
		ColorChat(id, "!g[%s]:!y Successful Logout!", TAG)
	}
}

public PlayerPassword(id)
{
	new Data[32]
	read_args(Data, 31)
	remove_quotes(Data)
	
	if(strlen(Data) < 5)
	{
		ColorChat(id, "!g[%s]:!y Your PW is too short!", TAG)
		client_cmd(id, "messagemode UserPassword")
		return PLUGIN_HANDLED
	}
	
	if(Loged[id])
	{
		return PLUGIN_HANDLED
	}
	
	copy(Password[id], 31, Data)
	RegMenu(id)
	return PLUGIN_CONTINUE
}

stock bool:Registered(id)
{
	new name[32]
	get_user_name(id, name, charsmax(name))
	
	new userInfo[40], userData[40]
	
	formatex(userInfo, charsmax(userInfo), "_%s_", name)
	
	if(nvault_get(g_vault_register, userInfo, userData, charsmax(userData)))
	{
		copy(SavedPassword[id], charsmax(SavedPassword), userData)
		return true
	}
	
	return false
}
	
	

Register(id, const rSavedPassword[])
{
	new name[32]
	get_user_name(id, name, charsmax(name))
	
	new userInfo[40], userData[40]
	
	formatex(userInfo, charsmax(userInfo), "_%s_", name)
	
	formatex(userData, charsmax(userData), "%s", rSavedPassword)
	
	nvault_set(g_vault_register, userInfo, userData)
	
	return PLUGIN_CONTINUE
}

public NameChange(id) 
{
	if(!is_user_connected(id))
		return FMRES_IGNORED;
		
	new OldName[32], NewName[32], Name[32];
	get_user_name(id, Name, 31);
	pev(id, pev_netname, OldName, charsmax(OldName));
	if(OldName[0])
	{
		get_user_info(id, "name", NewName, charsmax(NewName));
		if(!equal(OldName, NewName))
		{
			set_user_info(id, "name", OldName);
			//ColorChat(id, "!g[%s]:!y The name change is disabled!")
			return FMRES_HANDLED;
		}
	}
	return FMRES_IGNORED;
}

public MarketCost(id)
{
	if(inMarket[id] || !Loged[id])
		return PLUGIN_HANDLED
		
	new Data[32], Cost
	read_args(Data, charsmax(Data))
	remove_quotes(Data)
	
	Cost = str_to_num(Data)
	
	if(Cost < 0)
	{
		client_cmd(id, "messagemode Cost");
		return PLUGIN_HANDLED
	}
	else if(MarkMin >= Cost)
	{
		//ColorChat(id, "!g[%s]:!yYou can not sell anything over!t %d!y",PLUGIN, MarkMin)
		client_cmd(id, "messagemode Cost");
		return PLUGIN_HANDLED;
	}
	else
	{
		MarketPoints[id] = Cost
		Menu(id)
		MenuMod[id] = 3
		return PLUGIN_CONTINUE
	}
	
	return PLUGIN_CONTINUE
}


public GiftPoint(id)
{
	if(inMarket[id] || !Loged[id])
		return PLUGIN_HANDLED
		
	new Data[32], Cost
	read_args(Data, charsmax(Data))
	remove_quotes(Data)
	
	Cost = str_to_num(Data)
	
	if(Cost < 0 || Points[id] < Cost)
	{
		client_cmd(id, "messagemode Gift");
		return PLUGIN_HANDLED
	}
	else
	{
		aPoints[id] = Cost
		Menu(id)
		MenuMod[id] = 5
		return PLUGIN_CONTINUE
	}
	
	return PLUGIN_CONTINUE
}


save_data(id)
{
	if(!is_user_connected(id))
	return PLUGIN_CONTINUE
	
	new name[32]
	get_user_name(id, name, charsmax(name))
	
	new userInfo[40], userData[655], string[8], infobuffer[64]
	
	formatex(userInfo, charsmax(userInfo), "_%s_", name)
	
	formatex(infobuffer, charsmax(infobuffer), "%i, %i, %i, %i, %i", Kills[id], Points[id], pKey[id], Chest[id], Rang[id])
	add(userData, charsmax(userData), infobuffer)
	
	for(new i; i < MAX_SKINS; i++)
	{
		format(string, charsmax(string), "^"%i^" ", uWeapon[i][id])
		add(userData, charsmax(userData), string)
	}
	
	nvault_set(g_vault_save, userInfo, userData)
	
	return PLUGIN_CONTINUE
}

retrieve_data(id)
{
	new name[32]
	get_user_name(id, name, charsmax(name))
	
	new userInfo[40], userData[655]
	
	formatex(userInfo, charsmax(userInfo), "_%s_", name)
	
	nvault_get(g_vault_save, userInfo, userData, charsmax(userData))
	
}
	
	

public load_config_file(bool:parse_csgo)
{
	new path[64]
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/csgo/%s", path, CONFIG_FILE)
	
	// File not present
	if(!file_exists(path))
	{
		new error[100]
		formatex(error, sizeof(error) - 1, "[%s]:Fisierul %s nu a fost detectat!",TAG, CONFIG_FILE)
		set_fail_state(error)
		return
	}
	
	if(parse_csgo)
	{
		new Line[128], Data[4][48], section, inc
	
		// Open customization file for reading
		new file = fopen(path, "rt")
	
		while (file && !feof(file))
		{
			// Read one line at a time
			fgets(file, Line, charsmax(Line))
		
			// Replace newlines with a null character to prevent headaches
			replace(Line, charsmax(Line), "^n", "")
		
			// Blank line or comment
			if(!Line[0] || Line[0] == ';') continue;
		
			// New section starting
			if (Line[0] == '[')
			{
				inc = 0
				section++
				continue;
			}

			switch (section)
			{
				case 1:
				{
					parse(Line, Data[0], 31, Data[1], 31)
				
					copy(Rangs[inc], 31, Data[0])
					NeedKills[inc] = str_to_num(Data[1])
					inc++
				}
				case 2:
				{
					if(strlen(Line) < 5) continue;
				
					parse(Line, Data[0], 31, Data[1], 31, Data[2], 47, Data[3], 31)
				
					Weapons[AllWeapon] = str_to_num(Data[0])
					copy(WeaponNames[AllWeapon], 31, Data[1])
				
					if(ValidMdl(Data[2]))
					{
						precache_model(Data[2])
						copy(WeaponMdls[AllWeapon], 47, Data[2])
					}
					WeaponDrop[AllWeapon] = str_to_num(Data[3])
					AllWeapon++
				}
				case 3:
				{
					if(strlen(Line) < 5) continue;
				
					parse(Line, Data[0], 31, Data[1], 47)
				
					if(ValidMdl(Data[1]))
					{
						precache_model(Data[1])
						copy(DefaultSkin[str_to_num(Data[0])], 47, Data[1])
					}
				}
			}
		}
		if(file) fclose(file)
	}
	else
	{
			// Set up some vars to hold parsing info
		new linedata[1024], key[64], value[960], section
	
		// Open customization file for reading
		new file = fopen(path, "rt")
		
		while (file && !feof(file))
		{
			// Read one line at a time
			fgets(file, linedata, charsmax(linedata))
		
			// Replace newlines with a null character to prevent headaches
			replace(linedata, charsmax(linedata), "^n", "")
		
			// Blank line or comment
			if (!linedata[0] || linedata[0] == ';') continue;
		
			// New section starting
			if (linedata[0] == '[')
			{
				section++
				continue;
			}
	
			// Get key and value(s)
			strtok(linedata, key, charsmax(key), value, charsmax(value), '=')

			// Trim spaces
			trim(key)
			trim(value)

			switch (section)
			{
				case 4:
				{
					
				}
			}
		}
		if(file) fclose(file)
	}
		
}


stock bool:ValidMdl(Mdl[])
{
	if(containi(Mdl, ".mdl") != -1)
	{
		return true;
	}
	return false;
}

stock PlayMusic(id, const sound[])
{
	if(id == 0)
	{
		if (equal(sound[strlen(sound)-4], ".mp3"))
			client_cmd(0, "mp3 play ^"sound/%s^"", sound)
		else
			client_cmd(0, "spk ^"%s^"", sound)
	} 
	else 
	{
		if(is_user_connected(id) && is_user_alive(id))
		{
			if (equal(sound[strlen(sound)-4], ".mp3"))
				client_cmd(id, "mp3 play ^"sound/%s^"", sound)
			else
				client_cmd(id, "spk ^"%s^"", sound)			
		}
	}
}

stock ColorChat(const id, const input[], any:...)
{
	new Count = 1, Players[32];
	static Msg[191];
	vformat(Msg, 190, input, 3);
	
	replace_all(Msg, 190, "!g", "^4");
	replace_all(Msg, 190, "!y", "^1");
	replace_all(Msg, 190, "!t", "^3");

	if(id) Players[0] = id; else get_players(Players, Count, "ch");
	{
		for (new i = 0; i < Count; i++)
		{
			if (is_user_connected(Players[i]))
			{
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, Players[i]);
				write_byte(Players[i]);
				write_string(Msg);
				message_end();
			}
		}
	}
	return PLUGIN_HANDLED
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1048\\ f0\\ fs16 \n\\ par }
*/
