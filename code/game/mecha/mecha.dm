#define MECHA_INT_FIRE 1
#define MECHA_INT_TEMP_CONTROL 2
#define MECHA_INT_SHORT_CIRCUIT 4
#define MECHA_INT_TANK_BREACH 8
#define MECHA_INT_CONTROL_LOST 16

#define MELEE 1
#define RANGED 2


/obj/mecha
	name = "Mecha"
	desc = "Exosuit"
	icon = 'icons/mecha/mecha.dmi'
	density = 1 //Dense. To raise the heat.
	opacity = 1 ///opaque. Menacing.
	anchored = 1 //no pulling around.
	unacidable = 1 //and no deleting hoomans inside
	layer = MOB_LAYER //icon draw layer
	infra_luminosity = 15 //byond implementation is bugged.
	force = 5
	var/initial_icon = null //Mech type for resetting icon. Only used for reskinning kits (see custom items)
	var/can_move = 1
	var/mob/living/carbon/occupant = null
	var/step_in = 10 //make a step in step_in/10 sec.
	var/dir_in = 2//What direction will the mech face when entered/powered on? Defaults to South.
	var/step_energy_drain = 10
	var/health = 300 //health is health
	var/deflect_chance = 10 //chance to deflect the incoming projectiles, hits, or lesser the effect of ex_act.
	//the values in this list show how much damage will pass through, not how much will be absorbed.
	var/list/damage_absorption = list("brute"=0.8,"fire"=1.2,"bullet"=0.9,"laser"=1,"energy"=1,"bomb"=1)
	var/obj/item/weapon/stock_parts/cell/cell
	var/state = 0
	var/list/log = new
	var/last_message = 0
	var/add_req_access = 1
	var/maint_access = 1
	var/dna	//dna-locking the mech
	var/list/proc_res = list() //stores proc owners, like proc_res["functionname"] = owner reference
	var/datum/effect/system/spark_spread/spark_system = new
	var/lights = 0
	var/lights_power = 6
	var/emagged = 0

	//inner atmos
	var/use_internal_tank = 0
	var/internal_tank_valve = ONE_ATMOSPHERE
	var/obj/machinery/portable_atmospherics/canister/internal_tank
	var/datum/gas_mixture/cabin_air
	var/obj/machinery/atmospherics/unary/portables_connector/connected_port = null

	var/obj/item/device/radio/radio = null

	var/max_temperature = 25000
	var/internal_damage_threshold = 50 //health percentage below which internal damage is possible
	var/internal_damage = 0 //contains bitflags

	var/list/operation_req_access = list()//required access level for mecha operation
	var/list/internals_req_access = list(access_engine,access_robotics)//required access level to open cell compartment

	var/wreckage

	var/list/equipment = new
	var/obj/item/mecha_parts/mecha_equipment/selected
	var/max_equip = 3
	var/datum/events/events
	var/turf/crashing = null


	var/stepsound = 'sound/mecha/mechstep.ogg'
	var/turnsound = 'sound/mecha/mechturn.ogg'

	var/melee_cooldown = 10
	var/melee_can_hit = 1

	hud_possible = list (DIAG_STAT_HUD, DIAG_BATT_HUD, DIAG_MECH_HUD)

/obj/mecha/New()
	..()
	events = new
	icon_state += "-open"
	add_radio()
	add_cabin()

	if(!add_airtank()) //we check this here in case mecha does not have an internal tank available by default - WIP
		removeVerb(/obj/mecha/verb/connect_to_port)
		removeVerb(/obj/mecha/verb/toggle_internal_tank)

	spark_system.set_up(2, 0, src)
	spark_system.attach(src)
	add_cell()

	processing_objects.Add(src)
	removeVerb(/obj/mecha/verb/disconnect_from_port)
	log_message("[src] created.")
	mechas_list += src //global mech list
	prepare_huds()
	var/datum/atom_hud/data/diagnostic/diag_hud = huds[DATA_HUD_DIAGNOSTIC]
	diag_hud.add_to_hud(src)
	diag_hud_set_mechhealth()
	diag_hud_set_mechcell()
	diag_hud_set_mechstat()

