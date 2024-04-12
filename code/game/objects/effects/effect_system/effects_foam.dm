// Foam
// Similar to smoke, but spreads out more
// metal foams leave behind a foamed metal wall

#define FOAM_REACT_NEVER			(2<<0)
#define FOAM_REACT_AFTER_SPREAD 	(2<<1)
#define FOAM_REACT_DURING_SPREAD	(2<<2)
#define FOAM_REACT_BEFORE_SPREAD	(2<<3)

/obj/effect/particle_effect/foam
	name = "foam"
	icon_state = "foam"
	opacity = FALSE
	density = FALSE
	gender = PLURAL
	layer = OBJ_LAYER + 0.9
	animate_movement = 0
	/// Whether or not we spread other reagents from ourselves on init
	/// How many times this one bit of foam can spread around itself
	var/spread_amount = 3
	/// How long it takes this to initially start spreading after being dispersed
	var/spread_time = 0.9 SECONDS
	/// How long it takes this, once it's spread, to stop spreading and disperse its chems
	var/solidify_time = 1.2 SECONDS
	/// Whether it reacts on or after dispersion (or both)
	var/react_mode = FOAM_REACT_BEFORE_SPREAD
	/// Maximum amount of reagents gained by spreading onto a foamed tile
	var/max_amount_on_spread = 27  // arbitrary

// /obj/effect/particle_effect/foam/proc/spread_time



/obj/effect/particle_effect/foam/Initialize(mapload, loc, ismetal = FALSE)
	. = ..()
	playsound(src, 'sound/effects/bubbles2.ogg', 80, TRUE, -3)
	addtimer(CALLBACK(src, PROC_REF(initial_process), spread_time))

/obj/effect/particle_effect/foam/proc/disperse_reagents()
	if(!reagents)
		return
	reagents.handle_reactions()
	for(var/atom/A in oview(1, src))
		if(A == src)
			continue
		if(reagents.total_volume)
			var/fraction = 5 / reagents.total_volume
			reagents.reaction(A, REAGENT_TOUCH, fraction)

/obj/effect/particle_effect/foam/proc/initial_process()
	process()
	flick("[icon_state]-disolve", src)
	addtimer(CALLBACK(src, PROC_REF(disperse), solidify_time))


/obj/effect/particle_effect/foam/proc/disperse()
	STOP_PROCESSING(SSobj, src)
	sleep(3 SECONDS)  // i'll get you
	if(react_mode & FOAM_REACT_AFTER_SPREAD)
		addtimer(CALLBACK(src, PROC_REF(disperse_reagents)), 0.3 SECONDS)
	flick("[icon_state]-disolve", src)
	QDEL_IN(src, 1 SECONDS)

// on delete, transfer any reagents to the floor
/obj/effect/particle_effect/foam/Destroy()
	return ..()

/obj/effect/particle_effect/foam/proc/generate_color()
	color = mix_color_from_reagents(reagents.reagent_list)

/obj/effect/particle_effect/foam/process()
	var/obj/effect/particle_effect/foam/new_foam

	if(--spread_amount < 0)
		return

	for(var/direction in GLOB.cardinal)
		var/turf/T = get_step(src, direction)
		if(!T)
			continue

		if(!T.Enter(src))
			continue

		new_foam = locate() in T
		if(new_foam)
			new_foam.spread_amount = min(spread_amount + new_foam.spread_amount, max_amount_on_spread)
			new_foam.disperse_reagents()
			continue

		// just so it's clear
		new_foam = new type(T)
		new_foam.spread_amount = spread_amount
		new_foam.create_reagents(25)
		if(reagents)
			for(var/datum/reagent/R in reagents.reagent_list)
				new_foam.reagents.add_reagent(R.id, min(R.volume, 5), R.data, reagents.chem_temp)
			new_foam.color = mix_color_from_reagents(reagents.reagent_list)
		if(react_mode & FOAM_REACT_BEFORE_SPREAD)
			new_foam.disperse_reagents()

	if(react_mode & FOAM_REACT_DURING_SPREAD)
		disperse_reagents()



// foam disolves when heated
// except metal foams
/obj/effect/particle_effect/foam/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE) //Don't heat the reagents inside
	return

/obj/effect/particle_effect/foam/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume) // overriden to prevent weird behaviors with heating reagents inside
	if(prob(max(0, exposed_temperature - 475)))
		flick("[icon_state]-disolve", src)
		QDEL_IN(src, 0.5 SECONDS)

/obj/effect/particle_effect/foam/Crossed(atom/movable/AM, oldloc)
	if(iscarbon(AM))
		var/mob/living/carbon/M =	AM
		if(M.slip("foam", 10 SECONDS))
			if(reagents)
				for(var/reagent_id in reagents.reagent_list)
					var/amount = M.reagents.get_reagent_amount(reagent_id)
					if(amount < 25)
						M.reagents.add_reagent(reagent_id, min(round(amount / 2), 15))
				if(reagents.total_volume)
					var/fraction = 5 / reagents.total_volume
					reagents.reaction(M, REAGENT_TOUCH, fraction)


/obj/effect/particle_effect/foam/metal
	name = "metal foam"
	icon_state = "mfoam"  // finally mentor foam
	spread_time = 12 SECONDS
	/// Represents the icon state that we'll become when we solidify
	var/metal = METAL_FOAM_ALUMINUM

/obj/effect/particle_effect/foam/metal/generate_color()
	return  // metal foam is boring

