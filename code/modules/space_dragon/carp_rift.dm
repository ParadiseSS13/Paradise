/// The carp rift is currently charging.
#define CHARGE_ONGOING 0
/// The carp rift is currently charging and has output a final warning.
#define CHARGE_FINALWARNING 1
/// The carp rift is now fully charged.
#define CHARGE_COMPLETED 2

/datum/action/innate/summon_rift
	name = "Summon Rift"
	desc = "Открывает разлом призыва орды космических карпов."
	button_icon_state = "carp_rift"
	background_icon_state = "bg_default"

/datum/action/innate/summon_rift/Activate()
	var/datum/antagonist/space_dragon/dragon = owner.mind?.has_antag_datum(/datum/antagonist/space_dragon)
	if(!dragon)
		return
	var/area/rift_location = get_area(owner)
	if(!rift_location.valid_territory)
		to_chat(owner, span_warning("Вы не можете открыть разлом здесь! Попробуйте ещё раз где-то в безопасном месте на станции!"))
		return
	for(var/obj/structure/carp_rift/rift as anything in dragon.rift_list)
		var/area/used_location = get_area(rift)
		if(used_location == rift_location)
			to_chat(owner, span_warning("Вы уже открыли разлом на этой территории! Разлом должен находиться где-то ещё!"))
			return
	var/turf/rift_spawn_turf = get_turf(dragon)
	if(isspaceturf(rift_spawn_turf))
		to_chat(owner, span_warning("Вы не можете открыть разлом здесь! Для него нужна поверхность!"))
		return
	to_chat(owner, span_notice("Вы начинаете открывать разлом..."))
	if(!do_after(owner, 10 SECONDS, target = owner))
		return
	if(locate(/obj/structure/carp_rift) in owner.loc)
		return
	var/obj/structure/carp_rift/new_rift = new(get_turf(owner))
	playsound(owner.loc, 'sound/vehicles/rocketlaunch.ogg', 100, TRUE)
	dragon.riftTimer = -1
	new_rift.dragon = dragon
	dragon.rift_list += new_rift
	to_chat(owner, span_boldwarning("Разлом был открыт. Любой ценой не допустите его уничтожения!"))
	notify_ghosts("Космический дракон открыл разлом!", source = new_rift, action = NOTIFY_FOLLOW, flashwindow = FALSE, title = "Открытие разлома Карпов")
	ASSERT(dragon.rift_ability == src) // Badmin protection.
	QDEL_NULL(dragon.rift_ability) // Deletes this action when used successfully, we re-gain a new one on success later.

/**
 * # Carp Rift
 *
 * The portals Space Dragon summons to bring carp onto the station.
 *
 * The portals Space Dragon summons to bring carp onto the station.  His main objective is to summon 3 of them and protect them from being destroyed.
 * The portals can summon sentient space carp in limited amounts.  The portal also changes color based on whether or not a carp spawn is available.
 * Once it is fully charged, it becomes indestructible, and intermitently spawns non-sentient carp.  It is still destroyed if Space Dragon dies.
 */
/obj/structure/carp_rift
	name = "carp rift"
	desc = "Разлом, позвляющий космическим карпам перемещаться на огромные расстояния."
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 50, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 100)
	max_integrity = 300
	icon = 'icons/obj/carp_rift.dmi'
	icon_state = "carp_rift_carpspawn"
	light_color = LIGHT_COLOR_PURPLE
	light_range = 10
	anchored = TRUE
	density = FALSE
	plane = OBJ_LAYER
	/// The amount of time the rift has charged for.
	var/time_charged = 0
	/// The maximum charge the rift can have.
	var/max_charge = 300
	/// How many carp spawns it has available.
	var/carp_stored = 1
	/// A reference to the Space Dragon antag that created it.
	var/datum/antagonist/space_dragon/dragon
	/// Current charge state of the rift.
	var/charge_state = CHARGE_ONGOING
	/// The interval for adding additional space carp spawns to the rift.
	var/carp_interval = 30
	/// The time since an extra carp was added to the ghost role spawning pool.
	var/last_carp_inc = 0
	/// A list of all the ckeys which have used this carp rift to spawn in as carps.
	var/list/ckey_list = list()

/obj/structure/carp_rift/Initialize(mapload)
	. = ..()

	AddComponent( \
		/datum/component/aura_healing, \
		range = 0, \
		simple_heal = 5, \
		limit_to_trait = TRAIT_HEALS_FROM_CARP_RIFTS, \
		healing_color = COLOR_BLUE, \
	)

	START_PROCESSING(SSobj, src)

// Carp rifts always take heavy explosion damage. Discourages the use of maxcaps
// and favours more weaker explosives to destroy the portal
// as they have the same effect on the portal.
/obj/structure/carp_rift/ex_act(severity, target)
	return ..(min(EXPLODE_HEAVY, severity))

/obj/structure/carp_rift/examine(mob/user)
	. = ..()
	if(time_charged < max_charge)
		. += span_notice("Похоже, что разлом заряжен на [(time_charged / max_charge) * 100]%")
	else
		. += span_warning("Этот разлом полностью заряжен. Теперь, он может перемещать гораздо большее количество карпов, чем обычно.")

	if(isobserver(user))
		. += span_notice("В этом разломе находится [carp_stored] карпов для вселения призраков.")

/obj/structure/carp_rift/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	playsound(src, 'sound/magic/lightningshock.ogg', 50, TRUE)

/obj/structure/carp_rift/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(charge_state != CHARGE_COMPLETED)
		if(dragon)
			to_chat(dragon.owner.current, span_boldwarning("Разлом был уничтожен! Вы провалили свою задачу, и слабость одолевает вас"))
			dragon.destroy_rifts()
	dragon = null
	return ..()

