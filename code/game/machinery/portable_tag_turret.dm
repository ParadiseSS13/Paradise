#define TURRET_PRIORITY_TARGET 2
#define TURRET_SECONDARY_TARGET 1
#define TURRET_NOT_TARGET 0

/obj/machinery/porta_turret/tag
	// Reasonable defaults, in case someone manually spawns us
	var/lasercolor = "r"	//Something to do with lasertag turrets, blame Sieve for not adding a comment.
	installation = /obj/item/gun/energy/laser/tag/red
	targetting_is_configurable = FALSE
	lethal_is_configurable = FALSE
	shot_delay = 30
	iconholder = 1
	has_cover = FALSE
	always_up = TRUE
	raised = TRUE
	req_access = list(ACCESS_MAINT_TUNNELS, ACCESS_THEATRE)

/obj/machinery/porta_turret/tag/red

/obj/machinery/porta_turret/tag/blue
	lasercolor = "b"
	installation = /obj/item/gun/energy/laser/tag/blue

/obj/machinery/porta_turret/tag/Initialize(mapload)
	. = ..()
	icon_state = "[lasercolor]grey_target_prism"

/obj/machinery/porta_turret/tag/weapon_setup(var/obj/item/gun/energy/E)
	return

/obj/machinery/porta_turret/tag/tgui_data(mob/user)
	var/list/data = list(
		"locked" = isLocked(user), // does the current user have access?
		"on" = enabled, // is turret turned on?
		"lethal" = FALSE,
		"lethal_is_configurable" = lethal_is_configurable
	)
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

/obj/machinery/porta_turret/tag/bullet_act(obj/item/projectile/P)
	..()
	if(!disabled)
		if(lasercolor == "b")
			if(istype(P, /obj/item/projectile/beam/lasertag/redtag))
				disabled  = TRUE
				spawn(100)
					disabled  = FALSE
		else if(lasercolor == "r")
			if(istype(P, /obj/item/projectile/beam/lasertag/bluetag))
				disabled  = TRUE
				spawn(100)
					disabled  = FALSE

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
