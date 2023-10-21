//Supply modules for MODsuits

///Internal GPS - Extends a GPS you can use.
/obj/item/mod/module/gps
	name = "MOD internal GPS module"
	desc = "This module uses common Nanotrasen technology to calculate the user's position anywhere in space, \
		down to the exact coordinates. This information is fed to a central database viewable from the device itself, \
		though using it to help people is up to you."
	icon_state = "gps"
	module_type = MODULE_ACTIVE
	complexity = 1
	use_power_cost = DEFAULT_CHARGE_DRAIN * 0.2
	incompatible_modules = list(/obj/item/mod/module/gps)
	cooldown_time = 0.5 SECONDS
	device = /obj/item/gps/mod

///Hydraulic Clamp - Lets you pick up and drop crates.
/obj/item/mod/module/clamp
	name = "MOD hydraulic clamp module"
	desc = "A series of actuators installed into both arms of the suit, boasting a lifting capacity of almost a ton. \
		However, this design has been locked by Nanotrasen to be primarily utilized for lifting various crates. \
		A lot of people would say that loading cargo is a dull job, but you could not disagree more."
	icon_state = "clamp"
	module_type = MODULE_ACTIVE
	complexity = 3
	use_power_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/clamp)
	cooldown_time = 0.5 SECONDS
	overlay_state_inactive = "module_clamp"
	overlay_state_active = "module_clamp_on"
	/// Time it takes to load a crate.
	var/load_time = 3 SECONDS
	/// The max amount of crates you can carry.
	var/max_crates = 3
	/// The crates stored in the module.
	var/list/stored_crates = list()

/obj/item/mod/module/clamp/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!mod.wearer.Adjacent(target))
		return
	if(istype(target, /obj/structure/closet/crate))
		var/obj/structure/closet/crate/picked_crate = target
		if(!check_crate_pickup(picked_crate))
			return
		playsound(src, 'sound/mecha/hydraulic.ogg', 25, TRUE)
		if(!do_after(mod.wearer, load_time, target = target))
			return
		if(!check_crate_pickup(picked_crate))
			return
		stored_crates += picked_crate
		picked_crate.forceMove(src)
		drain_power(use_power_cost)
	else if(length(stored_crates))
		var/turf/target_turf = get_turf(target)
		if(target_turf.density)
			return
		playsound(src, 'sound/mecha/hydraulic.ogg', 25, TRUE)
		if(!do_after(mod.wearer, load_time, target = target))
			return
		if(target_turf.density)
			return
		var/obj/structure/closet/crate/dropped_crate = pop(stored_crates)
		dropped_crate.forceMove(target_turf)
		drain_power(use_power_cost)
	else
		to_chat(mod.wearer, "<span class='warning'>Invalid target!</span>")

/obj/item/mod/module/clamp/on_suit_deactivation(deleting = FALSE)
	if(deleting)
		return
	for(var/obj/structure/closet/crate/crate as anything in stored_crates)
		crate.forceMove(drop_location())
		stored_crates -= crate

/obj/item/mod/module/clamp/proc/check_crate_pickup(atom/movable/target)
	if(length(stored_crates) >= max_crates)
		to_chat(mod.wearer, "<span class='warning'>Too many crates!</span>")
		return FALSE
	for(var/mob/living/mob in target.client_mobs_in_contents)
		if(mob.mob_size < MOB_SIZE_HUMAN)
			continue
		to_chat(mod.wearer, "<span class='warning'>Too heavy!</span>")
		return FALSE
	return TRUE

/obj/item/mod/module/clamp/loader
	name = "MOD loader hydraulic clamp module"
	icon_state = "clamp_loader"
	complexity = 0
	removable = FALSE
	overlay_state_inactive = null
	overlay_state_active = "module_clamp_loader"
	load_time = 1 SECONDS
	max_crates = 5
	use_mod_colors = TRUE

