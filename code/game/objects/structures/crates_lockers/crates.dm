/obj/structure/closet/crate
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/crates.dmi'
	icon_state = "crate"
	icon_opened = "crateopen"
	icon_closed = "crate"
	climbable = 1
//	mouse_drag_pointer = MOUSE_ACTIVE_POINTER	//???
	var/rigged = 0
	var/obj/item/paper/manifest/manifest
	// A list of beacon names that the crate will announce the arrival of, when delivered.
	var/list/announce_beacons = list()

/obj/structure/closet/crate/New()
	..()
	update_icon()

/obj/structure/closet/crate/update_icon()
	..()
	overlays.Cut()
	if(manifest)
		overlays += "manifest"

/obj/structure/closet/crate/can_open()
	return 1

/obj/structure/closet/crate/can_close()
	return 1

/obj/structure/closet/crate/open()
	if(src.opened)
		return 0
	if(!src.can_open())
		return 0

	if(rigged && locate(/obj/item/radio/electropack) in src)
		if(isliving(usr))
			var/mob/living/L = usr
			if(L.electrocute_act(17, src))
				do_sparks(5, 1, src)
				return 2

	playsound(src.loc, 'sound/machines/click.ogg', 15, 1, -3)
	for(var/obj/O in src) //Objects
		O.forceMove(loc)
	for(var/mob/M in src) //Mobs
		M.forceMove(loc)
	icon_state = icon_opened
	src.opened = 1

	if(climbable)
		structure_shaken()

	return 1

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
		if(istype(O, /obj/structure/bed)) //This is only necessary because of rollerbeds and swivel chairs.
			var/obj/structure/bed/B = O
			if(B.buckled_mob)
				continue
		O.forceMove(src)
		itemcount++

	icon_state = icon_closed
	src.opened = 0
	return 1

/obj/structure/closet/crate/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/rcs) && !src.opened)
		var/obj/item/rcs/E = W
		if(E.rcell && (E.rcell.charge >= E.chargecost))
			if(!is_level_reachable(src.z)) // This is inconsistent with the closet sending code
				to_chat(user, "<span class='warning'>The rapid-crate-sender can't locate any telepads!</span>")
				return
			if(E.mode == 0)
				if(!E.teleporting)
					var/list/L = list()
					var/list/areaindex = list()
					for(var/obj/machinery/telepad_cargo/R in world)
						if(R.stage == 0)
							var/turf/T = get_turf(R)
							var/tmpname = T.loc.name
							if(areaindex[tmpname])
								tmpname = "[tmpname] ([++areaindex[tmpname]])"
							else
								areaindex[tmpname] = 1
							L[tmpname] = R
					var/desc = input("Please select a telepad.", "RCS") in L
					E.pad = L[desc]
					if(!Adjacent(user))
						to_chat(user, "<span class='notice'>Unable to teleport, too far from crate.</span>")
						return
					playsound(E.loc, E.usesound, 50, 1)
					to_chat(user, "<span class='notice'>Teleporting [src.name]...</span>")
					E.teleporting = 1
					if(!do_after(user, 50 * E.toolspeed, target = src))
						E.teleporting = 0
						return
					E.teleporting = 0
					if(!(E.rcell && E.rcell.use(E.chargecost)))
						to_chat(user, "<span class='notice'>Unable to teleport, insufficient charge.</span>")
						return
					do_sparks(5, 1, src)
					do_teleport(src, E.pad, 0)
					to_chat(user, "<span class='notice'>Teleport successful. [round(E.rcell.charge/E.chargecost)] charge\s left.</span>")
					return

			else
				E.rand_x = rand(50,200)
				E.rand_y = rand(50,200)
				var/L = locate(E.rand_x, E.rand_y, 6)
				if(!Adjacent(user))
					to_chat(user, "<span class='notice'>Unable to teleport, too far from crate.</span>")
					return
				playsound(E.loc, E.usesound, 50, 1)
				to_chat(user, "<span class='notice'>Teleporting [src.name]...</span>")
				E.teleporting = 1
				if(!do_after(user, 50 * E.toolspeed, target = src))
					E.teleporting = 0
					return
				E.teleporting = 0
				if(!(E.rcell && E.rcell.use(E.chargecost)))
					to_chat(user, "<span class='notice'>Unable to teleport, insufficient charge.</span>")
					return
				do_sparks(5, 1, src)
				do_teleport(src, L)
				to_chat(user, "<span class='notice'>Teleport successful. [round(E.rcell.charge/E.chargecost)] charge\s left.</span>")
				return
		else
			to_chat(user, "<span class='warning'>Out of charges.</span>")
			return

	if(opened)
		if(isrobot(user))
			return
		if(!user.drop_item()) //couldn't drop the item
			to_chat(user, "<span class='notice'>\The [W] is stuck to your hand, you cannot put it in \the [src]!</span>")
			return
		if(W)
			W.forceMove(loc)
	else if(istype(W, /obj/item/stack/packageWrap))
		return
	else if(istype(W, /obj/item/stack/cable_coil))
		if(rigged)
			to_chat(user, "<span class='notice'>[src] is already rigged!</span>")
			return
		to_chat(user, "<span class='notice'>You rig [src].</span>")
		user.drop_item()
		qdel(W)
		rigged = 1
		return
	else if(istype(W, /obj/item/radio/electropack))
		if(rigged)
			to_chat(user, "<span class='notice'>You attach [W] to [src].</span>")
			user.drop_item()
			W.forceMove(src)
			return
	else if(istype(W, /obj/item/wirecutters))
		if(rigged)
			to_chat(user, "<span class='notice'>You cut away the wiring.</span>")
			playsound(loc, W.usesound, 100, 1)
			rigged = 0
			return
	else return attack_hand(user)

