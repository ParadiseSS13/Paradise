/obj/mecha
	name = "Mecha"
	desc = "Exosuit"
	icon = 'icons/mecha/mecha.dmi'
	density = 1 //Dense. To raise the heat.
	opacity = 1 ///opaque. Menacing.
	anchored = 1 //no pulling around.
	resistance_flags = FIRE_PROOF | ACID_PROOF
	layer = MOB_LAYER //icon draw layer
	infra_luminosity = 15 //byond implementation is bugged.
	force = 5
	max_integrity = 300 //max_integrity is base health
	armor = list(melee = 20, bullet = 10, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 100)
	var/list/facing_modifiers = list(MECHA_FRONT_ARMOUR = 1.5, MECHA_SIDE_ARMOUR = 1, MECHA_BACK_ARMOUR = 0.5)
	var/ruin_mecha = FALSE //if the mecha starts on a ruin, don't automatically give it a tracking beacon to prevent metagaming.
	var/initial_icon = null //Mech type for resetting icon. Only used for reskinning kits (see custom items)
	var/can_move = 0 // time of next allowed movement
	var/mob/living/carbon/occupant = null
	var/step_in = 10 //make a step in step_in/10 sec.
	var/dir_in = 2//What direction will the mech face when entered/powered on? Defaults to South.
	var/normal_step_energy_drain = 10
	var/step_energy_drain = 10
	var/melee_energy_drain = 15
	var/overload_step_energy_drain_min = 100
	var/deflect_chance = 10 //chance to deflect the incoming projectiles, hits, or lesser the effect of ex_act.
	var/obj/item/stock_parts/cell/cell
	var/state = 0
	var/list/log = new
	var/last_message = 0
	var/add_req_access = 1
	var/maint_access = 1
	var/dna	//dna-locking the mech
	var/list/proc_res = list() //stores proc owners, like proc_res["functionname"] = owner reference
	var/datum/effect_system/spark_spread/spark_system = new
	var/lights = 0
	var/lights_power = 6
	var/emagged = FALSE

	//inner atmos
	var/use_internal_tank = 0
	var/internal_tank_valve = ONE_ATMOSPHERE
	var/obj/machinery/portable_atmospherics/canister/internal_tank
	var/datum/gas_mixture/cabin_air
	var/obj/machinery/atmospherics/unary/portables_connector/connected_port = null

	var/obj/item/radio/radio = null
	var/list/trackers = list()

	var/max_temperature = 25000
	var/internal_damage_threshold = 50 //health percentage below which internal damage is possible
	var/internal_damage = 0 //contains bitflags

	var/list/operation_req_access = list()//required access level for mecha operation
	var/list/internals_req_access = list(ACCESS_ENGINE,ACCESS_ROBOTICS)//required access level to open cell compartment

	var/wreckage

	var/list/equipment = new
	var/obj/item/mecha_parts/mecha_equipment/selected
	var/max_equip = 3
	var/datum/events/events
	var/turf/crashing = null
	var/occupant_sight_flags = 0

	var/stepsound = 'sound/mecha/mechstep.ogg'
	var/turnsound = 'sound/mecha/mechturn.ogg'
	var/nominalsound = 'sound/mecha/nominal.ogg'
	var/zoomsound = 'sound/mecha/imag_enh.ogg'
	var/critdestrsound = 'sound/mecha/critdestr.ogg'
	var/weapdestrsound = 'sound/mecha/weapdestr.ogg'
	var/lowpowersound = 'sound/mecha/lowpower.ogg'
	var/longactivationsound = 'sound/mecha/nominal.ogg'
	var/starting_voice = /obj/item/mecha_modkit/voice
	var/activated = FALSE
	var/power_warned = FALSE

	var/destruction_sleep_duration = 1 //Time that mech pilot is put to sleep for if mech is destroyed

	var/melee_cooldown = 10
	var/melee_can_hit = 1

	// Action vars
	var/defence_mode = FALSE
	var/defence_mode_deflect_chance = 35
	var/leg_overload_mode = FALSE
	var/leg_overload_coeff = 100
	var/thrusters_active = FALSE
	var/smoke = 5
	var/smoke_ready = 1
	var/smoke_cooldown = 100
	var/zoom_mode = FALSE
	var/phasing = FALSE
	var/phasing_energy_drain = 200
	var/phase_state = "" //icon_state when phasing

	hud_possible = list (DIAG_STAT_HUD, DIAG_BATT_HUD, DIAG_MECH_HUD, DIAG_TRACK_HUD)

/obj/mecha/Initialize()
	. = ..()
	events = new
	icon_state += "-open"
	add_radio()
	add_cabin()
	add_airtank()
	spark_system.set_up(2, 0, src)
	spark_system.attach(src)
	smoke_system.set_up(3, src)
	smoke_system.attach(src)
	add_cell()
	START_PROCESSING(SSobj, src)
	GLOB.poi_list |= src
	log_message("[src] created.")
	GLOB.mechas_list += src //global mech list
	prepare_huds()
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_to_hud(src)
	diag_hud_set_mechhealth()
	diag_hud_set_mechcell()
	diag_hud_set_mechstat()
	diag_hud_set_mechtracking()

	var/obj/item/mecha_modkit/voice/V = new starting_voice(src)
	V.install(src)
	qdel(V)

////////////////////////
////// Helpers /////////
////////////////////////

/obj/mecha/get_cell()
	return cell

/obj/mecha/proc/add_airtank()
	internal_tank = new /obj/machinery/portable_atmospherics/canister/air(src)
	return internal_tank

/obj/mecha/proc/add_cell(var/obj/item/stock_parts/cell/C=null)
	if(C)
		C.forceMove(src)
		cell = C
		return
	cell = new/obj/item/stock_parts/cell/high/plus(src)

/obj/mecha/proc/add_cabin()
	cabin_air = new
	cabin_air.temperature = T20C
	cabin_air.volume = 200
	cabin_air.oxygen = O2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	cabin_air.nitrogen = N2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	return cabin_air

/obj/mecha/proc/add_radio()
	radio = new(src)
	radio.name = "[src] radio"
	radio.icon = icon
	radio.icon_state = icon_state
	radio.subspace_transmission = 1

/obj/mecha/examine(mob/user)
	. = ..()
	var/integrity = obj_integrity * 100 / max_integrity
	switch(integrity)
		if(85 to 100)
			. += "It's fully intact."
		if(65 to 85)
			. += "It's slightly damaged."
		if(45 to 65)
			. += "It's badly damaged."
		if(25 to 45)
			. += "It's heavily damaged."
		else
			. += "It's falling apart."
	if(equipment && equipment.len)
		. += "It's equipped with:"
		for(var/obj/item/mecha_parts/mecha_equipment/ME in equipment)
			. += "[bicon(ME)] [ME]"

/obj/mecha/hear_talk(mob/M, list/message_pieces)
	if(M == occupant && radio.broadcasting)
		radio.talk_into(M, message_pieces)

