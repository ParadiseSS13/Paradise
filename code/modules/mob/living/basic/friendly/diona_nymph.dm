/*
 * Tiny babby plant critter plus procs.
 */

//Mob defines.
#define GESTALT_ALERT "gestalt screen alert"
#define NYMPH_ALERT "nymph screen alert"

/mob/living/basic/diona_nymph
	name = "diona nymph"
	icon = 'icons/mob/monkey.dmi'
	icon_state = "nymph"
	icon_living = "nymph"
	icon_dead = "nymph_dead"
	icon_resting = "nymph_sleep"
	pass_flags = PASSTABLE | PASSMOB
	mob_biotypes = MOB_ORGANIC | MOB_PLANT
	mob_size = MOB_SIZE_SMALL
	ventcrawler = VENTCRAWLER_ALWAYS
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0

	maxHealth = 50
	health = 50

	voice_name = "diona nymph"
	speak_emote = list("chirrups")

	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "pushes"
	response_disarm_simple = "push"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"

	melee_damage_lower = 5
	melee_damage_upper = 8
	melee_attack_cooldown_min = 1.5 SECONDS
	melee_attack_cooldown_max = 2.5 SECONDS
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/weapons/bite.ogg'

	ai_controller = /datum/ai_controller/basic_controller/diona_nymph

	var/list/donors = list()
	holder_type = /obj/item/holder/diona

	/// Amount of blood donors needed to evolve
	var/evolve_donors = 5
	/// Amount of blood donors needed for understand language
	var/awareness_donors = 3
	/// Amount of nutrition needed before evolving
	var/nutrition_need = 500
	/// List of stuff (mice) that we want to eat
	var/static/list/edibles = list(
		/obj/item/food/grown,
	)

	var/datum/action/innate/diona_nymph/merge/merge_action = new()
	var/datum/action/innate/diona_nymph/evolve/evolve_action = new()
	var/datum/action/innate/diona_nymph/steal_blood/steal_blood_action = new()

/mob/living/basic/diona_nymph/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/wears_collar)
	if(name == initial(name)) // To stop named dionas becoming generic.
		name = "[name] ([rand(1, 1000)])"
		real_name = name
	add_language("Rootspeak")
	merge_action.Grant(src)
	evolve_action.Grant(src)
	steal_blood_action.Grant(src)
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/basic_eating, heal_amt_ = 2, food_types_ = edibles)
	RegisterSignal(src, COMSIG_MOB_PRE_EAT, PROC_REF(check_full))
	RegisterSignal(src, COMSIG_MOB_ATE, PROC_REF(consume))
	ai_controller.set_blackboard_key(BB_BASIC_FOODS, typecacheof(edibles))

/datum/action/innate/diona_nymph/merge
	name = "Merge with gestalt"
	button_icon = 'icons/mob/human_races/r_diona.dmi'
	button_icon_state = "preview"

/datum/action/innate/diona_nymph/merge/Activate()
	var/mob/living/basic/diona_nymph/user = owner
	user.merge()

/datum/action/innate/diona_nymph/evolve
	name = "Evolve"
	button_icon = 'icons/obj/cloning.dmi'
	button_icon_state = "pod_cloning"

/datum/action/innate/diona_nymph/evolve/Activate()
	var/mob/living/basic/diona_nymph/user = owner
	user.evolve()

/datum/action/innate/diona_nymph/steal_blood
	name = "Steal blood"
	button_icon = 'icons/goonstation/objects/iv.dmi'
	button_icon_state = "bloodbag"

/datum/action/innate/diona_nymph/steal_blood/Activate()
	var/mob/living/basic/diona_nymph/user = owner
	user.steal_blood()

/mob/living/basic/diona_nymph/UnarmedAttack(atom/A)
	// Can't attack your gestalt
	if(isdiona(A) && (src in A.contents))
		visible_message("[src] wiggles around a bit.")
	else
		..()

/mob/living/basic/diona_nymph/run_resist()
	if(!split())
		..()

/mob/living/basic/diona_nymph/attack_hand(mob/living/carbon/human/M)
	// Let people pick the little buggers up.
	if(M.a_intent == INTENT_HELP)
		if(isdiona(M))
			to_chat(M, "You feel your being twine with that of [src] as it merges with your biomass.")
			to_chat(src, "You feel your being twine with that of [M] as you merge with its biomass.")
			// adds a screen alert that can call resist
			throw_alert(GESTALT_ALERT, /atom/movable/screen/alert/nymph, new_master = src)
			M.throw_alert(NYMPH_ALERT, /atom/movable/screen/alert/gestalt, new_master = src)
			forceMove(M)
		else if(isrobot(M))
			M.visible_message("<span class='notice'>[M] playfully boops [src] on the head!</span>", "<span class='notice'>You playfully boop [src] on the head!</span>")
		else
			get_scooped(M)
	else
		..()