/obj/structure/closet/crate/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/obj/O in src.contents)
				qdel(O)
			qdel(src)
			return
		if(2.0)
			for(var/obj/O in src.contents)
				if(prob(50))
					qdel(O)
			qdel(src)
			return
		if(3.0)
			if(prob(50))
				qdel(src)
			return
		else
	return

/obj/structure/closet/crate/attack_hand(mob/user)
	if(manifest)
		to_chat(user, "<span class='notice'>You tear the manifest off of the crate.</span>")
		playsound(src.loc, 'sound/items/poster_ripped.ogg', 75, 1)
		manifest.forceMove(loc)
		if(ishuman(user))
			user.put_in_hands(manifest)
		manifest = null
		update_icon()
		return
	else
		if(rigged && locate(/obj/item/radio/electropack) in src)
			if(isliving(user))
				var/mob/living/L = user
				if(L.electrocute_act(17, src))
					do_sparks(5, 1, src)
					return
		src.add_fingerprint(user)
		src.toggle(user)

// Called when a crate is delivered by MULE at a location, for notifying purposes
/obj/structure/closet/crate/proc/notifyRecipient(var/destination)
	var/msg = "[capitalize(name)] has arrived at [destination]."
	if(destination in announce_beacons)
		for(var/obj/machinery/requests_console/D in allConsoles)
			if(D.department in src.announce_beacons[destination])
				D.createMessage(name, "Your Crate has Arrived!", msg, 1)

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
	broken = 0
	locked = 1
	health = 1000

/obj/structure/closet/crate/secure/update_icon()
	..()
	overlays.Cut()
	if(manifest)
		overlays += "manifest"
	if(locked)
		overlays += redlight
	else if(broken)
		overlays += emag
	else
		overlays += greenlight

/obj/structure/closet/crate/secure/can_open()
	return !locked

/obj/structure/closet/crate/secure/proc/togglelock(mob/user)
	if(src.opened)
		to_chat(user, "<span class='notice'>Close the crate first.</span>")
		return
	if(src.broken)
		to_chat(user, "<span class='warning'>The crate appears to be broken.</span>")
		return
	if(src.allowed(user))
		src.locked = !src.locked
		visible_message("<span class='notice'>The crate has been [locked ? null : "un"]locked by [user].</span>")
		update_icon()
	else
		to_chat(user, "<span class='notice'>Access Denied</span>")

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
		to_chat(usr, "<span class='warning'>This mob type can't use this verb.</span>")

/obj/structure/closet/crate/secure/attack_hand(mob/user)
	if(manifest)
		to_chat(user, "<span class='notice'>You tear the manifest off of the crate.</span>")
		playsound(src.loc, 'sound/items/poster_ripped.ogg', 75, 1)
		manifest.forceMove(loc)
		if(ishuman(user))
			user.put_in_hands(manifest)
		manifest = null
		update_icon()
		return
	if(locked)
		src.togglelock(user)
	else
		src.toggle(user)


