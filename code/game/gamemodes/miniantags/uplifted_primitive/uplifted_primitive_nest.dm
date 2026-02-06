/obj/structure/uplifted_primitive
	icon = 'icons/obj/uplifted_primitive.dmi'
	anchored = TRUE

/obj/structure/uplifted_primitive/nest
	icon_state = "nest"
	desc = "A home for some primitive form of sentient being."

	/// The species of lesser human to spawn.
	var/datum/species/nest_species = /datum/species/monkey

	/// The amount of scrap (recycled materials) currently stored in the nest.
	var/available_scrap = 0

	/// The amount of food currently stored in the nest.
	var/available_food = 0

/obj/structure/uplifted_primitive/nest/Initialize()
	. = ..()
	AddElement(/datum/element/relay_attackers)
	RegisterSignal(src, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(rally_retaliation))

/obj/structure/uplifted_primitive/nest/Destroy()
	UnregisterSignal(src, COMSIG_ATOM_WAS_ATTACKED)
	RemoveElement(/datum/element/relay_attackers)
	return ..()

/obj/structure/uplifted_primitive/nest/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!user.mind || !user.mind.has_antag_datum(/datum/antagonist/uplifted_primitive))
		return NONE

	if(user.a_intent != INTENT_HELP)
		return ITEM_INTERACT_COMPLETE

	if(used.resistance_flags & INDESTRUCTIBLE)
		to_chat(user, SPAN_WARNING("You don't think it's a good idea to put [used] in the nest."))
		return ITEM_INTERACT_COMPLETE

	var/potential_scrap = 0
	var/potential_food = 0
	if(used.materials && length(used.materials) > 0)
		for(var/mat in used.materials)
			potential_scrap += used.materials[mat]

	if(used.reagents)
		for(var/datum/reagent/consumable/C in used.reagents.reagent_list)
			if(nest_species.dietflags & C.diet_flags)
				potential_food += C.nutriment_factor

	if(potential_scrap == 0 && potential_food == 0)
		to_chat(user, SPAN_WARNING("[used] does not seem suitable to disassemble or place in the nest."))
		return ITEM_INTERACT_COMPLETE

	user.visible_message(
		SPAN_WARNING("[user] starts finding a place to put [used] in the nest."),
		SPAN_NOTICE("You start finding a place to put [used] in the nest.")
	)

	if(!do_after(user, 1 SECONDS, target = src))
		return ITEM_INTERACT_COMPLETE

	if(potential_scrap > 0)
		to_chat(user, SPAN_NOTICE("You dismantle [used] and place the scrap around the nest."))
		available_scrap += potential_scrap

	if(potential_food > 0)
		to_chat(user, SPAN_NOTICE("You place the edible parts of [used] in the nest."))
		available_food += potential_food

	qdel(used)

	return ITEM_INTERACT_COMPLETE

/obj/structure/uplifted_primitive/nest/proc/rally_retaliation(mob/living/attacker)
	SIGNAL_HANDLER
	if(!istype(attacker))
		return
	for(var/mob/living/carbon/human/monkey/defender in oview(src, 7))
		if(defender.dna.species != nest_species) // Not your nest so who cares
			continue
		if(defender == attacker) // Do not commit suicide attacking yourself
			continue

		var/datum/ai_controller/monkey/M = defender.ai_controller
		if(istype(M))
			M.retaliate(attacker)

