#define TURRET_PRIORITY_TARGET 2
#define TURRET_SECONDARY_TARGET 1
#define TURRET_NOT_TARGET 0

/obj/machinery/porta_turret/tag
	// Reasonable defaults, in case someone manually spawns us
	var/lasercolor = "r"	//Something to do with lasertag turrets, blame Sieve for not adding a comment.
	installation = /obj/item/gun/energy/laser/tag/red

/obj/machinery/porta_turret/tag/red

/obj/machinery/porta_turret/tag/blue
	lasercolor = "b"
	installation = /obj/item/gun/energy/laser/tag/blue

/obj/machinery/porta_turret/tag/New()
	..()
	icon_state = "[lasercolor]grey_target_prism"

/obj/machinery/porta_turret/tag/weapon_setup(var/obj/item/gun/energy/E)
	switch(E.type)
		if(/obj/item/gun/energy/laser/tag/blue)
			eprojectile = /obj/item/gun/energy/laser/tag/blue
			lasercolor = "b"
			req_access = list(access_maint_tunnels, access_theatre)
			check_arrest = 0
			check_records = 0
			check_weapons = 1
			check_access = 0
			check_anomalies = 0
			shot_delay = 30

		if(/obj/item/gun/energy/laser/tag/red)
			eprojectile = /obj/item/gun/energy/laser/tag/red
			lasercolor = "r"
			req_access = list(access_maint_tunnels, access_theatre)
			check_arrest = 0
			check_records = 0
			check_weapons = 1
			check_access = 0
			check_anomalies = 0
			shot_delay = 30
			iconholder = 1

/obj/machinery/porta_turret/tag/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "turret_control.tmpl", "Turret Controls", 500, 300)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/porta_turret/tag/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/data[0]
	data["access"] = !isLocked(user)
	data["locked"] = locked
	data["enabled"] = enabled
	data["is_lethal"] = 0
	return data

/obj/machinery/porta_turret/tag/update_icon()
	if(!anchored)
		icon_state = "turretCover"
		return
	if(stat & BROKEN)
		icon_state = "[lasercolor]destroyed_target_prism"
	else
		if(powered())
			if(enabled)
				if(iconholder)
					//lasers have a orange icon
					icon_state = "[lasercolor]orange_target_prism"
				else
					//almost everything has a blue icon
					icon_state = "[lasercolor]target_prism"
			else
				icon_state = "[lasercolor]grey_target_prism"
		else
			icon_state = "[lasercolor]grey_target_prism"

/obj/machinery/porta_turret/tag/bullet_act(obj/item/projectile/Proj)
	..()

	if(lasercolor == "b" && disabled == 0)
		if(istype(Proj, /obj/item/gun/energy/laser/tag/red))
			disabled = 1
			qdel(Proj) // qdel
			sleep(100)
			disabled = 0
	if(lasercolor == "r" && disabled == 0)
		if(istype(Proj, /obj/item/gun/energy/laser/tag/blue))
			disabled = 1
			qdel(Proj) // qdel
			sleep(100)
			disabled = 0

/obj/machinery/porta_turret/tag/assess_living(var/mob/living/L)
	if(!L)
		return TURRET_NOT_TARGET

	if(L.lying)
		return TURRET_NOT_TARGET

	var/target_suit
	var/target_weapon
	switch(lasercolor)
		if("b")
			target_suit = /obj/item/clothing/suit/redtag
			target_weapon = /obj/item/gun/energy/laser/tag/red
		if("r")
			target_suit = /obj/item/clothing/suit/bluetag
			target_weapon = /obj/item/gun/energy/laser/tag/blue


	if(target_suit)//Lasertag turrets target the opposing team, how great is that? -Sieve
		if((istype(L.r_hand, target_weapon)) || (istype(L.l_hand, target_weapon)))
			return TURRET_PRIORITY_TARGET

		if(istype(L, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = L
			if(istype(H.wear_suit, target_suit))
				return TURRET_PRIORITY_TARGET
			if(istype(H.belt, target_weapon))
				return TURRET_SECONDARY_TARGET

	return TURRET_NOT_TARGET
