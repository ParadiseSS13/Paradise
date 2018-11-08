// Drill, Diamond drill, Mining scanner

/obj/item/mecha_parts/mecha_equipment/drill
	name = "exosuit drill"
	desc = "Equipment for engineering and combat exosuits. This is the drill that'll pierce the heavens!"
	icon_state = "mecha_drill"
	equip_cooldown = 30
	energy_drain = 10
	force = 15

/obj/item/mecha_parts/mecha_equipment/drill/action(atom/target)
	if(!action_checks(target))
		return
	if(istype(target, /turf/space))
		return
	if(isobj(target))
		var/obj/target_obj = target
		if(target_obj.unacidable && !istype(target_obj, /obj/mecha))
			occupant_message("<span class='danger'>[target] is too durable to drill through.</span>")
			return
	target.visible_message("<span class='warning'>[chassis] starts to drill [target].</span>",
					"<span class='userdanger'>[chassis] starts to drill [target]...</span>",
					blind_message = "<span class='italics'>You hear drilling.</span>")
	if(do_after_cooldown(target))
		if(isturf(target))
			var/turf/T = target
			T.drill_act(src)
		else
			log_message("Drilled through [target]")
			if(isliving(target))
				if(istype(src , /obj/item/mecha_parts/mecha_equipment/drill/diamonddrill))
					drill_mob(target, chassis.occupant, 120)
				else
					drill_mob(target, chassis.occupant)
			else
				target.ex_act(2)

/turf/proc/drill_act(obj/item/mecha_parts/mecha_equipment/drill/drill)
	return

/turf/simulated/floor/drill_act(obj/item/mecha_parts/mecha_equipment/drill/drill)
	ex_act(1)

/turf/simulated/wall/drill_act(obj/item/mecha_parts/mecha_equipment/drill/drill)
	ex_act(2)

/turf/simulated/wall/r_wall/drill_act(obj/item/mecha_parts/mecha_equipment/drill/drill)
	if(istype(drill, /obj/item/mecha_parts/mecha_equipment/drill/diamonddrill))
		if(drill.do_after_cooldown(src))//To slow down how fast mechs can drill through the station
			drill.log_message("Drilled through [src]")
			ex_act(3)
	else
		drill.occupant_message("<span class='danger'>[src] is too durable to drill through.</span>")

/turf/simulated/mineral/drill_act(obj/item/mecha_parts/mecha_equipment/drill/drill)
	for(var/turf/simulated/mineral/M in range(drill.chassis, 1))
		if(get_dir(drill.chassis, M) & drill.chassis.dir)
			M.gets_drilled()
	drill.log_message("Drilled through [src]")
	drill.move_ores()

/turf/simulated/floor/plating/airless/asteroid/drill_act(obj/item/mecha_parts/mecha_equipment/drill/drill)
	if(istype(drill, /obj/item/mecha_parts/mecha_equipment/drill/diamonddrill))
		for(var/turf/simulated/floor/plating/airless/asteroid/M in range(1, src))
			M.gets_drilled()
	else
		for(var/turf/simulated/floor/plating/airless/asteroid/M in range(1, drill.chassis))
			if(get_dir(drill.chassis, M) & drill.chassis.dir)
				M.gets_drilled()
	drill.log_message("Drilled through [src]")
	drill.move_ores()

/obj/item/mecha_parts/mecha_equipment/drill/proc/move_ores()
	if(locate(/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp) in chassis.equipment)
		var/obj/structure/ore_box/ore_box = locate(/obj/structure/ore_box) in chassis:cargo
		if(ore_box)
			for(var/obj/item/stack/ore/ore in range(1, chassis))
				if(get_dir(chassis, ore) & chassis.dir)
					ore.Move(ore_box)

/obj/item/mecha_parts/mecha_equipment/drill/can_attach(obj/mecha/M)
	if(..())
		if(istype(M, /obj/mecha/working) || istype(M, /obj/mecha/combat))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/drill/proc/drill_mob(mob/living/target, mob/user, var/drill_damage=80)
	target.visible_message("<span class='danger'>[chassis] drills [target] with [src].</span>", \
						"<span class='userdanger'>[chassis] drills [target] with [src].</span>")
	add_attack_logs(user, target, "DRILLED with [src] (INTENT: [uppertext(user.a_intent)]) (DAMTYPE: [uppertext(damtype)])")
	if(target.stat == DEAD && target.butcher_results)
		target.harvest(chassis) // Butcher the mob with our drill.
	else
		target.take_organ_damage(drill_damage)

	if(target)
		target.Paralyse(10)


/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill
	name = "diamond-tipped exosuit drill"
	desc = "Equipment for engineering and combat exosuits. This is an upgraded version of the drill that'll pierce the heavens!"
	icon_state = "mecha_diamond_drill"
	origin_tech = "materials=4;engineering=4"
	equip_cooldown = 20
	force = 15


/obj/item/mecha_parts/mecha_equipment/mining_scanner
	name = "exosuit mining scanner"
	desc = "Equipment for engineering and combat exosuits. It will automatically check surrounding rock for useful minerals."
	icon_state = "mecha_analyzer"
	selectable = 0
	equip_cooldown = 30
	var/scanning = 0

/obj/item/mecha_parts/mecha_equipment/mining_scanner/attach(obj/mecha/M)
	. = ..()
	processing_objects.Add(src)
	M.occupant_sight_flags |= SEE_TURFS
	if(M.occupant)
		M.occupant.update_sight()

/obj/item/mecha_parts/mecha_equipment/mining_scanner/detach()
	chassis.occupant_sight_flags &= ~SEE_TURFS
	processing_objects.Remove(src)
	if(chassis.occupant)
		chassis.occupant.update_sight()
	return ..()

/obj/item/mecha_parts/mecha_equipment/mining_scanner/process()
	if(!loc)
		qdel(src)
	if(scanning)
		return
	if(istype(loc,/obj/mecha/working))
		var/obj/mecha/working/mecha = loc
		if(!mecha.occupant)
			return
		var/list/occupant = list()
		occupant |= mecha.occupant
		scanning = 1
		mineral_scan_pulse(occupant,get_turf(loc))
		spawn(equip_cooldown)
			scanning = 0
