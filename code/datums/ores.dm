/datum/ore
	/// The type of ore that is dropped. Expected to be a subtype of [/obj/item/stack/ore].
	var/drop_type
	/// The lower bound for the amount of randomized ore dropped.
	var/drop_min = 1
	/// The upper bound for the amount of randomized ore dropped.
	var/drop_max = 5
	/// The probability that the ore will spread to nearby [/turf/simulated/mineral]s when placed.
	var/spread_chance = 0
	/// The icon state of the ore used for mining scanner overlays.
	var/scan_icon_state = ""

/**
 * Called when the containing turf is "mined", such as with a pickaxe or other
 * digging implement.
 *
 * Returns [MINERAL_ALLOW_DIG] if the containing turf should be changed to its
 * "dug" state, [MINERAL_PREVENT_DIG] if it should remain as is.
 */
/datum/ore/proc/on_mine(turf/source, mob/user, triggered_by_explosion = FALSE, productivity_mod = 1)
	var/amount = round(rand(drop_min, drop_max) + productivity_mod)

	if(ispath(drop_type, /obj/item/stack/ore))
		new drop_type(source, amount)
		SSticker.score?.score_ore_mined++
		SSblackbox.record_feedback("tally", "ore_mined", amount, type)
	else
		stack_trace("[source.type] [COORD(source)] had non-ore stack [drop_type]")

	return MINERAL_ALLOW_DIG

/datum/ore/iron
	drop_type = /obj/item/stack/ore/iron
	spread_chance = 20
	scan_icon_state = "rock_Iron"

/datum/ore/uranium
	drop_type = /obj/item/stack/ore/uranium
	spread_chance = 5
	scan_icon_state = "rock_Uranium"

/datum/ore/diamond
	drop_type = /obj/item/stack/ore/diamond
	scan_icon_state = "rock_Diamond"

/datum/ore/platinum
	drop_type = /obj/item/stack/ore/platinum
	scan_icon_state = "rock_Platinum"

/datum/ore/palladium
	drop_type = /obj/item/stack/ore/palladium
	scan_icon_state = "rock_Palladium"

/datum/ore/iridium
	drop_type = /obj/item/stack/ore/iridium
	scan_icon_state = "rock_Iridium"

/datum/ore/gold
	drop_type = /obj/item/stack/ore/gold
	spread_chance = 5
	scan_icon_state = "rock_Gold"

/datum/ore/silver
	drop_type = /obj/item/stack/ore/silver
	spread_chance = 5
	scan_icon_state = "rock_Silver"

/datum/ore/titanium
	drop_type = /obj/item/stack/ore/titanium
	spread_chance = 5
	scan_icon_state = "rock_Titanium"

/datum/ore/plasma
	drop_type = /obj/item/stack/ore/plasma
	spread_chance = 8
	scan_icon_state = "rock_Plasma"

/datum/ore/bluespace
	drop_type = /obj/item/stack/ore/bluespace_crystal
	drop_max = 1
	scan_icon_state = "rock_BScrystal"

/datum/ore/bananium
	drop_type = /obj/item/stack/ore/bananium
	drop_min = 3
	drop_max = 3
	scan_icon_state = "rock_Clown"

/datum/ore/tranquillite
	drop_type = /obj/item/stack/ore/tranquillite
	drop_min = 3
	drop_max = 3
	scan_icon_state = "rock_Tranquillite"

/datum/ore/ancient_basalt
	drop_type = /obj/item/stack/ore/glass/basalt/ancient
	drop_min = 2
	drop_max = 2

#define GIBTONITE_UNSTRUCK	0	//! The gibtonite ore is dormant.
#define GIBTONITE_ACTIVE	1	//! The gibtonite ore is in its detonation countdown.
#define GIBTONITE_STABLE	2	//! The gibtonite ore has been stabilized and its detonation countdown is cancelled.
#define GIBTONITE_DETONATE	3	//! The gibtonite ore is about to explode.

/datum/ore/gibtonite
	drop_max = 1
	scan_icon_state = "rock_Gibtonite"
	/// Amount of time from mining before gibtonite explodes.
	var/detonate_time
	/// The world.time that the detonate countdown started at.
	var/detonate_start_time
	/// The amount of time remaining if the gibtonite was stabilized before explosion, in half-seconds.
	var/remaining_time
	/// The state the ore is in. One of [GIBTONITE_UNSTRUCK], [GIBTONITE_ACTIVE], [GIBTONITE_STABLE], or [GIBTONITE_DETONATE].
	var/stage = GIBTONITE_UNSTRUCK
	/// The overlay used for when the gibtonite is in its detonation countdown mode.
	var/mutable_appearance/activated_overlay
	/// Whether an admin log should be generated for this gibtonite's detonation.
	/// Typically enabled if the detonation doesn't occur on the station z-level.
	/// Note that this is only for explosions caused while the gibtonite is still
	/// unmined, in contrast to [/obj/item/gibtonite/proc/GibtoniteReaction].
	var/notify_admins = FALSE
	/// The callback for the explosion that occurs if the gibtonite is not
	/// defused in time.
	var/explosion_callback

