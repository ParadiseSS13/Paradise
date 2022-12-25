/obj/effect/proc_holder/spell/alien_spell/build_resin
	name = "Build Resin Structure"
	desc = "Allows you to create resin structures, does not work while in space."
	plasma_cost = 55
	action_icon_state = "alien_resin"

/obj/effect/proc_holder/spell/alien_spell/build_resin/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/alien_spell/build_resin/cast(list/targets, mob/living/carbon/user)
	var/list/resin_buildings = list("Resin Wall (55)" = image(icon = 'icons/obj/smooth_structures/alien/resin_wall.dmi', icon_state = "resin_wall-0"),
									"Resin Membrane (55)" = image(icon = 'icons/obj/smooth_structures/alien/resin_membrane.dmi', icon_state = "resin_membrane-0"),
									"Resin Nest (55)" = image(icon = 'icons/obj/smooth_structures/alien/nest.dmi', icon_state = "nest-0"))
	var/choice = show_radial_menu(user, user, resin_buildings, src, radius = 40)
	var/turf/T = user.loc
	if(!choice)
		revert_cast(user)
		return
	if(isspaceturf(T))
		to_chat(user, "<span class='alertalien'>You cannot build the [choice] while in space!")
		revert_cast(user)
		return
	visible_message("<span class='alertalien'>[user] vomits up a thick purple substance and shapes it!</span>")
	switch(choice)
		if("Resin Wall (55)")
			new /obj/structure/alien/resin/wall(T)
		if("Resin Membrane (55)")
			new /obj/structure/alien/resin/membrane(T)
		if("Resin Nest (55)")
			new /obj/structure/bed/nest(T)