////////////////////////
////// Helpers /////////
////////////////////////

/obj/mecha/proc/removeVerb(verb_path)
	verbs -= verb_path

/obj/mecha/proc/addVerb(verb_path)
	verbs += verb_path

/obj/mecha/proc/add_airtank()
	internal_tank = new /obj/machinery/portable_atmospherics/canister/air(src)
	return internal_tank

/obj/mecha/proc/add_cell(var/obj/item/weapon/stock_parts/cell/C=null)
	if(C)
		C.forceMove(src)
		cell = C
		return
	cell = new(src)
	cell.charge = 15000
	cell.maxcharge = 15000

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
	..(user)
	var/integrity = health/initial(health)*100
	switch(integrity)
		if(85 to 100)
			to_chat(user, "It's fully intact.")
		if(65 to 85)
			to_chat(user, "It's slightly damaged.")
		if(45 to 65)
			to_chat(user, "It's badly damaged.")
		if(25 to 45)
			to_chat(user, "It's heavily damaged.")
		else
			to_chat(user, "It's falling apart.")
	if(equipment && equipment.len)
		to_chat(user, "It's equipped with:")
		for(var/obj/item/mecha_parts/mecha_equipment/ME in equipment)
			to_chat(user, "[bicon(ME)] [ME]")


/obj/mecha/proc/drop_item()//Derpfix, but may be useful in future for engineering exosuits.
	return

/obj/mecha/hear_talk(mob/M as mob, text)
	if(M == occupant && radio.broadcasting)
		radio.talk_into(M, text)


/obj/mecha/proc/click_action(atom/target, mob/user, params)
	if(!occupant || occupant != user )
		return
	if(user.incapacitated())
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

	if(!target.Adjacent(src))
		if(selected && selected.is_ranged())
			selected.action(target, params)
	else if(selected && selected.is_melee())
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



/atom/proc/mech_melee_attack(obj/mecha/M)
	return

/obj/mecha/mech_melee_attack(obj/mecha/M)
	if(M.damtype =="brute")
		playsound(src, 'sound/weapons/punch4.ogg', 50, 1)
	else if(M.damtype == "fire")
		playsound(src, 'sound/items/Welder.ogg', 50, 1)
	else
		return
	M.occupant_message("<span class='danger'>You hit [src].</span>")
	visible_message("<span class='danger'>[src] has been hit by [M.name].</span>")
	take_damage(M.force, damtype)
	add_logs(M.occupant, src, "attacked", object=M, addition="(INTENT: [uppertext(M.occupant.a_intent)]) (DAMTYPE: [uppertext(M.damtype)])")
	return

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
	if(!can_move)
		return 0
	if(!Process_Spacemove(direction))
		return 0
	if(!has_charge(step_energy_drain))
		return 0

	var/move_result = 0
	if(internal_damage & MECHA_INT_CONTROL_LOST)
		move_result = mechsteprand()
	else if(dir != direction)
		move_result = mechturn(direction)
	else
		move_result = mechstep(direction)

	can_move = 0
	spawn(step_in)
		can_move = 1

	if(move_result)
		use_power(step_energy_drain)
		return 1
	return 0


/obj/mecha/proc/mechturn(direction)
	dir = direction
	if(turnsound)
		playsound(src,turnsound,40,1)
	return 1

/obj/mecha/proc/mechstep(direction)
	var/result = step(src,direction)
	if(result && stepsound)
		playsound(src,stepsound,40,1)
	return result

/obj/mecha/proc/mechsteprand()
	var/result = step_rand(src)
	if(result && stepsound)
		playsound(src,stepsound,40,1)
	return result



/obj/mecha/Bump(var/atom/obstacle, bump_allowed)
	if(throwing) //high velocity mechas in your face!
		var/breakthrough = 0
		if(istype(obstacle, /obj/structure/window))
			qdel(obstacle)
			breakthrough = 1

		else if(istype(obstacle, /obj/structure/grille/))
			var/obj/structure/grille/G = obstacle
			G.health = (0.25*initial(G.health))
			G.destroyed = 1
			G.icon_state = "[initial(G.icon_state)]-b"
			G.density = 0
			new /obj/item/stack/rods(get_turf(G.loc))
			breakthrough = 1

		else if(istype(obstacle, /obj/structure/table))
			var/obj/structure/table/T = obstacle
			qdel(T)
			breakthrough = 1

		else if(istype(obstacle, /obj/structure/rack))
			new /obj/item/weapon/rack_parts(obstacle.loc)
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
			throwing = 0 //so mechas don't get stuck when landing after being sent by a Mass Driver
			crashing = null

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

