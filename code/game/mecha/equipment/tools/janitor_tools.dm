// Mecha mop, light replacer, mecha spray, garbage bag

/obj/item/mecha_parts/mecha_equipment/janitor

/obj/item/mecha_parts/mecha_equipment/janitor/can_attach(obj/mecha/janitor/M)
	if(..() && istype(M))
		return TRUE

// Mop
//! How many seconds before the mopping sound triggers again
#define MOP_SOUND_CD 2 SECONDS

/obj/item/mecha_parts/mecha_equipment/janitor/mega_mop
	name = "\improper WLLY mega mop"
	desc = "An upsized advanced mop, designed for use in exosuits."
	icon_state = "mecha_mop"
	equip_cooldown = 1.5 SECONDS
	energy_drain = 1
	range = MECHA_MELEE | MECHA_RANGED
	/// When the mopping sound was last played.
	COOLDOWN_DECLARE(mop_sound_cooldown)
	/// How fast does this mop?
	var/mop_speed = 2 SECONDS
	/// Toggle for refilling itself
	var/refill_enabled = TRUE
	/// Rate per process() tick mop refills itself
	var/refill_rate = 5
	/// Power use per process to refill reagents
	var/refill_cost = 10
	/// What reagent to refill with
	var/refill_reagent = "water"

/obj/item/mecha_parts/mecha_equipment/janitor/mega_mop/Initialize(mapload)
	. = ..()
	create_reagents(1000)
	reagents.add_reagent("water", 1000)
	START_PROCESSING(SSobj, src)

/obj/item/mecha_parts/mecha_equipment/janitor/mega_mop/emag_act(mob/user)
	. = ..()
	emagged = TRUE
	to_chat(user, "<span class='warning'>You short out the automatic watering system on [src].</span>")
	reagents.clear_reagents()
	refill_reagent = "lube"
	refill_cost = 50

/obj/item/mecha_parts/mecha_equipment/janitor/mega_mop/action(atom/target)
	if(get_dist(chassis, target) > 2)
		return
	if(istype(target, /obj/structure/reagent_dispensers/watertank) && get_dist(chassis,target) <= 1)
		var/obj/structure/reagent_dispensers/watertank/WT = target
		WT.reagents.trans_to(src, 1000)
		occupant_message("<span class='notice'>Mop refilled.</span>")
		playsound(chassis, 'sound/effects/refill.ogg', 50, TRUE, -6)
		return
	if(reagents.total_volume > 0)
		if(COOLDOWN_FINISHED(src, mop_sound_cooldown))
			playsound(loc, pick('sound/weapons/mopping1.ogg', 'sound/weapons/mopping2.ogg'), 30, TRUE, -1)
			COOLDOWN_START(src, mop_sound_cooldown, MOP_SOUND_CD)
		// 3x3 mopping area
		var/turf/target_turf = get_turf(target)
		if(!istype(target_turf) || iswallturf(target_turf))
			return
		chassis.occupant.visible_message("<span class='warning'>[chassis] begins to mop \the [target_turf] with \the [src].</span>", "<span class='warning'>You begin to mop \the [target_turf] with \the [src].</span>")
		if(do_after(chassis.occupant, mop_speed, target = target))
			for(var/turf/current_target_turf in view(1, target))
				current_target_turf.cleaning_act(chassis.occupant, src, mop_speed, "mop", ".", skip_do_after = TRUE)
			chassis.occupant_message("You mop \the [target].")

/obj/item/mecha_parts/mecha_equipment/janitor/mega_mop/post_clean(atom/target, mob/user)
	var/turf/T = get_turf(target)
	if(issimulatedturf(T))
		reagents.reaction(T, REAGENT_TOUCH, 10)	// 10 is the multiplier for the reaction effect. 10 is needed to properly wet a floor.
	reagents.remove_any(1)	// reaction() doesn't use up the reagents

/obj/item/mecha_parts/mecha_equipment/janitor/mega_mop/can_clean()
	return reagents.has_reagent("water", 1) || reagents.has_reagent("cleaner", 1) || reagents.has_reagent("holywater", 1)

// Auto-regeneration of water. Takes energy.
/obj/item/mecha_parts/mecha_equipment/janitor/mega_mop/process()
	if(reagents.total_volume < 1000)
		reagents.add_reagent(refill_reagent, refill_rate)
		chassis.use_power(refill_cost)
		update_equip_info()

/obj/item/mecha_parts/mecha_equipment/janitor/mega_mop/get_equip_info()
	var/output = ..()
	if(output)
		return "[output] \[<a href='byond://?src=[UID()];toggle_mode=1'>Refill [refill_enabled? "Enabled" : "Disabled"]</a>\] \[[reagents.total_volume]\]"

/obj/item/mecha_parts/mecha_equipment/janitor/mega_mop/Topic(href, href_list)
	..()
	var/datum/topic_input/afilter = new (href, href_list)
	if(afilter.get("toggle_mode"))
		refill_enabled = !refill_enabled
		if(refill_enabled)
			START_PROCESSING(SSobj, src)
		else
			STOP_PROCESSING(SSobj, src)
		update_equip_info()

