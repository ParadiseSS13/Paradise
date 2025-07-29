/obj/item/chemical_flamethrower
	name = "chemical flamethrower"
	desc = "I love the smell of napalm in the morning."
	icon = 'icons/obj/chemical_flamethrower.dmi'
	icon_state = "chem_flame"
	lefthand_file = 'icons/mob/inhands/flamethrower_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/flamethrower_righthand.dmi'
	flags = CONDUCT
	force = 5
	throwforce = 10
	throw_speed = 1
	throw_range = 5
	slot_flags = ITEM_SLOT_BACK
	materials = list(MAT_METAL = 5000)
	resistance_flags = FIRE_PROOF
	origin_tech = "combat=1;plasmatech=2;engineering=2"

	/// How many canisters fit in our flamethrower?
	var/max_canisters = 1
	/// All our loaded canisters in a list
	var/list/canisters = list()
	/// Is this a type of flamethrower that starts loaded?
	var/should_start_with_canisters = FALSE

	/// The burn temperature of our currently stored chemical in the canister
	var/canister_burn_temp = T0C + 300
	/// The burn duration of our currently stored chemical in the canister
	var/canister_burn_duration = 10 SECONDS
	/// How many firestacks will our reagent apply
	var/canister_fire_applications = 1
	/// Does our chemical have any special color?
	var/canister_fire_color
	/// How much ammo do we use per tile?
	var/ammo_usage = 1
	/// Is this a syndicate flamethrower
	var/syndicate = FALSE

/obj/item/chemical_flamethrower/Initialize(mapload)
	. = ..()
	if(should_start_with_canisters && !length(canisters))
		canisters += new /obj/item/chemical_canister
	update_canister_stats()
	update_icon(UPDATE_ICON_STATE)

/obj/item/chemical_flamethrower/Destroy()
	QDEL_LIST_CONTENTS(canisters)
	return ..()

/obj/item/chemical_flamethrower/update_icon_state()
	icon_state = "chem_flame[max_canisters == 2 ? "_2" : ""][syndicate ? "_s" : ""]"

/obj/item/chemical_flamethrower/update_overlays()
	. = ..()
	var/iterator = 1
	for(var/obj/item/chemical_canister as anything in canisters)
		. += mutable_appearance('icons/obj/chemical_flamethrower.dmi', "[chemical_canister.icon_state]_[iterator]")
		iterator++

/obj/item/chemical_flamethrower/attack_self__legacy__attackchain(mob/user)
	. = ..()
	if(length(canisters))
		unequip_canisters(user)

/obj/item/chemical_flamethrower/proc/unequip_canisters(mob/user)
	if(!length(canisters))
		return

	var/obj/item/chemical_canister/canister_to_remove = canisters[length(canisters)]
	canister_to_remove.forceMove(get_turf(src))
	user.put_in_hands(canister_to_remove)
	canisters -= canister_to_remove
	update_icon(UPDATE_OVERLAYS)

/obj/item/chemical_flamethrower/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	. = ..()
	if(!istype(I, /obj/item/chemical_canister))
		to_chat(user, "<span class='notice'>You can't fit [I] in there!</span>")
		return
	if(length(canisters) >= max_canisters)
		to_chat(user, "<span class='notice'>[src] is already full!</span>")
		return

	if(user.transfer_item_to(I, src))
		canisters += I
		to_chat(user, "<span class='notice'>You put [I] into [src].</span>")
		update_canister_stats()

/obj/item/chemical_flamethrower/proc/update_canister_stats()
	if(!length(canisters))
		canister_burn_temp = null
		canister_burn_duration = null
		canister_fire_applications = null
		canister_fire_color = null
		return

	var/burn_temp
	var/burn_duration
	var/fire_applications
	var/how_many_canisters = length(canisters)
	var/list/colors = list()

	for(var/obj/item/chemical_canister/canister as anything in canisters)
		if(!canister.ammo)
			continue
		burn_temp += canister.chem_burn_temp
		burn_duration += canister.chem_burn_duration
		fire_applications += canister.fire_applications
		colors += canister.chem_color

	canister_burn_temp = round(burn_temp / how_many_canisters, 1)
	canister_burn_duration = round(burn_duration / how_many_canisters, 1)
	canister_fire_applications = round(fire_applications / how_many_canisters, 1)
	if(length(colors))
		canister_fire_color = pick(colors)
	update_icon(UPDATE_OVERLAYS)

