#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
#include <fun>
#include <hamsandwich>

#define PLUGIN "VIP Sistem"
#define VERSION "0.1"
#define AUTHOR "bbb"

#define VIP_BRONZE ADMIN_LEVEL_F
#define VIP_SILVER ADMIN_LEVEL_G
#define VIP_GOLDEN ADMIN_LEVEL_H
#define OWNER      ADMIN_IMMUNITY

#pragma tabsize 0 

new BRONZE_TAG[] ="!v[VIP Bronze]:!g"
new SILVER_TAG[] ="!v[VIP Silver]:!g"
new GOLDEN_TAG[] ="!v[VIP Golden]:!g"
new SISTEM_TAG[] ="!v[VIP Sistem]:!g"

//BRONZE
new bool:ShowSpeed[33]
new bool:Ihave[33]
new bool:iWeapon[33]
//End

//SILVER
new bool:SetSpeed[33]
new bool:Userhave[33]
new bool:Weapons[33]
//End

//GOLDEN
new bool:GiveSpeed[33]
new bool:Have[33]
new bool:Wep[33]
//End

//Skinuri Arme
new M4A1[64] = "models/vip_sistem/v_m4a1_gold.mdl"
new pM4a1[64] = "models/vip_sistem/p_m4a1_gold.mdl"

new AK47[64] = "models/vip_sistem/v_ak47_gold.mdl"
new pAK47[64] = "models/vip_sistem/p_ak47_gold.mdl"

new Deagle[64] = "models/vip_sistem/v_deagle_gold.mdl"
new pDeagle[64] = "models/vip_sistem/p_deagle_gold.mdl"

//End

new plugin_on,bronze_speed,silver_speed,golden_speed;
new p_bronze_speed,p_silver_speed,p_golden_speed;

new maxplayers
new gmsgSayText

static const COLOR[] = "^x04"
public plugin_init()
{
	register_plugin(PLUGIN,VERSION,AUTHOR)
	
	register_clcmd("say /bronze","cmd_bronze")
	register_clcmd("say_team /bronze","cmd_bronze")
	register_clcmd("say /bmenu","cmd_bronze")
	register_clcmd("say_team /bmenu","cmd_bronze")
	
	register_clcmd("say /silver","cmd_silver")
	register_clcmd("say_team /silver","cmd_silver")
	register_clcmd("say /smenu","cmd_silver")
	register_clcmd("say_team /smenu","cmd_silver")
	
	register_clcmd("say /golden","cmd_golden")
	register_clcmd("say_team /golden","cmd_golden")
	register_clcmd("say /gmenu","cmd_golden")
	register_clcmd("say_team /gmenu","cmd_golden")
	
	register_clcmd("say /vip","cmd_vips")
	register_clcmd("say /vips","cmd_vips")
	register_clcmd("say_team /vip","cmd_vips")
	register_clcmd("say_team /vips","cmd_vips")
	maxplayers = get_maxplayers()
	gmsgSayText = get_user_msgid("SayText")
	
	RegisterHam(Ham_Spawn, "player", "Player_Spawn", 1)
	
	RegisterHam(Ham_Item_PreFrame,"player","PreFrame_Post",1)
	
	RegisterHam ( Ham_TakeDamage, "player", "Player_TakeDamage" )
	
	register_event ( "CurWeapon", "CurrentWeapon", "be", "1=1" )
	
	plugin_on = register_cvar("plugin_on_off","1")
	bronze_speed = register_cvar("bronze_value","400")
	silver_speed = register_cvar("silver_value","500")
	golden_speed = register_cvar("golden_value","600")
	p_bronze_speed = get_pcvar_num(bronze_speed)
	p_silver_speed = get_pcvar_num(silver_speed)
	p_golden_speed = get_pcvar_num(golden_speed)
	
	set_task(60.0, "ShowMessage", _, _, _, "b", 0)
}