/obj/mecha/proc/check_for_internal_damage(var/list/possible_int_damage,var/ignore_threshold=null)
	if(!islist(possible_int_damage) || isemptylist(possible_int_damage)) return
	if(prob(20))
		if(ignore_threshold || health*100/initial(health)<internal_damage_threshold)
			for(var/T in possible_int_damage)
				if(internal_damage & T)
					possible_int_damage -= T
			var/int_dam_flag = safepick(possible_int_damage)
			if(int_dam_flag)
				setInternalDamage(int_dam_flag)
	if(prob(5))
		if(ignore_threshold || health*100/initial(health)<internal_damage_threshold)
			var/obj/item/mecha_parts/mecha_equipment/destr = safepick(equipment)
			if(destr)
				qdel(destr)
	return

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

/obj/mecha/proc/take_damage(amount, type="brute")
	if(amount)
		var/damage = absorbDamage(amount,type)
		health -= damage
		update_health()
		log_append_to_last("Took [damage] points of damage. Damage type: \"[type]\".",1)
	return

/obj/mecha/proc/absorbDamage(damage,damage_type)
	return call((proc_res["dynabsorbdamage"]||src), "dynabsorbdamage")(damage,damage_type)

/obj/mecha/proc/dynabsorbdamage(damage,damage_type)
	return damage*(listgetindex(damage_absorption,damage_type) || 1)


/obj/mecha/proc/update_health()
	if(health > 0)
		spark_system.start()
		diag_hud_set_mechhealth()
	else
		qdel(src)
	return

/obj/mecha/attack_hand(mob/living/user as mob)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	log_message("Attack by hand/paw. Attacker - [user].",1)

	if((HULK in user.mutations) && !prob(deflect_chance))
		take_damage(15)
		check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
		user.visible_message("<span class='danger'>[user] hits [name], doing some damage.</span>",
		"<span class='danger'>You hit [name] with all your might. The metal creaks and bends.</span>")
	else
		user.visible_message("<span class='danger'>[user] hits [name]. Nothing happens</span>","<span class='danger'>You hit [name] with no visible effect.</span>")
		log_append_to_last("Armor saved.")
	return


/obj/mecha/attack_alien(mob/living/user as mob)
	log_message("Attack by alien. Attacker - [user].",1)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	if(!prob(deflect_chance))
		take_damage(15)
		check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
		playsound(loc, 'sound/weapons/slash.ogg', 50, 1, -1)
		to_chat(user, "\red You slash at the armored suit!")
		visible_message("\red The [user] slashes at [name]'s armor!")
	else
		log_append_to_last("Armor saved.")
		playsound(loc, 'sound/weapons/slash.ogg', 50, 1, -1)
		to_chat(user, "\green Your claws had no effect!")
		occupant_message("\blue The [user]'s claws are stopped by the armor.")
		visible_message("\blue The [user] rebounds off [name]'s armor!")
	return


/obj/mecha/attack_animal(mob/living/simple_animal/user as mob)
	log_message("Attack by simple animal. Attacker - [user].",1)
	if(user.melee_damage_upper == 0)
		user.custom_emote(1, "[user.friendly] [src]")
	else
		user.do_attack_animation(src)
		if(!prob(deflect_chance))
			var/damage = rand(user.melee_damage_lower, user.melee_damage_upper)
			take_damage(damage)
			check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
			visible_message("<span class='danger'>[user]</span> [user.attacktext] [src]!")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name]</font>")
		else
			log_append_to_last("Armor saved.")
			playsound(loc, 'sound/weapons/slash.ogg', 50, 1, -1)
			occupant_message("\blue The [user]'s attack is stopped by the armor.")
			visible_message("\blue The [user] rebounds off [name]'s armor!")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [name]</font>")
	return

