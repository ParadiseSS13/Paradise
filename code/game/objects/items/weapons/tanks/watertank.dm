//Hydroponics tank and base code
/obj/item/watertank
	name = "backpack water tank"
	desc = "A S.U.N.S.H.I.N.E. brand watertank backpack with nozzle to water plants."
	icon = 'icons/obj/watertank.dmi'
	icon_state = "waterbackpack"
	item_state = "waterbackpack"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = SLOT_FLAG_BACK
	slowdown = 1
	actions_types = list(/datum/action/item_action/toggle_mister)
	max_integrity = 200
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
	QDEL_NULL(noz)
	return ..()

/obj/item/watertank/ui_action_click(mob/user)
	toggle_mister(user)

/obj/item/watertank/item_action_slot_check(slot, mob/user)
	if(slot == SLOT_HUD_BACK)
		return TRUE

/obj/item/watertank/proc/toggle_mister(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return
	if(user.get_item_by_slot(SLOT_HUD_BACK) != src)
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
	if(slot != SLOT_HUD_BACK)
		remove_noz()

/obj/item/watertank/proc/remove_noz()
	if(ismob(noz.loc))
		var/mob/M = noz.loc
		M.unEquip(noz, 1)
	return

/obj/item/watertank/Destroy()
	if(on)
		remove_noz()
		QDEL_NULL(noz)
	return ..()

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
				if(!H.unEquip(src))
					return
				H.put_in_r_hand(src)
			if("l_hand")
				if(H.l_hand)
					return
				if(!H.unEquip(src))
					return
				H.put_in_l_hand(src)
	return

/obj/item/watertank/attackby(obj/item/W, mob/user, params)
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
	item_state = "mister"
	w_class = WEIGHT_CLASS_BULKY
	amount_per_transfer_from_this = 50
	possible_transfer_amounts = list(25,50,100)
	volume = 500
	flags = NOBLUDGEON
	container_type = OPENCONTAINER

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

/obj/item/reagent_containers/spray/mister/attack_self()
	return

/proc/check_tank_exists(parent_tank, mob/living/carbon/human/M, obj/O)
	if(!parent_tank || !istype(parent_tank, /obj/item/watertank))	//To avoid weird issues from admin spawns
		return FALSE
	else
		return TRUE

/obj/item/reagent_containers/spray/mister/Move()
	..()
	if(loc != tank.loc)
		loc = tank.loc

/obj/item/reagent_containers/spray/mister/afterattack(obj/target, mob/user, proximity)
	if(target.loc == loc || target == tank) //Safety check so you don't fill your mister with mutagen or something and then blast yourself in the face with it putting it away
		return
	..()

//Janitor tank
/obj/item/watertank/janitor
	name = "backpack water tank"
	desc = "A janitorial watertank backpack with nozzle to clean dirt and graffiti."
	icon_state = "waterbackpackjani"
	item_state = "waterbackpackjani"

/obj/item/watertank/janitor/New()
	..()
	reagents.add_reagent("cleaner", 500)

/obj/item/reagent_containers/spray/mister/janitor
	name = "janitor spray nozzle"
	desc = "A janitorial spray nozzle attached to a watertank, designed to clean up large messes."
	icon = 'icons/obj/watertank.dmi'
	icon_state = "misterjani"
	item_state = "misterjani"
	spray_maxrange = 4
	spray_currentrange = 4
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = null

/obj/item/watertank/janitor/make_noz()
	return new /obj/item/reagent_containers/spray/mister/janitor(src)

/obj/item/reagent_containers/spray/mister/janitor/attack_self(mob/user)
	amount_per_transfer_from_this = (amount_per_transfer_from_this == 5 ? 10 : 5)
	spray_currentrange = (spray_currentrange == 2 ? spray_maxrange : 2)
	to_chat(user, "<span class='notice'>You [amount_per_transfer_from_this == 5 ? "remove" : "fix"] the nozzle. You'll now use [amount_per_transfer_from_this] units per spray.</span>")

//ATMOS FIRE FIGHTING BACKPACK

#define EXTINGUISHER 0
#define NANOFROST 1
#define METAL_FOAM 2

/obj/item/watertank/atmos
	name = "backpack firefighter tank"
	desc = "A refridgerated and pressurized backpack tank with extinguisher nozzle, intended to fight fires. Swaps between extinguisher, nanofrost launcher, and metal foam dispenser for breaches. Nanofrost converts plasma in the air to nitrogen, but only if it is combusting at the time."
	icon_state = "waterbackpackatmos"
	item_state = "waterbackpackatmos"
	volume = 500

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
	icon_state = "atmos_nozzle"
	item_state = "nozzleatmos"
	safety = 0
	max_water = 500
	precision = 1
	cooling_power = 5
	w_class = WEIGHT_CLASS_HUGE
	flags = NODROP //Necessary to ensure that the nozzle and tank never seperate
	/// A reference to the tank that this nozzle is linked to
	var/obj/item/watertank/tank
	/// What mode are we currently in?
	var/nozzle_mode = EXTINGUISHER
	/// Are we overusing the metal synthesizer? can be used 5 times in quick succession, regains 1 use per 10 seconds
	var/metal_synthesis_cooldown = 0
	/// Is our nanofrost on cooldown?
	var/nanofrost_cooldown = FALSE

/obj/item/extinguisher/mini/nozzle/Initialize(mapload)
	if(!check_tank_exists(loc, src))
		return INITIALIZE_HINT_QDEL

	tank = loc
	reagents = tank.reagents
	max_water = tank.volume

	return ..()

/obj/item/extinguisher/mini/nozzle/Destroy()
	tank = null
	reagents = null // Unset, this is the tanks reagents
	return ..()

/obj/item/extinguisher/mini/nozzle/Move()
	..()
	if(tank && loc != tank.loc)
		forceMove(tank)

/obj/item/extinguisher/mini/nozzle/attack_self(mob/user)
	switch(nozzle_mode)
		if(EXTINGUISHER)
			nozzle_mode = NANOFROST
			tank.icon_state = "waterbackpackatmos_1"
			to_chat(user, "Swapped to nanofrost launcher")
		if(NANOFROST)
			nozzle_mode = METAL_FOAM
			tank.icon_state = "waterbackpackatmos_2"
			to_chat(user, "Swapped to metal foam synthesizer")
		if(METAL_FOAM)
			nozzle_mode = EXTINGUISHER
			tank.icon_state = "waterbackpackatmos_0"
			to_chat(user, "Swapped to water extinguisher")

/obj/item/extinguisher/mini/nozzle/dropped(mob/user)
	..()
	to_chat(user, "<span class='notice'>The nozzle snaps back onto the tank!</span>")
	tank.on = FALSE
	loc = tank

/obj/item/extinguisher/mini/nozzle/afterattack(atom/target, mob/user)
	if(nozzle_mode == EXTINGUISHER)
		..()
		return
	var/Adj = user.Adjacent(target)
	if(Adj)
		AttemptRefill(target, user)

	switch(nozzle_mode)
		if(NANOFROST)
			if(Adj)
				return //Safety check so you don't blast yourself trying to refill your tank
			if(reagents.total_volume < 100)
				to_chat(user, "<span class='notice'>You need at least 100 units of water to use the nanofrost launcher!</span>")
				return
			if(nanofrost_cooldown)
				to_chat(user, "<span class='notice'>Nanofrost launcher is still recharging.</span>")
				return
			nanofrost_cooldown = TRUE
			reagents.remove_any(100)
			var/obj/effect/nanofrost_container/A = new /obj/effect/nanofrost_container(get_turf(src))
			log_game("[key_name(user)] used Nanofrost at [get_area(user)] ([user.x], [user.y], [user.z]).")
			playsound(src,'sound/items/syringeproj.ogg', 40, TRUE)
			for(var/a in 1 to 6)
				step_towards(A, target)
				sleep(2)
			A.Smoke()
			addtimer(VARSET_CALLBACK(src, nanofrost_cooldown, FALSE))
		if(METAL_FOAM)
			if(!Adj)
				return
			if(metal_synthesis_cooldown >= 5)
				to_chat(user, "<span class='notice'>Metal foam mix is still being synthesized.</span>")
				return
			var/obj/effect/particle_effect/foam/F = new /obj/effect/particle_effect/foam(get_turf(target), TRUE)
			F.amount = 0
			metal_synthesis_cooldown++
			addtimer(CALLBACK(src, PROC_REF(metal_cooldown)), 10 SECONDS)

/obj/item/extinguisher/mini/nozzle/proc/metal_cooldown()
	metal_synthesis_cooldown--

/obj/effect/nanofrost_container
	name = "nanofrost container"
	desc = "A frozen shell of ice containing nanofrost that freezes the surrounding area after activation."
	icon = 'icons/effects/effects.dmi'
	icon_state = "frozen_smoke_capsule"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pass_flags = PASSTABLE

/obj/effect/nanofrost_container/proc/Smoke()
	var/datum/effect_system/smoke_spread/freezing/S = new
	S.set_up(amount = 6, only_cardinals = FALSE, source = loc, desired_direction = null, chemicals = null, blasting = TRUE)
	S.start()
	new /obj/effect/decal/cleanable/flour/nanofrost(get_turf(src))
	playsound(src, 'sound/effects/bamf.ogg', 100, TRUE)
	qdel(src)

#undef EXTINGUISHER
#undef NANOFROST
#undef METAL_FOAM
