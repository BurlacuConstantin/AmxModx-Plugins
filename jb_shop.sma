#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <cstrike>
#include <engine>
#include <hamsandwich>
#include <licenta_online>

#pragma tabsize 0 

#define PLUGIN "JB Shop"
#define VERSION "0.1"
#define AUTHOR "AsuStar"

//------------------------- PLAYER -----------------------------
new const tag_shop[] = "!v[JailBreak Shop]:!g"

new g_tero[] = "\w |Terorists Shop|"

new g_cts[] = "\w |CounterTs Shop|"

#define TASK_INVIZIBILITY 54234
#define TASK_SPEED 32454

new bool:g_inviziblity[33],bool:HasSpeed[33]

// ================= TERORISTS CVARS ================= //

new cvar_plugin_activat,cvar_glock_ammo,cvar_glock_money,cvar_health_ammount,cvar_health_money,cvar_armor_ammount,cvar_armor_money
new cvar_invizibility_time,cvar_invizibility_money,cvar_speed_time,cvar_speed_value,cvar_speed_money,cvar_grenade_ammo,cvar_grenade_money

// ================= TERORISTS CVARS ================= //


// ================= COUNTER-TERORISTS CVARS ================= //
new cvar_deagle_ammo,cvar_deagle_money,cvar_m4a1_ammo,cvar_m4a1_money,cvar_ak47_ammo,cvar_ak47_money
//------------------------- PLAYER -----------------------------


//------------------------ VIP ---------------------------------
new const tag_shop_vip[] = "!v[JailBreak VIP Shop]:!g"

new g_sz_tero[] = "\w |Terorists VIP Shop|"

new g_sz_cts[] = "\w |CounterTs VIP Shop|"

#define TASK_INVIZIBILITY_VIP 54233
#define TASK_SPEED_VIP 32455

new bool:g_inviziblity_vip[33],bool:HasSpeed_vip[33]


new cvar_glock_ammo_vip,cvar_glock_money_vip,cvar_health_ammount_vip,cvar_health_money_vip,cvar_armor_ammount_vip,cvar_armor_money_vip
new cvar_invizibility_time_vip,cvar_invizibility_money_vip,cvar_speed_time_vip,cvar_speed_value_vip,cvar_speed_money_vip,cvar_grenade_ammo_vip,cvar_grenade_money_vip

new cvar_deagle_ammo_vip,cvar_deagle_money_vip,cvar_m4a1_ammo_vip,cvar_m4a1_money_vip,cvar_ak47_ammo_vip,cvar_ak47_money_vip
//------------------------ VIP ---------------------------------


new g_acces[33]