/obj/item/chemical_flamethrower/afterattack__legacy__attackchain(atom/target, mob/user, flag)
	. = ..()
	if(flag || !user)
		return

	if(user.mind?.martial_art?.no_guns)
		to_chat(user, "<span class='warning'>[user.mind.martial_art.no_guns_message]</span>")
		return

	if(HAS_TRAIT(user, TRAIT_CHUNKYFINGERS))
		to_chat(user, "<span class='warning'>Your meaty finger is far too large for the trigger guard!</span>")
		return

	if(user.get_active_hand() == src) // Make sure our user is still holding us
		var/turf/target_turf = get_turf(target)
		if(target_turf)
			var/turf_list = get_line(user, target_turf)
			add_attack_logs(user, target, "Chemical Flamethrowered at [target.x], [target.y], [target.z]")
			INVOKE_ASYNC(src, PROC_REF(flame_turf), turf_list, user)

/obj/item/chemical_flamethrower/proc/flame_turf(list/turflist = list(), mob/user)
	if(!length(turflist))
		return

	var/turf/previousturf = get_turf(src)
	for(var/turf/simulated/T in turflist)
		if(iswallturf(T)) // No going through walls
			break
		if(!use_ammo(ammo_usage))
			to_chat(user, "<span class='warning'>You hear a click!</span>")
			playsound(user, 'sound/weapons/empty.ogg', 100, TRUE)
			break // Whoops! No ammo!

		if(T == previousturf)
			continue // So we don't burn the tile we be standin on

		var/found_obstruction = FALSE
		for(var/obj/thing in T)
			if(thing.density && !istype(thing, /obj/structure/table))
				found_obstruction = TRUE
				break
		if(found_obstruction)
			break

		make_flame(T)
		update_canister_stats() // In case we ran out of some fuel this fire
		sleep(1)
		previousturf = T

/obj/item/chemical_flamethrower/proc/make_flame(turf/spawn_turf)
	// For that spicy randomness (and to save your ears from all fires extinguishing at the same time)
	new /obj/effect/fire(spawn_turf, canister_burn_temp, (canister_burn_duration + rand(1, 3) SECONDS), canister_fire_applications, canister_fire_color)

/*
  * Uses `amount` ammo from the flamethrower.
  * Returns `TRUE` if ammo could be consumed, returns `FALSE` if it failed somehow
  * It will use up ammo if it failed.
  */
/obj/item/chemical_flamethrower/proc/use_ammo(amount)
	var/total_ammo
	for(var/obj/item/chemical_canister/canister as anything in canisters)
		total_ammo += canister.ammo
	if(total_ammo - amount < 0)
		return FALSE

	var/length = length(canisters)
	var/difference = amount
	for(var/i in 0 to length)
		var/obj/item/chemical_canister/canister = canisters[length - i]
		if(canister.ammo - difference <= 0)
			difference -= canister.ammo
			canister.ammo = 0
			canister.has_filled_reagent = FALSE // We're empty now!
		else
			canister.ammo -= difference
			difference = 0

		if(!difference)
			break

	return !difference

/obj/item/chemical_flamethrower/extended
	name = "extended capacity chemical flamethrower"
	desc = "A flamethrower that accepts two chemical canisters to create lasting fires."
	max_canisters = 2

/obj/item/chemical_flamethrower/extended/nuclear
	name = "\improper Syndicate extended capacity chemical flamethrower"
	desc = "A flamethrower that accepts two chemical canisters to create lasting fires. As black as the ash of your enemies."
	syndicate = TRUE

/obj/item/chemical_flamethrower/extended/nuclear/Initialize(mapload)
	. = ..()
	for(var/i in 1 to max_canisters)
		canisters += new /obj/item/chemical_canister/extended/nuclear
	update_canister_stats()

