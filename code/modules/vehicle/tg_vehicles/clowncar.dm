/obj/tgvehicle/sealed/car/clowncar
	name = "clown car"
	desc = "How someone could even fit in there is beyond me."
	icon_state = "clowncar"
	max_integrity = 150
	max_occupants = 50
	key_type = /obj/item/bikehorn
	light_range = 6
	light_power = 2
	enter_sound = 'sound/effects/clowncar/door_close.ogg'
	exit_sound = 'sound/effects/clowncar/door_open.ogg'
	/// Traits
	var/car_traits = CAN_KIDNAP
	/// Armor
	var/armor_type = /datum/armor/car_clowncar
	/// How long does it take to get in?
	enter_delay = 4 SECONDS
	/// Are the lights on?
	var/light_on = FALSE
	// /Determines which occupants provide access when bumping into doors
	access_provider_flags = VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_KIDNAPPED
	/// list of headlight colors we use to pick through when we have party mode due to emag
	var/headlight_colors = list(COLOR_RED, COLOR_ORANGE, COLOR_YELLOW, COLOR_LIME, COLOR_BLUE_LIGHT, COLOR_CYAN, COLOR_PURPLE)
	/// Cooldown time inbetween [/obj/tgvehicle/clowncar/proc/roll_the_dice()] usages
	var/dice_cooldown_time = 15 SECONDS
	/// Current status of the cannon, alternates between CLOWN_CANNON_INACTIVE, CLOWN_CANNON_BUSY and CLOWN_CANNON_READY
	var/cannonmode = CLOWN_CANNON_INACTIVE
	/// Does the driver require the clown role to drive it
	var/enforce_clown_role = TRUE
	/// Emag Button Cooldown
	var/last_emag_button_use = 0

/datum/armor/car_clowncar
	melee = 70
	bullet = 40
	laser = 40
	bomb = 30
	fire = 80
	acid = 80

/obj/tgvehicle/clowncar/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj,src)
	RegisterSignal(src, COMSIG_MOVABLE_CHECK_CROSS, PROC_REF(check_crossed))

/obj/tgvehicle/clowncar/process()
	if(light_on && emagged)
		set_light(light_range, light_power, pick(headlight_colors))

/obj/tgvehicle/clowncar/MouseDrop_T(mob/living/M, mob/living/user)
	mob_try_enter(user)

/obj/tgvehicle/clowncar/generate_actions()
	. = ..()
	if(car_traits & CAN_KIDNAP)
		initialize_controller_action_type(/datum/action/vehicle/dump_kidnapped_mobs, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/climb_out, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/horn, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/headlights, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/thank, VEHICLE_CONTROL_KIDNAPPED)

// Getting in the car
/obj/tgvehicle/clowncar/proc/mob_try_enter(mob/rider)
	if(!istype(rider))
		return FALSE
	if (do_after(rider, enter_delay, target = src))
		if(occupant_amount() < max_occupants)
			mob_enter(rider)
		else
			audible_message("<span class='notify'>The clown car is full... somehow.</span>", null, 1)
		return TRUE
	return FALSE

/obj/tgvehicle/clowncar/proc/mob_enter(mob/M, silent = FALSE)
	if(!istype(M))
		return FALSE
	M.visible_message("<span class='notice'>[M] climbs into \the [src]!</span>")
	M.forceMove(src)
	add_occupant(M)
	return TRUE

/obj/tgvehicle/clowncar/auto_assign_occupant_flags(mob/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.mind?.assigned_role == "Clown") // Ensures only clowns can drive the car. (Including more at once)
			add_control_flags(H, VEHICLE_CONTROL_DRIVE)
			RegisterSignal(H, COMSIG_MOB_CLICKON, PROC_REF(fire_cannon_at))
			playsound(src, 'sound/effects/clowncar/door_close.ogg', 70, TRUE)
			log_game("[M] has entered [src] as a possible driver")
			return
	add_control_flags(M, VEHICLE_CONTROL_KIDNAPPED)

/obj/tgvehicle/clowncar/after_add_occupant(mob/M)
	. = ..()
	ADD_TRAIT(M, TRAIT_HANDS_BLOCKED, "clowncar")

// Getting out of the car
/obj/tgvehicle/clowncar/mob_exit(mob/M, silent = FALSE, randomstep = FALSE)
	. = ..()
	UnregisterSignal(M, COMSIG_MOB_CLICKON)

