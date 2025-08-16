
//Hydraulic clamp, Kill clamp, Extinguisher, RCD, Mime RCD, Cable layer.

#define MECH_RCD_MODE_DECONSTRUCT 0
#define MECH_RCD_MODE_WALL_OR_FLOOR 1
#define MECH_RCD_MODE_AIRLOCK 2

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp
	name = "hydraulic clamp"
	desc = "Equipment for engineering exosuits. Lifts objects and loads them into cargo."
	icon_state = "mecha_clamp"
	equip_cooldown = 15
	energy_drain = 10
	var/dam_force = 20
	var/obj/mecha/working/ripley/cargo_holder
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/can_attach(obj/mecha/working/ripley/M)
	if(..())
		if(istype(M))
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/attach(obj/mecha/M)
	..()
	cargo_holder = M

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/detach(atom/moveto = null)
	..()
	cargo_holder = null

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/action(atom/target)
	if(!action_checks(target))
		return
	if(!cargo_holder)
		return
	if(isobj(target))
		var/obj/O = target
		if(istype(target, /obj/machinery/atmospherics/supermatter_crystal)) //No, you can't pick up the SM with this you moron, did you think you were clever?
			var/obj/mecha/working/ripley/R = chassis
			QDEL_LIST_CONTENTS(R.cargo) //We don't want to drop cargo that just spam hits the SM, let's delete it
			occupant_message("<span class='userdanger'>You realise in horror what you have done as [chassis] starts warping around you!</span>")
			chassis.occupant.dust()
			target.Bumped(chassis)
			return
		if(O.anchored)
			occupant_message("<span class='warning'>[target] is firmly secured!</span>")
			return
		if(length(cargo_holder.cargo) >= cargo_holder.cargo_capacity)
			occupant_message("<span class='warning'>Not enough room in cargo compartment!</span>")
			return
		chassis.visible_message("<span class='notice'>[chassis] lifts [target] and starts to load it into cargo compartment.</span>")
		var/anchor_state_before_load = O.anchored
		O.anchored = TRUE
		if(!do_after_cooldown(target))
			O.anchored = anchor_state_before_load
			return
		cargo_holder.cargo += O
		O.forceMove(chassis)
		O.anchored = FALSE
		occupant_message("<span class='notice'>[target] was successfully loaded.</span>")
		log_message("Loaded [O]. Cargo compartment capacity: [cargo_holder.cargo_capacity - length(cargo_holder.cargo)]")
		return

	if(isliving(target))
		var/mob/living/M = target
		if(M.stat == DEAD)
			return
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
			return
		step_away(M, chassis)
		occupant_message("<span class='notice'>You push [target] out of the way.</span>")
		chassis.visible_message("<span class='notice'>[chassis] pushes [target] out of the way.</span>")


//This is pretty much just for the death-ripley
/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill
	name = "\improper KILL CLAMP"
	desc = "They won't know what clamped them!"
	energy_drain = 0

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill/action(atom/target)
	if(!action_checks(target)) return
	if(!cargo_holder) return
	if(isobj(target))
		var/obj/O = target
		if(!O.anchored)
			if(length(cargo_holder.cargo) < cargo_holder.cargo_capacity)
				chassis.visible_message("[chassis] lifts [target] and starts to load it into cargo compartment.")
				O.anchored = TRUE
				if(do_after_cooldown(target))
					cargo_holder.cargo += O
					O.forceMove(chassis)
					O.anchored = FALSE
					occupant_message("<span class='notice'>[target] successfully loaded.</span>")
					log_message("Loaded [O]. Cargo compartment capacity: [cargo_holder.cargo_capacity - length(cargo_holder.cargo)]")
				else
					O.anchored = initial(O.anchored)
			else
				occupant_message("<span class='warning'>Not enough room in cargo compartment!</span>")
		else
			occupant_message("<span class='warning'>[target] is firmly secured!</span>")

	else if(isliving(target))
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
			return


