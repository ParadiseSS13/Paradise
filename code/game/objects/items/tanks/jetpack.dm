/obj/item/tank/jetpack
	name = "Jetpack (Empty)"
	desc = "A tank of compressed gas for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack"
	inhand_icon_state = "jetpack"
	lefthand_file = 'icons/mob/inhands/jetpack_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/jetpack_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	distribute_pressure = ONE_ATMOSPHERE * O2STANDARD
	actions_types = list(/datum/action/item_action/set_internals, /datum/action/item_action/toggle_jetpack, /datum/action/item_action/jetpack_stabilization)
	var/gas_type = "oxygen"
	var/on = FALSE
	var/volume_rate = 500              //Needed for borg jetpack transfer
	var/stabilize = FALSE
	var/thrust_callback

/obj/item/tank/jetpack/Initialize(mapload)
	. = ..()
	thrust_callback = CALLBACK(src, PROC_REF(allow_thrust), 0.01)
	configure_jetpack(stabilize)

/obj/item/tank/jetpack/Destroy()
	thrust_callback = null
	return ..()

/**
 * configures/re-configures the jetpack component
 *
 * Arguments
 * stabilize - Should this jetpack be stabalized
 */
/obj/item/tank/jetpack/proc/configure_jetpack(stabilize)
	src.stabilize = stabilize

	AddComponent( \
		/datum/component/jetpack, \
		src.stabilize, \
		COMSIG_JETPACK_ACTIVATED, \
		COMSIG_JETPACK_DEACTIVATED, \
		JETPACK_ACTIVATION_FAILED, \
		thrust_callback, \
		/datum/effect_system/trail_follow/ion \
	)

/obj/item/tank/jetpack/populate_gas()
	if(gas_type)
		switch(gas_type)
			if("oxygen")
				air_contents.set_oxygen(((6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C)))
			if("carbon dioxide")
				air_contents.set_carbon_dioxide(((6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C)))

/obj/item/tank/jetpack/on_mob_move(direction, mob/user)
	if(on)
		var/turf/T = get_step(src, REVERSE_DIR(direction))
		if(!has_gravity(T))
			new /obj/effect/particle_effect/ion_trails(T, direction)

/obj/item/tank/jetpack/ui_action_click(mob/user, actiontype)
	if(actiontype == /datum/action/item_action/toggle_jetpack)
		cycle(user)
	else if(actiontype == /datum/action/item_action/jetpack_stabilization)
		toggle_stabilization(user)
	else
		toggle_internals(user)

/obj/item/tank/jetpack/proc/toggle_stabilization(mob/user)
	if(on)
		configure_jetpack(!stabilize)
		to_chat(user, "<span class='notice'>You turn [src]'s stabilization [stabilize ? "on" : "off"].</span>")

/obj/item/tank/jetpack/proc/cycle(mob/user)
	if(user.incapacitated())
		return

	if(!on)
		turn_on(user)
		to_chat(user, "<span class='notice'>You turn the jetpack on.</span>")
	else
		turn_off(user)
		to_chat(user, "<span class='notice'>You turn the jetpack off.</span>")
	update_action_buttons()

/obj/item/tank/jetpack/proc/turn_on(mob/user)
	if(SEND_SIGNAL(src, COMSIG_JETPACK_ACTIVATED, user) & JETPACK_ACTIVATION_FAILED)
		return FALSE

	on = TRUE
	icon_state = "[initial(icon_state)]-on"

/obj/item/tank/jetpack/proc/turn_off(mob/user)
	SEND_SIGNAL(src, COMSIG_JETPACK_DEACTIVATED, user)
	on = FALSE
	icon_state = initial(icon_state)

/obj/item/tank/jetpack/dropped(mob/user, silent)
	. = ..()
	if(on)
		turn_off(user)

/obj/item/tank/jetpack/proc/allow_thrust(num)
	if(!ismob(loc))
		return FALSE
	var/mob/user = loc

	if((num < 0.005 || air_contents.total_moles() < num))
		turn_off(user)
		return FALSE

	var/datum/gas_mixture/removed = air_contents.remove(num)
	if(removed.total_moles() < 0.005)
		turn_off(user)
		return FALSE

	var/turf/T = get_turf(user)
	T.blind_release_air(removed)
	return TRUE

/obj/item/tank/jetpack/improvised
	name = "improvised jetpack"
	desc = "A jetpack made from two air tanks, a fire extinguisher and some atmospherics equipment. It doesn't look like it can hold much."
	icon_state = "jetpack-improvised"
	inhand_icon_state = "jetpack-improvised"
	volume = 20 //normal jetpacks have 70 volume
	gas_type = null //it starts empty