///Drill - Lets you dig through rock and basalt.
/obj/item/mod/module/drill
	name = "MOD drill module"
	desc = "An integrated drill, typically extending over the user's hand. While useful for drilling through rock, \
		your drill is surely the one that both pierces and creates the heavens."
	icon_state = "drill"
	module_type = MODULE_ACTIVE
	complexity = 2
	use_power_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/drill)
	cooldown_time = 0.5 SECONDS
	overlay_state_active = "module_drill"

/obj/item/mod/module/drill/on_activation()
	. = ..()
	if(!.)
		return
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_BUMP, PROC_REF(bump_mine))

/obj/item/mod/module/drill/on_deactivation(display_message = TRUE, deleting = FALSE)
	. = ..()
	if(!.)
		return
	UnregisterSignal(mod.wearer, COMSIG_MOVABLE_BUMP)

/obj/item/mod/module/drill/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!mod.wearer.Adjacent(target))
		return
	if(ismineralturf(target))
		var/turf/simulated/mineral/mineral_turf = target
		mineral_turf.gets_drilled(mod.wearer)
		drain_power(use_power_cost)

/obj/item/mod/module/drill/proc/bump_mine(mob/living/carbon/human/bumper, atom/bumped_into, proximity)
	SIGNAL_HANDLER
	if(!ismineralturf(bumped_into) || !drain_power(use_power_cost))
		return
	var/turf/simulated/mineral/mineral_turf = bumped_into
	mineral_turf.gets_drilled(mod.wearer)
	return COMPONENT_CANCEL_ATTACK_CHAIN

///Ore Bag - Lets you pick up ores and drop them from the suit.
/obj/item/mod/module/orebag
	name = "MOD ore bag module"
	desc = "An integrated ore storage system installed into the suit, \
		this utilizes precise electromagnets and storage compartments to automatically collect and deposit ore. \
		It's recommended by Cybersun Industries to actually deposit that ore at local refineries."
	icon_state = "ore"
	module_type = MODULE_USABLE
	complexity = 1
	use_power_cost = DEFAULT_CHARGE_DRAIN * 0.2
	incompatible_modules = list(/obj/item/mod/module/orebag)
	cooldown_time = 0.5 SECONDS
	allow_flags = MODULE_ALLOW_INACTIVE

/obj/item/mod/module/orebag/on_equip()
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED, PROC_REF(ore_pickup))
	..()

/obj/item/mod/module/orebag/on_unequip()
	UnregisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED)
	..()

