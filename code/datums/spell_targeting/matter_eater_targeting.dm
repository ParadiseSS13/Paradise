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
		/mob/living/simple_animal/crab,
		/mob/living/simple_animal/mouse,
		/mob/living/carbon/human,
		/mob/living/simple_animal/slime,
		/mob/living/carbon/alien/larva,
		/mob/living/simple_animal/slime,
		/mob/living/simple_animal/chick,
		/mob/living/simple_animal/chicken,
		/mob/living/simple_animal/lizard,
		/mob/living/simple_animal/cow,
		/mob/living/simple_animal/spiderbot
	)
	var/list/own_blacklist = list(
		/obj/item/organ,
		/obj/item/implant
	)

/datum/spell_targeting/matter_eater/choose_targets(mob/user, obj/effect/proc_holder/spell/spell, params, atom/clicked_atom)
	var/list/possible_targets = list()

	for(var/atom/movable/O in view_or_range(range, user, selection_type))
		if((O in user) && is_type_in_list(O, own_blacklist))
			continue
		if(is_type_in_list(O, types_allowed))
			if(isanimal(O))
				var/mob/living/simple_animal/SA = O
				if(!SA.gold_core_spawnable)
					continue
			possible_targets += O

	var/atom/movable/target = input("Choose the target of your hunger.", "Targeting") as null|anything in possible_targets

	if(QDELETED(target))
		return

	return list(target)
