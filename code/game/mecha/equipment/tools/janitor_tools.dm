// Mecha mop, light replacer, mecha spray, garbage bag, cleaning grenade launcher

/obj/item/mecha_parts/mecha_equipment/janitor

/obj/item/mecha_parts/mecha_equipment/janitor/can_attach(obj/mecha/janitor/M)
	if(..() && istype(M))
		return TRUE

// Mop

#define MOP_SOUND_CD 2 SECONDS // How many seconds before the mopping sound triggers again

/obj/item/mecha_parts/mecha_equipment/janitor/mega_mop
	name = "WLLY mega mop"
	desc = "An upsized advanced mop, designed for use in exosuits."
	icon_state = "mecha_mop"
	equip_cooldown = 15
	energy_drain = 1
	range = MECHA_MELEE | MECHA_RANGED
	/// When the mopping sound was last played.
	var/mop_sound_cooldown
	/// How fast does this mop?
	var/mop_speed = 20
	/// Toggle for refilling itself
	var/refill_enabled = TRUE
	/// Rate per process() tick mop refills itself
	var/refill_rate = 5
	/// Power use per process to refill reagents
	var/refill_cost = 10
	/// What reagent to refill with
	var/refill_reagent = "water"

/obj/item/mecha_parts/mecha_equipment/janitor/mega_mop/New()
	create_reagents(1000)
	reagents.add_reagent("water", 1000)
	START_PROCESSING(SSobj, src)
	..()

/obj/item/mecha_parts/mecha_equipment/janitor/mega_mop/emag_act(mob/user)
	. = ..()
	emagged = TRUE
	to_chat(user, "<span class='notice'>You short out the automatic watering system on [src].</span>")
	reagents.clear_reagents()
	refill_reagent = "lube"
	refill_cost = 50

/obj/item/mecha_parts/mecha_equipment/janitor/mega_mop/action(atom/target)
	if(istype(target, /obj/structure/reagent_dispensers/watertank) && get_dist(chassis,target) <= 1)
		var/obj/structure/reagent_dispensers/watertank/WT = target
		WT.reagents.trans_to(src, 1000)
		occupant_message("<span class='notice'>Mop refilled.</span>")
		playsound(chassis, 'sound/effects/refill.ogg', 50, TRUE, -6)
	else
		if(get_dist(chassis, target) > 2)
			return
		if(reagents.total_volume > 0)
			if(world.time > mop_sound_cooldown)
				playsound(loc, pick('sound/weapons/mopping1.ogg', 'sound/weapons/mopping2.ogg'), 30, TRUE, -1)
				mop_sound_cooldown = world.time + MOP_SOUND_CD
			// 3x3 mopping area
			var/turf/target_turf = get_turf(target)
			if(!istype(target_turf) || iswallturf(target_turf))
				return
			for(var/turf/current_target_turf in view(1, target))
				INVOKE_ASYNC(current_target_turf, TYPE_PROC_REF(/atom, cleaning_act), chassis.occupant, src, mop_speed, "mop", ".")

/obj/item/mecha_parts/mecha_equipment/janitor/mega_mop/post_clean(atom/target, mob/user)
	var/turf/T = get_turf(target)
	if(issimulatedturf(T))
		reagents.reaction(T, REAGENT_TOUCH, 10)	// 10 is the multiplier for the reaction effect. 10 is needed to properly wet a floor.
	reagents.remove_any(1)	// reaction() doesn't use up the reagents

/obj/item/mecha_parts/mecha_equipment/janitor/mega_mop/can_clean()
	if(reagents.has_reagent("water", 1) || reagents.has_reagent("cleaner", 1) || reagents.has_reagent("holywater", 1))
		return TRUE
	else
		return FALSE

// Auto-regeneration of water. Takes energy.
/obj/item/mecha_parts/mecha_equipment/janitor/mega_mop/process()
	if(reagents.total_volume < 1000)
		reagents.add_reagent(refill_reagent, refill_rate)
		chassis.use_power(refill_cost)
		update_equip_info()

/obj/item/mecha_parts/mecha_equipment/janitor/mega_mop/get_equip_info()
	var/output = ..()
	if(output)
		return "[output] \[<a href='byond://?src=[UID()];toggle_mode=1'>Refill [refill_enabled? "Enabled" : "Disabled"]</a>\] \[[src.reagents.total_volume]\]"

/obj/item/mecha_parts/mecha_equipment/janitor/mega_mop/Topic(href,href_list)
	..()
	var/datum/topic_input/afilter = new (href,href_list)
	if(afilter.get("toggle_mode"))
		refill_enabled = !refill_enabled
		if(refill_enabled)
			START_PROCESSING(SSobj, src)
		else
			STOP_PROCESSING(SSobj, src)
		update_equip_info()
		return

#undef MOP_SOUND_CD

// Light Replacer

#define LIGHT_OK 0
#define LIGHT_EMPTY 1
#define LIGHT_BROKEN 2
#define LIGHT_BURNED 3

/obj/item/mecha_parts/mecha_equipment/janitor/light_replacer
	name = "NT-12 illuminator"
	desc = "A modified light replacer fit for an exosuit that zaps lights into place."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "lightreplacer_blue0"
	equip_cooldown = 15
	energy_drain = 100
	range = MECHA_MELEE | 15

/obj/item/mecha_parts/mecha_equipment/janitor/light_replacer/emag_act(mob/user)
	. = ..()
	emagged = TRUE
	to_chat(user, "<span class='notice'>You short out the safeties on [src].</span>")