/obj/mecha/proc/click_action(atom/target, mob/user, params)
	if(!occupant || occupant != user )
		return
	if(user.incapacitated())
		return
	if(phasing)
		occupant_message("<span class='warning'>Unable to interact with objects while phasing.</span>")
		return
	if(state)
		occupant_message("<span class='warning'>Maintenance protocols in effect.</span>")
		return
	if(!get_charge())
		return
	if(src == target)
		return

	var/dir_to_target = get_dir(src, target)
	if(dir_to_target && !(dir_to_target & dir))//wrong direction
		return

	if(hasInternalDamage(MECHA_INT_CONTROL_LOST))
		target = safepick(view(3,target))
		if(!target)
			return

	var/mob/living/L = user
	if(!target.Adjacent(src))
		if(selected && selected.is_ranged())
			if(HAS_TRAIT(L, TRAIT_PACIFISM) && selected.harmful)
				to_chat(L, "<span class='warning'>You don't want to harm other living beings!</span>")
				return
			selected.action(target, params)
	else if(selected && selected.is_melee())
		if(isliving(target) && selected.harmful && HAS_TRAIT(L, TRAIT_PACIFISM))
			to_chat(user, "<span class='warning'>You don't want to harm other living beings!</span>")
			return
		selected.action(target, params)
	else
		if(internal_damage & MECHA_INT_CONTROL_LOST)
			target = safepick(oview(1, src))
		if(!melee_can_hit || !isatom(target))
			return
		target.mech_melee_attack(src)
		melee_can_hit = 0
		spawn(melee_cooldown)
			melee_can_hit = 1

/obj/mecha/proc/mech_toxin_damage(mob/living/target)
	playsound(src, 'sound/effects/spray2.ogg', 50, 1)
	if(target.reagents)
		if(target.reagents.get_reagent_amount("atropine") + force < force*2)
			target.reagents.add_reagent("atropine", force/2)
		if(target.reagents.get_reagent_amount("toxin") + force < force*2)
			target.reagents.add_reagent("toxin", force/2.5)

/obj/mecha/proc/range_action(atom/target)
	return


//////////////////////////////////
////////  Movement procs  ////////
//////////////////////////////////

/obj/mecha/Move(atom/newLoc, direct)
	. = ..()
	if(.)
		events.fireEvent("onMove",get_turf(src))

/obj/mecha/Process_Spacemove(var/movement_dir = 0)
	. = ..()
	if(.)
		return 1
	if(thrusters_active && movement_dir && use_power(step_energy_drain))
		return 1

	var/atom/movable/backup = get_spacemove_backup()
	if(backup)
		if(istype(backup) && movement_dir && !backup.anchored)
			if(backup.newtonian_move(turn(movement_dir, 180)))
				if(occupant)
					to_chat(occupant, "<span class='info'>You push off of [backup] to propel yourself.</span>")
		return 1

/obj/mecha/relaymove(mob/user, direction)
	if(!direction)
		return
	if(user != occupant) //While not "realistic", this piece is player friendly.
		user.forceMove(get_turf(src))
		to_chat(user, "<span class='notice'>You climb out from [src].</span>")
		return 0
	if(connected_port)
		if(world.time - last_message > 20)
			occupant_message("<span class='warning'>Unable to move while connected to the air system port!</span>")
			last_message = world.time
		return 0
	if(state)
		occupant_message("<span class='danger'>Maintenance protocols in effect.</span>")
		return
	return domove(direction)

/obj/mecha/proc/domove(direction)
	if(can_move >= world.time)
		return 0
	if(!Process_Spacemove(direction))
		return 0
	if(!has_charge(step_energy_drain))
		return 0
	if(defence_mode)
		if(world.time - last_message > 20)
			occupant_message("<span class='danger'>Unable to move while in defence mode.</span>")
			last_message = world.time
		return 0
	if(zoom_mode)
		if(world.time - last_message > 20)
			occupant_message("<span class='danger'>Unable to move while in zoom mode.</span>")
			last_message = world.time
		return 0

	var/move_result = 0
	var/move_type = 0
	if(internal_damage & MECHA_INT_CONTROL_LOST)
		move_result = mechsteprand()
		move_type = MECHAMOVE_RAND
	else if(dir != direction)
		move_result = mechturn(direction)
		move_type = MECHAMOVE_TURN
	else
		move_result = mechstep(direction)
		move_type = MECHAMOVE_STEP

	if(move_result && move_type)
		aftermove(move_type)
		can_move = world.time + step_in
		return TRUE
	return FALSE

/obj/mecha/proc/aftermove(move_type)
	use_power(step_energy_drain)
	if(move_type & (MECHAMOVE_RAND | MECHAMOVE_STEP) && occupant)
		var/obj/machinery/atmospherics/unary/portables_connector/possible_port = locate(/obj/machinery/atmospherics/unary/portables_connector) in loc
		if(possible_port)
			var/obj/screen/alert/mech_port_available/A = occupant.throw_alert("mechaport", /obj/screen/alert/mech_port_available, override = TRUE)
			if(A)
				A.target = possible_port
		else
			occupant.clear_alert("mechaport")
	if(leg_overload_mode)
		if(obj_integrity < max_integrity - max_integrity / 3)
			leg_overload_mode = FALSE
			step_in = initial(step_in)
			step_energy_drain = initial(step_energy_drain)
			occupant_message("<font color='red'>Leg actuators damage threshold exceded. Disabling overload.</font>")

/obj/mecha/proc/mechturn(direction)
	dir = direction
	if(turnsound)
		playsound(src,turnsound,40,1)
	return 1

/obj/mecha/proc/mechstep(direction)
	. = step(src, direction)
	if(!.)
		if(phasing && get_charge() >= phasing_energy_drain)
			if(can_move < world.time)
				. = FALSE // We lie to mech code and say we didn't get to move, because we want to handle power usage + cooldown ourself
				flick("phazon-phase", src)
				forceMove(get_step(src, direction))
				use_power(phasing_energy_drain)
				playsound(src, stepsound, 40, 1)
				can_move = world.time + (step_in * 3)
	else if(stepsound)
		playsound(src, stepsound, 40, 1)

/obj/mecha/proc/mechsteprand()
	. = step_rand(src)
	if(. && stepsound)
		playsound(src, stepsound, 40, 1)

/obj/mecha/Bump(var/atom/obstacle, bump_allowed)
	if(throwing) //high velocity mechas in your face!
		var/breakthrough = 0
		if(istype(obstacle, /obj/structure/window))
			qdel(obstacle)
			breakthrough = 1

		else if(istype(obstacle, /obj/structure/grille/))
			var/obj/structure/grille/G = obstacle
			G.obj_break()
			breakthrough = 1

		else if(istype(obstacle, /obj/structure/table))
			var/obj/structure/table/T = obstacle
			qdel(T)
			breakthrough = 1

		else if(istype(obstacle, /obj/structure/rack))
			new /obj/item/rack_parts(obstacle.loc)
			qdel(obstacle)
			breakthrough = 1

		else if(istype(obstacle, /obj/structure/reagent_dispensers/fueltank))
			obstacle.ex_act(1)

		else if(isliving(obstacle))
			var/mob/living/L = obstacle
			var/hit_sound = list('sound/weapons/genhit1.ogg','sound/weapons/genhit2.ogg','sound/weapons/genhit3.ogg')
			if(L.flags & GODMODE)
				return
			L.take_overall_damage(5,0)
			if(L.buckled)
				L.buckled = 0
			L.Stun(5)
			L.Weaken(5)
			L.apply_effect(STUTTER, 5)
			playsound(src, pick(hit_sound), 50, 0, 0)
			breakthrough = 1

		else
			if(throwing)
				throwing.finalize(FALSE)
			crashing = null

		..()

		if(breakthrough)
			if(crashing)
				spawn(1)
					throw_at(crashing, 50, throw_speed)
			else
				spawn(1)
					crashing = get_distant_turf(get_turf(src), dir, 3)//don't use get_dir(src, obstacle) or the mech will stop if he bumps into a one-direction window on his tile.
					throw_at(crashing, 50, throw_speed)

	else
		if(bump_allowed)
			if(..())
				return
			if(isobj(obstacle))
				var/obj/O = obstacle
				if(istype(O, /obj/effect/portal)) //derpfix
					anchored = 0
					O.Bumped(src)
					spawn(0) //countering portal teleport spawn(0), hurr
						anchored = 1
				else if(!O.anchored)
					step(obstacle, dir)
			else if(ismob(obstacle))
				step(obstacle, dir)


