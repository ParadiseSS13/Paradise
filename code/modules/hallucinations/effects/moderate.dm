/**
  * # Hallucination - Bolts (Moderate)
  *
  * A variation that affects more airlocks.
  */
/obj/effect/hallucination/bolts/moderate
	bolt_amount = 7

/**
  * # Hallucination - Fake Alert
  *
  * Displays a random alert on the target's HUD.
  */
/obj/effect/hallucination/fake_alert
	duration = list(10 SECONDS, 25 SECONDS)
	/// The possible alerts to be displayed. Key is alert type, value is alert category.
	var/list/alerts = list(
		/atom/movable/screen/alert/not_enough_oxy = "not_enough_oxy",
		/atom/movable/screen/alert/not_enough_tox = "not_enough_tox",
		/atom/movable/screen/alert/not_enough_co2 = "not_enough_co2",
		/atom/movable/screen/alert/not_enough_nitro = "not_enough_nitro",
		/atom/movable/screen/alert/too_much_oxy = "too_much_oxy",
		/atom/movable/screen/alert/too_much_co2 = "too_much_co2",
		/atom/movable/screen/alert/too_much_tox = "too_much_tox",
		/atom/movable/screen/alert/hunger/fat = "nutrition",
		/atom/movable/screen/alert/hunger/starving = "nutrition",
		/atom/movable/screen/alert/hot = "temp",
		/atom/movable/screen/alert/cold = "temp",
		/atom/movable/screen/alert/highpressure = "pressure",
		/atom/movable/screen/alert/lowpressure = "pressure",
	)
	/// Alert severities. Only needed for some alerts such as temperature or pressure. Key is alert category, value is severity.
	var/list/severities = list(
		"temp" = 3,
		"pressure" = 2,
	)
	/// The alert category that was affected(arc) as part of this hallucination.
	var/alert_category

/obj/effect/hallucination/fake_alert/Initialize(mapload, mob/living/carbon/target)
	. = ..()
	var/alert_type = pick(alerts)
	alert_category = alerts[alert_type]
	target.throw_alert(alert_category, alert_type, override = TRUE, severity = severities[alert_category])

/obj/effect/hallucination/fake_alert/Destroy()
	target?.clear_alert(alert_category, clear_override = TRUE)
	return ..()

/**
  * # Hallucination - Fake Item
  *
  * Displays a random fake item around the target. If it's on the floor and they try to pick it up, they will trip and fall.
  */
/obj/effect/hallucination/fake_item
	hallucination_override = TRUE
	hallucination_layer = OBJ_LAYER
	/// Static list of items this hallucination can be.
	var/static/list/items = list(
		"\improper .357 revolver" = list('icons/obj/guns/projectile.dmi', "revolver"),
		"\improper ARG" = list('icons/obj/guns/projectile.dmi', "arg-30"),
		"\improper C4" = list('icons/obj/grenade.dmi', "plastic-explosive0"),
		"\improper L6 SAW" = list('icons/obj/guns/projectile.dmi', "l6closed100"),
		"chainsaw" = list('icons/obj/weapons/melee.dmi', "chainsaw"),
		"combat shotgun" = list('icons/obj/guns/projectile.dmi', "shotgun_combat"),
		"double-bladed energy sword" = list('icons/obj/weapons/energy_melee.dmi', "dualsaberred1"),
		"energy sword" = list('icons/obj/weapons/energy_melee.dmi', "swordred"),
		"fireaxe" = list('icons/obj/weapons/melee.dmi', "fireaxe1"),
		"ritual dagger" = list('icons/obj/cult.dmi', "blood_dagger"),
		"ritual dagger" = list('icons/obj/cult.dmi', "death_dagger"),
		"ritual dagger" = list('icons/obj/cult.dmi', "hell_dagger"),
		"sniper rifle" = list('icons/obj/guns/projectile.dmi', "sniper"),
	)

/obj/effect/hallucination/fake_item/Initialize(mapload, mob/living/carbon/target)
	name = pick(items)
	var/list/icon_data = items[name]
	hallucination_icon = icon_data[1]
	hallucination_icon_state = icon_data[2]
	. = ..()

	var/list/locs = list()
	for(var/turf/T in oview(world.view, target))
		if(!T.is_blocked_turf())
			locs += T
	if(!length(locs))
		qdel(src)
		return
	loc = pick(locs)

