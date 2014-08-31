//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/structure/closet/crate
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/storage.dmi'
	icon_state = "crate"
	icon_opened = "crateopen"
	icon_closed = "crate"
	climbable = 1
//	mouse_drag_pointer = MOUSE_ACTIVE_POINTER	//???
	var/rigged = 0

/obj/structure/closet/crate/can_open()
	return 1

/obj/structure/closet/crate/can_close()
	return 1

/obj/structure/closet/crate/open()
	if(src.opened)
		return 0
	if(!src.can_open())
		return 0

	if(rigged && locate(/obj/item/device/radio/electropack) in src)
		if(isliving(usr))
			var/mob/living/L = usr
			if(L.electrocute_act(17, src))
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, src)
				s.start()
				return 2

	playsound(src.loc, 'sound/machines/click.ogg', 15, 1, -3)
	for(var/obj/O in src)
		O.loc = get_turf(src)
	icon_state = icon_opened
	src.opened = 1

	if(climbable)
		structure_shaken()

	return

/obj/structure/closet/crate/close()
	if(!src.opened)
		return 0
	if(!src.can_close())
		return 0

	playsound(src.loc, 'sound/machines/click.ogg', 15, 1, -3)
	var/itemcount = 0
	for(var/obj/O in get_turf(src))
		if(itemcount >= storage_capacity)
			break
		if(O.density || O.anchored || istype(O,/obj/structure/closet))
			continue
		if(istype(O, /obj/structure/stool/bed)) //This is only necessary because of rollerbeds and swivel chairs.
			var/obj/structure/stool/bed/B = O
			if(B.buckled_mob)
				continue
		O.loc = src
		itemcount++

	icon_state = icon_closed
	src.opened = 0
	return 1

/obj/structure/closet/crate/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(opened)
		if(isrobot(user))
			return
		user.drop_item()
		if(W)
			W.loc = src.loc
	else if(istype(W, /obj/item/weapon/packageWrap))
		return
	else if(istype(W, /obj/item/stack/cable_coil))
		if(rigged)
			user << "<span class='notice'>[src] is already rigged!</span>"
			return
		user  << "<span class='notice'>You rig [src].</span>"
		user.drop_item()
		del(W)
		rigged = 1
		return
	else if(istype(W, /obj/item/device/radio/electropack))
		if(rigged)
			user  << "<span class='notice'>You attach [W] to [src].</span>"
			user.drop_item()
			W.loc = src
			return
	else if(istype(W, /obj/item/weapon/wirecutters))
		if(rigged)
			user  << "<span class='notice'>You cut away the wiring.</span>"
			playsound(loc, 'sound/items/Wirecutter.ogg', 100, 1)
			rigged = 0
			return
	else return attack_hand(user)

/obj/structure/closet/crate/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/obj/O in src.contents)
				del(O)
			qdel(src)
			return
		if(2.0)
			for(var/obj/O in src.contents)
				if(prob(50))
					del(O)
			qdel(src)
			return
		if(3.0)
			if (prob(50))
				qdel(src)
			return
		else
	return

/obj/structure/closet/crate/secure
	desc = "A secure crate."
	name = "Secure crate"
	icon_state = "securecrate"
	icon_opened = "securecrateopen"
	icon_closed = "securecrate"
	var/redlight = "securecrater"
	var/greenlight = "securecrateg"
	var/sparks = "securecratesparks"
	var/emag = "securecrateemag"
	var/broken = 0
	var/locked = 1

/obj/structure/closet/crate/secure/New()
	..()
	if(locked)
		overlays.Cut()
		overlays += redlight
	else
		overlays.Cut()
		overlays += greenlight

/obj/structure/closet/crate/secure/can_open()
	return !locked

/obj/structure/closet/crate/secure/proc/togglelock(mob/user as mob)
	if(src.opened)
		user << "<span class='notice'>Close the crate first.</span>"
		return
	if(src.broken)
		user << "<span class='warning'>The crate appears to be broken.</span>"
		return
	if(src.allowed(user))
		src.locked = !src.locked
		for(var/mob/O in viewers(user, 3))
			if((O.client && !( O.blinded )))
				O << "<span class='notice'>The crate has been [locked ? null : "un"]locked by [user].</span>"
		overlays.Cut()
		overlays += locked ? redlight : greenlight
	else
		user << "<span class='notice'>Access Denied</span>"