public ShowMessage(id)
{
	ColorChat(0,"%s Acest server foloseste !vVIP Sistem !g creat de bbb",SISTEM_TAG)
}
public plugin_precache()
{
	precache_model(M4A1)
	precache_model(pM4a1)
	precache_model(AK47)
	precache_model(pAK47)
	precache_model(Deagle)
	precache_model(pDeagle)
}
public client_connect(id)
{
	if(get_pcvar_num(plugin_on) == 1)
	{
	ShowSpeed[id] = false
	Ihave[id] = false
	iWeapon[id] = false
	
	SetSpeed[id] = false
	Userhave[id] = false
	Weapons[id] = false
	
	GiveSpeed[id] = false
	Have[id] = false
	Wep[id] = false
	
	new name[32]
	get_user_name(id,name,31)
	
	if(get_user_flags(id) & VIP_BRONZE)
	{
		ColorChat(0,"%s %s s-a conectat pe server!",BRONZE_TAG,name)
	}
	else if(get_user_flags(id) & VIP_SILVER)
	{
		ColorChat(0,"%s %s s-a conectat pe server!",SILVER_TAG,name)
	}
	else if(get_user_flags(id) & VIP_GOLDEN)
	{
		ColorChat(0,"%s %s s-a conectat pe server!",GOLDEN_TAG,name)
	}
	if(get_user_flags(id) & OWNER)
	{
		ColorChat(0,"%s Ownerul %s s-a conectat pe server!",SISTEM_TAG,name)
	}
	}
}

public client_disconnect(id)
{
	if(get_pcvar_num(plugin_on) == 1)
	{
	ShowSpeed[id] = false
	Ihave[id] = false
	iWeapon[id] = false
	
	SetSpeed[id] = false
	Userhave[id] = false
	Weapons[id] = false
	
	GiveSpeed[id] = false
	Have[id] = false
	Wep[id] = false
	
	new Name[32]
	get_user_name(id,Name,31)
	
	if(get_user_flags(id) & VIP_BRONZE)
	{
		ColorChat(0,"%s %s s-a deconectat de pe server!",BRONZE_TAG,Name)
	}
	else if(get_user_flags(id) & VIP_SILVER)
	{
		ColorChat(0,"%s %s s-a deconectat de pe server!",SILVER_TAG,Name)
	}
	else if(get_user_flags(id) & VIP_GOLDEN)
	{
		ColorChat(0,"%s %s s-a deconectat de pe server!",GOLDEN_TAG,Name)
	}
	if(get_user_flags(id) & OWNER)
	{
		ColorChat(0,"%s Ownerul %s s-a deconectat de pe server!",SISTEM_TAG,Name)
	}
	}
}

public Player_Spawn(id)
{
	if(get_pcvar_num(plugin_on) == 1)
	{
	ShowSpeed[id] = false
	Ihave[id] = false
	iWeapon[id] = false
	
	SetSpeed[id] = false
	Userhave[id] = false
	Weapons[id] = false
	
	GiveSpeed[id] = false
	Have[id] = false
	Wep[id] = false
	
	set_task(0.1,"Armor",id)
	
	if(get_user_flags(id) & VIP_BRONZE)
	{
		set_task(0.1,"Bronze_life",id)
	}
	else if(get_user_flags(id) & VIP_SILVER)
	{
		set_task(0.1,"Silver_life",id)
	}
	else if(get_user_flags(id) & VIP_GOLDEN)
	{
		set_task(0.1,"Golden_life",id)
	}
	}
}
public Armor(id)
{
	set_user_armor(id,0)
}
public Bronze_life(id)
{
	new Health = get_user_health(id)
	new useArmory = get_user_armor(id)
	
	set_user_health(id,Health + 50)
	set_user_armor(id,useArmory + 150)
}
public Silver_life(id)
{
	new userlife = get_user_health(id)
	new userArmor = get_user_armor(id)
	
	set_user_health(id,userlife + 100)
	set_user_armor(id,userArmor + 200)
}
public Golden_life(id)
{
	new iHealth = get_user_health(id)
	new iArmor = get_user_armor(id)
	
	set_user_health(id,iHealth + 150)
	set_user_armor(id,iArmor + 250)
}
	
