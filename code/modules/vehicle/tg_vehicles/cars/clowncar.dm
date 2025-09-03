/obj/tgvehicle/sealed/car/clowncar
	name = "clown car"
	desc = "How someone could even fit in there is beyond me."
	icon_state = "clowncar"
	max_integrity = 150
	max_occupants = 50
	key_type = /obj/item/bikehorn
	enter_sound = 'sound/effects/clowncar/door_close.ogg'
	exit_sound = 'sound/effects/clowncar/door_open.ogg'
	car_traits = CAN_KIDNAP
	armor = list(MELEE = 70, BULLET = 40, LASER = 40, ENERGY = 40, BOMB = 30, RAD = 0, FIRE = 80, ACID = 80)
	enter_delay = 4 SECONDS
	access_provider_flags = VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_KIDNAPPED
	/// list of headlight colors we use to pick through when we have party mode due to emag
	var/headlight_colors = list(COLOR_RED, COLOR_ORANGE, COLOR_YELLOW, COLOR_LIME, COLOR_BLUE_LIGHT, COLOR_CYAN, COLOR_PURPLE)
	/// Cooldown time inbetween [/obj/tgvehicle/sealed/car/clowncar/proc/roll_the_dice()] usages
	var/dice_cooldown_time = 15 SECONDS
	/// Are we disguised as a singularity?
	var/singulomode = FALSE
	/// Current status of the cannon, alternates between CLOWN_CANNON_INACTIVE, CLOWN_CANNON_BUSY and CLOWN_CANNON_READY
	var/cannonmode = CLOWN_CANNON_INACTIVE
	/// Does the driver require the clown role to drive it
	var/enforce_clown_role = TRUE
	/// Emag Button Cooldown
	var/last_emag_button_use = 0
	/// How fast can you fire the cannon
	var/cannon_fire_delay = 0.5 SECONDS
	COOLDOWN_DECLARE(cannon_cooldown)

/obj/tgvehicle/sealed/car/clowncar/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj,src)

/obj/tgvehicle/sealed/car/clowncar/process()
	if(headlights_toggle && emagged)
		set_light(headlight_range, headlight_power, pick(headlight_colors))

/obj/tgvehicle/sealed/car/clowncar/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/horn, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/headlights, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/thank, VEHICLE_CONTROL_KIDNAPPED)

