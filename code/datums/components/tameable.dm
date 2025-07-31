/// This component lets you make specific mobs tameable by feeding them
/datum/component/tameable
	/// If true, this atom can only be domesticated by one person
	var/unique
	/// Starting success chance for taming.
	var/tame_chance
	/// Added success chance after every failed tame attempt.
	var/bonus_tame_chance
	/// Current chance to tame on interaction
	var/current_tame_chance

/datum/component/tameable/Initialize(food_types, tame_chance, bonus_tame_chance, unique = TRUE)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE

	if(tame_chance)
		src.tame_chance = tame_chance
		src.current_tame_chance = tame_chance
	if(bonus_tame_chance)
		src.bonus_tame_chance = bonus_tame_chance
	src.unique = unique

	if(food_types && !HAS_TRAIT(parent, TRAIT_MOB_EATER))
		parent.AddElement(/datum/element/basic_eating, food_types_ = food_types)

	RegisterSignal(parent, COMSIG_MOB_ATE, PROC_REF(try_tame))

/datum/component/tameable/proc/try_tame(atom/source, obj/item/food, mob/living/attacker)
	SIGNAL_HANDLER

	if(isnull(attacker) || already_friends(attacker))
		return

	var/inform_tamer = FALSE
	if(prob(current_tame_chance)) // note: lack of feedback message is deliberate, keep them guessing unless they're an expert!
		on_tame(source, attacker, food, inform_tamer)
	else
		current_tame_chance += bonus_tame_chance

/// Check if the passed mob is already considered one of our friends
/datum/component/tameable/proc/already_friends(mob/living/potential_friend)
	if(!isliving(parent))
		return FALSE // Figure this out when we actually need it
	var/mob/living/living_parent = parent
	var/living_parent_id = living_parent.UID()
	return living_parent.faction.Find(living_parent_id)

/// Ran once taming succeeds
/datum/component/tameable/proc/on_tame(mob/source, mob/living/tamer, obj/item/food, inform_tamer = FALSE)
	SIGNAL_HANDLER
	source.tamed(tamer, food)//Run custom behavior if needed

	if(isliving(parent) && isliving(tamer))
		INVOKE_ASYNC(source, TYPE_PROC_REF(/mob/living, befriend), tamer)
	if(unique)
		qdel(src)
	else
		current_tame_chance = tame_chance

/datum/component/tameable/proc/rename_pet(mob/living/animal, mob/living/tamer)
	var/chosen_name = tgui_input_text(tamer, "Choose your pet's name!", "Name pet", animal.name, MAX_NAME_LEN)
	if(QDELETED(animal) || chosen_name == animal.name)
		return
	if(!chosen_name)
		to_chat(tamer, "<span class='warning'>Please enter a valid name.</span>")
		rename_pet(animal, tamer)
		return
	animal.rename_character(animal.name, chosen_name)
