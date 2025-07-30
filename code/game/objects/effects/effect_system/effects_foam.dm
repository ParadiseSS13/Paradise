// Foam
// Similar to smoke, but spreads out more
// metal foams leave behind a foamed metal wall

/obj/effect/particle_effect/foam
	name = "foam"
	icon_state = "foam"
	gender = PLURAL
	layer = OBJ_LAYER + 0.9
	animate_movement = NO_STEPS
	cares_about_temperature = TRUE
	/// How many times this one bit of foam can spread around itself
	var/spread_amount = 3
	/// How long it takes this to initially start spreading after being dispersed
	var/spread_time = 0.9 SECONDS
	/// How long it takes this, once it's spread, to stop spreading and disperse its chems
	var/solidify_time = 12 SECONDS
	/// Whether it reacts on or after dispersion (or both)
	var/react_mode = FOAM_REACT_ON_DISSIPATE | FOAM_REACT_BEFORE_SPREAD
	/// Maximum amount of reagents gained by spreading onto a foamed tile
	var/max_amount_on_spread = 27
	/// We will never fill a mob with more than this many units of a given reagent
	var/max_reagent_filling = 25
	/// Whether or not to spread at a range when spreading
	var/spread_at_range = TRUE

/obj/effect/particle_effect/foam/Initialize(mapload)
	. = ..()
	create_reagents(25)
	playsound(src, 'sound/effects/bubbles2.ogg', 80, TRUE, -3)
	addtimer(CALLBACK(src, PROC_REF(initial_process)), spread_time)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered)
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/particle_effect/foam/proc/disperse_reagents()
	if(!reagents)
		return
	reagents.handle_reactions()
	for(var/atom/A in (spread_at_range ? oview(1, src) : view(0, src)))
		if(A == src)
			continue
		fill_with_reagents(A)

/obj/effect/particle_effect/foam/proc/fill_with_reagents(atom/A)
	if(reagents.total_volume)
		var/fraction = 5 / reagents.total_volume
		reagents.reaction(A, REAGENT_TOUCH, fraction)

	if(iscarbon(A) && !QDELETED(A))
		var/mob/living/carbon/foamed = A
		for(var/datum/reagent/R as anything in reagents.reagent_list)
			var/amount = foamed.reagents?.get_reagent_amount(R.id)
			var/foam_content_amount = reagents.get_reagent_amount(R.id)
			if(amount < max_reagent_filling)
				foamed.reagents?.add_reagent(R.id, min(round(foam_content_amount / 2), 15))

/obj/effect/particle_effect/foam/proc/initial_process()
	process()
	START_PROCESSING(SSobj, src)
	addtimer(CALLBACK(src, PROC_REF(stop_processing)), solidify_time)
	addtimer(CALLBACK(src, PROC_REF(dissipate)), solidify_time + 3 SECONDS)

/obj/effect/particle_effect/foam/proc/stop_processing()
	STOP_PROCESSING(SSobj, src)

/obj/effect/particle_effect/foam/proc/dissipate()

	if(react_mode & FOAM_REACT_ON_DISSIPATE)
		addtimer(CALLBACK(src, PROC_REF(disperse_reagents)), 0.3 SECONDS)
	flick("[icon_state]-disolve", src)
	QDEL_IN(src, 0.5 SECONDS)

/obj/effect/particle_effect/foam/proc/try_spread_to(turf/target_turf)
	if(!target_turf || !target_turf.Enter(src))
		return

	var/obj/effect/particle_effect/foam/new_foam = locate() in target_turf

	if(new_foam)
		return

	new_foam = new type(target_turf)
	new_foam.spread_amount = spread_amount
	new_foam.spread_time = spread_time
	new_foam.solidify_time = solidify_time
	new_foam.max_amount_on_spread = max_amount_on_spread
	new_foam.spread_at_range = spread_at_range
	new_foam.react_mode = react_mode
	new_foam.max_reagent_filling = max_reagent_filling

	// add the new amount of foam
	if(reagents)
		for(var/datum/reagent/R in reagents.reagent_list)
			new_foam.reagents.add_reagent(R.id, min(R.volume, 5), R.data, reagents.chem_temp)
		new_foam.color = mix_color_from_reagents(reagents.reagent_list)
	if(react_mode & FOAM_REACT_BEFORE_SPREAD)
		new_foam.disperse_reagents()

/obj/effect/particle_effect/foam/proc/spread()
	for(var/direction in GLOB.cardinal)
		var/turf/T = get_step(src, direction)
		try_spread_to(T)

/obj/effect/particle_effect/foam/proc/generate_color()
	color = mix_color_from_reagents(reagents.reagent_list)

/obj/effect/particle_effect/foam/process()
	if(react_mode & FOAM_REACT_DURING_SPREAD)
		disperse_reagents()

	if(--spread_amount < 0)
		return

	spread()

// foam disolves when heated
// except metal foams
/obj/effect/particle_effect/foam/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE) //Don't heat the reagents inside
	return