public plugin_init()
{
	register_plugin(PLUGIN,VERSION,AUTHOR)
	
	register_clcmd("say /shop","cmd_shop")
	register_clcmd("say_team /shop","cmd_shop")
	
	register_clcmd("say shop","cmd_shop")
	register_clcmd("say_team shop","cmd_shop")
	
	register_clcmd("say /vipshop","cmd_shop")
	register_clcmd("say_team /vipshop","cmd_shop")
	
	register_clcmd("say vipshop","cmd_shop")
	register_clcmd("say_team vipshop","cmd_shop")
	
	
	register_event("DeathMsg" , "DeathMsgEvent" , "a")
	RegisterHam(Ham_Spawn, "player", "HAM_Spawn_Post", 1)
	RegisterHam(Ham_Item_PreFrame,"player","PreFrame_Post",1)
	
	
	cvar_plugin_activat = register_cvar("cvar_plugin_activat","1") // defaut 1
	
	// ================= TERORISTS CVARS ================= //
	
	cvar_glock_ammo = register_cvar("cvar_glock_munitie","20")
	cvar_glock_money = register_cvar("cvar_glock_pret","3000")
	
	cvar_health_ammount = register_cvar("cvar_viata_valoare","200")
	cvar_health_money = register_cvar("cvar_viata_pret","2500")
	
	cvar_armor_ammount = register_cvar("cvar_armura_valoare","100")
	cvar_armor_money = register_cvar("cvar_armura_pret","2000")
	
	cvar_invizibility_time = register_cvar("cvar_invizibilitate_durata","10.0")
	cvar_invizibility_money = register_cvar("cvar_invizibilitate_pret","5000")
	
	cvar_speed_time = register_cvar("cvar_viteza_timp","10.0")
	cvar_speed_value = register_cvar("cvar_viteza_valoare","450.0")
	cvar_speed_money = register_cvar("cvar_viteza_pret","1000")
	
	cvar_grenade_ammo = register_cvar("cvar_grenada_munitie","2")
	cvar_grenade_money = register_cvar("cvar_grenada_pret","300")	
	
	// ================= TERORISTS CVARS ================= //
	
	
	// ================= COUNTER-TERORISTS CVARS ================= //
	
	cvar_deagle_ammo = register_cvar("cvar_deagle_munitie","10")
	cvar_deagle_money = register_cvar("cvar_deagle_pret", "1000")
	
	cvar_m4a1_ammo = register_cvar("cvar_m4a1_munitie","20")
	cvar_m4a1_money = register_cvar("cvar_m4a1_pret","2000")
	
	cvar_ak47_ammo = register_cvar("cvar_ak47_munitie","30")
	cvar_ak47_money = register_cvar("cvar_ak47_pret","1500")
	
	
	
//----------------------------------------------------------------------------------------//

	cvar_glock_ammo_vip = register_cvar("cvar_glock_munitie_vip","30")
	cvar_glock_money_vip = register_cvar("cvar_glock_pret_vip","2000")
	
	cvar_health_ammount_vip = register_cvar("cvar_viata_valoare_vip","100")
	cvar_health_money_vip = register_cvar("cvar_viata_pret_vip","2000")
	
	cvar_armor_ammount_vip = register_cvar("cvar_armura_valoare_vip","150")
	cvar_armor_money_vip = register_cvar("cvar_armura_pret_vip","100")
	
	cvar_invizibility_time_vip = register_cvar("cvar_invizibilitate_durata_vip","15.0")
	cvar_invizibility_money_vip = register_cvar("cvar_invizibilitate_pret_vip","3000")
	
	cvar_speed_time_vip = register_cvar("cvar_viteza_timp_vip","15.0")
	cvar_speed_value_vip = register_cvar("cvar_viteza_valoare_vip","500.0")
	cvar_speed_money_vip = register_cvar("cvar_viteza_pret_vip","1500")
	
	cvar_grenade_ammo_vip = register_cvar("cvar_grenada_munitie_vip","3")
	cvar_grenade_money_vip = register_cvar("cvar_grenada_pret_vip","200")
	
	
	//--------------------------- TERORISTS --------------------------------------
	
	cvar_deagle_ammo_vip = register_cvar("cvar_deagle_munitie_vip","20")
	cvar_deagle_money_vip = register_cvar("cvar_deagle_pret_vip","200")
	
	cvar_m4a1_ammo_vip = register_cvar("cvar_m4a1_munitie_vip","40")
	cvar_m4a1_money_vip = register_cvar("cvar_m4a1_pret_vip","1500")
	
	cvar_ak47_ammo_vip = register_cvar("cvar_ak47_munitie_vip","50")
	cvar_ak47_money_vip = register_cvar("cvar_ak47_pret_vip","1000")
	
}

public plugin_precache()
{
	licence_cheker()
}

public plugin_cfg()
{
	new cfgdir[64]
	get_configsdir(cfgdir, charsmax(cfgdir))
	
	server_cmd("exec %s/JailBreak_SHOP_Settings.cfg", cfgdir)
}

public client_connect(id)
{
	g_inviziblity[id] = false
	HasSpeed[id] = false
	
	g_inviziblity_vip[id] = false
	HasSpeed_vip[id] = false
	
	g_acces[id] = 0
}

public client_disconnect(id)
{
	g_inviziblity[id] = false
	HasSpeed[id] = false
	
	g_inviziblity_vip[id] = false
	HasSpeed_vip[id] = false
	
	g_acces[id] = 0
}

public DeathMsgEvent()
{
	new id = read_data(2)
	
	if(get_user_flags(id) && is_user_vip(id))
	{
		if(g_inviziblity_vip[id])
		{
			g_inviziblity_vip[id] = false
			
			remove_task(id+TASK_INVIZIBILITY_VIP)
		}
		else if(HasSpeed_vip[id])
		{
			HasSpeed_vip[id] = false
			
			remove_task(id+TASK_SPEED_VIP)
		}
	}
	else
	{
		if(g_inviziblity[id])
		{
			g_inviziblity[id] = false
			
			remove_task(id+TASK_INVIZIBILITY)
		}
		else if(HasSpeed[id])
		{
			HasSpeed[id] = false
			
			remove_task(id+TASK_SPEED)
		}
	}	
}

public HAM_Spawn_Post(id)
{
	if(get_user_flags(id) && is_user_vip(id))
	{
		if(g_inviziblity_vip[id])
		{
			g_inviziblity_vip[id] = false
			
			remove_task(id+TASK_INVIZIBILITY_VIP)
		}
		else if(HasSpeed_vip[id])
		{
			HasSpeed_vip[id] = false
			
			remove_task(id+TASK_SPEED_VIP)
		}
	}
	else
	{
		if(g_inviziblity[id])
		{
			g_inviziblity[id] = false
			
			remove_task(id+TASK_INVIZIBILITY)
		}
		else if(HasSpeed[id])
		{
			HasSpeed[id] = false
			
			remove_task(id+TASK_SPEED)
		}
	}
	
	g_acces[id] = 0
}