/obj/tgvehicle/clowncar/after_remove_occupant(mob/M)
	. = ..()
	REMOVE_TRAIT(M, TRAIT_HANDS_BLOCKED, "clowncar")

/obj/tgvehicle/clowncar/proc/mob_forced_enter(mob/M, silent = FALSE)
	M.forceMove(src)
	add_occupant(M, VEHICLE_CONTROL_KIDNAPPED)
	playsound(src, pick('sound/effects/clowncar/clowncar_load1.ogg', 'sound/effects/clowncar/clowncar_load2.ogg'), 75)
	if(iscarbon(M))
		var/mob/living/carbon/forced_mob = M
		if(forced_mob.reagents.has_reagent("irishcarbomb"))
			var/reagent_amount = forced_mob.reagents.get_reagent_amount("irishcarbomb")
			forced_mob.reagents.del_reagent("irishcarbomb")
			if(reagent_amount >= 30)
				message_admins("[ADMIN_LOOKUPFLW(forced_mob)] was forced into a clown car with [reagent_amount] unit(s) of Irish Car Bomb, causing an explosion.")
				audible_message("<span class='warning'>You hear a rattling sound coming from the engine. That can't be good...</span>", null, 1)
				addtimer(CALLBACK(src, PROC_REF(irish_car_bomb)), 5 SECONDS)

/obj/tgvehicle/clowncar/proc/irish_car_bomb()
	dump_mobs()
	explosion(src, light_impact_range = 1)

/obj/tgvehicle/clowncar/attack_animal(mob/living/simple_animal/user, list/modifiers)
	if((user.loc != src) || user.environment_smash >= ENVIRONMENT_SMASH_WALLS)
		return ..()

/obj/tgvehicle/clowncar/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(prob(33))
		visible_message("<span class='warning'>[src] spews out a ton of space lube!</span>")
		var/datum/effect_system/foam_spread/L = new()
		var/datum/reagents/foamreagent = new /datum/reagents(25)
		foamreagent.add_reagent(/datum/reagent/lube, 25)
		L.set_up(40, loc, foamreagent)
		L.start()

/obj/tgvehicle/clowncar/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(!istype(I, /obj/item/food/grown/banana))
		return
	var/obj/item/food/grown/banana/banana = I
	obj_integrity += min(banana.seed.potency, max_integrity-obj_integrity)
	to_chat(user, "<span class='warning'>You use the [banana] to repair [src]!</span>")
	qdel(banana)

/obj/tgvehicle/clowncar/proc/dump_mobs(randomstep = TRUE)
	for(var/i in occupants)
		mob_exit(i, randomstep = randomstep)
		if(iscarbon(i))
			var/mob/living/carbon/Carbon = i
			Carbon.apply_effect(4 SECONDS, PARALYZE)

/obj/tgvehicle/clowncar/Bump(atom/bumped)
	. = ..()
	if(istype(bumped, /obj/machinery/door))
		var/obj/machinery/door/conditionalwall = bumped
		for(var/mob/occupant as anything in return_controllers_with_flag(access_provider_flags))
			if(conditionalwall.try_to_activate_door(occupant))
				return
			conditionalwall.bumpopen(occupant)

	if(isliving(bumped))
		if(ismegafauna(bumped)) //No, you cannot kidnap megafauna with the clown car
			return
		var/mob/living/hittarget_living = bumped

		if(istype(hittarget_living, /mob/living/basic/deer))
			visible_message("<span class='warning'>[src] careens into [hittarget_living]! Oh the humanity!</span>")
			for(var/mob/living/carbon/carbon_occupant in occupants)
				if(prob(35)) // Note: The randomstep on dump_mobs throws occupants into each other and often causes wounds regardless.
					continue
			hittarget_living.adjustBruteLoss(200)
			new /obj/effect/decal/cleanable/blood/splatter(get_turf(hittarget_living))

			// log_combat(src, hittarget_living, "rammed into", null, "injuring all passengers and killing the [hittarget_living]")
			dump_mobs(TRUE)
			playsound(src, 'sound/effects/clowncar/car_crash.ogg', 100)
			return

		if(iscarbon(hittarget_living))
			var/mob/living/carbon/C = hittarget_living
			C.Paralyse(4 SECONDS) //I play to make sprites go horizontal
		hittarget_living.visible_message("<span class='warning'>[src] rams into [hittarget_living] and sucks [hittarget_living.p_them()] up!</span>")
		mob_forced_enter(hittarget_living)
		playsound(src, pick('sound/effects/clowncar/clowncar_ram1.ogg', 'sound/effects/clowncar/clowncar_ram2.ogg', 'sound/effects/clowncar/clowncar_ram3.ogg'), 75)
		//log_combat(src, hittarget_living, "sucked up")
		return
	if(isturf(bumped))
		var/turf/bumped_turf = bumped
		if(!bumped_turf.is_blocked_turf())
			return
	visible_message("<span class='warning'>[src] rams into [bumped] and crashes!</span>")
	playsound(src, pick('sound/effects/clowncar/clowncar_crash1.ogg', 'sound/effects/clowncar/clowncar_crash2.ogg'), 75)
	playsound(src, 'sound/effects/clowncar/clowncar_crashpins.ogg', 75)
	dump_mobs(TRUE)
	//log_combat(src, bumped, "crashed into", null, "dumping all passengers")

