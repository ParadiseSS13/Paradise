#define MURGHAL_BOOST_HUNGERCOST 5
#define MURGHAL_BOOST_STAMINACOST 6
#define MURGHAL_BOOST_MINHUNGER 150
#define MURGHAL_BOOST_MINSTAMINA 60

/obj/item/organ/internal/heart/murghal
	name = "murghal heart"
	icon = 'icons/hispania/obj/species_organs/murghal.dmi'

/obj/item/organ/internal/adrenal/murghal
	name = "adrenaline gland"
	desc = "Specialized gland that convert nutriment into adrenaline directly into the bloodstream."
	icon = 'icons/hispania/obj/species_organs/murghal.dmi'
	icon_state = "adrenal_gland"
	origin_tech = "biotech=2"
	w_class = WEIGHT_CLASS_TINY
	parent_organ = "groin"
	slot = "gland"
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	var/sprint = FALSE
	var/chaser_timer = 0
	var/chaser_cooldown = 1200
	var/footstep = 0  // Esto es una chapuzeria, cambiar para la v2

/obj/item/organ/internal/adrenal/murghal/proc/on_species_walk(var/turf/NewLoc, var/dir)

	if(sprint)

		if(owner.nutrition < MURGHAL_BOOST_MINHUNGER || owner.getStaminaLoss() > MURGHAL_BOOST_MINSTAMINA)
			toggle_boost(TRUE)
			to_chat(owner, "<span class='warning'>You are too tired to sprint!</span>")

		if(newCollision(NewLoc, dir))
			impact()

		if(owner.step_count % 2)
			playsound(NewLoc, 'sound/hispania/effects/footsteps/sprint_murghal0.ogg', 35, 1, -(world.view - 2))
		else
			playsound(NewLoc, 'sound/hispania/effects/footsteps/sprint_murghal1.ogg', 35, 1, -(world.view - 2))

		if(footstep > 40)
			legs_pain()

		if(owner.get_int_organ(/obj/item/organ/internal/heart/murghal))
			if(prob(0.3))
				heart_attack()
		else
			if(prob(0.8))
				heart_attack()

		footstep += 1

		owner.staminaloss += MURGHAL_BOOST_STAMINACOST * 0.4
		owner.nutrition -= MURGHAL_BOOST_HUNGERCOST * 0.4
	return

/obj/item/organ/internal/adrenal/murghal/on_life()
	if(footstep > 0)
		footstep -= 1

/obj/item/organ/internal/adrenal/murghal/ui_action_click()
	if(toggle_boost())
		if(sprint)
			owner.visible_message("<span class='notice'>[owner] crouches a little!</span>", "<span class='notice'>You get ready to sprint.</span>")
		else
			owner.visible_message("<span class='ntice'>[owner] assumes a normal standing position.</span>", "<span class='notice'>You relax your muscles.</span>")

/obj/item/organ/internal/adrenal/murghal/on_owner_death()
	if(sprint)
		toggle_boost(TRUE)

/obj/item/organ/internal/adrenal/murghal/proc/legs_pain()
	var/obj/item/organ/external/l_leg = owner.get_organ("l_leg")
	var/obj/item/organ/external/r_leg = owner.get_organ("r_leg")

	if(r_leg.receive_damage(3, 0) && l_leg.receive_damage(3, 0))
		owner.UpdateDamageIcon()

	return

/obj/item/organ/internal/adrenal/murghal/proc/impact()
	playsound(owner.loc, 'sound/effects/bang.ogg', 25, 1)

	if(!istype(owner.head, /obj/item/clothing/head/helmet))
		toggle_boost(TRUE)
		var/obj/item/organ/external/affecting = owner.get_organ("head")
		owner.Stun(5)
		owner.Weaken(5)
		if(affecting.receive_damage(10, 0))
			owner.UpdateDamageIcon()

	return

/obj/item/organ/internal/adrenal/murghal/proc/heart_attack()
	to_chat(owner, "<span class='warning'>Your heart lurches awkwardly!</span>")
	owner.ForceContractDisease(new /datum/disease/critical/heart_failure(0))

/obj/item/organ/internal/adrenal/murghal/proc/toggle_boost(statoverride)
	if(!statoverride && (owner.incapacitated(TRUE) || owner.lying || owner.buckled))
		to_chat(owner, "<span class='warning'>You cannot sprint in your current state.</span>")
		return FALSE

	if(!statoverride && owner.nutrition < MURGHAL_BOOST_MINHUNGER)
		to_chat(owner, "<span class='warning'>You are too tired to sprint, eat something!</span>")
		return FALSE

	// Odio este bloque de codigo, si llega alguien con una mejor idea que por favor proceda a borrarlo.
	if(!sprint)
		if(chaser_timer <= world.time || footstep <= 0)
			chaser_timer = world.time + chaser_cooldown
			owner.status_flags |= GOTTAGOFAST
			sprint = TRUE
			return TRUE
		else
			to_chat(owner, "<span class='warning'>You are still exhausted from the last sprint, you will need to wait a bit longer!</span>")
			return FALSE
	else
		owner.status_flags &= ~GOTTAGOFAST
		sprint = FALSE
		return TRUE

/*
if(!sprint)
			if(chaser_timer <= world.time)
				chaser_timer = world.time + chaser_cooldown
				owner.status_flags |= GOTTAGOFAST
				sprint = TRUE
				return TRUE
			else
				to_chat(owner, "<span class='warning'>You are still exhausted from the last sprint, you will need to wait a bit longer!</span>")
				return FALSE

		return TRUE /// Capaz hay que borrar

	else
		owner.status_flags &= ~GOTTAGOFAST
		sprint = FALSE
		return TRUE
*/

/obj/item/organ/internal/adrenal/murghal/proc/newCollision(turf/loc,var/dir)
	if(loc.density)
		return TRUE

	/* // Hacer que se choque con todo lo que tenga densidad como mesas, maquinas, etc.
	for(var/i in loc)
		var/atom/A = i
		if(A.density && !ismob(A))
			return TRUE
	*/

	for(var/obj/structure/window/D in loc)
		if(!D.density)
			continue
		if(D.fulltile)
			return TRUE
		if(D.dir == dir)
			return TRUE

	for(var/obj/machinery/door/D in loc)
		if(!D.density)//if the door is open
			continue
		else return TRUE	// if closed, it's a real, air blocking door

	return FALSE

#undef MURGHAL_BOOST_HUNGERCOST
#undef MURGHAL_BOOST_MINHUNGER
#undef MURGHAL_BOOST_STAMINACOST
#undef MURGHAL_BOOST_MINSTAMINA