/obj/structure/closet/crate/secure/verb/verb_togglelock()
	set src in oview(1) // One square distance
	set category = null
	set name = "Toggle Lock"

	if(!usr.canmove || usr.stat || usr.restrained()) // Don't use it if you're not able to! Checks for stuns, ghost and restrain
		return

	if(ishuman(usr))
		src.add_fingerprint(usr)
		src.togglelock(usr)
	else
		usr << "<span class='warning'>This mob type can't use this verb.</span>"

/obj/structure/closet/crate/secure/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	if(locked)
		src.togglelock(user)
	else
		src.toggle(user)

/obj/structure/closet/crate/secure/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(is_type_in_list(W, list(/obj/item/weapon/packageWrap, /obj/item/stack/cable_coil, /obj/item/device/radio/electropack, /obj/item/weapon/wirecutters)))
		return ..()
	if(locked && (istype(W, /obj/item/weapon/card/emag)||istype(W, /obj/item/weapon/melee/energy/blade)))
		overlays.Cut()
		overlays += emag
		overlays += sparks
		spawn(6) overlays -= sparks //Tried lots of stuff but nothing works right. so i have to use this *sadface*
		playsound(src.loc, "sparks", 60, 1)
		src.locked = 0
		src.broken = 1
		user << "<span class='notice'>You unlock \the [src].</span>"
		return
	if(!opened)
		src.togglelock(user)
		return
	return ..()

/obj/structure/closet/crate/secure/emp_act(severity)
	for(var/obj/O in src)
		O.emp_act(severity)
	if(!broken && !opened  && prob(50/severity))
		if(!locked)
			src.locked = 1
			overlays.Cut()
			overlays += redlight
		else
			overlays.Cut()
			overlays += emag
			overlays += sparks
			spawn(6) overlays -= sparks //Tried lots of stuff but nothing works right. so i have to use this *sadface*
			playsound(src.loc, 'sound/effects/sparks4.ogg', 75, 1)
			src.locked = 0
	if(!opened && prob(20/severity))
		if(!locked)
			open()
		else
			src.req_access = list()
			src.req_access += pick(get_all_accesses())
	..()

/obj/structure/closet/crate/plastic
	name = "plastic crate"
	desc = "A rectangular plastic crate."
	icon_state = "plasticcrate"
	icon_opened = "plasticcrateopen"
	icon_closed = "plasticcrate"

/obj/structure/closet/crate/internals
	desc = "A internals crate."
	name = "Internals crate"
	icon_state = "o2crate"
	icon_opened = "o2crateopen"
	icon_closed = "o2crate"

/obj/structure/closet/crate/trashcart
	desc = "A heavy, metal trashcart with wheels."
	name = "Trash Cart"
	icon_state = "trashcart"
	icon_opened = "trashcartopen"
	icon_closed = "trashcart"

/*these aren't needed anymore
/obj/structure/closet/crate/hat
	desc = "A crate filled with Valuable Collector's Hats!."
	name = "Hat Crate"
	icon_state = "crate"
	icon_opened = "crateopen"
	icon_closed = "crate"

/obj/structure/closet/crate/contraband
	name = "Poster crate"
	desc = "A random assortment of posters manufactured by providers NOT listed under Nanotrasen's whitelist."
	icon_state = "crate"
	icon_opened = "crateopen"
	icon_closed = "crate"
*/

/obj/structure/closet/crate/medical
	desc = "A medical crate."
	name = "Medical crate"
	icon_state = "medicalcrate"
	icon_opened = "medicalcrateopen"
	icon_closed = "medicalcrate"

/obj/structure/closet/crate/rcd
	desc = "A crate for the storage of the RCD."
	name = "RCD crate"
	icon_state = "crate"
	icon_opened = "crateopen"
	icon_closed = "crate"

/obj/structure/closet/crate/rcd/New()
	..()
	new /obj/item/weapon/rcd_ammo(src)
	new /obj/item/weapon/rcd_ammo(src)
	new /obj/item/weapon/rcd_ammo(src)
	new /obj/item/weapon/rcd(src)

/obj/structure/closet/crate/freezer
	desc = "A freezer."
	name = "Freezer"
	icon_state = "freezer"
	icon_opened = "freezeropen"
	icon_closed = "freezer"
	var/target_temp = T0C - 40
	var/cooling_power = 40

	return_air()
		var/datum/gas_mixture/gas = (..())
		if(!gas)	return null
		var/datum/gas_mixture/newgas = new/datum/gas_mixture()
		newgas.oxygen = gas.oxygen
		newgas.carbon_dioxide = gas.carbon_dioxide
		newgas.nitrogen = gas.nitrogen
		newgas.toxins = gas.toxins
		newgas.volume = gas.volume
		newgas.temperature = gas.temperature
		if(newgas.temperature <= target_temp)	return

		if((newgas.temperature - cooling_power) > target_temp)
			newgas.temperature -= cooling_power
		else
			newgas.temperature = target_temp
		return newgas