/obj/mecha/hitby(atom/movable/A as mob|obj) //wrapper
	..()
	log_message("Hit by [A].",1)

	var/def_coeff = 1
	var/dam_coeff = 1
	var/counter_tracking = 0
	for(var/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/B in equipment)
		if(B.projectile_react())
			def_coeff = B.deflect_coeff
			dam_coeff = B.damage_coeff
			counter_tracking = 1
			break
	if(istype(A, /obj/item/mecha_parts/mecha_tracking))
		if(!counter_tracking)
			A.forceMove(src)
			visible_message("The [A] fastens firmly to [src].")
			return

	if(prob(deflect_chance * def_coeff) || ismob(A))
		occupant_message("<span class='danger'>[A] bounces off the armor.</span>")
		visible_message("<span class='danger'>[A] bounces off the [src]\s armor!</span>")
		log_append_to_last("Armor saved.")
		if(isliving(A))
			var/mob/living/M = A
			M.take_organ_damage(10)

	if(isobj(A))
		var/obj/O = A
		if(O.throwforce)
			take_damage(O.throwforce * dam_coeff)
			check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))


/obj/mecha/bullet_act(var/obj/item/projectile/Proj) //wrapper
	log_message("Hit by projectile. Type: [Proj.name]([Proj.flag]).",1)

	var/deflection = 1
	var/dam_coeff = 1
	for(var/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/B in equipment)
		if(B.projectile_react())
			deflection = B.deflect_coeff
			dam_coeff = B.damage_coeff
			break

	if(prob(deflect_chance & deflection) && (Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		visible_message("<span class='danger'>[src] is hit by [Proj].</span>")
		take_damage(Proj.damage * dam_coeff, Proj.flag)
		check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT))
	Proj.on_hit(src)


/obj/mecha/Destroy()
	go_out()
	for(var/mob/M in src) //Let's just be ultra sure
		if(isAI(M))
			M.gib() //AIs are loaded into the mech computer itself. When the mech dies, so does the AI. Forever.
		else
			M.forceMove(loc)

	if(prob(30))
		explosion(get_turf(loc), 0, 0, 1, 3)

	if(wreckage)
		var/obj/effect/decal/mecha_wreckage/WR = new wreckage(loc)
		for(var/obj/item/mecha_parts/mecha_equipment/E in equipment)
			if(E.salvageable && prob(30))
				WR.crowbar_salvage += E
				E.forceMove(WR)
				E.equip_ready = 1
				E.reliability = round(rand(E.reliability/3,E.reliability))
			else
				E.forceMove(loc)
				qdel(E)
		if(cell)
			WR.crowbar_salvage += cell
			cell.forceMove(WR)
			cell.charge = rand(0, cell.charge)
		if(internal_tank)
			WR.crowbar_salvage += internal_tank
			internal_tank.forceMove(WR)
	else
		for(var/obj/item/mecha_parts/mecha_equipment/E in equipment)
			E.forceMove(loc)
			qdel(E)
		if(cell)
			qdel(cell)
		if(internal_tank)
			qdel(internal_tank)

	processing_objects.Remove(src)
	equipment.Cut()
	cell = null
	internal_tank = null
	if(loc)
		loc.assume_air(cabin_air)
		air_update_turf()
	else
		qdel(cabin_air)
	cabin_air = null
	qdel(spark_system)
	spark_system = null

	mechas_list -= src //global mech list
	return ..()

/obj/mecha/ex_act(severity)
	log_message("Affected by explosion of severity: [severity].",1)
	if(prob(deflect_chance))
		severity++
		log_append_to_last("Armor saved, changing severity to [severity].")
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(30))
				qdel(src)
			else
				take_damage(initial(health)/2)
				check_for_internal_damage(list(MECHA_INT_FIRE, MECHA_INT_TEMP_CONTROL, MECHA_INT_TANK_BREACH, MECHA_INT_CONTROL_LOST, MECHA_INT_SHORT_CIRCUIT), 1)
		if(3)
			if(prob(5))
				qdel(src)
			else
				take_damage(initial(health) / 5)
				check_for_internal_damage(list(MECHA_INT_FIRE, MECHA_INT_TEMP_CONTROL, MECHA_INT_TANK_BREACH, MECHA_INT_CONTROL_LOST, MECHA_INT_SHORT_CIRCUIT), 1)

