#define MELEE_MODE "CqC"		//Spawn people with only melee things
#define RANGED_MODE "Ranged"		//Spawn people with only ranged things
#define MIXED_MODE "Mixed"		//Spawn people with melee and ranged things
#define DEFAULT_TIME_LIMIT 5 MINUTES //Time-to-Live of participants (default - 5 minutes)
#define ARENA_COOLDOWN 5 MINUTES //After which time thunderdome will be once again allowed to use
#define CQC_ARENA_RADIUS 6 //how much tiles away from a center players will spawn
#define RANGED_ARENA_RADIUS 10
#define VOTING_POLL_TIME 60 SECONDS
#define MAX_PLAYERS_COUNT 16
#define MIN_PLAYERS_COUNT 2
#define SPAWN_COEFFICENT 0.85 //how many (polled * spawn_coefficent) players will go brawling
/* Uncomment this if you want to mess up with thunderdome alone
#define THUND_TESTING
#ifdef THUND_TESTING
#define DEFAULT_TIME_LIMIT 30 SECONDS
#define ARENA_COOLDOWN 30 SECONDS
#define VOTING_POLL_TIME 10 SECONDS
#define MIN_PLAYERS_COUNT 1
#endif
*/

GLOBAL_DATUM_INIT(thunderdome_battle, /datum/thunderdome_battle, new())

/**
 * #thunderdome_battle
 *
 * This datum is responsible for making fun for non-admin ghosts who want to have a brawl on thunderdome.
 *
 * Constants were defined in variables of this class in case if you need to adjust parameters of a brawl through VV.
 * Be aware, that you'll have to make indestructible area if you want to use it properly.
 * /obj/thunderdome_poller object is basically a center of the arena and can be used from "mob spawn" ghost menu.
 */
/datum/thunderdome_battle
	var/spawn_minimum_limit = MIN_PLAYERS_COUNT
	var/spawn_coefficent = SPAWN_COEFFICENT
	var/isGoing = FALSE
	var/maxplayers = MAX_PLAYERS_COUNT
	var/time_limit = DEFAULT_TIME_LIMIT
	var/arena_cooldown = ARENA_COOLDOWN
	var/gamemode = MELEE_MODE
	var/cqc_arena_radius = CQC_ARENA_RADIUS
	var/ranged_arena_radius = RANGED_ARENA_RADIUS
	var/voting_poll_time = VOTING_POLL_TIME
	var/role = ROLE_THUNDERDOME
	var/melee_random_items_count = 1
	var/ranged_random_items_count = 2
	var/mixed_random_items_count = 1

	var/list/melee_pool = list(
		/obj/item/CQC_manual = 1,
		/obj/item/sleeping_carp_scroll = 1,
		/obj/item/clothing/gloves/color/black/krav_maga/sec = 1,
		/obj/item/clothing/gloves/fingerless/rapid = 1,
		/obj/item/melee/baton/loaded = 1,
		/obj/item/melee/baseball_bat = 1,
		/obj/item/melee/rapier = 1,
		/obj/item/melee/energy/axe = 1,
		/obj/item/melee/energy/sword/saber/red = 1,
		/obj/item/melee/energy/cleaving_saw = 1,
		/obj/item/twohanded/mjollnir = 1,
		/obj/item/twohanded/chainsaw = 1,
		/obj/item/twohanded/dualsaber = 1,
		/obj/item/twohanded/singularityhammer = 1,
		/obj/item/twohanded/fireaxe = 1
	)

	var/list/ranged_pool = list(
		/obj/item/gun/energy/immolator/multi = 1,
		/obj/item/gun/projectile/automatic/mini_uzi = 1,
		/obj/item/gun/projectile/automatic/pistol/deagle = 1,
		/obj/item/gun/projectile/automatic/wt550 = 1,
		/obj/item/gun/projectile/automatic/l6_saw = 1,
		/obj/item/gun/projectile/automatic/lasercarbine = 1,
		/obj/item/gun/projectile/automatic/shotgun/bulldog = 1,
		/obj/item/gun/magic/wand/fireball = 1,
		/obj/item/gun/projectile/revolver/mateba = 3,
		/obj/item/gun/projectile/shotgun/automatic = 2,
		/obj/item/gun/projectile/shotgun/riot = 2,
		/obj/item/gun/projectile/automatic/ak814 = 1,
		/obj/item/gun/projectile/automatic/shotgun/bulldog = 2
	)

