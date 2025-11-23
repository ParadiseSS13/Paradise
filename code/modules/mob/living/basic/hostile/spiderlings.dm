/mob/living/basic/spiderling
	name = "spiderling"
	desc = "It never stays still for long."
	icon_state = "spiderling"
	icon_dead = "spiderling_dead" // Doesn't exist, because they splat.
	density = FALSE
	speed = -0.75
	move_resist = INFINITY // YOU CAN'T HANDLE ME LET ME BE FREE LET ME BE FREE LET ME BE FREE
	speak_emote = list("hisses")
	layer = 2.75
	basic_mob_flags = FLAMMABLE_MOB | DEL_ON_DEATH
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB | PASSDOOR
	mob_size = MOB_SIZE_TINY
	ventcrawler = TRUE
	melee_damage_lower = 1
	melee_damage_upper = 1
	health = 5
	maxHealth = 5
	faction = list("spiders")
	attack_verb_simple = "bite"
	attack_verb_continuous = "bites"
	attack_sound = 'sound/weapons/bite.ogg'
	can_hide = TRUE
	ai_controller = /datum/ai_controller/basic_controller/spiderling
	/// How grown up is the spider?
	var/amount_grown = 0
	/// The mob the spiderling will grow into. null is giant spiders.
	var/grow_as = null
	/// Is the spider supposed to be player controlled?
	var/player_spiders = FALSE
	/// Are we selecting a player?
	var/selecting_player = FALSE

/mob/living/basic/spiderling/Initialize(mapload)
	. = ..()
	pixel_x = rand(6,-6)
	pixel_y = rand(6,-6)
	AddComponent(/datum/component/swarming)
	AddElement(/datum/element/ai_retaliate)
	ADD_TRAIT(src, TRAIT_EDIBLE_BUG, "edible_bug")

/mob/living/basic/spiderling/Life(seconds, times_fired)
	. = ..()
	if(!isturf(loc))
		return
	amount_grown += rand(0,2)
	if(amount_grown < 100)
		return
	if(SSmobs.xenobiology_mobs > MAX_GOLD_CORE_MOBS && HAS_TRAIT(src, TRAIT_XENOBIO_SPAWNED))
		qdel(src)
		return
	if(!grow_as)
		grow_as = pick(typesof(/mob/living/basic/giant_spider) - list(/mob/living/basic/giant_spider/hunter/infestation_spider, /mob/living/basic/giant_spider/araneus))
	var/mob/living/basic/giant_spider/S = new grow_as(loc)
	S.faction = faction.Copy()
	S.master_commander = master_commander
	if(HAS_TRAIT(src, TRAIT_XENOBIO_SPAWNED))
		ADD_TRAIT(S, TRAIT_XENOBIO_SPAWNED, "xenobio")
		SSmobs.xenobiology_mobs++
	if(!player_spiders)
		qdel(src)
		return
	if(selecting_player)
		return
	selecting_player = TRUE
	spawn()
		var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a giant spider?", ROLE_SENTIENT, TRUE, source = S)
		if(!length(candidates) || QDELETED(S))
			return
		var/mob/C = pick(candidates)
		if(C)
			S.key = C.key
			dust_if_respawnable(C)
			if(S.master_commander)
				to_chat(S, "<span class='biggerdanger'>You are a spider who is loyal to [S.master_commander], obey [S.master_commander]'s every order and assist [S.master_commander.p_them()] in completing [S.master_commander.p_their()] goals at any cost.</span>")
	qdel(src)

/mob/living/basic/spiderling/death(gibbed)
	if(!istype(loc, /obj/machinery/atmospherics))
		new /obj/effect/decal/cleanable/spiderling_remains(get_turf(src))
	. = ..()