//TODO
/obj/mecha/blob_act()
	take_damage(30, "brute")
	return

/obj/mecha/emp_act(severity)
	if(get_charge())
		use_power((cell.charge / 2) / severity)
		take_damage(50 / severity, "energy")
	log_message("EMP detected", 1)
	check_for_internal_damage(list(MECHA_INT_FIRE, MECHA_INT_TEMP_CONTROL, MECHA_INT_CONTROL_LOST, MECHA_INT_SHORT_CIRCUIT), 1)

/obj/mecha/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > max_temperature)
		log_message("Exposed to dangerous temperature.", 1)
		take_damage(5, "fire")
		check_for_internal_damage(list(MECHA_INT_FIRE, MECHA_INT_TEMP_CONTROL))

//////////////////////
////// AttackBy //////
//////////////////////

/obj/mecha/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/device/mmi))
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
				var/obj/item/weapon/card/id/id_card
				if(istype(W, /obj/item/weapon/card/id))
					id_card = W
				else
					var/obj/item/device/pda/pda = W
					id_card = pda.id
				output_maintenance_dialog(id_card, user)
				return
			else
				to_chat(user, "<span class='warning'>Invalid ID: Access denied.</span>")
		else
			to_chat(user, "<span class='warning'>Maintenance protocols disabled by operator.</span>")

	else if(iswrench(W))
		if(state==1)
			state = 2
			to_chat(user, "You undo the securing bolts.")
		else if(state==2)
			state = 1
			to_chat(user, "You tighten the securing bolts.")
		return

	else if(iscrowbar(W))
		if(state==2)
			state = 3
			to_chat(user, "You open the hatch to the power unit")
		else if(state==3)
			state=2
			to_chat(user, "You close the hatch to the power unit")
		else if(state==4 && pilot_is_mmi())
			// Since having maint protocols available is controllable by the MMI, I see this as a consensual way to remove an MMI without destroying the mech
			user.visible_message("[user] begins levering out the MMI from the [src].", "You begin to lever out the MMI from the [src].")
			to_chat(occupant, "<span class='warning'>[user] is prying you out of the exosuit!</span>")
			if(do_after(user,80,target=src))
				user.visible_message("<span class='notice'>[user] pries the MMI out of the [src]!</span>", "<span class='notice'>You finish removing the MMI from the [src]!</span>")
				go_out()
		return

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

	else if(isscrewdriver(W) && user.a_intent != I_HARM)
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
		return

	else if(istype(W, /obj/item/weapon/stock_parts/cell))
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

	else if(iswelder(W) && user.a_intent != I_HARM)
		var/obj/item/weapon/weldingtool/WT = W
		if(health<initial(health))
			if (WT.remove_fuel(0,user))
				if (internal_damage & MECHA_INT_TANK_BREACH)
					clearInternalDamage(MECHA_INT_TANK_BREACH)
					to_chat(user, "<span class='notice'>You repair the damaged gas tank.</span>")
				else
					user.visible_message("<span class='notice'>[user] repairs some damage to [name].</span>")
					health += min(10, initial(health)-health)
			else
				to_chat(user, "<span class='warning'>The welder must be on for this task!</span>")
				return 1
		else
			to_chat(user, "<span class='warning'>The [name] is at full integrity!</span>")
		return 1

	else if(istype(W, /obj/item/mecha_parts/mecha_tracking))
		if(!user.unEquip(W))
			to_chat(user, "<span class='notice'>\the [W] is stuck to your hand, you cannot put it in \the [src]</span>")
			return
		W.forceMove(src)
		user.visible_message("[user] attaches [W] to [src].", "<span class='notice'>You attach [W] to [src].</span>")
		return

	else if(istype(W, /obj/item/weapon/paintkit))
		if(occupant)
			to_chat(user, "You can't customize a mech while someone is piloting it - that would be unsafe!")
			return

		var/obj/item/weapon/paintkit/P = W
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

	else
		return attacked_by(W, user)