public cmd_bronze(id)
{
     if(get_pcvar_num(plugin_on) == 1)
	{
	if(is_user_alive(id) && get_user_flags(id) & VIP_BRONZE)
	{
		bronze(id)
	}
	else if(!is_user_alive(id) && get_user_flags(id) & VIP_BRONZE)
	{
		ColorChat(id,"%s Nu poti accesa!v VIP Bronze!g cand esti mort!",SISTEM_TAG)
		return PLUGIN_HANDLED
	}
	else if(cs_get_user_team(id) == CS_TEAM_SPECTATOR)
	{
		ColorChat(id,"%s Nu poti accesa!v VIP Bronze!g cand esti mort!",SISTEM_TAG)
		return PLUGIN_HANDLED
	}
	}
	return PLUGIN_HANDLED
}

public cmd_silver(id)
{
     if(get_pcvar_num(plugin_on) == 1)
	{
	if(is_user_alive(id) && get_user_flags(id) & VIP_SILVER)
	{
		silver(id)
	}
	else if(!is_user_alive(id) && get_user_flags(id) & VIP_SILVER)
	{
		ColorChat(id,"%s Nu poti accesa!v VIP Silver!g cand esti mort!",SISTEM_TAG)
		return PLUGIN_HANDLED
	}
	else if(cs_get_user_team(id) == CS_TEAM_SPECTATOR)
	{
		ColorChat(id,"%s Nu poti accesa!v VIP Silver!g cand esti mort!",SISTEM_TAG)
		return PLUGIN_HANDLED
	}
	}
	return PLUGIN_HANDLED
}

public cmd_golden(id)
{
     if(get_pcvar_num(plugin_on) == 1)
	{
	if(is_user_alive(id) && get_user_flags(id) & VIP_GOLDEN)
	{
		golden(id)
	}
	else if(!is_user_alive(id) && get_user_flags(id) & VIP_GOLDEN)
	{
		ColorChat(id,"%s Nu poti accesa!v VIP Golden!g cand esti mort!",SISTEM_TAG)
		return PLUGIN_HANDLED
	}
	else if(cs_get_user_team(id) == CS_TEAM_SPECTATOR)
	{
		ColorChat(id,"%s Nu poti accesa!v VIP Golden!g cand esti mort!",SISTEM_TAG)
		return PLUGIN_HANDLED
	}
	}
	return PLUGIN_HANDLED
}

public bronze(id)
{
	new bron = menu_create("\wSurf \rVIP Bronze\w Menu","bronze_handler")
	if(Ihave[id])
	{
	menu_additem(bron,"\dSpeed\d 400","1",0)
	}
	else
	{
	menu_additem(bron,"\wSpeed\r 400","1",0)
	}
	if(Ihave[id])
	{
	menu_additem(bron,"\dHE\d 20","2",0)
	}
	else
	{
	menu_additem(bron,"\wHE\r 20","2",0)
	}
	if(Ihave[id])
	{
	menu_additem(bron,"\dM4A1 Gold\d x2 Dmg","3",0)
	}
	else
	{
	menu_additem(bron,"\wM4A1 Gold\r x2 Dmg","3",0)
	}
	if(Ihave[id])
	{
	menu_additem(bron,"\dAK47 Gold\d x2 Dmg","4",0)
	}
	else
	{
	menu_additem(bron,"\wAK47 Gold\r x2 Dmg","4",0)
	}
	if(Ihave[id])
	{
	menu_additem(bron,"\dDeagle Gold\d x3 Dmg","5",0)
	}
	else
	{
	menu_additem(bron,"\wDeagle Gold\r x3 Dmg","5",0)
	}
	
	menu_setprop(bron, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, bron, 0)
	
	return PLUGIN_HANDLED
}

