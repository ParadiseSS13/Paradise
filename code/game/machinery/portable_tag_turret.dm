
/obj/machinery/porta_turret/tag
	targetting_is_configurable = FALSE
	lethal_is_configurable = FALSE
	shot_delay = 3 SECONDS
	iconholder = TRUE
	has_cover = FALSE
	always_up = TRUE
	raised = TRUE
	req_access = list(ACCESS_MAINT_TUNNELS, ACCESS_THEATRE)
	/// Team that we are assigned to
	var/team_color

/obj/machinery/porta_turret/tag/Initialize(mapload)
	. = ..()
	icon_state = "[team_color]_off"
	base_icon_state = team_color

/obj/machinery/porta_turret/tag/red
	team_color = "red"
	installation = /obj/item/gun/energy/laser/tag/red

/obj/machinery/porta_turret/tag/blue
	team_color = "blue"
	installation = /obj/item/gun/energy/laser/tag/blue

/obj/machinery/porta_turret/tag/weapon_setup(obj/item/gun/energy/E)
	return

/obj/machinery/porta_turret/tag/ui_data(mob/user)
	var/list/data = list(
		"locked" = isLocked(user), // does the current user have access?
		"on" = enabled, // is turret turned on?
		"lethal" = FALSE,
		"lethal_is_configurable" = lethal_is_configurable
	)
	return data

/obj/machinery/porta_turret/tag/bullet_act(obj/item/projectile/P)
	..()
	if(!disabled)
		if(team_color == "blue")
			if(istype(P, /obj/item/projectile/beam/lasertag/redtag))
				disabled  = TRUE
				spawn(100)
					disabled  = FALSE
		else if(team_color == "red")
			if(istype(P, /obj/item/projectile/beam/lasertag/bluetag))
				disabled  = TRUE
				spawn(100)
					disabled  = FALSE

/obj/machinery/porta_turret/tag/assess_living(mob/living/L)
	if(!L)
		return TURRET_NOT_TARGET

	if(IS_HORIZONTAL(L))
		return TURRET_NOT_TARGET

	var/target_suit
	var/target_weapon
	switch(team_color)
		if("blue")
			target_suit = /obj/item/clothing/suit/redtag
			target_weapon = /obj/item/gun/energy/laser/tag/red
		if("red")
			target_suit = /obj/item/clothing/suit/bluetag
			target_weapon = /obj/item/gun/energy/laser/tag/blue

	if(target_suit)//Lasertag turrets target the opposing team, how great is that? -Sieve
		if((istype(L.r_hand, target_weapon)) || (istype(L.l_hand, target_weapon)))
			return TURRET_PRIORITY_TARGET

		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if(istype(H.wear_suit, target_suit))
				return TURRET_PRIORITY_TARGET
			if(istype(H.belt, target_weapon))
				return TURRET_SECONDARY_TARGET

	return TURRET_NOT_TARGET
