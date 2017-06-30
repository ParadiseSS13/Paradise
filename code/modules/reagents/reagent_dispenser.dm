/obj/structure/reagent_dispensers
	name = "Dispenser"
	desc = "..."
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertank"
	density = 1
	anchored = 0
	pressure_resistance = 2*ONE_ATMOSPHERE

	var/tank_volume = 1000 //In units, how much the dispenser can hold
	var/reagent_id = "water" //The ID of the reagent that the dispenser uses

/obj/structure/reagent_dispensers/attackby(obj/item/weapon/W, mob/user, params)
	return

/obj/structure/reagent_dispensers/New()
	create_reagents(tank_volume)
	reagents.add_reagent(reagent_id, tank_volume)
	..()

/obj/structure/reagent_dispensers/examine(mob/user)
	if(!..(user, 2))
		return
	if(reagents.total_volume)
		to_chat(user, "<span class='notice'>It has [reagents.total_volume] units left.</span>")
	else
		to_chat(user, "<span class='danger'>It's empty.</span>")


/obj/structure/reagent_dispensers/proc/boom()
	visible_message("<span class='danger'>[src] ruptures!</span>")
	chem_splash(loc, 5, list(reagents))
	qdel(src)

/obj/structure/reagent_dispensers/ex_act(severity)
	switch(severity)
		if(1)
			boom()
		if(2)
			if(prob(50))
				boom()
		if(3)
			if(prob(5))
				boom()

/obj/structure/reagent_dispensers/blob_act()
	if(prob(50))
		boom()


//Dispensers
/obj/structure/reagent_dispensers/watertank
	name = "water tank"
	desc = "A water tank."
	icon_state = "water"

/obj/structure/reagent_dispensers/watertank/high
	name = "high-capacity water tank"
	desc = "A highly-pressurized water tank made to hold gargantuan amounts of water.."
	icon_state = "water_high" //I was gonna clean my room...
	tank_volume = 100000


/obj/structure/reagent_dispensers/fueltank
	name = "fuel tank"
	desc = "A tank full of industrial welding fuel. Do not consume."
	icon_state = "fuel"
	reagent_id = "fuel"
	var/obj/item/device/assembly_holder/rig = null
	var/accepts_rig = 1

/obj/structure/reagent_dispensers/fueltank/Destroy()
	QDEL_NULL(rig)
	return ..()

/obj/structure/reagent_dispensers/fueltank/bullet_act(obj/item/projectile/P)
	..()
	if(!qdeleted(src)) //wasn't deleted by the projectile's effects.
		if(!P.nodamage && ((P.damage_type == BURN) || (P.damage_type == BRUTE)))
			message_admins("[key_name_admin(P.firer)] triggered a fueltank explosion.")
			log_game("[key_name(P.firer)] triggered a fueltank explosion.")
			boom()

/obj/structure/reagent_dispensers/fueltank/boom()
	explosion(loc, 0, 1, 5, 7, 10, flame_range = 5)
	qdel(src)

/obj/structure/reagent_dispensers/fueltank/blob_act()
	boom()

/obj/structure/reagent_dispensers/fueltank/ex_act()
	boom()

/obj/structure/reagent_dispensers/fueltank/fire_act()
	boom()

/obj/structure/reagent_dispensers/fueltank/tesla_act()
	..() //extend the zap
	boom()

/obj/structure/reagent_dispensers/fueltank/examine(mob/user)
	if(!..(user, 2))
		return
	if(rig)
		to_chat(usr, "<span class='notice'>There is some kind of device rigged to the tank.</span>")

/obj/structure/reagent_dispensers/fueltank/attack_hand()
	if(rig)
		usr.visible_message("<span class='notice'>[usr] begins to detach [rig] from [src].</span>", "<span class='notice'>You begin to detach [rig] from [src].</span>")
		if(do_after(usr, 20, target = src))
			usr.visible_message("<span class='notice'>[usr] detaches [rig] from [src].</span>", "<span class='notice'>You detach [rig] from [src].</span>")
			rig.forceMove(get_turf(usr))
			rig = null
			overlays.Cut()

