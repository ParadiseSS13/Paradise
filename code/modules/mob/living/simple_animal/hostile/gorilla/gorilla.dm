/mob/living/simple_animal/hostile/gorilla
	name = "Gorilla"
	desc = "A ground-dwelling, predominantly herbivorous ape that inhabits the forests of central Africa."
	icon = 'icons/mob/gorilla.dmi'
	icon_state = "crawling"
	icon_living = "crawling"
	icon_dead = "dead"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	speak_chance = 80
	maxHealth = 220
	health = 220
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/gorilla = 4)
	response_help = "prods"
	response_disarm = "challenges"
	response_harm = "thumps"
	attacktext = "pummels"
	speed = 0.5
	melee_damage_lower = 15
	melee_damage_upper = 18
	damage_coeff = list(BRUTE = 1, BURN = 1.5, TOX = 1.5, CLONE = 0, STAMINA = 0, OXY = 1.5)
	obj_damage = 20
	environment_smash = ENVIRONMENT_SMASH_WALLS | ENVIRONMENT_SMASH_STRUCTURES
	attack_sound = 'sound/weapons/punch1.ogg'
	faction = list("monkey", "jungle")
	robust_searching = TRUE
	minbodytemp = 270
	maxbodytemp = 350
	footstep_type = FOOTSTEP_MOB_BAREFOOT

// Gorillas like to dismember limbs from unconscious mobs.
// Returns null when the target is not an unconscious carbon mob; a list of limbs (possibly empty) otherwise.
/mob/living/simple_animal/hostile/gorilla/proc/get_target_bodyparts(atom/hit_target)
	if(!iscarbon(hit_target))
		return

	var/mob/living/carbon/human/target = hit_target
	if(target.stat < UNCONSCIOUS)
		return

	var/list/parts = list()
	for(var/obj/item/organ/external/part as anything in target.bodyparts)
		if(istype(part, /obj/item/organ/external/chest) || istype(part, /obj/item/organ/external/head))
			continue
		if(part.limb_flags & CANNOT_DISMEMBER)
			continue
		parts += part
	return parts

/mob/living/simple_animal/hostile/gorilla/AttackingTarget(atom/attacked_target)
	. = ..()
	if(!.)
		return

	if(client)
		oogaooga()

	var/list/parts = get_target_bodyparts(target)
	if(length(parts))
		var/obj/item/organ/external/to_dismember = pick(parts)
		to_dismember.droplimb()
		return

	if(isliving(target))
		var/mob/living/living_target = target
		if(prob(80))
			living_target.throw_at(get_edge_target_turf(living_target, dir), rand(1, 2), 7, src)
			return

		living_target.Paralyse(2 SECONDS)
		visible_message("<span class='warning'>[src] knocks [living_target] down!</span>")

/mob/living/simple_animal/hostile/gorilla/CanAttack(atom/the_target)
	var/list/parts = get_target_bodyparts(target)
	return ..() && !ismonkeybasic(the_target) && (!parts || length(parts) > 3)

/mob/living/simple_animal/hostile/gorilla/CanSmashTurfs(turf/T)
	return iswallturf(T)

/mob/living/simple_animal/hostile/gorilla/handle_automated_speech(override)
	if(speak_chance && (override || prob(speak_chance)))
		playsound(src, 'sound/creatures/gorilla.ogg', 50)
	return ..()

/mob/living/simple_animal/hostile/gorilla/can_use_guns(obj/item/G)
	to_chat(src, "<span class='warning'>Your meaty finger is much too large for the trigger guard!</span>")
	return FALSE

/mob/living/simple_animal/hostile/gorilla/proc/oogaooga()
	if(prob(rand(15, 50)))
		playsound(src, 'sound/creatures/gorilla.ogg', 50)

/obj/item/card/id/supply/cargo_gorilla
	name = "cargorilla ID"
	registered_name = "Cargorilla"
	desc = "A card used to provide ID and determine access across the station. A gorilla-sized ID for a gorilla-sized cargo technician."