/obj/structure/closet/crate/secure/attackby(obj/item/W, mob/user, params)
	if(is_type_in_list(W, list(/obj/item/stack/packageWrap, /obj/item/stack/cable_coil, /obj/item/radio/electropack, /obj/item/wirecutters,/obj/item/rcs)))
		return ..()
	if((istype(W, /obj/item/card/emag) || istype(W, /obj/item/melee/energy/blade)))
		emag_act(user)
		return
	if(!opened)
		src.togglelock(user)
		return
	return ..()

/obj/structure/closet/crate/secure/emag_act(mob/user)
	if(locked)
		overlays += sparks
		spawn(6) overlays -= sparks //Tried lots of stuff but nothing works right. so i have to use this *sadface*
		playsound(src.loc, "sparks", 60, 1)
		src.locked = 0
		src.broken = 1
		update_icon()
		to_chat(user, "<span class='notice'>You unlock \the [src].</span>")

/obj/structure/closet/crate/secure/emp_act(severity)
	for(var/obj/O in src)
		O.emp_act(severity)
	if(!broken && !opened  && prob(50/severity))
		if(!locked)
			src.locked = 1
		else
			overlays += sparks
			spawn(6) overlays -= sparks //Tried lots of stuff but nothing works right. so i have to use this *sadface*
			playsound(src.loc, 'sound/effects/sparks4.ogg', 75, 1)
			src.locked = 0
		update_icon()
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
	name = "internals crate"
	icon_state = "o2crate"
	icon_opened = "o2crateopen"
	icon_closed = "o2crate"

/obj/structure/closet/crate/trashcart
	desc = "A heavy, metal trashcart with wheels."
	name = "trash Cart"
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
	name = "medical crate"
	icon_state = "medicalcrate"
	icon_opened = "medicalcrateopen"
	icon_closed = "medicalcrate"

/obj/structure/closet/crate/rcd
	desc = "A crate for the storage of the RCD."
	name = "\improper RCD crate"
	icon_state = "crate"
	icon_opened = "crateopen"
	icon_closed = "crate"

/obj/structure/closet/crate/rcd/New()
	..()
	new /obj/item/rcd_ammo(src)
	new /obj/item/rcd_ammo(src)
	new /obj/item/rcd_ammo(src)
	new /obj/item/rcd(src)

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


/obj/structure/closet/crate/can
	desc = "A large can, looks like a bin to me."
	name = "garbage can"
	icon_state = "largebin"
	icon_opened = "largebinopen"
	icon_closed = "largebin"
	anchored = TRUE

/obj/structure/closet/crate/can/attackby(obj/item/W, mob/living/user, params)
	if(iswrench(W))
		add_fingerprint(user)
		user.changeNext_move(CLICK_CD_MELEE)
		if(anchored)
			playsound(loc, W.usesound, 100, 1)
			user.visible_message("[user] starts loosening [src]'s floor casters.", \
								 					"<span class='notice'>You start loosening [src]'s floor casters...</span>")
			if(do_after(user, 40 * W.toolspeed, target = src))
				if(!loc || !anchored)
					return
				user.visible_message("[user] loosened [src]'s floor casters.", \
									 					"<span class='notice'>You loosen [src]'s floor casters.</span>")
				anchored = FALSE
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
				anchored = TRUE
	else
		..()

/obj/structure/closet/crate/radiation
	desc = "A crate with a radiation sign on it."
	name = "radioactive gear crate"
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
	name = "weapons crate"
	icon_state = "weaponcrate"
	icon_opened = "weaponcrateopen"
	icon_closed = "weaponcrate"

/obj/structure/closet/crate/secure/plasma
	desc = "A secure plasma crate."
	name = "plasma crate"
	icon_state = "plasmacrate"
	icon_opened = "plasmacrateopen"
	icon_closed = "plasmacrate"

/obj/structure/closet/crate/secure/gear
	desc = "A secure gear crate."
	name = "gear crate"
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
	name = "secure bin"
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
	icon_state = "largemetal"
	icon_opened = "largemetalopen"
	icon_closed = "largemetal"