public PreFrame_Post(id)
{
	if(HasSpeed[id])
	{
		set_user_maxspeed(id,get_pcvar_float(cvar_speed_value))
	}
	else if(HasSpeed_vip[id])
	{
		set_user_maxspeed(id,get_pcvar_float(cvar_speed_value_vip))
	}
}

public cmd_shop(id)
{
	if(get_pcvar_num(cvar_plugin_activat) != 1)
		   return PLUGIN_HANDLED
		   
		
		if(is_user_alive(id))
		{
			new csTEAMS:team = cs_get_user_team(id)
			
			if(get_user_flags(id) && is_user_vip(id))
			{
				if(g_acces[id] == 1)
				{
					ColorChat(id,"%s Poti folosi !VIP Shop-ul!g doar o data pe runda!",tag_shop_vip)
					return PLUGIN_HANDLED
				}
				
				switch(team)
				{
					case CS_TEAM_T:
					{
						shop_vip_tero(id)
						g_acces[id] = 1
					}
					case CS_TEAM_CT:
					{
						shop_vip_cts(id)
						g_acces[id] = 1
					}
					case CS_TEAM_SPECTATOR:
					{
						ColorChat(id,"%s Nu poti folosi !VIP Shop-ul!g la spectator!",tag_shop_vip)
						return PLUGIN_HANDLED
					}
				}
			}
			else
			{
				if(g_acces[id] == 1)
				{
					ColorChat(id,"%s Poti folosi !Shop-ul!g doar o data pe runda!",tag_shop)
					return PLUGIN_HANDLED
				}
				
				switch(team)
				{
					case CS_TEAM_T:
					{
						shop_normal_tero(id)
						g_acces[id] = 1
					}
					case CS_TEAM_CT:
					{
						shop_normal_cts(id)
						g_acces[id] = 1
					}
					case CS_TEAM_SPECTATOR:
					{
						ColorChat(id,"%s Nu poti folosi !Shop-ul!g la spectator!",tag_shop)
						return PLUGIN_HANDLED
					}
				}
			}
		}
		else
		{
			if(get_user_flags(id) && is_user_vip(id))
			{
				ColorChat(id,"%s Nu poti folosi !vVIP Shop-ul!g cand esti mort!",tag_shop_vip)
				return PLUGIN_HANDLED
			}
			else
			{
				ColorChat(id,"%s Nu poti folosi !vShop-ul!g cand esti mort!",tag_shop)
				return PLUGIN_HANDLED
			}
		}
		
		return PLUGIN_CONTINUE
}

public shop_vip_tero(id)
{
	if(is_user_alive(id))
	{
		static Title[150],Item1[150],Item2[150],Item3[150],Item4[150],Item5[150],Item6[150]
		
		new iMoney = cs_get_user_money(id)
		
		formatex(Title, sizeof(Title) - 1, "\y%s^n\w  Money:[\r%s\w]\r",g_sz_tero,iMoney)
		
		if(iMoney >= get_pcvar_num(cvar_glock_money_vip))
		{
			formatex(Item1, sizeof(Item1) - 1, "\wGlock \R\r%i$",get_pcvar_num(cvar_glock_money_vip))
		}
		else
		{
			formatex(Item1, sizeof(Item1) - 1, "\dGlock \R\r%i$",get_pcvar_num(cvar_glock_money_vip))
		}
		if(iMoney >= get_pcvar_num(cvar_health_money_vip))
		{
			formatex(Item2, sizeof(Item2) - 1, "\wHealth +%i \R\r%i$",get_pcvar_num(cvar_health_ammount_vip),get_pcvar_num(cvar_health_money_vip))
		}
		else
		{
			formatex(Item2, sizeof(Item2) - 1, "\dHealth +%i \R\r%i$",get_pcvar_num(cvar_health_ammount_vip),get_pcvar_num(cvar_health_money_vip))
		}
		if(iMoney >= get_pcvar_num(cvar_armor_money_vip))
		{
			formatex(Item3, sizeof(Item3) - 1, "\wArmor +%i \R\r%i$",get_pcvar_num(cvar_armor_ammount_vip),get_pcvar_num(cvar_armor_money_vip))
		}
		else
		{
			formatex(Item3, sizeof(Item3) - 1, "\dArmor +%i \R\r%i$",get_pcvar_num(cvar_armor_ammount_vip),get_pcvar_num(cvar_armor_money_vip))
		}
		if(iMoney >= get_pcvar_num(cvar_invizibility_money_vip))
		{
			formatex(Item4, sizeof(Item4) - 1, "\wInvizibility \R\r%i$",get_pcvar_num(cvar_invizibility_money_vip))
		}
		else
		{
			formatex(Item4, sizeof(Item4) - 1, "\dInvizibility \R\r%i$",get_pcvar_num(cvar_invizibility_money_vip))
		}
		if(iMoney >= get_pcvar_num(cvar_speed_money_vip))
		{
			formatex(Item5, sizeof(Item5) - 1, "\wSpeed \R\r%i$",get_pcvar_num(cvar_speed_money_vip))
		}
		else
		{
			formatex(Item5, sizeof(Item5) - 1, "\dSpeed \R\r%i$",get_pcvar_num(cvar_speed_money_vip))
		}
		if(iMoney >= get_pcvar_num(cvar_grenade_money_vip))
		{
			formatex(Item6, sizeof(Item6) - 1, "\wHE Grenade +%i \R\r%i$",get_pcvar_num(cvar_grenade_ammo_vip),get_pcvar_num(cvar_grenade_money_vip))
		}
		else
		{
			formatex(Item6, sizeof(Item6) - 1, "\dHE Grenade +%i \R\r%i$",get_pcvar_num(cvar_grenade_ammo_vip),get_pcvar_num(cvar_grenade_money_vip))
		}
		
		new tero_vip_shop = menu_create(Title, "sub_tero_vip_shop", 0)
		
		menu_additem(tero_vip_shop, Item1, "1", 0, -1)
		menu_additem(tero_vip_shop, Item2, "2", 0, -1)
		menu_additem(tero_vip_shop, Item3, "3", 0, -1)
		menu_additem(tero_vip_shop, Item4, "4", 0, -1)
		menu_additem(tero_vip_shop, Item5, "5", 0, -1)
		menu_additem(tero_vip_shop, Item6, "6", 0, -1)
		
		menu_setprop(tero_vip_shop, MPROP_EXIT, MEXIT_ALL)
		menu_display(id,tero_vip_shop , 0)
	}
}