public bronze_handler(id, bron, item)
{
	if(Ihave[id])
	{
		ColorChat(id,"%s Doar odata pe runda poti folosi!v VIP Bronze!g Menu",SISTEM_TAG)
		return HAM_IGNORED
	}
	if (item == MENU_EXIT)
	{
		menu_destroy(bron);
   		remove_task(id);
		return PLUGIN_HANDLED;
	}
	new Data[7], Name[64];
	new Access, Callback;
	menu_item_getinfo(bron, item, Access, Data,5, Name, 63, Callback);
	
	new Key = str_to_num(Data);
	
	switch (Key)
	{
		case 1:
		{
			ShowSpeed[id] = true
			Ihave[id] = true
			Speed(id,float(p_bronze_speed))
			ColorChat(id,"%s Ai ales +400 Speed",BRONZE_TAG)
		}
		case 2:
		{
			Ihave[id] = true
			give_item(id,"weapon_hegrenade")
			cs_set_user_bpammo(id,CSW_HEGRENADE,20)
			ColorChat(id,"%s Ai ales +20 Grenazi",BRONZE_TAG)
		}
		case 3:
		{
			Ihave[id] = true
			iWeapon[id] = true
			give_item(id,"weapon_m4a1")
			set_pev(id,pev_viewmodel2,M4A1)
			set_pev(id,pev_weaponmodel2,pM4a1)
			cs_set_user_bpammo(id,CSW_M4A1,10000)
			ColorChat(id,"%s Ai ales M4A1 Gold",BRONZE_TAG)
		}
		case 4:
		{
			Ihave[id] = true
			iWeapon[id] = true
			give_item(id,"weapon_ak47")
			set_pev(id,pev_viewmodel2,AK47)
			set_pev(id,pev_weaponmodel2,pAK47)
			cs_set_user_bpammo(id,CSW_AK47,10000)
			ColorChat(id,"%s Ai ales AK47 Gold",BRONZE_TAG)
		}
		case 5:
		{
			Ihave[id] = true
			iWeapon[id] = true
			give_item(id,"weapon_deagle")
			set_pev(id,pev_viewmodel2,Deagle)
			set_pev(id,pev_weaponmodel2,pDeagle)
			cs_set_user_bpammo(id,CSW_DEAGLE,10000)
			ColorChat(id,"%s Ai ales Deagle Gold",BRONZE_TAG)
		}
	}
	return PLUGIN_HANDLED
}

public silver(id)
{
	new silv = menu_create("\wSurf \rVIP Silver\w Menu", "silver_handler")
	if(Userhave[id])
	{
	menu_additem(silv,"\dSpeed\d 500","1",0)
	}
	else
	{
	menu_additem(silv,"\wSpeed\r 500","1",0)
	}
	if(Userhave[id])
	{
	menu_additem(silv,"\dHE\d 30","2",0)
	}
	else
	{
	menu_additem(silv,"\wHE\r 30","2",0)
	}
	if(Userhave[id])
	{
	menu_additem(silv,"\dM4A1 Gold\d x3 Dmg","3",0)
	}
	else
	{
	menu_additem(silv,"\wM4A1 Gold\r x3 Dmg","3",0)
	}
	if(Userhave[id])
	{
	menu_additem(silv,"\dAK47 Gold\d x3 Dmg","4",0)
	}
	else
	{
	menu_additem(silv,"\wAK47 Gold\r x3 Dmg","4",0)
	}
	if(Userhave[id])
	{
	menu_additem(silv,"\dDeagle Gold\d x4 Dmg","5",0)
	}
	else
	{
	menu_additem(silv,"\wDeagle Gold\r x4 Dmg","5",0)
	}
	
	menu_setprop(silv, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, silv, 0)
}

