/obj/item/tank/jetpack
	name = "Jetpack (Empty)"
	desc = "A tank of compressed gas for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack"
	w_class = WEIGHT_CLASS_BULKY
	item_state = "jetpack"
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD
	var/datum/effect_system/trail_follow/ion/ion_trail
	actions_types = list(/datum/action/item_action/set_internals, /datum/action/item_action/toggle_jetpack, /datum/action/item_action/jetpack_stabilization)
	var/on = 0
	var/stabilizers = 0
	var/volume_rate = 500              //Needed for borg jetpack transfer

/obj/item/tank/jetpack/New()
	..()
	ion_trail = new /datum/effect_system/trail_follow/ion()
	ion_trail.set_up(src)

/obj/item/tank/jetpack/Destroy()
	QDEL_NULL(ion_trail)
	return ..()

/obj/item/tank/jetpack/ui_action_click(mob/user, actiontype)
	if(actiontype == /datum/action/item_action/toggle_jetpack)
		cycle(user)
	else if(actiontype == /datum/action/item_action/jetpack_stabilization)
		toggle_stabilization(user)
	else
		toggle_internals(user)

/obj/item/tank/jetpack/proc/toggle_stabilization(mob/user)
	if(on)
		stabilizers = !stabilizers
		to_chat(user, "<span class='notice'>You turn [src]'s stabilization [stabilizers ? "on" : "off"].</span>")


/obj/item/tank/jetpack/examine(mob/user)
	if(!..(user, 0))
		return

	if(air_contents.oxygen < 10)
		to_chat(user, "<span class='danger'>The meter on [src] indicates you are almost out of air!</span>")
		playsound(user, 'sound/effects/alert.ogg', 50, 1)


/obj/item/tank/jetpack/proc/cycle(mob/user)
	if(user.incapacitated())
		return

	if(!on)
		turn_on()
		to_chat(user, "<span class='notice'>You turn the jetpack on.</span>")
	else
		turn_off()
		to_chat(user, "<span class='notice'>You turn the jetpack off.</span>")
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()


/obj/item/tank/jetpack/proc/turn_on()
	on = TRUE
	icon_state = "[initial(icon_state)]-on"
	ion_trail.start()

/obj/item/tank/jetpack/proc/turn_off()
	on = FALSE
	stabilizers = FALSE
	icon_state = initial(icon_state)
	ion_trail.stop()


/obj/item/tank/jetpack/proc/allow_thrust(num, mob/living/user as mob)
	if(!on)
		return 0
	if((num < 0.005 || air_contents.total_moles() < num))
		turn_off()
		return 0

	var/datum/gas_mixture/removed = air_contents.remove(num)
	if(removed.total_moles() < 0.005)
		turn_off()
		return 0

	var/turf/T = get_turf(user)
	T.assume_air(removed)
	return 1

/obj/item/tank/jetpack/void
	name = "Void Jetpack (Oxygen)"
	desc = "It works well in a void."
	icon_state = "jetpack-void"
	item_state =  "jetpack-void"

/obj/item/tank/jetpack/void/New()
	..()
	air_contents.oxygen = (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)

/obj/item/tank/jetpack/void/grey
	name = "Void Jetpack (Oxygen)"
	icon_state = "jetpack-void-grey"

/obj/item/tank/jetpack/void/gold
	name = "Retro Jetpack (Oxygen)"
	icon_state = "jetpack-void-gold"


/obj/item/tank/jetpack/oxygen
	name = "Jetpack (Oxygen)"
	desc = "A tank of compressed oxygen for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack"
	item_state = "jetpack"

/obj/item/tank/jetpack/oxygen/New()
	..()
	air_contents.oxygen = (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)

/obj/item/tank/jetpack/oxygen/captain
	name = "Captain's jetpack"
	desc = "A compact, lightweight jetpack containing a high amount of compressed oxygen."
	icon_state = "jetpack-captain"
	item_state = "jetpack-captain"
	volume = 90
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/tank/jetpack/oxygen/harness
	name = "jet harness (oxygen)"
	desc = "A lightweight tactical harness, used by those who don't want to be weighed down by traditional jetpacks."
	icon_state = "jetpack-mini"
	item_state = "jetpack-mini"
	volume = 40
	throw_range = 8
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/tank/jetpack/oxygenblack
	name = "Jetpack (Oxygen)"
	desc = "A black tank of compressed oxygen for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack-black"
	item_state = "jetpack-black"

/obj/item/tank/jetpack/oxygenblack/New()
	..()
	air_contents.oxygen = (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)

/obj/item/tank/jetpack/carbondioxide
	name = "Jetpack (Carbon Dioxide)"
	desc = "A tank of compressed carbon dioxide for use as propulsion in zero-gravity areas. Painted black to indicate that it should not be used as a source for internals."
	distribute_pressure = 0
	icon_state = "jetpack-black"
	item_state =  "jetpack-black"

/obj/item/tank/jetpack/carbondioxide/New()
	..()
	ion_trail = new /datum/effect_system/trail_follow/ion()
	ion_trail.set_up(src)
	air_contents.carbon_dioxide = (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)

/obj/item/tank/jetpack/carbondioxide/examine(mob/user)
	if(!..(user, 0))
		return

	if(air_contents.carbon_dioxide < 10)
		to_chat(user, "<span class='danger'>The meter on [src] indicates you are almost out of air!</span>")
		playsound(user, 'sound/effects/alert.ogg', 50, 1)


/obj/item/tank/jetpack/rig
	name = "jetpack"
	var/obj/item/rig/holder
	actions_types = list(/datum/action/item_action/toggle_jetpack, /datum/action/item_action/jetpack_stabilization)

/obj/item/tank/jetpack/rig/examine()
	to_chat(usr, "It's a jetpack. If you can see this, report it on the bug tracker.")
	return 0

/obj/item/tank/jetpack/rig/allow_thrust(num, mob/living/user as mob)
	if(!on)
		return 0

	if(!istype(holder) || !holder.air_supply)
		return 0

	var/datum/gas_mixture/removed = holder.air_supply.air_contents.remove(num)
	if(removed.total_moles() < 0.005)
		turn_off()
		return 0

	var/turf/T = get_turf(user)
	T.assume_air(removed)

	return 1
