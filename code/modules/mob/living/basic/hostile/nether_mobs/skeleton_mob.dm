/mob/living/basic/skeleton
	name = "reanimated skeleton"
	desc = "A real bonefied skeleton, doesn't seem like it wants to socialize."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "skeleton"
	icon_living = "skeleton"
	speak_emote = list("rattles")
	mob_biotypes = MOB_UNDEAD | MOB_HUMANOID
	maxHealth = 40
	health = 40
	a_intent = INTENT_HARM
	melee_damage_lower = 15
	melee_damage_upper = 15
	harm_intent_damage = 5
	obj_damage = 50
	melee_attack_cooldown_min = 1.5 SECONDS
	melee_attack_cooldown_max = 2.5 SECONDS
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1500
	healable = FALSE
	attack_verb_simple = "slash"
	attack_verb_continuous = "slashes"
	attack_sound = 'sound/hallucinations/growl1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, STAM = 0, OXY = 1)
	unsuitable_atmos_damage = 10
	see_in_dark = 8
	faction = list("skeleton")
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	basic_mob_flags = DEL_ON_DEATH
	step_type = FOOTSTEP_MOB_SHOE
	gold_core_spawnable = HOSTILE_SPAWN
	loot = list(/obj/effect/decal/remains/human)
	ai_controller = /datum/ai_controller/basic_controller/incursion

/mob/living/basic/skeleton/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	add_language("Galactic Common")
	set_default_language(GLOB.all_languages["Galactic Common"])

/mob/living/basic/skeleton/arctic
	name = "undead arctic explorer"
	desc = "The reanimated remains of some poor traveler."
	icon_state = "arctic_skeleton"
	icon_living = "arctic_skeleton"
	maxHealth = 55
	health = 55
	weather_immunities = list("snow")
	gold_core_spawnable = NO_SPAWN
	melee_damage_lower = 17
	melee_damage_upper = 20
	death_message = "collapses into a pile of bones, its gear falling to the floor!"
	loot = list(/obj/effect/decal/remains/human,
				/obj/item/spear,
				/obj/item/clothing/shoes/winterboots,
				/obj/item/clothing/suit/hooded/wintercoat)

/mob/living/basic/skeleton/warden
	name = "skeleton warden"
	desc = "The remains of a warden."
	icon_state = "skeleton_warden"
	icon_living = "skeleton_warden"
	loot = list(/obj/effect/decal/cleanable/shreds, /mob/living/basic/skeleton/angered_warden)
	maxHealth = 300
	health = 300
	death_message = null
	gold_core_spawnable = NO_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/simple/simple_hostile_obstacles/skeleton_warden

/mob/living/basic/skeleton/warden/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return TRUE

/mob/living/basic/skeleton/angered_warden
	name = "angered skeleton warden" // round 2
	desc = "An angry skeleton."
	icon_state = "skeleton_warden_alt"
	icon_living = "skeleton_warden_alt"
	attack_verb_simple = "claw"
	attack_verb_continuous = "claws"
	maxHealth = 200
	health = 200
	speed = -1
	melee_damage_lower = 30
	melee_damage_upper = 30
	loot = list(/obj/effect/decal/remains/human, /obj/item/clothing/head/warden, /obj/item/card/sec_shuttle_ruin)
	gold_core_spawnable = NO_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/simple/simple_hostile_obstacles/skeleton_warden

/mob/living/basic/skeleton/angered_warden/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return TRUE

/datum/ai_controller/basic_controller/simple/simple_hostile_obstacles/skeleton_warden
	idle_behavior = null // Don't idly wander

/mob/living/basic/skeleton/incursion
	name = "reinforced skeleton"
	desc = "It's got a bone to pick with you."
	health = 75
	maxHealth = 75
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/skeleton/incursion/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/event_tracker)

/mob/living/basic/skeleton/incursion/event_cost()
	. = list()
	if(is_station_level((get_turf(src)).z) && stat != DEAD)
		return list(ASSIGNMENT_SECURITY = 0.5, ASSIGNMENT_CREW = 1, ASSIGNMENT_MEDICAL = 0.5)

