/obj/structure/closet/crate
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/crates.dmi'
	icon_state = "crate"
	icon_opened = "crate_open"
	icon_closed = "crate"
	climbable = TRUE
	var/rigged = FALSE
	open_sound = 'sound/machines/crate_open.ogg'
	close_sound = 'sound/machines/crate_close.ogg'
	open_sound_volume = 35
	close_sound_volume = 50
	var/obj/item/paper/manifest/manifest
	/// A list of beacon names that the crate will announce the arrival of, when delivered.
	var/list/announce_beacons = list()
	/// How much this crate is worth if you sell it via the cargo shuttle, needed for balance :)
	var/crate_value = DEFAULT_CRATE_VALUE

/obj/structure/closet/crate/update_overlays()
	. = ..()
	if(manifest)
		. += "manifest"

/obj/structure/closet/crate/can_open()
	return TRUE

/obj/structure/closet/crate/can_close()
	return TRUE

/obj/structure/closet/crate/open(by_hand = FALSE)
	if(opened)
		return FALSE
	if(!can_open())
		return FALSE

	if(by_hand)
		for(var/obj/O in src)
			if(O.density)
				var/response = alert(usr, "This crate has been packed with bluespace compression, an item inside won't fit back inside. Are you sure you want to open it?","Bluespace Compression Warning", "Yes", "No")
				if(response == "No" || !Adjacent(usr))
					return FALSE
				break

	if(rigged && locate(/obj/item/electropack) in src)
		if(isliving(usr))
			var/mob/living/L = usr
			if(L.electrocute_act(17, src))
				do_sparks(5, 1, src)
				return 2

	playsound(loc, open_sound, open_sound_volume, TRUE, -3)
	for(var/obj/O in src) //Objects
		O.forceMove(loc)
	for(var/mob/M in src) //Mobs
		M.forceMove(loc)
	icon_state = icon_opened
	opened = TRUE

	if(climbable)
		structure_shaken()

	return TRUE

/obj/structure/closet/crate/close()
	if(!opened)
		return FALSE
	if(!can_close())
		return FALSE

	playsound(loc, close_sound, close_sound_volume, TRUE, -3)
	var/itemcount = 0
	for(var/atom/movable/O in get_turf(src))
		if(itemcount >= storage_capacity)
			break
		if(O.density || O.anchored || istype(O,/obj/structure/closet))
			continue
		if(ismob(O) && !HAS_TRAIT(O, TRAIT_CONTORTED_BODY))
			continue
		if(istype(O, /obj/structure/bed)) //This is only necessary because of rollerbeds and swivel chairs.
			var/obj/structure/bed/B = O
			if(B.has_buckled_mobs())
				continue
		O.forceMove(src)
		itemcount++

	icon_state = icon_closed
	opened = FALSE
	return TRUE

/obj/structure/closet/crate/attackby(obj/item/W, mob/user, params)
	if(!opened && try_rig(W, user))
		return
	return ..()

/obj/structure/closet/crate/toggle(mob/user, by_hand = FALSE)
	if(!(opened ? close() : open(by_hand)))
		to_chat(user, "<span class='notice'>It won't budge!</span>")

/obj/structure/closet/crate/proc/try_rig(obj/item/W, mob/user)
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W
		if(rigged)
			to_chat(user, "<span class='notice'>[src] is already rigged!</span>")
			return TRUE
		if(C.use(15))
			to_chat(user, "<span class='notice'>You rig [src].</span>")
			rigged = TRUE
		else
			to_chat(user, "<span class='warning'>You need at least 15 wires to rig [src]!</span>")
		return TRUE
	if(istype(W, /obj/item/electropack))
		if(rigged)
			if(!user.drop_item())
				to_chat(user, "<span class='warning'>[W] seems to be stuck to your hand!</span>")
				return TRUE
			to_chat(user, "<span class='notice'>You attach [W] to [src].</span>")
			W.forceMove(src)
		return TRUE

/obj/structure/closet/crate/wirecutter_act(mob/living/user, obj/item/I)
	if(opened)
		return
	if(!rigged)
		return

	if(I.use_tool(src, user))
		to_chat(user, "<span class='notice'>You cut away the wiring.</span>")
		playsound(loc, I.usesound, 100, 1)
		rigged = FALSE
		return TRUE

