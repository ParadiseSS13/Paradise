/datum/spell/morph_spell/open_vent
	name = "Open Vents"
	desc = "Spit out acidic puke on nearby vents or scrubbers. Will take a little while for the acid to take effect. Not usable from inside a vent."
	action_icon_state = "acid_vent"
	hunger_cost = 10

/datum/spell/morph_spell/open_vent/create_new_targeting()
	var/datum/spell_targeting/aoe/T = new
	T.range = 1
	T.allowed_type = /obj/machinery/atmospherics/unary
	return T

/datum/spell/morph_spell/open_vent/valid_target(target, user)
	if(istype(target, /obj/machinery/atmospherics/unary/vent_scrubber))
		var/obj/machinery/atmospherics/unary/vent_scrubber/S = target
		return S.welded
	else if(istype(target, /obj/machinery/atmospherics/unary/vent_pump))
		var/obj/machinery/atmospherics/unary/vent_scrubber/V = target
		return V.welded
	return FALSE

/datum/spell/morph_spell/open_vent/cast(list/targets, mob/user)
	if(!length(targets))
		to_chat(user, "<span class='warning'>No nearby welded vents found!</span>")
		revert_cast(user)
		return
	to_chat(user, "<span class='sinister'>You begin regurgitating up some acidic puke!</span>")
	if(!do_after(user, 2 SECONDS, FALSE, user))
		to_chat(user, "<span class='warning'>You swallow the acid again.</span>")
		revert_cast(user)
		return
	for(var/thing in targets)
		var/obj/machinery/atmospherics/unary/U = thing
		U.add_overlay(GLOB.acid_overlay, TRUE)
		addtimer(CALLBACK(src, PROC_REF(unweld_vent), U), 2 SECONDS)
		playsound(U, 'sound/items/welder.ogg', 100, TRUE)

/datum/spell/morph_spell/open_vent/proc/unweld_vent(obj/machinery/atmospherics/unary/U)
	if(istype(U, /obj/machinery/atmospherics/unary/vent_scrubber))
		var/obj/machinery/atmospherics/unary/vent_scrubber/S = U
		S.welded = FALSE
	else if(istype(U, /obj/machinery/atmospherics/unary/vent_pump))
		var/obj/machinery/atmospherics/unary/vent_scrubber/V = U
		V.welded = FALSE
	U.update_icon()
	U.cut_overlay(GLOB.acid_overlay, TRUE)
