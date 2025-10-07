GLOBAL_LIST_EMPTY(flame_effects)
#define MAX_FIRE_EXIST_TIME 10 MINUTES // That's a lot of fuel, but you are not gonna make it last for longer

/obj/effect/fire
	name = "fire"
	desc = "You don't think you should touch this."
	icon = 'icons/effects/chemical_fire.dmi'
	icon_state = "red_small"
	base_icon_state = "red"
	/// How hot is our fire?
	var/temperature
	/// How long will our fire last
	var/duration = 10 SECONDS
	/// How many firestacks does the fire give to mobs
	var/application_stacks = 1

/obj/effect/fire/Initialize(mapload, reagent_temperature, reagent_duration, fire_applications, color)
	. = ..()

	if(reagent_duration < 0 || reagent_temperature <= 0) // There is no reason for this thing to exist
		qdel(src)
		return

	duration = reagent_duration
	temperature = reagent_temperature
	application_stacks = max(application_stacks, fire_applications)
	if(color)
		base_icon_state = color
	update_icon()

	for(var/obj/effect/fire/flame in get_turf(src))
		if(!istype(flame) || flame == src)
			continue
		merge_flames(flame)

	GLOB.flame_effects += src
	START_PROCESSING(SSprocessing, src)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/fire/Destroy()
	. = ..()
	GLOB.flame_effects -= src
	STOP_PROCESSING(SSprocessing, src)

/obj/effect/fire/process()
	if(duration <= 0)
		fizzle()
		return
	duration -= 2 SECONDS
	update_icon(UPDATE_ICON_STATE)

	for(var/atom/movable/thing_to_burn in get_turf(src))
		if(isliving(thing_to_burn))
			damage_mob(thing_to_burn)
			continue

		if(isobj(thing_to_burn))
			var/obj/obj_to_burn = thing_to_burn
			obj_to_burn.fire_act(null, temperature)
			continue

	var/turf/location = get_turf(src)
	if(!location)
		return
	var/datum/gas_mixture/air = location.private_unsafe_get_air()
	if(!air)
		return FALSE
	var/datum/milla_safe/fire_heat_air/milla = new()
	milla.invoke_async(src, location)

/obj/effect/fire/update_icon_state()
	var/suffix = "small"
	if(duration >= 30 SECONDS)
		suffix = "big"
	else if(duration >= 10 SECONDS)
		suffix = "medium"
	icon_state = "[base_icon_state]_[suffix]"

/datum/milla_safe/fire_heat_air

/datum/milla_safe/fire_heat_air/on_run(obj/effect/fire/fire, turf/T)
	var/datum/gas_mixture/env = get_turf_air(T)
	env.set_temperature(fire.temperature)

/obj/effect/fire/water_act(volume, temperature, source, method)
	. = ..()
	duration -= 10 SECONDS
	if(duration <= 0)
		fizzle()
	update_icon(UPDATE_ICON_STATE)

/obj/effect/fire/proc/on_atom_entered(datum/source, atom/movable/entered, old_loc)
	SIGNAL_HANDLER // COMSIG_ATOM_ENTERED
	if(isliving(entered))
		if(!damage_mob(entered))
			return
		to_chat(entered, "<span class='warning'>[src] burns you!</span>")
		return

	if(isitem(entered))
		var/obj/item/item_to_burn = entered
		item_to_burn.fire_act(null, temperature)

/obj/effect/fire/proc/fizzle()
	playsound(src, 'sound/effects/fire_sizzle.ogg', 50, TRUE)
	qdel(src)

/obj/effect/fire/proc/merge_flames(obj/effect/fire/merging_flame)
	duration = min((duration + (merging_flame.duration / 4)), MAX_FIRE_EXIST_TIME)
	temperature = ((merging_flame.temperature + temperature) / 2) // No making a sun by just clicking 10 times on a turf
	merging_flame.fizzle()

/obj/effect/fire/proc/damage_mob(mob/living/mob_to_burn)
	if(!istype(mob_to_burn))
		return
	var/fire_damage = temperature / 100
	if(ishuman(mob_to_burn))
		var/mob/living/carbon/human/human_to_burn = mob_to_burn
		var/fire_armour = human_to_burn.get_thermal_protection()
		if(fire_armour >= FIRE_IMMUNITY_MAX_TEMP_PROTECT)
			return FALSE

		if(fire_armour == FIRE_SUIT_MAX_TEMP_PROTECT) // Good protection but you won't survive infinitely in it
			fire_damage /= 4

	mob_to_burn.adjustFireLoss(fire_damage)
	mob_to_burn.adjust_fire_stacks(application_stacks)
	mob_to_burn.IgniteMob()

/obj/effect/fire/mapping

/obj/effect/fire/mapping/Initialize(mapload)
	. = ..(mapload, T0C + 300, 4 HOURS, 1)
	set_light(3, 3, LIGHT_COLOR_LAVA)

/obj/effect/fire/mapping/water_act(volume, temperature, source, method)
	. = ..()
	duration -= 30 MINUTES
	if(duration <= 0)
		fizzle()

#undef MAX_FIRE_EXIST_TIME