#undef MOP_SOUND_CD

// Light Replacer
/obj/item/mecha_parts/mecha_equipment/janitor/light_replacer
	name = "\improper NT-12 illuminator"
	desc = "A modified light replacer fit for an exosuit that zaps lights into place."
	icon_state = "mecha_light_replacer"
	equip_cooldown = 1.5 SECONDS
	energy_drain = 100
	range = MECHA_MELEE | MECHA_RANGED

/obj/item/mecha_parts/mecha_equipment/janitor/light_replacer/emag_act(mob/user)
	. = ..()
	emagged = TRUE
	to_chat(user, "<span class='notice'>You short out the safeties on [src].</span>")

/obj/item/mecha_parts/mecha_equipment/janitor/light_replacer/action(atom/target)
	if(istype(target, /obj/machinery/light))
		chassis.Beam(target, icon_state = "rped_upgrade", icon = 'icons/effects/effects.dmi', time = 5)
		playsound(src, 'sound/items/pshoom.ogg', 40, 1)
		target.fix(chassis.occupant, src, emagged)

// Mecha spray
/obj/item/mecha_parts/mecha_equipment/janitor/mega_spray
	name = "\improper JS-33 super spray"
	desc = "A spray bottle, upscaled for an exosuit. Capable of mass sanitation."
	icon_state = "mecha_spray"
	equip_cooldown = 1.5 SECONDS
	energy_drain = 200
	range = MECHA_MELEE | MECHA_RANGED
	/// Toggle for refilling itself
	var/refill_enabled = TRUE
	/// Rate per process() tick spray refills itself
	var/refill_rate = 1
	/// Power use per process to refill reagents
	var/refill_cost = 25
	/// What reagent to refill with
	var/refill_reagent = "cleaner"
	/// The range of tiles the sprayer will reach.
	var/spray_range = 4

/obj/item/mecha_parts/mecha_equipment/janitor/mega_spray/Initialize(mapload)
	. = ..()
	create_reagents(100)
	reagents.add_reagent("cleaner", 100)
	START_PROCESSING(SSobj, src)

/obj/item/mecha_parts/mecha_equipment/janitor/mega_spray/emag_act(mob/user)
	. = ..()
	emagged = TRUE
	to_chat(user, "<span class='warning'>You short out the automatic watering system on [src].</span>")
	reagents.clear_reagents()
	refill_reagent = "lube"
	refill_cost = 50
	refill_rate = 5

/obj/item/mecha_parts/mecha_equipment/janitor/mega_spray/action(atom/target)
	if(reagents.total_volume < 15) // Needs at least enough reagents to apply the full spray
		to_chat(chassis.occupant, "<span class='danger'>*click*</span>")
		playsound(src, 'sound/weapons/empty.ogg', 100, 1)
		return
	var/direction = get_dir(chassis, target)
	var/turf/T = get_turf(target)
	var/turf/T1 = get_step(T, turn(direction, 90))
	var/turf/T2 = get_step(T, turn(direction, -90))
	var/list/the_targets = list(T, T1, T2)
	playsound(chassis, 'sound/effects/spray2.ogg', 75, TRUE, -3)
	for(var/turf/target_turf in the_targets)
		INVOKE_ASYNC(src, PROC_REF(spray), target_turf)

/obj/item/mecha_parts/mecha_equipment/janitor/mega_spray/proc/spray(turf/target)
	var/obj/effect/decal/chempuff/spray = new /obj/effect/decal/chempuff(get_turf(chassis))
	var/datum/reagents/R = new/datum/reagents(5)
	spray.reagents = R
	R.my_atom = spray
	reagents.trans_to(spray, 5)
	spray.icon += mix_color_from_reagents(spray.reagents.reagent_list)
	for(var/B in 1 to 4)
		if(QDELETED(spray))
			return
		if(spray.reagents.total_volume == 0)
			qdel(spray)
			return
		step_towards(spray, target)
		if(QDELETED(spray))
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
		return "[output] \[<a href='byond://?src=[UID()];toggle_mode=1'>Refill [refill_enabled? "Enabled" : "Disabled"]</a>\] \[[reagents.total_volume]\]"

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

// Garbage Magnet
/obj/item/mecha_parts/mecha_equipment/janitor/garbage_magnet
	name = "\improper WA1E Garbage Magnet"
	desc = "Bluespace technology integrated with an oversized garbage bag and heavy duty magnets allows this device to pick up all manner of litter. \
	The complex technology prevents users from directly looking inside the bag."
	icon_state = "mecha_trash_magnet"
	equip_cooldown = 1.5 SECONDS
	energy_drain = 5
	range = MECHA_MELEE | MECHA_RANGED
	/// Toggle for filling the bag (true) or emptying (false)
	var/bagging = TRUE
	/// Toggle for wide area or single tile pickups
	var/extended = FALSE
	/// List of items currently in the bag
	var/list/cargo = list()
	/// How many different items can be in the bag?
	var/cargo_slots = 100
	/// How much weight is the maximum for the bag?
	var/cargo_max_weight = 100
	/// Largest weight class that can fit in the bag
	var/max_weight_class = WEIGHT_CLASS_NORMAL
	/// List of items the bag cannot hold
	var/list/cant_hold = list(/obj/item/disk/nuclear, /obj/item/grown/bananapeel/traitorpeel, /obj/item/storage/bag)