/obj/effect/hallucination/fake_item/attack_hand(mob/living/user)
	if(user != target)
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/temp = H.bodyparts_by_name["r_hand"]
		if(user.hand)
			temp = H.bodyparts_by_name["l_hand"]
		if(!temp)
			to_chat(user, "<span class='warning'>You try to use your hand, but it's missing!</span>")
			return
		if(!temp.is_usable())
			to_chat(user, "<span class='warning'>You try to move your [temp.name], but cannot!</span>")
			return

	user.Weaken(4 SECONDS)
	user.visible_message("<span class='warning'>[user] does a grabbing motion towards [get_turf(src)] but [user.p_they()] stumble[user.p_s()] - nothing is there!</span>",
						"<span class='userdanger'>[src] vanishes as you try grabbing it, causing you to stumble!</span>")
	qdel(src)

/**
  * # Hallucination - Fake Weapon
  *
  * Displays a random fake weapon wielded by a human around the target.
  */
/obj/effect/hallucination/fake_weapon
	/// Static list of weapons this hallucination can be. Key is icon state, value is LEFT-HAND icon file.
	var/static/list/weapons = list(
		"advtaserstun4" = 'icons/mob/inhands/guns_lefthand.dmi',
		"arm_blade" = null,
		"blood_blade" = null,
		"crossbow" = 'icons/mob/inhands/guns_lefthand.dmi',
		"death_blade" = null,
		"disintegrate" = null,
		"fireaxe0" = null,
		"hell_blade" = null,
		"ling_shield" = null,
		"nucgun" = 'icons/mob/inhands/guns_lefthand.dmi',
		"prod" = null,
		"staffofslipping" = null,
		"staffofstorms" = null,
		"swordred" = null,
		"ttv" = null,
	)
	/// The default LEFT-HAND icon file for weapons. Static.
	var/static/default_icon = 'icons/mob/inhands/items_lefthand.dmi'
	/// Static list of RIGHT-HAND counterpart for any LEFT-HAND icon files used above.
	var/static/right_hand_icons = list(
		'icons/mob/inhands/items_lefthand.dmi' = 'icons/mob/inhands/items_righthand.dmi',
		'icons/mob/inhands/guns_lefthand.dmi' = 'icons/mob/inhands/guns_righthand.dmi',
	)
	/// The mob wielding the fake weapon.
	var/mob/living/carbon/human/wielder = null

/obj/effect/hallucination/fake_weapon/Initialize(mapload, mob/living/carbon/target)
	. = ..()

	// Find able-bodied mobs first
	var/list/mobs = list()
	for(var/mob/living/carbon/human/H in oview(world.view, target))
		if(H.stat || !((H.has_left_hand() && !H.l_hand) || (H.has_right_hand() && !H.r_hand)))
			continue
		mobs += H
	if(!length(mobs))
		qdel(src)
		return

	// Pick a hand if it exists of course
	wielder = pick(mobs)
	var/right = FALSE
	if(!(wielder.bodyparts_by_name["l_hand"] && !wielder.l_hand) || ((wielder.bodyparts_by_name["r_hand"] && !wielder.r_hand) && prob(50)))
		right = TRUE

	// Create the icon
	hallucination_icon_state = pick(weapons)
	var/icon = weapons[hallucination_icon_state] || default_icon
	if(right)
		icon = right_hand_icons[icon]
	var/image/I = image(icon, wielder, hallucination_icon_state)
	I = center_image(I, 32, 32)
	add_icon(I)

	if(hallucination_icon_state == "swordred")
		target.playsound_local(get_turf(wielder), 'sound/weapons/saberon.ogg', 35, TRUE)

/obj/effect/hallucination/fake_weapon/Destroy()
	if(!QDELETED(wielder) && hallucination_icon_state == "swordred")
		target.playsound_local(get_turf(wielder), 'sound/weapons/saberoff.ogg', 35, TRUE)
	return ..()

/**
  * # Hallucination - Chasms
  *
  * Displays fake chasms around the target that if crossed, cause them to trip.
  */
/obj/effect/hallucination/chasms
	/// Minimum number of chasms to create.
	var/min_amount = 3
	/// Maximum number of chasms to create.
	var/max_amount = 7

/obj/effect/hallucination/chasms/Initialize(mapload, mob/living/carbon/target)
	. = ..()

	// Let's check if we can spawn somewhere first
	var/list/locs = list()
	for(var/turf/T in oview(world.view, target))
		if(isfloorturf(T) && !T.is_blocked_turf())
			locs += T
	if(!length(locs))
		qdel(src)
		return

	var/amount = rand(min_amount, max_amount)
	while(amount-- && length(locs))
		new /obj/effect/hallucination/tripper/chasm(pick_n_take(locs), target)

