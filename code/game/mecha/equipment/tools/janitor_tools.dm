// Mecha mop, light replacer, mecha spray, garbage bag

/obj/item/mecha_parts/mecha_equipment/janitor

/obj/item/mecha_parts/mecha_equipment/janitor/can_attach(obj/mecha/nkarrdem/M)
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
	/// Is the holosign deployer on?
	var/holosign_enabled = TRUE
	/// Internal holosign deployer
	var/obj/item/holosign_creator/janitor/holosign_controller = new /obj/item/holosign_creator/janitor

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
		if(do_after(chassis.occupant, mop_speed, target = target, allow_moving = 0))
			for(var/turf/current_target_turf in view(1, target))
				current_target_turf.cleaning_act(chassis.occupant, src, mop_speed, "mop", ".", skip_do_after = TRUE)
			chassis.occupant_message("You mop \the [target].")
			if(holosign_enabled)
				holosign_controller.afterattack__legacy__attackchain(target_turf, chassis.occupant, TRUE)

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
		return "[output] \[<a href='byond://?src=[UID()];toggle_mode=1'>Refill [refill_enabled? "Enabled" : "Disabled"]</a>\] \[[reagents.total_volume]\] \[<a href='byond://?src=[UID()];toggle_holosign=1'>Holosigns [holosign_enabled? "Enabled" : "Disabled"]</a>\]"

/obj/item/mecha_parts/mecha_equipment/janitor/mega_mop/Topic(href, href_list)
	if(..())
		return
	var/datum/topic_input/afilter = new (href, href_list)
	if(afilter.get("toggle_mode"))
		refill_enabled = !refill_enabled
		if(refill_enabled)
			START_PROCESSING(SSobj, src)
		else
			STOP_PROCESSING(SSobj, src)
		update_equip_info()
		return
	if(afilter.get("toggle_holosign"))
		holosign_enabled = !holosign_enabled
		if(!holosign_enabled)
			holosign_controller.attack_self__legacy__attackchain(chassis.occupant)
		update_equip_info()
		return

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
		var/obj/machinery/light/light_to_fix = target
		light_to_fix.fix(chassis.occupant, src, emagged)

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
	/// Internal sprayer object
	var/obj/item/reagent_containers/spray/spray_controller = new /obj/item/reagent_containers/spray

/obj/item/mecha_parts/mecha_equipment/janitor/mega_spray/Initialize(mapload)
	. = ..()
	// Setup spray controller
	spray_controller.loc = src
	spray_controller.spray_maxrange = spray_range
	spray_controller.spray_currentrange = spray_range
	spray_controller.volume = 100
	spray_controller.reagents.add_reagent("cleaner", 100)
	START_PROCESSING(SSobj, src)

/obj/item/mecha_parts/mecha_equipment/janitor/mega_spray/emag_act(mob/user)
	. = ..()
	emagged = TRUE
	to_chat(user, "<span class='warning'>You short out the automatic watering system on [src].</span>")
	spray_controller.reagents.clear_reagents()
	refill_reagent = "lube"
	refill_cost = 50
	refill_rate = 5

/obj/item/mecha_parts/mecha_equipment/janitor/mega_spray/action(atom/target)
	if(spray_controller.reagents.total_volume < 15) // Needs at least enough reagents to apply the full spray
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
	spray_controller.spray(target)

// Auto-regeneration of space cleaner. Takes energy.
/obj/item/mecha_parts/mecha_equipment/janitor/mega_spray/process()
	if(spray_controller.reagents.total_volume < 100)
		spray_controller.reagents.add_reagent(refill_reagent, refill_rate)
		chassis.use_power(refill_cost)
		update_equip_info()

/obj/item/mecha_parts/mecha_equipment/janitor/mega_spray/get_equip_info()
	var/output = ..()
	if(output)
		return "[output] \[<a href='byond://?src=[UID()];toggle_mode=1'>Refill [refill_enabled? "Enabled" : "Disabled"]</a>\] \[[spray_controller.reagents.total_volume]\]"