/obj/structure/carp_rift/process(seconds_per_tick)
	// If we're fully charged, just start mass spawning carp.
	if(charge_state == CHARGE_COMPLETED)
		if(dragon && SPT_PROB(1.25, seconds_per_tick))
			var/mob/living/newcarp = new dragon.ai_to_spawn(loc)
			newcarp.faction = dragon.owner.current.faction.Copy()
		if(SPT_PROB(1.5, seconds_per_tick))
			var/rand_dir = pick(GLOB.cardinal)
			Move(get_step(src, rand_dir), rand_dir)
		return

	// Increase time trackers and check for any updated states.
	time_charged = min(time_charged + seconds_per_tick, max_charge)
	last_carp_inc += seconds_per_tick
	update_check()

/obj/structure/carp_rift/attack_ghost(mob/user)
	. = ..()
	if(.)
		return
	summon_carp(user)

/**
 * Does a series of checks based on the portal's status.
 *
 * Performs a number of checks based on the current charge of the portal, and triggers various effects accordingly.
 * If the current charge is a multiple of carp_interval, add an extra carp spawn.
 * If we're halfway charged, announce to the crew our location in a CENTCOM announcement.
 * If we're fully charged, tell the crew we are, change our color to yellow, become invulnerable, and give Space Dragon the ability to make another rift, if he hasn't summoned 3 total.
 */
/obj/structure/carp_rift/proc/update_check()
	// If the rift is fully charged, there's nothing to do here anymore.
	if(charge_state == CHARGE_COMPLETED)
		return

	// Can we increase the carp spawn pool size?
	if(last_carp_inc >= carp_interval)
		carp_stored++
		icon_state = "carp_rift_carpspawn"
		if(light_color != LIGHT_COLOR_PURPLE)
			light_color = LIGHT_COLOR_PURPLE
			update_light()
		notify_ghosts("Разлом может призвать дополнительного карпа!", source = src, action = NOTIFY_FOLLOW, flashwindow = FALSE, title = "Доступен космический карп")
		last_carp_inc -= carp_interval

	// Is the rift now fully charged?
	if(time_charged >= max_charge)
		charge_state = CHARGE_COMPLETED
		var/area/A = get_area(src)
		GLOB.command_announcement.Announce("Простраственный объект достиг максимального энергетического заряда в зоне [initial(A.name)]. Пожалуйста, ожидайте.", "Отдел Изучения Дикой Природы")
		max_integrity = INFINITY
		obj_integrity = INFINITY
		icon_state = "carp_rift_charged"
		light_color = LIGHT_COLOR_YELLOW
		update_light()
		armor = list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100)
		resistance_flags = INDESTRUCTIBLE
		dragon.rifts_charged += 1
		if(dragon.rifts_charged != 3 && !dragon.objective_complete)
			dragon.rift_ability = new()
			dragon.rift_ability.Grant(dragon.owner.current)
			dragon.riftTimer = 0
			dragon.rift_empower()
		// Early return, nothing to do after this point.
		return

	// Do we need to give a final warning to the station at the halfway mark?
	if(charge_state < CHARGE_FINALWARNING && time_charged >= (max_charge * 0.5))
		charge_state = CHARGE_FINALWARNING
		var/area/A = get_area(src)

		GLOB.command_announcement.Announce("Разлом создает неествественно большой поток энергии в зоне [initial(A.name)]. Остановите его любой ценой!", "Отдел Изучения Дикой Природы", 'sound/AI/spanomalies.ogg')

/**
 * Used to create carp controlled by ghosts when the option is available.
 *
 * Creates a carp for the ghost to control if we have a carp spawn available.
 * Gives them prompt to control a carp, and if our circumstances still allow if when they hit yes, spawn them in as a carp.
 * Also add them to the list of carps in Space Dragon's antgonist datum, so they'll be displayed as having assisted him on round end.
 * Arguments:
 * * mob/user - The ghost which will take control of the carp.
 */
/obj/structure/carp_rift/proc/summon_carp(mob/user)
	if(carp_stored <= 0)//Not enough carp points
		return FALSE
	var/is_listed = FALSE
	if (user.ckey in ckey_list)
		if(carp_stored == 1)
			to_chat(user, span_warning("Вы уже появлялись карпом из этого разлома! Пожалуйста, ожидайте избытка карпов или следующего разлома!"))
			return FALSE
		is_listed = TRUE
	var/carp_ask = alert(user, "Стать карпом?", "Разлом карпов", "Yes", "No")
	if(carp_ask != "Yes" || QDELETED(src) || QDELETED(user))
		return FALSE
	if(carp_stored <= 0)
		to_chat(user, span_warning("Разлом уже призвал достаточно карпов!"))
		return FALSE

	if(!dragon)
		return
	var/mob/living/newcarp = new dragon.minion_to_spawn(loc)
	newcarp.faction = dragon.owner.current.faction

	if(!is_listed)
		ckey_list += user.ckey
	newcarp.key = user.key
	newcarp.name = "carp ([rand(1, 1000)])"
	var/datum/antagonist/space_carp/carp_antag = new(src)
	newcarp.mind.add_antag_datum(carp_antag)
	dragon.carp += newcarp.mind
	to_chat(newcarp, span_boldwarning("Вы прибыли, чтобы помочь космическому дракону защищать разломы. Следуйте поставленной миссии и защитите разлом любой ценой!"))
	carp_stored--
	if(carp_stored <= 0 && charge_state < CHARGE_COMPLETED)
		icon_state = "carp_rift"
		light_color = LIGHT_COLOR_BLUE
		update_light()
	return TRUE

#undef CHARGE_ONGOING
#undef CHARGE_FINALWARNING
#undef CHARGE_COMPLETED
