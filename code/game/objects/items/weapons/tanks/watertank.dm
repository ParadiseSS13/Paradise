//Hydroponics tank and base code
/obj/item/watertank
	name = "backpack water tank"
	desc = "A S.U.N.S.H.I.N.E. brand watertank backpack with nozzle to water plants."
	icon = 'icons/obj/watertank.dmi'
	icon_state = "waterbackpack"
	item_state = "waterbackpack"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = SLOT_BACK
	slowdown = 1
	actions_types = list(/datum/action/item_action/toggle_mister)

	var/obj/item/noz
	var/on = 0
	var/volume = 500

/obj/item/watertank/New()
	..()
	create_reagents(volume)
	noz = make_noz()

/obj/item/watertank/ui_action_click()
	toggle_mister()

/obj/item/watertank/item_action_slot_check(slot, mob/user)
	if(slot == slot_back)
		return 1

/obj/item/watertank/verb/toggle_mister()
	set name = "Toggle Mister"
	set category = "Object"
	if(usr.get_item_by_slot(slot_back) != src)
		to_chat(usr, "<span class='notice'>The watertank needs to be on your back to use.</span>")
		return
	if(usr.incapacitated())
		return
	on = !on

	var/mob/living/carbon/human/user = usr
	if(on)
		if(noz == null)
			noz = make_noz()

		//Detach the nozzle into the user's hands
		if(!user.put_in_hands(noz))
			on = 0
			to_chat(user, "<span class='notice'>You need a free hand to hold the mister.</span>")
			return
		noz.loc = user
	else
		//Remove from their hands and put back "into" the tank
		remove_noz()
	return

/obj/item/watertank/proc/make_noz()
	return new /obj/item/reagent_containers/spray/mister(src)

/obj/item/watertank/equipped(mob/user, slot)
	..()
	if(slot != slot_back)
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

/obj/item/watertank/attack_hand(mob/user as mob)
	if(src.loc == user)
		ui_action_click()
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
	flags = NODROP | NOBLUDGEON
	container_type = OPENCONTAINER

	var/obj/item/watertank/tank

/obj/item/reagent_containers/spray/mister/New(parent_tank)
	..()
	if(check_tank_exists(parent_tank, src))
		tank = parent_tank
		reagents = tank.reagents	//This mister is really just a proxy for the tank's reagents
		loc = tank
	return

/obj/item/reagent_containers/spray/mister/dropped(mob/user as mob)
	..()
	to_chat(user, "<span class='notice'>The mister snaps back onto the watertank.</span>")
	tank.on = 0
	loc = tank

/obj/item/reagent_containers/spray/mister/attack_self()
	return

/proc/check_tank_exists(parent_tank, var/mob/living/carbon/human/M, var/obj/O)
	if(!parent_tank || !istype(parent_tank, /obj/item/watertank))	//To avoid weird issues from admin spawns
		M.unEquip(O)
		qdel(0)
		return 0
	else
		return 1

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
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = null

/obj/item/watertank/janitor/make_noz()
	return new /obj/item/reagent_containers/spray/mister/janitor(src)

/obj/item/reagent_containers/spray/mister/janitor/attack_self(var/mob/user)
	amount_per_transfer_from_this = (amount_per_transfer_from_this == 10 ? 5 : 10)
	to_chat(user, "<span class='notice'>You [amount_per_transfer_from_this == 10 ? "remove" : "fix"] the nozzle. You'll now use [amount_per_transfer_from_this] units per spray.</span>")

//ATMOS FIRE FIGHTING BACKPACK

#define EXTINGUISHER 0
#define NANOFROST 1
#define METAL_FOAM 2

/obj/item/watertank/atmos
	name = "backpack firefighter tank"
	desc = "A refridgerated and pressurized backpack tank with extinguisher nozzle, intended to fight fires. Swaps between extinguisher, nanofrost launcher, and metal foam dispenser for breaches. Nanofrost converts plasma in the air to nitrogen, but only if it is combusting at the time."
	icon_state = "waterbackpackatmos"
	item_state = "waterbackpackatmos"
	volume = 200

