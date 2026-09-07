#define ROT_LEFT 0
#define ROT_RIGHT 1
#define ROT_NONE 2

/obj/tgvehicle/moon_ascension
	name = "Avatar of the Moon"
	desc = "A vessel of pure moonlight that has taken the form of the full moon. It shines with a dizzying radiance. You should probably run."
	icon_state = "base"
	icon = 'icons/vehicles/moon.dmi'
	move_resist = INFINITY
	move_force = MOVE_FORCE_OVERPOWERING
	layer = ABOVE_ALL_MOB_LAYER
	max_integrity = 5000
	armor = list(MELEE = -100, BULLET = 0, LASER = 50, ENERGY = 50, BOMB = 20, RAD = INFINITY, FIRE = INFINITY, ACID = INFINITY) // weak to physical. Resistant to energy.
	pixel_x = -16
	pixel_y = 6
	pass_flags = null
	/// What direction do we wish to spin
	var/rotation_dir = ROT_NONE
	/// Hold our old location to know when to stop spinning
	var/turf/old_loc
	/// Holds our moonrays effect
	var/obj/effect/moonray/moonray
	/// Who is the moon's owner?
	var/mob/living/carbon/owner
	/// Holds our armor to apply onto our rider. We want to kill the moon not the rider, with exception (like bombs).
	var/datum/armor/moon_resistance_boost



/obj/tgvehicle/moon_ascension/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSprocessing, src)
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/moon)
	set_light(30, 4, "#ff4b4b")

/obj/tgvehicle/moon_ascension/Destroy(force)
	STOP_PROCESSING(SSprocessing, src)
	QDEL_NULL(moonray)
	. = ..()

/obj/tgvehicle/moon_ascension/Bump(atom/bumped_atom)
	. = ..()
	if(iscarbon(bumped_atom))
		var/mob/living/carbon/C = bumped_atom
		C.AdjustKnockDown(10 SECONDS)
	else if(isliving(bumped_atom))
		var/mob/living/L = bumped_atom
		if(L.stat == DEAD)
			L.gib()
		L.adjustBruteLoss(25)
		step(L, dir)
	else if(isobj(bumped_atom))
		var/obj/O = bumped_atom
		O.take_damage(200, BRUTE, MELEE, 1)
	else if(bumped_atom.type == /turf/simulated/wall)
		var/turf/simulated/wall/wall = bumped_atom
		playsound(wall, 'sound/effects/meteorimpact.ogg', 80, 1)
		wall.dismantle_wall(TRUE, FALSE)

/obj/tgvehicle/moon_ascension/Move(newloc, dir)
	. = ..()
	for(var/mob/living/victim in loc)
		if(is_occupant(victim))
			continue
		if(victim.stat == DEAD)
			continue
		if(HAS_TRAIT(victim, TRAIT_CLOWN_CAR_SQUISHED))
			continue
		squish_victim(victim)

/obj/tgvehicle/moon_ascension/user_unbuckle_mob(mob/living/buckled_mob, mob/living/carbon/user)
	if(!istype(user))
		return FINISH_ATTACK
	if(user != owner)
		to_chat(user, SPAN_HIEROPHANT("GET YOUR FILTHY HANDS OFF MY RADIANT FORM!"))
		user.AdjustKnockDown(5 SECONDS)
		user.AdjustJitter(30 SECONDS, 30 SECONDS, 2 MINUTES)
		user.AdjustConfused(5 SECONDS)
		user.adjustFireLoss(10)
		return FINISH_ATTACK
	return ..()

/// Damage and flatten our poor victim
/obj/tgvehicle/moon_ascension/proc/squish_victim(mob/living/victim)
	if(iscarbon(victim))
		var/mob/living/carbon/C = victim
		ADD_TRAIT(victim, TRAIT_CLOWN_CAR_SQUISHED, "moon_roller")
		addtimer(CALLBACK(src, PROC_REF(allow_resquish), C), 3 SECONDS)
		var/datum/status_effect/stacking/heretic_insanity/insanity = C.has_status_effect(/datum/status_effect/stacking/heretic_insanity)
		if(C.mind && insanity && insanity.stacks >= 8 && prob(insanity.stacks * 2.5))
			C.AdjustKnockDown(5 SECONDS)
			C.visible_message(SPAN_HIEROPHANT_WARNING("[victim] is dazzled by the brillian lights!"))
			victim.apply_status_effect(/datum/status_effect/moon_converted)
			add_attack_logs(owner, victim, "[victim] was driven insane by [owner]([src])")
			log_game("[victim] was driven insane by [owner]")
			C.adjustBruteLoss(-30)
			C.adjustBruteLoss(-30)
			playsound(victim, 'sound/effects/clowncar/cartoon_splat.ogg', 75)
			playsound(victim, 'sound/effects/splat.ogg', 50, TRUE)
		else
			playsound(victim, 'sound/effects/blobattack.ogg', 40, TRUE)
			playsound(victim, 'sound/effects/splat.ogg', 50, TRUE)
			C.adjustBruteLoss(30)
			handle_squish_carbon(victim, 40, duration = 3 SECONDS)
		C.apply_status_effect(/datum/status_effect/stacking/heretic_insanity, 2)

