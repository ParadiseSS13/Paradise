/obj/item/chemical_flamethrower
	name = "chemical flamethrower"
	desc = "I love the smell of napalm in the morning."
	icon = 'icons/obj/flamethrower.dmi'
	icon_state = "flamethrower1"
	item_state = "flamethrower_0"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	flags = CONDUCT
	force = 5
	throwforce = 10
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL = 5000)
	resistance_flags = FIRE_PROOF
	origin_tech = "combat=1;plasmatech=2;engineering=2"

	/// How many canisters fit in our flamethrower?
	var/canister_max = 1
	/// The first loaded canister
	var/obj/item/chemical_canister/canister
	/// The second loaded canister. Should only be filled if `canister_max` is 2
	var/obj/item/chemical_canister/canister_2

	/// The burn temperature of our currently stored chemical in the canister
	var/canister_burn_temp = T0C + 300
	/// The burn duration of our currently stored chemical in the canister
	var/canister_burn_duration = 10 SECONDS
	/// How many firestacks will our reagent apply
	var/canister_fire_applications = 1

/obj/item/chemical_flamethrower/Initialize(mapload)
	. = ..()
	canister = new()
	get_canister_stats()

/obj/item/chemical_flamethrower/attack_self(mob/user)
	. = ..()
	if(canister)
		unequip_canisters(user)

/obj/item/chemical_flamethrower/proc/unequip_canisters(mob/user)
	if(canister_2)
		canister_2.forceMove(get_turf(src))
		user.put_in_hands(canister_2)
		canister_2 = null
		return

	if(canister)
		canister.forceMove(get_turf(src))
		user.put_in_hands(canister)
		canister = null

/obj/item/chemical_flamethrower/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!istype(I, /obj/item/chemical_canister))
		to_chat(user, "<span class='notice'>You can't fit [I] in there!</span>")
		return
	if(canister_2 || (canister_max == 1 && canister))
		to_chat(user, "<span class='notice'>[src] is already full!</span>")
		return

	if(canister_max == 2)
		canister_2 = I
	else
		canister = I
	user.unEquip(I)
	I.forceMove(src)

	get_canister_stats()

/obj/item/chemical_flamethrower/proc/get_canister_stats()
	if(!canister)
		canister_burn_temp = null
		canister_burn_duration = null
		canister_fire_applications = null
		return

	var/dual_canisters = (canister && canister_2) ? TRUE : FALSE
	if(dual_canisters)
		canister_burn_temp = round((canister.chem_burn_temp + canister_2.chem_burn_temp) / 2, 1)
		canister_burn_duration = round((canister.chem_burn_duration + canister_2.chem_burn_duration) / 2, 1)
		canister_fire_applications = round((canister.fire_applications + canister_2.fire_applications) / 2, 1)
	else
		canister_burn_temp = canister.chem_burn_temp
		canister_burn_duration = canister.chem_burn_duration
		canister_fire_applications = canister.fire_applications

/obj/item/chemical_flamethrower/afterattack(atom/target, mob/user, flag)
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
			var/turflist = get_line(user, target_turf)
			add_attack_logs(user, target, "Flamethrowered at [target.x],[target.y],[target.z]")
			INVOKE_ASYNC(src, PROC_REF(flame_turf), turflist, user)

/obj/item/chemical_flamethrower/proc/flame_turf(list/turflist = list(), mob/user)
	if(!length(turflist))
		return

	var/turf/previousturf = get_turf(src)
	for(var/turf/simulated/T in turflist)
		if(!use_ammo(1))
			to_chat(user, "<span class='warning'>You hear a click!</span>")
			playsound(user, 'sound/weapons/empty.ogg', 100, 1)
			break // Whoops! No ammo!

		if(T == previousturf)
			continue	// So we don't burn the tile we be standin on

		var/found_obstruction = FALSE
		for(var/obj/thing in T)
			if(thing.density && !istype(thing, /obj/structure/table))
				found_obstruction = TRUE
				break
		if(found_obstruction)
			break

		make_flame(T)
		sleep(1)
		previousturf = T

/obj/item/chemical_flamethrower/proc/make_flame(turf/spawn_turf)
	new /obj/effect/fire(spawn_turf, canister_burn_temp, (canister_burn_duration + rand(1, 3) SECONDS), canister_fire_applications) // For that spicy randomness (and to save your ears from all fires extinguishing at the same time)

/*
  * Uses `amount` ammo from the flamethrower.
  * Returns `TRUE` if ammo could be consumed, returns `FALSE` if it failed somehow
  */
/obj/item/chemical_flamethrower/proc/use_ammo(amount)
	var/dual_canisters = (canister && canister_2) ? TRUE : FALSE
	var/total_ammo = canister.ammo
	if(dual_canisters)
		total_ammo += canister_2.ammo
	if((total_ammo - amount) <= 0)
		return FALSE

	var/difference
	if(dual_canisters && canister_2.ammo)
		difference = canister_2.ammo - amount
		if(difference >= 0)
			canister_2.ammo -= amount
			return TRUE
		else
			difference -= canister_2.ammo
			canister_2.ammo = 0

		if(difference < canister.ammo)
			canister.ammo -= difference
		else
			return FALSE

	difference = canister.ammo - amount
	if(difference >= 0)
		canister.ammo -= amount
		return TRUE
	return FALSE

