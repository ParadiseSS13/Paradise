/mob/living/simple_animal/hostile/gorilla
	name = "gorilla"
	desc = "A ground-dwelling, predominantly herbivorous ape that inhabits the forests of central Africa on Earth."
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
	faction = list("hostile", "monkey", "jungle")
	robust_searching = TRUE
	minbodytemp = 270
	maxbodytemp = 350
	footstep_type = FOOTSTEP_MOB_BAREFOOT
	stat_attack = UNCONSCIOUS // Sleeping won't save you
	a_intent = INTENT_HARM // Angrilla
	/// Is the gorilla stood up or not?
	var/is_bipedal = FALSE
	/// The max number of crates we can carry
	var/crate_limit = 1
	/// Typecache of all the types we can pick up and carry
	var/list/carriable_cache
	/// A lazylist of all crates we are carrying
	var/list/atom/movable/crates_in_hand
	/// Chance to dismember while unconcious
	var/dismember_chance = 10
	/// Amount of stamina lost on a successful hit
	var/stamina_damage = 20
	/// Chance of doing the throw or stamina damage, along with the flat damage amount
	var/throw_onhit = 50

/mob/living/simple_animal/hostile/gorilla/Initialize()
	. = ..()
	var/datum/action/innate/gorilla/gorilla_toggle/toggle = new
	toggle.Grant(src)
	var/static/default_cache = typecacheof(list(/obj/structure/closet/crate)) // Normal crates only please, no weird sized ones
	carriable_cache = default_cache

/mob/living/simple_animal/hostile/gorilla/Destroy()
	LAZYCLEARLIST(crates_in_hand)
	return ..()

/datum/action/innate/gorilla/gorilla_toggle
	name = "Toggle Stand"
	desc = "Toggles between crawling and standing up."
	icon_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "gorilla_toggle"

/datum/action/innate/gorilla/gorilla_toggle/Activate()
	. = ..()
	var/mob/living/simple_animal/hostile/gorilla/gorilla = owner
	if(!istype(gorilla))
		return

	var/mob/living/simple_animal/hostile/gorilla/cargo_domestic/domesticated = gorilla
	if(istype(domesticated) && LAZYLEN(domesticated.crates_in_hand))
		to_chat(domesticated, "<span class='warning'>You can't get on all fours while carrying something!</span>")
		return

	gorilla.is_bipedal = !gorilla.is_bipedal // Toggle
	gorilla.visible_message("<span class='notice'>[gorilla] [gorilla.is_bipedal ? "stands up menacingly." : "drops back to all fours."]</span>",
		"<span class='notice'>You [gorilla.is_bipedal ? "stand up" : "get down on all fours."]</span>",
		"<span class='notice'>You hear the sound of a gorilla rustling.</span>")

	gorilla.update_icon(UPDATE_ICON_STATE)

// Gorillas like to dismember limbs from unconscious mobs.
/// Returns null when the target is not an unconscious carbon mob; a list of limbs (possibly empty) otherwise.
/mob/living/simple_animal/hostile/gorilla/proc/get_target_bodyparts(atom/hit_target)
	if(!ishuman(hit_target))
		return

	var/mob/living/carbon/human/target = hit_target
	if(target.stat < UNCONSCIOUS)
		return

	var/list/parts = list()
	for(var/obj/item/organ/external/part as anything in target.bodyparts)
		if(istype(part, /obj/item/organ/external/chest) || istype(part, /obj/item/organ/external/head))
			continue // No chest or head removal please
		if(part.limb_flags & CANNOT_DISMEMBER)
			continue // No dismembering of limbs that cannot be dismembered
		parts += part
	return parts

/mob/living/simple_animal/hostile/gorilla/AttackingTarget(atom/attacked_target)
	if(client)
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
			is_bipedal = TRUE
			update_icon(UPDATE_OVERLAYS | UPDATE_ICON_STATE)
			movable_target.forceMove(src)
			return COMPONENT_CANCEL_ATTACK_CHAIN

		if(isturf(target) && !is_blocked_turf(target) && LAZYLEN(crates_in_hand))
			drop_random_crate(target)
			return COMPONENT_CANCEL_ATTACK_CHAIN

	. = ..()
	if(!.)
		return

	if(client)
		oogaooga()

	var/list/parts = get_target_bodyparts(target)
	if(length(parts) && prob(dismember_chance))
		var/obj/item/organ/external/to_dismember = pick(parts)
		to_dismember.droplimb()
		return

	if(isliving(target))
		var/mob/living/living_target = target
		if(prob(throw_onhit))
			living_target.throw_at(get_edge_target_turf(living_target, dir), rand(1, 2), 7, src)
			return

		living_target.adjustStaminaLoss(stamina_damage)
		visible_message("<span class='warning'>[src] knocks [living_target] down!</span>")

/mob/living/simple_animal/hostile/gorilla/update_icon_state()
	. = ..()
	if(is_bipedal || LAZYLEN(crates_in_hand))
		icon_state = "standing"
		return

	icon_state = initial(icon_state)

/mob/living/simple_animal/hostile/gorilla/update_overlays()
	. = ..()
	if(!LAZYLEN(crates_in_hand))
		return
	var/atom/movable/random_crate = pick(crates_in_hand)
	. += mutable_appearance(random_crate.icon, random_crate.icon_state)
	. += mutable_appearance(icon, "standing_overlay")

