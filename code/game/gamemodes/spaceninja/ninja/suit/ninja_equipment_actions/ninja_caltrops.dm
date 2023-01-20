/datum/action/item_action/advanced/ninja/ninja_caltrops

	name = "Energy Caltrops"
	desc = "Scatters deadly caltrops behind the user. Great to slow enemies down. Don't step on them. Even metal legs will be damaged. Energy cost: 1500"
	check_flags = AB_CHECK_STUNNED|AB_CHECK_LYING|AB_CHECK_CONSCIOUS
	charge_type = ADV_ACTION_TYPE_RECHARGE
	charge_max = 1 SECONDS
	use_itemicon = FALSE
	icon_icon = 'icons/mob/actions/actions_ninja.dmi'
	button_icon_state = "caltrop"
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"
	action_initialisation_text = "Energy Caltrops Scattering Device"


/obj/item/clothing/suit/space/space_ninja/proc/scatter_caltrops()
	var/mob/living/carbon/human/ninja = affecting
	if(!ninja)
		return
	if(!ninjacost(1500))
		var/list/possible_turfs = list()
		var/direct
		if(ninja.dir == NORTH)
			for(direct in list(SOUTH,SOUTHEAST,SOUTHWEST))
				possible_turfs += get_step(src,direct)
		else if(ninja.dir == SOUTH)
			for(direct in list(NORTH,NORTHEAST,NORTHWEST))
				possible_turfs += get_step(src,direct)
		else if(ninja.dir == WEST)
			for(direct in list(EAST,SOUTHEAST,NORTHEAST))
				possible_turfs += get_step(src,direct)
		else if(ninja.dir == EAST)
			for(direct in list(WEST,SOUTHWEST,NORTHWEST))
				possible_turfs += get_step(src,direct)
		else if(ninja.dir == NORTHWEST)
			for(direct in list(EAST,SOUTHEAST,SOUTH))
				possible_turfs += get_step(src,direct)
		else if(ninja.dir == NORTHEAST)
			for(direct in list(WEST,SOUTHWEST,SOUTH))
				possible_turfs += get_step(src,direct)
		else if(ninja.dir == SOUTHWEST)
			for(direct in list(EAST,NORTHEAST,NORTH))
				possible_turfs += get_step(src,direct)
		else if(ninja.dir == SOUTHEAST)
			for(direct in list(WEST,NORTHWEST,NORTH))
				possible_turfs += get_step(src,direct)
		for(var/turf/spawn_turf in possible_turfs)
			if(!istype(spawn_turf, /turf/simulated/wall) && !locate(/obj/structure/grille) in spawn_turf)
				new /obj/structure/energy_caltrops(spawn_turf)
		for(var/datum/action/item_action/advanced/ninja/ninja_caltrops/ninja_action in actions)
			ninja_action.use_action()
			break
		playsound(ninja, 'sound/effects/glass_step_sm.ogg', 50, TRUE)
		if(auto_smoke)
			if(locate(/datum/action/item_action/advanced/ninja/ninja_smoke_bomb) in actions)
				prime_smoke(lowcost = TRUE)


///The caltrops object
/obj/structure/energy_caltrops
	name = "Caltrops"
	desc = "Made of condensed energy! Don't step on this. Even metal legs will be damaged!"
	icon = 'icons/obj/ninjaobjects.dmi'
	icon_state = "caltrops"
	resistance_flags = INDESTRUCTIBLE
	max_integrity = 30
	density = FALSE
	anchored = TRUE
	var/destroy_after = 10 SECONDS
	var/self_destroy = TRUE

/obj/structure/energy_caltrops/noselfdestroy
	self_destroy = FALSE

/obj/structure/energy_caltrops/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, 5, 10, 100, CALTROP_BYPASS_SHOES|CALTROP_BYPASS_ROBOTIC_LEGS|CALTROP_BYPASS_WALKERS)
	for(var/obj/structure/energy_caltrops/other_caltrop in src.loc.contents)
		if(other_caltrop!=src)
			qdel(other_caltrop)	//Не больше одной кучки калтропов на тайле!
	if(self_destroy)
		addtimer(CALLBACK(GLOBAL_PROC, .proc/qdel, src), destroy_after)

/obj/structure/energy_caltrops/Crossed(mob/living/L, oldloc)
	if(istype(L) && has_gravity(loc))
		if(L.incorporeal_move || L.flying || L.floating)
			return
		add_attack_logs(L, src, "Stepped on Caltrop")
		playsound(loc, 'sound/weapons/bladeslice.ogg', 50, TRUE)
		addtimer(CALLBACK(GLOBAL_PROC, .proc/qdel, src), 1)	//На нас наступили? Удаляемся быстрее. Нужно в целях баланса.
	return ..()