public shop_vip_cts(id)
{
	if(is_user_alive(id))
	{
		static Title[150],Item1[150],Item2[150],Item3[150]
		
		new iMoney = cs_get_user_money(id)
		
		formatex(Title, sizeof(Title) - 1, "\y%s^n\w  Money:[\r%i\w]\r",g_sz_cts,iMoney)

		if(iMoney >= get_pcvar_num(cvar_deagle_money_vip))
		{
			formatex(Item1, sizeof(Item1) - 1, "\wDeagle \R\r%i$",get_pcvar_num(cvar_deagle_money_vip))
		}
		else
		{
			formatex(Item1, sizeof(Item1) - 1, "\dDeagle \R\r%i$",get_pcvar_num(cvar_deagle_money_vip))
		}
		if(iMoney >= get_pcvar_num(cvar_m4a1_money_vip))
		{
			formatex(Item2, sizeof(Item2) - 1, "\wM4A1 \R\r%i$",get_pcvar_num(cvar_m4a1_money_vip))
		}
		else
		{
			formatex(Item2, sizeof(Item2) - 1, "\dM4A1 \R\r%i$",get_pcvar_num(cvar_m4a1_money_vip))
		}
		if(iMoney >= get_pcvar_num(cvar_ak47_money_vip))
		{
			formatex(Item3, sizeof(Item3) - 1, "\wAK47 \R\r%i$",get_pcvar_num(cvar_ak47_money_vip))
		}
		else
		{
			formatex(Item3, sizeof(Item3) - 1, "\dAK47 \R\r%i$",get_pcvar_num(cvar_ak47_money_vip))
		}
		
		new cts_vip_shop = menu_create(Title, "sub_cts_vip_shop")
		
		menu_additem(cts_vip_shop, Item1, "1", 0, -1)
		menu_additem(cts_vip_shop, Item2, "2", 0, -1)
		menu_additem(cts_vip_shop, Item3, "3", 0, -1)
		
		menu_setprop(cts_vip_shop, MPROP_EXIT, MEXIT_ALL)
		menu_display(id,cts_vip_shop , 0)
	}
}