/obj/item/tank/jetpack/improvised/allow_thrust(num, mob/living/user)
	if(rand(0, 250) == 0)
		to_chat(user, "<span class='notice'>You feel your jetpack's engines cut out.</span>")
		turn_off(user)
		return
	return ..()

/obj/item/tank/jetpack/void
	name = "Void Jetpack (Oxygen)"
	desc = "It works well in a void."
	icon_state = "jetpack-void"
	inhand_icon_state = "jetpack-void"

/obj/item/tank/jetpack/void/grey
	icon_state = "jetpack-void-grey"
	inhand_icon_state = "jetpack-void-grey"

/obj/item/tank/jetpack/void/gold
	name = "Retro Jetpack (Oxygen)"
	icon_state = "jetpack-void-gold"
	inhand_icon_state = "jetpack-void-gold"

/obj/item/tank/jetpack/oxygen
	name = "Jetpack (Oxygen)"
	desc = "A tank of compressed oxygen for use as propulsion in zero-gravity areas. Use with caution."

/obj/item/tank/jetpack/oxygen/harness
	name = "jet harness (oxygen)"
	desc = "A lightweight tactical harness, used by those who don't want to be weighed down by traditional jetpacks."
	icon_state = "jetpack-mini"
	volume = 40
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/tank/jetpack/oxygen/captain
	name = "Captain's jetpack"
	desc = "A compact, lightweight jetpack containing a high amount of compressed oxygen."
	icon_state = "jetpack-captain"
	inhand_icon_state = "jetpack-captain"
	volume = 90
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/tank/jetpack/oxygen/security
	name = "security jetpack (oxygen)"
	desc = "A tank of compressed oxygen for use as propulsion in zero-gravity areas by security forces."
	icon_state = "jetpack-sec"
	inhand_icon_state = "jetpack-sec"

/obj/item/tank/jetpack/carbondioxide
	name = "Jetpack (Carbon Dioxide)"
	desc = "A tank of compressed carbon dioxide for use as propulsion in zero-gravity areas. Painted black to indicate that it should not be used as a source for internals."
	icon_state = "jetpack-black"
	inhand_icon_state = "jetpack-black"
	distribute_pressure = 0
	gas_type = "carbon dioxide"

/obj/item/tank/jetpack/suit
	name = "hardsuit jetpack upgrade"
	desc = "A modular, compact set of thrusters designed to integrate with a hardsuit. It is fueled by a tank inserted into the suit's storage compartment."
	icon_state = "jetpack-mining"
	inhand_icon_state = "jetpack-mining"
	origin_tech = "materials=4;magnets=4;engineering=5"
	w_class = WEIGHT_CLASS_NORMAL
	actions_types = list(/datum/action/item_action/toggle_jetpack, /datum/action/item_action/jetpack_stabilization)
	volume = 1
	slot_flags = null
	gas_type = null
	var/datum/gas_mixture/temp_air_contents
	var/obj/item/tank/internals/tank = null
	var/mob/living/carbon/human/cur_user

/obj/item/tank/jetpack/suit/New()
	..()
	STOP_PROCESSING(SSobj, src)
	temp_air_contents = air_contents

/obj/item/tank/jetpack/suit/attack_self__legacy__attackchain()
	return

/obj/item/tank/jetpack/suit/cycle(mob/user)
	if(!istype(loc, /obj/item/clothing/suit/space/hardsuit))
		to_chat(user, "<span class='warning'>[src] must be connected to a hardsuit!</span>")
		return

	var/mob/living/carbon/human/H = user
	if(!istype(H.s_store, /obj/item/tank))
		to_chat(user, "<span class='warning'>You need a tank in your suit storage!</span>")
		return
	..()

/obj/item/tank/jetpack/suit/turn_on(mob/user)
	if(!istype(loc, /obj/item/clothing/suit/space/hardsuit) || !ishuman(loc.loc) || loc.loc != user)
		return
	var/mob/living/carbon/human/H = user
	tank = H.s_store
	air_contents = tank.air_contents
	START_PROCESSING(SSobj, src)
	cur_user = user
	..()

/obj/item/tank/jetpack/suit/turn_off(mob/user)
	tank = null
	air_contents = temp_air_contents
	STOP_PROCESSING(SSobj, src)
	cur_user = null
	..()

/obj/item/tank/jetpack/suit/process()
	if(!istype(loc, /obj/item/clothing/suit/space/hardsuit) || !ishuman(loc.loc))
		turn_off(cur_user)
		return
	var/mob/living/carbon/human/H = loc.loc
	if(!tank || tank != H.s_store)
		turn_off(cur_user)
		return
	..()