/obj/effect/particle_effect/foam/temperature_expose(exposed_temperature, exposed_volume) // overriden to prevent weird behaviors with heating reagents inside
	if(prob(max(0, exposed_temperature - 475)))
		flick("[icon_state]-disolve", src)
		QDEL_IN(src, 0.5 SECONDS)

/obj/effect/particle_effect/foam/proc/on_atom_entered(datum/source, atom/movable/entered)
	if(!iscarbon(entered))
		return
	var/mob/living/carbon/M = entered
	if((M.slip("foam", 10 SECONDS) || IS_HORIZONTAL(M)) && reagents)
		fill_with_reagents(M)

/obj/effect/particle_effect/foam/metal
	name = "metal foam"
	icon_state = "mfoam"  // finally mentor foam
	spread_time = 1.2 SECONDS
	react_mode = FOAM_REACT_ON_DISSIPATE
	/// Represents the icon state that we'll become when we solidify
	var/metal_kind = METAL_FOAM_ALUMINUM

/obj/effect/particle_effect/foam/metal/generate_color()
	return  // metal foam is boring

/obj/effect/particle_effect/foam/metal/disperse_reagents()
	var/turf/T = get_turf(src)
	if(isspaceturf(T) && !istype(T, /turf/space/transit))
		T.ChangeTurf(/turf/simulated/floor/plating/metalfoam)
		var/turf/simulated/floor/plating/metalfoam/MF = get_turf(src)
		MF.metal_kind = metal_kind

	var/obj/structure/foamedmetal/M = new(loc)
	M.metal = metal_kind
	M.update_state()

/obj/effect/particle_effect/foam/metal/temperature_expose(exposed_temperature, exposed_volume)
	return

/obj/effect/particle_effect/foam/metal/on_atom_entered(datum/source, atom/movable/entered)
	return

/datum/effect_system/foam_spread
	effect_type = /obj/effect/particle_effect/foam
	/// the size of the foam spread.
	var/spread_size = 5
	/// the IDs of reagents present when the foam was mixed
	var/list/carried_reagents
	/// the temperature that the reagents in the foam will be set to
	var/temperature = T0C
	/// the reagents that we don't want in foam
	var/list/banned_reagents = list("smoke_powder", "fluorosurfactant", "stimulants")

/datum/effect_system/foam_spread/set_up(amt = 5, where, datum/reagents/carry)
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
	if(!carried_reagents)
		return
	for(var/id in carried_reagents)
		if(banned_reagents.Find("[id]"))
			continue
		var/datum/reagent/reagent_volume = carried_reagents[id]
		working_foam.reagents.add_reagent(id, min(reagent_volume, 5), null, temperature)
	working_foam.reagents.chem_temp = temperature
	working_foam.color = mix_color_from_reagents(working_foam.reagents.reagent_list)

/datum/effect_system/foam_spread/proc/spread()
	var/obj/effect/particle_effect/foam/working_foam = locate() in location
	if(working_foam)
		working_foam.spread_amount = min(working_foam.spread_amount + working_foam.spread_amount, working_foam.max_amount_on_spread)
		return

	working_foam = new effect_type(location)
	working_foam.spread_amount = spread_size
	setup_reagents(working_foam)

/datum/effect_system/foam_spread/start()
	INVOKE_ASYNC(src, PROC_REF(spread))

/datum/effect_system/foam_spread/cleaner

/datum/effect_system/foam_spread/cleaner/setup_reagents(obj/effect/particle_effect/foam/F)
	F.react_mode = FOAM_REACT_ON_DISSIPATE
	F.spread_at_range = TRUE
	F.color = mix_color_from_reagents(F.reagents.reagent_list)

/datum/effect_system/foam_spread/metal
	/// The type of metal that will be formed from this
	var/metal_type = METAL_FOAM_ALUMINUM
	effect_type = /obj/effect/particle_effect/foam/metal

/datum/effect_system/foam_spread/metal/set_up(amt, where, datum/reagents/carry, _metal_type = METAL_FOAM_ALUMINUM)
	. = ..()
	metal_type = _metal_type

/datum/effect_system/foam_spread/metal/setup_reagents()
	return

/obj/effect/particle_effect/foam/oil
	react_mode = FOAM_REACT_DURING_SPREAD | FOAM_REACT_ON_DISSIPATE
	spread_at_range = FALSE

/datum/effect_system/foam_spread/oil
	effect_type = /obj/effect/particle_effect/foam/oil
	temperature = 1000

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

/obj/structure/foamedmetal/Initialize(mapload)
	. = ..()
	recalculate_atmos_connectivity()

/obj/structure/foamedmetal/Destroy()
	var/turf/T = get_turf(src)
	. = ..()
	T.recalculate_atmos_connectivity()

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

/obj/structure/foamedmetal/CanPass(atom/movable/mover, border_dir)
	return !density

/obj/structure/foamedmetal/CanAtmosPass(direction)
	return !density
