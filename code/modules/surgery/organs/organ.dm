/obj/item/organ
	name = "organ"
	icon = 'icons/obj/surgery.dmi'
	var/dead_icon
	var/mob/living/carbon/human/owner = null
	var/status = 0
	var/vital = FALSE //Lose a vital limb, die immediately.
	var/damage = 0 // amount of damage to the organ

	var/min_bruised_damage = 10
	var/min_broken_damage = 30
	var/max_damage
	var/organ_tag = "organ"

	var/parent_organ = "chest"

	var/list/datum/autopsy_data/autopsy_data = list()
	var/list/trace_chemicals = list()	// traces of chemicals in the organ,
										// links chemical IDs to number of ticks for which they'll stay in the blood
	germ_level = 0
	var/datum/dna/dna

	// Stuff for tracking if this is on a tile with an open freezer or not
	var/last_freezer_update_time = 0
	var/freezer_update_period = 100
	var/is_in_freezer = 0

	var/sterile = FALSE //can the organ be infected by germs?
	var/tough = FALSE //can organ be easily damaged?
	var/emp_proof = FALSE //is the organ immune to EMPs?
	var/hidden_pain = FALSE //will it skip pain messages?
	var/requires_robotic_bodypart = FALSE

	///Should this organ be destroyed on removal?
	var/destroy_on_removal = FALSE

	/// What was the last pain message that was sent?
	var/last_pain_message
	/// When can we get the next pain message?
	var/next_pain_time

/obj/item/organ/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(owner)
		remove(owner, TRUE)
	QDEL_LIST_ASSOC_VAL(autopsy_data)
	QDEL_NULL(dna)
	return ..()

/obj/item/organ/proc/update_health()
	return

/obj/item/organ/New(mob/living/carbon/holder, datum/species/species_override = null)
	..(holder)
	if(!max_damage)
		max_damage = min_broken_damage * 2
	if(istype(holder))
		if(holder.dna)
			dna = holder.dna.Clone()
		else
			stack_trace("[holder] spawned without a proper DNA.")
		var/mob/living/carbon/human/H = holder
		if(istype(H))
			if(dna)
				if(!blood_DNA)
					blood_DNA = list()
				blood_DNA[dna.unique_enzymes] = dna.blood_type
	else
		dna = new /datum/dna(null)
		if(species_override)
			dna.species = new species_override

/obj/item/organ/attackby(obj/item/I, mob/user, params)
	if(is_robotic() && istype(I, /obj/item/stack/nanopaste))
		var/obj/item/stack/nanopaste/nano = I
		nano.use(1)
		rejuvenate()
		to_chat(user, "<span class='notice'>You repair the damage on [src].</span>")
		return
	return ..()

/obj/item/organ/proc/set_dna(datum/dna/new_dna)
	if(new_dna)
		dna = new_dna.Clone()
		if(blood_DNA)
			blood_DNA.Cut()
		else
			blood_DNA = list()
		blood_DNA[dna.unique_enzymes] = dna.blood_type

/obj/item/organ/proc/necrotize(update_sprite = TRUE)
	damage = max_damage
	status |= ORGAN_DEAD
	STOP_PROCESSING(SSobj, src)
	if(dead_icon && !is_robotic())
		icon_state = dead_icon
	if(owner && vital)
		owner.death()

/obj/item/organ/process()

	//dead already, no need for more processing
	if(status & ORGAN_DEAD)
		return

	//Process infections
	if(is_robotic() || sterile || (owner && HAS_TRAIT(owner, TRAIT_NOGERMS)))
		germ_level = 0
		return

	if(!owner || ((status & ORGAN_BURNT) && !(status & ORGAN_SALVED)))
		if(is_preserved())
			return
		// Maybe scale it down a bit, have it REALLY kick in once past the basic infection threshold
		// Another mercy for surgeons preparing transplant organs
		germ_level++
		if(germ_level >= INFECTION_LEVEL_ONE)
			germ_level += rand(2,6)
		if(germ_level >= INFECTION_LEVEL_TWO)
			germ_level += rand(2,6)
		if(germ_level >= INFECTION_LEVEL_THREE)
			necrotize()

	else if(owner.bodytemperature >= 170)	//cryo stops germs from moving and doing their bad stuffs
		// Handle antibiotics and curing infections
		if(germ_level)
			handle_germs()
		return TRUE