/obj/item/mod/module/orebag/proc/ore_pickup(atom/movable/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER

	for(var/obj/item/stack/ore/ore in get_turf(mod.wearer))
		INVOKE_ASYNC(src, PROC_REF(move_ore), ore)

/obj/item/mod/module/orebag/proc/move_ore(obj/item/stack/ore)
	ore.forceMove(src)

/obj/item/mod/module/orebag/on_use()
	. = ..()
	if(!.)
		return
	for(var/obj/item/ore as anything in contents)
		ore.forceMove(drop_location())
	drain_power(use_power_cost)

/obj/item/mod/module/hydraulic
	name = "MOD loader hydraulic arms module"
	desc = "A pair of powerful hydraulic arms installed in a MODsuit."
	icon_state = "launch_loader"
	module_type = MODULE_ACTIVE
	removable = FALSE
	use_power_cost = DEFAULT_CHARGE_DRAIN*10
	incompatible_modules = list(/obj/item/mod/module/hydraulic)
	cooldown_time = 4 SECONDS
	overlay_state_inactive = "module_hydraulic"
	overlay_state_active = "module_hydraulic_active"
	use_mod_colors = TRUE
	/// Time it takes to launch
	var/launch_time = 2 SECONDS
	/// The overlay used to show that you are charging.
	var/image/charge_up_overlay

/obj/item/mod/module/hydraulic/Initialize(mapload)
	. = ..()
	charge_up_overlay = image(icon = 'icons/effects/effects.dmi', icon_state = "electricity3", layer = EFFECTS_LAYER)

/obj/item/mod/module/hydraulic/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(mod.wearer.buckled)
		return
	var/current_time = world.time
	var/atom/movable/plane_master_controller/pm_controller = mod.wearer.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	for(var/key in pm_controller.controlled_planes)
		animate(pm_controller.controlled_planes[key], launch_time, transform = matrix(1.25, MATRIX_SCALE))
	mod.wearer.visible_message("<span class='warning'>[mod.wearer] starts whirring!</span>")
	playsound(src, 'sound/items/modsuit/loader_charge.ogg', 75, TRUE)
	mod.wearer.add_overlay(charge_up_overlay)
	var/power = launch_time
	if(!do_after(mod.wearer, launch_time, target = mod.wearer))
		power = world.time - current_time
	drain_power(use_power_cost)
	for(var/key in pm_controller.controlled_planes)
		animate(pm_controller.controlled_planes[key], 0.1 SECONDS, transform = matrix(1, MATRIX_SCALE))
	playsound(src, 'sound/items/modsuit/loader_launch.ogg', 75, TRUE)
	var/angle = get_angle(mod.wearer, target)
	mod.wearer.transform = mod.wearer.transform.Turn(mod.wearer.transform, angle)
	mod.wearer.throw_at(get_ranged_target_turf_direct(mod.wearer, target, power), \
		range = power, speed = max(round(0.2*power), 1), thrower = mod.wearer, spin = FALSE, \
		callback = CALLBACK(src, PROC_REF(on_throw_end), mod.wearer, -angle))

/obj/item/mod/module/hydraulic/proc/on_throw_end(mob/user, angle)
	if(!user)
		return
	user.transform = user.transform.Turn(user.transform, angle)
	user.cut_overlay(charge_up_overlay)

/obj/item/mod/module/magnet
	name = "MOD loader hydraulic magnet module"
	desc = "A powerful hydraulic electromagnet able to launch crates and lockers towards the user, and keep them attached."
	icon_state = "magnet_loader"
	module_type = MODULE_ACTIVE
	removable = FALSE
	use_power_cost = DEFAULT_CHARGE_DRAIN * 3
	incompatible_modules = list(/obj/item/mod/module/magnet)
	cooldown_time = 1.5 SECONDS
	overlay_state_active = "module_magnet"
	use_mod_colors = TRUE

/obj/item/mod/module/magnet/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(istype(mod.wearer.pulling, /obj/structure/closet))
		var/obj/structure/closet/locker = mod.wearer.pulling
		playsound(locker, 'sound/effects/gravhit.ogg', 75, TRUE)
		locker.forceMove(mod.wearer.loc)
		locker.throw_at(target, range = 7, speed = 4, thrower = mod.wearer)
		return
	if(!istype(target, /obj/structure/closet) || !(target in view(mod.wearer)))
		to_chat(mod.wearer, "<span class='warning'>Invalid target!</span>")
		return
	var/obj/structure/closet/locker = target
	if(locker.anchored || locker.move_resist >= MOVE_FORCE_OVERPOWERING)
		return
	playsound(locker, 'sound/effects/gravhit.ogg', 75, TRUE)
	locker.throw_at(get_step_towards(mod.wearer, target), range = 7, speed = 3, force = MOVE_FORCE_WEAK, \
		callback = CALLBACK(src, PROC_REF(check_locker), locker))

/obj/item/mod/module/magnet/on_deactivation(display_message = TRUE, deleting = FALSE)
	. = ..()
	if(!.)
		return
	if(istype(mod.wearer.pulling, /obj/structure/closet))
		mod.wearer.stop_pulling()

/obj/item/mod/module/magnet/proc/check_locker(obj/structure/closet/locker)
	if(!mod?.wearer)
		return
	if(!locker.Adjacent(mod.wearer) || !isturf(locker.loc) || !isturf(mod.wearer.loc))
		return
	mod.wearer.start_pulling(locker)

/obj/item/mod/module/ash_accretion
	name = "MOD ash accretion module"
	desc = "A module that collects ash from the terrain, covering the suit in a protective layer, this layer is \
		lost when moving across standard terrain."
	icon_state = "ash_accretion"
	removable = FALSE
	incompatible_modules = list(/obj/item/mod/module/ash_accretion)
	overlay_state_inactive = "module_ash"
	use_mod_colors = TRUE
	/// How many tiles we can travel to max out the armor.
	var/max_traveled_tiles = 10
	/// How many tiles we traveled through.
	var/traveled_tiles = 0
	/// Armor values per tile.
	var/armor_mod_1 = /obj/item/mod/armor/mod_ash_accretion
	/// the actual armor object
	var/obj/item/mod/armor/armor_mod_2 = null
	/// Speed added when you're fully covered in ash.
	var/speed_added = 0.5
	/// Speed that we actually added.
	var/actual_speed_added = 0
	/// Turfs that let us accrete ash.
	var/static/list/accretion_turfs
	/// Turfs that let us keep ash.
	var/static/list/keep_turfs

/obj/item/mod/module/ash_accretion/Initialize(mapload)
	. = ..()
	armor_mod_2 = new armor_mod_1

/obj/item/mod/module/ash_accretion/Destroy()
	QDEL_NULL(armor_mod_2)
	return ..()

/obj/item/mod/armor/mod_ash_accretion
	armor = list(MELEE = 4, BULLET = 1, LASER = 2, ENERGY = 1, BOMB = 4, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/mod/module/ash_accretion/Initialize(mapload)
	. = ..()
	if(!accretion_turfs)
		accretion_turfs = typecacheof(list(
			/turf/simulated/floor/plating/asteroid
		))
	if(!keep_turfs)
		keep_turfs = typecacheof(list(
			/turf/simulated/floor/plating/lava,
			/turf/simulated/floor/indestructible/hierophant
			))

/obj/item/mod/module/ash_accretion/on_suit_activation()
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))