public silver_handler(id,silv,item)
{
	if(Userhave[id])
	{
		ColorChat(id,"%s Doar odata pe runda poti folosi!v VIP Silver!g Menu",SISTEM_TAG)
		return HAM_IGNORED
	}
	
	if (item == MENU_EXIT)
	{
		menu_destroy(silv);
   		remove_task(id);
		return PLUGIN_HANDLED;
	}
	new Data[7], Name[64];
	new Access, Callback;
	menu_item_getinfo(silv, item, Access, Data,5, Name, 63, Callback);
	
	new Key = str_to_num(Data);
	
	switch (Key)
	{
		case 1:
		{
			SetSpeed[id] = true
			Userhave[id] = true
			Speed(id,float(p_silver_speed))
			ColorChat(id,"%s Ai ales +500 Speed",SILVER_TAG)
		}
		case 2:
		{
			Userhave[id] = true
			give_item(id,"weapon_hegrenade")
			cs_set_user_bpammo(id,CSW_HEGRENADE,30)
			ColorChat(id,"%s Ai ales +30 Grenazi",SILVER_TAG)
		}
		case 3:
		{
			Userhave[id] = true
			Weapons[id] = true
			give_item(id,"weapon_m4a1")
			set_pev(id,pev_viewmodel2,M4A1)
			set_pev(id,pev_weaponmodel2,pM4a1)
			cs_set_user_bpammo(id,CSW_M4A1,10000)
			ColorChat(id,"%s Ai ales M4A1 Gold",SILVER_TAG)
		}
		case 4:
		{
			Userhave[id] = true
			Weapons[id] = true
			give_item(id,"weapon_ak47")
			set_pev(id,pev_viewmodel2,AK47)
			set_pev(id,pev_weaponmodel2,pAK47)
			cs_set_user_bpammo(id,CSW_AK47,10000)
			ColorChat(id,"%s Ai ales AK47 Gold",SILVER_TAG)
		}
		case 5:
		{
			Userhave[id] = true
			Weapons[id] = true
			give_item(id,"weapon_deagle")
			set_pev(id,pev_viewmodel2,Deagle)
			set_pev(id,pev_weaponmodel2,pDeagle)
			cs_set_user_bpammo(id,CSW_DEAGLE,10000)
			ColorChat(id,"%s Ai ales Deagle Gold",SILVER_TAG)
		}
	}
	return PLUGIN_HANDLED
}

public golden(id)
{
	new gold = menu_create("\wSurf \rVIP Golden\w Menu", "golden_handler")
	if(Have[id])
	{
	menu_additem(gold,"\dSpeed\d 600","1",0)
	}
	else
	{
	menu_additem(gold,"\wSpeed\r 600","1",0)
	}
	if(Have[id])
	{
	menu_additem(gold,"\dHE\d 40","2",0)
	}
	else
	{
	menu_additem(gold,"\wHE\r 40","2",0)
	}
	if(Have[id])
	{
	menu_additem(gold,"\dM4A1 Gold\d x4 Dmg","3",0)
	}
	else
	{
	menu_additem(gold,"\wM4A1 Gold\r x4 Dmg","3",0)
	}
	if(Have[id])
	{
	menu_additem(gold,"\dAK47 Gold\d x4 Dmg","4",0)
	}
	else
	{
	menu_additem(gold,"\wAK47 Gold\r x4 Dmg","4",0)
	}
	if(Have[id])
	{
	menu_additem(gold,"\dDeagle Gold\d x5 Dmg","5",0)
	}
	else
	{
	menu_additem(gold,"\wDeagle Gold\r x5 Dmg","5",0)
	}
	
	menu_setprop(gold, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, gold, 0)
}

