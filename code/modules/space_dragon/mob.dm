/// The darkness threshold for space dragon when choosing a color
#define DARKNESS_THRESHOLD 50
#define DRAGON_DEPRESSION_MODIFIER 5
#define DRAGON_RAGE_MODIFIER -0.5

/**
 * # Space Dragon
 *
 * A space-faring leviathan-esque monster which breathes fire and summons carp.  Spawned during its respective midround antagonist event.
 *
 * A space-faring monstrosity who has the ability to breathe dangerous fire breath and uses its powerful wings to knock foes away.
 * Normally spawned as an antagonist during the Space Dragon event, Space Dragon's main goal is to open three rifts from which to pull a great tide of carp onto the station.
 * Space Dragon can summon only one rift at a time, and can do so anywhere a blob is allowed to spawn.  In order to trigger his victory condition, Space Dragon must summon and defend three rifts while they charge.
 * Space Dragon, when spawned, has five minutes to summon the first rift.  Failing to do so will cause Space Dragon to return from whence he came.
 * When the rift spawns, ghosts can interact with it to spawn in as space carp to help complete the mission.  One carp is granted when the rift is first summoned, with an extra one every 30 seconds.
 * Once the victory condition is met, all current rifts become invulnerable to damage, are allowed to spawn infinite sentient space carp, and Space Dragon gets unlimited rage.
 * Alternatively, if the shuttle arrives while Space Dragon is still active, their victory condition will automatically be met and all the rifts will immediately become fully charged.
 * If a charging rift is destroyed, Space Dragon will be incredibly slowed, and the endlag on his gust attack is greatly increased on each use.
 * Space Dragon has the following abilities to assist him with his objective:
 * - Can shoot fire in straight line, dealing 30 burn damage and setting those suseptible on fire.
 * - Can use his wings to temporarily stun and knock back any nearby mobs.  This attack has no cooldown, but instead has endlag after the attack where Space Dragon cannot act.  This endlag's time decreases over time, but is added to every time he uses the move.
 * - Can swallow mob corpses to heal for half their max health.  Any corpses swallowed are stored within him, and will be regurgitated on death.
 * - Can tear through any type of wall.  This takes 4 seconds for most walls, and 12 seconds for reinforced walls.
 */
/mob/living/simple_animal/hostile/space_dragon
	name = "Space Dragon"
	desc = "Ужасное существо, схожее с классом левиафан, которое летает самым неестественным способом. Схож внешне с космическим карпом."
	gender = NEUTER
	maxHealth = 400
	health = 400
	damage_coeff = list(BRUTE = 0.5, BURN = 0.7, TOX = 1, CLONE = 1, STAMINA = 1, OXY = 0)
	a_intent = INTENT_HARM
	speed = -0.2
	flying = TRUE
	attacktext = "кусает"
	attack_sound = 'sound/misc/demon_attack1.ogg'
	death_sound = 'sound/creatures/space_dragon_roar.ogg'
	icon = 'icons/mob/spacedragon_new.dmi'
	icon_state = "spacedragon"
	icon_living = "spacedragon"
	icon_dead = "spacedragon_dead"
	health_doll_icon = "spacedragon"
	obj_damage = 80
	environment_smash = ENVIRONMENT_SMASH_WALLS
	melee_damage_upper = 25
	melee_damage_lower = 40
	mob_size = MOB_SIZE_LARGE
	armour_penetration = 25 // do you really expect some tiny riot armour can hadle dragon size bites? you're right
	pixel_x = -16
	maptext_height = 64
	maptext_width = 64
	turns_per_move = 5
	ranged = TRUE
	mouse_opacity = MOUSE_OPACITY_ICON
	butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/sinew = 5, /obj/item/stack/sheet/bone = 30, /obj/item/reagent_containers/food/snacks/carpmeat = 15)
	deathmessage = "визжит, крылья превращаются в пыль, а в глазах угасает жизнь, после чего дракон падает замертво."
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 3500
	faction = list("carp")
	pressure_resistance = 200
	sentience_type = SENTIENCE_BOSS
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	sight = SEE_TURFS|SEE_MOBS|SEE_OBJS
	/// How much endlag using Wing Gust should apply.  Each use of wing gust increments this, and it decreases over time.
	var/tiredness = 0
	/// A multiplier to how much each use of wing gust should add to the tiredness variable.  Set to 5 if the current rift is destroyed.
	var/tiredness_mult = 1
	/// The distance Space Dragon's gust reaches
	var/gust_distance = 4
	/// The amount of tiredness to add to Space Dragon per use of gust
	var/gust_tiredness = 30
	/// Determines whether or not Space Dragon is in the middle of using wing gust.  If set to true, prevents him from moving and doing certain actions.
	var/using_special = FALSE
	/// Determines whether or not Space Dragon is currently tearing through a wall.
	var/tearing_wall = FALSE
	/// The ability to make your sprite smaller
	var/datum/action/innate/small_sprite_dragon/small_sprite
	/// The ability to Gust
	var/datum/action/innate/space_dragon_gust/space_dragon_gust
	/// The color of the space dragon.
	var/chosen_color
	/// Minimum devastation damage dealt coefficient based on max health
	var/devastation_damage_min_percentage = 10
	/// Maximum devastation damage dealt coefficient based on max health
	var/devastation_damage_max_percentage = 25
	/// Movement speed changes
	var/dragon_depression = FALSE
	var/dragon_rage = FALSE