/obj/item/mecha_parts/mecha_equipment/janitor/light_replacer/action(atom/target)
	if(istype(target, /obj/machinery/light))
		chassis.Beam(target, icon_state = "rped_upgrade", icon = 'icons/effects/effects.dmi', time = 5)
		playsound(src, 'sound/items/pshoom.ogg', 40, 1)
		ReplaceLight(target)

/obj/item/mecha_parts/mecha_equipment/janitor/light_replacer/proc/ReplaceLight(obj/machinery/light/target)
	if(target.status != LIGHT_OK)
		to_chat(chassis.occupant, "<span class='notice'>You replace the light [target.fitting] with [src].</span>")
		var/obj/item/light/replacement = target.light_type
		target.status = LIGHT_OK
		target.switchcount = 0
		target.rigged = emagged
		target.brightness_range = initial(replacement.brightness_range)
		target.brightness_power = initial(replacement.brightness_power)
		target.brightness_color = initial(replacement.brightness_color)
		target.on = target.has_power()
		target.update(TRUE, TRUE, FALSE)
	else
		to_chat(chassis.occupant, "<span class='warning'>There is a working [target.fitting] already inserted!</span>")
		return

#undef LIGHT_OK
#undef LIGHT_EMPTY
#undef LIGHT_BROKEN
#undef LIGHT_BURNED

// Mecha spray
/obj/item/mecha_parts/mecha_equipment/janitor/mega_spray
	name = "JS-33 super spray"
	desc = "A spray bottle, upscaled for an exosuit. Capable of mass sanitation."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cleaner"
	equip_cooldown = 15
	energy_drain = 20
	range = MECHA_MELEE | MECHA_RANGED
	/// Toggle for refilling itself
	var/refill_enabled = TRUE
	/// Rate per process() tick spray refills itself
	var/refill_rate = 5
	/// Power use per process to refill reagents
	var/refill_cost = 25
	/// What reagent to refill with
	var/refill_reagent = "cleaner"
	/// The range of tiles the sprayer will reach.
	var/spray_range = 4

/obj/item/mecha_parts/mecha_equipment/janitor/mega_spray/New()
	create_reagents(100)
	reagents.add_reagent("cleaner", 100)
	START_PROCESSING(SSobj, src)
	..()

/obj/item/mecha_parts/mecha_equipment/janitor/mega_spray/emag_act(mob/user)
	. = ..()
	emagged = TRUE
	to_chat(user, "<span class='notice'>You short out the automatic watering system on [src].</span>")
	reagents.clear_reagents()
	refill_reagent = "lube"
	refill_cost = 50

/obj/item/mecha_parts/mecha_equipment/janitor/mega_spray/action(atom/target)
	if(reagents.total_volume > 0)
		var/direction = get_dir(chassis, target)
		var/turf/T = get_turf(target)
		var/turf/T1 = get_step(T, turn(direction, 90))
		var/turf/T2 = get_step(T, turn(direction, -90))
		var/list/the_targets = list(T, T1, T2)
		playsound(chassis, 'sound/effects/spray2.ogg', 75, TRUE, -3)
		for(var/turf/target_turf in the_targets)
			if(reagents.total_volume > 5)
				INVOKE_ASYNC(src, PROC_REF(spray), target_turf)

/obj/item/mecha_parts/mecha_equipment/janitor/mega_spray/proc/spray(turf/target)
	spawn(0)
		var/obj/effect/decal/chempuff/spray = new /obj/effect/decal/chempuff(get_turf(chassis))
		if(!spray)
			return
		var/datum/reagents/R = new/datum/reagents(5)
		spray.reagents = R
		R.my_atom = spray
		reagents.trans_to(spray, 5)
		spray.icon += mix_color_from_reagents(spray.reagents.reagent_list)
		for(var/b=0, b<4, b++)
			if(spray.reagents.total_volume == 0)
				qdel(spray)
				return
			if(!spray)
				return
			step_towards(spray, target)
			if(!spray)
				return
			var/turf/spray_turf = get_turf(spray)
			spray.reagents.reaction(spray_turf)
			for(var/atom/atm in spray_turf)
				spray.reagents.reaction(atm)
			if(spray.loc == target)
				qdel(spray)
				return
			sleep(2)
		qdel(spray)

// Auto-regeneration of space cleaner. Takes energy.
/obj/item/mecha_parts/mecha_equipment/janitor/mega_spray/process()
	if(reagents.total_volume < 100)
		reagents.add_reagent(refill_reagent, refill_rate)
		chassis.use_power(refill_cost)
		update_equip_info()

/obj/item/mecha_parts/mecha_equipment/janitor/mega_spray/get_equip_info()
	var/output = ..()
	if(output)
		return "[output] \[<a href='byond://?src=[UID()];toggle_mode=1'>Refill [refill_enabled? "Enabled" : "Disabled"]</a>\] \[[src.reagents.total_volume]\]"

/obj/item/mecha_parts/mecha_equipment/janitor/mega_spray/Topic(href,href_list)
	..()
	var/datum/topic_input/afilter = new (href,href_list)
	if(afilter.get("toggle_mode"))
		refill_enabled = !refill_enabled
		if(refill_enabled)
			START_PROCESSING(SSobj, src)
		else
			STOP_PROCESSING(SSobj, src)
		update_equip_info()
		return
