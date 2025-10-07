/obj/item/grenade/plastic/miningcharge
	name = "industrial mining charge"
	desc = "Used to make big holes in rocks. Only works on rocks!"
	icon = 'icons/obj/mining.dmi'
	icon_state = "mining-charge-2"
	inhand_icon_state = "charge_indust"
	det_time = 5
	origin_tech = "materials=1"
	notify_admins = FALSE // no need to make adminlogs on lavaland, while they are "safe" to use
	/// When TRUE, charges won't detonate on it's own. Used for mining detonator
	var/timer_off = FALSE
	var/installed = FALSE
	var/smoke_amount = 3
	/// list of sizes for explosion. Third number is used for actual rock explosion size, second number is radius for Weaken() effects, first is used for hacked charges
	var/boom_sizes = list(2, 3, 5)
	var/hacked = FALSE

/obj/item/grenade/plastic/miningcharge/Initialize(mapload)
	. = ..()
	image_overlay = mutable_appearance(icon, "[icon_state]_active", ON_EDGED_TURF_LAYER)

/obj/item/grenade/plastic/miningcharge/examine(mob/user)
	. = ..()
	if(hacked)
		. += "<span class='warning'>Its wiring is haphazardly changed.</span>"
	if(timer_off)
		. += "<span class='notice'>The mining charge is connected to a detonator.</span>"

/obj/item/grenade/plastic/miningcharge/attack_self__legacy__attackchain(mob/user)
	if(nadeassembly)
		nadeassembly.attack_self__legacy__attackchain(user)

/obj/item/grenade/plastic/miningcharge/afterattack__legacy__attackchain(atom/movable/AM, mob/user, flag)
	if(!ismineralturf(AM) && !hacked)
		return
	if(is_ancient_rock(AM) && !hacked)
		to_chat(user, "<span class='notice'>This rock appears to be resistant to all mining tools except pickaxes!</span>")
		return
	if(!timer_off) //override original proc for plastic explosions
		return ..()
	if(!flag)
		return
	if(iscarbon(AM))
		return
	to_chat(user, "<span class='notice'>You start planting [src].</span>")
	if(!do_after(user, (2.5 SECONDS) * toolspeed, target = AM))
		return
	if(!user.unequip(src))
		return
	target = AM
	forceMove(AM)
	if(hacked)
		message_admins("[ADMIN_LOOKUPFLW(user)] planted [name] on [target.name] at [ADMIN_COORDJMP(target)]")
		log_game("planted [name] on [target.name] at [COORD(target)]", user)
	installed = TRUE
	target.overlays += image_overlay

/obj/item/grenade/plastic/miningcharge/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/detonator))
		return
	var/obj/item/detonator/detonator = I
	if((src in detonator.bombs) || timer_off)
		to_chat(user, "<span class='warning'>[src] was already synchronized to a existing detonator!</span>")
		return
	detonator.bombs += src
	timer_off = TRUE
	to_chat(user, "<span class='notice'>You synchronize [src] to [I].</span>")
	playsound(src, 'sound/machines/twobeep.ogg', 50)
	detonator.update_icon()

/obj/item/grenade/plastic/miningcharge/proc/detonate()
	addtimer(CALLBACK(src, PROC_REF(prime)), 3 SECONDS)

/obj/item/grenade/plastic/miningcharge/prime()
	if(hacked) //try not to blow your fingers off
		explode()
		return
	var/turf/simulated/mineral/location = get_turf(target)
	var/datum/effect_system/smoke_spread/S = new
	S.set_up(smoke_amount, 0, location, null)
	S.start()
	for(var/turf/simulated/mineral/rock in circlerangeturfs(location, boom_sizes[3]))
		var/distance = get_dist_euclidian(location, rock)
		if(distance <= boom_sizes[3])
			if(rock.ore)
				rock.ore.drop_max += 3 // if rock is going to get drilled, add bonus mineral amount
				rock.ore.drop_min += 3
			rock.gets_drilled(triggered_by_explosion = TRUE)
	for(var/mob/living/carbon/C in circlerange(location, boom_sizes[3]))
		var/distance = get_dist_euclidian(location, C)
		C.flash_eyes()
		C.Weaken((boom_sizes[2] - distance) * 1 SECONDS) //1 second for how close you are to center if you're in range
		C.AdjustDeaf((boom_sizes[3] - distance) * 5 SECONDS) //guaranteed deafness
		var/obj/item/organ/internal/ears/ears = C.get_int_organ(/obj/item/organ/internal/ears)
		if(istype(ears) && C.check_ear_prot() < HEARING_PROTECTION_MINOR) //headsets should be enough to avoid taking damage
			ears.receive_damage((boom_sizes[3] - distance) * 2) //something like that i guess. Mega charge makes 12 damage to ears if nearby
		to_chat(C, "<span class='userdanger'>You are knocked down by the power of the mining charge!</span>")
	qdel(src)