/obj/tgvehicle/sealed/car/clowncar/auto_assign_occupant_flags(mob/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		// Only clowns can drive the car, unless an admin varedits the car to allow someone else to drive.
		if(H.mind?.assigned_role == "Clown" || (!enforce_clown_role && length(return_controllers_with_flag(VEHICLE_CONTROL_DRIVE)) < 1))
			add_control_flags(H, VEHICLE_CONTROL_DRIVE)
			playsound(src, 'sound/effects/clowncar/door_close.ogg', 70, TRUE)
			log_game("[M] has entered [src] as a possible driver")
			return
	add_control_flags(M, VEHICLE_CONTROL_KIDNAPPED)

/obj/tgvehicle/sealed/car/clowncar/mob_forced_enter(mob/M)
	. = ..()
	playsound(src, pick('sound/effects/clowncar/clowncar_load1.ogg', 'sound/effects/clowncar/clowncar_load2.ogg'), 75)
	if(iscarbon(M))
		var/mob/living/carbon/forced_mob = M
		if(forced_mob.reagents.has_reagent("dublindrop"))
			var/reagent_amount = forced_mob.reagents.get_reagent_amount("dublindrop")
			forced_mob.reagents.del_reagent("dublindrop")
			if(reagent_amount >= 30)
				message_admins("[ADMIN_LOOKUPFLW(forced_mob)] was forced into a clown car with [reagent_amount] unit(s) of Irish Car Bomb, causing an explosion.")
				audible_message("<span class='warning'>You hear a rattling sound coming from the engine. That can't be good...</span>", null, 1)
				addtimer(CALLBACK(src, PROC_REF(irish_car_bomb)), 5 SECONDS)

// We don't want everything in the clown car to get dusted when it touches the supermatter, so dump the mobs.
/obj/tgvehicle/sealed/car/clowncar/on_entered_supermatter(atom/movable/vehicle, atom/movable/supermatter)
	dump_mobs(TRUE)

/obj/tgvehicle/sealed/car/clowncar/proc/irish_car_bomb()
	dump_mobs()
	explosion(src, light_impact_range = 1)

/obj/tgvehicle/sealed/car/clowncar/attack_animal(mob/living/simple_animal/user, list/modifiers)
	if((user.loc != src) || user.environment_smash >= ENVIRONMENT_SMASH_WALLS)
		return ..()

/obj/tgvehicle/sealed/car/clowncar/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(prob(33))
		visible_message("<span class='warning'>[src] spews out a ton of space lube!</span>")
		var/datum/effect_system/foam_spread/L = new()
		var/datum/reagents/foamreagent = new /datum/reagents(200)
		foamreagent.add_reagent("lube", 200)
		L.set_up(40, get_turf(src), foamreagent)
		L.start()

/obj/tgvehicle/sealed/car/clowncar/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(!istype(I, /obj/item/food/grown/banana))
		return
	var/obj/item/food/grown/banana/banana = I
	obj_integrity += min(banana.seed.potency, max_integrity-obj_integrity)
	to_chat(user, "<span class='warning'>You use the [banana] to repair [src]!</span>")
	qdel(banana)

/obj/tgvehicle/sealed/car/clowncar/Bump(atom/bumped)
	. = ..()
	if(isliving(bumped))
		if(ismegafauna(bumped)) // No, you cannot kidnap megafauna with the clown car
			return
		var/mob/living/hittarget_living = bumped

		if(istype(hittarget_living, /mob/living/basic/deer))
			visible_message("<span class='warning'>[src] careens into [hittarget_living]! Oh the humanity!</span>")
			for(var/mob/living/carbon/carbon_occupant in occupants)
				if(prob(35)) // Note: The randomstep on dump_mobs throws occupants into each other and often causes wounds regardless.
					continue
			hittarget_living.adjustBruteLoss(200)
			new /obj/effect/decal/cleanable/blood/splatter(get_turf(hittarget_living))

			dump_mobs(TRUE)
			playsound(src, 'sound/effects/clowncar/car_crash.ogg', 100)
			return

		if(iscarbon(hittarget_living))
			var/mob/living/carbon/C = hittarget_living
			C.Stun(4 SECONDS) // I play to make sprites go horizontal
		hittarget_living.visible_message("<span class='warning'>[src] rams into [hittarget_living] and sucks [hittarget_living.p_them()] up!</span>")
		mob_forced_enter(hittarget_living)
		playsound(src, pick('sound/effects/clowncar/clowncar_ram1.ogg', 'sound/effects/clowncar/clowncar_ram2.ogg', 'sound/effects/clowncar/clowncar_ram3.ogg'), 75)
		log_attack(src, hittarget_living, "sucked up")
		return
	if(isturf(bumped))
		var/turf/bumped_turf = bumped
		if(!bumped_turf.is_blocked_turf())
			return
	if(istype(bumped, /obj/machinery/door))
		var/obj/machinery/door/conditionalwall = bumped
		for(var/mob/occupant as anything in return_controllers_with_flag(access_provider_flags))
			if(conditionalwall.allowed(occupant))
				return
			if(conditionalwall.operating)
				return
	visible_message("<span class='warning'>[src] rams into [bumped] and crashes!</span>")
	playsound(src, pick('sound/effects/clowncar/clowncar_crash1.ogg', 'sound/effects/clowncar/clowncar_crash2.ogg'), 75)
	playsound(src, 'sound/effects/clowncar/clowncar_crashpins.ogg', 75)
	dump_mobs(TRUE)
	log_attack(src, bumped, "crashed into", null)

/obj/tgvehicle/sealed/car/clowncar/after_move(direction)
	..()
	if(!has_gravity(src))
		return
	var/mob/possible_pancake = locate(/mob/living/carbon) in loc
	if(!possible_pancake)
		return
	if(possible_pancake.loc == src)
		return
	if(!iscarbon(possible_pancake))
		return
	var/mob/living/carbon/target_pancake = possible_pancake
	if(target_pancake.body_position != LYING_DOWN)
		return
	if(HAS_TRAIT(target_pancake, TRAIT_CLOWN_CAR_SQUISHED))
		return
	target_pancake.visible_message("<span class='warning'>[src] runs over [target_pancake], flattening [target_pancake.p_them()] like a pancake!</span>")
	handle_squish_carbon(target_pancake, 30)
	ADD_TRAIT(target_pancake, TRAIT_CLOWN_CAR_SQUISHED, "clown_car")
	addtimer(CALLBACK(src, PROC_REF(allow_resquish), target_pancake), 5 SECONDS)
	target_pancake.Stun(2 SECONDS)
	playsound(target_pancake, 'sound/effects/clowncar/cartoon_splat.ogg', 75)
	log_attack(src, target_pancake, "ran over")

/obj/tgvehicle/sealed/car/clowncar/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(emagged)
		return FALSE
	emagged = TRUE
	to_chat(user, "<span class='warning'>You scramble [src]'s child safety lock, and a panel with six colorful buttons appears!</span>")
	initialize_controller_action_type(/datum/action/vehicle/sealed/roll_the_dice, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/cannon, VEHICLE_CONTROL_DRIVE)
	return TRUE

/obj/tgvehicle/sealed/car/clowncar/obj_destruction(damage_flag)
	playsound(src, 'sound/misc/sadtrombone.ogg', 100)
	STOP_PROCESSING(SSobj,src)
	return ..()

/obj/tgvehicle/sealed/car/clowncar/proc/allow_resquish(mob/living/carbon/pancake)
	REMOVE_TRAIT(pancake, TRAIT_CLOWN_CAR_SQUISHED, "clown_car")

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

/obj/tgvehicle/sealed/car/clowncar/proc/roll_the_dice(mob/user)
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
			singulomode = TRUE
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

/// resets the icon and iconstate of the clowncar after it was set to singulo states
/obj/tgvehicle/sealed/car/clowncar/proc/reset_icon()
	icon = initial(icon)
	icon_state = initial(icon_state)
	singulomode = FALSE
	if(cannonmode)
		icon_state = "clowncar_fire"

/// Deploys oil when the clowncar moves in oil deploy mode
/obj/tgvehicle/sealed/car/clowncar/proc/cover_in_oil()
	SIGNAL_HANDLER
	var/turf/simulated/T = get_turf(src)
	T.MakeSlippery(TURF_WET_LUBE)

/// Stops dropping oil after the time has run up
/obj/tgvehicle/sealed/car/clowncar/proc/stop_dropping_oil()
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)