/obj/item/chemical_canister
	name = "chemical canister"
	desc = "A simple canister of fuel. Does not accept any pyrotechnics except for welding fuel."
	icon = 'icons/obj/chemical_flamethrower.dmi'
	icon_state = "normal"
	container_type = REFILLABLE
	/// How much ammo do we have? Empty at 0.
	var/ammo = 100
	/// Which reagent IDs do we accept
	var/list/accepted_chemicals = list("fuel")
	/// The burn temperature of our currently stored chemical
	var/chem_burn_temp = T0C + 300
	/// The burn duration of our currently stored chemical
	var/chem_burn_duration = 10 SECONDS
	/// How many firestacks will our reagent apply
	var/fire_applications = 1
	/// The currently stored reagent ID
	var/current_reagent_id
	/// How many units of the reagent do we need to have it's effects kick in?
	var/required_volume = 10
	/// Do we have a locked in reagent type?
	var/has_filled_reagent = FALSE
	/// Are we silent on the first change of reagents?
	var/first_time_silent = FALSE // The reason for this is so we can have canisters that spawn with reagents but don't announce it on `Initialize()`
	/// What chemical do we have? This will be the chemical ID, so a string
	var/stored_chemical
	/// What color will our fire burn
	var/chem_color

/obj/item/chemical_canister/Initialize(mapload)
	. = ..()
	create_reagents(50)

/obj/item/chemical_canister/examine(mob/user)
	. = ..()
	. += "[src] has [ammo] out of [initial(ammo)] units left!"
	if(stored_chemical && ammo != 0)
		. += "[src] is currently filled with [stored_chemical]"

/obj/item/chemical_canister/on_reagent_change()
	if(!length(reagents.reagent_list))
		// Nothing to check. Has to be here because we call `clear_reagents` at the end of this proc.
		return

	if(has_filled_reagent && ammo != 0)
		audible_message("<span class='notice'>[src]'s speaker beeps: no new chemicals are accepted!</span>")
		return

	if(!reagents.get_master_reagent_id() || !(reagents.get_master_reagent_id() in accepted_chemicals))
		reagents.clear_reagents()
		audible_message("<span class='notice'>[src]'s speaker beeps: the most present chemical isn't accepted!</span>")
		return

	current_reagent_id = reagents.get_master_reagent_id()
	stored_chemical = current_reagent_id
	reagents.isolate_reagent(current_reagent_id)
	var/has_enough_reagents = reagents.total_volume >= required_volume

	if(!first_time_silent)
		audible_message("<span class='notice'>[src]'s speaker beeps: \
						The reservoir has [reagents.total_volume] out of [required_volume] units. \
						Reagents are [has_enough_reagents ? "in effect" : "not active"].</span>")
	first_time_silent = FALSE

	if(has_enough_reagents)
		var/datum/reagent/reagent_to_burn = reagents.reagent_list[1]
		chem_burn_duration = reagent_to_burn.burn_duration
		chem_burn_temp = reagent_to_burn.burn_temperature
		fire_applications = reagent_to_burn.fire_stack_applications
		if(reagent_to_burn.burn_color)
			chem_color = reagent_to_burn.burn_color
		ammo = initial(ammo)
		has_filled_reagent = TRUE
		reagents.clear_reagents()

/obj/item/chemical_canister/extended
	name = "extended capacity chemical canister"
	desc = "An extended version of the original design. Does not accept any pyrotechnics except for welding fuel."
	icon_state = "extended"
	ammo = 200
	required_volume = 20 // Bigger canister? More reagents needed.

/obj/item/chemical_canister/extended/nuclear
	name = "\improper Syndicate chemical canister"
	desc = "A canister pre-filled with napalm to bring a fiery death to capitalism."
	icon_state = "pyro"
	accepted_chemicals = list("napalm")
	first_time_silent = TRUE

/obj/item/chemical_canister/extended/nuclear/Initialize(mapload)
	..()
	reagents.add_reagent("napalm", 30) // Overload it with napalm!

/obj/item/chemical_canister/pyrotechnics
	name = "extended capacity chemical canister"
	desc = "A specialized canister designed to accept certain pyrotechnics."
	icon_state = "pyro"
	ammo = 150
	accepted_chemicals = list("phlogiston", "phlogiston_dust", "napalm", "fuel", "thermite", "clf3", "plasma")