/obj/item/mecha_parts/mecha_equipment/extinguisher
	name = "exosuit extinguisher"
	desc = "Equipment for engineering exosuits. A rapid-firing high capacity fire extinguisher."
	icon_state = "mecha_exting"
	equip_cooldown = 5
	range = MECHA_MELEE | MECHA_RANGED

/obj/item/mecha_parts/mecha_equipment/extinguisher/Initialize(mapload)
	. = ..()
	create_reagents(1000)
	reagents.add_reagent("water", 1000)

/obj/item/mecha_parts/mecha_equipment/extinguisher/action(atom/target) //copypasted from extinguisher. TODO: Rewrite from scratch.
	if(!action_checks(target) || get_dist(chassis, target)>3)
		return

	if(istype(target, /obj/structure/reagent_dispensers/watertank) && get_dist(chassis,target) <= 1)
		var/obj/structure/reagent_dispensers/watertank/WT = target
		WT.reagents.trans_to(src, 1000)
		occupant_message("<span class='notice'>Extinguisher refilled.</span>")
		playsound(chassis, 'sound/effects/refill.ogg', 50, TRUE, -6)
	else
		if(reagents.total_volume > 0)
			playsound(chassis, 'sound/effects/extinguish.ogg', 75, TRUE, -3)
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
		return

/obj/item/mecha_parts/mecha_equipment/extinguisher/get_equip_info()
	return "[..()] \[[src.reagents.total_volume]\]"

/obj/item/mecha_parts/mecha_equipment/extinguisher/on_reagent_change()
	return

/obj/item/mecha_parts/mecha_equipment/extinguisher/can_attach(obj/mecha/working/M)
	if(..())
		if(istype(M))
			return TRUE
	return FALSE


/obj/item/mecha_parts/mecha_equipment/rcd
	name = "mounted RCD"
	desc = "An exosuit-mounted Rapid Construction Device. (Can be attached to: Any exosuit)"
	icon_state = "mecha_rcd"
	origin_tech = "materials=4;bluespace=3;magnets=4;powerstorage=4;engineering=4"
	equip_cooldown = 10
	energy_drain = 250
	range = MECHA_MELEE | MECHA_RANGED
	flags_2 = NO_MAT_REDEMPTION_2
	var/mode = MECH_RCD_MODE_DECONSTRUCT
	var/can_rwall = 0
	usesound = 'sound/items/deconstruct.ogg'

/obj/item/mecha_parts/mecha_equipment/rcd/Initialize(mapload)
	. = ..()
	GLOB.rcd_list += src

/obj/item/mecha_parts/mecha_equipment/rcd/Destroy()
	GLOB.rcd_list -= src
	return ..()