/**
  * Starts poll for candidates with a question and a preview of the mode
  *
  * Arguments:
  * * mode - Name of the tdome mode: "ranged", "cqc", "mixed"
  * * center - Object in the center of a thunderdome
  */
/datum/thunderdome_battle/proc/start(mode as text, obj/center)
	if(isGoing)
		return
	isGoing = TRUE
	add_game_logs("Thunderdome poll voting in [mode] mode started.")
	var/image/I = new('icons/mob/thunderdome_previews.dmi', "thunderman_preview_[mode]")
	var/list/candidates = shuffle(SSghost_spawns.poll_candidates("Желаете записаться на Тандердом? (Режим - [mode])", \
		role, poll_time = voting_poll_time, ignore_respawnability = TRUE, check_antaghud = FALSE, source = I))
	var/players_count = clamp(CEILING(length(candidates)*spawn_coefficent, 1), 0, maxplayers)
	if(players_count < spawn_minimum_limit)
		notify_ghosts("Not enough players to start Thunderdome Battle!")
		addtimer(CALLBACK(src, PROC_REF(clear_thunderdome)), arena_cooldown) //making sure there will be no spam
		return

	//vars below are responsible for making spawns at the edge of circle with certain radius
	var/points = players_count
	var/delta_phi_ = 2 * PI / points
	var/currpoint = 1
	var/curr_x = center.x
	var/curr_y = center.y
	var/phi = 0
	var/radius
	//circle-builder vars ended
	var/list/random_stuff = list()
	var/brawler_type

	switch(mode)
		if(RANGED_MODE)
			brawler_type = /obj/effect/mob_spawn/human/thunderdome/ranged
			radius = RANGED_ARENA_RADIUS
			random_stuff += get_random_items(ranged_pool, ranged_random_items_count)
		if(MELEE_MODE)
			brawler_type = /obj/effect/mob_spawn/human/thunderdome/cqc
			radius = CQC_ARENA_RADIUS
			random_stuff += get_random_items(melee_pool, melee_random_items_count)
		if(MIXED_MODE)
			brawler_type = /obj/effect/mob_spawn/human/thunderdome/mixed
			radius = RANGED_ARENA_RADIUS
			random_stuff += get_random_items(melee_pool, mixed_random_items_count)
			random_stuff += get_random_items(ranged_pool, mixed_random_items_count)
		else
			isGoing = FALSE
			return //Shouldn't be happening.

	if(mode == MELEE_MODE)
		for(var/obj/machinery/door/poddoor/M in GLOB.airlocks)
			if(M.id_tag != "TD_CloseCombat")
				continue
			spawn(0)
				M.close()

	if(mode == RANGED_MODE || mode == MIXED_MODE)
		for(var/obj/machinery/door/poddoor/M in GLOB.airlocks)
			if(M.id_tag != "TD_CloseCombat")
				continue
			if(M.density)
				spawn(0)
					M.open()


	while(currpoint <= points)
		if(phi > (2 * PI))
			break;
		var/ang = phi * 180 / PI
		curr_x = center.x + radius * cos(ang)
		curr_y = center.y + radius * sin(ang)
		var/obj/effect/mob_spawn/human/thunderdome/brawler = new brawler_type(get_rounded_location(curr_x, curr_y, center.z))
		brawler.outfit.backpack_contents += random_stuff
		var/mob/dead/observer/ghost = candidates[currpoint]
		brawler.attack_ghost(ghost)
		phi += delta_phi_
		currpoint += 1

	add_game_logs("Thunderdome battle has begun in [mode] mode.")
	addtimer(CALLBACK(src, PROC_REF(clear_thunderdome)), time_limit)

/**
  * Rolls items from a list and returns associative list with keys and values.
  *	Does not check if it's not associative list or some values don't have them.
  *
  * Arguments:
  * * from - list we are collecting items from
  * * count - how many items we will roll from a list
  */

/datum/thunderdome_battle/proc/get_random_items(list/from, count)
	var/list/random_items = list()
	if(count <= 0)
		return
	for(var/i in 1 to count)
		random_items += pick(from)

	for(var/i in random_items)
		random_items[i] = from[i]

	return random_items