/obj/structure/closet/crate/welder_act()
	return

/obj/structure/closet/crate/attack_hand(mob/user)
	if(manifest)
		to_chat(user, "<span class='notice'>You tear the manifest off of the crate.</span>")
		playsound(loc, 'sound/items/poster_ripped.ogg', 75, TRUE)
		manifest.forceMove(loc)
		if(ishuman(user))
			user.put_in_hands(manifest)
		manifest = null
		update_icon()
		return
	else
		if(rigged && locate(/obj/item/electropack) in src)
			if(isliving(user))
				var/mob/living/L = user
				if(L.electrocute_act(17, src))
					do_sparks(5, 1, src)
					return
		add_fingerprint(user)
		toggle(user, by_hand = TRUE)

/obj/structure/closet/crate/shove_impact(mob/living/target, mob/living/attacker)
	return FALSE

// Called when a crate is delivered by MULE at a location, for notifying purposes
/obj/structure/closet/crate/proc/notifyRecipient(destination)
	var/list/msg = list("[capitalize(name)] has arrived at [destination].")
	if(destination in announce_beacons)
		for(var/obj/machinery/requests_console/D in GLOB.allRequestConsoles)
			if(D.department in announce_beacons[destination])
				D.createMessage(name, "Your Crate has Arrived!", msg, 1)

/obj/structure/closet/crate/secure
	desc = "A secure crate."
	name = "Secure crate"
	icon_state = "securecrate"
	icon_opened = "securecrate_open"
	icon_closed = "securecrate"
	max_integrity = 500
	armor = list(MELEE = 30, BULLET = 50, LASER = 50, ENERGY = 100, BOMB = 0, RAD = 0, FIRE = 80, ACID = 80)
	damage_deflection = 25
	broken = FALSE
	locked = TRUE
	can_be_emaged = TRUE
	crate_value = 25 // rarer and cannot be crafted, bonus credits for exporting them

	var/redlight = "securecrater"
	var/greenlight = "securecrateg"
	var/emag = "securecrateemag"

	var/tamperproof = FALSE

/obj/structure/closet/crate/secure/update_overlays()
	. = ..()
	if(broken)
		. += emag
		return
	if(locked)
		. += redlight
	else
		. += greenlight

/obj/structure/closet/crate/secure/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	if(prob(tamperproof) && damage_amount >= DAMAGE_PRECISION)
		boom()
	else
		return ..()

/obj/structure/closet/crate/secure/proc/boom(mob/user)
	if(user)
		to_chat(user, "<span class='danger'>The crate's anti-tamper system activates!</span>")
		investigate_log("[key_name(user)] has detonated a [src]", INVESTIGATE_BOMB)
		add_attack_logs(user, src, "has detonated", ATKLOG_MOST)
	for(var/atom/movable/AM in src)
		qdel(AM)
	explosion(get_turf(src), 0, 1, 5, 5)
	qdel(src)

/obj/structure/closet/crate/secure/can_open()
	return !locked

/obj/structure/closet/crate/secure/proc/togglelock(mob/user)
	if(opened)
		to_chat(user, "<span class='notice'>Close the crate first.</span>")
		return
	if(broken)
		to_chat(user, "<span class='warning'>The crate appears to be broken.</span>")
		return
	if(allowed(user))
		locked = !locked
		visible_message("<span class='notice'>The crate has been [locked ? null : "un"]locked by [user].</span>")
		update_icon()
	else
		to_chat(user, "<span class='notice'>Access Denied</span>")

/obj/structure/closet/crate/secure/AltClick(mob/user)
	if(Adjacent(user) && !opened)
		verb_togglelock()
		return

	. = ..()

/obj/structure/closet/crate/secure/verb/verb_togglelock()
	set src in oview(1) // One square distance
	set category = null
	set name = "Toggle Lock"

	if(HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED) || usr.stat || usr.restrained()) // Don't use it if you're not able to! Checks for stuns, ghost and restrain
		return

	if(ishuman(usr) || isrobot(usr))
		add_fingerprint(usr)
		togglelock(usr)
		return
	to_chat(usr, "<span class='warning'>This mob type can't use this verb.</span>")

