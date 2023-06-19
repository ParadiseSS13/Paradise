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

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/can_attach(obj/mecha/M)
	if(..())
		if(istype(M, /obj/mecha/working) || istype(M, /obj/mecha/combat/lockersyndie))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/attach_act(obj/mecha/M)
	cargo_holder = M

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/detach_act()
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
		if(M.stat == DEAD && !issilicon(M))
			return
		if(M.stat == DEAD && issilicon(M))
			if(!M.anchored)
				if(cargo_holder.cargo.len < cargo_holder.cargo_capacity)
					chassis.visible_message("[chassis] lifts [target] and starts to load it into cargo compartment.")
					M.anchored = 1
					if(do_after_cooldown(target))
						cargo_holder.cargo += M
						M.loc = chassis
						M.anchored = 0
						occupant_message("<span class='notice'>[target] successfully loaded.</span>")
						log_message("Loaded [M]. Cargo compartment capacity: [cargo_holder.cargo_capacity - cargo_holder.cargo.len]")
					else
						M.anchored = initial(M.anchored)
				else
					occupant_message("<span class='warning'>Not enough room in cargo compartment!</span>")
			else
				occupant_message("<span class='warning'>[target] is buckled to something!</span>")
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
			if(issilicon(M) && M.stat == DEAD)
				return
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

/obj/item/mecha_parts/mecha_equipment/rcd
	name = "Mounted RCD"
	desc = "An exosuit-mounted Rapid Construction Device. (Can be attached to: Any exosuit)"
	icon_state = "mecha_rcd"
	origin_tech = "materials=4;bluespace=3;magnets=4;powerstorage=4;engineering=4"
	equip_cooldown = 10
	energy_drain = 300
	range = MECHA_MELEE | MECHA_RANGED
	flags_2 = NO_MAT_REDEMPTION_2
	var/obj/item/rcd/mecha_ref/rcd_holder
	toolspeed = 1
	usesound = 'sound/items/deconstruct.ogg'

/obj/item/mecha_parts/mecha_equipment/rcd/New()
	GLOB.rcd_list += src
	rcd_holder = new(rcd_holder)
	rcd_holder.power_use_multiplier = energy_drain
	rcd_holder.canRwall = TRUE
	..()

/obj/item/mecha_parts/mecha_equipment/rcd/Destroy()
	GLOB.rcd_list -= src
	rcd_holder.chassis = null
	qdel(rcd_holder)
	return ..()

/obj/item/mecha_parts/mecha_equipment/rcd/attach_act(obj/mecha/M)
	rcd_holder.chassis = M

/obj/item/mecha_parts/mecha_equipment/rcd/action(atom/target)
	if(!action_checks(target) || get_dist(chassis, target)>3)
		return
	var/area/check_area = get_area(target)
	if(check_area?.type in rcd_holder.areas_blacklist)
		to_chat(chassis.occupant, span_warning("Something prevents you from using [rcd_holder] in here..."))
		return
	playsound(chassis, 'sound/machines/click.ogg', 50, 1)
	chassis.can_move = world.time + 2 SECONDS 	// We don't move while we build
	var/rcd_act_result = target.rcd_act(chassis.occupant, rcd_holder, rcd_holder.mode)
	if(rcd_act_result == RCD_NO_ACT) //if our rcd_act was not implemented/impossible to do - we can move again
		chassis.can_move = 0

/obj/item/mecha_parts/mecha_equipment/rcd/Topic(href,href_list)
	..()
	if(href_list["mode"])
		rcd_holder.mode = href_list["mode"]
		switch(rcd_holder.mode)
			if(RCD_MODE_DECON)
				occupant_message("Switched RCD to Deconstruct.")
			if(RCD_MODE_TURF)
				occupant_message("Switched RCD to Construct.")
			if(RCD_MODE_AIRLOCK)
				occupant_message("Switched RCD to Construct Airlock.")
			if(RCD_MODE_WINDOW)
				occupant_message("Switched RCD to Construct Windows.")
			if(RCD_MODE_FIRELOCK)
				occupant_message("Switched RCD to Construct Firelock.")

/obj/item/mecha_parts/mecha_equipment/rcd/get_module_equip_info()
	return " \[<a href='?src=[UID()];mode=[RCD_MODE_DECON]'>D</a>|<a href='?src=[UID()];mode=[RCD_MODE_TURF]'>C</a>|<a href='?src=[UID()];mode=[RCD_MODE_AIRLOCK]'>A</a>|<a href='?src=[UID()];mode=[RCD_MODE_WINDOW]'>W</a>|<a href='?src=[UID()];mode=[RCD_MODE_FIRELOCK]'>F</a>\]"