/mob/living/simple_animal/hostile/space_dragon/Initialize(mapload)
	. = ..()
	small_sprite = new
	small_sprite.Grant(src)
	space_dragon_gust = new
	space_dragon_gust.Grant(src)
	ADD_TRAIT(src, TRAIT_HEALS_FROM_CARP_RIFTS, INNATE_TRAIT)
	RegisterSignal(small_sprite, COMSIG_ACTION_TRIGGER, PROC_REF(add_dragon_overlay))

/mob/living/simple_animal/hostile/space_dragon/Process_Spacemove(movement_dir)
	return TRUE

/mob/living/simple_animal/hostile/space_dragon/movement_delay()
	. = ..()
	if(dragon_depression)
		. += DRAGON_DEPRESSION_MODIFIER
	if(dragon_rage)
		. += DRAGON_RAGE_MODIFIER

/mob/living/simple_animal/hostile/space_dragon/Login()
	. = ..()
	if(!chosen_color)
		dragon_name()
		color_selection()

/mob/living/simple_animal/hostile/space_dragon/ex_act(severity, origin)
	if(severity == 1)
		var/damage_coefficient = rand(devastation_damage_min_percentage, devastation_damage_max_percentage) / 100
		adjustBruteLoss(initial(maxHealth)*damage_coefficient)
		return
	..()

/mob/living/simple_animal/hostile/space_dragon/Life(seconds_per_tick, times_fired)
	. = ..()
	tiredness = max(tiredness - (1 * seconds_per_tick), 0)
	for(var/mob/living/consumed_mob in src)
		if(consumed_mob.stat == DEAD)
			continue
		playsound(src, 'sound/effects/splat.ogg', 50, TRUE)
		visible_message(span_danger("[src] vomits up [consumed_mob]!"))
		consumed_mob.forceMove(loc)
		consumed_mob.Paralyse(3)

/mob/living/simple_animal/hostile/space_dragon/death(gibbed)
	for(var/atom/movable/barfed_out in contents)
		barfed_out.forceMove(loc)
		if(prob(90))
			step(barfed_out, pick(GLOB.alldirs))
	. = ..()
	add_dragon_overlay()
	UnregisterSignal(small_sprite, COMSIG_ACTION_TRIGGER)

/mob/living/simple_animal/hostile/space_dragon/AttackingTarget()
	if(using_special)
		return
	if(target == src)
		to_chat(src, span_warning("Вы почти укусили себя, но вовремя остановились."))
		return
	if(iswallturf(target))
		if(tearing_wall)
			return
		tearing_wall = TRUE
		var/turf/simulated/wall/thewall = target
		to_chat(src, span_warning("Вы начинаете рвать стену на части..."))
		playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)
		var/timetotear = 2 SECONDS
		if(istype(target, /turf/simulated/wall/r_wall))
			timetotear = 4 SECONDS
		if(do_after(src, timetotear, target = thewall))
			if(!iswallturf(thewall))
				return
			thewall.dismantle_wall(TRUE)
			playsound(src, 'sound/effects/meteorimpact.ogg', 100, TRUE)
		tearing_wall = FALSE
		return
	if(isliving(target)) //Swallows corpses like a snake to regain health.
		var/mob/living/L = target
		if(L.stat == DEAD)
			to_chat(src, span_warning("Вы начинаете глотать [L] целиком..."))
			if(!do_after(src, 3 SECONDS, target = L))
				return
			if(eat(L))
				adjustHealth(-L.maxHealth * 0.5)
			return
		if("carp" in L.faction)
			to_chat(src, span_warning("Вы почти укусили своего сородича, но вовремя остановились."))
			return
	. = ..()
	if(ismecha(target))
		var/obj/mecha/M = target
		M.take_damage(80, BRUTE, "melee", 1)

/mob/living/simple_animal/hostile/space_dragon/proc/try_gust()
	if(using_special)
		return
	using_special = TRUE
	icon_state = "spacedragon_gust"
	add_dragon_overlay()
	useGust(0)

/mob/living/simple_animal/hostile/space_dragon/Move()
	if(!using_special)
		. = ..()

