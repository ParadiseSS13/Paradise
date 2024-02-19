/datum/spell/alien_spell/build_resin
	name = "Build Resin Structure"
	desc = "Allows you to create resin structures. Does not work while in space."
	plasma_cost = 55
	action_icon_state = "alien_resin"

/datum/spell/alien_spell/build_resin/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/alien_spell/build_resin/cast(list/targets, mob/living/carbon/user)
	var/static/list/resin_buildings = list("Resin Wall (55)" = image(icon = 'icons/obj/smooth_structures/alien/resin_wall.dmi', icon_state = "resin_wall-0"),
									"Resin Nest (55)" = image(icon = 'icons/mob/alien.dmi', icon_state = "nest"),
									"Resin door (80)" = image(icon = 'icons/obj/smooth_structures/alien/resin_door.dmi', icon_state = "resin"))
	var/choice = show_radial_menu(user, user, resin_buildings, src, radius = 40)
	var/turf/turf_to_spawn_at = user.loc
	if(!choice)
		revert_cast(user)
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
		if("Resin Wall (55)")
			new /obj/structure/alien/resin/wall(turf_to_spawn_at)
		if("Resin Nest (55)")
			new /obj/structure/bed/nest(turf_to_spawn_at)
		if("Resin door (80)")
			var/plasma_current = user.get_plasma()
			if(plasma_current >= 25)
				new /obj/structure/alien/resin/door(turf_to_spawn_at)
				user.add_plasma(-25)
				return
			to_chat(user, "<span class='danger'>You don't have enough plasma to place a door down.</span>")
			revert_cast(user)