/obj/effect/particle_effect/foam/metal/disperse_reagents()
	var/turf/T = get_turf(src)
	if(isspaceturf(T) && !istype(T, /turf/space/transit))
		T.ChangeTurf(/turf/simulated/floor/plating/metalfoam)
		var/turf/simulated/floor/plating/metalfoam/MF = get_turf(src)
		MF.metal = metal


	var/obj/structure/foamedmetal/M = new(src.loc)
	M.metal = metal
	M.update_state()

/obj/effect/particle_effect/foam/metal/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/effect/particle_effect/foam/metal/Crossed(atom/movable/AM, oldloc)
	return

/datum/effect_system/foam_spread
	effect_type = /obj/effect/particle_effect/foam
	/// the size of the foam spread.
	var/spread_size = 5
	/// the IDs of reagents present when the foam was mixed
	var/list/carried_reagents
	/// which type of foam this generates
	var/foam_type = /obj/effect/particle_effect/foam
	/// the temperature that the reagents in the foam will be set to
	var/temperature = T0C
	/// the reagents that we don't want in smoke
	var/list/banned_reagents = list("smoke_powder", "fluorosurfactant", "stimulants")

/datum/effect_system/foam_spread/set_up(amt = 5, where, datum/reagents/carry = null)
	spread_size = min(round(amt / 5, 1), 7)
	if(isturf(where))
		location = where
	else
		location = get_turf(where)

	carried_reagents = list()
	temperature = carry.chem_temp

	// bit of a hack here. Foam carries along any reagent also present in the glass it is mixed
	// with (defaults to water if none is present). Rather than actually transfer the reagents,
	// this makes a list of the reagent ids and spawns 1 unit of that reagent when the foam disolves.

	if(carry)
		for(var/datum/reagent/R in carry.reagent_list)
			carried_reagents[R.id] = R.volume

/datum/effect_system/foam_spread/proc/setup_reagents(obj/effect/particle_effect/foam/working_foam)
	working_foam.create_reagents(25)

	if(!carried_reagents)
		return
	for(var/id in carried_reagents)
		if(banned_reagents.Find("[id]"))
			continue
		var/datum/reagent/reagent_volume = carried_reagents[id]
		working_foam.reagents.add_reagent(id, min(reagent_volume, 5), null, temperature)
	working_foam.color = mix_color_from_reagents(working_foam.reagents.reagent_list)

/datum/effect_system/foam_spread/proc/spread()
	var/obj/effect/particle_effect/foam/working_foam = locate() in location
	if(working_foam)
		working_foam.spread_amount = min(working_foam.spread_amount + working_foam.spread_amount, working_foam.max_amount_on_spread)
		if(FOAM_REACT_DURING_SPREAD)
			working_foam.disperse_reagents()
		return

	working_foam = new foam_type(location)
	working_foam.spread_amount = spread_size
	setup_reagents(working_foam)

/datum/effect_system/foam_spread/cleaner

/datum/effect_system/foam_spread/cleaner/setup_reagents(obj/effect/particle_effect/foam/F)
	F.reagents.add_reagent("cleaner", 1)
	F.color = mix_color_from_reagents(F.reagents.reagent_list)

/datum/effect_system/foam_spread/start()
	INVOKE_ASYNC(src, PROC_REF(spread))

/datum/effect_system/foam_spread/metal
	/// The type of metal that will be formed from this
	var/metal_type = METAL_FOAM_ALUMINUM
	effect_type = /obj/effect/particle_effect/foam/metal

/datum/effect_system/foam_spread/metal/setup_reagents()
	return

// wall formed by metal foams
// dense and opaque, but easy to break

/obj/structure/foamedmetal
	name = "foamed metal"
	desc = "A lightweight foamed metal wall."
	icon = 'icons/effects/effects.dmi'
	icon_state = "metalfoam"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	density = TRUE
	opacity = TRUE	// changed in New()
	anchored = TRUE
	max_integrity = 20
	var/metal = METAL_FOAM_ALUMINUM

/obj/structure/foamedmetal/Initialize()
	..()
	air_update_turf(1)

/obj/structure/foamedmetal/Destroy()
	var/turf/T = get_turf(src)
	. = ..()
	T.air_update_turf(TRUE)

/obj/structure/foamedmetal/Move()
	var/turf/T = loc
	..()
	move_update_air(T)

/obj/structure/foamedmetal/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	playsound(src.loc, 'sound/weapons/tap.ogg', 100, TRUE)

/obj/structure/foamedmetal/proc/update_state()
	if(metal == METAL_FOAM_ALUMINUM)
		max_integrity = 20
		obj_integrity = max_integrity
	else
		max_integrity = 50
		obj_integrity = max_integrity
	update_icon(UPDATE_ICON_STATE)

/obj/structure/foamedmetal/update_icon_state()
	if(metal == METAL_FOAM_ALUMINUM)
		icon_state = "metalfoam"
	else
		icon_state = "ironfoam"

/obj/structure/foamedmetal/attack_hand(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
	if(prob(75 - metal * 25))
		user.visible_message("<span class='warning'>[user] smashes through [src].</span>", "<span class='notice'>You smash through [src].</span>")
		qdel(src)
	else
		to_chat(user, "<span class='notice'>You hit the metal foam but bounce off it.</span>")
		playsound(loc, 'sound/weapons/tap.ogg', 100, 1)

/obj/structure/foamedmetal/CanPass(atom/movable/mover, turf/target)
	return !density

/obj/structure/foamedmetal/CanAtmosPass()
	return !density