/mob/living/simple_animal/hostile/gorilla/cargo_domestic
	name = "Cargorilla" // Overriden, normally
	icon = 'icons/mob/cargorillia.dmi'
	desc = "Cargo's pet gorilla. They seem to have an 'I love Mom' tattoo."
	maxHealth = 200
	health = 200
	faction = list("neutral", "monkey", "jungle")
	gold_core_spawnable = NO_SPAWN
	/// The ID card that the gorilla is currently wearing.
	var/obj/item/card/id/access_card
	/// The max number of crates we can carry
	var/crate_limit = 3
	/// Typecache of all the types we can pick up and carry
	var/list/carriable_cache
	/// A lazylist of all crates we are carrying
	var/list/atom/movable/crates_in_hand

/mob/living/simple_animal/hostile/gorilla/cargo_domestic/Initialize(mapload)
	. = ..()
	access_card = new /obj/item/card/id/supply/cargo_gorilla(src)
	var/static/default_cache = typecacheof(list(/obj/structure/closet/crate))
	carriable_cache = default_cache
	ADD_TRAIT(src, TRAIT_PACIFISM, INNATE_TRAIT)

/mob/living/simple_animal/hostile/gorilla/cargo_domestic/Destroy()
	LAZYCLEARLIST(crates_in_hand)
	QDEL_NULL(access_card)
	return ..()

/mob/living/simple_animal/hostile/gorilla/cargo_domestic/AttackingTarget(atom/attacked_target)
	if(is_type_in_typecache(target, carriable_cache))
		var/atom/movable/movable_target = target
		if(LAZYLEN(crates_in_hand) >= crate_limit)
			to_chat(src, "<span class='warning'>You are carrying too many crates!</span>")
			return COMPONENT_CANCEL_ATTACK_CHAIN

		for(var/mob/living/inside_mob in movable_target.contents)
			if(inside_mob.mob_size < MOB_SIZE_HUMAN)
				continue
			to_chat(src, "<span class='warning'>This crate is too heavy!</span>")
			return COMPONENT_CANCEL_ATTACK_CHAIN

		LAZYADD(crates_in_hand, target)
		update_icon(UPDATE_OVERLAYS | UPDATE_ICON_STATE)
		movable_target.forceMove(src)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(isturf(target) && !is_blocked_turf(target) && LAZYLEN(crates_in_hand))
		drop_random_crate(target)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	return ..()

/mob/living/simple_animal/hostile/gorilla/cargo_domestic/update_icon_state()
	. = ..()
	if(LAZYLEN(crates_in_hand))
		icon_state = "standing"
		return
	icon_state = initial(icon_state)

/mob/living/simple_animal/hostile/gorilla/cargo_domestic/update_overlays()
	. = ..()
	if(!LAZYLEN(crates_in_hand))
		return
	var/atom/movable/random_crate = pick(crates_in_hand)
	. += mutable_appearance(random_crate)
	. += mutable_appearance('icons/mob/cargorillia.dmi', "standing_overlay")

/mob/living/simple_animal/hostile/gorilla/cargo_domestic/death(gibbed)
	drop_all_crates(drop_location())
	return ..()

/mob/living/simple_animal/hostile/gorilla/cargo_domestic/examine(mob/user)
	. = ..()
	var/num_crates = LAZYLEN(crates_in_hand)
	if(num_crates)
		. += "<span class='notice'>[p_theyre(TRUE)] carrying [num_crates == 1 ? "a crate" : "[num_crates] crates"].</span>"

/// Drops one random crates from our crate list.
/mob/living/simple_animal/hostile/gorilla/cargo_domestic/proc/drop_random_crate(atom/drop_to)
	var/obj/structure/closet/crate/held_crate = pick(crates_in_hand)
	held_crate.forceMove(drop_to)
	LAZYREMOVE(crates_in_hand, held_crate)
	update_icon(UPDATE_OVERLAYS | UPDATE_ICON_STATE)

/// Drops all the crates in our crate list.
/mob/living/simple_animal/hostile/gorilla/cargo_domestic/proc/drop_all_crates(atom/drop_to)
	for(var/obj/structure/closet/crate/held_crate as anything in crates_in_hand)
		held_crate.forceMove(drop_to)
		LAZYREMOVE(crates_in_hand, held_crate)
	update_icon(UPDATE_OVERLAYS | UPDATE_ICON_STATE)