public shop_normal_tero(id)
{
	if(is_user_alive(id))
	{
		static Title[150],Item[150],Item2[150],Item3[150],Item4[150],Item5[150],Item6[150]
		
		new iMoney = cs_get_user_money(id)
		
		formatex(Title, sizeof(Title) - 1, "\y%s^n\w  Money:[\r%i\w]\r",g_tero,iMoney)
		
		if(iMoney >= get_pcvar_num(cvar_glock_money))
		{
			formatex(Item, sizeof(Item) - 1, "\wGlock \R\r%i$",get_pcvar_num(cvar_glock_money))
		}
		else
		{
			formatex(Item, sizeof(Item) - 1, "\dGlock \R\r%i$",get_pcvar_num(cvar_glock_money))
		}
		if(iMoney >= get_pcvar_num(cvar_health_money))
		{
			formatex(Item2, sizeof(Item2) - 1, "\wHealth +%i \R\r%i$",get_pcvar_num(cvar_health_ammount),get_pcvar_num(cvar_health_money))
		}
		else
		{
			formatex(Item2, sizeof(Item2) - 1, "\dHealth +%i \R\r%i$",get_pcvar_num(cvar_health_ammount),get_pcvar_num(cvar_health_money))
		}
		if(iMoney >= get_pcvar_num(cvar_armor_money))
		{
			formatex(Item3, sizeof(Item3) - 1, "\wArmor +%i \R\r%i$",get_pcvar_num(cvar_armor_ammount),get_pcvar_num(cvar_armor_money))
		}
		else
		{
			formatex(Item3, sizeof(Item3) - 1, "\dArmor +%i \R\r%i$",get_pcvar_num(cvar_armor_ammount),get_pcvar_num(cvar_armor_money))
		}
		if(iMoney >= get_pcvar_num(cvar_invizibility_money))
		{
			formatex(Item4, sizeof(Item4) - 1, "\wInvizibility \R\r%i$",get_pcvar_num(cvar_invizibility_money))
		}
		else
		{
			formatex(Item4, sizeof(Item4) - 1, "\dInvizibility \R\r%i$",get_pcvar_num(cvar_invizibility_money))
		}
		if(iMoney >= get_pcvar_num(cvar_speed_money))
		{
			formatex(Item5, sizeof(Item5) - 1, "\wSpeed \R\r%i$",get_pcvar_num(cvar_speed_money))
		}
		else
		{
			formatex(Item5, sizeof(Item5) - 1, "\dSpeed \R\r%i$",get_pcvar_num(cvar_speed_money))
		}
		if(iMoney >= get_pcvar_num(cvar_grenade_money))
		{
			formatex(Item6, sizeof(Item6) - 1, "\wHE Grenade +%i \R\r%i$",get_pcvar_num(cvar_grenade_ammo),get_pcvar_num(cvar_grenade_money))
		}
		else
		{
			formatex(Item6, sizeof(Item6) - 1, "\dHE Grenade +%i \R\r%i$",get_pcvar_num(cvar_grenade_ammo),get_pcvar_num(cvar_grenade_money))
		}
	
		new tero_shop = menu_create(Title, "sub_tero_shop", 0)
		
		menu_additem(tero_shop, Item, "1", 0, -1)
		menu_additem(tero_shop, Item2, "2", 0, -1)
		menu_additem(tero_shop, Item3, "3", 0, -1)
		menu_additem(tero_shop, Item4, "4", 0, -1)
		menu_additem(tero_shop, Item5, "5", 0, -1)
		menu_additem(tero_shop, Item6, "6", 0, -1)
		
		menu_setprop(tero_shop, MPROP_EXIT, MEXIT_ALL)
		menu_display(id,tero_shop , 0)
	}
}
	
	
public shop_normal_cts(id)
{
	if(is_user_alive(id))
	{
		static Title[150],Item[150],Item2[150],Item3[150]
		
		new iMoney = cs_get_user_money(id)
		
		formatex(Title, sizeof(Title) - 1, "\y%s^n\w  Money:[\r%i\w]\r",g_cts,cs_get_user_money(id))

		if(iMoney >= get_pcvar_num(cvar_deagle_money))
		{
			formatex(Item, sizeof(Item) - 1, "\wDeagle \R\r%i$",get_pcvar_num(cvar_deagle_money))
		}
		else
		{
			formatex(Item, sizeof(Item) - 1, "\dDeagle \R\r%i$",get_pcvar_num(cvar_deagle_money))
		}
		if(iMoney >= get_pcvar_num(cvar_m4a1_money))
		{
			formatex(Item2, sizeof(Item2) - 1, "\wM4A1 \R\r%i$",get_pcvar_num(cvar_m4a1_money))
		}
		else
		{
			formatex(Item2, sizeof(Item2) - 1, "\dM4A1 \R\r%i$",get_pcvar_num(cvar_m4a1_money))
		}
		if(iMoney >= get_pcvar_num(cvar_ak47_money))
		{
			formatex(Item3, sizeof(Item3) - 1, "\wAK47 \R\r%i$",get_pcvar_num(cvar_ak47_money))
		}
		else
		{
			formatex(Item3, sizeof(Item3) - 1, "\dAK47 \R\r%i$",get_pcvar_num(cvar_ak47_money))
		}
		
		new cts_shop = menu_create(Title, "sub_cts_shop")
		
		menu_additem(cts_shop, Item, "1", 0, -1)
		menu_additem(cts_shop, Item2, "2", 0, -1)
		menu_additem(cts_shop, Item3, "3", 0, -1)
		
		menu_setprop(cts_shop, MPROP_EXIT, MEXIT_ALL);
		menu_display(id,cts_shop , 0)
	}
}