public golden_handler(id,gold,item)
{
	if(Have[id])
	{
		ColorChat(id,"%s Doar odata pe runda poti folosi!v VIP Golden!g Menu",SISTEM_TAG)
		return HAM_IGNORED
	}
	
	if (item == MENU_EXIT)
	{
		menu_destroy(gold);
   		remove_task(id);
		return PLUGIN_HANDLED;
	}
	new Data[7], Name[64];
	new Access, Callback;
	menu_item_getinfo(gold, item, Access, Data,5, Name, 63, Callback);
	
	new Key = str_to_num(Data);
	
	switch (Key)
	{
		case 1:
		{
			GiveSpeed[id] = true
			Have[id] = true
			Speed(id,float(p_golden_speed))
			ColorChat(id,"%s Ai ales +600 Speed",GOLDEN_TAG)
		}
		case 2:
		{
			Have[id] = true
			give_item(id,"weapon_hegrenade")
			cs_set_user_bpammo(id,CSW_HEGRENADE,40)
			ColorChat(id,"%s Ai ales +40 Grenazi",GOLDEN_TAG)
		}
		case 3:
		{
			Have[id] = true
			Wep[id] = true
			give_item(id,"weapon_m4a1")
			set_pev(id,pev_viewmodel2,M4A1)
			set_pev(id,pev_weaponmodel2,pM4a1)
			cs_set_user_bpammo(id,CSW_M4A1,10000)
			ColorChat(id,"%s Ai ales M4A1 Gold",GOLDEN_TAG)
		}
		case 4:
		{
			Have[id] = true
			Wep[id] = true
			give_item(id,"weapon_ak47")
			set_pev(id,pev_viewmodel2,AK47)
			set_pev(id,pev_weaponmodel2,pAK47)
			cs_set_user_bpammo(id,CSW_AK47,10000)
			ColorChat(id,"%s Ai ales AK47 Gold",GOLDEN_TAG)
		}
		case 5:
		{
			Have[id] = true
			Wep[id] = true
			give_item(id,"weapon_deagle")
			set_pev(id,pev_viewmodel2,Deagle)
			set_pev(id,pev_weaponmodel2,pDeagle)
			cs_set_user_bpammo(id,CSW_DEAGLE,10000)
			ColorChat(id,"%s Ai ales Deagle Gold",GOLDEN_TAG)
		}
	}
	return PLUGIN_HANDLED
}
			