/obj/item/mecha_parts/mecha_equipment/mimercd
	name = "mounted MRCD"
	desc = "An exosuit-mounted Mime Rapid Construction Device. (Can be attached to: Reticence)"
	icon_state = "mecha_rcd"
	origin_tech = "materials=4;bluespace=3;magnets=4;powerstorage=4;engineering=4"
	equip_cooldown = 10
	energy_drain = 250
	range = MECHA_MELEE | MECHA_RANGED

/obj/item/mecha_parts/mecha_equipment/mimercd/can_attach(obj/mecha/combat/M)
	if(..())
		if(istype(M, /obj/mecha/combat/reticence) || istype(M, /obj/mecha/combat/lockersyndie))
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

/obj/item/mecha_parts/mecha_equipment/multimodule
	name = "multi module"
	var/list/modules = list()
	var/obj/item/mecha_parts/mecha_equipment/targeted_module
	range = MECHA_MELEE | MECHA_RANGED

/obj/item/mecha_parts/mecha_equipment/multimodule/New()
	..()
	for(var/module in modules)
		var/obj/item/mecha_parts/mecha_equipment/new_module = new module(src)
		modules[module] = new_module

/obj/item/mecha_parts/mecha_equipment/multimodule/is_ranged()//add a distance restricted equipment. Why not?
	return targeted_module?.is_ranged()

/obj/item/mecha_parts/mecha_equipment/multimodule/is_melee()
	return targeted_module?.is_melee()

/obj/item/mecha_parts/mecha_equipment/multimodule/can_attach(obj/mecha/M)
	if(!..())
		return FALSE
	for(var/obj/item/mecha_parts/mecha_equipment/module in modules)
		if(!module.can_attach(M))
			return FALSE
	return TRUE


/obj/item/mecha_parts/mecha_equipment/multimodule/attach_act(obj/mecha/M)
	for(var/thing in modules)
		var/obj/item/mecha_parts/mecha_equipment/module = modules[thing]
		module.chassis = src.chassis
		module.attach_act(M)

/obj/item/mecha_parts/mecha_equipment/multimodule/detach_act()
	for(var/thing in modules)
		var/obj/item/mecha_parts/mecha_equipment/module = modules[thing]
		module.detach_act()
		module.chassis = null
		module.set_ready_state(TRUE)

/obj/item/mecha_parts/mecha_equipment/multimodule/action(atom/target)
	targeted_module.action(target)
	update_equip_info()


/obj/item/mecha_parts/mecha_equipment/multimodule/get_equip_info()
	. = "<dt>[..()]"

/obj/item/mecha_parts/mecha_equipment/multimodule/get_module_equip_info()
	. = "</dt>"
	for(var/thing in modules)
		var/obj/item/mecha_parts/mecha_equipment/module = modules[thing]
		if(module == targeted_module)
			. += "<dd> [module.name] [module.get_module_equip_info()]</dd>"
		else
			. += "<dd><a href='?src=[UID()];module=[module.UID()]'>Select [module.name]</a> [module.get_module_equip_info()]</dd>"

/obj/item/mecha_parts/mecha_equipment/multimodule/Topic(href, href_list)
	..()
	if(href_list["module"])
		targeted_module = locateUID(href_list["module"])
		update_equip_info()
		occupant_message("Switched to [targeted_module]")

/obj/item/mecha_parts/mecha_equipment/multimodule/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/storage/bible))
		var/obj/item/mecha_parts/mecha_equipment/extinguisher/extinguisher = locate() in src
		if(extinguisher?.reagents && user.mind?.isholy)
			var/obj/item/storage/bible/bible = I
			bible.add_holy_water(user, extinguisher)

/obj/item/mecha_parts/mecha_equipment/multimodule/atmos_module
	name = "Atmos module"
	desc = "Equipment for engineering exosuits. Lays cable along the exosuit's path."
	icon_state = "mecha_wire"
	modules = list(/obj/item/mecha_parts/mecha_equipment/cable_layer,
					/obj/item/mecha_parts/mecha_equipment/extinguisher,
					/obj/item/mecha_parts/mecha_equipment/holowall)

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
	cable = new(src, 0)
	..()

/obj/item/mecha_parts/mecha_equipment/cable_layer/can_attach(obj/mecha/M)
	if(..())
		if(istype(M, /obj/mecha/working) || istype(M, /obj/mecha/combat/lockersyndie))
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/cable_layer/attach_act()
	RegisterSignal(chassis, COMSIG_MOVABLE_MOVED, PROC_REF(layCable))

/obj/item/mecha_parts/mecha_equipment/cable_layer/detach_act()
	UnregisterSignal(chassis, COMSIG_MOVABLE_MOVED)