/obj/structure/closet/crate/large/close()
	. = ..()
	if(.)//we can hold up to one large item
		var/found = 0
		for(var/obj/structure/S in src.loc)
			if(S == src)
				continue
			if(!S.anchored)
				found = 1
				S.forceMove(src)
				break
		if(!found)
			for(var/obj/machinery/M in src.loc)
				if(!M.anchored)
					M.forceMove(src)
					break

/obj/structure/closet/crate/secure/large
	name = "large crate"
	desc = "A hefty metal crate with an electronic locking system."
	icon_state = "largemetal"
	icon_opened = "largemetalopen"
	icon_closed = "largemetal"
	redlight = "largemetalr"
	greenlight = "largemetalg"

/obj/structure/closet/crate/secure/large/close()
	. = ..()
	if(.)//we can hold up to one large item
		var/found = 0
		for(var/obj/structure/S in src.loc)
			if(S == src)
				continue
			if(!S.anchored)
				found = 1
				S.forceMove(src)
				break
		if(!found)
			for(var/obj/machinery/M in src.loc)
				if(!M.anchored)
					M.forceMove(src)
					break

//fluff variant
/obj/structure/closet/crate/secure/large/reinforced
	desc = "A hefty, reinforced metal crate with an electronic locking system."
	icon_state = "largermetal"
	icon_opened = "largermetalopen"
	icon_closed = "largermetal"

/obj/structure/closet/crate/hydroponics
	name = "hydroponics crate"
	desc = "All you need to destroy those pesky weeds and pests."
	icon_state = "hydrocrate"
	icon_opened = "hydrocrateopen"
	icon_closed = "hydrocrate"

/obj/structure/closet/crate/hydroponics/prespawned
	//This exists so the prespawned hydro crates spawn with their contents.

	New()
		..()
		new /obj/item/reagent_containers/glass/bucket(src)
		new /obj/item/reagent_containers/glass/bucket(src)
		new /obj/item/screwdriver(src)
		new /obj/item/screwdriver(src)
		new /obj/item/wrench(src)
		new /obj/item/wrench(src)
		new /obj/item/wirecutters(src)
		new /obj/item/wirecutters(src)
		new /obj/item/shovel/spade(src)
		new /obj/item/shovel/spade(src)
		new /obj/item/storage/box/beakers(src)
		new /obj/item/storage/box/beakers(src)
		new /obj/item/hand_labeler(src)
		new /obj/item/hand_labeler(src)

/obj/structure/closet/crate/sci
	name = "science crate"
	desc = "A science crate."
	icon_state = "scicrate"
	icon_opened = "scicrateopen"
	icon_closed = "scicrate"

/obj/structure/closet/crate/secure/scisec
	name = "secure science crate"
	desc = "A crate with a lock on it, painted in the scheme of the station's scientists."
	icon_state = "scisecurecrate"
	icon_opened = "scisecurecrateopen"
	icon_closed = "scisecurecrate"

/obj/structure/closet/crate/engineering
	name = "engineering crate"
	desc = "An engineering crate."
	icon_state = "engicrate"
	icon_opened = "engicrateopen"
	icon_closed = "engicrate"

/obj/structure/closet/crate/secure/engineering
	name = "secure engineering crate"
	desc = "A crate with a lock on it, painted in the scheme of the station's engineers."
	icon_state = "engisecurecrate"
	icon_opened = "engisecurecrateopen"
	icon_closed = "engisecurecrate"

/obj/structure/closet/crate/engineering/electrical
	name = "electrical engineering crate"
	desc = "An electrical engineering crate."
	icon_state = "electricalcrate"
	icon_opened = "electricalcrateopen"
	icon_closed = "electricalcrate"

/obj/structure/closet/crate/tape/New()
	if(prob(10))
		new /obj/item/bikehorn/rubberducky(src)
	..()

//crates of gear in the free golem ship
/obj/structure/closet/crate/golemgear/New()
	..()
	new /obj/item/storage/backpack/industrial(src)
	new /obj/item/shovel(src)
	new /obj/item/pickaxe(src)
	new /obj/item/t_scanner/adv_mining_scanner/lesser(src)
	new /obj/item/storage/bag/ore(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/card/id/golem(src)
	new /obj/item/flashlight/lantern(src)