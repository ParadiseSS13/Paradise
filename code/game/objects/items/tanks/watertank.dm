//Hydroponics tank and base code
/obj/item/watertank
	name = "backpack water tank"
	desc = "A S.U.N.S.H.I.N.E. brand watertank backpack with nozzle to water plants."
	icon = 'icons/obj/watertank.dmi'
	icon_state = "waterbackpack"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	slowdown = 1
	actions_types = list(/datum/action/item_action/toggle_mister)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 100, ACID = 30)
	resistance_flags = FIRE_PROOF

	var/obj/item/noz
	var/on = FALSE
	var/volume = 500

/obj/item/watertank/New()
	..()
	create_reagents(volume)
	noz = make_noz()

/obj/item/watertank/Destroy()
	if(on)
		remove_noz()
	QDEL_NULL(noz)
	return ..()

/obj/item/watertank/ui_action_click(mob/user)
	toggle_mister(user)

/obj/item/watertank/item_action_slot_check(slot, mob/user)
	if(slot == ITEM_SLOT_BACK)
		return TRUE

/obj/item/watertank/proc/toggle_mister(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return
	if(user.get_item_by_slot(ITEM_SLOT_BACK) != src)
		to_chat(user, "<span class='notice'>The watertank needs to be on your back to use.</span>")
		return
	on = !on
	if(on)
		if(!noz)
			noz = make_noz()

		//Detach the nozzle into the user's hands
		if(!user.put_in_hands(noz))
			on = FALSE
			to_chat(user, "<span class='notice'>You need a free hand to hold the mister.</span>")
			return
		noz.forceMove(user)
	else
		//Remove from their hands and put back "into" the tank
		remove_noz()
	return

/obj/item/watertank/proc/make_noz()
	return new /obj/item/reagent_containers/spray/mister(src)

/obj/item/watertank/equipped(mob/user, slot)
	..()
	if(slot != ITEM_SLOT_BACK)
		remove_noz()

/obj/item/watertank/proc/remove_noz()
	if(ismob(noz.loc))
		var/mob/M = noz.loc
		M.drop_item_to_ground(noz, force = TRUE)
	return

/obj/item/watertank/attack_hand(mob/user)
	if(loc == user)
		toggle_mister(user)
		return
	..()

/obj/item/watertank/MouseDrop(obj/over_object)
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		switch(over_object.name)
			if("r_hand")
				if(H.r_hand)
					return
				if(!H.unequip(src))
					return
				H.put_in_r_hand(src)
			if("l_hand")
				if(H.l_hand)
					return
				if(!H.unequip(src))
					return
				H.put_in_l_hand(src)
	return

/obj/item/watertank/attackby__legacy__attackchain(obj/item/W, mob/user, params)
	if(W == noz)
		remove_noz()
		return
	..()

// This mister item is intended as an extension of the watertank and always attached to it.
// Therefore, it's designed to be "locked" to the player's hands or extended back onto
// the watertank backpack. Allowing it to be placed elsewhere or created without a parent
// watertank object will likely lead to weird behaviour or runtimes.
/obj/item/reagent_containers/spray/mister
	name = "water mister"
	desc = "A mister nozzle attached to a water tank."
	icon = 'icons/obj/watertank.dmi'
	icon_state = "mister"
	w_class = WEIGHT_CLASS_BULKY
	amount_per_transfer_from_this = 50
	possible_transfer_amounts = list(25,50,100)
	volume = 500
	var/obj/item/watertank/tank

/obj/item/reagent_containers/spray/mister/Initialize(mapload)
	if(!check_tank_exists(loc, src))
		return INITIALIZE_HINT_QDEL
	tank = loc
	reagents = tank.reagents	//This mister is really just a proxy for the tank's reagents
	return ..()

/obj/item/reagent_containers/spray/mister/Destroy()
	tank = null
	reagents = null // Unset, this is the tanks reagents
	return ..()

/obj/item/reagent_containers/spray/mister/dropped(mob/user as mob)
	..()
	to_chat(user, "<span class='notice'>The mister snaps back onto the watertank.</span>")
	tank.on = FALSE
	loc = tank

/proc/check_tank_exists(parent_tank, mob/living/carbon/human/M, obj/O)
	if(!parent_tank || (!istype(parent_tank, /obj/item/watertank) && !istype(parent_tank, /obj/item/mod/module/firefighting_tank)))	//To avoid weird issues from admin spawns
		return FALSE
	else
		return TRUE

/obj/item/reagent_containers/spray/mister/Move()
	..()
	if(loc != tank.loc)
		loc = tank.loc

/obj/item/reagent_containers/spray/mister/normal_act(atom/target, mob/living/user)
	if(target.loc == loc || target == tank)
		return FALSE

	return ..()

//Janitor tank
/obj/item/watertank/janitor
	desc = "A janitorial watertank backpack with nozzle to clean dirt and graffiti."
	icon_state = "waterbackpackjani"

/obj/item/watertank/janitor/New()
	..()
	reagents.add_reagent("cleaner", 500)

/obj/item/reagent_containers/spray/mister/janitor
	name = "janitor spray nozzle"
	desc = "A janitorial spray nozzle attached to a watertank, designed to clean up large messes."
	icon_state = "misterjani"
	spray_maxrange = 4
	spray_currentrange = 4
	spray_minrange = 2
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = null

/obj/item/watertank/janitor/make_noz()
	return new /obj/item/reagent_containers/spray/mister/janitor(src)

//ATMOS FIRE FIGHTING BACKPACK

#define EXTINGUISHER 0
#define NANOFROST 1
#define METAL_FOAM 2

/obj/item/watertank/atmos
	name = "backpack firefighter tank"
	desc = "A refridgerated and pressurized backpack tank with extinguisher nozzle, intended to fight fires. Swaps between extinguisher, nanofrost launcher, and metal foam dispenser for breaches. Nanofrost converts plasma in the air to nitrogen, but only if it is combusting at the time."
	icon_state = "waterbackpackatmos"
	worn_icon_state = "waterbackpackatmos"
	inhand_icon_state = "waterbackpackatmos"

/obj/item/watertank/atmos/New()
	..()
	reagents.add_reagent("water", 500)

/obj/item/watertank/atmos/make_noz()
	return new /obj/item/extinguisher/mini/nozzle(src)

/obj/item/watertank/atmos/dropped(mob/user as mob)
	..()
	icon_state = "waterbackpackatmos"
	if(istype(noz, /obj/item/extinguisher/mini/nozzle))
		var/obj/item/extinguisher/mini/nozzle/N = noz
		N.nozzle_mode = 0

/obj/item/extinguisher/mini/nozzle
	name = "extinguisher nozzle"
	desc = "A heavy duty nozzle attached to a firefighter's backpack tank."
	icon = 'icons/obj/watertank.dmi'
	icon_state = "atmos_nozzle_1"
	inhand_icon_state = "nozzleatmos"
	has_safety = FALSE
	safety_active = FALSE
	reagent_capacity = 500
	precision = TRUE
	w_class = WEIGHT_CLASS_HUGE
	flags = NODROP //Necessary to ensure that the nozzle and tank never seperate
	/// A reference to the tank that this nozzle is linked to
	var/obj/item/watertank/tank
	/// What mode are we currently in?
	var/nozzle_mode = EXTINGUISHER
	/// How many shots of metal foam do we have?
	var/metal_synthesis_charge = 5
	/// Time to refill 1 charge of metal foam.
	var/metal_regen_time = 2 SECONDS
	/// Refire delay for nanofrost chunks.
	var/nanofrost_cooldown_time = 2 SECONDS
	COOLDOWN_DECLARE(nanofrost_cooldown)

/obj/item/extinguisher/mini/nozzle/examine(mob/user)
	. = ..()
	switch(nozzle_mode)
		if(EXTINGUISHER)
			. += "<span class='notice'>[src] is currently set to extinguishing mode.</span>"
		if(NANOFROST)
			. += "<span class='notice'>[src] is currently set to nanofrost mode.</span>"
		if(METAL_FOAM)
			. += "<span class='notice'>[src] is currently set to metal foam mode.</span>"

/obj/item/extinguisher/mini/nozzle/Initialize(mapload)
	if(!check_tank_exists(loc, src))
		return INITIALIZE_HINT_QDEL

	tank = loc
	reagents = tank.reagents
	reagent_capacity = tank.volume

	return ..()

/obj/item/extinguisher/mini/nozzle/Destroy()
	tank = null
	reagents = null // Unset, this is the tanks reagents
	return ..()

/obj/item/extinguisher/mini/nozzle/Move()
	..()
	if(tank && loc != tank.loc)
		forceMove(tank)

/obj/item/extinguisher/mini/nozzle/activate_self(mob/user)
	..()
	switch(nozzle_mode)
		if(EXTINGUISHER)
			nozzle_mode = NANOFROST
			to_chat(user, "Swapped to nanofrost launcher")
		if(NANOFROST)
			nozzle_mode = METAL_FOAM
			to_chat(user, "Swapped to metal foam synthesizer")
		if(METAL_FOAM)
			nozzle_mode = EXTINGUISHER
			to_chat(user, "Swapped to water extinguisher")
	update_icon(UPDATE_ICON_STATE)
	return ITEM_INTERACT_COMPLETE

/obj/item/extinguisher/mini/nozzle/update_icon_state()
	switch(nozzle_mode)
		if(EXTINGUISHER)
			icon_state = "atmos_nozzle_1"
			tank.icon_state = "waterbackpackatmos_0"
		if(NANOFROST)
			icon_state = "atmos_nozzle_2"
			tank.icon_state = "waterbackpackatmos_1"
		if(METAL_FOAM)
			icon_state = "atmos_nozzle_3"
			tank.icon_state = "waterbackpackatmos_2"

/obj/item/extinguisher/mini/nozzle/dropped(mob/user)
	..()
	if(istype(tank, /obj/item/mod/module/firefighting_tank))
		return

	to_chat(user, "<span class='notice'>The nozzle snaps back onto the tank!</span>")
	tank.on = FALSE
	loc = tank

/obj/item/extinguisher/mini/nozzle/extinguisher_spray(atom/A, mob/living/user)
	if(nozzle_mode == EXTINGUISHER)
		return ..()

	. = TRUE
	switch(nozzle_mode)
		if(NANOFROST)
			if(reagents.total_volume < 100)
				to_chat(user, "<span class='warning'>You need at least 100 units of water to use the nanofrost launcher!</span>")
				return

			if(COOLDOWN_TIMELEFT(src, nanofrost_cooldown))
				to_chat(user, "<span class='warning'>The nanofrost launcher is still recharging!</span>")
				return

			COOLDOWN_START(src, nanofrost_cooldown, nanofrost_cooldown_time)
			reagents.remove_any(100)
			var/obj/effect/nanofrost_container/iceball = new /obj/effect/nanofrost_container(get_turf(src))
			log_game("[key_name(user)] used Nanofrost at [get_area(user)] ([user.x], [user.y], [user.z]).")
			playsound(src,'sound/items/syringeproj.ogg', 40, TRUE)
			iceball.throw_at(A, 6, 2, user)
			sleep(2)
			iceball.Smoke()
			return

		if(METAL_FOAM)
			if(!user.Adjacent(A) || !isturf(A))
				return

			if(metal_synthesis_charge <= 0)
				to_chat(user, "<span class='warning'>Metal foam mix is still being synthesized!</span>")
				return

			if(reagents.total_volume < 10)
				to_chat(user, "<span class='warning'>You need at least 10 units of water to use the metal foam synthesizer!</span>")
				return

			var/obj/effect/particle_effect/foam/metal/foam = new /obj/effect/particle_effect/foam/metal(get_turf(A), TRUE)
			foam.spread_amount = 0
			reagents.remove_any(10)
			metal_synthesis_charge--
			addtimer(CALLBACK(src, PROC_REF(refill_metal_charge)), metal_regen_time)
			return

/obj/item/extinguisher/mini/nozzle/proc/refill_metal_charge()
	metal_synthesis_charge++

/obj/effect/nanofrost_container
	name = "nanofrost container"
	desc = "A frozen shell of ice containing nanofrost that freezes the surrounding area after activation."
	icon_state = "frozen_smoke_capsule"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pass_flags = PASSTABLE

/obj/effect/nanofrost_container/proc/Smoke()
	var/datum/effect_system/smoke_spread/freezing/S = new
	S.set_up(amount = 6, only_cardinals = FALSE, source = loc)
	S.start()
	new /obj/effect/decal/cleanable/flour/nanofrost(get_turf(src))
	playsound(src, 'sound/effects/bamf.ogg', 100, TRUE)
	qdel(src)

/obj/effect/nanofrost_container/anomaly
	name = "nanofrost anomaly"
	desc = "A frozen shell of ice containing nanofrost that freezes the surrounding area."
	icon_state = "frozen_smoke_anomaly"

#undef EXTINGUISHER
#undef NANOFROST
#undef METAL_FOAM