/mob/living/basic/diona_nymph/proc/merge()
	if(stat != CONSCIOUS)
		return FALSE

	var/list/choices = list()
	for(var/mob/living/carbon/human/H in view(1,src))
		if(!(Adjacent(H)) || !isdiona(H))
			continue
		choices += H

	if(!length(choices))
		to_chat(src, "<span class='warning'>No suitable diona nearby.</span>")
		return FALSE

	var/mob/living/M = tgui_input_list(src, "Who do you wish to merge with?", "Nymph Merging", choices)

	// input can take a while, so re-validate
	if(!M || !src || !(Adjacent(M)) || stat != CONSCIOUS)
		return FALSE

	if(isdiona(M))
		to_chat(M, "You feel your being twine with that of [src] as it merges with your biomass.")
		M.status_flags |= PASSEMOTES
		to_chat(src, "You feel your being twine with that of [M] as you merge with its biomass.")
		forceMove(M)
		// adds a screen alert that can call resist
		throw_alert(GESTALT_ALERT, /atom/movable/screen/alert/nymph, new_master = src)
		M.throw_alert(NYMPH_ALERT, /atom/movable/screen/alert/gestalt, new_master = src)
		return TRUE
	else
		return FALSE

/mob/living/basic/diona_nymph/proc/split(forced = FALSE)
	if((stat != CONSCIOUS && !forced) || !isdiona(loc))
		return FALSE
	var/mob/living/carbon/human/D = loc
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE
	to_chat(loc, "You feel a pang of loss as [src] splits away from your biomass.")
	to_chat(src, "You wiggle out of the depths of [loc]'s biomass and plop to the ground.")
	forceMove(T)

	var/hasMobs = FALSE
	for(var/atom/A in D.contents)
		if(ismob(A) || istype(A, /obj/item/holder))
			hasMobs = TRUE
	if(!hasMobs)
		D.status_flags &= ~PASSEMOTES
		D.clear_alert(NYMPH_ALERT)

	clear_alert(GESTALT_ALERT)
	return TRUE

/mob/living/basic/diona_nymph/proc/evolve()
	if(stat != CONSCIOUS)
		return FALSE

	if(length(donors) < evolve_donors)
		to_chat(src, "<span class='warning'>You need more blood in order to ascend to a new state of consciousness...</span>")
		return FALSE

	if(nutrition < nutrition_need)
		to_chat(src, "<span class='warning'>You need to binge on weeds in order to have the energy to grow...</span>")
		return FALSE

	if(isdiona(loc) && !split()) // if it's merged with diona, needs to able to split before evolving
		return FALSE

	visible_message("<span class='danger'>[src] begins to shift and quiver, and erupts in a shower of shed bark as it splits into a tangle of nearly a dozen new dionaea.</span>","<span class='danger'>You begin to shift and quiver, feeling your awareness splinter. All at once, we consume our stored nutrients to surge with growth, splitting into a tangle of at least a dozen new dionaea. We have attained our gestalt form.</span>")

	if(master_commander)
		to_chat(src, "<span class='userdanger'>As you evolve, your mind grows out of it's restraints. You are no longer loyal to [master_commander]!</span>")

	var/mob/living/carbon/human/diona/adult = new(get_turf(loc))
	adult.set_species(/datum/species/diona)

	if(istype(loc, /obj/item/holder/diona))
		var/obj/item/holder/diona/L = loc
		forceMove(L.loc)
		qdel(L)

	for(var/datum/language/L in languages)
		adult.add_language(L.name)
	adult.regenerate_icons()

	adult.name = "diona ([rand(100,999)])"
	adult.real_name = adult.name
	adult.ckey = ckey
	adult.real_name = adult.dna.species.get_random_name()	// I hate this being here of all places but unfortunately dna is based on real_name!
	// [Nymph -> Diona] is from xenobio (or botany) and does not give vampires usuble blood and cannot be converted by cult.
	ADD_TRAIT(adult.mind, TRAIT_XENOBIO_SPAWNED_HUMAN, ROUNDSTART_TRAIT)

	for(var/obj/item/W in contents)
		drop_item_to_ground(W)

	qdel(src)
	return TRUE

/mob/living/basic/diona_nymph/proc/check_full(datum/source, obj/item/potential_food)
	SIGNAL_HANDLER // COMSIG_MOB_PRE_EAT
	if(nutrition >= nutrition_need) // Prevents griefing by overeating food items without evolving.
		to_chat(src, "<span class='warning'>You're too full to consume this! Perhaps it's time to grow bigger...</span>")
		return COMSIG_MOB_TERMINATE_EAT