/obj/item/mecha_parts/mecha_equipment/janitor/garbage_magnet/Initialize(mapload)
	. = ..()
	cant_hold = typecacheof(cant_hold)

/obj/item/mecha_parts/mecha_equipment/janitor/garbage_magnet/deconstruct()
	var/turf/T = get_turf(src)
	for(var/obj/item/I in cargo)
		I.forceMove(T)
	cargo.Cut()
	qdel(src)

/obj/item/mecha_parts/mecha_equipment/janitor/garbage_magnet/get_equip_info()
	var/output = ..()
	if(output)
		return "[output] \[<a href='byond://?src=[UID()];toggle_bagging=1'>[bagging? "Filling" : "Dumping"]</a>\] \[<a href='byond://?src=[UID()];toggle_extended=1'>Area [extended? "Extended" : "Focused"]</a>\] \[Cargo: [length(cargo)]/[cargo_max_weight]</a>\]\]"

/obj/item/mecha_parts/mecha_equipment/janitor/garbage_magnet/Topic(href,href_list)
	..()
	var/datum/topic_input/afilter = new (href,href_list)
	if(afilter.get("toggle_bagging"))
		bagging = !bagging
		update_equip_info()
		return
	if(afilter.get("toggle_extended"))
		extended = !extended
		update_equip_info()
		return

/obj/item/mecha_parts/mecha_equipment/janitor/garbage_magnet/action(atom/target)
	if(istype(target, /obj/machinery/disposal)) // Emptying stuff into disposals
		chassis.occupant.visible_message(
			"<span class='notice'>[chassis.occupant] empties [src] into the disposal unit.</span>",
			"<span class='notice'>You empty [src] into disposal unit.</span>",
			"<span class='notice'>You hear someone emptying something into a disposal unit.</span>"
		)
		for(var/obj/item/I in cargo)
			I.forceMove(target)
		cargo.Cut()
		return
	var/turf/target_turf
	if(iswallturf(target))
		return
	if(isturf(target))
		target_turf = target
	else
		target_turf = get_turf(target)
	if(bagging) // If picking up
		if(extended) // If extended reach
			for(var/turf/current_target_turf in view(1, target_turf))
				for(var/obj/item/I in current_target_turf.contents)
					if(can_be_inserted(I))
						cargo += I
						I.forceMove(chassis)
		else // Single turf
			for(var/obj/item/I in target_turf.contents)
				if(can_be_inserted(I))
					cargo += I
					I.forceMove(chassis)
		chassis.occupant_message("You pick up all the items with [src]. Cargo compartment capacity: [cargo_max_weight - length(cargo)]")

	else // Dumping
		for(var/obj/item/I in cargo)
			I.forceMove(target_turf)
		cargo.Cut()
		chassis.occupant_message("<span class='notice'>You dump everything out of [src].")
	update_equip_info()

/obj/item/mecha_parts/mecha_equipment/janitor/garbage_magnet/proc/can_be_inserted(obj/item/I, stop_messages = FALSE)
	if(!istype(I) || (I.flags & ABSTRACT)) // Not an item
		return

	if(loc == I)
		return FALSE // Means the item is already in the storage item

	if(!I.can_enter_storage(src, usr))
		return FALSE

	if(length(contents) >= cargo_slots)
		if(!stop_messages)
			chassis.occupant_message("[I] won't fit in [src], make some space!")
		return FALSE // Storage item is full

	if(is_type_in_typecache(I, cant_hold)) // Check for specific items which this container can't hold.
		if(!stop_messages)
			chassis.occupant_message("[src] cannot hold [I].")
		return FALSE

	if(length(cant_hold) && isstorage(I)) // Checks nested storage contents for restricted objects, we don't want people sneaking the NAD in via boxes now, do we?
		var/obj/item/storage/S = I
		for(var/obj/A as anything in S.return_inv())
			if(is_type_in_typecache(A, cant_hold))
				if(!stop_messages)
					chassis.occupant_message("[src] rejects [I] because of its contents.")
				return FALSE

	if(I.w_class > max_weight_class)
		if(!stop_messages)
			chassis.occupant_message("[I] is too big for [src].")
		return FALSE

	var/sum_w_class = I.w_class
	for(var/obj/item/item in contents)
		sum_w_class += item.w_class // Adds up the combined w_classes which will be in the storage item if the item is added to it.

	if(sum_w_class > cargo_max_weight)
		if(!stop_messages)
			chassis.occupant_message("[src] is full, make some space.")
		return FALSE
	return TRUE