/obj/mecha/proc/attacked_by(obj/item/I, mob/user)
	log_message("Attacked by [I]. Attacker - [user]")
	var/deflection = deflect_chance
	var/dam_coeff = 1
	for(var/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster/B in equipment)
		if(B.attack_react(user))
			deflection *= B.deflect_coeff
			dam_coeff *= B.damage_coeff
			break
	if(prob(deflection))
		to_chat(user, "<span class='danger'>[I] bounces off [src]\s armor.</span>")
		log_append_to_last("Armor saved.")
	else
		user.visible_message("<span class='danger'>[user] hits [src] with [I].</span>", "<span class='danger'>You hit [src] with [I].</span>")
		take_damage(round(I.force * dam_coeff), I.damtype)
		check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))


/obj/mecha/emag_act(user as mob)
	if(istype(src,	/obj/mecha/working/ripley) && emagged == 0)
		emagged = 1
		to_chat(usr, "\blue You slide the card through the [src]'s ID slot.")
		playsound(loc, "sparks", 100, 1)
		desc += "</br><span class='danger'>The mech's equipment slots spark dangerously!</span>"
	else
		to_chat(usr, "\red The [src]'s ID slot rejects the card.")
	return


/////////////////////////////////////
//////////// AI piloting ////////////
/////////////////////////////////////

/obj/mecha/attack_ai(var/mob/living/silicon/ai/user as mob)
	if(!isAI(user))
		return
	//Allows the Malf to scan a mech's status and loadout, helping it to decide if it is a worthy chariot.
	if(user.can_dominate_mechs)
		examine(user) //Get diagnostic information!
		var/obj/item/mecha_parts/mecha_tracking/B = locate(/obj/item/mecha_parts/mecha_tracking) in src
		if(B) //Beacons give the AI more detailed mech information.
			to_chat(user, "<span class='danger'>Warning: Tracking Beacon detected. Enter at your own risk. Beacon Data:")
			to_chat(user, "[B.get_mecha_info()]")
		//Nothing like a big, red link to make the player feel powerful!
		to_chat(user, "<a href='?src=\ref[user];ai_take_control=\ref[src]'><span class='userdanger'>ASSUME DIRECT CONTROL?</span></a><br>")

