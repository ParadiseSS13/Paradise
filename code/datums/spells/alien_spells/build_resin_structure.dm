/// Defines include required plasma in brackets
#define ALIEN_RESIN_WALL		"Resin Wall (60)"
#define ALIEN_RESIN_DOOR		"Resin Door (50)"
#define ALIEN_RESIN_MEMBRANE	"Resin Membrane (40)"
#define ALIEN_RESIN_NEST		"Resin Nest (30)"


/obj/effect/proc_holder/spell/alien_spell/build_resin
	name = "Secrete Resin"
	desc = "Secrete tough malleable resin (Use Ctrl+Click on self)."
	plasma_cost = 0
	action_icon_state = "alien_resin"
	var/in_process = FALSE


/obj/effect/proc_holder/spell/alien_spell/build_resin/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/alien_spell/build_resin/cast(list/targets, mob/living/carbon/user)
	var/mob/living/carbon/alien/host = user

	if(in_process)
		to_chat(host, span_noticealien("Ability is already in use!"))
		revert_cast(user)
		return

	var/list/resin_params = list()

	resin_params["Plasma Amount"] = list(
		ALIEN_RESIN_WALL 		= 60,
		ALIEN_RESIN_DOOR 		= 50,
		ALIEN_RESIN_MEMBRANE 	= 40,
		ALIEN_RESIN_NEST 		= 30
	)

	resin_params["Process Time"] = list(
		ALIEN_RESIN_WALL 		= 2 SECONDS,
		ALIEN_RESIN_DOOR 		= 5 SECONDS,
		ALIEN_RESIN_MEMBRANE 	= 2 SECONDS,
		ALIEN_RESIN_NEST 		= 1 SECONDS
	)

	resin_params["Cooldown"] = list(
		ALIEN_RESIN_WALL 		= 3 SECONDS,
		ALIEN_RESIN_DOOR 		= 10 SECONDS,
		ALIEN_RESIN_MEMBRANE 	= 3 SECONDS,
		ALIEN_RESIN_NEST 		= 2 SECONDS
	)

	resin_params["Structure"] = list(
		ALIEN_RESIN_WALL 		= /obj/structure/alien/resin/wall,
		ALIEN_RESIN_DOOR 		= /obj/structure/alien/resin/door,
		ALIEN_RESIN_MEMBRANE 	= /obj/structure/alien/resin/membrane,
		ALIEN_RESIN_NEST 		= /obj/structure/bed/nest
	)

	resin_params["Image"] = list(
		ALIEN_RESIN_WALL		= image(icon = 'icons/obj/smooth_structures/alien/resin_wall.dmi', icon_state = "resin"),
		ALIEN_RESIN_DOOR		= image(icon = 'icons/obj/smooth_structures/alien/resin_door.dmi', icon_state = "resin_door_closed"),
		ALIEN_RESIN_MEMBRANE 	= image(icon = 'icons/obj/smooth_structures/alien/resin_membrane.dmi', icon_state = "membrane"),
		ALIEN_RESIN_NEST 		= image(icon = 'icons/mob/alien.dmi', icon_state = "nest")
	)

	var/choice = show_radial_menu(host, host, resin_params["Image"], radius = 40, custom_check = CALLBACK(src, PROC_REF(check_availability), host))

	if(!choice || !check_availability(host, resin_params["Plasma Amount"][choice]))
		revert_cast(host)
		return

	host.visible_message(span_warning("[host] starts vomitting purple substance on the surface!"), \
						span_notice("You start vomitting resin for future use."))

	in_process = TRUE
	if(!do_after(host, resin_params["Process Time"][choice], target = host))
		in_process = FALSE
		revert_cast(host)
		return
	in_process = FALSE

	if(!check_availability(host, resin_params["Plasma Amount"][choice]))
		revert_cast(host)
		return

	cooldown_handler.recharge_duration = resin_params["Cooldown"][choice]
	cooldown_handler.start_recharge()

	host.adjust_alien_plasma(-(resin_params["Plasma Amount"][choice]))

	var/build_path = resin_params["Structure"][choice]
	var/obj/alien_structure = new build_path(host.loc)

	playsound_xenobuild(alien_structure)
	host.visible_message(span_warning("[host] vomits up a thick purple substance and shapes it into the [alien_structure.name]!"), \
						span_alertalien("You finished shaping vomited resin into the [alien_structure.name]."))


/obj/effect/proc_holder/spell/alien_spell/build_resin/proc/check_availability(mob/living/carbon/user, plasma_amount)
	if(!istype(user))
		return FALSE

	if(QDELETED(user) || QDELETED(src))
		return FALSE

	if(isspaceturf(user.loc))
		to_chat(user, span_noticealien("You cannot build the resin while in space!"))
		return FALSE

	if(plasma_amount && user.get_plasma() < plasma_amount)
		to_chat(user, span_noticealien("Not enough plasma stored."))
		return FALSE

	if(user.incapacitated())
		to_chat(user, span_noticealien("You can't do this right now!"))
		return FALSE

	var/turf/source_turf = get_turf(user)
	if((locate(/obj/structure/alien/resin) in source_turf.contents) || (locate(/obj/structure/bed/nest) in source_turf.contents))
		to_chat(user, span_noticealien("This place is already occupied!"))
		return FALSE

	return TRUE


/mob/living/carbon/alien/humanoid/CtrlClick(mob/living/carbon/alien/humanoid/alien)
	if(!istype(alien) || src != alien)
		return ..()

	var/obj/effect/proc_holder/spell/alien_spell/build_resin/resin = locate() in alien.mob_spell_list
	if(!resin)
		return

	resin.try_perform(list(alien), alien)


#undef ALIEN_RESIN_WALL
#undef ALIEN_RESIN_DOOR
#undef ALIEN_RESIN_MEMBRANE
#undef ALIEN_RESIN_NEST