public sub_cts_vip_shop(id, cts_vip_shop, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(cts_vip_shop)
   		remove_task(id)
		return PLUGIN_HANDLED
	}
	new Data[7], Name[64]
	new Access, Callback
	menu_item_getinfo(cts_vip_shop, item, Access, Data,5, Name, 63, Callback)
	
	new Key = str_to_num(Data)
	
	switch (Key)
	{
		case 1:
		{
			new iMoney = cs_get_user_money( id ) - get_pcvar_num(cvar_deagle_money_vip)
			
			if(iMoney < 0)
			{
				ColorChat(id,"%s Fonduri insuficiente!",tag_shop_vip)
				return 1
			}
			else
			{
				give_item(id,"weapon_deagle")
				
				cs_set_user_bpammo(id,CSW_DEAGLE, get_pcvar_num(cvar_deagle_ammo_vip))
				
				cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(cvar_deagle_money_vip))
				
				ColorChat(id,"%s Ai cumparat !vDeagle!g!",tag_shop_vip)
			}
		}
		case 2:
		{
			new iMoney = cs_get_user_money( id ) - get_pcvar_num(cvar_m4a1_money_vip)
			
			if(iMoney < 0)
			{
				ColorChat(id,"%s Fonduri insuficiente!",tag_shop_vip)
				return 1
			}
			else
			{
				give_item(id,"weapon_m4a1")
				
				cs_set_user_bpammo(id,CSW_M4A1, get_pcvar_num(cvar_m4a1_ammo_vip))
				
				cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(cvar_m4a1_money_vip))
				
				ColorChat(id,"%s Ai cumparat !vM4A1!g!",tag_shop_vip)
			}
		}
		case 3:
		{
			new iMoney = cs_get_user_money( id ) - get_pcvar_num(cvar_ak47_money_vip)
			
			if(iMoney < 0)
			{
				ColorChat(id,"%s Fonduri insuficiente!",tag_shop_vip)
				return 1
			}
			else
			{
				give_item(id,"weapon_ak47")
				
				cs_set_user_bpammo(id,CSW_AK47, get_pcvar_num(cvar_ak47_ammo_vip))
				
				cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(cvar_ak47_money_vip))
				
				ColorChat(id,"%s Ai cumparat !vAK47!g!",tag_shop_vip)
			}
		}
	}
	menu_destroy(cts_vip_shop)
	return PLUGIN_HANDLED
}


public sub_tero_vip_shop(id, tero_vip_shop, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(tero_vip_shop)
   		remove_task(id)
		return PLUGIN_HANDLED
	}
	new Data[7], Name[64]
	new Access, Callback
	menu_item_getinfo(tero_vip_shop, item, Access, Data,5, Name, 63, Callback)
	
	new Key = str_to_num(Data)
	
	switch (Key)
	{
		case 1:
		{
			new iMoney = cs_get_user_money( id ) - get_pcvar_num(cvar_glock_money_vip)
			
			if(iMoney < 0)
			{
				ColorChat(id,"%s Fonduri insuficiente!",tag_shop_vip)
				return 1
			}
			else
			{
				give_item(id,"weapon_glock18")
				cs_set_user_bpammo(id,CSW_GLOCK18,get_pcvar_num(cvar_glock_ammo_vip))
				
				cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(cvar_glock_money_vip))
				
				ColorChat(id,"%s Ai cumparat !vGlock!g!",tag_shop_vip)
			}
		}
		case 2:
		{
			new iMoney = cs_get_user_money( id ) - get_pcvar_num(cvar_health_money_vip)
	
			if(iMoney < 0)
			{
				ColorChat(id,"%s Fonduri insuficiente!",tag_shop_vip)
				return 1
			}
			else
			{
				set_user_health(id,get_user_health(id) + get_pcvar_num(cvar_health_ammount_vip))
				
				cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(cvar_health_money_vip))
				
				ColorChat(id,"%s Ai cumparat !vViata!g!",tag_shop_vip)
			}
		}
		case 3:
		{
			new iMoney = cs_get_user_money( id ) - get_pcvar_num(cvar_armor_money_vip)
	
			if(iMoney < 0)
			{
				ColorChat(id,"%s Fonduri insuficiente!",tag_shop_vip)
				return 1
			}
			else
			{
				set_user_armor(id,get_user_armor(id) + get_pcvar_num(cvar_armor_ammount_vip))
				
				cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(cvar_armor_money_vip))
	
				ColorChat(id,"%s Ai cumparat !vArmura!g!",tag_shop_vip)
			}
		}
		case 4:
		{
			new iMoney = cs_get_user_money( id ) - get_pcvar_num(cvar_invizibility_money_vip)
	
			if(iMoney < 0)
			{
				ColorChat(id,"%s Fonduri insuficiente!",tag_shop_vip)
				return 1
			}
			else
			{
				g_inviziblity_vip[id] = true
				
				set_entity_visibility(id, 0)
				
				cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(cvar_invizibility_money_vip))
		
				ColorChat(id,"%s Ai cumparat !vInvizibilitate!g!",tag_shop_vip)
				
				set_task(get_pcvar_float(cvar_invizibility_time_vip),"remove_invizibility_vip",id+TASK_INVIZIBILITY_VIP)
			}
		}
		case 5:
		{
			new iMoney = cs_get_user_money( id ) - get_pcvar_num(cvar_speed_money_vip)
	
			if(iMoney < 0)
			{
				ColorChat(id,"%s Fonduri insuficiente!",tag_shop_vip)
				return 1
			}
			else 
			{
				HasSpeed_vip[id] = true
				
				set_user_maxspeed(id,get_pcvar_float(cvar_speed_value_vip))
				
				cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(cvar_speed_money_vip))
				
				ColorChat(id,"%s Ai cumparat !vViteza!g!",tag_shop_vip)
				
				set_task(get_pcvar_float(cvar_speed_time_vip),"remove_speed_vip",id+TASK_SPEED_VIP)
			}
		}
		case 6:
		{
			new iMoney = cs_get_user_money( id ) - get_pcvar_num(cvar_grenade_money_vip)
			
			if(iMoney < 0)
			{
				ColorChat(id,"%s Fonduri insuficiente!",tag_shop_vip)
				return 1
			}
			else
			{
				give_item(id,"weapon_hegrenade")
				cs_set_user_bpammo(id,CSW_HEGRENADE,get_pcvar_num(cvar_grenade_ammo_vip))
				
				cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(cvar_grenade_money_vip))
			
				ColorChat(id,"%s Ai cumparat !vHeGrenade!g!",tag_shop_vip)
			}
		}
			
	}
	menu_destroy(tero_vip_shop)
	return PLUGIN_HANDLED
}
			