/mob/living/simple_animal/hostile/space_dragon/OpenFire()
	if(using_special)
		return
	ranged_cooldown = world.time + ranged_cooldown_time
	fire_stream()

/mob/living/simple_animal/hostile/space_dragon/revive(full_heal_flags = NONE, excess_healing = 0, force_grab_ghost = FALSE)
	var/was_dead = stat == DEAD
	. = ..()
	add_dragon_overlay()

	if (was_dead)
		RegisterSignal(small_sprite, COMSIG_ACTION_TRIGGER, PROC_REF(add_dragon_overlay))

/**
 * Allows space dragon to choose its own name.
 *
 * Prompts the space dragon to choose a name, which it will then apply to itself.
 * If the name is invalid, will re-prompt the dragon until a proper name is chosen.
 */
/mob/living/simple_animal/hostile/space_dragon/proc/dragon_name()
	var/chosen_name = reject_bad_name(input(src, "Какое имя вы хотите задать?", "Выбор имени", real_name))
	if(!chosen_name)
		to_chat(src, span_warning("Это имя некорректно, попробуйте еще раз."))
		dragon_name()
		return
	to_chat(src, span_notice("Ваше имя теперь - [span_name("[chosen_name]")], устрашающий Космический Дракон."))
	rename_character(null, chosen_name)

/**
 * Allows space dragon to choose a color for itself.
 *
 * Prompts the space dragon to choose a color, from which it will then apply to itself.
 * If an invalid color is given, will re-prompt the dragon until a proper color is chosen.
 */
/mob/living/simple_animal/hostile/space_dragon/proc/color_selection()
	chosen_color = input(src,"Какого цвета вы хотите быть?","Выбор цвета", COLOR_WHITE) as color|null
	if(!chosen_color) //redo proc until we get a color
		to_chat(src, span_warning("Этот цвет некорректен, попробуйте еще раз."))
		color_selection()
		return
	var/temp_hsv = RGBtoHSV(chosen_color)
	if(ReadHSV(temp_hsv)[3] < DARKNESS_THRESHOLD)
		to_chat(src, span_danger("Этот цвет некорректен - он недостаточно светлый."))
		color_selection()
		return
	add_atom_colour(chosen_color, FIXED_COLOUR_PRIORITY)
	add_dragon_overlay()

/**
 * Adds the proper overlay to the space dragon.
 *
 * Clears the current overlay on space dragon and adds a proper one for whatever animation he's in.
 */
/mob/living/simple_animal/hostile/space_dragon/proc/add_dragon_overlay()
	cut_overlays()
	if(!small_sprite.small)
		return
	if(stat == DEAD)
		var/mutable_appearance/overlay = mutable_appearance(icon, "overlay_dead")
		overlay.appearance_flags = RESET_COLOR
		add_overlay(overlay)
		return
	if(!using_special)
		var/mutable_appearance/overlay = mutable_appearance(icon, "overlay_base")
		overlay.appearance_flags = RESET_COLOR
		add_overlay(overlay)
		return
	if(using_special)
		var/mutable_appearance/overlay = mutable_appearance(icon, "overlay_gust")
		overlay.appearance_flags = RESET_COLOR
		add_overlay(overlay)

/**
 * Determines a line of turfs from sources's position to the target with length range.
 *
 * Determines a line of turfs from the source's position to the target with length range.
 * The line will extend on past the target if the range is large enough, and not reach the target if range is small enough.
 * Arguments:
 * * offset - whether or not to aim slightly to the left or right of the target
 * * range - how many turfs should we go out for
 * * atom/at - The target
 */
/mob/living/simple_animal/hostile/space_dragon/proc/line_target(offset, range, atom/at = target)
	if(!at)
		return
	var/angle = ATAN2(at.x - src.x, at.y - src.y) + offset
	var/turf/T = get_turf(src)
	for(var/i in 1 to range)
		var/turf/check = locate(src.x + cos(angle) * i, src.y + sin(angle) * i, src.z)
		if(!check)
			break
		T = check
	return (get_line(src, T) - get_turf(src))

/**
 * Spawns fire at each position in a line from the source to the target.
 *
 * Spawns fire at each position in a line from the source to the target.
 * Stops if it comes into contact with a solid wall, a window, or a door.
 * Delays the spawning of each fire by 1.5 deciseconds.
 * Arguments:
 * * atom/at - The target
 */
/mob/living/simple_animal/hostile/space_dragon/proc/fire_stream(atom/at = target)
	playsound(get_turf(src),'sound/magic/fireball.ogg', 200, TRUE)
	var/range = 20
	var/list/turfs = list()
	turfs = line_target(0, range, at)
	var/delayFire = -1.0
	for(var/turf/T in turfs)
		if(iswallturf(T))
			return
		for(var/obj/structure/window/W in T.contents)
			return
		for(var/obj/machinery/door/D in T.contents)
			if(D.density)
				return
		delayFire += 1.5
		addtimer(CALLBACK(src, PROC_REF(dragon_fire_line), T), delayFire)