/obj/item/organ/proc/is_preserved()
	if(istype(loc,/obj/item/mmi))
		germ_level = max(0, germ_level - 1) // So a brain can slowly recover from being left out of an MMI
		return TRUE
	if(istype(loc, /mob/living/simple_animal/hostile/headslug) || istype(loc, /obj/item/organ/internal/body_egg/changeling_egg))
		germ_level = 0 // weird stuff might happen, best to be safe
		return TRUE
	if(is_found_within(/obj/structure/closet/crate/freezer))
		return TRUE
	if(is_found_within(/obj/machinery/clonepod))
		return TRUE
	if(isturf(loc))
		if(world.time - last_freezer_update_time > freezer_update_period)
			// I don't want to loop through everything in the tile constantly, especially since it'll be a pile of organs
			// if the virologist releases gibbingtons again or something
			// There's probably a much less silly way of doing this, but BYOND native algorithms are stupidly naive
			is_in_freezer = 0
			for(var/obj/structure/closet/crate/freezer/F in loc.contents)
				if(F.opened)
					is_in_freezer = 1 // on the same tile, close enough, should keep organs much fresher on avg
					break
			last_freezer_update_time = world.time
		return is_in_freezer // I'd like static varibles, please

	// You can do your cool location temperature organ preserving effects here!
	return FALSE

/obj/item/organ/examine(mob/user)
	. = ..()
	if(status & ORGAN_DEAD)
		if(!is_robotic())
			. += "<span class='notice'>The decay has set in.</span>"
		else
			. += "<span class='notice'>It looks in need of repairs.</span>"

/obj/item/organ/proc/handle_germs()
	if(germ_level > 0 && germ_level < INFECTION_LEVEL_ONE / 2 && prob(30))
		germ_level--

	if(germ_level >= INFECTION_LEVEL_ONE / 2)
		//aiming for germ level to go from ambient to INFECTION_LEVEL_TWO in an average of 15 minutes
		if(prob(round(germ_level / 6)))
			germ_level++

	if(germ_level >= INFECTION_LEVEL_ONE)
		var/fever_temperature = (owner.dna.species.heat_level_1 - owner.dna.species.body_temperature - 5) * min(germ_level / INFECTION_LEVEL_TWO, 1) + owner.dna.species.body_temperature
		owner.bodytemperature += clamp((fever_temperature - T20C) / BODYTEMP_COLD_DIVISOR + 1, 0, fever_temperature - owner.bodytemperature)

	if(germ_level >= INFECTION_LEVEL_TWO)
		var/obj/item/organ/external/parent = owner.get_organ(parent_organ)
		//spread germs
		if(parent.germ_level < germ_level && ( parent.germ_level < INFECTION_LEVEL_ONE * 2 || prob(30)))
			parent.germ_level++

/obj/item/organ/proc/rejuvenate()
	damage = 0
	germ_level = 0
	surgeryize()
	if(is_robotic())	//Robotic organs stay robotic.
		status = ORGAN_ROBOT
	else
		status = 0
	if(!owner)
		START_PROCESSING(SSobj, src)

/obj/item/organ/proc/is_damaged()
	return damage > 0

/obj/item/organ/proc/is_bruised()
	return damage >= min_bruised_damage

/obj/item/organ/proc/is_broken()
	return (damage >= min_broken_damage || ((status & ORGAN_BROKEN) && !(status & ORGAN_SPLINTED)))

//Adds autopsy data for used_weapon.
/obj/item/organ/proc/add_autopsy_data(used_weapon = "Unknown", damage)
	var/datum/autopsy_data/W = autopsy_data[used_weapon]
	if(!W)
		W = new()
		W.weapon = used_weapon
		autopsy_data[used_weapon] = W

	W.hits += 1
	W.damage += damage
	W.time_inflicted = world.time