/obj/structure/closet/crate/secure/attack_hand(mob/user)
	if(manifest)
		to_chat(user, "<span class='notice'>You tear the manifest off of the crate.</span>")
		playsound(loc, 'sound/items/poster_ripped.ogg', 75, 1)
		manifest.forceMove(loc)
		if(ishuman(user))
			user.put_in_hands(manifest)
		manifest = null
		update_icon()
		return
	if(locked)
		togglelock(user)
	else
		toggle(user, by_hand = TRUE)

/obj/structure/closet/crate/secure/closed_item_click(mob/user)
	togglelock(user)

/obj/structure/closet/crate/secure/emag_act(mob/user)
	if(locked)
		locked = FALSE
		broken = TRUE
		update_icon()
		do_sparks(2, 1, src)
		to_chat(user, "<span class='notice'>You unlock \the [src].</span>")

/obj/structure/closet/crate/secure/emp_act(severity)
	for(var/obj/O in src)
		O.emp_act(severity)
	if(!broken && !opened  && prob(50/severity))
		if(!locked)
			locked = TRUE
		else
			do_sparks(2, 1, src)
			locked = FALSE
		update_icon()
	if(!opened && prob(20/severity))
		if(!locked)
			open()
		else
			req_access = list()
			req_access += pick(get_all_accesses())
	..()

/obj/structure/closet/crate/plastic
	name = "plastic crate"
	desc = "A rectangular plastic crate."
	icon_state = "plasticcrate"
	icon_opened = "plasticcrate_open"
	icon_closed = "plasticcrate"
	material_drop = /obj/item/stack/sheet/plastic
	material_drop_amount = 4
	crate_value = 3 // You can mass produce plastic crates, this is needed to prevent cargo from making tons of money too easily

/obj/structure/closet/crate/internals
	desc = "A internals crate."
	name = "internals crate"
	icon_state = "o2crate"
	icon_opened = "o2crate_open"
	icon_closed = "o2crate"

/obj/structure/closet/crate/trashcart
	desc = "A heavy, metal trashcart with wheels."
	name = "trash Cart"
	icon_state = "trashcart"
	icon_opened = "trashcart_open"
	icon_closed = "trashcart"
	pull_speed = 0

/obj/structure/closet/crate/medical
	desc = "A medical crate."
	name = "medical crate"
	icon_state = "medicalcrate"
	icon_opened = "medicalcrate_open"
	icon_closed = "medicalcrate"

/obj/structure/closet/crate/rcd
	desc = "A crate for the storage of the RCD."
	name = "\improper RCD crate"

/obj/structure/closet/crate/rcd/populate_contents()
	new /obj/item/rcd_ammo(src)
	new /obj/item/rcd_ammo(src)
	new /obj/item/rcd_ammo(src)
	new /obj/item/rcd(src)

/obj/structure/closet/crate/freezer
	desc = "A freezer."
	name = "Freezer"
	icon_state = "freezer"
	icon_opened = "freezer_open"
	icon_closed = "freezer"
	var/target_temp = T0C - 40
	var/cooling_power = 40

/obj/structure/closet/crate/freezer/return_air()
	RETURN_TYPE(/datum/gas_mixture)
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

/obj/structure/closet/crate/freezer/iv_storage
	name = "IV storage freezer"
	desc = "A freezer used to store IV bags containing various blood types."

/obj/structure/closet/crate/freezer/iv_storage/populate_contents()
	new /obj/item/reagent_containers/iv_bag/blood/OMinus(src)
	new /obj/item/reagent_containers/iv_bag/blood/OPlus(src)
	new /obj/item/reagent_containers/iv_bag/blood/AMinus(src)
	new /obj/item/reagent_containers/iv_bag/blood/APlus(src)
	new /obj/item/reagent_containers/iv_bag/blood/BMinus(src)
	new /obj/item/reagent_containers/iv_bag/blood/BPlus(src)
	new /obj/item/reagent_containers/iv_bag/blood/random(src)
	new /obj/item/reagent_containers/iv_bag/blood/random(src)
	new /obj/item/reagent_containers/iv_bag/blood/random(src)
	new /obj/item/reagent_containers/iv_bag/salglu(src)
	new /obj/item/reagent_containers/iv_bag/slime(src)
	new /obj/item/reagent_containers/iv_bag/blood/vox(src)