///////////////////////////////////
////////  Internal damage  ////////
///////////////////////////////////

/obj/mecha/proc/check_for_internal_damage(list/possible_int_damage, ignore_threshold=null)
	if(!islist(possible_int_damage) || isemptylist(possible_int_damage))
		return
	if(prob(20))
		if(ignore_threshold || obj_integrity*100/max_integrity < internal_damage_threshold)
			for(var/T in possible_int_damage)
				if(internal_damage & T)
					possible_int_damage -= T
			var/int_dam_flag = safepick(possible_int_damage)
			if(int_dam_flag)
				setInternalDamage(int_dam_flag)
	if(prob(5))
		if(ignore_threshold || obj_integrity*100/max_integrity < internal_damage_threshold)
			var/obj/item/mecha_parts/mecha_equipment/ME = safepick(equipment)
			if(ME)
				qdel(ME)

/obj/mecha/proc/hasInternalDamage(int_dam_flag=null)
	return int_dam_flag ? internal_damage&int_dam_flag : internal_damage


/obj/mecha/proc/setInternalDamage(int_dam_flag)
	internal_damage |= int_dam_flag
	log_append_to_last("Internal damage of type [int_dam_flag].",1)
	occupant << sound('sound/machines/warning-buzzer.ogg',wait=0)
	diag_hud_set_mechstat()

/obj/mecha/proc/clearInternalDamage(int_dam_flag)
	internal_damage &= ~int_dam_flag
	switch(int_dam_flag)
		if(MECHA_INT_TEMP_CONTROL)
			occupant_message("<span class='notice'>Life support system reactivated.</span>")
		if(MECHA_INT_FIRE)
			occupant_message("<span class='notice'>Internal fire extinquished.</span>")
		if(MECHA_INT_TANK_BREACH)
			occupant_message("<span class='notice'>Damaged internal tank has been sealed.</span>")
	diag_hud_set_mechstat()


////////////////////////////////////////
////////  Health related procs  ////////
////////////////////////////////////////

/obj/mecha/proc/get_armour_facing(relative_dir)
	switch(relative_dir)
		if(0) // BACKSTAB!
			return facing_modifiers[MECHA_BACK_ARMOUR]
		if(45, 90, 270, 315)
			return facing_modifiers[MECHA_SIDE_ARMOUR]
		if(225, 180, 135)
			return facing_modifiers[MECHA_FRONT_ARMOUR]
	return 1 //always return non-0

/obj/mecha/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(. && obj_integrity > 0)
		spark_system.start()
		switch(damage_flag)
			if("fire")
				check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL))
			if("melee")
				check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
			else
				check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT))
		if(. >= 5 || prob(33))
			occupant_message("<span class='userdanger'>Taking damage!</span>")
		log_message("Took [damage_amount] points of damage. Damage type: [damage_type]")

/obj/mecha/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	. = ..()
	if(!damage_amount)
		return 0
	var/booster_deflection_modifier = 1
	var/booster_damage_modifier = 1
	if(damage_flag == "bullet" || damage_flag == "laser" || damage_flag == "energy")
		for(var/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/B in equipment)
			if(B.projectile_react())
				booster_deflection_modifier = B.deflect_coeff
				booster_damage_modifier = B.damage_coeff
				break
	else if(damage_flag == "melee")
		for(var/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster/B in equipment)
			if(B.attack_react())
				booster_deflection_modifier *= B.deflect_coeff
				booster_damage_modifier *= B.damage_coeff
				break

	if(attack_dir)
		var/facing_modifier = get_armour_facing(dir2angle(attack_dir) - dir2angle(src))
		booster_damage_modifier /= facing_modifier
		booster_deflection_modifier *= facing_modifier
	if(prob(deflect_chance * booster_deflection_modifier))
		visible_message("<span class='danger'>[src]'s armour deflects the attack!</span>")
		log_message("Armor saved.")
		return 0
	if(.)
		. *= booster_damage_modifier

/obj/mecha/attack_hand(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
	playsound(loc, 'sound/weapons/tap.ogg', 40, 1, -1)
	user.visible_message("<span class='danger'>[user] hits [name]. Nothing happens</span>", "<span class='danger'>You hit [name] with no visible effect.</span>")
	log_message("Attack by hand/paw. Attacker - [user].")


/obj/mecha/attack_alien(mob/living/user)
	log_message("Attack by alien. Attacker - [user].", color = "red")
	playsound(src.loc, 'sound/weapons/slash.ogg', 100, TRUE)
	attack_generic(user, 15, BRUTE, "melee", 0)

/obj/mecha/attack_animal(mob/living/simple_animal/user)
	log_message("Attack by simple animal. Attacker - [user].")
	if(!user.melee_damage_upper && !user.obj_damage)
		user.custom_emote(1, "[user.friendly] [src].")
		return FALSE
	else
		var/play_soundeffect = 1
		if(user.environment_smash)
			play_soundeffect = 0
			playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
		var/animal_damage = rand(user.melee_damage_lower,user.melee_damage_upper)
		if(user.obj_damage)
			animal_damage = user.obj_damage
		animal_damage = min(animal_damage, 20*user.environment_smash)
		user.create_attack_log("<font color='red'>attacked [name]</font>")
		add_attack_logs(user, src, "Attacked")
		attack_generic(user, animal_damage, user.melee_damage_type, "melee", play_soundeffect)
		return TRUE

/obj/mecha/hulk_damage()
	return 15

/obj/mecha/attack_hulk(mob/living/carbon/human/user)
	. = ..()
	if(.)
		log_message("Attack by hulk. Attacker - [user].", 1)
		add_attack_logs(user, src, "Punched with hulk powers")

/obj/mecha/blob_act(obj/structure/blob/B)
	log_message("Attack by blob. Attacker - [B].")
	take_damage(30, BRUTE, "melee", 0, get_dir(src, B))

/obj/mecha/attack_tk()
	return

/obj/mecha/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum) //wrapper
	log_message("Hit by [AM].")
	. = ..()

/obj/mecha/bullet_act(obj/item/projectile/Proj) //wrapper
	log_message("Hit by projectile. Type: [Proj.name]([Proj.flag]).")
	..()