/**
  * # Hallucination - Chasm
  *
  * A fake chasm that if crossed by the target, causes them to trip.
  */
/obj/effect/hallucination/tripper/chasm
	name = "chasm"
	hallucination_icon = 'icons/turf/floors/Chasms.dmi'
	hallucination_icon_state = "smooth"
	hallucination_override = TRUE
	hallucination_layer = HIGH_TURF_LAYER
	stun = 8 SECONDS
	weaken = 8 SECONDS

/obj/effect/hallucination/tripper/chasm/on_crossed()
	target.visible_message("<span class='warning'>[target] trips over nothing and flails on [get_turf(target)] as if they were falling!</span>",
						"<span class='userdanger'>You stumble and stare into an abyss before you. It stares back, and you fall into the enveloping dark!</span>")

/**
  * # Hallucination - Delamination Alarm
  *
  * A fake radio message and audio that alerts of an increasing SM unstability.
  */
/obj/effect/hallucination/delamination_alarm
	duration = 0

/obj/effect/hallucination/delamination_alarm/Initialize(mapload, mob/living/carbon/target)
	. = ..()
	target.playsound_local(target, 'sound/machines/engine_alert2.ogg', 25, FALSE, 30, 30)
	target.hear_radio(message_to_multilingual("<b>Danger! Crystal hyperstructure integrity faltering! Integrity: [rand(30, 50)]%</b>"), vname = "supermatter crystal", part_a = "<span class='[SSradio.frequency_span_class(PUB_FREQ)]'><b>\[[get_frequency_name(PUB_FREQ)]\]</b> <span class='name'>", part_b = "</span> <span class='message'>")

/**
  * # Hallucination - Plasma Flood
  *
  * A fake plasma flood emanating from a nearby vent.
  */
/obj/effect/hallucination/plasma_flood
	duration = 25 SECONDS
	/// List of turfs that need expanding from.
	var/list/turf/expand_queue = list()
	/// Associative list of turfs that have already been processed.
	var/list/turf/processed = list()
	/// The delay at which the plasma flood expands in deciseconds. Shouldn't be too low to prevent lag.
	var/expand_delay = 2.5 SECONDS // Expand 10 times
	/// Expand timer handle.
	var/expand_timer = null

/obj/effect/hallucination/plasma_flood/Initialize(mapload, mob/living/carbon/target)
	. = ..()

	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/vent in oview(world.view, target))
		var/turf/vent_turf = get_turf(vent)
		if(!vent_turf.is_blocked_turf() && !vent.welded)
			vents += vent
	if(!length(vents))
		qdel(src)
		return

	var/turf/T = get_turf(pick(vents))
	create_plasma(T)
	expand_queue += T
	processed[T] = TRUE
	expand_timer = addtimer(CALLBACK(src, PROC_REF(expand)), expand_delay, TIMER_LOOP | TIMER_STOPPABLE)

/obj/effect/hallucination/plasma_flood/Destroy()
	deltimer(expand_timer)
	QDEL_NULL(expand_queue)
	QDEL_NULL(processed)
	return ..()

/**
  * Called regularly in a timer to process the plasma flooding.
  */
/obj/effect/hallucination/plasma_flood/proc/expand()
	// Brace for potentially expensive proc
	for(var/t in expand_queue)
		var/turf/source_turf = t
		expand_queue -= source_turf
		// Expand to each dir
		for(var/direction in GLOB.cardinal)
			var/turf/target_turf = get_step(source_turf, direction)
			if(processed[target_turf] || !source_turf.CanAtmosPass(direction) || !target_turf.CanAtmosPass(turn(direction, 180)))
				continue
			create_plasma(target_turf)
			expand_queue += target_turf
			processed[target_turf] = TRUE

/**
  * Creates a fake plasma overlay on the given turf.
  *
  * Arguments:
  * * T - The turf to create a fake plasma overlay on.
  */
/obj/effect/hallucination/plasma_flood/proc/create_plasma(turf/T)
	var/image/I = image('icons/effects/tile_effects.dmi', T, "plasma", layer = FLY_LAYER)
	I.plane = GAME_PLANE
	add_icon(I)

/**
  * # Hallucination - Husks
  *
  * A random number of fake husks around the target.
  */
/obj/effect/hallucination/husks
	duration = 25 SECONDS
	/// The base number of husks to create.
	var/num_base = 3
	/// The husk number variation, both negative and positive.
	var/variation = 1

