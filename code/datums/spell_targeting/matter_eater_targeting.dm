/**
 * A spell targeting system especially made for the matter eater gene
 */
/datum/spell_targeting/matter_eater
	range = 1
	var/list/types_allowed = list(
		/obj/item,
		/mob/living/simple_animal/pet,
		/mob/living/simple_animal/hostile,
		/mob/living/simple_animal/parrot,
		/mob/living/basic/crab,
		/mob/living/basic/mouse,
		/mob/living/carbon/human,
		/mob/living/simple_animal/slime,
		/mob/living/carbon/alien/larva,
		/mob/living/simple_animal/slime,
		/mob/living/basic/chick,
		/mob/living/basic/chicken,
		/mob/living/basic/lizard,
		/mob/living/basic/cow,
		/mob/living/basic/spiderbot
	)
	var/list/own_blacklist = list(
		/obj/item/organ,
		/obj/item/bio_chip
	)

/datum/spell_targeting/matter_eater/choose_targets(mob/user, datum/spell/spell, params, atom/clicked_atom)
	var/list/possible_targets = list()

	for(var/atom/movable/O in view_or_range(range, user, selection_type))
		if((O in user) && is_type_in_list(O, own_blacklist))
			continue
		if(O.flags & ABSTRACT)
			continue
		if(is_type_in_list(O, types_allowed))
			if(isanimal(O))
				var/mob/living/simple_animal/SA = O
				if(!SA.gold_core_spawnable)
					continue
			if(isbasicmob(O))
				var/mob/living/basic/B = O
				if(!B.gold_core_spawnable)
					continue
			possible_targets += O

	var/atom/movable/target = tgui_input_list(user, "Choose the target of your hunger", "Targeting", possible_targets)

	if(QDELETED(target))
		return

	return list(target)