/obj/item/mecha_parts/mecha_equipment/cable_layer/action(var/obj/item/stack/cable_coil/target)
	if(!action_checks(target))
		return
	if(istype(target) && target.amount)
		var/cur_amount = cable? cable.amount : 0
		var/to_load = max(max_cable - cur_amount,0)
		if(to_load)
			to_load = min(target.amount, to_load)
			if(!cable)
				cable = new(src, 0)
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
		update_equip_info()
		return
	if(href_list["cut"])
		if(cable && cable.amount)
			var/m = round(input(chassis.occupant,"Please specify the length of cable to cut","Cut cable",min(cable.amount,30)) as num, 1)
			m = min(m, cable.amount)
			if(m)
				use_cable(m)
				new /obj/item/stack/cable_coil(get_turf(chassis), m)
		else
			occupant_message("There's no more cable on the reel.")
	return

/obj/item/mecha_parts/mecha_equipment/cable_layer/get_module_equip_info()
	return " \[Cable: [cable ? cable.amount : 0] m\][(cable && cable.amount) ? "- <a href='?src=[UID()];toggle=1'>[!equip_ready?"Dea":"A"]ctivate</a>|<a href='?src=[UID()];cut=1'>Cut</a>" : null]"

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
	update_equip_info()
	return TRUE

/obj/item/mecha_parts/mecha_equipment/extinguisher
	name = "extinguisher"
	desc = "Equipment for engineering exosuits. A rapid-firing high capacity fire extinguisher."
	icon_state = "mecha_exting"
	equip_cooldown = 5
	energy_drain = 0
	range = MECHA_MELEE | MECHA_RANGED

/obj/item/mecha_parts/mecha_equipment/extinguisher/New()
	create_reagents(1000)
	reagents.add_reagent("water", 1000)
	..()

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
				for(var/a = 0 to 5)
					var/obj/effect/particle_effect/water/W = new (get_turf(chassis))
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
		return TRUE

/obj/item/mecha_parts/mecha_equipment/extinguisher/get_module_equip_info()
	return " \[[src.reagents.total_volume]\]"

/obj/item/mecha_parts/mecha_equipment/extinguisher/on_reagent_change()
	return

/obj/item/mecha_parts/mecha_equipment/extinguisher/can_attach(obj/mecha/M)
	if(..())
		if(istype(M, /obj/mecha/working) || istype(M, /obj/mecha/combat/lockersyndie))
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/holowall
	name = "holowall module"
	desc = "Equipment for engineering exosuits. With it, you can build atmos holographic barriers."
	icon_state = "mecha_wholegen"
	energy_drain = 100
	equip_cooldown = 5
	range = MECHA_MELEE | MECHA_RANGED
	var/max_barriers = 5
	var/list/barriers = list()
	var/creation_time = 0 //time to create a holosbarriers in deciseconds.
	var/holocreator_busy = FALSE //to prevent placing multiple holo barriers at once

/obj/item/mecha_parts/mecha_equipment/holowall/action(atom/target) //copypasted from extinguisher. TODO: Rewrite from scratch.
	if(!action_checks(target) || get_dist(chassis, target) > 5)
		return

	if(!is_faced_target(target))
		return FALSE

	var/turf/T = get_turf(target)
	var/obj/structure/holosign/barrier/atmos/H = locate() in T
	if(H)
		occupant_message("<span class='notice'>You use [src] to deactivate [H].</span>")
		qdel(H)
	else
		if(!is_blocked_turf(T, TRUE)) //can't put holograms on a tile that has dense stuff
			if(holocreator_busy)
				occupant_message("<span class='notice'>[src] is busy creating a hologram.</span>")
				return
			if(length(barriers) < max_barriers)
				playsound(src.loc, 'sound/machines/click.ogg', 20, 1)
				if(creation_time)
					holocreator_busy = TRUE
					if(!do_after_mecha(target, creation_time))
						holocreator_busy = FALSE
						return
					holocreator_busy = FALSE
					if(length(barriers) >= max_barriers)
						return
					if(is_blocked_turf(T, TRUE)) //don't try to sneak dense stuff on our tile during the wait.
						return
				H = new /obj/structure/holosign/barrier/atmos(T, src)
				chassis.use_power(energy_drain)
				occupant_message("<span class='notice'>You create [H] with [src].</span>")
			else
				occupant_message("<span class='notice'>[src] is projecting at max capacity!</span>")

/obj/item/mecha_parts/mecha_equipment/holowall/get_module_equip_info()
	return " \[Holobarriers left: [max_barriers - length(barriers)]|<a href='?src=[UID()];remove_all=1'>Return all barriers</a>\]"

/obj/item/mecha_parts/mecha_equipment/holowall/Topic(href,href_list)
	..()
	if(href_list["remove_all"])
		if(length(barriers))
			for(var/H in barriers)
				qdel(H)
			occupant_message("<span class='notice'>You clear all active holobarriers.</span>")

/obj/item/mecha_parts/mecha_equipment/holowall/can_attach(obj/mecha/M)
	if(..())
		if(istype(M, /obj/mecha/working) || istype(M, /obj/mecha/combat/lockersyndie))
			return TRUE
	return FALSE
