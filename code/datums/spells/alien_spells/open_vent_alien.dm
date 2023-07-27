/obj/effect/proc_holder/spell/alien_spell/break_vents
	name = "Break Welded Vent"
	desc = "Breaks welded vent nearby. Can be used from inside the pipes."
	action_icon_state = "acid_vent"
	base_cooldown = 1 SECONDS


/obj/effect/proc_holder/spell/alien_spell/break_vents/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new
	T.selection_type = SPELL_SELECTION_RANGE
	T.random_target = TRUE
	T.range = 1
	T.use_turf_of_user = TRUE
	T.allowed_type = /obj/machinery/atmospherics/unary
	return T


/obj/effect/proc_holder/spell/alien_spell/break_vents/valid_target(target, user)
	if(istype(target, /obj/machinery/atmospherics/unary/vent_scrubber))
		var/obj/machinery/atmospherics/unary/vent_scrubber/scrubber = target
		return scrubber.welded

	if(istype(target, /obj/machinery/atmospherics/unary/vent_pump))
		var/obj/machinery/atmospherics/unary/vent_scrubber/vent = target
		return vent.welded

	return FALSE


/obj/effect/proc_holder/spell/alien_spell/break_vents/cast(list/targets, mob/user)

	var/obj/machinery/atmospherics/unary/vent_pump/vent = targets[1]
	if(!vent)
		to_chat(user, span_warning("No nearby welded vents found!"))
		revert_cast(user)
		return

	playsound(get_turf(user),'sound/weapons/bladeslice.ogg' , 100, FALSE)

	if(!do_after_once(user, 4 SECONDS, target = vent))
		to_chat(user, span_danger("There is no welded vent or scrubber close enough to do this."))
		revert_cast(user)
		return

	playsound(get_turf(user),'sound/weapons/bladeslice.ogg' , 100, FALSE)

	if(vent?.welded)
		vent.welded = FALSE
		vent.update_icon()
		vent.update_pipe_image()
		user.forceMove(vent.loc)
		vent.visible_message(span_danger("[user] smashes the welded cover off [vent]!"))

