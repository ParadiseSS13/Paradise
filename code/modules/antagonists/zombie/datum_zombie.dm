RESTRICT_TYPE(/datum/antagonist/zombie)

/datum/antagonist/zombie
	name = "Zombie"
	antag_hud_name = "hudzombie"
	antag_hud_type = ANTAG_HUD_ZOMBIE
	special_role = SPECIAL_ROLE_ZOMBIE
	clown_gain_text = "B-Braaaaaains... Honk..."
	clown_removal_text = "You feel funnier again."
	wiki_page_name = "Zombie"
	var/list/old_languages = list() // someone make this better to prevent langs changing if species changes while zombie somehow
	var/static/list/zombie_traits = list(TRAIT_LANGUAGE_LOCKED, TRAIT_GOTTAGOSLOW, TRAIT_ABSTRACT_HANDS, TRAIT_NOBREATH)
	var/datum/unarmed_attack/claws/claw_attack
	var/chosen_disease

// possibly upgrades for the zombies after eating brains? Better vision (/datum/action/changeling/augmented_eyesight), better weapons (armblade), better infection, more inhereint armor (physiology)
// ability to find nearby brains to eat (like cling/vamp ability to track people around them)
/datum/antagonist/zombie/New(chosen_plague)
	chosen_disease = chosen_plague
	..()

/datum/antagonist/zombie/on_gain()
	. = ..()
	if(HAS_TRAIT(owner.current, TRAIT_PLAGUE_ZOMBIE))
		var/datum/spell/zombie_claws/plague_claws/plague_claws = new /datum/spell/zombie_claws/plague_claws
		plague_claws.disease = chosen_disease
		owner.AddSpell(plague_claws)
		owner.AddSpell(new /datum/spell/zombie_leap)
	else
		owner.AddSpell(new /datum/spell/zombie_claws)
	claw_attack = new /datum/unarmed_attack/claws()

/datum/antagonist/zombie/Destroy(force, ...)
	QDEL_NULL(claw_attack)
	return ..()

/datum/antagonist/zombie/detach_from_owner()
	if(HAS_TRAIT(owner, TRAIT_PLAGUE_ZOMBIE))
		owner.RemoveSpell(new /datum/spell/zombie_claws/plague_claws)
		owner.RemoveSpell(new /datum/spell/zombie_leap)
	else
		owner.RemoveSpell(new /datum/spell/zombie_claws)
	return ..()

/datum/antagonist/zombie/add_owner_to_gamemode()
	SSticker.mode.zombies |= owner

/datum/antagonist/zombie/remove_owner_from_gamemode()
	SSticker.mode.zombies -= owner

/datum/antagonist/zombie/greet()
	if(HAS_TRAIT(owner.current, TRAIT_PLAGUE_ZOMBIE)) // we shouldnt get a second welcome message for wiz zombies
		return
	var/list/messages = list()
	. = messages
	if(owner && owner.current)
		messages.Add("<span class='userdanger zombie'>We are a [special_role]!</span>")
		messages.Add("<span class='zombie'>You can feel your heart stopping, but something isn't right... life has not abandoned your broken form. You can only feel a deep and immutable hunger that not even death can stop.</span>")

/datum/antagonist/zombie/finalize_antag()
	if(HAS_TRAIT(owner.current, TRAIT_PLAGUE_ZOMBIE)) // we shouldnt get a second welcome message for wiz zombies
		return
	var/list/messages = list()
	. = messages
	if(owner && owner.current)
		messages.Add("<br><span class='notice'>You can use your claws to break down doors, and to crack open damaged skulls. Once their head is open, use an empty hand to eat their brains. Alternatively, grab someone aggressively and them harm them to bite and infect them. You heal slowly but you heal faster in the dark, after death you will slowly revive and reawaken.</span>")

/datum/antagonist/zombie/apply_innate_effects(mob/living/mob_override)
	var/mob/living/L = ..()

	old_languages = L.languages.Copy()
	for(var/datum/language/lang as anything in L.languages)
		L.remove_language(lang.name)
	L.add_language("Zombie")
	L.default_language = GLOB.all_languages["Zombie"]
	if(!HAS_TRAIT(owner.current, TRAIT_PLAGUE_ZOMBIE))
		L.extinguish_light() // zombies prefer darkness
	for(var/trait in zombie_traits)
		ADD_TRAIT(L, trait, ZOMBIE_TRAIT)
	if(!L.HasDisease(/datum/disease/zombie))
		var/datum/disease/zombie/zomb = new /datum/disease/zombie()
		L.AddDisease(zomb, FALSE, 7)

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.physiology.stamina_mod *= 0.5

/datum/antagonist/zombie/remove_innate_effects(mob/living/mob_override)
	var/mob/living/L = ..()
	if(!ishuman(L))
		STOP_PROCESSING(SSobj, src) // This is to handle when they transfer into a headslug (simple animal). We shouldn't process in that case.
	for(var/trait in zombie_traits)
		REMOVE_TRAIT(L, trait, ZOMBIE_TRAIT)

	L.remove_language("Zombie")
	for(var/datum/language/lang as anything in old_languages)
		L.add_language(lang.name)
	L.default_language = null

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.physiology.stamina_mod /= 0.5

/datum/antagonist/zombie/on_body_transfer(mob/living/old_body, mob/living/new_body)
	if(!new_body.HasDisease(/datum/disease/zombie))
		owner.remove_antag_datum(/datum/antagonist/zombie)
		return
	return ..()

/datum/antagonist/zombie/give_objectives()
	if(HAS_TRAIT(owner.current, TRAIT_PLAGUE_ZOMBIE))
		return
	add_antag_objective(/datum/objective/zombie)

/datum/antagonist/zombie/get_antag_objectives()
	if(HAS_TRAIT(owner.current, TRAIT_PLAGUE_ZOMBIE))
		return
	return ..()

/datum/antagonist/zombie/add_antag_objective()
	if(HAS_TRAIT(owner.current, TRAIT_PLAGUE_ZOMBIE))
		return
	return ..()