/obj/item/mod/module/ash_accretion/on_suit_deactivation(deleting = FALSE)
	UnregisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED)
	if(!traveled_tiles)
		return
	var/list/parts = mod.mod_parts + mod
	var/speed_up = FALSE
	if(traveled_tiles == max_traveled_tiles)
		speed_up = TRUE
	if(HAS_TRAIT(mod, TRAIT_OIL_SLICKED))
		speed_up = FALSE
	for(var/obj/item/part as anything in parts)
		part.armor = part.armor.detachArmor(part.armor)
		var/obj/item/mod/armor/mod_theme_mining/A = new(src)
		part.armor = part.armor.attachArmor(A.armor) //TODO: ANYTHING BUT FUCKING THIS
		if(speed_up)
			part.slowdown += speed_added / 5
		qdel(A)
	traveled_tiles = 0
	mod.wearer.weather_immunities -= "ash"

/obj/item/mod/module/ash_accretion/generate_worn_overlay(user, mutable_appearance/standing)
	overlay_state_inactive = "[initial(overlay_state_inactive)]-[mod.skin]"
	return ..()

/obj/item/mod/module/ash_accretion/proc/on_move(atom/source, atom/oldloc, dir, forced)
	if(!isturf(mod.wearer.loc)) //dont lose ash from going in a locker
		return
	if(traveled_tiles) //leave ash every tile
		new /obj/effect/temp_visual/light_ash(get_turf(src))
	if(is_type_in_typecache(mod.wearer.loc, accretion_turfs))
		if(traveled_tiles >= max_traveled_tiles)
			return
		traveled_tiles++
		var/list/parts = mod.mod_parts + mod
		var/speed_up = FALSE
		if(traveled_tiles >= max_traveled_tiles)
			to_chat(mod.wearer, "<span class='notice'>You are fully covered in ash!</span>")
			mod.wearer.color = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,3) //make them super light
			animate(mod.wearer, 1 SECONDS, color = null, flags = ANIMATION_PARALLEL)
			playsound(src, 'sound/effects/sparks1.ogg', 100, TRUE)
			actual_speed_added = max(0, min(mod.slowdown_active, speed_added / 5))
			mod.wearer.weather_immunities |= "ash"
			if(!HAS_TRAIT(mod, TRAIT_OIL_SLICKED))
				speed_up = TRUE
		for(var/obj/item/part as anything in parts)
			part.armor = part.armor.attachArmor(armor_mod_2.armor)
			if(speed_up)
				part.slowdown -= speed_added / 5
	else if(is_type_in_typecache(mod.wearer.loc, keep_turfs))
		return
	else
		if(traveled_tiles <= 0)
			return
		var/speed_up = FALSE
		if(traveled_tiles == max_traveled_tiles)
			speed_up = TRUE
		if(HAS_TRAIT(mod, TRAIT_OIL_SLICKED))
			speed_up = FALSE
		traveled_tiles--
		var/list/parts = mod.mod_parts + mod
		for(var/obj/item/part as anything in parts)
			part.armor = part.armor.detachArmor(armor_mod_2.armor)
			if(speed_up)
				part.slowdown += actual_speed_added
		if(traveled_tiles <= 0)
			to_chat(mod.wearer, "<span class='warning'>You have ran out of ash!</span>")
			mod.wearer.weather_immunities -= "ash"