/**
 * What occurs on each tile to actually create the fire.
 *
 * Creates a fire on the given turf.
 * It creates a hotspot on the given turf, damages any living mob with 30 burn damage, and damages mechs by 50.
 * It can only hit any given target once.
 * Arguments:
 * * turf/T - The turf to trigger the effects on.
 */
/mob/living/simple_animal/hostile/space_dragon/proc/dragon_fire_line(turf/T)
	var/list/hit_list = list()
	hit_list += src
	new /obj/effect/hotspot(T)
	T.hotspot_expose(2000,50,1)
	for(var/mob/living/L in T.contents)
		if(L in hit_list)
			continue
		if("carp" in L.faction)
			continue
		hit_list += L
		L.adjustFireLoss(45)
		to_chat(L, span_userdanger("Вы попали под огненное дыхание [src]!"))
	// deals damage to mechs
	for(var/obj/mecha/M in T.contents)
		if(M in hit_list)
			continue
		hit_list += M
		M.take_damage(90, BRUTE, "melee", 1)

/**
 * Handles consuming and storing consumed things inside Space Dragon
 *
 * Plays a sound and then stores the consumed thing inside Space Dragon.
 * Used in AttackingTarget(), paired with a heal should it succeed.
 * Arguments:
 * * atom/movable/A - The thing being consumed
 */
/mob/living/simple_animal/hostile/space_dragon/proc/eat(atom/movable/A)
	if(A?.loc == src)
		return FALSE
	playsound(src, 'sound/misc/demon_attack1.ogg', 100, TRUE)
	visible_message(span_warning("[src] swallows [A] whole!"))
	A.forceMove(src)
	return TRUE

/**
 * Resets Space Dragon's status after using wing gust.
 *
 * Resets Space Dragon's status after using wing gust.
 * If it isn't dead by the time it calls this method, reset the sprite back to the normal living sprite.
 * Also sets the using_special variable to FALSE, allowing Space Dragon to move and attack freely again.
 */
/mob/living/simple_animal/hostile/space_dragon/proc/reset_status()
	if(stat != DEAD)
		icon_state = "spacedragon"
	using_special = FALSE
	add_dragon_overlay()

/**
 * Handles wing gust from the windup all the way to the endlag at the end.
 *
 * Handles the wing gust attack from start to finish, based on the timer.
 * When intially triggered, starts at 0.  Until the timer reaches 10, increase Space Dragon's y position by 2 and call back to the function in 1.5 deciseconds.
 * When the timer is at 10, trigger the attack.  Change Space Dragon's sprite. reset his y position, and push all living creatures back in a 3 tile radius and stun them for 5 seconds.
 * Stay in the ending state for how much our tiredness dictates and add to our tiredness.
 * Arguments:
 * * timer - The timer used for the windup.
 */
/mob/living/simple_animal/hostile/space_dragon/proc/useGust(timer)
	if(timer != 10)
		pixel_y = pixel_y + 2;
		addtimer(CALLBACK(src, PROC_REF(useGust), timer + 1), 1.5)
		return
	pixel_y = 0
	icon_state = "spacedragon_gust_2"
	cut_overlays()
	var/mutable_appearance/overlay = mutable_appearance(icon, "overlay_gust_2")
	overlay.appearance_flags = RESET_COLOR
	add_overlay(overlay)
	playsound(src, 'sound/effects/gravhit.ogg', 100, TRUE)
	var/gust_locs = spiral_range_turfs(gust_distance, get_turf(src))
	var/list/hit_things = list()
	for(var/turf/T in gust_locs)
		for(var/mob/living/L in T.contents)
			if(L == src)
				continue
			hit_things += L
			visible_message(span_boldwarning("[L] отброшен назад порывом ветра!"))
			to_chat(L, span_userdanger("Вас отбросило порывом ветра!"))
			var/dir_to_target = get_dir(get_turf(src), get_turf(L))
			var/throwtarget = get_edge_target_turf(target, dir_to_target)
			L.throw_at(throwtarget, 10, 1, src)
			L.Paralyse(3)
	addtimer(CALLBACK(src, PROC_REF(reset_status)), 4 + ((tiredness * tiredness_mult) / 10))
	tiredness = tiredness + (gust_tiredness * tiredness_mult)


#undef DRAGON_DEPRESSION_MODIFIER
#undef DRAGON_RAGE_MODIFIER
#undef DARKNESS_THRESHOLD

/mob/living/simple_animal/hostile/carp/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_HEALS_FROM_CARP_RIFTS, INNATE_TRAIT)


