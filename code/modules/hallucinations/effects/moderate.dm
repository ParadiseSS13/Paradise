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
		/obj/screen/alert/not_enough_oxy = "not_enough_oxy",
		/obj/screen/alert/not_enough_tox = "not_enough_tox",
		/obj/screen/alert/not_enough_co2 = "not_enough_co2",
		/obj/screen/alert/not_enough_nitro = "not_enough_nitro",
		/obj/screen/alert/too_much_oxy = "too_much_oxy",
		/obj/screen/alert/too_much_co2 = "too_much_co2",
		/obj/screen/alert/too_much_tox = "too_much_tox",
		/obj/screen/alert/fat = "nutrition",
		/obj/screen/alert/starving = "nutrition",
		/obj/screen/alert/hot = "temp",
		/obj/screen/alert/cold = "temp",
		/obj/screen/alert/highpressure = "pressure",
		/obj/screen/alert/lowpressure = "pressure",
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
		"chainsaw" = list('icons/obj/items.dmi', "chainsaw0"),
		"combat shotgun" = list('icons/obj/guns/projectile.dmi', "cshotgun"),
		"double-bladed energy sword" = list('icons/obj/items.dmi', "dualsaberred1"),
		"energy sword" = list('icons/obj/items.dmi', "swordred"),
		"fireaxe" = list('icons/obj/items.dmi', "fireaxe1"),
		"ritual dagger" = list('icons/obj/cult.dmi', "blood_dagger"),
		"ritual dagger" = list('icons/obj/cult.dmi', "death_dagger"),
		"ritual dagger" = list('icons/obj/cult.dmi', "hell_dagger"),
		"sniper rifle" = list('icons/obj/guns/projectile.dmi', "sniper"),
	)

/obj/effect/hallucination/fake_item/Initialize(mapload, mob/living/carbon/target)
	name = pick(items)
	var/icon_data = items[name]
	hallucination_icon = icon_data[1]
	hallucination_icon_state = icon_data[2]
	. = ..()

	var/list/locs = list()
	for(var/turf/T in range(world.view / 2, target))
		if(!is_blocked_turf(T))
			locs += T
	if(!length(locs))
		qdel(src)
		return
	loc = pick(locs)

/obj/effect/hallucination/fake_item/attack_hand(mob/living/user)
	if(user != target)
		return
	if(hasorgans(user))
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

	user.Weaken(4 SECONDS_TO_LIFE_CYCLES)
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
	for(var/mob/living/carbon/human/H in oviewers(world.view, target))
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
	duration = 5 SECONDS
	/// Minimum number of chasms to create.
	var/min_amount = 3
	/// Maximum number of chasms to create.
	var/max_amount = 7

/obj/effect/hallucination/chasms/Initialize(mapload, mob/living/carbon/target)
	. = ..()

	// Let's check if we can spawn somewhere first
	var/list/locs = list()
	for(var/turf/T in range(world.view, target))
		if(isfloorturf(T))
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
	stun = 8 SECONDS_TO_LIFE_CYCLES
	weaken = 8 SECONDS_TO_LIFE_CYCLES

/obj/effect/hallucination/tripper/chasm/on_crossed()
	target.visible_message("<span class='warning'>[target] trips over nothing and flails on [get_turf(target)] as if they were falling!</span>",
					  	   "<span class='userdanger'>You stumble and stare into an abyss before you. It stares back, and you fall into the enveloping dark!</span>")
