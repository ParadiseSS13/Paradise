#define RESIN_WALL "Resin Wall"
#define RESIN_NEST "Resin Nest"
#define RESIN_DOOR "Resin Door"

/datum/spell/alien_spell/build_resin
	name = "Build Resin Structure"
	desc = "Allows you to create resin structures. Does not work while in space."
	plasma_cost = 55
	action_icon_state = "alien_resin"

/datum/spell/alien_spell/build_resin/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/alien_spell/build_resin/cast(list/targets, mob/living/carbon/user)
	var/static/list/resin_buildings = list(RESIN_WALL = image(icon = 'icons/obj/smooth_structures/alien/resin_wall.dmi', icon_state = "resin_wall-0"),
									RESIN_NEST = image(icon = 'icons/mob/alien.dmi', icon_state = "nest"),
									RESIN_DOOR = image(icon = 'icons/obj/smooth_structures/alien/resin_door.dmi', icon_state = "resin"))
	var/choice = show_radial_menu(user, user, resin_buildings, src, radius = 40)
	var/turf/turf_to_spawn_at = user.loc
	if(!choice)
		revert_cast(user)
		return
	if(!do_mob(user, user, 3 SECONDS))
		revert_cast()
		return
	if(isspaceturf(turf_to_spawn_at))
		to_chat(user, "<span class='alertalien'>You cannot build the [choice] while in space!</span>")
		revert_cast(user)
		return
	var/obj/structure/alien/resin/resin_on_turf = locate() in turf_to_spawn_at
	if(resin_on_turf)
		to_chat(user, "<span class='danger'>There is already a resin construction here.</span>")
		revert_cast(user)
		return
	user.visible_message("<span class='alertalien'>[user] vomits up a thick purple substance and shapes it!</span>")
	switch(choice)
		if(RESIN_WALL)
			new /obj/structure/alien/resin/wall(turf_to_spawn_at)
		if(RESIN_NEST)
			new /obj/structure/bed/nest(turf_to_spawn_at)
		if(RESIN_DOOR)
			new /obj/structure/alien/resin/door(turf_to_spawn_at)

/datum/spell/touch/alien_spell/consume_resin
	name = "Consume resin structures"
	desc = "Allows you to rip and tear straight through resin structures."
	action_icon_state = "alien_resin"
	hand_path = "/obj/item/melee/touch_attack/alien/consume_resin"
	plasma_cost = 10
	base_cooldown = 5 SECONDS

/obj/item/melee/touch_attack/alien/consume_resin
	name = "Resin consumption"
	desc = "The hunger..."
	icon_state = "alien_acid"

/obj/item/melee/touch_attack/alien/consume_resin/after_attack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(target == user)
		to_chat(user, "<span class='noticealien'>You stop trying to consume resin.</span>")
		return
	if(!proximity_flag || !iscarbon(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	var/mob/living/carbon/C = user
	if(istype(target, /obj/structure/alien/weeds))
		qdel(target)
		if(istype(target, /obj/structure/alien/weeds/node))
			C.add_plasma(50)
		C.visible_message("<span class='alertalien'>[C] rips and tears into [target] with their teeth!</span>", "<span class='alertalien'>You viciously rip apart and consume [target]!</span>")
		return
	if(!plasma_check(10, C))
		to_chat(C, "<span class='noticealien'>You don't have enough plasma to perform this action!</span>")
		return
	var/static/list/resin_objects = list(/obj/structure/alien/resin, /obj/structure/alien/egg, /obj/structure/bed/nest)
	for(var/resin_type in resin_objects)
		if(!istype(target, resin_type))
			continue
		C.visible_message("<span class='alertalien'>[C] rips and tears into [target] with their teeth!</span>")
		if(!do_after(C, 3 SECONDS, target = target))
			return
		to_chat(C, "<span class='alertalien'>You viciously rip apart and consume [target]!</span>")
		C.add_plasma(-10)
		qdel(target)
	handle_delete(user)

#undef RESIN_WALL
#undef RESIN_NEST
#undef RESIN_DOOR