/obj/item/mecha_parts/mecha_equipment/janitor/mega_spray/Topic(href,href_list)
	if(..())
		return
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
	desc = "An industrial vaccuum cleaner integrated with an oversized garbage bag and heavy duty magnets allows this device to pick up all manner of litter. \
	The device's safety systems prevent users from directly looking inside the bag."
	icon_state = "mecha_trash_magnet"
	equip_cooldown = 1.5 SECONDS
	energy_drain = 5
	range = MECHA_MELEE | MECHA_RANGED
	/// Toggle for filling the bag (true) or emptying (false)
	var/bagging = TRUE
	/// Toggle for wide area or single tile pickups
	var/extended = FALSE
	/// Garbage magnet range
	var/max_range = 3
	/// List of items the bag cannot hold
	var/list/cant_hold = list(/obj/item/disk/nuclear, /obj/item/grown/bananapeel/traitorpeel, /obj/item/storage/bag)
	/// Handles controlling the storage of items
	var/obj/item/storage/bag/trash/storage_controller = new /obj/item/storage/bag/trash

/obj/item/mecha_parts/mecha_equipment/janitor/garbage_magnet/Initialize(mapload)
	. = ..()
	storage_controller.loc = src
	storage_controller.storage_slots = 100
	storage_controller.max_combined_w_class = 100
	storage_controller.max_w_class = WEIGHT_CLASS_NORMAL
	storage_controller.w_class = WEIGHT_CLASS_NORMAL
	storage_controller.allow_same_size = TRUE // This needs to be true or it won't be able to pick up smaller storages like boxes
	storage_controller.cant_hold = typecacheof(cant_hold)

/obj/item/mecha_parts/mecha_equipment/janitor/garbage_magnet/deconstruct()
	var/turf/T = get_turf(src)
	for(var/obj/item/I in storage_controller.contents)
		storage_controller.remove_from_storage(I, T)
	qdel(src)

/obj/item/mecha_parts/mecha_equipment/janitor/garbage_magnet/get_equip_info()
	var/output = ..()
	if(output)
		return "[output] \[<a href='byond://?src=[UID()];toggle_bagging=1'>[bagging? "Filling" : "Dumping"]</a>\] \[<a href='byond://?src=[UID()];toggle_extended=1'>Area [extended? "Extended" : "Focused"]</a>\] \[Cargo: [length(storage_controller.contents)]/[storage_controller.max_combined_w_class]</a>\]\]"

/obj/item/mecha_parts/mecha_equipment/janitor/garbage_magnet/Topic(href,href_list)
	if(..())
		return
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
	var/target_distance = get_dist(chassis, target)
	if(target_distance > max_range)
		return

	for(var/turf/tested_turf in get_line(chassis, target)) // Check if the path is blocked
		if(iswallturf(tested_turf) || locate(/obj/structure/window) in tested_turf || locate(/obj/machinery/door) in tested_turf) // walls, windows, and doors
			chassis.occupant_message("<span class='warning'>The target is out of reach of the magnet!</span>")
			return

	if(istype(target, /obj/machinery/disposal)) // Emptying stuff into disposals
		chassis.occupant.visible_message(
			"<span class='notice'>[chassis.occupant] empties [src] into the disposal unit.</span>",
			"<span class='notice'>You empty [src] into disposal unit.</span>",
			"<span class='notice'>You hear someone emptying something into a disposal unit.</span>"
		)
		chassis.Beam(target, icon_state = "rped_upgrade", icon = 'icons/effects/effects.dmi', time = 5)
		playsound(src, 'sound/items/pshoom.ogg', 40, 1)
		for(var/obj/item/I in storage_controller.contents)
			storage_controller.remove_from_storage(I, target)
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
					if(storage_controller.can_be_inserted(I))
						storage_controller.handle_item_insertion(I, null, TRUE)
		else // Single turf
			for(var/obj/item/I in target_turf.contents)
				if(storage_controller.can_be_inserted(I))
					storage_controller.handle_item_insertion(I, null, TRUE)
		chassis.occupant_message("You pick up all the items with [src]. Remaining cargo compartment capacity: [storage_controller.max_combined_w_class - length(storage_controller.contents)]")

	else // Dumping
		for(var/obj/item/I in storage_controller.contents)
			storage_controller.remove_from_storage(I, target_turf)
		chassis.occupant_message("<span class='notice'>You dump everything out of [src].")
	update_equip_info()