/obj/item/grenade/plastic/miningcharge/proc/explode()
	var/turf/location
	if(target)
		if(!QDELETED(target))
			if(isturf(target))
				location = get_turf(target)
			else
				location = get_atom_on_turf(target)
			target.overlays -= image_overlay
	else
		location = get_atom_on_turf(src)
	if(location)
		explosion(location, boom_sizes[1], boom_sizes[2], boom_sizes[3], cause = name)
		location.ex_act(EXPLODE_HEAVY, target)
	qdel(src)

/obj/item/grenade/plastic/miningcharge/proc/override_safety()
	hacked = TRUE
	notify_admins = TRUE
	boom_sizes[1] = round(boom_sizes[1] / 3)	//lesser - 0, normal - 0, mega - 1; c4 - 0
	boom_sizes[2] = round(boom_sizes[2] / 3)	//lesser - 0, normal - 1, mega - 2; c4 - 0
	boom_sizes[3] = round(boom_sizes[3] / 1.5)	//lesser - 2, normal - 3, mega - 5; c4 - 3

/// Overriding to avoid the chargers from exploding because of received damage
/obj/item/grenade/plastic/miningcharge/deconstruct(disassembled = TRUE)
	if(!QDELETED(src))
		qdel(src)

/obj/item/grenade/plastic/miningcharge/lesser
	name = "mining charge"
	desc = "A mining charge. This one seems less powerful than industrial. Only works on rocks!"
	icon_state = "mining-charge-1"
	inhand_icon_state = "charge_lesser"
	smoke_amount = 1
	boom_sizes = list(1, 2, 3)

/obj/item/grenade/plastic/miningcharge/mega
	name = "experimental mining charge"
	desc = "A mining charge. This one seems much more powerful than normal!"
	icon_state = "mining-charge-3"
	inhand_icon_state = "charge_mega"
	smoke_amount = 5
	boom_sizes = list(4, 6, 8)

/obj/item/storage/backpack/duffel/miningcharges/populate_contents()
	for(var/i in 1 to 5)
		new /obj/item/grenade/plastic/miningcharge/lesser(src)
	for(var/i in 1 to 3)
		new /obj/item/grenade/plastic/miningcharge(src)
	new /obj/item/detonator(src)

//MINING CHARGE HACKER

/obj/item/t_scanner/adv_mining_scanner/syndicate
	var/charges = 6

/obj/item/t_scanner/adv_mining_scanner/syndicate/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This scanner has an extra port for overriding mining charge safeties.</span>"

/obj/item/t_scanner/adv_mining_scanner/syndicate/afterattack__legacy__attackchain(atom/target, mob/user, proximity_flag, click_parameters)
	if(!istype(target, /obj/item/grenade/plastic/miningcharge))
		return
	var/obj/item/grenade/plastic/miningcharge/charge = target
	if(charge.hacked)
		to_chat(user, "<span class='notice'>[src] is already overridden!</span>")
		return
	if(charges <= 0)
		to_chat(user, "<span class='notice'>Its overriding function is depleted.</span>")
		return
	charge.override_safety()
	visible_message("<span class='warning'>Sparks fly out of [src]!</span>")
	playsound(src, "sparks", 50, TRUE)
	charges--
	if(charges <= 0)
		to_chat(user, "<span class='warning'>[src]'s internal battery for overriding mining charges has run dry!</span>")

// MINING CHARGES DETONATOR

/obj/item/detonator
	name = "mining charge detonator"
	desc = "A specialized mining device designed for controlled demolition operations using mining explosives."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/mining.dmi'
	icon_state = "Detonator-0"

	/// list of all bombs connected to a detonator for a moment
	var/list/bombs = list()

/obj/item/detonator/examine(mob/user)
	. = ..()
	if(length(bombs))
		. += "<span class='notice'>List of synched bombs:</span>"
		for(var/obj/item/grenade/plastic/miningcharge/charge in bombs)
			. += "<span class='notice'>[bicon(charge)] [charge]. Current status: [charge.installed ? "ready to detonate" : "ready to deploy"].</span>"

/obj/item/detonator/update_icon()
	. = ..()
	if(length(bombs))
		icon_state = "Detonator-1"
	else
		icon_state = initial(icon_state)

/obj/item/detonator/attack_self__legacy__attackchain(mob/user)
	playsound(src, 'sound/items/detonator.ogg', 40)
	if(length(bombs))
		to_chat(user, "<span class='notice'>Activating explosives...</span>")
		for(var/obj/item/grenade/plastic/miningcharge/charge in bombs)
			if(QDELETED(charge))
				bombs -= charge
				update_icon() //if the last bomb was qdeleted, detonator icon should change after activating
				continue
			if(charge.installed)
				bombs -= charge
				charge.detonate()
				update_icon()
	else
		to_chat(user, "<span class='warning'>There are no charges linked to a detonator!</span>")
	return ..()