/obj/mecha/transfer_ai(var/interaction, mob/user, var/mob/living/silicon/ai/AI, var/obj/item/device/aicard/card)
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

		if(AI_MECH_HACK) //Called by Malf AI mob on the mech.
			new /obj/structure/AIcore/deactivated(AI.loc)
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
/obj/mecha/proc/ai_enter_mech(var/mob/living/silicon/ai/AI, var/interaction)
	AI.aiRestorePowerRoutine = 0
	AI.loc = src
	occupant = AI
	icon_state = initial(icon_state)
	playsound(src, 'sound/machines/windowdoor.ogg', 50, 1)
	if(!hasInternalDamage())
		occupant << sound('sound/mecha/nominal.ogg',volume=50)
	AI.cancel_camera()
	AI.controlled_mech = src
	AI.remote_control = src
	AI.canmove = 1 //Much easier than adding AI checks! Be sure to set this back to 0 if you decide to allow an AI to leave a mech somehow.
	AI.can_shunt = 0 //ONE AI ENTERS. NO AI LEAVES.
	to_chat(AI, "[interaction == AI_MECH_HACK ? "<span class='announce'>Takeover of [name] complete! You are now permanently loaded onto the onboard computer. Do not attempt to leave the station sector!</span>" \
	: "<span class='notice'>You have been uploaded to a mech's onboard computer."]")
	to_chat(AI, "<span class='boldnotice'>Use Middle-Mouse to activate mech functions and equipment. Click normally for AI interactions.</span>")

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
	if(connected_port || !new_port || new_port.connected_device)
		return 0

	//Make sure are close enough for a valid connection
	if(new_port.loc != loc)
		return 0

	//Perform the connection
	connected_port = new_port
	connected_port.connected_device = src
	connected_port.parent.reconcile_air()

	log_message("Connected to gas port.")
	return 1

/obj/mecha/proc/disconnect()
	if(!connected_port)
		return 0

	connected_port.connected_device = null
	connected_port = null
	log_message("Disconnected from gas port.")
	return 1

/obj/mecha/portableConnectorReturnAir()
	return internal_tank.return_air()


/////////////////////////
////////  Verbs  ////////
/////////////////////////


/obj/mecha/verb/connect_to_port()
	set name = "Connect to port"
	set category = "Exosuit Interface"
	set src = usr.loc
	set popup_menu = 0
	if(!occupant) return
	if(usr!=occupant)
		return
	var/obj/machinery/atmospherics/unary/portables_connector/possible_port = locate(/obj/machinery/atmospherics/unary/portables_connector/) in loc
	if(possible_port)
		if(connect(possible_port))
			occupant_message("\blue [name] connects to the port.")
			verbs += /obj/mecha/verb/disconnect_from_port
			verbs -= /obj/mecha/verb/connect_to_port
			return
		else
			occupant_message("\red [name] failed to connect to the port.")
			return
	else
		occupant_message("Nothing happens")


/obj/mecha/verb/disconnect_from_port()
	set name = "Disconnect from port"
	set category = "Exosuit Interface"
	set src = usr.loc
	set popup_menu = 0
	if(!occupant) return
	if(usr!=occupant)
		return
	if(disconnect())
		occupant_message("\blue [name] disconnects from the port.")
		verbs -= /obj/mecha/verb/disconnect_from_port
		verbs += /obj/mecha/verb/connect_to_port
	else
		occupant_message("\red [name] is not connected to the port at the moment.")

/obj/mecha/verb/toggle_lights()
	set name = "Toggle Lights"
	set category = "Exosuit Interface"
	set src = usr.loc
	set popup_menu = 0
	if(usr!=occupant)	return
	lights = !lights
	if(lights)	set_light(light_range + lights_power)
	else		set_light(light_range - lights_power)
	occupant_message("Toggled lights [lights?"on":"off"].")
	log_message("Toggled lights [lights?"on":"off"].")
	return


/obj/mecha/verb/toggle_internal_tank()
	set name = "Toggle internal airtank usage."
	set category = "Exosuit Interface"
	set src = usr.loc
	set popup_menu = 0
	if(usr!=occupant)
		return
	use_internal_tank = !use_internal_tank
	occupant_message("Now taking air from [use_internal_tank?"internal airtank":"environment"].")
	log_message("Now taking air from [use_internal_tank?"internal airtank":"environment"].")
	return


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
	for(var/mob/living/carbon/slime/S in range(1,user))
		if(S.Victim == user)
			to_chat(user, "You're too busy getting your life sucked out of you.")
			return

	visible_message("<span class='notice'>[user] starts to climb into [src]")

	if(do_after(user, 40, target = src))
		if(health <= 0)
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
		H.reset_view(src)
		add_fingerprint(H)
		//GrantActions(H, human_occupant=1)
		forceMove(loc)
		log_append_to_last("[H] moved in as pilot.")
		icon_state = reset_icon()
		dir = dir_in
		playsound(src, 'sound/machines/windowdoor.ogg', 50, 1)
		if(!hasInternalDamage())
			occupant << sound('sound/mecha/nominal.ogg', volume = 50)
		return 1
	else
		return 0

/obj/mecha/proc/mmi_move_inside(var/obj/item/device/mmi/mmi_as_oc as obj,mob/user as mob)
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

/obj/mecha/proc/mmi_moved_inside(var/obj/item/device/mmi/mmi_as_oc as obj,mob/user as mob)
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
		brainmob.reset_view(src)
	/*
		brainmob.client.eye = src
		brainmob.client.perspective = EYE_PERSPECTIVE
	*/
		occupant = brainmob
		brainmob.loc = src //should allow relaymove
		brainmob.canmove = 1
		mmi_as_oc.loc = src
		mmi_as_oc.mecha = src
		verbs -= /obj/mecha/verb/eject
		Entered(mmi_as_oc)
		Move(loc)
		icon_state = reset_icon()
		dir = dir_in
		log_message("[mmi_as_oc] moved in as pilot.")
		if(!hasInternalDamage())
			to_chat(occupant, sound('sound/mecha/nominal.ogg',volume=50))
		return 1
	else
		return 0

/obj/mecha/proc/pilot_is_mmi()
	var/atom/movable/mob_container
	if(istype(occupant, /mob/living/carbon/brain))
		var/mob/living/carbon/brain/brain = occupant
		mob_container = brain.container
	if(istype(mob_container, /obj/item/device/mmi))
		return 1
	return 0

/obj/mecha/proc/pilot_mmi_hud(var/mob/living/carbon/brain/pilot)
	return

/obj/mecha/verb/view_stats()
	set name = "View Stats"
	set category = "Exosuit Interface"
	set src = usr.loc
	set popup_menu = 0
	if(usr!=occupant)
		return
	occupant << browse(get_stats_html(), "window=exosuit")
	return

/obj/mecha/verb/eject()
	set name = "Eject"
	set category = "Exosuit Interface"
	set src = usr.loc
	set popup_menu = 0
	if(usr != occupant)
		return
	go_out()
	add_fingerprint(usr)


/obj/mecha/Exited(atom/movable/M, atom/newloc)
	if(occupant && occupant == M) // The occupant exited the mech without calling go_out()
		go_out(1, newloc)

/obj/mecha/proc/go_out(var/forced, var/atom/newloc = loc)
	if(!occupant)
		return
	var/atom/movable/mob_container
	occupant.clear_alert("charge")
	occupant.clear_alert("mech damage")
	if(ishuman(occupant))
		mob_container = occupant
		//RemoveActions(occupant, human_occupant=1)
	else if(istype(occupant, /mob/living/carbon/brain))
		var/mob/living/carbon/brain/brain = occupant
		//RemoveActions(brain)
		mob_container = brain.container
	else if(isAI(occupant) && forced) //This should only happen if there are multiple AIs in a round, and at least one is Malf.
		//RemoveActions(occupant)
		occupant.gib()  //If one Malf decides to steal a mech from another AI (even other Malfs!), they are destroyed, as they have nowhere to go when replaced.
		occupant = null
		return
	else
		return
	var/mob/living/L = occupant
	occupant = null //we need it null when forceMove calls Exited().
	if(mob_container.forceMove(newloc))//ejecting mob container
		log_message("[mob_container] moved out.")
		L << browse(null, "window=exosuit")

		if(istype(mob_container, /obj/item/device/mmi))
			var/obj/item/device/mmi/mmi = mob_container
			if(mmi.brainmob)
				L.loc = mmi
				L.reset_view()
			mmi.mecha = null
			mmi.update_icon()
			L.canmove = 0
		icon_state = initial(icon_state)+"-open"
		dir = dir_in

	if(L && L.client)
		L.client.view = world.view

/////////////////////////
////// Access stuff /////
/////////////////////////

/obj/mecha/proc/operation_allowed(mob/living/carbon/human/H)
	if(!ishuman(H))
		return 0
	for(var/ID in list(H.get_active_hand(), H.wear_id, H.belt))
		if(check_access(ID,operation_req_access))
			return 1
	return 0


/obj/mecha/proc/internals_access_allowed(mob/living/carbon/human/H)
	for(var/atom/ID in list(H.get_active_hand(), H.wear_id, H.belt))
		if(check_access(ID,internals_req_access))
			return 1
	return 0


/obj/mecha/check_access(obj/item/weapon/card/id/I, list/access_list)
	if(!istype(access_list))
		return 1
	if(!access_list.len) //no requirements
		return 1
	if(istype(I, /obj/item/device/pda))
		var/obj/item/device/pda/pda = I
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
		return 1
	return 0

/obj/mecha/proc/give_power(amount)
	if(!isnull(get_charge()))
		cell.give(amount)
		return 1
	return 0

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
					take_damage(4/round(max_temperature/cabin_air.return_temperature(),0.1),"fire")

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


/obj/mecha/speech_bubble(var/bubble_state = "",var/bubble_loc = src, var/list/bubble_recipients = list())
	flick_overlay(image('icons/mob/talk.dmi', bubble_loc, bubble_state,MOB_LAYER+1), bubble_recipients, 30)
