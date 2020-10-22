//Hydraulic clamp, Kill clamp, Extinguisher, RCD, Mime RCD, Cable layer.

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp
	name = "hydraulic clamp"
	desc = "Equipment for engineering exosuits. Lifts objects and loads them into cargo."
	icon_state = "mecha_clamp"
	equip_cooldown = 15
	energy_drain = 10
	var/dam_force = 20
	var/obj/mecha/working/cargo_holder
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/can_attach(obj/mecha/working/M)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/attach(obj/mecha/M)
	..()
	cargo_holder = M
	return

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/detach(atom/moveto = null)
	..()
	cargo_holder = null

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/action(atom/target)
	if(!action_checks(target))
		return
	if(!cargo_holder)
		return
	if(istype(target,/obj))
		var/obj/O = target
		if(!O.anchored)
			if(cargo_holder.cargo.len < cargo_holder.cargo_capacity)
				chassis.visible_message("[chassis] lifts [target] and starts to load it into cargo compartment.")
				O.anchored = 1
				if(do_after_cooldown(target))
					cargo_holder.cargo += O
					O.loc = chassis
					O.anchored = 0
					occupant_message("<span class='notice'>[target] successfully loaded.</span>")
					log_message("Loaded [O]. Cargo compartment capacity: [cargo_holder.cargo_capacity - cargo_holder.cargo.len]")
				else
					O.anchored = initial(O.anchored)
			else
				occupant_message("<span class='warning'>Not enough room in cargo compartment!</span>")
		else
			occupant_message("<span class='warning'>[target] is firmly secured!</span>")

	else if(istype(target,/mob/living))
		var/mob/living/M = target
		if(M.stat == DEAD) return
		if(chassis.occupant.a_intent == INTENT_HARM)
			M.take_overall_damage(dam_force)
			if(!M)
				return
			M.adjustOxyLoss(round(dam_force/2))
			target.visible_message("<span class='danger'>[chassis] squeezes [target].</span>", \
								"<span class='userdanger'>[chassis] squeezes [target].</span>",\
								"<span class='italics'>You hear something crack.</span>")
			add_attack_logs(chassis.occupant, M, "Squeezed with [src] ([uppertext(chassis.occupant.a_intent)]) ([uppertext(damtype)])")
			start_cooldown()
		else
			step_away(M,chassis)
			occupant_message("<span class='notice'>You push [target] out of the way.</span>")
			chassis.visible_message("<span class='notice'>[chassis] pushes [target] out of the way.</span>")
		return 1



//This is pretty much just for the death-ripley
/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill
	name = "\improper KILL CLAMP"
	desc = "They won't know what clamped them!"
	energy_drain = 0

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill/action(atom/target)
	if(!action_checks(target)) return
	if(!cargo_holder) return
	if(istype(target,/obj))
		var/obj/O = target
		if(!O.anchored)
			if(cargo_holder.cargo.len < cargo_holder.cargo_capacity)
				chassis.visible_message("[chassis] lifts [target] and starts to load it into cargo compartment.")
				O.anchored = 1
				if(do_after_cooldown(target))
					cargo_holder.cargo += O
					O.loc = chassis
					O.anchored = 0
					occupant_message("<span class='notice'>[target] successfully loaded.</span>")
					log_message("Loaded [O]. Cargo compartment capacity: [cargo_holder.cargo_capacity - cargo_holder.cargo.len]")
				else
					O.anchored = initial(O.anchored)
			else
				occupant_message("<span class='warning'>Not enough room in cargo compartment!</span>")
		else
			occupant_message("<span class='warning'>[target] is firmly secured!</span>")

	else if(istype(target,/mob/living))
		var/mob/living/M = target
		if(M.stat == DEAD) return
		if(chassis.occupant.a_intent == INTENT_HARM)
			target.visible_message("<span class='danger'>[chassis] destroys [target] in an unholy fury.</span>",
								"<span class='userdanger'>[chassis] destroys [target] in an unholy fury.</span>")
			M.gib()
		/*if(chassis.occupant.a_intent == INTENT_DISARM)
			target.visible_message("<span class='danger'>[chassis] rips [target]'s arms off.</span>",
								"<span class='userdanger'>[chassis] rips [target]'s arms off.</span>")*/
		else
			step_away(M,chassis)
			target.visible_message("[chassis] tosses [target] like a piece of paper.")
			return 1