/obj/mecha/ex_act(severity, target)
	log_message("Affected by explosion of severity: [severity].")
	if(prob(deflect_chance))
		severity++
		log_message("Armor saved, changing severity to [severity]")
	..()
	severity++
	for(var/X in equipment)
		var/obj/item/mecha_parts/mecha_equipment/ME = X
		ME.ex_act(severity)
	for(var/Y in trackers)
		var/obj/item/mecha_parts/mecha_tracking/MT = Y
		MT.ex_act(severity)
	if(occupant)
		occupant.ex_act(severity)

/obj/mecha/handle_atom_del(atom/A)
	if(A == occupant)
		occupant = null
		icon_state = initial(icon_state)+"-open"
		setDir(dir_in)

/obj/mecha/Destroy()
	if(occupant)
		occupant.SetSleeping(destruction_sleep_duration)
	go_out()
	var/mob/living/silicon/ai/AI
	for(var/mob/M in src) //Let's just be ultra sure
		if(isAI(M))
			occupant = null
			AI = M //AIs are loaded into the mech computer itself. When the mech dies, so does the AI. They can be recovered with an AI card from the wreck.
		else
			M.forceMove(loc)
	for(var/obj/item/mecha_parts/mecha_equipment/E in equipment)
		E.detach(loc)
		qdel(E)
	equipment.Cut()
	QDEL_NULL(cell)
	QDEL_NULL(internal_tank)
	if(AI)
		AI.gib() //No wreck, no AI to recover
	STOP_PROCESSING(SSobj, src)
	GLOB.poi_list.Remove(src)
	if(loc)
		loc.assume_air(cabin_air)
		air_update_turf()
	else
		qdel(cabin_air)
	cabin_air = null
	QDEL_NULL(spark_system)
	QDEL_NULL(smoke_system)

	GLOB.mechas_list -= src //global mech list
	return ..()

//TODO
/obj/mecha/emp_act(severity)
	if(get_charge())
		use_power((cell.charge/3)/(severity*2))
		take_damage(30 / severity, BURN, "energy", 1)
	log_message("EMP detected", 1)
	check_for_internal_damage(list(MECHA_INT_FIRE, MECHA_INT_TEMP_CONTROL, MECHA_INT_CONTROL_LOST, MECHA_INT_SHORT_CIRCUIT), 1)

/obj/mecha/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > max_temperature)
		log_message("Exposed to dangerous temperature.", 1)
		take_damage(5, BURN, 0, 1)
		check_for_internal_damage(list(MECHA_INT_FIRE, MECHA_INT_TEMP_CONTROL))

//////////////////////
////// AttackBy //////
//////////////////////

/obj/mecha/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/mmi))
		if(mmi_move_inside(W,user))
			to_chat(user, "[src]-MMI interface initialized successfuly")
		else
			to_chat(user, "[src]-MMI interface initialization failed.")
		return

	if(istype(W, /obj/item/mecha_parts/mecha_equipment))
		var/obj/item/mecha_parts/mecha_equipment/E = W
		spawn()
			if(E.can_attach(src))
				if(!user.drop_item())
					return
				E.attach(src)
				user.visible_message("[user] attaches [W] to [src].", "<span class='notice'>You attach [W] to [src].</span>")
			else
				to_chat(user, "<span class='warning'>You were unable to attach [W] to [src]!</span>")
		return

	if(W.GetID())
		if(add_req_access || maint_access)
			if(internals_access_allowed(usr))
				var/obj/item/card/id/id_card
				if(istype(W, /obj/item/card/id))
					id_card = W
				else
					var/obj/item/pda/pda = W
					id_card = pda.id
				output_maintenance_dialog(id_card, user)
				return
			else
				to_chat(user, "<span class='warning'>Invalid ID: Access denied.</span>")
		else
			to_chat(user, "<span class='warning'>Maintenance protocols disabled by operator.</span>")

	else if(istype(W, /obj/item/stack/cable_coil))
		if(state == 3 && hasInternalDamage(MECHA_INT_SHORT_CIRCUIT))
			var/obj/item/stack/cable_coil/CC = W
			if(CC.amount > 1)
				CC.use(2)
				clearInternalDamage(MECHA_INT_SHORT_CIRCUIT)
				to_chat(user, "You replace the fused wires.")
			else
				to_chat(user, "There's not enough wire to finish the task.")
		return

	else if(istype(W, /obj/item/stock_parts/cell))
		if(state==4)
			if(!cell)
				if(!user.drop_item())
					return
				to_chat(user, "<span class='notice'>You install the powercell.</span>")
				W.forceMove(src)
				cell = W
				log_message("Powercell installed")
			else
				to_chat(user, "<span class='notice'>There's already a powercell installed.</span>")
		return

	else if(istype(W, /obj/item/mecha_parts/mecha_tracking))
		if(!user.unEquip(W))
			to_chat(user, "<span class='notice'>\the [W] is stuck to your hand, you cannot put it in \the [src]</span>")
			return
		W.forceMove(src)
		trackers += W
		user.visible_message("[user] attaches [W] to [src].", "<span class='notice'>You attach [W] to [src].</span>")
		diag_hud_set_mechtracking()
		return

	else if(istype(W, /obj/item/paintkit))
		if(occupant)
			to_chat(user, "You can't customize a mech while someone is piloting it - that would be unsafe!")
			return

		var/obj/item/paintkit/P = W
		var/found = null

		for(var/type in P.allowed_types)
			if(type == initial_icon)
				found = 1
				break

		if(!found)
			to_chat(user, "That kit isn't meant for use on this class of exosuit.")
			return

		user.visible_message("[user] opens [P] and spends some quality time customising [src].")

		name = P.new_name
		desc = P.new_desc
		initial_icon = P.new_icon
		reset_icon()

		user.drop_item()
		qdel(P)

	else if(istype(W, /obj/item/mecha_modkit))
		if(occupant)
			to_chat(user, "<span class='notice'>You can't access the mech's modification port while it is occupied.</span>")
			return
		var/obj/item/mecha_modkit/M = W
		if(do_after_once(user, M.install_time, target = src))
			M.install(src, user)
		else
			to_chat(user, "<span class='notice'>You stop installing [M].</span>")

	else
		return ..()


/obj/mecha/crowbar_act(mob/user, obj/item/I)
	if(state != 2 && state != 3 && !(state == 4 && pilot_is_mmi()))
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(state == 2)
		state = 3
		to_chat(user, "You open the hatch to the power unit")
	else if(state == 3)
		state = 2
		to_chat(user, "You close the hatch to the power unit")
	else
		// Since having maint protocols available is controllable by the MMI, I see this as a consensual way to remove an MMI without destroying the mech
		user.visible_message("[user] begins levering out the MMI from the [src].", "You begin to lever out the MMI from the [src].")
		to_chat(occupant, "<span class='warning'>[user] is prying you out of the exosuit!</span>")
		if(I.use_tool(src, user, 80, volume = I.tool_volume) && pilot_is_mmi())
			user.visible_message("<span class='notice'>[user] pries the MMI out of the [src]!</span>", "<span class='notice'>You finish removing the MMI from the [src]!</span>")
			go_out()

