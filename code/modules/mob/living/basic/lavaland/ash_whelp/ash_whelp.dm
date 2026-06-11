/mob/living/basic/mining/ash_whelp
	name = "ash whelp"
	desc = "The offspring of an ash drake, weak in comparison but still terrifying."
	icon_state = "ash_whelp"
	icon_living = "ash_whelp"
	icon_dead = "ash_whelp_dead"
	mouse_opacity = MOUSE_OPACITY_ICON
	butcher_results = list(
		/obj/item/stack/ore/gold = 3,
		/obj/item/stack/sheet/animalhide/ashdrake = 1,
		/obj/item/stack/sheet/bone = 10,
		/obj/item/stack/sheet/sinew = 2,
	)
	crusher_loot = list(/obj/item/crusher_trophy/tail_spike)
	speed = 12

	maxHealth = 300
	health = 300
	obj_damage = 40
	armor_penetration_flat = 20
	melee_damage_lower = 20
	melee_damage_upper = 25

	response_help_continuous = "pets"
	response_help_simple = "pet"
	attack_verb_continuous = "chomps"
	attack_verb_simple = "chomp"
	throw_blocked_message = "does nothing to the scaled hide of the"
	death_message = "collapses on its side."
	death_sound = 'sound/misc/demon_dies.ogg'
	attack_sound = 'sound/misc/demon_attack1.ogg'

	faction = list("mining")

	move_force =  MOVE_FORCE_STRONG
	move_resist = MOVE_FORCE_STRONG
	pull_force = MOVE_FORCE_STRONG

	ai_controller = /datum/ai_controller/basic_controller/ash_whelp
	var/list/innate_actions = list(
		/datum/action/cooldown/mob_cooldown/fire_breath = BB_WHELP_STRAIGHTLINE_FIRE,
		/datum/action/cooldown/mob_cooldown/fire_breath/ice/eruption/fire = BB_WHELP_WIDESPREAD_FIRE,
	)

	/// How much we will heal when consuming a target
	var/heal_on_cannibalize = 5

/mob/living/basic/mining/ash_whelp/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	AddComponent(/datum/component/ai_target_timer)
	AddComponent(/datum/component/footstep, FOOTSTEP_MOB_HEAVY)
	grant_actions_by_list(innate_actions)

/mob/living/basic/mining/ash_whelp/early_melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()

	if(istype(target, /obj/structure/flora/ash/rock))
		create_sculpture(target)
		return FALSE

	if(!istype(target, type))
		return TRUE

	var/mob/living/victim = target
	if(victim.stat != DEAD)
		return TRUE

	if(istype(target, /mob/living/basic/mining/ash_whelp))
		cannibalize_victim(victim)
		return FALSE
	return FALSE

/// Carve a stone into a beautiful self-portrait
/mob/living/basic/mining/ash_whelp/proc/create_sculpture(atom/target)
	visible_message("[src] starts to sculpt [target].")
	if(!do_after(src, 5 SECONDS, target = target))
		return
	var/obj/structure/whelp_statue/dragon_statue = new(get_turf(target))
	dragon_statue.name = "statue of [src]"
	dragon_statue.desc = "Let this serve as a warning."
	qdel(target)

/// Gib and consume our fellow ash drakes
/mob/living/basic/mining/ash_whelp/proc/cannibalize_victim(mob/living/target)
	start_pulling(target)
	visible_message("[src] starts to consume [target].")
	if(!do_after(src, 5 SECONDS, target))
		return
	target.gib()
	adjustBruteLoss(-1 * heal_on_cannibalize)

/// Ice whelp, the cold variant of ash whelps.
/mob/living/basic/mining/ash_whelp/ice
	name = "ice whelp"
	desc = "The offspring of an ash drake, weak in comparison but still terrifying. This one exudes an icy aura."
	icon_state = "ice_whelp"
	icon_living = "ice_whelp"
	icon_dead = "ice_whelp_dead"
	innate_actions = list(
		/datum/action/cooldown/mob_cooldown/fire_breath/ice = BB_WHELP_STRAIGHTLINE_FIRE,
		/datum/action/cooldown/mob_cooldown/fire_breath/ice/eruption = BB_WHELP_WIDESPREAD_FIRE,
	)

/// Ash whelp statue formed by them carving a rock
/obj/structure/whelp_statue
	name = "statue of an ash whelp"
	desc = "A basalt sculpture of a proud and regal drake. Its eyes are six glowing gemstones."
	icon = 'icons/obj/structures/statues.dmi'
	icon_state = "drake"
	density = TRUE
	anchored = TRUE
	integrity_failure = 100
	layer = EDGED_TURF_LAYER

/obj/structure/whelp_statue/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	update_icon(UPDATE_ICON_STATE)

/obj/structure/whelp_statue/update_icon_state()
	if(broken)
		icon_state = "drake_headless"
		return
	icon_state = "drake"
