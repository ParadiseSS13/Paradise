/**
 * # Spider Charge
 *
 * A unique version of c4 possessed only by the space ninja.  Has a stronger blast radius.
 * Can only be detonated by space ninjas with the bombing objective.  Can only be set up where the objective says it can.
 * When it primes, the space ninja responsible will have their objective set to complete.
 *
 */
/obj/item/grenade/plastic/c4/ninja
	name = "spider charge"
	desc = "A modified C-4 charge supplied to you by the Spider Clan.  Its explosive power has been juiced up, but only works in one specific area."
	icon = 'icons/obj/ninjaobjects.dmi'
	lefthand_file = 'icons/mob/inhands/antag/ninja_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/ninja_righthand.dmi'
	icon_state = "spider_charge0"
	item_state = "spider_charge"
	devastation_range = 4
	heavy_impact_range = 8
	light_impact_range = 12
	///Mob that has planted the charge
	var/mob/living/carbon/human/detonator
	///Reference to the objective that will be completed after da bang!
	var/datum/objective/plant_explosive/detonation_objective

/obj/item/grenade/plastic/c4/ninja/New()
	. = ..()
	image_overlay = image('icons/obj/ninjaobjects.dmi', "[item_state]2")

/obj/item/grenade/plastic/c4/ninja/Destroy()
	detonator = null
	detonation_objective = null
	return ..()

/obj/item/grenade/plastic/c4/ninja/afterattack(atom/movable/AM, mob/ninja, flag)
	if(!isninja(ninja))
		to_chat(ninja, span_notice("While it appears normal, you can't seem to detonate the charge."))
		return
	if(!check_loc(ninja))
		return
	detonator = ninja
	return ..()

/obj/item/grenade/plastic/c4/ninja/prime(mob/living/lanced_by)
	//Since we already did the checks in afterattack, the denonator must be a ninja with the bomb objective.
	if(!detonator || !detonation_objective)
		return
	if(!check_loc(detonator)) // if its moved, deactivate the c4
		var/obj/item/grenade/plastic/c4/ninja/new_c4 = new /obj/item/grenade/plastic/c4/ninja(target.loc)
		new_c4.detonation_objective = detonation_objective
		to_chat(lanced_by, span_warning("Invalid location!"))
		qdel(src)
		return
	detonation_objective.completed = TRUE
	. = ..()

/**
 * check_loc
 *
 * Checks to see if the c4 is in the correct place when being planted.
 *
 * Arguments
 * * mob/user - The planter of the c4
 */
/obj/item/grenade/plastic/c4/ninja/proc/check_loc(mob/user)
	if(!detonation_objective || !detonation_objective.detonation_location)				//Если у нашей бомбы нету цели/зоны, мы попробуем её взять из наших целей
		detonation_objective = locate(/datum/objective/plant_explosive) in user.mind.objectives
		to_chat(user, span_warning("ERROR REQUIRED ZONE NOT FOUND... Reloading... Try again later!"))
		return FALSE
	if((get_area(target) != detonation_objective.detonation_location) && (get_area(src) != detonation_objective.detonation_location))
		if(!active)
			to_chat(user, span_notice("This isn't the location you're supposed to use this!"))
		return FALSE
	return TRUE

/obj/item/grenade/plastic/c4/ninja/examine(mob/user)
	. = ..()
	if(detonation_objective && isninja(user))
		. += "This bomb is location locked, you need to blow it up at: [detonation_objective.detonation_location]"