/obj/structure/reagent_dispensers/fueltank/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/assembly_holder) && accepts_rig)
		if(rig)
			to_chat(user, "<span class='warning'>There is another device in the way.</span>")
			return ..()
		user.visible_message("[user] begins rigging [I] to [src].", "You begin rigging [I] to [src]")
		if(do_after(user, 20, target = src))
			user.visible_message("<span class='notice'>[user] rigs [I] to [src].</span>", "<span class='notice'>You rig [I] to [src].</span>")

			var/obj/item/device/assembly_holder/H = I
			if(istype(H.a_left, /obj/item/device/assembly/igniter) || istype(H.a_right, /obj/item/device/assembly/igniter))
				msg_admin_attack("[key_name_admin(user)] rigged a fueltank for explosion (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
				log_game("[key_name(user)] rigged fueltank a fueltank for explosion at [loc.x], [loc.y], [loc.z]")

				rig = H
				user.drop_item()
				H.forceMove(src)

				var/icon/test = getFlatIcon(H)
				test.Shift(NORTH, 1)
				test.Shift(EAST, 6)
				overlays += test

	if(istype(I, /obj/item/weapon/weldingtool))
		if(!reagents.has_reagent("fuel"))
			to_chat(user, "<span class='warning'>[src] is out of fuel!</span>")
			return
		var/obj/item/weapon/weldingtool/W = I
		if(!W.welding)
			if(W.reagents.has_reagent("fuel", W.max_fuel))
				to_chat(user, "<span class='warning'>Your [W] is already full!</span>")
				return
			reagents.trans_to(W, W.max_fuel)
			user.visible_message("<span class='notice'>[user] refills \his [W].</span>", "<span class='notice'>You refill [W].</span>")
			playsound(src, 'sound/effects/refill.ogg', 50, 1)
			W.update_icon()
		else
			user.visible_message("<span class='warning'>[user] catastrophically fails at refilling \his [W]!</span>", "<span class='userdanger'>That was stupid of you.</span>")
			message_admins("[key_name_admin(user)] triggered a fueltank explosion.")
			log_game("[key_name(user)] triggered a fueltank explosion.")
			boom()
	else
		..()

/obj/structure/reagent_dispensers/fueltank/Move()
	..()
	if(rig)
		rig.process_movement()

/obj/structure/reagent_dispensers/fueltank/HasProximity(atom/movable/AM)
	if(rig)
		rig.HasProximity(AM)

/obj/structure/reagent_dispensers/fueltank/Crossed(atom/movable/AM)
	if(rig)
		rig.Crossed(AM)

/obj/structure/reagent_dispensers/fueltank/hear_talk(mob/living/M, msg)
	if(rig)
		rig.hear_talk(M, msg)

/obj/structure/reagent_dispensers/fueltank/hear_message(mob/living/M, msg)
	if(rig)
		rig.hear_message(M, msg)

/obj/structure/reagent_dispensers/fueltank/Bump()
	..()
	if(rig)
		rig.process_movement()


/obj/structure/reagent_dispensers/peppertank
	name = "pepper spray refiller"
	desc = "Contains condensed capsaicin for use in law \"enforcement.\""
	icon_state = "pepper"
	anchored = 1
	density = 0
	reagent_id = "condensedcapsaicin"

/obj/structure/reagent_dispensers/water_cooler
	name = "liquid cooler"
	desc = "A machine that dispenses liquid to drink."
	icon = 'icons/obj/vending.dmi'
	icon_state = "water_cooler"
	anchored = 1
	tank_volume = 500
	var/paper_cups = 25 //Paper cups left from the cooler

/obj/structure/reagent_dispensers/water_cooler/examine(mob/user)
	if(!..(user, 2))
		return
	to_chat(user, "There are [paper_cups ? paper_cups : "no"] paper cups left.")

/obj/structure/reagent_dispensers/water_cooler/attack_hand(mob/living/user)
	if(!paper_cups)
		to_chat(user, "<span class='warning'>There aren't any cups left!</span>")
		return
	user.visible_message("<span class='notice'>[user] takes a cup from [src].</span>", "<span class='notice'>You take a paper cup from [src].</span>")
	var/obj/item/weapon/reagent_containers/food/drinks/sillycup/S = new(get_turf(src))
	user.put_in_hands(S)
	paper_cups--

/obj/structure/reagent_dispensers/water_cooler/attackby(obj/item/weapon/W, mob/living/user, params)
	add_fingerprint(user)
	user.changeNext_move(CLICK_CD_MELEE)
	if(iswrench(W))
		if(anchored)
			playsound(loc, W.usesound, 100, 1)
			user.visible_message("[user] starts loosening [src]'s floor casters.", \
								 "<span class='notice'>You start loosening [src]'s floor casters...</span>")
			if(do_after(user, 40 * W.toolspeed, target = src))
				if(!loc || !anchored)
					return
				user.visible_message("[user] loosened [src]'s floor casters.", \
									 "<span class='notice'>You loosen [src]'s floor casters.</span>")
				anchored = 0
		else
			if(!isfloorturf(loc))
				user.visible_message("<span class='warning'>A floor must be present to secure [src]!</span>")
				return
			playsound(loc, W.usesound, 100, 1)
			user.visible_message("[user] start securing [src]'s floor casters...", \
								 "<span class='notice'>You start securing [src]'s floor casters...</span>")
			if(do_after(user, 40 * W.toolspeed, target = src))
				if(!loc || anchored)
					return
				user.visible_message("[user] has secured [src]'s floor casters.", \
									 "<span class='notice'>You have secured [src]'s floor casters.</span>")
				anchored = 1

/obj/structure/reagent_dispensers/beerkeg
	name = "beer keg"
	desc = "Beer is liquid bread, it's good for you..."
	icon_state = "beer"
	reagent_id = "beer"

/obj/structure/reagent_dispensers/beerkeg/blob_act()
	explosion(loc, 0, 3, 5, 7, 10)
	qdel(src)

/obj/structure/reagent_dispensers/virusfood
	name = "virus food dispenser"
	desc = "A dispenser of low-potency virus mutagenic."
	icon_state = "virus_food"
	anchored = 1
	density = 0
	reagent_id = "virusfood"

/obj/structure/reagent_dispensers/spacecleanertank
	name = "space cleaner refiller"
	desc = "Refills space cleaner bottles."
	icon_state = "cleaner"
	anchored = 1
	density = 0
	tank_volume = 5000
	reagent_id = "cleaner"

/obj/structure/reagent_dispensers/fueltank/chem
	icon_state = "fuel_chem"
	anchored = 1
	density = 0
	accepts_rig = 0