/datum/ore/gibtonite/New()
	// So you don't know exactly when the hot potato will explode
	detonate_time = rand(4 SECONDS, 5 SECONDS)

/datum/ore/gibtonite/proc/explosive_reaction(turf/source, mob/user, triggered_by_explosion = FALSE)
	activated_overlay = mutable_appearance(source.icon, "rock_Gibtonite_active", ON_EDGED_TURF_LAYER)
	source.add_overlay(activated_overlay)
	source.name = "gibtonite deposit"
	source.desc = "An active gibtonite reserve. Run!"
	stage = GIBTONITE_ACTIVE
	source.visible_message("<span class='danger'>There was gibtonite inside! It's going to explode!</span>")

	if(!is_mining_level(source.z))
		notify_admins = TRUE
		if(!triggered_by_explosion)
			message_admins("[key_name_admin(user)] has triggered a gibtonite deposit reaction at [ADMIN_VERBOSEJMP(source)].")
		else
			message_admins("An explosion has triggered a gibtonite deposit reaction at [ADMIN_VERBOSEJMP(source)].")

	if(!triggered_by_explosion)
		log_game("[key_name(user)] has triggered a gibtonite deposit reaction at [AREACOORD(source)].")
	else
		log_game("An explosion has triggered a gibtonite deposit reaction at [AREACOORD(source)].")

	RegisterSignal(source, COMSIG_ATTACK_BY, PROC_REF(on_attackby))
	detonate_start_time = world.time
	explosion_callback = addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/ore/gibtonite, detonate), source), detonate_time, TIMER_STOPPABLE)

/datum/ore/gibtonite/on_mine(turf/source, mob/user, triggered_by_explosion = FALSE)
	switch(stage)
		if(GIBTONITE_UNSTRUCK)
			playsound(src,'sound/effects/hit_on_shattered_glass.ogg', 50, TRUE)
			explosive_reaction(source, user, triggered_by_explosion)
			SEND_SIGNAL(source, COMSIG_MINE_EXPOSE_GIBTONITE, user)
			return MINERAL_PREVENT_DIG
		if(GIBTONITE_ACTIVE)
			detonate(source)

			// Detonation takes care of this for us.
			return MINERAL_PREVENT_DIG
		if(GIBTONITE_STABLE)
			var/obj/item/gibtonite/gibtonite = new(source)
			if(remaining_time <= 0)
				gibtonite.quality = 3
				gibtonite.icon_state = "Gibtonite ore 3"
			if(remaining_time >= 1 && remaining_time <= 2)
				gibtonite.quality = 2
				gibtonite.icon_state = "Gibtonite ore 2"

			return MINERAL_ALLOW_DIG

	return MINERAL_PREVENT_DIG

/datum/ore/gibtonite/proc/on_attackby(turf/source, obj/item/attacker, mob/user)
	SIGNAL_HANDLER // COMSIG_ATTACK_BY

	if(istype(attacker, /obj/item/mining_scanner) || istype(attacker, /obj/item/t_scanner/adv_mining_scanner) && stage == GIBTONITE_ACTIVE)
		user.visible_message("<span class='notice'>[user] holds [attacker] to [source]...</span>", "<span class='notice'>You use [attacker] to locate where to cut off the chain reaction and attempt to stop it...</span>")
		defuse(source)
		return COMPONENT_SKIP_AFTERATTACK

/datum/ore/gibtonite/proc/detonate(turf/simulated/mineral/source)
	if(stage == GIBTONITE_STABLE)
		return

	// Don't explode twice please
	if(explosion_callback)
		deltimer(explosion_callback)

	stage = GIBTONITE_DETONATE
	explosion(source, 1, 3, 5, adminlog = notify_admins, cause = "Gibtonite")

	if(!istype(source))
		return

	// Dunno where else to put this
	source.ChangeTurf(source.turf_type, source.defer_change)
	addtimer(CALLBACK(source, TYPE_PROC_REF(/turf, AfterChange)), 1, TIMER_UNIQUE)

/datum/ore/gibtonite/proc/defuse(turf/source)
	var/world_time = world.time // Grab this immediately so we're fairly calculating countdown time
	if(stage == GIBTONITE_ACTIVE)
		source.cut_overlay(activated_overlay)
		activated_overlay.icon_state = "rock_Gibtonite_inactive"
		source.add_overlay(activated_overlay)
		source.desc = "An inactive gibtonite reserve. The ore can be extracted."
		stage = GIBTONITE_STABLE

		// ticks remaining / 10 = seconds remaining * 2 countdown decrements every second
		remaining_time = floor((detonate_time - (world_time - detonate_start_time)) / 5)

		if(remaining_time < 0)
			remaining_time = 0
		source.visible_message("<span class='notice'>The chain reaction was stopped! The gibtonite had [remaining_time] reactions left till the explosion!</span>")

#undef GIBTONITE_UNSTRUCK
#undef GIBTONITE_ACTIVE
#undef GIBTONITE_STABLE
#undef GIBTONITE_DETONATE