/mob/living/basic/skeleton/incursion/security
	name = "skeletal officer"
	desc = "HALT! SKELECURITY!"
	icon_state = "skeleton_officer"
	icon_living = "skeleton_officer"
	health = 90
	maxHealth = 90
	is_ranged = TRUE
	projectile_type = /obj/projectile/beam/laser
	projectile_sound = 'sound/weapons/gunshots/gunshot_lascarbine.ogg'
	ranged_cooldown = 2.5 SECONDS
	ai_controller = /datum/ai_controller/basic_controller/incursion/ranged_distance

/mob/living/basic/skeleton/incursion/security/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_BASICMOB_POST_ATTACK_RANGED, PROC_REF(cycle_lever))
	AddComponent(/datum/component/aggro_emote, say_list = list("Halt! Security!", "Hands up!", "Get on the ground!", "Halt! Halt! Halt!", "They're resisting!", "Lethals authorized!"))
	if(prob(20))
		loot += pick(/obj/item/clothing/head/helmet, /obj/item/clothing/suit/armor/vest/security)

/mob/living/basic/skeleton/incursion/security/proc/cycle_lever()
	sleep(0.5 SECONDS)
	playsound(src, 'sound/weapons/gun_interactions/lever_action.ogg', 60, TRUE)

/mob/living/basic/skeleton/incursion/mobster
	name = "skeletal mobster"
	desc = "THEY EXAMINED THE SKELETON! RATTLE EM, BOYS!"
	icon_state = "skeleton_mobster"
	icon_living = "skeleton_mobster"
	is_ranged = TRUE
	casing_type = /obj/item/ammo_casing/skeleton_smg
	ranged_burst_count = 6
	ranged_burst_interval = 0.1 SECONDS
	ranged_cooldown = 2.5 SECONDS
	ai_controller = /datum/ai_controller/basic_controller/incursion/ranged_distance

/mob/living/basic/skeleton/incursion/mobster/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/aggro_emote, say_list = list("Ice 'em!", "Rattle 'em, boys!", "I've got a bone to pick with you!", "Everyone's got a few skeletons in their closet!"))
	if(prob(20))
		loot += pick(/obj/item/clothing/head/fedora, /obj/item/clothing/under/suit/mafia)

/obj/item/ammo_casing/skeleton_smg
	projectile_type = /obj/projectile/bullet/skeleton_smg
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/projectile/bullet/skeleton_smg
	damage = 5

/mob/living/basic/skeleton/reanimator
	name = "skeletal reanimator"
	desc = "A dark necromancer from the depths of an unknowable darkness."
	icon_state = "skeleton_reanimator"
	icon_living = "skeleton_reanimator"
	is_ranged = TRUE
	projectile_type = /obj/projectile/magic/necrotic_bolt
	ranged_burst_count = 2
	ranged_burst_interval = 0.35 SECONDS
	projectile_sound = 'sound/magic/magic_missile.ogg'
	ai_controller = /datum/ai_controller/basic_controller/incursion/reanimator
	/// List of actions the reanimator has
	var/list/reanimator_actions = list(
		/datum/action/cooldown/mob_cooldown/summon_skulls = BB_REANIMATOR_SKULL_ACTION,
	)

/mob/living/basic/skeleton/reanimator/Initialize(mapload)
	. = ..()
	grant_actions_by_list(reanimator_actions)

/mob/living/basic/skeleton/reanimator/melee_attack(mob/living/carbon/human/target, list/modifiers, ignore_cooldown)
	if(!ishuman(target))
		return ..()
	if(target.stat != DEAD)
		return ..()
	new /obj/effect/temp_visual/cult/rune_spawn/rune7(target.loc, 5 SECONDS, "#252525")
	new /obj/effect/temp_visual/cult/rune_spawn/rune7/inner(target.loc, 5 SECONDS, "#252525")
	new /obj/effect/temp_visual/cult/rune_spawn/rune7/center(target.loc, 5 SECONDS, "#252525")

	// First, see if we can get the OG player. If not, choose from Dchat
	var/mob/dead/observer/original_ghost = target.get_ghost()
	if(original_ghost)
		to_chat(original_ghost, "<span class='ghostalert'>You are being revived by otherworldly forces! Return to your body if you want to be revived!</span> (Verbs -> Ghost -> Re-enter corpse)")
		window_flash(original_ghost.client)
		SEND_SOUND(original_ghost, sound('sound/effects/genetics.ogg'))
	if(do_after_once(src, 2 SECONDS, target = target, attempt_cancel_message = "You stop reanimating a corpse.", interaction_key = "reanimator_revive"))
		sleep(3 SECONDS) // Locks the revitalizer down for 2 seconds, but gives the player 5 seconds to return
		reanimate(target)