/obj/item/chemical_flamethrower/extended
	name = "Extended capacity chemical flamethrower"
	desc = "A flamethrower that accepts two chemical cartridges to create lasting fires."
	canister_max = 2

/obj/item/chemical_canister
	name = "Chemical canister"
	desc = "A simple canister of fuel. Does not accept any pyrotechnics except for welding fuel."
	icon = 'icons/obj/tank.dmi'
	icon_state = "oxygen"
	container_type = OPENCONTAINER
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

/obj/item/chemical_canister/Initialize(mapload)
	. = ..()
	create_reagents(50)

/obj/item/chemical_canister/on_reagent_change()
	if(!reagents.get_master_reagent_id() || !(reagents.get_master_reagent_id() in accepted_chemicals))
		reagents.clear_reagents()
		visible_message("<span class='notice'>[src] doesn't accept the most present chemical!</span>")
		return

	current_reagent_id = reagents.get_master_reagent_id()
	reagents.isolate_reagent(current_reagent_id)
	var/has_enough_reagents = reagents.total_volume >= required_volume ? TRUE : FALSE
	visible_message("<span class='notice'>[src] removes all reagents except for [current_reagent_id]. \
					The reservoir has [reagents.total_volume] out of [required_volume] units. \
					Reagent effects are [has_enough_reagents ? "in effect" : "not active"].</span>")

	if(has_enough_reagents)
		var/datum/reagent/reagent_to_burn = reagents.reagent_list[1]
		chem_burn_duration = reagent_to_burn.burn_duration
		chem_burn_temp = reagent_to_burn.burn_temperature
		fire_applications = reagent_to_burn.fire_stack_applications

/obj/item/chemical_canister/extended
	name = "Extended capacity chemical canister"
	desc = "An extended version of the original design. Does not accept any pyrotechnics except for welding fuel."
	ammo = 200
	required_volume = 20 // Bigger canister? More reagents needed.

/obj/item/chemical_canister/pyrotechnics
	name = "Extended capacity chemical canister"
	desc = "A specialized canister designed to accept certain pyrotechnics."
	ammo = 150
	accepted_chemicals = list("phlogiston_dust", "napalm", "fuel", "thermite", "clf3", "plasma")

GLOBAL_LIST_EMPTY(flame_effects)
#define MAX_FIRE_EXIST_TIME 10 MINUTES // That's a lot of fuel, but you are not gonna make it last for longer

/obj/effect/fire
	name = "Fire"
	desc = "You don't think you should touch this."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "match_unathi"

	/// How hot is our fire?
	var/temperature
	/// How long will our fire last
	var/duration = 10 SECONDS
	/// How many firestacks does the fire give to mobs
	var/application_stacks = 1

/obj/effect/fire/Initialize(mapload, reagent_temperature, reagent_duration, fire_applications)
	. = ..()

	if(!reagent_duration || !reagent_temperature) // There is no reason for this thing to exist
		qdel(src)
		return

	duration = reagent_duration
	temperature = reagent_temperature
	application_stacks = max(application_stacks, fire_applications)

	for(var/obj/effect/fire/flame as anything in GLOB.flame_effects)
		if(flame == src)
			continue
		if(get_dist(src, flame) < 1) // It's on the same turf
			merge_flames(flame)

	for(var/atom/thing_to_burn in get_turf(src))
		if(isliving(thing_to_burn))
			var/mob/living/mob_to_burn = thing_to_burn
			mob_to_burn.adjustFireLoss(temperature / 100)
			mob_to_burn.adjust_fire_stacks(application_stacks)
			mob_to_burn.IgniteMob()
			continue

		if(isobj(thing_to_burn))
			var/obj/obj_to_burn = thing_to_burn
			obj_to_burn.fire_act(null, temperature)
			continue

	GLOB.flame_effects += src
	START_PROCESSING(SSprocessing, src)

/obj/effect/fire/Destroy()
	. = ..()
	GLOB.flame_effects -= src
	STOP_PROCESSING(SSprocessing, src)

/obj/effect/fire/process()
	if(duration <= 0)
		fizzle()
		return

	duration -= 1 SECONDS

/obj/effect/fire/water_act(volume, temperature, source, method)
	. = ..()
	duration -= 10 SECONDS
	if(duration <= 0)
		fizzle()

/obj/effect/fire/Crossed(atom/movable/AM, oldloc)
	. = ..()
	if(isliving(AM)) // TODO: add checks to see if they're protected here first
		var/mob/living/mob_to_burn = AM
		mob_to_burn.adjustFireLoss(temperature / 100)
		mob_to_burn.adjust_fire_stacks(application_stacks)
		mob_to_burn.IgniteMob()
		to_chat(mob_to_burn, "<span class='warning'>[src] burns you!</span>")
		return

	if(isitem(AM))
		var/obj/item/item_to_burn = AM
		item_to_burn.fire_act(null, temperature)
		return

/obj/effect/fire/proc/fizzle()
	playsound(src, 'sound/effects/fire_sizzle.ogg', 50, TRUE)
	qdel(src)

/obj/effect/fire/proc/merge_flames(obj/effect/fire/merging_flame)
	duration = min((duration + (merging_flame.duration / 2)), MAX_FIRE_EXIST_TIME)
	temperature += (merging_flame.temperature) / 10 // No making a sun by just clicking 10 times on a turf
	merging_flame.fizzle()

#undef MAX_FIRE_EXIST_TIME
