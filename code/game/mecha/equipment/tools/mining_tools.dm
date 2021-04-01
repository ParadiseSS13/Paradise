
// Drill, Diamond drill, Mining scanner

#define DRILL_BASIC 1
#define DRILL_HARDENED 2

/obj/item/mecha_parts/mecha_equipment/drill
	name = "exosuit drill"
	desc = "Equipment for engineering and combat exosuits. This is the drill that'll pierce the heavens!"
	icon_state = "mecha_drill"
	equip_cooldown = 15
	energy_drain = 10
	force = 15
	harmful = TRUE
	sharp = TRUE
	var/drill_delay = 7
	var/drill_level = DRILL_BASIC

/obj/item/mecha_parts/mecha_equipment/drill/action(atom/target)
	if(!action_checks(target))
		return
	if(isspaceturf(target))
		return
	if(isobj(target))
		var/obj/target_obj = target
		if(target_obj.resistance_flags & UNACIDABLE)
			return
	target.visible_message("<span class='warning'>[chassis] starts to drill [target].</span>",
					"<span class='userdanger'>[chassis] starts to drill [target]...</span>",
					 "<span class='italics'>You hear drilling.</span>")

	if(do_after_cooldown(target))
		set_ready_state(FALSE)
		log_message("Started drilling [target]")
		if(isturf(target))
			var/turf/T = target
			T.drill_act(src)
			set_ready_state(TRUE)
			return
		while(do_after_mecha(target, drill_delay))
			if(isliving(target))
				drill_mob(target, chassis.occupant)
				playsound(src, 'sound/mecha/mechdrill.ogg', 40, TRUE)
			else if(isobj(target))
				var/obj/O = target
				O.take_damage(15, BRUTE, 0, FALSE, get_dir(chassis, target))
				playsound(src, 'sound/mecha/mechdrill.ogg', 40, TRUE)
			else
				set_ready_state(TRUE)
				return
		set_ready_state(TRUE)

/turf/proc/drill_act(obj/item/mecha_parts/mecha_equipment/drill/drill)
	return

/turf/simulated/wall/drill_act(obj/item/mecha_parts/mecha_equipment/drill/drill)
	if(drill.do_after_mecha(src, 60 / drill.drill_level))
		drill.log_message("Drilled through [src]")
		dismantle_wall(TRUE, FALSE)

/turf/simulated/wall/r_wall/drill_act(obj/item/mecha_parts/mecha_equipment/drill/drill)
	if(drill.drill_level >= DRILL_HARDENED)
		if(drill.do_after_mecha(src, 120 / drill.drill_level))
			drill.log_message("Drilled through [src]")
			dismantle_wall(TRUE, FALSE)
	else
		drill.occupant_message("<span class='danger'>[src] is too durable to drill through.</span>")

/turf/simulated/mineral/drill_act(obj/item/mecha_parts/mecha_equipment/drill/drill)
	for(var/turf/simulated/mineral/M in range(drill.chassis, 1))
		if(get_dir(drill.chassis, M) & drill.chassis.dir)
			M.gets_drilled()
	drill.log_message("Drilled through [src]")
	drill.move_ores()

/turf/simulated/floor/plating/asteroid/drill_act(obj/item/mecha_parts/mecha_equipment/drill/drill)
	for(var/turf/simulated/floor/plating/asteroid/M in range(1, drill.chassis))
		if((get_dir(drill.chassis, M) & drill.chassis.dir) && !M.dug)
			M.getDug()
	drill.log_message("Drilled through [src]")
	drill.move_ores()

/obj/item/mecha_parts/mecha_equipment/drill/proc/move_ores()
	if((locate(/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp) in chassis.equipment) && istype(chassis, /obj/mecha/working/ripley))
		var/obj/mecha/working/ripley/R = chassis //we could assume that it's a ripley because it has a clamp, but that's ~unsafe~ and ~bad practice~
		R.collect_ore()

/obj/item/mecha_parts/mecha_equipment/drill/can_attach(obj/mecha/M)
	if(..())
		if(istype(M, /obj/mecha/working) || istype(M, /obj/mecha/combat))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/drill/proc/drill_mob(mob/living/target, mob/user)
	target.visible_message("<span class='danger'>[chassis] is drilling [target] with [src]!</span>",
						"<span class='userdanger'>[chassis] is drilling you with [src]!</span>")
	add_attack_logs(user, target, "DRILLED with [src] ([uppertext(user.a_intent)]) ([uppertext(damtype)])")
	if(target.stat == DEAD && target.getBruteLoss() >= 200)
		add_attack_logs(user, target, "gibbed")
		if(LAZYLEN(target.butcher_results))
			target.harvest(chassis) // Butcher the mob with our drill.
		else
			target.gib()
	else
		var/splatter_dir = get_dir(chassis, target)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			var/obj/item/organ/external/target_part = H.get_organ(ran_zone("chest"))
			H.apply_damage(10, BRUTE, "chest", H.run_armor_check(target_part, "melee"))

			//blood splatters
			blood_color = H.dna.species.blood_color

			new /obj/effect/temp_visual/dir_setting/bloodsplatter(H.drop_location(), splatter_dir, blood_color)

					//organs go everywhere
			if(target_part && prob(10 * drill_level))
				target_part.droplimb()
		else
			target.adjustBruteLoss(10)
			if(isalien(target))
				new /obj/effect/temp_visual/dir_setting/bloodsplatter/xenosplatter(target.drop_location(), splatter_dir)

/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill
	name = "diamond-tipped exosuit drill"
	desc = "Equipment for engineering and combat exosuits. This is an upgraded version of the drill that'll pierce the heavens!"
	icon_state = "mecha_diamond_drill"
	origin_tech = "materials=4;engineering=4"
	equip_cooldown = 10
	drill_delay = 4
	drill_level = DRILL_HARDENED
	force = 15


/obj/item/mecha_parts/mecha_equipment/mining_scanner
	name = "exosuit mining scanner"
	desc = "Equipment for engineering and combat exosuits. It will automatically check surrounding rock for useful minerals."
	icon_state = "mecha_analyzer"
	selectable = 0
	equip_cooldown = 15
	var/scanning_time = 0

/obj/item/mecha_parts/mecha_equipment/mining_scanner/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/item/mecha_parts/mecha_equipment/mining_scanner/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/mining_scanner/process()
	if(!loc)
		STOP_PROCESSING(SSfastprocess, src)
		qdel(src)
	if(istype(loc, /obj/mecha/working) && scanning_time <= world.time)
		var/obj/mecha/working/mecha = loc
		if(!mecha.occupant)
			return
		scanning_time = world.time + equip_cooldown
		mineral_scan_pulse(get_turf(src))

#undef DRILL_BASIC
#undef DRILL_HARDENED