/obj/item/mecha_parts/mecha_equipment/extinguisher
	name = "exosuit extinguisher"
	desc = "Equipment for engineering exosuits. A rapid-firing high capacity fire extinguisher."
	icon_state = "mecha_exting"
	equip_cooldown = 5
	energy_drain = 0
	range = MECHA_MELEE | MECHA_RANGED

/obj/item/mecha_parts/mecha_equipment/extinguisher/New()
	create_reagents(1000)
	reagents.add_reagent("water", 1000)
	..()
	return

/obj/item/mecha_parts/mecha_equipment/extinguisher/action(atom/target) //copypasted from extinguisher. TODO: Rewrite from scratch.
	if(!action_checks(target) || get_dist(chassis, target)>3)
		return

	if(istype(target, /obj/structure/reagent_dispensers/watertank) && get_dist(chassis,target) <= 1)
		var/obj/structure/reagent_dispensers/watertank/WT = target
		WT.reagents.trans_to(src, 1000)
		occupant_message("<span class='notice'>Extinguisher refilled.</span>")
		playsound(chassis, 'sound/effects/refill.ogg', 50, 1, -6)
	else
		if(reagents.total_volume > 0)
			playsound(chassis, 'sound/effects/extinguish.ogg', 75, 1, -3)
			var/direction = get_dir(chassis,target)
			var/turf/T = get_turf(target)
			var/turf/T1 = get_step(T,turn(direction, 90))
			var/turf/T2 = get_step(T,turn(direction, -90))

			var/list/the_targets = list(T,T1,T2)
			spawn(0)
				for(var/a=0, a<5, a++)
					var/obj/effect/particle_effect/water/W = new /obj/effect/particle_effect/water(get_turf(chassis))
					if(!W)
						return
					var/turf/my_target = pick(the_targets)
					var/datum/reagents/R = new/datum/reagents(5)
					W.reagents = R
					R.my_atom = W
					reagents.trans_to(W,1)
					for(var/b=0, b<4, b++)
						if(!W)
							return
						step_towards(W,my_target)
						if(!W)
							return
						var/turf/W_turf = get_turf(W)
						W.reagents.reaction(W_turf)
						for(var/atom/atm in W_turf)
							W.reagents.reaction(atm)
						if(W.loc == my_target)
							break
						sleep(2)
		return 1

/obj/item/mecha_parts/mecha_equipment/extinguisher/get_equip_info()
	return "[..()] \[[src.reagents.total_volume]\]"

/obj/item/mecha_parts/mecha_equipment/extinguisher/on_reagent_change()
	return

/obj/item/mecha_parts/mecha_equipment/extinguisher/can_attach(obj/mecha/working/M)
	if(..())
		if(istype(M))
			return 1
	return 0


/obj/item/mecha_parts/mecha_equipment/rcd
	name = "Mounted RCD"
	desc = "An exosuit-mounted Rapid Construction Device. (Can be attached to: Any exosuit)"
	icon_state = "mecha_rcd"
	origin_tech = "materials=4;bluespace=3;magnets=4;powerstorage=4;engineering=4"
	equip_cooldown = 10
	energy_drain = 250
	range = MECHA_MELEE | MECHA_RANGED
	flags_2 = NO_MAT_REDEMPTION_2
	var/mode = 0 //0 - deconstruct, 1 - wall or floor, 2 - airlock.
	var/canRwall = 0
	toolspeed = 1
	usesound = 'sound/items/deconstruct.ogg'

/obj/item/mecha_parts/mecha_equipment/rcd/New()
	GLOB.rcd_list += src
	..()

/obj/item/mecha_parts/mecha_equipment/rcd/Destroy()
	GLOB.rcd_list -= src
	return ..()