public PreFrame_Post(id)
{
	if(GiveSpeed[id])
	{
		Speed(id,float(p_golden_speed))
	}
	else if(SetSpeed[id])
	{
		Speed(id,float(p_silver_speed))
	}
	else if(ShowSpeed[id])
	{
		Speed(id,float(p_bronze_speed))
	}
}
public CurrentWeapon(id)
{
	if(get_user_flags(id) & VIP_BRONZE)
	{
		new Arma = read_data(2)
		
		if(Arma == CSW_M4A1){
		set_pev(id,pev_viewmodel2,M4A1)
		set_pev(id,pev_weaponmodel2,pM4a1)
		}
		
		if(Arma == CSW_AK47){
		set_pev(id,pev_viewmodel2,AK47)
		set_pev(id,pev_weaponmodel2,pAK47)
		}
		
		if(Arma == CSW_DEAGLE){
		set_pev(id,pev_viewmodel2,Deagle)
		set_pev(id,pev_weaponmodel2,pDeagle)
		}
	}
	else if(get_user_flags(id) & VIP_SILVER)
	{
		new Arma = read_data(2)
		
		if(Arma == CSW_M4A1){
		set_pev(id,pev_viewmodel2,M4A1)
		set_pev(id,pev_weaponmodel2,pM4a1)
		}
		
		if(Arma == CSW_AK47){
		set_pev(id,pev_viewmodel2,AK47)
		set_pev(id,pev_weaponmodel2,pAK47)
		}
		
		if(Arma == CSW_DEAGLE){
		set_pev(id,pev_viewmodel2,Deagle)
		set_pev(id,pev_weaponmodel2,pDeagle)
		}
	}
	else if(get_user_flags(id) & VIP_GOLDEN)
	{
		new Arma = read_data(2)
		
		if(Arma == CSW_M4A1){
		set_pev(id,pev_viewmodel2,M4A1)
		set_pev(id,pev_weaponmodel2,pM4a1)
		}
		
		if(Arma == CSW_AK47){
		set_pev(id,pev_viewmodel2,AK47)
		set_pev(id,pev_weaponmodel2,pAK47)
		}
		
		if(Arma == CSW_DEAGLE){
		set_pev(id,pev_viewmodel2,Deagle)
		set_pev(id,pev_weaponmodel2,pDeagle)
		}
	}
}
public Player_TakeDamage( iVictim, iInflictor, iAttacker, Float:fDamage, iDamageBits )
{
	//1
	if( iInflictor == iAttacker && iWeapon[iAttacker] && is_user_alive(iAttacker) && get_user_weapon(iAttacker) == CSW_M4A1)
	{
		SetHamParamFloat( 4, fDamage * 2);
		return HAM_HANDLED
	}
	if( iInflictor == iAttacker && iWeapon[iAttacker] && is_user_alive(iAttacker) && get_user_weapon(iAttacker) == CSW_AK47)
	{
		SetHamParamFloat( 4, fDamage * 2);
		return HAM_HANDLED
	}
	if( iInflictor == iAttacker && iWeapon[iAttacker] && is_user_alive(iAttacker) && get_user_weapon(iAttacker) == CSW_DEAGLE)
	{
		SetHamParamFloat( 4, fDamage * 3);
		return HAM_HANDLED
	}
	//2
	if( iInflictor == iAttacker && Weapons[iAttacker] && is_user_alive(iAttacker) && get_user_weapon(iAttacker) == CSW_M4A1)
	{
		SetHamParamFloat( 4, fDamage * 3);
		return HAM_HANDLED
	}
	if( iInflictor == iAttacker && Weapons[iAttacker] && is_user_alive(iAttacker) && get_user_weapon(iAttacker) == CSW_AK47)
	{
		SetHamParamFloat( 4, fDamage * 3);
		return HAM_HANDLED
	}
	if( iInflictor == iAttacker && Weapons[iAttacker] && is_user_alive(iAttacker) && get_user_weapon(iAttacker) == CSW_DEAGLE)
	{
		SetHamParamFloat( 4, fDamage * 4);
		return HAM_HANDLED
	}
	//3
	if( iInflictor == iAttacker && Wep[iAttacker] && is_user_alive(iAttacker) && get_user_weapon(iAttacker) == CSW_M4A1)
	{
		SetHamParamFloat( 4, fDamage * 4);
		return HAM_HANDLED
	}
	if( iInflictor == iAttacker && Wep[iAttacker] && is_user_alive(iAttacker) && get_user_weapon(iAttacker) == CSW_AK47)
	{
		SetHamParamFloat( 4, fDamage * 4);
		return HAM_HANDLED
	}
	if( iInflictor == iAttacker && Wep[iAttacker] && is_user_alive(iAttacker) && get_user_weapon(iAttacker) == CSW_DEAGLE)
	{
		SetHamParamFloat( 4, fDamage * 5);
		return HAM_HANDLED
	}
	return PLUGIN_CONTINUE
}

public cmd_vips(id)
{
	set_task(0.1,"Vips_print",id)
}

public Vips_print(user)
{
	if(get_pcvar_num(plugin_on) == 1)
	{
	new vipsname[33][32]
	new message[256]
	new id, count, x, len
	
	for(id = 1 ; id <= maxplayers ; id++)
		if(is_user_connected(id))
			if(get_user_flags(id) & VIP_BRONZE || get_user_flags(id) & VIP_SILVER || get_user_flags(id) & VIP_GOLDEN)
					get_user_name(id, vipsname[count++], 31)
					
			len = format(message, 255, "%s Vips Online: ",COLOR)
			if(count > 0) {
				for(x = 0 ; x < count ; x++) {
					len += format(message[len], 255-len, "%s%s ", vipsname[x], x < (count-1) ? ", ":"")
					if(len > 96 ) {
						print_message(user, message)
						len = format(message, 255, "%s ",COLOR)
					}
				}
				print_message(user, message)
			}
			else {
				len += format(message[len], 255-len, "No vips online.")
				print_message(user, message)
		}
	}
}

print_message(id, msg[]) {
	message_begin(MSG_ONE, gmsgSayText, {0,0,0}, id)
	write_byte(id)
	write_string(msg)
	message_end()
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

Speed(index,Float:maxspeed) set_pev(index,pev_maxspeed,maxspeed);	
	
	
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
