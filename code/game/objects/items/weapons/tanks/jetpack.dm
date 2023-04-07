/obj/item/tank/jetpack
	name = "Jetpack (Empty)"
	desc = "A tank of compressed gas for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack"
	w_class = WEIGHT_CLASS_BULKY
	item_state = "jetpack"
	distribute_pressure = ONE_ATMOSPHERE * O2STANDARD
	actions_types = list(/datum/action/item_action/set_internals, /datum/action/item_action/toggle_jetpack, /datum/action/item_action/jetpack_stabilization)
	var/gas_type = "oxygen"
	var/on = 0
	var/stabilizers = 0
	var/volume_rate = 500              //Needed for borg jetpack transfer

/obj/item/tank/jetpack/populate_gas()
	if(gas_type)
		switch(gas_type)
			if("oxygen")
				air_contents.oxygen = ((6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C))
			if("carbon dioxide")
				air_contents.carbon_dioxide = ((6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C))

/obj/item/tank/jetpack/ui_action_click(mob/user, actiontype)
	if(actiontype == /datum/action/item_action/toggle_jetpack || actiontype == /datum/action/item_action/toggle_jetpack/ninja)
		cycle(user)
	else if(actiontype == /datum/action/item_action/jetpack_stabilization || actiontype == /datum/action/item_action/jetpack_stabilization/ninja)
		toggle_stabilization(user)
	else
		toggle_internals(user)

/obj/item/tank/jetpack/proc/toggle_stabilization(mob/user)
	if(on)
		stabilizers = !stabilizers
		to_chat(user, "<span class='notice'>You turn [src]'s stabilization [stabilizers ? "on" : "off"].</span>")
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/tank/jetpack/proc/cycle(mob/user, must_be_on_back = TRUE)
	if(user.incapacitated())
		return

	if(must_be_on_back && src != user.back)
		to_chat(user, "<span class='warning'>You need [src] to be on your back!</span>")
		return

	if(!on)
		turn_on(user)
		to_chat(user, "<span class='notice'>You turn the jetpack on.</span>")
	else
		turn_off(user)
		to_chat(user, "<span class='notice'>You turn the jetpack off.</span>")
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()


/obj/item/tank/jetpack/proc/turn_on(mob/user)
	on = TRUE
	icon_state = "[initial(icon_state)]-on"

/obj/item/tank/jetpack/proc/turn_off(mob/user)
	on = FALSE
	stabilizers = FALSE
	icon_state = initial(icon_state)

/obj/item/tank/jetpack/proc/allow_thrust(num, mob/living/user, should_leave_trail)
	if(!on)
		return 0
	if((num < 0.005 || air_contents.total_moles() < num))
		turn_off(user)
		return 0

	var/datum/gas_mixture/removed = air_contents.remove(num)
	if(removed.total_moles() < 0.005)
		turn_off(user)
		return 0

	var/turf/T = get_turf(user)
	T.assume_air(removed)

	if(!has_gravity(T) && should_leave_trail)
		new /obj/effect/particle_effect/ion_trails(T)

	return 1

/obj/item/tank/jetpack/Moved(OldLoc, Dir, Forced)
	var/mob/living/carbon/human/holder = loc
	if(on && !(istype(loc) && holder.back == src))
		turn_off()
	..()

/obj/item/tank/jetpack/improvised
	name = "improvised jetpack"
	desc = "A jetpack made from two air tanks, a fire extinguisher and some atmospherics equipment. It doesn't look like it can hold much."
	icon_state = "jetpack-improvised"
	item_state = "jetpack-improvised"
	volume = 20 //normal jetpacks have 70 volume
	gas_type = null //it starts empty

/obj/item/tank/jetpack/improvised/allow_thrust(num, mob/living/user, should_leave_trail)
	if(rand(0, 250) == 0)
		to_chat(user, "<span class='notice'>You feel your jetpack's engines cut out.</span>")
		turn_off(user)
		return
	return ..()

/obj/item/tank/jetpack/void
	name = "Void Jetpack (Oxygen)"
	desc = "It works well in a void."
	icon_state = "jetpack-void"
	item_state =  "jetpack-void"

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