//Note: external organs have their own version of this proc
/obj/item/organ/proc/receive_damage(amount, silent = 0)
	if(tough)
		return
	damage = clamp(damage + amount, 0, max_damage)

	//only show this if the organ is not robotic
	if(owner && parent_organ && amount > 0)
		var/obj/item/organ/external/parent = owner.get_organ(parent_organ)
		if(parent && !silent)
			custom_pain("Something inside your [parent.name] hurts a lot.")

		//check if we've hit max_damage
	if(damage >= max_damage)
		necrotize()

/obj/item/organ/proc/heal_internal_damage(amount, robo_repair = FALSE)
	if(is_robotic() && !robo_repair)
		return
	damage = max(damage - amount, 0)

/obj/item/organ/proc/robotize(make_tough) //Being used to make robutt hearts, etc
	status &= ~ORGAN_BROKEN
	status &= ~ORGAN_SPLINTED
	status |= ORGAN_ROBOT

/*
  * remove
  *
  * Removes the organ from the user properly.
  * If the organ is vital, it will kill the user.
  * The proc returns the organ removed (i.e. `src`) assuming it was removed successfully;
* otherwise, or if the organ gets destroyed in the process, it returns null.
*/
/obj/item/organ/proc/remove(mob/living/user, special = 0)
	if(!istype(owner))
		return

	SEND_SIGNAL(owner, COMSIG_CARBON_LOSE_ORGAN, src)

	owner.internal_organs -= src

	var/obj/item/organ/external/affected = owner.get_organ(parent_organ)
	if(affected) affected.internal_organs -= src

	forceMove(get_turf(owner))
	START_PROCESSING(SSobj, src)

	if(owner && vital && is_primary_organ()) // I'd do another check for species or whatever so that you couldn't "kill" an IPC by removing a human head from them, but it doesn't matter since they'll come right back from the dead
		add_attack_logs(user, owner, "Removed vital organ ([src])", !!user ? ATKLOG_FEW : ATKLOG_ALL)
		owner.death()
	owner = null
	if(destroy_on_removal && !QDELETED(src))
		qdel(src)
		return
	return src

/obj/item/organ/proc/replaced(mob/living/carbon/human/target)
	return // Nothing uses this, it is always overridden

// A version of `replaced` that "flattens" the process of insertion, making organs "Plug'n'play"
// (Particularly the heart, which stops beating when removed)
/obj/item/organ/proc/safe_replace(mob/living/carbon/human/target)
	replaced(target)

/obj/item/organ/proc/surgeryize()
	return

/*
Returns 1 if this is the organ that is handling all the functionalities of that particular organ slot
Returns 0 if it isn't
I use this so that this can be made better once the organ overhaul rolls out -- Crazylemon
*/
/obj/item/organ/proc/is_primary_organ(mob/living/carbon/human/O = null)
	if(isnull(O))
		O = owner
	if(!istype(owner)) // You're not the primary organ of ANYTHING, bucko
		return 0
	return src == O.get_int_organ(organ_tag)

/obj/item/organ/proc/is_robotic()
	if(status & ORGAN_ROBOT)
		return TRUE
	return FALSE

/obj/item/organ/serialize()
	var/data = ..()
	if(status)
		data["status"] = status
	return data

/obj/item/organ/deserialize(data)
	if(isnum(data["status"]))
		if(data["status"] & ORGAN_ROBOT)
			robotize()
		status = data["status"]
	..()

// A proc to send a pain message to the owner.
/obj/item/organ/proc/custom_pain(message)
	if(!owner.can_feel_pain() || !message)
		return

	var/msg = "<span class='userdanger'>[message]</span>"

	// Anti message spam checks
	if(msg != last_pain_message || world.time >= next_pain_time)
		last_pain_message = msg
		to_chat(owner, msg)
		next_pain_time = world.time + 10 SECONDS