/obj/structure/closet/crate/can
	desc = "A large can, looks like a bin to me."
	name = "garbage can"
	icon_state = "largebin"
	icon_opened = "largebin_open"
	icon_closed = "largebin"
	anchored = TRUE
	open_sound = 'sound/effects/bin_open.ogg'
	close_sound = 'sound/effects/bin_close.ogg'

/obj/structure/closet/crate/can/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_unfasten_wrench(user, I, 40)

/obj/structure/closet/crate/radiation
	desc = "A crate with a radiation sign on it."
	name = "radioactive gear crate"
	icon_state = "radiation"
	icon_opened = "radiation_open"
	icon_closed = "radiation"

/obj/structure/closet/crate/secure/weapon
	desc = "A secure weapons crate."
	name = "weapons crate"
	icon_state = "weaponcrate"
	icon_opened = "weaponcrate_open"
	icon_closed = "weaponcrate"

/obj/structure/closet/crate/secure/plasma
	desc = "A secure plasma crate."
	name = "plasma crate"
	icon_state = "plasmacrate"
	icon_opened = "plasmacrate_open"
	icon_closed = "plasmacrate"

/obj/structure/closet/crate/secure/gear
	desc = "A secure gear crate."
	name = "gear crate"
	icon_state = "secgearcrate"
	icon_opened = "secgearcrate_open"
	icon_closed = "secgearcrate"

/obj/structure/closet/crate/secure/hydrosec
	desc = "A crate with a lock on it, painted in the scheme of the station's botanists."
	name = "secure hydroponics crate"
	icon_state = "hydrosecurecrate"
	icon_opened = "hydrosecurecrate_open"
	icon_closed = "hydrosecurecrate"

/obj/structure/closet/crate/secure/bin
	desc = "A secure bin."
	name = "secure bin"
	icon_state = "largebins"
	icon_opened = "largebins_open"
	icon_closed = "largebins"
	redlight = "largebinr"
	greenlight = "largebing"
	emag = "largebinemag"
	open_sound = 'sound/effects/bin_open.ogg'
	close_sound = 'sound/effects/bin_close.ogg'

/obj/structure/closet/crate/hydroponics
	name = "hydroponics crate"
	desc = "All you need to destroy those pesky weeds and pests."
	icon_state = "hydrocrate"
	icon_opened = "hydrocrate_open"
	icon_closed = "hydrocrate"

/obj/structure/closet/crate/hydroponics/prespawned
	//This exists so the prespawned hydro crates spawn with their contents.

// Do I need the definition above? Who knows!
/obj/structure/closet/crate/hydroponics/prespawned/populate_contents()
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
	icon_opened = "scicrate_open"
	icon_closed = "scicrate"

/obj/structure/closet/crate/secure/scisec
	name = "secure science crate"
	desc = "A crate with a lock on it, painted in the scheme of the station's scientists."
	icon_state = "scisecurecrate"
	icon_opened = "scisecurecrate_open"
	icon_closed = "scisecurecrate"

/obj/structure/closet/crate/engineering
	name = "engineering crate"
	desc = "An engineering crate."
	icon_state = "engicrate"
	icon_opened = "engicrate_open"
	icon_closed = "engicrate"

/obj/structure/closet/crate/secure/engineering
	name = "secure engineering crate"
	desc = "A crate with a lock on it, painted in the scheme of the station's engineers."
	icon_state = "engisecurecrate"
	icon_opened = "engisecurecrate_open"
	icon_closed = "engisecurecrate"

/obj/structure/closet/crate/engineering/electrical
	name = "electrical engineering crate"
	desc = "An electrical engineering crate."
	icon_state = "electricalcrate"
	icon_opened = "electricalcrate_open"
	icon_closed = "electricalcrate"

/obj/structure/closet/crate/tape/populate_contents()
	if(prob(10))
		new /obj/item/bikehorn/rubberducky(src)

//crates of gear in the free golem ship
/obj/structure/closet/crate/golemgear/populate_contents()
	new /obj/item/storage/backpack/industrial(src)
	new /obj/item/shovel(src)
	new /obj/item/pickaxe(src)
	new /obj/item/t_scanner/adv_mining_scanner/lesser(src)
	new /obj/item/storage/bag/ore(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/card/id/golem(src)
	new /obj/item/flashlight/lantern(src)