/obj/effect/temp_visual/light_ash
	icon_state = "light_ash"
	icon = 'icons/effects/weather_effects.dmi'
	duration = 3.2 SECONDS


/obj/item/mod/module/sphere_transform
	name = "MOD sphere transform module"
	desc = "A module able to move the suit's parts around, turning it and the user into a sphere. \
		The sphere can move quickly, and launch mining bombs to decimate terrain."
	icon_state = "sphere"
	module_type = MODULE_ACTIVE
	removable = FALSE
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	use_power_cost = DEFAULT_CHARGE_DRAIN * 3
	incompatible_modules = list(/obj/item/mod/module/sphere_transform)
	cooldown_time = 2 SECONDS
	allow_flags = MODULE_ALLOW_INCAPACITATED //Required so hands blocked doesnt block bombs
	/// Time it takes us to complete the animation.
	var/animate_time = 0.25 SECONDS

/obj/item/mod/module/sphere_transform/on_activation()
	if(!has_gravity(get_turf(src)))
		to_chat(mod.wearer, "<span class='warning'>ERROR, NO GRAVITY!</span>")
		return FALSE
	. = ..()
	if(!.)
		return
	playsound(src, 'sound/items/modsuit/ballin.ogg', 100, TRUE)
	mod.wearer.add_filter("mod_ball", 1, alpha_mask_filter(icon = icon('icons/mob/clothing/modsuit/mod_modules.dmi', "ball_mask"), flags = MASK_INVERSE))
	mod.wearer.add_filter("mod_blur", 2, angular_blur_filter(size = 15))
	mod.wearer.add_filter("mod_outline", 3, outline_filter(color = "#000000AA"))
	animate(mod.wearer, animate_time, pixel_y = mod.wearer.pixel_y - 4, flags = ANIMATION_PARALLEL)
	mod.wearer.SpinAnimation(1.5)
	// todo, someone get balance approval to add TRAIT_FORCED_STANDING here, like it is on tg.
	// Or, register a signal on floored trait signal
	ADD_TRAIT(mod.wearer, TRAIT_HANDS_BLOCKED, "metriod[UID()]")
	ADD_TRAIT(mod.wearer, TRAIT_GOTTAGOFAST, "metroid[UID()]")
	RegisterSignal(mod.wearer, COMSIG_MOB_STATCHANGE, PROC_REF(on_statchange))

/obj/item/mod/module/sphere_transform/on_deactivation(display_message = TRUE, deleting = FALSE)
	. = ..()
	if(!.)
		return
	if(!deleting)
		playsound(src, 'sound/items/modsuit/ballin.ogg', 100, TRUE, frequency = -1)
	animate(mod.wearer, animate_time, pixel_y = 0)
	addtimer(CALLBACK(mod.wearer, TYPE_PROC_REF(/atom, remove_filter), list("mod_ball", "mod_blur", "mod_outline")), animate_time)
	REMOVE_TRAIT(mod.wearer, TRAIT_HANDS_BLOCKED, "metriod[UID()]")
	REMOVE_TRAIT(mod.wearer, TRAIT_GOTTAGOFAST, "metroid[UID()]")
	UnregisterSignal(mod.wearer, COMSIG_MOB_STATCHANGE)