/obj/item/mecha_parts/mecha_equipment/rcd/action(atom/target)
	if(istype(target, /turf/space/transit))//>implying these are ever made -Sieve
		return

	if(!istype(target, /turf) && !istype(target, /obj/machinery/door/airlock))
		target = get_turf(target)

	if(!action_checks(target) || get_dist(chassis, target)>3)
		return
	playsound(chassis, 'sound/machines/click.ogg', 50, 1)

	switch(mode)
		if(0)
			if(istype(target, /turf/simulated/wall))
				if(istype(target, /turf/simulated/wall/r_wall) && !canRwall)
					return 0
				var/turf/simulated/wall/W = target
				occupant_message("Deconstructing [target]...")
				if(do_after_cooldown(W))
					chassis.spark_system.start()
					W.ChangeTurf(/turf/simulated/floor/plating)
					playsound(W, usesound, 50, 1)
			else if(istype(target, /turf/simulated/floor))
				var/turf/simulated/floor/F = target
				occupant_message("Deconstructing [target]...")
				if(do_after_cooldown(F))
					chassis.spark_system.start()
					F.ChangeTurf(F.baseturf)
					F.air_update_turf()
					playsound(F, usesound, 50, 1)
			else if(istype(target, /obj/machinery/door/airlock))
				occupant_message("Deconstructing [target]...")
				if(do_after_cooldown(target))
					chassis.spark_system.start()
					qdel(target)
					playsound(target, usesound, 50, 1)
		if(1)
			if(istype(target, /turf/space))
				var/turf/space/S = target
				occupant_message("Building Floor...")
				if(do_after_cooldown(S))
					S.ChangeTurf(/turf/simulated/floor/plating)
					playsound(S, usesound, 50, 1)
					chassis.spark_system.start()
			else if(istype(target, /turf/simulated/floor))
				var/turf/simulated/floor/F = target
				occupant_message("Building Wall...")
				if(do_after_cooldown(F))
					F.ChangeTurf(/turf/simulated/wall)
					playsound(F, usesound, 50, 1)
					chassis.spark_system.start()
		if(2)
			if(istype(target, /turf/simulated/floor))
				occupant_message("Building Airlock...")
				if(do_after_cooldown(target))
					chassis.spark_system.start()
					var/obj/machinery/door/airlock/T = new /obj/machinery/door/airlock(target)
					T.autoclose = 1
					playsound(target, usesound, 50, 1)
					playsound(target, 'sound/effects/sparks2.ogg', 50, 1)


/obj/item/mecha_parts/mecha_equipment/rcd/Topic(href,href_list)
	..()
	if(href_list["mode"])
		mode = text2num(href_list["mode"])
		switch(mode)
			if(0)
				occupant_message("Switched RCD to Deconstruct.")
			if(1)
				occupant_message("Switched RCD to Construct.")
			if(2)
				occupant_message("Switched RCD to Construct Airlock.")

/obj/item/mecha_parts/mecha_equipment/rcd/get_equip_info()
	return "[..()] \[<a href='?src=[UID()];mode=0'>D</a>|<a href='?src=[UID()];mode=1'>C</a>|<a href='?src=[UID()];mode=2'>A</a>\]"


/obj/item/mecha_parts/mecha_equipment/mimercd
	name = "mounted MRCD"
	desc = "An exosuit-mounted Mime Rapid Construction Device. (Can be attached to: Reticence)"
	icon_state = "mecha_rcd"
	origin_tech = "materials=4;bluespace=3;magnets=4;powerstorage=4;engineering=4"
	equip_cooldown = 10
	energy_drain = 250
	range = MECHA_MELEE | MECHA_RANGED

/obj/item/mecha_parts/mecha_equipment/mimercd/can_attach(obj/mecha/combat/reticence/M)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/mimercd/action(atom/target)
	if(istype(target, /turf/space/transit))//>implying these are ever made -Sieve
		return
	if(!istype(target, /turf))
		target = get_turf(target)
	if(!action_checks(target) || get_dist(chassis, target)>3)
		return

	if(istype(target, /turf/simulated/floor))
		occupant_message("Building Wall...")
		if(do_after_cooldown(target))
			new /obj/structure/barricade/mime/mrcd(target)
			chassis.spark_system.start()



/obj/item/mecha_parts/mecha_equipment/cable_layer
	name = "cable layer"
	desc = "Equipment for engineering exosuits. Lays cable along the exosuit's path."
	icon_state = "mecha_wire"
	var/datum/event/event
	var/turf/old_turf
	var/obj/structure/cable/last_piece
	var/obj/item/stack/cable_coil/cable
	var/max_cable = 1000

/obj/item/mecha_parts/mecha_equipment/cable_layer/New()
	cable = new(src)
	cable.amount = 0
	..()

/obj/item/mecha_parts/mecha_equipment/cable_layer/can_attach(obj/mecha/working/M)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/cable_layer/attach()
	..()
	RegisterSignal(chassis, COMSIG_MOVABLE_MOVED, .proc/layCable)
	return