/obj/item/watertank/atmos/New()
	..()
	reagents.add_reagent("water", 200)

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
	max_water = 200
	power = 8
	precision = 1
	cooling_power = 5
	w_class = WEIGHT_CLASS_HUGE
	flags = NODROP //Necessary to ensure that the nozzle and tank never seperate
	var/obj/item/watertank/tank
	var/nozzle_mode = 0
	var/metal_synthesis_cooldown = 0
	var/nanofrost_cooldown = 0

/obj/item/extinguisher/mini/nozzle/New(parent_tank)
	if(check_tank_exists(parent_tank, src))
		tank = parent_tank
		reagents = tank.reagents
		max_water = tank.volume
		loc = tank
	return

/obj/item/extinguisher/mini/nozzle/Move()
	..()
	if(tank && loc != tank.loc)
		loc = tank
	return

/obj/item/extinguisher/mini/nozzle/attack_self(mob/user as mob)
	switch(nozzle_mode)
		if(EXTINGUISHER)
			nozzle_mode = NANOFROST
			tank.icon_state = "waterbackpackatmos_1"
			to_chat(user, "Swapped to nanofrost launcher")
			return
		if(NANOFROST)
			nozzle_mode = METAL_FOAM
			tank.icon_state = "waterbackpackatmos_2"
			to_chat(user, "Swapped to metal foam synthesizer")
			return
		if(METAL_FOAM)
			nozzle_mode = EXTINGUISHER
			tank.icon_state = "waterbackpackatmos_0"
			to_chat(user, "Swapped to water extinguisher")
			return
	return

/obj/item/extinguisher/mini/nozzle/dropped(mob/user as mob)
	..()
	to_chat(user, "<span class='notice'>The nozzle snaps back onto the tank!</span>")
	tank.on = 0
	loc = tank

/obj/item/extinguisher/mini/nozzle/afterattack(atom/target, mob/user)
	if(nozzle_mode == EXTINGUISHER)
		..()
		return
	var/Adj = user.Adjacent(target)
	if(Adj)
		AttemptRefill(target, user)
	if(nozzle_mode == NANOFROST)
		if(Adj)
			return //Safety check so you don't blast yourself trying to refill your tank
		var/datum/reagents/R = reagents
		if(R.total_volume < 50)
			to_chat(user, "You need at least 50 units of water to use the nanofrost launcher!")
			return
		if(nanofrost_cooldown)
			to_chat(user, "Nanofrost launcher is still recharging")
			return
		nanofrost_cooldown = 1
		R.remove_any(50)
		var/obj/effect/nanofrost_container/A = new /obj/effect/nanofrost_container(get_turf(src))
		log_game("[key_name(user)] used Nanofrost at [get_area(user)] ([user.x], [user.y], [user.z]).")
		playsound(src,'sound/items/syringeproj.ogg',40,1)
		for(var/a=0, a<5, a++)
			step_towards(A, target)
			sleep(1)
		A.Smoke()
		spawn(50)
			if(src)
				nanofrost_cooldown = 0
		return
	if(nozzle_mode == METAL_FOAM)
		if(!Adj|| !istype(target, /turf))
			return
		if(metal_synthesis_cooldown < 5)
			var/obj/effect/particle_effect/foam/F = new /obj/effect/particle_effect/foam(get_turf(target), 1)
			F.amount = 0
			metal_synthesis_cooldown++
			spawn(100)
				if(src)
					metal_synthesis_cooldown--
		else
			to_chat(user, "Metal foam mix is still being synthesized.")
			return

/obj/effect/nanofrost_container
	name = "nanofrost container"
	desc = "A frozen shell of ice containing nanofrost that freezes the surrounding area after activation."
	icon = 'icons/effects/effects.dmi'
	icon_state = "frozen_smoke_capsule"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pass_flags = PASSTABLE

/obj/effect/nanofrost_container/proc/Smoke()
	var/datum/effect_system/smoke_spread/freezing/S = new
	S.set_up(6, 0, loc, null, 1)
	S.start()
	var/obj/effect/decal/cleanable/flour/F = new /obj/effect/decal/cleanable/flour(src.loc)
	F.color = "#B2FFFF"
	F.name = "nanofrost residue"
	F.desc = "Residue left behind from a nanofrost detonation. Perhaps there was a fire here?"
	playsound(src,'sound/effects/bamf.ogg',100,1)
	qdel(src)

#undef EXTINGUISHER
#undef NANOFROST
#undef METAL_FOAM