/**
 * Clears thunderdome and it's specific areas, also resets thunderdome state.
 *
*/
/datum/thunderdome_battle/proc/clear_thunderdome()
	var/area/tdome_arena = locate(/area/tdome/newtdome)
	var/area/tdome_arena_melee = locate(/area/tdome/newtdome/CQC)

	clear_area(tdome_arena)
	clear_area(tdome_arena_melee)

	isGoing = FALSE
	add_game_logs("Thunderdome battle has ended.")
	var/image/alert_overlay = image('icons/obj/assemblies.dmi', "thunderdome-bomb-active-wires")
	notify_ghosts(message = "Thunderdome is ready for battle!", title="Thunderdome News", alert_overlay = alert_overlay, ghost_sound = 'sound/misc/notice2.ogg')

/**
 * Clears area from:
 * All mobs
 * All object except thunderdome poller and poddors (shutters included)
 * *Arguments:
 * *zone - specific area
 */
/datum/thunderdome_battle/proc/clear_area(area/zone)
	if(!zone)
		return
	for(var/mob/living/mob in zone)
		mob.melt()

	for(var/obj/A in zone)
		if(istype(A, /obj/machinery/door/poddoor) || istype(A, /obj/thunderdome_poller))
			continue
		qdel(A)

/**
 * Gets location with rounded coordinates (needed for precise geometry builder)
 */
/datum/thunderdome_battle/proc/get_rounded_location(curr_x, curr_y, z)
	return locate(round(curr_x), round(curr_y), z)

/**
 * Invisible object which is responsible for rolling brawlers for fighting on thunderdome.
 */
/obj/thunderdome_poller
	name = "Thunderdome Poller (Melee)"
	desc = "Желаете стать лучшим бойцом? Опробуйте себя на Тандердоме в роли мастера ближнего боя!"
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "thunderdome-bomb"
	anchored = 1
	density = 0
	invisibility = INVISIBILITY_MAXIMUM
	opacity = 0
	layer = BELOW_MOB_LAYER
	resistance_flags = INDESTRUCTIBLE
	var/gamemode = MELEE_MODE
	var/datum/thunderdome_battle/thunderdome

/obj/thunderdome_poller/is_mob_spawnable()
	return TRUE

/obj/thunderdome_poller/ranged
	name = "Thunderdome Poller (Ranged)"
	desc = "Желаете стать лучшим стрелком? Опробуйте себя на Тандердоме в роли мастера со смертельным арсеналом!"
	gamemode = RANGED_MODE

/obj/thunderdome_poller/mixed
	name = "Thunderdome Poller (Ranged+Melee)"
	desc = "Желаете стать лучшим воином? Опробуйте себя на Тандердоме в роли мастера стрелковых искусств и техник ближнего боя!"
	gamemode = MIXED_MODE

/obj/thunderdome_poller/Initialize(mapload)
	. = ..()
	GLOB.poi_list |= src
	LAZYADD(GLOB.mob_spawners[name], src)

/obj/thunderdome_poller/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(!thunderdome)
		thunderdome = GLOB.thunderdome_battle
	if(!SSghost_spawns.is_eligible(user, ROLE_THUNDERDOME))
		to_chat(user, "Вы не можете использовать Тандердом. Включите эту возможность в Game Preferences!")
		return
	if(thunderdome.isGoing)
		to_chat(user, "Битва все ещё идёт или прошло недостаточно времени с момента последнего голосования!")
		return
	thunderdome.start(gamemode, src)

/obj/item/storage/backpack/thunderdome_infinite
	name = "fighter's interdimensional backpack"
	desc = "A spacious backpack with lots of pocket dimensions, used by fighters of Thunderdome"
	icon_state = "ert_commander"
	item_state = "backpack"
	max_combined_w_class = 999
	max_w_class = WEIGHT_CLASS_HUGE
	resistance_flags = FIRE_PROOF

/obj/effect/mob_spawn/human/thunderdome
	roundstart = FALSE
	death = FALSE
	min_hours = 0
	allow_tts_pick = FALSE