/mob/living/basic/skeleton/reanimator/proc/reanimate(mob/living/carbon/human/H)
	visible_message("<span class='warning'>[name] releases dark tendrils into the flesh of [H], morphing their corpse into a grotesque creature!</span>")
	var/mob/living/basic/netherworld/blankbody/blank = new(H.loc)
	blank.name = "[H]"
	blank.desc = "It's [H], but [H.p_their()] flesh has an ashy texture, and [H.p_their()] face is featureless save an eerie smile."
	blank.faction = faction.Copy()
	visible_message("<span class='warning'>[blank] staggers to [H.p_their()] feet!</span>")
	blank.held_body = H
	H.forceMove(blank)
	var/mob/dead/observer/ghost = H.get_ghost(TRUE)
	if(!ghost)
		H.mind.transfer_to(blank)
		blank.is_original_mob = TRUE
		return

	var/mob/dead/observer/chosen_ghost
	var/list/candidates
	candidates = SSghost_spawns.poll_candidates("Would you like to play as a Reanimated Blank?", ROLE_SENTIENT, FALSE, poll_time = 10 SECONDS, source = /mob/living/basic/netherworld/blankbody, role_cleanname = "blank")
	if(length(candidates))
		chosen_ghost = pick(candidates)
	if(chosen_ghost && blank.stat != DEAD)
		blank.key = chosen_ghost.key
		blank.cancel_camera()
		dust_if_respawnable(chosen_ghost)
		to_chat(blank, "<span class='userdanger'>You have been raised by the dead to serve as a footsoldier in the incursion. Strike down your foes!</span>")

/obj/projectile/magic/necrotic_bolt
	name = "necrotic bolt"
	damage = 10
	damage_type = BURN
	nodamage = 0
	icon_state = "arcane_barrage"

/datum/action/cooldown/mob_cooldown/summon_skulls
	name = "Summon Skulls"
	button_icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	button_icon_state = "legion_head"
	desc = "Summon a pair of skulls to seek out and slay enemies."
	click_to_activate = FALSE
	melee_cooldown_time = CLICK_CD_CLICK_ABILITY
	cooldown_time = 20 SECONDS
	shared_cooldown = NONE

/datum/action/cooldown/mob_cooldown/summon_skulls/Activate(atom/target)
	var/mob/living/summoner = target
	if(!istype(summoner))
		to_chat(target, "<span class='warning'>You are unable to summon skulls!</span>")
		return

	for(var/i in 1 to 2)
		var/mob/living/basic/mining/hivelordbrood/reanimator/S = new(summoner.loc)
		S.admin_spawned = summoner.admin_spawned
		S.faction = summoner.faction.Copy()
		S.Move(get_step(summoner.loc, pick(GLOB.alldirs)))
		S.ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, summoner.ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET])
		new /obj/effect/temp_visual/emp/pulse/cult(S.loc)
	StartCooldown()

// A fragile skull produced by Skeleton Reanimators
/mob/living/basic/mining/hivelordbrood/reanimator
	name = "reanimator skull"
	desc = "A cursed skull."
	icon_state = "legion_head"
	icon_living = "legion_head"
	icon_aggro = "legion_head"
	icon_dead = "legion_head"
	melee_damage_lower = 5
	attack_verb_continuous = "bites"
	attack_verb_simple = "bites"
	speak_emote = list("chatters")
	throw_blocked_message = "is shrugged off by"
	ai_controller = /datum/ai_controller/basic_controller/simple/simple_hostile_obstacles/prowler