/obj/item/mecha_parts/mecha_equipment/cable_layer/detach()
	UnregisterSignal(chassis, COMSIG_MOVABLE_MOVED)
	return ..()

/obj/item/mecha_parts/mecha_equipment/cable_layer/action(var/obj/item/stack/cable_coil/target)
	if(!action_checks(target))
		return
	if(istype(target) && target.amount)
		var/cur_amount = cable? cable.amount : 0
		var/to_load = max(max_cable - cur_amount,0)
		if(to_load)
			to_load = min(target.amount, to_load)
			if(!cable)
				cable = new(src)
				cable.amount = 0
			cable.amount += to_load
			target.use(to_load)
			occupant_message("<span class='notice'>[to_load] meters of cable successfully loaded.</span>")
			send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
		else
			occupant_message("<span class='warning'>Reel is full.</span>")
	else
		occupant_message("<span class='warning'>Unable to load [target] - no cable found.</span>")


/obj/item/mecha_parts/mecha_equipment/cable_layer/Topic(href,href_list)
	..()
	if(href_list["toggle"])
		set_ready_state(!equip_ready)
		occupant_message("[src] [equip_ready?"dea":"a"]ctivated.")
		log_message("[equip_ready?"Dea":"A"]ctivated.")
		return
	if(href_list["cut"])
		if(cable && cable.amount)
			var/m = round(input(chassis.occupant,"Please specify the length of cable to cut","Cut cable",min(cable.amount,30)) as num, 1)
			m = min(m, cable.amount)
			if(m)
				use_cable(m)
				var/obj/item/stack/cable_coil/CC = new (get_turf(chassis))
				CC.amount = m
		else
			occupant_message("There's no more cable on the reel.")
	return

/obj/item/mecha_parts/mecha_equipment/cable_layer/get_equip_info()
	var/output = ..()
	if(output)
		return "[output] \[Cable: [cable ? cable.amount : 0] m\][(cable && cable.amount) ? "- <a href='?src=[UID()];toggle=1'>[!equip_ready?"Dea":"A"]ctivate</a>|<a href='?src=[UID()];cut=1'>Cut</a>" : null]"
	return

/obj/item/mecha_parts/mecha_equipment/cable_layer/proc/use_cable(amount)
	if(!cable || cable.amount<1)
		set_ready_state(1)
		occupant_message("Cable depleted, [src] deactivated.")
		log_message("Cable depleted, [src] deactivated.")
		return
	if(cable.amount < amount)
		occupant_message("No enough cable to finish the task.")
		return
	cable.use(amount)
	update_equip_info()
	return 1

/obj/item/mecha_parts/mecha_equipment/cable_layer/proc/reset()
	last_piece = null

/obj/item/mecha_parts/mecha_equipment/cable_layer/proc/dismantleFloor(var/turf/new_turf)
	if(istype(new_turf, /turf/simulated/floor))
		var/turf/simulated/floor/T = new_turf
		if(!istype(T, /turf/simulated/floor/plating))
			if(!T.broken && !T.burnt)
				new T.floor_tile(T)
			T.make_plating()
	return !new_turf.intact

/obj/item/mecha_parts/mecha_equipment/cable_layer/proc/layCable(obj/mecha/M, atom/OldLoc, Dir, Forced = FALSE)
	var/turf/new_turf = get_turf(M)
	if(equip_ready || !istype(new_turf) || !dismantleFloor(new_turf))
		return reset()
	var/fdirn = turn(Dir, 180)
	for(var/obj/structure/cable/LC in new_turf)		// check to make sure there's not a cable there already
		if(LC.d1 == fdirn || LC.d2 == fdirn)
			return reset()
	if(!use_cable(1))
		return reset()
	var/obj/structure/cable/NC = new(new_turf)
	NC.cable_color("red")
	NC.d1 = 0
	NC.d2 = fdirn
	NC.updateicon()

	var/datum/powernet/PN
	if(last_piece && last_piece.d2 != Dir)
		last_piece.d1 = min(last_piece.d2, Dir)
		last_piece.d2 = max(last_piece.d2, Dir)
		last_piece.updateicon()
		PN = last_piece.powernet

	if(!PN)
		PN = new()
	NC.powernet = PN
	PN.cables += NC
	NC.mergeConnectedNetworks(NC.d2)

	//NC.mergeConnectedNetworksOnTurf()
	last_piece = NC
	return TRUE