/obj/item/mecha_parts/mecha_equipment/rcd/action(atom/target)
	if(istype(target, /turf/space/transit))//>implying these are ever made -Sieve
		return

	if(!isturf(target) && !istype(target, /obj/machinery/door/airlock))
		target = get_turf(target)

	if(!action_checks(target) || get_dist(chassis, target)>3)
		return
	playsound(chassis, 'sound/machines/click.ogg', 50, 1)

	switch(mode)
		if(MECH_RCD_MODE_DECONSTRUCT)
			if(iswallturf(target))
				if((isreinforcedwallturf(target) && !can_rwall) || istype(target, /turf/simulated/wall/indestructible))
					return 0
				var/turf/simulated/wall/W = target
				occupant_message("Deconstructing [target]...")
				if(do_after_cooldown(W))
					chassis.spark_system.start()
					W.ChangeTurf(/turf/simulated/floor/plating)
					playsound(W, usesound, 50, 1)
			else if(isfloorturf(target))
				var/turf/simulated/floor/F = target
				occupant_message("Deconstructing [target]...")
				if(do_after_cooldown(F))
					chassis.spark_system.start()
					F.ChangeTurf(F.baseturf)
					F.recalculate_atmos_connectivity()
					playsound(F, usesound, 50, 1)
			else if(istype(target, /obj/machinery/door/airlock))
				occupant_message("Deconstructing [target]...")
				if(do_after_cooldown(target))
					chassis.spark_system.start()
					qdel(target)
					playsound(target, usesound, 50, 1)
		if(MECH_RCD_MODE_WALL_OR_FLOOR)
			if(isspaceturf(target) || ischasm(target))
				var/turf/space/S = target
				occupant_message("Building Floor...")
				if(do_after_cooldown(S))
					S.ChangeTurf(/turf/simulated/floor/plating)
					playsound(S, usesound, 50, 1)
					chassis.spark_system.start()
			else if(isfloorturf(target))
				var/turf/simulated/floor/F = target
				occupant_message("Building Wall...")
				if(do_after_cooldown(F))
					F.ChangeTurf(/turf/simulated/wall)
					playsound(F, usesound, 50, 1)
					chassis.spark_system.start()
		if(MECH_RCD_MODE_AIRLOCK)
			if(isfloorturf(target))
				occupant_message("Building Airlock...")
				if(do_after_cooldown(target))
					chassis.spark_system.start()
					var/obj/machinery/door/airlock/T = new /obj/machinery/door/airlock(target)
					T.autoclose = TRUE
					playsound(target, usesound, 50, 1)
					playsound(target, 'sound/effects/sparks2.ogg', 50, 1)


/obj/item/mecha_parts/mecha_equipment/rcd/Topic(href,href_list)
	if(..())
		return
	if(href_list["mode"])
		mode = text2num(href_list["mode"])
		switch(mode)
			if(MECH_RCD_MODE_DECONSTRUCT)
				occupant_message("Switched RCD to Deconstruct.")
			if(MECH_RCD_MODE_WALL_OR_FLOOR)
				occupant_message("Switched RCD to Construct.")
			if(MECH_RCD_MODE_AIRLOCK)
				occupant_message("Switched RCD to Construct Airlock.")

/obj/item/mecha_parts/mecha_equipment/rcd/get_equip_info()
	return "[..()] \[<a href='byond://?src=[UID()];mode=0'>D</a>|<a href='byond://?src=[UID()];mode=1'>C</a>|<a href='byond://?src=[UID()];mode=2'>A</a>\]"


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
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/mimercd/action(atom/target)
	if(istype(target, /turf/space/transit))//>implying these are ever made -Sieve
		return
	if(!isturf(target))
		target = get_turf(target)
	if(!action_checks(target) || get_dist(chassis, target)>3)
		return

	if(isfloorturf(target))
		occupant_message("Building Wall...")
		if(do_after_cooldown(target))
			new /obj/structure/barricade/mime/mrcd(target)
			chassis.spark_system.start()



/obj/item/mecha_parts/mecha_equipment/cable_layer
	name = "cable layer"
	desc = "Equipment for engineering exosuits. Lays cable along the exosuit's path."
	icon_state = "mecha_wire"
	var/obj/structure/cable/last_piece
	var/obj/item/stack/cable_coil/cable
	var/max_cable = 1000

/obj/item/mecha_parts/mecha_equipment/cable_layer/Initialize(mapload)
	. = ..()
	cable = new(src)
	cable.amount = 0

/obj/item/mecha_parts/mecha_equipment/cable_layer/can_attach(obj/mecha/working/M)
	if(..())
		if(istype(M))
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/cable_layer/attach()
	..()
	RegisterSignal(chassis, COMSIG_MOVABLE_MOVED, PROC_REF(layCable))

/obj/item/mecha_parts/mecha_equipment/cable_layer/detach()
	UnregisterSignal(chassis, COMSIG_MOVABLE_MOVED)
	return ..()

/obj/item/mecha_parts/mecha_equipment/cable_layer/action(obj/item/stack/cable_coil/target)
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
	if(..())
		return
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