/obj/effect/hallucination/husks/Initialize(mapload, mob/living/carbon/target)
	. = ..()

	var/list/locs = list()
	for(var/turf/T in oview(world.view, target))
		if(isfloorturf(T) && !T.is_blocked_turf())
			locs += T
	if(!length(locs))
		qdel(src)
		return

	var/to_spawn = num_base + rand(-variation, variation)
	while(to_spawn-- && length(locs))
		var/image/I = image('icons/mob/human.dmi', pick_n_take(locs), "husk_s", layer = MOB_LAYER, dir = pick(GLOB.cardinal))
		I.plane = GAME_PLANE
		I.transform = turn(I.transform, pick(-90, 90))
		add_icon(I)

/**
  * # Hallucination - Stunprodding
  *
  * A series of localized audio playback simulating a kidnapping with a stunprod.
  */
/obj/effect/hallucination/stunprodding
	duration = 3 SECONDS

/obj/effect/hallucination/stunprodding/Initialize(mapload, mob/living/carbon/target)
	. = ..()

	var/list/possible_turfs = RANGE_TURFS(15, target)
	if(!length(possible_turfs))
		return INITIALIZE_HINT_QDEL
	var/turf/T = pick(possible_turfs)
	target.playsound_local(T, 'sound/weapons/egloves.ogg', 25, TRUE)
	target.playsound_local(T, get_sfx("bodyfall"), 25, TRUE)
	target.playsound_local(T, "sparks", 50, TRUE)

	if(prob(50))
		var/snd = pick('sound/goonstation/voice/female_scream.ogg', 'sound/goonstation/voice/male_scream.ogg')
		play_sound_in(rand(13, 20), T, snd, 50, TRUE, rand(9, 11) / 10)

	play_sound_in(rand(17, 20), T, 'sound/weapons/cablecuff.ogg', 15, TRUE)

/**
  * # Hallucination - Energy Sword
  *
  * A series of localized audio playback simulating an energy sword murder.
  */
/obj/effect/hallucination/energy_sword
	duration = 10 SECONDS

/obj/effect/hallucination/energy_sword/Initialize(mapload, mob/living/carbon/target)
	. = ..()

	var/list/possible_turfs = RANGE_TURFS(15, target)
	if(!length(possible_turfs))
		return INITIALIZE_HINT_QDEL
	var/turf/T = pick(possible_turfs)
	forceMove(T)
	target.playsound_local(T, 'sound/weapons/saberon.ogg', 20, TRUE)

	var/scream_sound = pick('sound/goonstation/voice/female_scream.ogg', 'sound/goonstation/voice/male_scream.ogg')
	var/scream_pitch = rand(9, 11) / 10
	var/num_hits = rand(5, 6)
	var/scream_cd = 0
	for(var/i in 1 to num_hits)
		var/time = i * CLICK_CD_MELEE + rand(3, 7)
		play_sound_in(time, T, 'sound/weapons/blade1.ogg', 15, TRUE)
		if(i == num_hits)
			play_sound_in(time, T, pick('sound/goonstation/voice/deathgasp_1.ogg', 'sound/goonstation/voice/deathgasp_2.ogg'), 50, TRUE, scream_pitch)
		else if(scream_sound && scream_cd-- <= 0 && prob(20))
			scream_cd = 2
			play_sound_in(time, T, scream_sound, 50, TRUE, scream_pitch)

/obj/effect/hallucination/energy_sword/Destroy()
	target.playsound_local(loc, 'sound/weapons/saberoff.ogg', 20, TRUE)
	return ..()

/**
  * # Hallucination - Gunfire
  *
  * A series of localized audio playback simulating a gunshot murder.
  */
/obj/effect/hallucination/gunfire
	duration = 10 SECONDS

/obj/effect/hallucination/gunfire/Initialize(mapload, mob/living/carbon/target)
	. = ..()

	var/list/possible_turfs = RANGE_TURFS(15, target)
	if(!length(possible_turfs))
		return INITIALIZE_HINT_QDEL
	var/turf/T = pick(possible_turfs)
	forceMove(T)

	var/gun_sound = pick('sound/weapons/gunshots/gunshot_pistol.ogg', 'sound/weapons/gunshots/gunshot_strong.ogg')
	var/scream_sound = pick('sound/goonstation/voice/female_scream.ogg', 'sound/goonstation/voice/male_scream.ogg')
	var/scream_pitch = rand(9, 11) / 10
	var/num_hits = rand(7, 8)
	var/scream_cd = 0
	for(var/i in 1 to num_hits)
		var/time = i * CLICK_CD_RANGE + rand(2, 4)
		play_sound_in(time, T, gun_sound, 25, TRUE)
		if(i == num_hits)
			play_sound_in(time, T, pick('sound/goonstation/voice/deathgasp_1.ogg', 'sound/goonstation/voice/deathgasp_2.ogg'), 50, TRUE, scream_pitch)
		else if(scream_sound && scream_cd-- <= 0 && prob(20))
			scream_cd = 2
			play_sound_in(time, T, scream_sound, 50, TRUE, scream_pitch)