/obj/tgvehicle/clowncar/proc/check_crossed(datum/source, atom/movable/crossed)
	SIGNAL_HANDLER // COMSIG_MOVABLE_CHECK_CROSS
	if(!has_gravity())
		return
	if(!iscarbon(crossed))
		return
	var/mob/living/carbon/target_pancake = crossed
	if(target_pancake.body_position != LYING_DOWN)
		return
	if(HAS_TRAIT(target_pancake, TRAIT_KNOCKEDOUT))
		return
	target_pancake.visible_message("<span class='warning'>[src] runs over [target_pancake], flattening [target_pancake.p_them()] like a pancake!</span>")
	target_pancake.AddElement(/datum/element/squish, 5 SECONDS)
	target_pancake.apply_effect(2 SECONDS, PARALYZE)
	playsound(target_pancake, 'sound/effects/clowncar/cartoon_splat.ogg', 75)
	//log_combat(src, crossed, "ran over")

/obj/tgvehicle/clowncar/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(emagged)
		return FALSE
	emagged = TRUE
	to_chat(user, "<span class='warning'>You scramble [src]'s child safety lock, and a panel with six colorful buttons appears!</span>")
	initialize_controller_action_type(/datum/action/vehicle/roll_the_dice, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/cannon, VEHICLE_CONTROL_DRIVE)
	return TRUE

/obj/tgvehicle/clowncar/obj_destruction(damage_flag)
	playsound(src, 'sound/misc/sadtrombone.ogg', 100)
	STOP_PROCESSING(SSobj,src)
	return ..()

/**
 * Plays a random funky effect
 * Only available while car is emagged
 * Possible effects:
 * * Spawn bananapeel
 * * Spawn random reagent foam
 * * Make the clown car look like a singulo temporarily
 * * Spawn Laughing chem gas
 * * Drop oil
 * * Fart and make everyone nearby laugh
 */

//clown car cooldowns

/obj/tgvehicle/clowncar/proc/roll_the_dice(mob/user)
	if(last_emag_button_use + dice_cooldown_time > world.time)
		to_chat(user, "<span class=notice'>The button panel is currently recharging.</span>")
		return
	last_emag_button_use = world.time
	switch(rand(1,6))
		if(1)
			visible_message("<span class='warning'>[user] presses one of the colorful buttons on [src], and a special banana peel drops out of it.</span>")
			new /obj/item/grown/bananapeel/specialpeel(loc)
		if(2)
			visible_message("<span class='warning'>[user] presses one of the colorful buttons on [src], and unknown chemicals flood out of it.</span>")
			var/datum/reagents/randomchems = new/datum/reagents(300)
			randomchems.my_atom = src
			randomchems.add_reagent(get_random_reagent_id(), 100)
			var/datum/effect_system/foam_spread/foam = new()
			foam.set_up(200, src, randomchems)
			foam.start()
		if(3)
			visible_message("<span class='warning'>[user] presses one of the colorful buttons on [src], and the clown car turns on its singularity disguise system.</span>")
			icon = 'icons/obj/singularity.dmi'
			icon_state = "singularity_s1"
			addtimer(CALLBACK(src, PROC_REF(reset_icon)), 10 SECONDS)
		if(4)
			visible_message("<span class='warning'>[user] presses one of the colorful buttons on [src], and the clown car spews out a cloud of confetti all over the place.</span>")
			confettisize(src, 50, 8)
		if(5)
			visible_message("<span class='warning'>[user] presses one of the colorful buttons on [src], and the clown car starts dropping a lubricant trail.</span>")
			RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(cover_in_oil))
			addtimer(CALLBACK(src, PROC_REF(stop_dropping_oil)), 3 SECONDS)
		if(6)
			visible_message("<span class='warning'>[user] presses one of the colorful buttons on [src], and the clown car lets out a comedic toot.</span>")
			playsound(src, 'sound/effects/clowncar/clowncar_fart.ogg', 100)
			for(var/mob/living/L in orange(loc, 6))
				L.emote("laugh")
			for(var/mob/living/L as anything in occupants)
				L.emote("laugh")

