// Sidepaths for knowledge between Void and Blade.

/datum/heretic_knowledge_tree_column/void_to_blade
	neighbour_type_left = /datum/heretic_knowledge_tree_column/main/void
	neighbour_type_right = /datum/heretic_knowledge_tree_column/main/blade

	route = PATH_SIDE

	tier1 = /datum/heretic_knowledge/limited_amount/risen_corpse
	tier2 = /datum/heretic_knowledge/rune_carver
	tier3 = /datum/heretic_knowledge/summon/maid_in_mirror



/// The max health given to Shattered Risen
#define RISEN_MAX_HEALTH 125

/datum/heretic_knowledge/limited_amount/risen_corpse
	name = "Shattered Ritual"
	desc = "Allows you to transmute a corpse with a soul, a pair of latex or nitrile gloves, and \
		and any exosuit clothing (such as armor) to create a Shattered Risen. \
		Shattered Risen are strong ghouls that have 125 health, but cannot hold items, \
		instead having two brutal weapons for hands. You can only create one at a time."
	gain_text = "I witnessed a cold, rending force drag this corpse back to near-life. \
		When it moves, it crunches like broken glass. Its hands are no longer recognizable as human - \
		each clenched fist contains a brutal nest of sharp bone-shards instead."

	required_atoms = list(
		/obj/item/clothing/suit = 1,
		/obj/item/clothing/gloves/color/latex = 1,
	)
	cost = 1

	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "ghoul_shattered"


/datum/heretic_knowledge/limited_amount/risen_corpse/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/our_turf)
	. = ..()
	if(!.)
		return FALSE

	var/datum/antagonist/heretic/howetic = IS_HERETIC(user)
	for(var/uid_finder as anything in howetic.list_of_our_monsters)
		var/atom/real_thing = locateUID(uid_finder)
		if(QDELETED(real_thing))
			LAZYREMOVE(howetic.list_of_our_monsters, uid_finder)
	if(LAZYLEN(howetic.list_of_our_monsters) >= howetic.monster_limit)
		to_chat(user, SPAN_HIEROPHANT("The ritual failed, you are at your limit of [howetic.monster_limit] monsters!"))
		return FALSE

	for(var/mob/living/carbon/human/body in atoms)
		if(body.stat != DEAD)
			continue
		if(!IS_VALID_GHOUL_MOB(body) || HAS_TRAIT(body, TRAIT_HUSK))
			to_chat(user, SPAN_HIEROPHANT_WARNING("[body] is not in a valid state to be made into a ghoul."))
			continue
		if(!body.mind)
			to_chat(user, SPAN_HIEROPHANT_WARNING("[body] is mindless and cannot be made into a ghoul."))
			continue
		if(!body.client && !body.mind.get_ghost())
			to_chat(user, SPAN_HIEROPHANT_WARNING("[body] is soulless and cannot be made into a ghoul."))
			continue

		// We will only accept valid bodies with a mind, or with a ghost connected that used to control the body
		selected_atoms += body
		return TRUE

	to_chat(user, SPAN_HIEROPHANT_WARNING("The ritual has failed, there is no valid body."))
	return FALSE

/datum/heretic_knowledge/limited_amount/risen_corpse/on_finished_recipe(mob/living/user, list/selected_atoms, turf/our_turf)
	var/mob/living/carbon/human/soon_to_be_ghoul = locate() in selected_atoms
	if(QDELETED(soon_to_be_ghoul)) // No body? No ritual
		stack_trace("[type] reached on_finished_recipe without a human in selected_atoms to make a ghoul out of.")
		to_chat(user, SPAN_HIEROPHANT_WARNING("The ritual has failed, there is no valid body."))
		return FALSE

	soon_to_be_ghoul.grab_ghost()
	if(!soon_to_be_ghoul.mind || !soon_to_be_ghoul.client)
		stack_trace("[type] reached on_finished_recipe without a minded / cliented human in selected_atoms to make a ghoul out of.")
		to_chat(user, SPAN_HIEROPHANT_WARNING("The ritual has failed, there is no valid body."))
		return FALSE

	selected_atoms -= soon_to_be_ghoul
	make_risen(user, soon_to_be_ghoul)
	return TRUE