/obj/mecha/screwdriver_act(mob/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)
		return
	if(!(state==3 && cell) && !(state==4 && cell))
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(hasInternalDamage(MECHA_INT_TEMP_CONTROL))
		clearInternalDamage(MECHA_INT_TEMP_CONTROL)
		to_chat(user, "<span class='notice'>You repair the damaged temperature controller.</span>")
	else if(state==3 && cell)
		cell.forceMove(loc)
		cell = null
		state = 4
		to_chat(user, "<span class='notice'>You unscrew and pry out the powercell.</span>")
		log_message("Powercell removed")
	else if(state==4 && cell)
		state=3
		to_chat(user, "<span class='notice'>You screw the cell in place.</span>")

/obj/mecha/wrench_act(mob/user, obj/item/I)
	if(state != 1 && state != 2)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(state==1)
		state = 2
		to_chat(user, "You undo the securing bolts.")
	else
		state = 1
		to_chat(user, "You tighten the securing bolts.")

/obj/mecha/welder_act(mob/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if((obj_integrity >= max_integrity) && !internal_damage)
		to_chat(user, "<span class='notice'>[src] is at full integrity!</span>")
		return
	WELDER_ATTEMPT_REPAIR_MESSAGE
	if(I.use_tool(src, user, 15, volume = I.tool_volume))
		if(internal_damage & MECHA_INT_TANK_BREACH)
			clearInternalDamage(MECHA_INT_TANK_BREACH)
			user.visible_message("<span class='notice'>[user] repairs the damaged gas tank.</span>", "<span class='notice'>You repair the damaged gas tank.</span>")
		else if(obj_integrity < max_integrity)
			user.visible_message("<span class='notice'>[user] repairs some damage to [name].</span>", "<span class='notice'>You repair some damage to [name].</span>")
			obj_integrity += min(10, max_integrity - obj_integrity)
		else
			to_chat(user, "<span class='notice'>[src] is at full integrity!</span>")

/obj/mecha/mech_melee_attack(obj/mecha/M)
	if(!has_charge(melee_energy_drain))
		return 0
	use_power(melee_energy_drain)
	if(M.damtype == BRUTE || M.damtype == BURN)
		add_attack_logs(M.occupant, src, "Mecha-attacked with [M] (INTENT: [uppertext(M.occupant.a_intent)]) (DAMTYPE: [uppertext(M.damtype)])")
		. = ..()

/obj/mecha/emag_act(mob/user)
	to_chat(user, "<span class='warning'>[src]'s ID slot rejects the card.</span>")
	return


/////////////////////////////////////
//////////// AI piloting ////////////
/////////////////////////////////////

/obj/mecha/attack_ai(mob/living/silicon/ai/user)
	if(!isAI(user))
		return
	//Allows the Malf to scan a mech's status and loadout, helping it to decide if it is a worthy chariot.
	if(user.can_dominate_mechs)
		examine(user) //Get diagnostic information!
		for(var/obj/item/mecha_parts/mecha_tracking/B in trackers)
			to_chat(user, "<span class='danger'>Warning: Tracking Beacon detected. Enter at your own risk. Beacon Data:")
			to_chat(user, "[B.get_mecha_info_text()]")
			break
		//Nothing like a big, red link to make the player feel powerful!
		to_chat(user, "<a href='?src=[user.UID()];ai_take_control=\ref[src]'><span class='userdanger'>ASSUME DIRECT CONTROL?</span></a><br>")
	else
		examine(user)
		if(occupant)
			user << "<span class='warning'>This exosuit has a pilot and cannot be controlled.</span>"
			return
		var/can_control_mech = FALSE
		for(var/obj/item/mecha_parts/mecha_tracking/ai_control/A in trackers)
			can_control_mech = TRUE
			to_chat(user, "<span class='notice'>[bicon(src)] Status of [name]:</span>\n\
				[A.get_mecha_info_text()]")
			break
		if(!can_control_mech)
			to_chat(user, "<span class='warning'>You cannot control exosuits without AI control beacons installed.</span>")
			return
		to_chat(user, "<a href='?src=[user.UID()];ai_take_control=\ref[src]'><span class='boldnotice'>Take control of exosuit?</span></a><br>")

/obj/mecha/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(!..())
		return

 //Transfer from core or card to mech. Proc is called by mech.
	switch(interaction)
		if(AI_TRANS_TO_CARD) //Upload AI from mech to AI card.
			if(!maint_access) //Mech must be in maint mode to allow carding.
				to_chat(user, "<span class='warning'>[name] must have maintenance protocols active in order to allow a transfer.</span>")
				return
			AI = occupant
			if(!AI || !isAI(occupant)) //Mech does not have an AI for a pilot
				to_chat(user, "<span class='warning'>No AI detected in the [name] onboard computer.</span>")
				return
			if(AI.mind.special_role) //Malf AIs cannot leave mechs. Except through death.
				to_chat(user, "<span class='boldannounce'>ACCESS DENIED.</span>")
				return
			AI.aiRestorePowerRoutine = 0//So the AI initially has power.
			AI.control_disabled = 1
			AI.aiRadio.disabledAi = 1
			AI.loc = card
			occupant = null
			AI.controlled_mech = null
			AI.remote_control = null
			icon_state = initial(icon_state)+"-open"
			to_chat(AI, "You have been downloaded to a mobile storage device. Wireless connection offline.")
			to_chat(user, "<span class='boldnotice'>Transfer successful</span>: [AI.name] ([rand(1000,9999)].exe) removed from [name] and stored within local memory.")

		if(AI_MECH_HACK) //Called by AIs on the mech
			AI.linked_core = new /obj/structure/AIcore/deactivated(AI.loc)
			if(AI.can_dominate_mechs)
				if(occupant) //Oh, I am sorry, were you using that?
					to_chat(AI, "<span class='warning'>Pilot detected! Forced ejection initiated!")
					to_chat(occupant, "<span class='danger'>You have been forcibly ejected!</span>")
					go_out(1) //IT IS MINE, NOW. SUCK IT, RD!
			ai_enter_mech(AI, interaction)

		if(AI_TRANS_FROM_CARD) //Using an AI card to upload to a mech.
			AI = locate(/mob/living/silicon/ai) in card
			if(!AI)
				to_chat(user, "<span class='warning'>There is no AI currently installed on this device.</span>")
				return
			else if(AI.stat || !AI.client)
				to_chat(user, "<span class='warning'>[AI.name] is currently unresponsive, and cannot be uploaded.</span>")
				return
			else if(occupant || dna) //Normal AIs cannot steal mechs!
				to_chat(user, "<span class='warning'>Access denied. [name] is [occupant ? "currently occupied" : "secured with a DNA lock"].")
				return
			AI.control_disabled = 0
			AI.aiRadio.disabledAi = 0
			to_chat(user, "<span class='boldnotice'>Transfer successful</span>: [AI.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed.")
			ai_enter_mech(AI, interaction)

//Hack and From Card interactions share some code, so leave that here for both to use.
/obj/mecha/proc/ai_enter_mech(mob/living/silicon/ai/AI, interaction)
	AI.aiRestorePowerRoutine = 0
	AI.loc = src
	occupant = AI
	icon_state = initial(icon_state)
	playsound(src, 'sound/machines/windowdoor.ogg', 50, 1)
	if(!hasInternalDamage())
		occupant << sound(nominalsound, volume = 50)
	AI.cancel_camera()
	AI.controlled_mech = src
	AI.remote_control = src
	AI.canmove = 1 //Much easier than adding AI checks! Be sure to set this back to 0 if you decide to allow an AI to leave a mech somehow.
	AI.can_shunt = 0 //ONE AI ENTERS. NO AI LEAVES.
	to_chat(AI, "[AI.can_dominate_mechs ? "<span class='announce'>Takeover of [name] complete! You are now permanently loaded onto the onboard computer. Do not attempt to leave the station sector!</span>" \
	: "<span class='notice'>You have been uploaded to a mech's onboard computer."]")
	to_chat(AI, "<span class='boldnotice'>Use Middle-Mouse to activate mech functions and equipment. Click normally for AI interactions.</span>")
	if(interaction == AI_TRANS_FROM_CARD)
		GrantActions(AI, FALSE)
	else
		GrantActions(AI, !AI.can_dominate_mechs)

/////////////////////////////////////
////////  Atmospheric stuff  ////////
/////////////////////////////////////

/obj/mecha/proc/get_turf_air()
	var/turf/T = get_turf(src)
	if(T)
		. = T.return_air()

/obj/mecha/remove_air(amount)
	if(use_internal_tank)
		return cabin_air.remove(amount)
	else
		var/turf/T = get_turf(src)
		if(T)
			return T.remove_air(amount)

/obj/mecha/return_air()
	if(use_internal_tank)
		return cabin_air
	return get_turf_air()

/obj/mecha/proc/return_pressure()
	var/datum/gas_mixture/t_air = return_air()
	if(t_air)
		. = t_air.return_pressure()

//skytodo: //No idea what you want me to do here, mate.
/obj/mecha/proc/return_temperature()
	var/datum/gas_mixture/t_air = return_air()
	if(t_air)
		. = t_air.return_temperature()

/obj/mecha/proc/connect(obj/machinery/atmospherics/unary/portables_connector/new_port)
	//Make sure not already connected to something else
	if(connected_port || !istype(new_port) || new_port.connected_device)
		return 0

	//Make sure are close enough for a valid connection
	if(new_port.loc != loc)
		return 0

	//Perform the connection
	connected_port = new_port
	connected_port.connected_device = src
	connected_port.parent.reconcile_air()

	if(occupant)
		occupant.clear_alert("mechaport")
		occupant.throw_alert("mechaport_d", /obj/screen/alert/mech_port_disconnect)

	log_message("Connected to gas port.")
	return 1

/obj/mecha/proc/disconnect()
	if(!connected_port)
		return 0

	connected_port.connected_device = null
	connected_port = null
	log_message("Disconnected from gas port.")
	if(occupant)
		occupant.clear_alert("mechaport_d")
	return 1

/obj/mecha/portableConnectorReturnAir()
	return internal_tank.return_air()

/obj/mecha/proc/toggle_lights()
	lights = !lights
	if(lights)
		set_light(light_range + lights_power)
	else
		set_light(light_range - lights_power)
	occupant_message("Toggled lights [lights ? "on" : "off"].")
	log_message("Toggled lights [lights ? "on" : "off"].")

/obj/mecha/proc/toggle_internal_tank()
	use_internal_tank = !use_internal_tank
	occupant_message("Now taking air from [use_internal_tank ? "internal airtank" : "environment"].")
	log_message("Now taking air from [use_internal_tank ? "internal airtank" : "environment"].")

/obj/mecha/MouseDrop_T(mob/M, mob/user)
	if(user.incapacitated())
		return
	if(user != M)
		return
	log_message("[user] tries to move in.")
	if(occupant)
		to_chat(user, "<span class='warning'>The [src] is already occupied!</span>")
		log_append_to_last("Permission denied.")
		return
	var/passed
	if(dna)
		if(ishuman(user))
			if(user.dna.unique_enzymes == dna)
				passed = 1
	else if(operation_allowed(user))
		passed = 1
	if(!passed)
		to_chat(user, "<span class='warning'>Access denied.</span>")
		log_append_to_last("Permission denied.")
		return
	if(user.buckled)
		to_chat(user, "<span class='warning'>You are currently buckled and cannot move.</span>")
		log_append_to_last("Permission denied.")
		return
	if(user.has_buckled_mobs()) //mob attached to us
		to_chat(user, "<span class='warning'>You can't enter the exosuit with other creatures attached to you!</span>")
		return

	visible_message("<span class='notice'>[user] starts to climb into [src]")

	if(do_after(user, 40, target = src))
		if(obj_integrity <= 0)
			to_chat(user, "<span class='warning'>You cannot get in the [name], it has been destroyed!</span>")
		else if(occupant)
			to_chat(user, "<span class='danger'>[occupant] was faster! Try better next time, loser.</span>")
		else if(user.buckled)
			to_chat(user, "<span class='warning'>You can't enter the exosuit while buckled.</span>")
		else if(user.has_buckled_mobs())
			to_chat(user, "<span class='warning'>You can't enter the exosuit with other creatures attached to you!</span>")
		else
			moved_inside(user)
	else
		to_chat(user, "<span class='warning'>You stop entering the exosuit!</span>")

/obj/mecha/proc/moved_inside(var/mob/living/carbon/human/H as mob)
	if(H && H.client && H in range(1))
		occupant = H
		H.stop_pulling()
		H.forceMove(src)
		H.reset_perspective(src)
		add_fingerprint(H)
		GrantActions(H, human_occupant = 1)
		forceMove(loc)
		log_append_to_last("[H] moved in as pilot.")
		icon_state = reset_icon()
		dir = dir_in
		playsound(src, 'sound/machines/windowdoor.ogg', 50, 1)
		if(!activated)
			occupant << sound(longactivationsound, volume = 50)
			activated = TRUE
		else if(!hasInternalDamage())
			occupant << sound(nominalsound, volume = 50)
		if(state)
			H.throw_alert("locked", /obj/screen/alert/mech_maintenance)
		return 1
	else
		return 0

/obj/mecha/proc/mmi_move_inside(var/obj/item/mmi/mmi_as_oc as obj,mob/user as mob)
	if(!mmi_as_oc.brainmob || !mmi_as_oc.brainmob.client)
		to_chat(user, "<span class='warning'>Consciousness matrix not detected!</span>")
		return 0
	else if(mmi_as_oc.brainmob.stat)
		to_chat(user, "<span class='warning'>Beta-rhythm below acceptable level!</span>")
		return 0
	else if(occupant)
		to_chat(user, "<span class='warning'>Occupant detected!</span>")
		return 0
	else if(dna && dna != mmi_as_oc.brainmob.dna.unique_enzymes)
		to_chat(user, "<span class='warning'>Access denied. [name] is secured with a DNA lock.</span>")
		return 0

	if(do_after(user, 40, target = src))
		if(!occupant)
			return mmi_moved_inside(mmi_as_oc,user)
		else
			to_chat(user, "<span class='warning'>Occupant detected!</span>")
	else
		to_chat(user, "<span class='notice'>You stop inserting the MMI.</span>")
	return 0

/obj/mecha/proc/mmi_moved_inside(obj/item/mmi/mmi_as_oc,mob/user)
	if(mmi_as_oc && user in range(1))
		if(!mmi_as_oc.brainmob || !mmi_as_oc.brainmob.client)
			to_chat(user, "Consciousness matrix not detected.")
			return 0
		else if(mmi_as_oc.brainmob.stat)
			to_chat(user, "Beta-rhythm below acceptable level.")
			return 0
		if(!user.unEquip(mmi_as_oc))
			to_chat(user, "<span class='notice'>\the [mmi_as_oc] is stuck to your hand, you cannot put it in \the [src]</span>")
			return 0
		var/mob/brainmob = mmi_as_oc.brainmob
		brainmob.reset_perspective(src)
		occupant = brainmob
		brainmob.forceMove(src) //should allow relaymove
		brainmob.canmove = 1
		if(istype(mmi_as_oc, /obj/item/mmi/robotic_brain))
			var/obj/item/mmi/robotic_brain/R = mmi_as_oc
			if(R.imprinted_master)
				to_chat(brainmob, "<span class='notice'>Your imprint to [R.imprinted_master] has been temporarily disabled. You should help the crew and not commit harm.</span>")
		mmi_as_oc.loc = src
		mmi_as_oc.mecha = src
		Entered(mmi_as_oc)
		Move(loc)
		icon_state = reset_icon()
		dir = dir_in
		log_message("[mmi_as_oc] moved in as pilot.")
		if(!hasInternalDamage())
			to_chat(occupant, sound(nominalsound, volume=50))
		GrantActions(brainmob)
		return 1
	else
		return 0

/obj/mecha/proc/pilot_is_mmi()
	var/atom/movable/mob_container
	if(istype(occupant, /mob/living/carbon/brain))
		var/mob/living/carbon/brain/brain = occupant
		mob_container = brain.container
	if(istype(mob_container, /obj/item/mmi))
		return 1
	return 0

/obj/mecha/proc/pilot_mmi_hud(var/mob/living/carbon/brain/pilot)
	return

/obj/mecha/Exited(atom/movable/M, atom/newloc)
	if(occupant && occupant == M) // The occupant exited the mech without calling go_out()
		go_out(1, newloc)

/obj/mecha/proc/go_out(forced, atom/newloc = loc)
	if(!occupant)
		return
	var/atom/movable/mob_container
	occupant.clear_alert("charge")
	occupant.clear_alert("locked")
	occupant.clear_alert("mech damage")
	occupant.clear_alert("mechaport")
	occupant.clear_alert("mechaport_d")
	if(ishuman(occupant))
		mob_container = occupant
		RemoveActions(occupant, human_occupant = 1)
	else if(isbrain(occupant))
		var/mob/living/carbon/brain/brain = occupant
		RemoveActions(brain)
		mob_container = brain.container
	else if(isAI(occupant))
		var/mob/living/silicon/ai/AI = occupant
		if(forced)//This should only happen if there are multiple AIs in a round, and at least one is Malf.
			RemoveActions(occupant)
			occupant.gib()  //If one Malf decides to steal a mech from another AI (even other Malfs!), they are destroyed, as they have nowhere to go when replaced.
			occupant = null
			return
		else
			if(!AI.linked_core || QDELETED(AI.linked_core))
				to_chat(AI, "<span class='userdanger'>Inactive core destroyed. Unable to return.</span>")
				AI.linked_core = null
				return
			to_chat(AI, "<span class='notice'>Returning to core...</span>")
			AI.controlled_mech = null
			AI.remote_control = null
			RemoveActions(occupant, 1)
			mob_container = AI
			newloc = get_turf(AI.linked_core)
			qdel(AI.linked_core)
	else
		return
	var/mob/living/L = occupant
	occupant = null //we need it null when forceMove calls Exited().
	if(mob_container.forceMove(newloc))//ejecting mob container
		log_message("[mob_container] moved out.")
		L << browse(null, "window=exosuit")

		if(istype(mob_container, /obj/item/mmi))
			var/obj/item/mmi/mmi = mob_container
			if(mmi.brainmob)
				L.loc = mmi
				L.reset_perspective()
			mmi.mecha = null
			mmi.update_icon()
			L.canmove = 0
			if(istype(mmi, /obj/item/mmi/robotic_brain))
				var/obj/item/mmi/robotic_brain/R = mmi
				if(R.imprinted_master)
					to_chat(L, "<span class='notice'>Imprint re-enabled, you are once again bound to [R.imprinted_master]'s commands.</span>")
		icon_state = initial(icon_state)+"-open"
		dir = dir_in

	if(L && L.client)
		L.client.RemoveViewMod("mecha")
		zoom_mode = FALSE

/////////////////////////
////// Access stuff /////
/////////////////////////

/obj/mecha/proc/operation_allowed(mob/living/carbon/human/H)
	if(!ishuman(H))
		return 0
	for(var/ID in list(H.get_active_hand(), H.wear_id, H.belt))
		if(check_access(ID, operation_req_access))
			return 1
	return 0


/obj/mecha/proc/internals_access_allowed(mob/living/carbon/human/H)
	for(var/atom/ID in list(H.get_active_hand(), H.wear_id, H.belt))
		if(check_access(ID, internals_req_access))
			return 1
	return 0


/obj/mecha/check_access(obj/item/card/id/I, list/access_list)
	if(!istype(access_list))
		return 1
	if(!access_list.len) //no requirements
		return 1
	if(istype(I, /obj/item/pda))
		var/obj/item/pda/pda = I
		I = pda.id
	if(!istype(I) || !I.access) //not ID or no access
		return 0
	if(access_list==operation_req_access)
		for(var/req in access_list)
			if(!(req in I.access)) //doesn't have this access
				return 0
	else if(access_list==internals_req_access)
		for(var/req in access_list)
			if(req in I.access)
				return 1
	return 1

///////////////////////
///// Power stuff /////
///////////////////////

/obj/mecha/proc/has_charge(amount)
	return (get_charge()>=amount)

/obj/mecha/proc/get_charge()
	for(var/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/R in equipment)
		var/relay_charge = R.get_charge()
		if(relay_charge)
			return relay_charge
	if(cell)
		return max(0, cell.charge)

/obj/mecha/proc/use_power(amount)
	if(get_charge())
		cell.use(amount)
		if(occupant)
			update_cell()
		return 1
	return 0

/obj/mecha/proc/give_power(amount)
	if(!isnull(get_charge()))
		cell.give(amount)
		if(occupant)
			update_cell()
		return 1
	return 0

/obj/mecha/proc/update_cell()
	if(cell)
		var/cellcharge = cell.charge/cell.maxcharge
		switch(cellcharge)
			if(0.75 to INFINITY)
				occupant.clear_alert("charge")
			if(0.5 to 0.75)
				occupant.throw_alert("charge", /obj/screen/alert/mech_lowcell, 1)
			if(0.25 to 0.5)
				occupant.throw_alert("charge", /obj/screen/alert/mech_lowcell, 2)
				if(power_warned)
					power_warned = FALSE
			if(0.01 to 0.25)
				occupant.throw_alert("charge", /obj/screen/alert/mech_lowcell, 3)
				if(!power_warned)
					occupant << sound(lowpowersound, volume = 50)
					power_warned = TRUE
			else
				occupant.throw_alert("charge", /obj/screen/alert/mech_emptycell)
	else
		occupant.throw_alert("charge", /obj/screen/alert/mech_nocell)

/obj/mecha/proc/reset_icon()
	if(initial_icon)
		icon_state = initial_icon
	else
		icon_state = initial(icon_state)
	return icon_state

//////////////////////////////////////////
////////  Mecha global iterators  ////////
//////////////////////////////////////////

/obj/mecha/process()
	process_internal_damage()
	regulate_temp()
	give_air()
	update_huds()

/obj/mecha/proc/process_internal_damage()
	if(!internal_damage)
		return

	if(internal_damage & MECHA_INT_FIRE)
		if(!(internal_damage & MECHA_INT_TEMP_CONTROL) && prob(5))
			clearInternalDamage(MECHA_INT_FIRE)
		if(internal_tank)
			var/datum/gas_mixture/int_tank_air = internal_tank.return_air()
			if(int_tank_air.return_pressure() > internal_tank.maximum_pressure && !(internal_damage & MECHA_INT_TANK_BREACH))
				setInternalDamage(MECHA_INT_TANK_BREACH)

			if(int_tank_air && int_tank_air.return_volume() > 0)
				int_tank_air.temperature = min(6000 + T0C, cabin_air.return_temperature() + rand(10, 15))

			if(cabin_air && cabin_air.return_volume()>0)
				cabin_air.temperature = min(6000+T0C, cabin_air.return_temperature()+rand(10,15))
				if(cabin_air.return_temperature() > max_temperature/2)
					take_damage(4/round(max_temperature/cabin_air.return_temperature(),0.1), BURN, 0, 0)

	if(internal_damage & MECHA_INT_TANK_BREACH) //remove some air from internal tank
		if(internal_tank)
			var/datum/gas_mixture/int_tank_air = internal_tank.return_air()
			var/datum/gas_mixture/leaked_gas = int_tank_air.remove_ratio(0.10)
			if(loc)
				loc.assume_air(leaked_gas)
				air_update_turf()
			else
				qdel(leaked_gas)

	if(internal_damage & MECHA_INT_SHORT_CIRCUIT)
		if(get_charge())
			spark_system.start()
			cell.charge -= min(20,cell.charge)
			cell.maxcharge -= min(20,cell.maxcharge)

/obj/mecha/proc/regulate_temp()
	if(internal_damage & MECHA_INT_TEMP_CONTROL)
		return

	if(cabin_air && cabin_air.return_volume() > 0)
		var/delta = cabin_air.temperature - T20C
		cabin_air.temperature -= max(-10, min(10, round(delta / 4, 0.1)))

/obj/mecha/proc/give_air()
	if(!internal_tank)
		return

	var/datum/gas_mixture/tank_air = internal_tank.return_air()

	var/release_pressure = internal_tank_valve
	var/cabin_pressure = cabin_air.return_pressure()
	var/pressure_delta = min(release_pressure - cabin_pressure, (tank_air.return_pressure() - cabin_pressure)/2)
	var/transfer_moles = 0
	if(pressure_delta > 0) //cabin pressure lower than release pressure
		if(tank_air.return_temperature() > 0)
			transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
			var/datum/gas_mixture/removed = tank_air.remove(transfer_moles)
			cabin_air.merge(removed)
	else if(pressure_delta < 0) //cabin pressure higher than release pressure
		var/datum/gas_mixture/t_air = return_air()
		pressure_delta = cabin_pressure - release_pressure
		if(t_air)
			pressure_delta = min(cabin_pressure - t_air.return_pressure(), pressure_delta)
		if(pressure_delta > 0) //if location pressure is lower than cabin pressure
			transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
			var/datum/gas_mixture/removed = cabin_air.remove(transfer_moles)
			if(t_air)
				t_air.merge(removed)
			else //just delete the cabin gas, we're in space or some shit
				qdel(removed)

/obj/mecha/proc/update_huds()
	diag_hud_set_mechhealth()
	diag_hud_set_mechcell()
	diag_hud_set_mechstat()
	diag_hud_set_mechtracking()


/obj/mecha/speech_bubble(var/bubble_state = "",var/bubble_loc = src, var/list/bubble_recipients = list())
	flick_overlay(image('icons/mob/talk.dmi', bubble_loc, bubble_state,MOB_LAYER+1), bubble_recipients, 30)

/obj/mecha/update_remote_sight(mob/living/user)
	if(occupant_sight_flags)
		if(user == occupant)
			user.sight |= occupant_sight_flags

	..()

/obj/mecha/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect, end_pixel_y)
	if(!no_effect)
		if(selected)
			used_item = selected
		else if(!visual_effect_icon)
			visual_effect_icon = ATTACK_EFFECT_SMASH
			if(damtype == BURN)
				visual_effect_icon = ATTACK_EFFECT_MECHFIRE
			else if(damtype == TOX)
				visual_effect_icon = ATTACK_EFFECT_MECHTOXIN
	..()

/obj/mecha/obj_destruction()
	if(wreckage)
		var/mob/living/silicon/ai/AI
		if(isAI(occupant))
			AI = occupant
			occupant = null
		var/obj/structure/mecha_wreckage/WR = new wreckage(loc, AI)
		for(var/obj/item/mecha_parts/mecha_equipment/E in equipment)
			if(E.salvageable && prob(30))
				WR.crowbar_salvage += E
				E.detach(WR) //detaches from src into WR
				E.equip_ready = 1
			else
				E.detach(loc)
				qdel(E)
		if(cell)
			WR.crowbar_salvage += cell
			cell.forceMove(WR)
			cell.charge = rand(0, cell.charge)
			cell = null
		if(internal_tank)
			WR.crowbar_salvage += internal_tank
			internal_tank.forceMove(WR)
			cell = null
	. = ..()

/obj/mecha/CtrlClick(mob/living/L)
	if(occupant != L || !istype(L))
		return ..()

	var/list/choices = list("Cancel / No Change" = mutable_appearance(icon = 'icons/mob/screen_gen.dmi', icon_state = "x"))
	var/list/choices_to_refs = list()

	for(var/obj/item/mecha_parts/mecha_equipment/MT in equipment)
		if(!MT.selectable || selected == MT)
			continue
		var/mutable_appearance/clean/MA = new(MT)
		choices[MT.name] = MA
		choices_to_refs[MT.name] = MT

	var/choice = show_radial_menu(L, src, choices, radius = 48, custom_check = CALLBACK(src, .proc/check_menu, L))
	if(!check_menu(L) || choice == "Cancel / No Change")
		return

	var/obj/item/mecha_parts/mecha_equipment/new_sel = LAZYACCESS(choices_to_refs, choice)
	if(istype(new_sel))
		selected = new_sel
		occupant_message("<span class='notice'>You switch to [selected].</span>")
		visible_message("[src] raises [selected]")
		send_byjax(occupant, "exosuit.browser", "eq_list", get_equipment_list())

/obj/mecha/proc/check_menu(mob/living/L)
	if(L != occupant || !istype(L))
		return FALSE
	if(L.incapacitated())
		return FALSE
	return TRUE