/obj/item/tank/jetpack/oxygen/harness
	name = "jet harness (oxygen)"
	desc = "A lightweight tactical harness, used by those who don't want to be weighed down by traditional jetpacks."
	icon_state = "jetpack-mini"
	item_state = "jetpack-mini"
	volume = 40
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/tank/jetpack/oxygen/captain
	name = "Captain's jetpack"
	desc = "A compact, lightweight jetpack containing a high amount of compressed oxygen."
	icon_state = "jetpack-captain"
	item_state = "jetpack-captain"
	volume = 90
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF //steal objective items are hard to destroy.

/obj/item/tank/jetpack/oxygen/security
	name = "security jetpack (oxygen)"
	desc = "A tank of compressed oxygen for use as propulsion in zero-gravity areas by security forces."
	icon_state = "jetpack-sec"
	item_state = "jetpack-sec"

/obj/item/tank/jetpack/carbondioxide
	name = "Jetpack (Carbon Dioxide)"
	desc = "A tank of compressed carbon dioxide for use as propulsion in zero-gravity areas. Painted black to indicate that it should not be used as a source for internals."
	distribute_pressure = 0
	icon_state = "jetpack-black"
	item_state =  "jetpack-black"
	gas_type = "carbon dioxide"

/obj/item/tank/jetpack/suit
	name = "hardsuit jetpack upgrade"
	desc = "A modular, compact set of thrusters designed to integrate with a hardsuit. It is fueled by a tank inserted into the suit's storage compartment."
	icon_state = "jetpack-mining"
	item_state = "jetpack-black"
	origin_tech = "materials=4;magnets=4;engineering=5"
	w_class = WEIGHT_CLASS_NORMAL
	actions_types = list(/datum/action/item_action/toggle_jetpack, /datum/action/item_action/jetpack_stabilization)
	volume = 1
	slot_flags = null
	gas_type = null
	fillable = FALSE
	var/datum/gas_mixture/temp_air_contents
	var/obj/item/tank/internals/tank = null
	var/mob/living/carbon/human/cur_user
	var/req_suit_type = /obj/item/clothing/suit/space/hardsuit
	var/req_suit_name = "hardsuit"

/obj/item/tank/jetpack/suit/New()
	..()
	STOP_PROCESSING(SSobj, src)
	temp_air_contents = air_contents

/obj/item/tank/jetpack/suit/attack_self()
	return

/obj/item/tank/jetpack/suit/examine(mob/user)
	. = ..(user, show_contents_info = FALSE)

/obj/item/tank/jetpack/suit/cycle(mob/user)
	if(!istype(loc, req_suit_type))
		to_chat(user, "<span class='warning'>[src] must be connected to a [req_suit_name]!</span>")
		return

	var/mob/living/carbon/human/H = user
	if(!istype(H.s_store, /obj/item/tank))
		to_chat(user, "<span class='warning'>You need a tank in your suit storage!</span>")
		return
	..(user, must_be_on_back = FALSE)

/obj/item/tank/jetpack/suit/turn_on(mob/user)
	if(!istype(loc, req_suit_type) || !ishuman(loc.loc) || loc.loc != user)
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
	if(!istype(loc, req_suit_type) || !ishuman(loc.loc))
		turn_off(cur_user)
		return
	var/mob/living/carbon/human/H = loc.loc
	if(!tank || tank != H.s_store)
		turn_off(cur_user)
		return
	..()

/obj/item/tank/jetpack/suit/ninja
	name = "ninja jetpack upgrade"
	desc = "A modular, compact set of thrusters designed to integrate with ninja's suit. It is fueled by a tank inserted into the suit's storage compartment."
	icon = 'icons/obj/ninjaobjects.dmi'
	icon_state = "ninja_jetpack"
	actions_types = list(/datum/action/item_action/toggle_jetpack/ninja, /datum/action/item_action/jetpack_stabilization/ninja)
	req_suit_type = /obj/item/clothing/suit/space/space_ninja
	req_suit_name = "ninja suit"

/obj/item/tank/jetpack/suit/ninja/New()
	. = ..()
	var/datum/action/item_action/jetpack_action
	for(jetpack_action in actions)
		jetpack_action.button_icon = 'icons/mob/actions/actions_ninja.dmi'
		jetpack_action.background_icon_state = "background_green"

/obj/item/tank/jetpack/suit/ninja/allow_thrust(num, mob/living/user, should_leave_trail)
	. = ..(num, user, cur_user?.alpha != NINJA_ALPHA_INVISIBILITY && should_leave_trail)