/obj/item/mecha_parts/mecha_equipment/cable_layer/get_equip_info()
	var/output = ..()
	if(output)
		return "[output] \[Cable: [cable ? cable.amount : 0] m\][(cable && cable.amount) ? "- <a href='byond://?src=[UID()];toggle=1'>[!equip_ready?"Dea":"A"]ctivate</a>|<a href='byond://?src=[UID()];cut=1'>Cut</a>" : null]"

/obj/item/mecha_parts/mecha_equipment/cable_layer/proc/use_cable(amount)
	if(!cable || cable.amount<1)
		set_ready_state(1)
		occupant_message("Cable depleted, [src] deactivated.")
		log_message("Cable depleted, [src] deactivated.")
		return FALSE
	if(cable.amount < amount)
		occupant_message("No enough cable to finish the task.")
		return FALSE
	cable.use(amount)
	update_equip_info()
	return TRUE

/obj/item/mecha_parts/mecha_equipment/cable_layer/proc/reset()
	last_piece = null

/obj/item/mecha_parts/mecha_equipment/cable_layer/proc/dismantleFloor(turf/new_turf)
	if(isfloorturf(new_turf))
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
	NC.d1 = NO_DIRECTION
	NC.d2 = fdirn
	NC.update_icon()

	var/datum/regional_powernet/PN
	if(last_piece && last_piece.d2 != Dir)
		last_piece.d1 = min(last_piece.d2, Dir)
		last_piece.d2 = max(last_piece.d2, Dir)
		last_piece.update_icon()
		PN = last_piece.powernet

	if(!PN)
		PN = new()
	NC.powernet = PN
	PN.cables += NC
	NC.merge_connected_networks(NC.d2)

	//NC.mergeConnectedNetworksOnTurf()
	last_piece = NC
	return TRUE

/obj/item/mecha_parts/mecha_equipment/mech_crusher
	name = "exosuit crusher"
	desc = "A mech mounted crusher. For crushing bigger things."
	icon_state = "mecha_crusher"
	equip_cooldown = 1.2 SECONDS
	energy_drain = 3000
	harmful = TRUE
	range = MECHA_MELEE | MECHA_RANGED
	var/obj/item/kinetic_crusher/mecha/internal_crusher

/obj/item/kinetic_crusher/mecha
	/// Since this one doesn't have the two_handed component it will always use the value in force
	force = 30
	armor_penetration_flat = 15
	detonation_damage = 90
	backstab_bonus = 50

/obj/item/kinetic_crusher/mecha/get_turf_for_projectile(atom/user)
	if(ismecha(user.loc) && isturf(user.loc?.loc))
		return user.loc.loc
	return null

/obj/item/kinetic_crusher/mecha/Initialize(mapload)
	. = ..()
	DeleteComponent(/datum/component/parry)
	DeleteComponent(/datum/component/two_handed)

	/// This is only for the sake of internal checks in the crusher itself.
	ADD_TRAIT(src, TRAIT_WIELDED, "mech[UID()]")

/obj/item/mecha_parts/mecha_equipment/mech_crusher/Initialize(mapload)
	. = ..()
	internal_crusher = new(src)

/obj/item/mecha_parts/mecha_equipment/mech_crusher/Destroy()
	QDEL_NULL(internal_crusher)
	. = ..()

/obj/item/mecha_parts/mecha_equipment/mech_crusher/action(atom/target)
	if(!action_checks(target))
		return
	if(!chassis.occupant)
		return
	chassis.occupant.changeNext_click(equip_cooldown)
	var/proximate = chassis.Adjacent(target)
	if(proximate)
		target.attackby__legacy__attackchain(internal_crusher, chassis.occupant)
	internal_crusher.afterattack__legacy__attackchain(target, chassis.occupant, proximate, null)

#undef MECH_RCD_MODE_DECONSTRUCT
#undef MECH_RCD_MODE_WALL_OR_FLOOR
#undef MECH_RCD_MODE_AIRLOCK