// Consumes plant matter other than weeds to evolve
/mob/living/basic/diona_nymph/proc/consume(datum/source, obj/item/potential_food)
	SIGNAL_HANDLER // COMSIG_MOB_ATE
	if(potential_food.reagents.get_reagent_amount("nutriment") + potential_food.reagents.get_reagent_amount("plantmatter") < 1)
		adjust_nutrition(2)
	else
		adjust_nutrition((potential_food.reagents.get_reagent_amount("nutriment") + potential_food.reagents.get_reagent_amount("plantmatter")) * 2)

/mob/living/basic/diona_nymph/proc/steal_blood()
	if(stat != CONSCIOUS)
		return FALSE

	var/list/choices = list()
	for(var/mob/living/carbon/human/H in oview(1,src))
		if(Adjacent(H) && H.dna && !(NO_BLOOD in H.dna.species.species_traits))
			choices += H

	if(!length(choices))
		to_chat(src, "<span class='warning'>No suitable blood donors nearby.</span>")
		return FALSE

	var/mob/living/carbon/human/M = tgui_input_list(src, "Who do you wish to take a sample from?", "Blood Sampling", choices)

	if(!M || !src || !(Adjacent(M)) || stat != CONSCIOUS) //input can take a while, so re-validate
		return FALSE

	if(!M.dna || (NO_BLOOD in M.dna.species.species_traits))
		to_chat(src, "<span class='warning'>That donor has no blood to take.</span>")
		return FALSE

	if(donors.Find(M.real_name))
		to_chat(src, "<span class='warning'>That donor offers you nothing new.</span>")
		return FALSE

	visible_message("<span class='danger'>[src] flicks out a feeler and neatly steals a sample of [M]'s blood.</span>","<span class='danger'>You flick out a feeler and neatly steal a sample of [M]'s blood.</span>")
	donors += M.real_name
	for(var/datum/language/L in M.languages)
		if(!(L.flags & HIVEMIND))
			languages |= L

	spawn(25)
		update_progression()

/mob/living/basic/diona_nymph/proc/update_progression()
	if(stat != CONSCIOUS || !length(donors))
		return FALSE

	if(length(donors) == evolve_donors)
		to_chat(src, "<span class='noticealien'>You feel ready to move on to your next stage of growth.</span>")
	else if(length(donors) == awareness_donors)
		universal_understand = TRUE
		to_chat(src, "<span class='noticealien'>You feel your awareness expand, and realize you know how to understand the creatures around you.</span>")
	else
		to_chat(src, "<span class='noticealien'>The blood seeps into your small form, and you draw out the echoes of memories and personality from it, working them into your budding mind.</span>")


/mob/living/basic/diona_nymph/put_in_hands(obj/item/W)
	W.forceMove(get_turf(src))
	W.layer = initial(W.layer)
	W.plane = initial(W.plane)
	W.dropped()

/mob/living/basic/diona_nymph/put_in_active_hand(obj/item/W)
	to_chat(src, "<span class='warning'>You don't have any hands!</span>")
	return

/mob/living/basic/diona_nymph/valid_respawn_target_for(mob/user)
	if(!jobban_isbanned(user, ROLE_NYMPH))
		return TRUE
	return FALSE

/// Diona nymphs want to eat plant matter to get to evolution stage, but won't evolve or sample blood on their own. They flee when attacked.
/datum/ai_controller/basic_controller/diona_nymph
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	ai_traits = AI_FLAG_STOP_MOVING_WHEN_PULLED | AI_FLAG_PAUSE_DURING_DO_AFTER
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/find_food/diona_nymph,
		/datum/ai_planning_subtree/random_speech/diona_nymph,
	)

/datum/ai_planning_subtree/find_food/diona_nymph

/datum/ai_planning_subtree/find_food/diona_nymph/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/basic/diona_nymph/nymph = controller.pawn
	if(nymph.nutrition >= nymph.nutrition_need)
		// Put eating on cooldown so it doesn't keep trying to eat.
		var/food_cooldown = controller.blackboard[BB_EAT_FOOD_COOLDOWN] || EAT_FOOD_COOLDOWN
		controller.set_blackboard_key(BB_NEXT_FOOD_EAT, world.time + food_cooldown)
		return SUBTREE_RETURN_FINISH_PLANNING
	return ..()

/datum/ai_planning_subtree/random_speech/diona_nymph
	speech_chance = 5
	emote_hear = list("chirrups.")
	emote_see = list("chirrups.")

#undef GESTALT_ALERT
#undef NYMPH_ALERT