/obj/item/mod/module/sphere_transform/on_use()
	if(!lavaland_equipment_pressure_check(get_turf(src)))
		to_chat(mod.wearer, "<span class='warning'>ERROR, OVER PRESSURE!</span>")
		playsound(src, 'sound/weapons/gun_interactions/dry_fire.ogg', 25, TRUE)
		return FALSE
	return ..()

/obj/item/mod/module/sphere_transform/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	var/obj/item/projectile/bomb = new /obj/item/projectile/bullet/reusable/mining_bomb(get_turf(mod.wearer))
	bomb.original = target
	bomb.firer = mod.wearer
	bomb.preparePixelProjectile(target, get_turf(target), mod.wearer)
	bomb.fire()
	playsound(src, 'sound/weapons/grenadelaunch.ogg', 75, TRUE)
	drain_power(use_power_cost)

/obj/item/mod/module/sphere_transform/on_active_process()
	animate(mod.wearer) //stop the animation
	mod.wearer.SpinAnimation(1.5) //start it back again
	if(!has_gravity(get_turf(src)))
		on_deactivation() //deactivate in no grav

/obj/item/mod/module/sphere_transform/proc/on_statchange(datum/source)
	SIGNAL_HANDLER
	if(!mod.wearer.stat)
		return
	on_deactivation()

/obj/item/projectile/bullet/reusable/mining_bomb
	name = "mining bomb"
	desc = "A bomb. Why are you staring at this?"
	icon_state = "mine_bomb"
	icon = 'icons/obj/clothing/modsuit/mod_modules.dmi'
	damage = 0
	range = 6
	flag = "bomb"
	light_range = 1
	light_power = 1
	light_color = LIGHT_COLOR_ORANGE
	ammo_type = /obj/structure/mining_bomb

/obj/structure/mining_bomb
	name = "mining bomb"
	desc = "A bomb. Why are you staring at this?"
	icon_state = "mine_bomb"
	icon = 'icons/obj/clothing/modsuit/mod_modules.dmi'
	anchored = TRUE
	resistance_flags = FIRE_PROOF|LAVA_PROOF
	light_range = 1
	light_power = 1
	light_color = LIGHT_COLOR_ORANGE
	/// Time to prime the explosion
	var/prime_time = 0.5 SECONDS
	/// Time to explode from the priming
	var/explosion_time = 1 SECONDS
	/// Damage done on explosion.
	var/damage = 12
	/// Damage multiplier on hostile fauna.
	var/fauna_boost = 4
	/// Image overlaid on explosion.
	var/static/image/explosion_image

/obj/structure/mining_bomb/Initialize(mapload, atom/movable/firer)
	. = ..()
	generate_image()
	addtimer(CALLBACK(src, PROC_REF(prime), firer), prime_time)

/obj/structure/mining_bomb/proc/generate_image()
	explosion_image = image('icons/effects/96x96.dmi', "judicial_explosion")
	explosion_image.pixel_x = -32
	explosion_image.pixel_y = -32

/obj/structure/mining_bomb/proc/prime(atom/movable/firer)
	add_overlay(explosion_image)
	addtimer(CALLBACK(src, PROC_REF(boom), firer), explosion_time)

/obj/structure/mining_bomb/proc/boom(atom/movable/firer)
	visible_message("<span class='danger'>[src] explodes!</span>")
	playsound(src, 'sound/magic/magic_missile.ogg', 200, vary = TRUE)
	for(var/turf/T in circleviewturfs(src, 2))
		if(ismineralturf(T))
			var/turf/simulated/mineral/mineral_turf = T
			mineral_turf.gets_drilled(firer)
	for(var/mob/living/mob in range(1, src))
		mob.apply_damage(damage * (ishostile(mob) ? fauna_boost : 1), BRUTE, spread_damage = TRUE)
		if(!ishostile(mob) || !firer)
			continue
		var/mob/living/simple_animal/hostile/hostile_mob = mob
		hostile_mob.GiveTarget(firer)
	for(var/obj/object in range(1, src))
		object.take_damage(damage, BRUTE, BOMB)
	qdel(src)