/obj/tgvehicle/moon_ascension/proc/allow_resquish(mob/living/victim)
	REMOVE_TRAIT(victim, TRAIT_CLOWN_CAR_SQUISHED, "moon_roller")

/obj/tgvehicle/moon_ascension/buckle_mob(mob/living/carbon/M, force, check_loc)
	if(M != owner)
		to_chat(M, SPAN_HIEROPHANT("YOU THINK YOU ARE WORTHY OF THE MOONS RADIANCE!?"))
		M.AdjustKnockDown(5 SECONDS)
		M.AdjustJitter(30 SECONDS, 30 SECONDS, 2 MINUTES)
		M.AdjustConfused(5 SECONDS)
		M.adjustFireLoss(10)
		return FALSE
	if(!istype(M))
		to_chat(M, SPAN_HIEROPHANT("Only a suitable human may pilot the moon's greatness."))
		return FALSE
	return ..()

/obj/tgvehicle/moon_ascension/post_buckle_mob(mob/living/carbon/human/M, force, check_loc)
	. = ..()
	M.plane = 20
	moonray = new(M)
	M.vis_contents += moonray
	moon_resistance_boost = new /datum/armor(INFINITY, INFINITY, INFINITY, INFINITY, 100, 50, 50, 50, 0)
	M.physiology.armor = M.physiology.armor.attachArmor(moon_resistance_boost)
	M.physiology.stamina_mod *= 0.25
	add_filter("heavenly_glow", 3, list("type" = "outline", "color" = "#ffffffff", "size" = 1))

/obj/tgvehicle/moon_ascension/unbuckle_mob(mob/living/carbon/human/buckled_mob, force)
	. = ..()
	buckled_mob.plane = -1
	buckled_mob.physiology.armor = buckled_mob.physiology.armor.detachArmor(moon_resistance_boost)
	buckled_mob.physiology.stamina_mod /= 0.25
	QDEL_NULL(moonray)
	handle_rotation(ROT_NONE)
	remove_filter("heavenly_glow")

/obj/tgvehicle/moon_ascension/process()
	var/turf/T = get_turf(src)
	if(old_loc == T && rotation_dir != ROT_NONE)
		handle_rotation(new_rotation = ROT_NONE)
	old_loc = T
	for(var/mob/living/rider in occupants)
		if(rider.stat == DEAD || rider.stat == UNCONSCIOUS) // emergency just in case someone gets stuck.
			unbuckle_mob(rider)

/obj/tgvehicle/moon_ascension/proc/handle_rotation(new_rotation = ROT_NONE)
	if(new_rotation == rotation_dir)
		return
	rotation_dir = new_rotation
	switch(new_rotation)
		if(ROT_LEFT)
			SpinAnimation(speed = 20, loops = -1, clockwise = new_rotation, parallel = FALSE)
		if(ROT_RIGHT)
			SpinAnimation(speed = 20, loops = -1, clockwise = new_rotation, parallel = FALSE)
		if(ROT_NONE)
			SpinAnimation(speed = 9999, loops = -1, clockwise = new_rotation, parallel = FALSE)

/datum/component/riding/vehicle/moon
	vehicle_move_delay = 1.8
	override_allow_spacemove = TRUE
	ride_check_flags = RIDER_NEEDS_LEGS | UNBUCKLE_DISABLED_RIDER

/datum/component/riding/vehicle/moon/vehicle_moved(datum/source, oldloc, dir, forced)
	. = ..()
	var/obj/tgvehicle/moon_ascension/moon = parent
	if(dir == WEST || dir == NORTH)
		moon.handle_rotation(ROT_LEFT)
	else
		moon.handle_rotation(ROT_RIGHT)

/datum/component/riding/vehicle/moon/handle_specials()
	. = ..()
	set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(NORTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(EAST, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(WEST, ABOVE_MOB_LAYER)

	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 70), TEXT_SOUTH = list(0, 70), TEXT_EAST = list(0, 70), TEXT_WEST = list(0, 70)))
	set_vehicle_dir_offsets(NORTH, -16, 6)
	set_vehicle_dir_offsets(SOUTH, -16, 6)
	set_vehicle_dir_offsets(EAST, -16, 6)
	set_vehicle_dir_offsets(WEST, -16, 6)

/datum/component/riding/vehicle/moon/on_rider_try_pull(mob/living/rider_pulling, atom/movable/target, force)
	return

/obj/effect/moonray
	name = "Moonray"
	desc = "Dazzling! But you shouldnt be reading this."
	icon = null
	pixel_y = -45
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/moonray/Initialize(mapload)
	START_PROCESSING(SSprocessing, src)
	. = ..()

/obj/effect/moonray/process()
	var/new_filter = isnull(get_filter("ray"))
	ray_filter_helper(1, 80, "#ffffffff", 6, 20)
	if(new_filter)
		animate(get_filter("ray"), alpha = 0, offset = 10, time = 3 SECONDS, loop = -1)
		animate(offset = 0, time = 3 SECONDS)

/obj/effect/moonray/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	remove_filter("rays")
	. = ..()

#undef ROT_LEFT
#undef ROT_RIGHT
#undef ROT_NONE
