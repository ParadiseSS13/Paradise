// goat
/mob/living/basic/goat
	name = "goat"
	desc = "Not known for their pleasant disposition."
	icon_state = "goat"
	icon_living = "goat"
	icon_dead = "goat_dead"
	see_in_dark = 6
	butcher_results = list(/obj/item/food/meat = 4)

	speak_emote = list("brays")
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "kicks"
	attack_verb_simple = "kick"

	faction = list("neutral", "jungle")
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	health = 40
	maxHealth = 40
	melee_damage_lower = 1
	melee_damage_upper = 2
	blood_volume = BLOOD_VOLUME_NORMAL
	gender = FEMALE
	step_type = FOOTSTEP_MOB_SHOE
	ai_controller = /datum/ai_controller/basic_controller/goat
	/// What can the goat eat?
	var/static/list/edibles = list(
		/obj/structure/glowshroom,
		/obj/structure/spacevine,
	)
	/// The goat's udder
	var/obj/item/udder/cow/udder

/mob/living/basic/goat/Initialize(mapload)
	. = ..()
	udder = new()
	AddElement(/datum/element/wears_collar)
	AddElement(/datum/element/ai_retaliate)
	ai_controller.set_blackboard_key(BB_BASIC_FOODS, typecacheof(edibles))

	RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(on_pre_attack))
	RegisterSignal(src, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_move))

/mob/living/basic/goat/Destroy()
	QDEL_NULL(udder)
	return ..()

/mob/living/basic/goat/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(. && isdiona(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/NB = pick(H.bodyparts)
		H.visible_message("<span class='warning'>[src] takes a big chomp out of [H]!</span>", "<span class='userdanger'>[src] takes a big chomp out of your [NB.name]!</span>")
		NB.droplimb()

/mob/living/basic/goat/proc/on_pre_attack(datum/source, atom/target)
	SIGNAL_HANDLER // COMSIG_HOSTILE_PRE_ATTACKINGTARGET
	if(is_type_in_list(target, edibles))
		eat_plant(list(target))
		return COMPONENT_HOSTILE_NO_ATTACK

/mob/living/basic/goat/proc/on_move(datum/source, atom/entering_loc)
	SIGNAL_HANDLER // COMSIG_MOVABLE_PRE_MOVE
	if(!isturf(entering_loc) || stat == DEAD)
		return

	var/list/edible_plants = list()
	for(var/obj/target in entering_loc)
		if(is_type_in_list(target, edibles))
			edible_plants += target

	INVOKE_ASYNC(src, PROC_REF(eat_plant), edible_plants)

/mob/living/basic/goat/Life(seconds, times_fired)
	. = ..()
	if(stat == CONSCIOUS)
		udder.generateMilk()

/mob/living/basic/goat/item_interaction(mob/living/user, obj/item/O, list/modifiers)
	if(stat == CONSCIOUS && istype(O, /obj/item/reagent_containers/glass))
		udder.milkAnimal(O, user)
		return ITEM_INTERACT_COMPLETE

/mob/living/basic/goat/proc/eat_plant(list/plants)
	var/eaten = FALSE

	for(var/atom/target as anything in plants)
		if(istype(target, /obj/structure/spacevine))
			var/obj/structure/spacevine/vine = target
			vine.eat(src)
			eaten = TRUE

		if(istype(target, /obj/structure/glowshroom))
			qdel(target)
			eaten = TRUE

	if(eaten && prob(10))
		say("Nom") // bon appetit
		playsound(src, 'sound/items/eatfood.ogg', rand(30, 50), TRUE)

/mob/living/basic/goat/chef
	name = "Pete"
	desc = "Pete, the Chef's pet goat from the Caribbean. Not known for their pleasant disposition."

/// Goats are normally content to sorta hang around and crunch any plant in sight, but they will go ape on someone who attacks them.
/datum/ai_controller/basic_controller/goat
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	ai_traits = AI_FLAG_STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/capricious_retaliate, // Capricious like Capra, get it?
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/goat,
	)

/datum/ai_planning_subtree/random_speech/goat
	speech_chance = 3
	emote_hear = list("brays.")
	emote_see = list("shakes their head.", "stamps a foot.", "glares around.")
	speak = list("EHEHEHEHEH", "eh?")