/mob/living/basic/spiderling/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(isdrone(user))
		return ..()
	user.visible_message("<span class='notice'>[user] sucks [src] into its decompiler. There's a horrible crunching noise.</span>", \
	"<span class='warning'>It's a bit of a struggle, but you manage to suck [src] into your decompiler. It makes a series of visceral crunching noises.</span>")
	C.stored_comms["metal"] += 2
	C.stored_comms["glass"] += 1
	playsound(src, 'sound/misc/demon_consume.ogg', 10, TRUE, SOUND_RANGE_SET(4))
	qdel(src)
	return TRUE

/obj/effect/decal/cleanable/spiderling_remains
	name = "spiderling remains"
	desc = "Green squishy mess."
	icon_state = "greenshatter"

// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: SPIDERLINGS (USED BY GREEN, WHITE, QUEEN AND MOTHER TYPES)
// --------------------------------------------------------------------------------

/mob/living/basic/spiderling/terror_spiderling
	desc = "A fast-moving tiny spider, prone to making aggressive hissing sounds. Hope it doesn't grow up."
	speed = -1
	faction = list("terrorspiders")
	var/stillborn = FALSE
	var/mob/living/simple_animal/hostile/poison/terror_spider/queen/spider_myqueen = null
	var/mob/living/simple_animal/hostile/poison/terror_spider/spider_mymother = null
	var/list/enemies = list()
	var/spider_awaymission = FALSE

/mob/living/basic/spiderling/terror_spiderling/Initialize(mapload)
	. = ..()
	GLOB.ts_spiderling_list += src
	if(is_away_level(z))
		spider_awaymission = TRUE

/mob/living/basic/spiderling/terror_spiderling/death(gibbed)
	GLOB.ts_spiderling_list -= src
	return ..()

/mob/living/basic/spiderling/terror_spiderling/Life(seconds, times_fired)
	. = ..()
	var/turf/T = get_turf(src)
	amount_grown += rand(0,2)
	if(amount_grown >= 100)
		if(spider_awaymission && !is_away_level(T.z))
			stillborn = TRUE
		if(stillborn)
			if(amount_grown >= 300)
				// Fake spiderlings stick around for awhile, just to be spooky.
				qdel(src)
		else
			if(!grow_as)
				grow_as = pick(/mob/living/simple_animal/hostile/poison/terror_spider/red, /mob/living/simple_animal/hostile/poison/terror_spider/gray, /mob/living/simple_animal/hostile/poison/terror_spider/green)
			var/mob/living/simple_animal/hostile/poison/terror_spider/S = new grow_as(T)
			S.spider_myqueen = spider_myqueen
			S.spider_mymother = spider_mymother
			S.enemies = enemies
			qdel(src)

/datum/ai_controller/basic_controller/spiderling
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/of_size/larger, // Run away from mobs bigger than we are
		BB_VENT_SEARCH_RANGE = 10,
		BB_VENTCRAWL_DELAY = 1
	)
	ai_movement = /datum/ai_movement/jps
	idle_behavior = /datum/idle_behavior/idle_random_walk

	// We understand that vents are nice little hidey holes through epigenetic inheritance, so we'll use them.
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/opportunistic, // Trapped! Bite the person trapping them.
		/datum/ai_planning_subtree/simple_find_nearest_target_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/ventcrawl_find_target/spiderling,
		/datum/ai_planning_subtree/ventcrawl/spiderling,
		/datum/ai_planning_subtree/random_speech/insect,
	)

/datum/ai_planning_subtree/ventcrawl_find_target/spiderling
	crawl_behavior = /datum/ai_behavior/find_ventcrawl_target/spiderling

/datum/ai_behavior/find_ventcrawl_target/spiderling
	action_cooldown = 20 SECONDS

/datum/ai_planning_subtree/ventcrawl/spiderling
	ventcrawl_finding_behavior = /datum/ai_behavior/find_and_set/ventcrawl/spiderling

/datum/ai_behavior/find_and_set/ventcrawl/spiderling
	searched_entry_types = list(/obj/machinery/atmospherics/unary/vent_pump)