/obj/structure/closet/crate/bin
	desc = "A large bin."
	name = "Large bin"
	icon_state = "largebin"
	icon_opened = "largebinopen"
	icon_closed = "largebin"

/obj/structure/closet/crate/radiation
	desc = "A crate with a radiation sign on it."
	name = "Radioactive gear crate"
	icon_state = "radiation"
	icon_opened = "radiationopen"
	icon_closed = "radiation"

/obj/structure/closet/crate/radiation/New()
	..()
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)

/obj/structure/closet/crate/secure/weapon
	desc = "A secure weapons crate."
	name = "Weapons crate"
	icon_state = "weaponcrate"
	icon_opened = "weaponcrateopen"
	icon_closed = "weaponcrate"

/obj/structure/closet/crate/secure/plasma
	desc = "A secure plasma crate."
	name = "Plasma crate"
	icon_state = "plasmacrate"
	icon_opened = "plasmacrateopen"
	icon_closed = "plasmacrate"

/obj/structure/closet/crate/secure/gear
	desc = "A secure gear crate."
	name = "Gear crate"
	icon_state = "secgearcrate"
	icon_opened = "secgearcrateopen"
	icon_closed = "secgearcrate"

/obj/structure/closet/crate/secure/hydrosec
	desc = "A crate with a lock on it, painted in the scheme of the station's botanists."
	name = "secure hydroponics crate"
	icon_state = "hydrosecurecrate"
	icon_opened = "hydrosecurecrateopen"
	icon_closed = "hydrosecurecrate"

/obj/structure/closet/crate/secure/bin
	desc = "A secure bin."
	name = "Secure bin"
	icon_state = "largebins"
	icon_opened = "largebinsopen"
	icon_closed = "largebins"
	redlight = "largebinr"
	greenlight = "largebing"
	sparks = "largebinsparks"
	emag = "largebinemag"

/obj/structure/closet/crate/large
	name = "large crate"
	desc = "A hefty metal crate."
	icon = 'icons/obj/storage.dmi'
	icon_state = "largemetal"
	icon_opened = "largemetalopen"
	icon_closed = "largemetal"

/obj/structure/closet/crate/large/close()
	. = ..()
	if (.)//we can hold up to one large item
		var/found = 0
		for(var/obj/structure/S in src.loc)
			if(S == src)
				continue
			if(!S.anchored)
				found = 1
				S.loc = src
				break
		if(!found)
			for(var/obj/machinery/M in src.loc)
				if(!M.anchored)
					M.loc = src
					break
	return

/obj/structure/closet/crate/secure/large
	name = "large crate"
	desc = "A hefty metal crate with an electronic locking system."
	icon = 'icons/obj/storage.dmi'
	icon_state = "largemetal"
	icon_opened = "largemetalopen"
	icon_closed = "largemetal"
	redlight = "largemetalr"
	greenlight = "largemetalg"

/obj/structure/closet/crate/secure/large/close()
	. = ..()
	if (.)//we can hold up to one large item
		var/found = 0
		for(var/obj/structure/S in src.loc)
			if(S == src)
				continue
			if(!S.anchored)
				found = 1
				S.loc = src
				break
		if(!found)
			for(var/obj/machinery/M in src.loc)
				if(!M.anchored)
					M.loc = src
					break
	return

//fluff variant
/obj/structure/closet/crate/secure/large/reinforced
	desc = "A hefty, reinforced metal crate with an electronic locking system."
	icon_state = "largermetal"
	icon_opened = "largermetalopen"
	icon_closed = "largermetal"

/obj/structure/closet/crate/hydroponics
	name = "Hydroponics crate"
	desc = "All you need to destroy those pesky weeds and pests."
	icon_state = "hydrocrate"
	icon_opened = "hydrocrateopen"
	icon_closed = "hydrocrate"

/obj/structure/closet/crate/hydroponics/prespawned
	//This exists so the prespawned hydro crates spawn with their contents.

	New()
		..()
		new /obj/item/weapon/reagent_containers/spray/plantbgone(src)
		new /obj/item/weapon/reagent_containers/spray/plantbgone(src)
		new /obj/item/weapon/minihoe(src)
//		new /obj/item/weapon/weedspray(src)
//		new /obj/item/weapon/weedspray(src)
//		new /obj/item/weapon/pestspray(src)
//		new /obj/item/weapon/pestspray(src)
//		new /obj/item/weapon/pestspray(src)