public sub_cts_shop(id,cts_shop, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(cts_shop)
   		remove_task(id)
		return PLUGIN_HANDLED
	}
	new Data[7], Name[64]
	new Access, Callback
	menu_item_getinfo(cts_shop, item, Access, Data,5, Name, 63, Callback)
	
	new Key = str_to_num(Data)
	
	switch (Key)
	{
		case 1:
		{
			new iMoney = cs_get_user_money( id ) - get_pcvar_num(cvar_deagle_money)
			
			if(iMoney < 0)
			{
				ColorChat(id,"%s Fonduri insuficiente!",tag_shop)
				return 1
			}
			else
			{
				give_item(id,"weapon_deagle")
				
				cs_set_user_bpammo(id,CSW_DEAGLE, get_pcvar_num(cvar_deagle_ammo))
				
				cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(cvar_deagle_money))
				
				ColorChat(id,"%s Ai cumparat !vDeagle!g!",tag_shop)
			}
		}
		case 2:
		{
			new iMoney = cs_get_user_money( id ) - get_pcvar_num(cvar_m4a1_money)
			
			if(iMoney < 0)
			{
				ColorChat(id,"%s Fonduri insuficiente!",tag_shop)
				return 1
			}
			else
			{
				give_item(id,"weapon_m4a1")
				
				cs_set_user_bpammo(id,CSW_M4A1, get_pcvar_num(cvar_m4a1_ammo))
				
				cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(cvar_m4a1_money))
				
				ColorChat(id,"%s Ai cumparat !vM4A1!g!",tag_shop)
			}
		}
		case 3:
		{
			new iMoney = cs_get_user_money( id ) - get_pcvar_num(cvar_ak47_money)
			
			if(iMoney < 0)
			{
				ColorChat(id,"%s Fonduri insuficiente!",tag_shop)
				return 1
			}
			else
			{
				give_item(id,"weapon_ak47")
				
				cs_set_user_bpammo(id,CSW_AK47, get_pcvar_num(cvar_ak47_ammo))
				
				cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(cvar_ak47_money))
				
				ColorChat(id,"%s Ai cumparat !vAK47!g!",tag_shop)
			}
		}
	}
	menu_destroy(cts_shop)
	return PLUGIN_HANDLED
}
			
			
			