///resets the icon and iconstate of the clowncar after it was set to singulo states
/obj/tgvehicle/clowncar/proc/reset_icon()
	icon = initial(icon)
	icon_state = initial(icon_state)

///Deploys oil when the clowncar moves in oil deploy mode
/obj/tgvehicle/clowncar/proc/cover_in_oil()
	SIGNAL_HANDLER
	var/turf/simulated/T = get_turf(src)
	T.MakeSlippery(TURF_WET_LUBE)

///Stops dropping oil after the time has run up
/obj/tgvehicle/clowncar/proc/stop_dropping_oil()
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)

///Toggles the on and off state of the clown cannon that shoots random kidnapped people
/obj/tgvehicle/clowncar/proc/toggle_cannon(mob/user)
	if(cannonmode == CLOWN_CANNON_BUSY)
		to_chat(user, "<span class='notice'>Please wait for the vehicle to finish its current action first.</span>")
		return
	if(cannonmode) //canon active, deactivate
		flick("clowncar_fromfire", src)
		icon_state = "clowncar"
		addtimer(CALLBACK(src, PROC_REF(deactivate_cannon)), 2 SECONDS)
		playsound(src, 'sound/effects/clowncar/clowncar_cannonmode2.ogg', 75)
		visible_message("<span class='warning'>[src] starts going back into mobile mode.</span>")
	else
		canmove = FALSE //anchor and activate canon
		flick("clowncar_tofire", src)
		icon_state = "clowncar_fire"
		visible_message("<span class='warning'>[src] opens up and reveals a large cannon.</span>")
		addtimer(CALLBACK(src, PROC_REF(activate_cannon)), 2 SECONDS)
		playsound(src, 'sound/effects/clowncar/clowncar_cannonmode1.ogg', 75)
	cannonmode = CLOWN_CANNON_BUSY

///Finalizes canon activation
/obj/tgvehicle/clowncar/proc/activate_cannon()
	var/mouse_pointer = 'icons/effects/mouse_pointers/weapon_pointer.dmi'
	cannonmode = CLOWN_CANNON_READY
	for(var/mob/living/driver as anything in return_controllers_with_flag(VEHICLE_CONTROL_DRIVE))
		if(driver.client.mouse_pointer_icon == initial(driver.client.mouse_pointer_icon))
			driver.client.mouse_pointer_icon = mouse_pointer

///Finalizes canon deactivation
/obj/tgvehicle/clowncar/proc/deactivate_cannon()
	canmove = TRUE
	cannonmode = CLOWN_CANNON_INACTIVE
	for(var/mob/living/driver as anything in return_controllers_with_flag(VEHICLE_CONTROL_DRIVE))
		driver.client.mouse_pointer_icon = initial(driver.client.mouse_pointer_icon)

///Fires the cannon where the user clicks
/obj/tgvehicle/clowncar/proc/fire_cannon_at(mob/user, atom/target, list/modifiers)
	SIGNAL_HANDLER
	if(cannonmode != CLOWN_CANNON_READY || !length(return_controllers_with_flag(VEHICLE_CONTROL_KIDNAPPED)))
		return
	//The driver can still examine things and interact with his inventory.
	if(modifiers[SHIFT_CLICK] || (ismovable(target) && !isturf(target.loc)))
		return
	var/mob/living/unlucky_sod = pick(return_controllers_with_flag(VEHICLE_CONTROL_KIDNAPPED))
	mob_exit(unlucky_sod, silent = TRUE)
	flick("clowncar_recoil", src)
	playsound(src, pick('sound/effects/clowncar/carcannon1.ogg', 'sound/effects/clowncar/carcannon2.ogg', 'sound/effects/clowncar/carcannon3.ogg'), 75)
	unlucky_sod.throw_at(target, 10, 2)
	//log_combat(user, unlucky_sod, "fired", src, "towards [target]") //this doesn't catch if the mob hits something between the car and the target
	return COMSIG_MOB_CANCEL_CLICKON