/obj/effect/mob_spawn/human/thunderdome/attack_ghost(mob/user)
	if(SSticker.current_state != GAME_STATE_PLAYING || !loc || !ghost_usable)
		return
	if(jobban_isbanned(user, banType))
		to_chat(user, "<span class='warning'>You are jobanned!</span>")
		return
	if(config.use_exp_restrictions && min_hours)
		if(user.client.get_exp_type_num(exp_type) < min_hours * 60 && !check_rights(R_ADMIN|R_MOD, 0, usr))
			to_chat(user, "<span class='warning'>У вас недостаточно часов для игры на этой роли. Требуется набрать [min_hours] часов типа [exp_type] для доступа к ней.</span>")
			return
	var/mob_use_prefs = FALSE
	var/_mob_species = FALSE
	var/_mob_gender = FALSE
	var/_mob_name = FALSE
	if(!loc || !uses || QDELETED(src) || QDELETED(user))
		to_chat(user, "<span class='warning'>The [name] is no longer usable!</span>")
		return
	if(id_job == null)
		add_game_logs("[user.ckey] became [mob_name]", user)
	else
		add_game_logs("[user.ckey] became [mob_name]. Job: [id_job]", user)
	create(plr = user, prefs = mob_use_prefs, _mob_name = _mob_name, _mob_gender = _mob_gender, _mob_species = _mob_species)

/datum/outfit/thunderdome
	implants = list(
		/obj/item/implant/postponed_death,
		/obj/item/implant/adrenalin
	)
	uniform = /obj/item/clothing/under/misc/durathread
	shoes = /obj/item/clothing/shoes/combat
	back = /obj/item/storage/backpack/thunderdome_infinite
	head = /obj/item/clothing/head/HoS

/datum/outfit/thunderdome/cqc
	name = "Fighter"
	backpack_contents = list(
		/obj/item/CQC_manual = 1,
		/obj/item/sleeping_carp_scroll = 1,
		/obj/item/ipc_combat_upgrade = 1,
		/obj/item/clothing/gloves/color/black/krav_maga/sec = 1,
		/obj/item/clothing/gloves/fingerless/rapid = 1
	)

/datum/outfit/thunderdome/ranged
	name = "Ranger"
	backpack_contents = list(

	)

/datum/outfit/thunderdome/mixed
	name = "Gladiator"
	backpack_contents = list(

	)

/obj/effect/mob_spawn/human/thunderdome/cqc
	name = "CQC Thunderdome Brawler"
	mob_name = "Fighter"
	icon = 'icons/mob/thunderdome_previews.dmi'
	flavour_text = "Станьте лучшим бойцом арены среди любителей ближнего боя!"
	outfit = /datum/outfit/thunderdome/cqc

/obj/effect/mob_spawn/human/thunderdome/ranged
	name = "Ranged Thunderdome Brawler"
	mob_name = "Ranger"
	icon = 'icons/mob/thunderdome_previews.dmi'
	flavour_text = "Станьте лучшим бойцом арены среди любителей дальнего боя!"
	outfit = /datum/outfit/thunderdome/ranged

/obj/effect/mob_spawn/human/thunderdome/mixed
	name = "Mixed Thunderdome Brawler"
	mob_name = "Gladiator"
	icon = 'icons/mob/thunderdome_previews.dmi'
	flavour_text = "Станьте лучшим бойцом арены среди любителей любого боя!"
	outfit = /datum/outfit/thunderdome/mixed

/**
 *  Special implant that will definetly end brawler's life. Sad, but we have queue to go!
 */
/obj/item/implant/postponed_death
	name = "Postponed death implant"
	desc = "Kills you after specific amount of time"
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	var/time_to_live = DEFAULT_TIME_LIMIT

/obj/item/implant/postponed_death/implant(mob/source, mob/user)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(activate)), time_to_live)

/obj/item/implant/postponed_death/activate()
	imp_in.melt()

#undef MELEE_MODE
#undef RANGED_MODE
#undef MIXED_MODE
#undef DEFAULT_TIME_LIMIT
#undef CQC_ARENA_RADIUS
#undef RANGED_ARENA_RADIUS
#undef ARENA_COOLDOWN
#undef VOTING_POLL_TIME
#undef MAX_PLAYERS_COUNT
#undef MIN_PLAYERS_COUNT
#undef SPAWN_COEFFICENT