public sub_tero_shop(id,tero_shop,item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(tero_shop)
   		remove_task(id)
		return PLUGIN_HANDLED
	}
	new Data[7], Name[64]
	new Access, Callback
	menu_item_getinfo(tero_shop, item, Access, Data,5, Name, 63, Callback)
	
	new Key = str_to_num(Data)
	
	switch (Key)
	{
		case 1:
		{
			new iMoney = cs_get_user_money( id ) - get_pcvar_num(cvar_glock_money)
			
			if(iMoney < 0)
			{
				ColorChat(id,"%s Fonduri insuficiente!",tag_shop)
				return 1
			}
			else
			{
				give_item(id,"weapon_glock18")
				cs_set_user_bpammo(id,CSW_GLOCK18,get_pcvar_num(cvar_glock_ammo))
				
				cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(cvar_glock_money))
				
				ColorChat(id,"%s Ai cumparat !vGlock!g!",tag_shop)
			}
		}
		case 2:
		{
			new iMoney = cs_get_user_money( id ) - get_pcvar_num(cvar_health_money)
	
			if(iMoney < 0)
			{
				ColorChat(id,"%s Fonduri insuficiente!",tag_shop)
				return 1
			}
			else
			{
				set_user_health(id,get_user_health(id) + get_pcvar_num(cvar_health_ammount))
				
				cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(cvar_health_money))
				
				ColorChat(id,"%s Ai cumparat !vViata!g!",tag_shop)
			}
		}
		case 3:
		{
			new iMoney = cs_get_user_money( id ) - get_pcvar_num(cvar_armor_money)
	
			if(iMoney < 0)
			{
				ColorChat(id,"%s Fonduri insuficiente!",tag_shop)
				return 1
			}
			else
			{
				set_user_armor(id,get_user_armor(id) + get_pcvar_num(cvar_armor_ammount))
				
				cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(cvar_armor_money))
	
				ColorChat(id,"%s Ai cumparat !vArmura!g!",tag_shop)
			}
		}
		case 4:
		{
			new iMoney = cs_get_user_money( id ) - get_pcvar_num(cvar_invizibility_money)
	
			if(iMoney < 0)
			{
				ColorChat(id,"%s Fonduri insuficiente!",tag_shop)
				return 1
			}
			else
			{
				g_inviziblity[id] = true
				
				set_entity_visibility(id, 0)
				
				cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(cvar_invizibility_money))
		
				ColorChat(id,"%s Ai cumparat !vInvizibilitate!g!",tag_shop)
				
				set_task(get_pcvar_float(cvar_invizibility_time),"remove_invizibility",id+TASK_INVIZIBILITY)
			}
		}
		case 5:
		{
			new iMoney = cs_get_user_money( id ) - get_pcvar_num(cvar_speed_money)
	
			if(iMoney < 0)
			{
				ColorChat(id,"%s Fonduri insuficiente!",tag_shop)
				return 1
			}
			else 
			{
				HasSpeed[id] = true
				
				set_user_maxspeed(id,get_pcvar_float(cvar_speed_value))
				
				cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(cvar_speed_money))
				
				ColorChat(id,"%s Ai cumparat !vViteza!g!",tag_shop)
				
				set_task(get_pcvar_float(cvar_speed_time),"remove_speed",id+TASK_SPEED)
			}
		}
		case 6:
		{
			new iMoney = cs_get_user_money( id ) - get_pcvar_num(cvar_grenade_money)
			
			if(iMoney < 0)
			{
				ColorChat(id,"%s Fonduri insuficiente!",tag_shop)
				return 1
			}
			else
			{
				give_item(id,"weapon_hegrenade")
				cs_set_user_bpammo(id,CSW_HEGRENADE,get_pcvar_num(cvar_grenade_ammo))
				
				cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(cvar_grenade_money))
			
				ColorChat(id,"%s Ai cumparat !vHeGrenade!g!",tag_shop)
			}
		}
			
	}
	menu_destroy(tero_shop)
	return PLUGIN_HANDLED
}

public remove_invizibility(id)
{
	id -= TASK_INVIZIBILITY
	
	if(!is_user_alive(id))
	{
		g_inviziblity[id] = false
		set_entity_visibility(id, 1)
		remove_task(id+TASK_INVIZIBILITY)
	}
	
	set_entity_visibility(id, 1)
	ColorChat(id,"%s Invizibilitatea a exipirat!",tag_shop)
}

public remove_speed(id)
{
	id -= TASK_SPEED
	
	if(!is_user_alive(id))
	{
		HasSpeed[id] = false
		remove_task(id+TASK_SPEED)
	}
	
	HasSpeed[id] = false
	ColorChat(id,"%s Viteza a exipirat!",tag_shop)
}

public remove_invizibility_vip(id)
{
	id -= TASK_INVIZIBILITY_VIP
	
	if(!is_user_alive(id))
	{
		g_inviziblity_vip[id] = false
		set_entity_visibility(id, 1)
		remove_task(id+TASK_INVIZIBILITY_VIP)
	}
	
	set_entity_visibility(id, 1)
	ColorChat(id,"%s Invizibilitatea a exipirat!",tag_shop_vip)
}

public remove_speed_vip(id)
{
	id -= TASK_SPEED_VIP
	
	if(!is_user_alive(id))
	{
		HasSpeed_vip[id] = false
		remove_task(id+TASK_SPEED_VIP)
	}
	
	HasSpeed_vip[id] = false
	ColorChat(id,"%s Viteza a exipirat!",tag_shop_vip)
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

stock is_user_vip(id)
{
	if(get_user_flags(id) && read_flags("v"))
	return true
	
		return false
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