/// Make [victim] into a shattered risen ghoul.
/datum/heretic_knowledge/limited_amount/risen_corpse/proc/make_risen(mob/living/user, mob/living/carbon/human/victim)
	message_admins("[ADMIN_LOOKUPFLW(user)] created a shattered risen, [ADMIN_LOOKUPFLW(victim)].")

	victim.apply_status_effect(
		/datum/status_effect/ghoul,
		RISEN_MAX_HEALTH,
		user.mind,
		CALLBACK(src, PROC_REF(apply_to_risen)),
		CALLBACK(src, PROC_REF(remove_from_risen)),
	)
	var/datum/antagonist/heretic/whoetic = IS_HERETIC(user)
	LAZYADD(whoetic.list_of_our_monsters,victim.UID())

/// Callback for the ghoul status effect - what effects are applied to the ghoul.
/datum/heretic_knowledge/limited_amount/risen_corpse/proc/apply_to_risen(mob/living/risen)
	LAZYADD(created_items, risen.UID())
	risen.put_in_active_hand(new/obj/item/shattered_risen)

/// Callback for the ghoul status effect - cleaning up effects after the ghoul status is removed.
/datum/heretic_knowledge/limited_amount/risen_corpse/proc/remove_from_risen(mob/living/risen)
	LAZYREMOVE(created_items, risen.UID())
	for(var/obj/item/shattered_risen/bone_shards in risen)
		qdel(bone_shards)

#undef RISEN_MAX_HEALTH

/// The "hand" "weapon" used by shattered risen
/obj/item/shattered_risen
	name = "bone-shards"
	desc = "What once appeared to be a normal human fist, now holds a maulled nest of sharp bone-shards."
	icon = 'icons/effects/vampire_effects.dmi'
	icon_state = "vamp_claws"
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	flags = ABSTRACT | NODROP | DROPDEL
	color = "#001aff"
	hitsound = "shatter"
	force = 16
	sharp = TRUE

/obj/item/shattered_risen/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)

/datum/heretic_knowledge/rune_carver
	name = "Carving Knife"
	desc = "Allows you to transmute a knife, a shard of glass, and a piece of paper to create a Carving Knife. \
		The Carving Knife allows you to etch difficult to see traps that trigger on heathens who walk overhead. \
		Also makes for a handy throwing weapon."
	gain_text = "Etched, carved... eternal. There is power hidden in everything. I can unveil it! \
		I can carve the monolith to reveal the chains!"

	required_atoms = list(
		/obj/item/kitchen/knife = 1,
		/obj/item/shard = 1,
		/obj/item/paper = 1,
	)
	result_atoms = list(/obj/item/melee/rune_carver)
	cost = 1


	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "rune_carver"

/datum/heretic_knowledge/summon/maid_in_mirror
	name = "Maid in the Mirror"
	desc = "Allows you to transmute five sheets of titanium, a flash, a suit of armor, and a pair of lungs \
		to create a Maid in the Mirror. Maid in the Mirrors are decent combatants that can become incorporeal by \
		phasing in and out of the mirror realm, serving as powerful scouts and ambushers. \
		However, they are weak to mortal gaze and take damage by being examined."
	gain_text = "Within each reflection, lies a gateway into an unimaginable world of colors never seen and \
		people never met. The ascent is glass, and the walls are knives. Each step is blood, if you do not have a guide."

	required_atoms = list(
		/obj/item/stack/sheet/mineral/titanium = 5,
		/obj/item/clothing/suit/armor = 1,
		/obj/item/flash = 1,
		/obj/item/organ/internal/lungs = 1,
	)
	cost = 1

	mob_to_summon = /mob/living/basic/heretic_summon/maid_in_the_mirror