/**
  * # Hallucination - Self Delusion
  *
  * Changes the target's appearance to something else temporarily.
  */
/obj/effect/hallucination/self_delusion

/obj/effect/hallucination/self_delusion/Initialize(mapload, mob/living/carbon/target)
	. = ..()

	var/image/I = get_image()
	I.override = TRUE
	add_icon(I)

	to_chat(target, "<span class='italics'>...wabbajack...wabbajack...</span>")
	target.playsound_local(get_turf(target), 'sound/magic/staff_change.ogg', 50, TRUE, -1)

/**
  * Returns the image to use as override to the target's appearance.
  */
/obj/effect/hallucination/self_delusion/proc/get_image()
	return image('icons/mob/animal.dmi', target, pick("black_bear", "brown_bear", "corgi", "cow", "deer", "goat", "goose", "pig", "blank-body"))

/**
  * # Hallucination - Delusion
  *
  * Changes the appearance of all humans around the target.
  */
/obj/effect/hallucination/delusion

/obj/effect/hallucination/delusion/Initialize(mapload, mob/living/carbon/target, override_icon, override_icon_state)
	. = ..()

	for(var/mob/living/carbon/human/H in orange(world.view, target))
		var/image/I
		if(override_icon && override_icon_state)
			I = image(override_icon, H, override_icon_state)
		else
			I = get_image(H)
		I.override = TRUE
		add_icon(I)

/obj/effect/hallucination/delusion/long
	duration = 30 SECONDS

/**
  * Returns the image to use as override to the target's appearance.
  */
/obj/effect/hallucination/delusion/proc/get_image(mob/living/carbon/human/H)
	return image('icons/mob/animal.dmi', H, pick("black_bear", "brown_bear", "corgi", "cow", "deer", "goat", "goose", "pig", "blank-body"))

/**
  * # Hallucination - Vent Peek
  *
  * A suspicious individual peers out of a nearby vent at the target.
  */
/obj/effect/hallucination/ventpeek
	duration = 4 SECONDS

/obj/effect/hallucination/ventpeek/Initialize(mapload, mob/living/carbon/hallucination_target)
	. = ..()

	var/list/venttargets = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/vent in oview(world.view, target))
		venttargets += vent
	if(!length(venttargets))
		return INITIALIZE_HINT_QDEL
	var/image/I = image('icons/effects/effects.dmi', get_turf(pick(venttargets)))
	add_icon(I)
	flick("hallucination_clown", I)
	addtimer(CALLBACK(src, PROC_REF(play_honk)), 2.3 SECONDS)

/obj/effect/hallucination/ventpeek/proc/play_honk()
	target.playsound_local(target, 'sound/items/bikehorn.ogg', 10, TRUE)

// Doppelganger hallucination
// Spawns a copy of the player that briefly follows them around
/obj/effect/hallucination/doppelganger
	duration = 10 SECONDS
	var/obj/effect/hallucination/chaser/you/fake_you

/obj/effect/hallucination/doppelganger/Initialize(mapload, mob/living/carbon/target)
	. = ..()

	var/list/locs = list()
	for(var/turf/T in oview(world.view / 2, target))
		if(!T.is_blocked_turf())
			locs += T
	if(!length(locs))
		return INITIALIZE_HINT_QDEL

	var/turf/T = pick(locs)
	fake_you = new(T, target)

/obj/effect/hallucination/doppelganger/Destroy()
	QDEL_NULL(fake_you)
	return ..()

/obj/effect/hallucination/chaser/you
	duration = 10 SECONDS
	min_distance = 2
	var/image/I = new

/obj/effect/hallucination/chaser/you/Initialize(mapload, mob/living/carbon/target)
	. = ..()
	name = "???"
	I.appearance = target.appearance
	I.loc = src
	I.override = TRUE
	add_icon(I)

/obj/effect/hallucination/chaser/you/chase()
	..()
	I.dir = get_dir(src, target)

/obj/effect/hallucination/chaser/you/Destroy()
	QDEL_NULL(I)
	return ..()