/mob/living/simple_animal/hostile/gorilla/CanAttack(atom/the_target)
	var/list/parts = get_target_bodyparts(target)
	return ..() && !ismonkeybasic(the_target) && (!parts || length(parts) > 3)

/mob/living/simple_animal/hostile/gorilla/CanSmashTurfs(turf/T)
	return iswallturf(T)

/mob/living/simple_animal/hostile/gorilla/handle_automated_speech(override)
	if(speak_chance && (override || prob(speak_chance)))
		playsound(src, 'sound/creatures/gorilla.ogg', 50)
	return ..()

/mob/living/simple_animal/hostile/gorilla/proc/oogaooga()
	if(prob(rand(15, 50)))
		playsound(src, 'sound/creatures/gorilla.ogg', 50)

/mob/living/simple_animal/hostile/gorilla/special_get_hands_check()
	if(LAZYLEN(crates_in_hand))
		return pick(crates_in_hand)

/mob/living/simple_animal/hostile/gorilla/death(gibbed)
	drop_all_crates(drop_location())
	return ..()

/mob/living/simple_animal/hostile/gorilla/examine(mob/user)
	. = ..()
	var/num_crates = LAZYLEN(crates_in_hand)
	if(num_crates)
		. += "<span class='notice'>[p_theyre(TRUE)] carrying the following:"
		for(var/atom/movable/crate in crates_in_hand)
			. += "[crate]."
		. += "</span>"

/mob/living/simple_animal/hostile/gorilla/drop_item_v()
	drop_random_crate(drop_location())

/// Drops one random crates from our crate list.
/mob/living/simple_animal/hostile/gorilla/proc/drop_random_crate(atom/drop_to)
	var/obj/structure/closet/crate/held_crate = pick(crates_in_hand)
	held_crate.forceMove(drop_to)
	LAZYREMOVE(crates_in_hand, held_crate)
	update_icon(UPDATE_OVERLAYS | UPDATE_ICON_STATE)

/// Drops all the crates in our crate list.
/mob/living/simple_animal/hostile/gorilla/proc/drop_all_crates(atom/drop_to)
	for(var/obj/structure/closet/crate/held_crate as anything in crates_in_hand)
		held_crate.forceMove(drop_to)
		LAZYREMOVE(crates_in_hand, held_crate)
	update_icon(UPDATE_OVERLAYS | UPDATE_ICON_STATE)

/mob/living/simple_animal/hostile/gorilla/cargo_domestic
	name = "cargorilla" // Overriden, normally
	icon = 'icons/mob/cargorillia.dmi'
	desc = "Cargo's pet gorilla. He seems to have an 'I love Mom' tattoo."
	faction = list("neutral", "monkey", "jungle")
	gold_core_spawnable = NO_SPAWN
	gender = MALE
	a_intent = INTENT_HELP
	unique_pet = TRUE
	crate_limit = 2
	/// The ID card that the gorilla is currently wearing.
	var/obj/item/card/id/access_card

/mob/living/simple_animal/hostile/gorilla/cargo_domestic/Login()
	. = ..()
	// Github copilot wrote the below fluff IDK
	to_chat(src, "<span class='boldnotice'>You are [name]. You are a domesticated gorilla, and you are Cargo's pet. You are a loyal and hardworking gorilla, and you love your job. You are a good gorilla, and Cargo loves you.</span>")
	to_chat(src, "<span class='boldnotice'>You can pick up crates by clicking them, and drop them by clicking on an open floor. You can carry [crate_limit] crates at a time.</span>")

/mob/living/simple_animal/hostile/gorilla/cargo_domestic/Initialize(mapload)
	. = ..()
	access_card = new /obj/item/card/id/supply/cargo_gorilla(src)
	ADD_TRAIT(src, TRAIT_PACIFISM, INNATE_TRAIT)

/mob/living/simple_animal/hostile/gorilla/cargo_domestic/Destroy()
	QDEL_NULL(access_card)
	return ..()

/mob/living/simple_animal/hostile/gorilla/cargo_domestic/get_access()
	. = ..()
	. |= access_card.GetAccess()

/obj/item/card/id/supply/cargo_gorilla
	name = "cargorilla ID"
	registered_name = "Cargorilla"
	desc = "A card used to provide ID and determine access across the station. A gorilla-sized ID for a gorilla-sized cargo technician."

/mob/living/simple_animal/hostile/gorilla/rampaging
	name = "Rampaging Gorilla"
	desc = "A gorilla that has gone wild. Run!"
	speed = 0
	color = "#ff0000"
	health = 350
	maxHealth = 350
	melee_damage_lower = 25
	melee_damage_upper = 35
	obj_damage = 40
	damage_coeff = list(BRUTE = 1.25, BURN = 1, TOX = 1.5, CLONE = 0, STAMINA = 0, OXY = 1)
	dismember_chance = 100
	stamina_damage = 40
	throw_onhit = 80

/mob/living/simple_animal/hostile/gorilla/rampaging/Initialize(mapload)
	. = ..()
	add_overlay(mutable_appearance('icons/effects/effects.dmi', "electricity"))  // I wanna be Winston