/// Toggles the on and off state of the clown cannon that shoots random kidnapped people
/obj/tgvehicle/sealed/car/clowncar/proc/toggle_cannon(mob/user)
	if(cannonmode == CLOWN_CANNON_BUSY)
		to_chat(user, "<span class='notice'>Please wait for the vehicle to finish its current action first.</span>")
		return
	if(cannonmode) // cannon active, deactivate
		if(!singulomode)
			flick("clowncar_fromfire", src)
			icon_state = "clowncar"
		addtimer(CALLBACK(src, PROC_REF(deactivate_cannon)), 2 SECONDS)
		playsound(src, 'sound/effects/clowncar/clowncar_cannonmode2.ogg', 75)
		visible_message("<span class='warning'>[src] starts going back into mobile mode.</span>")
	else
		canmove = FALSE // anchor and activate cannon
		if(!singulomode)
			flick("clowncar_tofire", src)
			icon_state = "clowncar_fire"
		visible_message("<span class='warning'>[src] opens up and reveals a large cannon.</span>")
		addtimer(CALLBACK(src, PROC_REF(activate_cannon)), 2 SECONDS)
		playsound(src, 'sound/effects/clowncar/clowncar_cannonmode1.ogg', 75)
	cannonmode = CLOWN_CANNON_BUSY

/// Finalizes cannon activation
/obj/tgvehicle/sealed/car/clowncar/proc/activate_cannon()
	var/mouse_pointer = 'icons/mouse_icons/weapon_pointer.dmi'
	cannonmode = CLOWN_CANNON_READY
	for(var/mob/living/driver as anything in return_controllers_with_flag(VEHICLE_CONTROL_DRIVE))
		REMOVE_TRAIT(driver, TRAIT_HANDS_BLOCKED, VEHICLE_TRAIT)
		driver.add_mousepointer(MP_CLOWN_CAR_PRIORITY, mouse_pointer)

/// Finalizes cannon deactivation
/obj/tgvehicle/sealed/car/clowncar/proc/deactivate_cannon()
	canmove = TRUE
	cannonmode = CLOWN_CANNON_INACTIVE
	for(var/mob/living/driver as anything in return_controllers_with_flag(VEHICLE_CONTROL_DRIVE))
		driver.remove_mousepointer(MP_CLOWN_CAR_PRIORITY)
		ADD_TRAIT(driver, TRAIT_HANDS_BLOCKED, VEHICLE_TRAIT)

/// Fires the cannon where the user clicks
/obj/tgvehicle/sealed/car/clowncar/proc/fire_cannon_at(atom/target, mob/user, list/modifiers)
	if(cannonmode != CLOWN_CANNON_READY || !length(return_controllers_with_flag(VEHICLE_CONTROL_KIDNAPPED)))
		return
	if(!COOLDOWN_FINISHED(src, cannon_cooldown))
		return
	var/mob/living/unlucky_sod = pick(return_controllers_with_flag(VEHICLE_CONTROL_KIDNAPPED))
	mob_exit(unlucky_sod, silent = TRUE)
	if(!singulomode)
		flick("clowncar_recoil", src)
	playsound(src, pick('sound/effects/clowncar/carcannon1.ogg', 'sound/effects/clowncar/carcannon2.ogg', 'sound/effects/clowncar/carcannon3.ogg'), 75)
	unlucky_sod.throw_at(target, 10, 2)
	COOLDOWN_START(src, cannon_cooldown, cannon_fire_delay)
	log_attack(user, unlucky_sod, "fired towards [target]") // this doesn't catch if the mob hits something between the car and the target
	return COMSIG_MOB_CANCEL_CLICKON

