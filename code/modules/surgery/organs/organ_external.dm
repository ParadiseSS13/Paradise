/****************************************************
				EXTERNAL ORGANS
****************************************************/
/obj/item/organ/external
	name = "external"
	min_broken_damage = 30
	max_damage = 0
	dir = SOUTH
	organ_tag = "limb"

	blocks_emissive = FALSE

	var/brute_mod = 1
	var/burn_mod = 1

	var/icon_name = null
	var/body_part = null
	var/icon_position = 0

	var/model
	var/force_icon

	var/icobase = 'icons/mob/human_races/r_human.dmi'		// Normal icon set.

	var/damage_state = "00"
	var/brute_dam = 0
	var/burn_dam = 0
	var/max_size = 0
	var/icon/mob_icon
	var/gendered_icon = FALSE
	var/limb_name
	var/limb_flags
	var/s_tone = null
	var/s_col = null // If this is instantiated, it should be a hex value.
	var/list/child_icons = list()
	var/perma_injury = 0
	var/dismember_at_max_damage = FALSE
	/// If the organ has been properly attached or not. Limbs on mobs and robotic ones
	var/properly_attached = FALSE

	var/obj/item/organ/external/parent
	var/list/obj/item/organ/external/children
	var/list/convertable_children = list()

	// Does the organ take reduce damage from EMPs? IPC limbs get this by default
	var/emp_resistant = FALSE

	// Internal organs of this body part
	var/list/internal_organs = list()

	var/damage_msg = "<span class='warning'>You feel an intense pain</span>"
	var/broken_description

	var/open = 0  // If the body part has an open incision from surgery. Can have values > 1.
	var/sabotaged = FALSE //If a prosthetic limb is emagged, it will detonate when it fails.
	var/encased       // Needs to be opened with a saw to access the organs.

	var/obj/item/hidden = null
	var/list/embedded_objects = list()
	var/amputation_point // Descriptive string used in amputation.
	var/can_grasp
	var/can_stand

	var/splinted_count = 0 //Time when this organ was last splinted

/obj/item/organ/external/necrotize(update_sprite=TRUE)
	if(status & (ORGAN_ROBOT|ORGAN_DEAD))
		return
	status |= ORGAN_DEAD
	if(dead_icon)
		icon_state = dead_icon
	if(owner)
		to_chat(owner, "<span class='notice'>You can't feel your [name] anymore...</span>")
		owner.update_body()
		if(vital)
			owner.death()

/obj/item/organ/external/Destroy()
	if(parent && parent.children)
		parent.children -= src

	parent = null

	if(internal_organs)
		for(var/obj/item/organ/internal/O in internal_organs)
			internal_organs -= O
			O.remove(owner,special = 1)
			qdel(O)

	if(owner)
		owner.bodyparts_by_name[limb_name] = null
		owner.splinted_limbs -= src

	QDEL_LIST_CONTENTS(children)

	QDEL_LIST_CONTENTS(embedded_objects)

	QDEL_NULL(hidden)

	return ..()

/obj/item/organ/external/examine(mob/user)
	. = ..()

	var/list/embedded_names = list()
	for(var/obj/item/I in embedded_objects)
		embedded_names += "[I]"
	if(length(embedded_names))
		. += "<span class='warning'>You can see [english_list(embedded_names)] embedded.</span>"

/obj/item/organ/external/update_health()
	damage = min(max_damage, (brute_dam + burn_dam))
	return


/obj/item/organ/external/New(mob/living/carbon/holder)
	..()
	if(ishuman(holder))
		var/mob/living/carbon/human/H = holder
		icobase = H.dna.species.icobase
		replaced(H)
		sync_colour_to_human(H)
		properly_attached = TRUE

	if(is_robotic())
		// These can just be slapped on.
		properly_attached = TRUE

	get_icon()

	// so you can just smack the limb onto a guy to start the "surgery"
	var/application_surgery
	if(!is_robotic())
		application_surgery = /datum/surgery/reattach
	else
		application_surgery = /datum/surgery/reattach_synth

	AddComponent(/datum/component/surgery_initiator/limb, forced_surgery = application_surgery)


/obj/item/organ/external/proc/add_limb_flags()
	if(HAS_TRAIT(owner, TRAIT_NO_BONES))
		limb_flags |= CANNOT_BREAK
		encased = null // no bones to saw

	if(HAS_TRAIT(owner, TRAIT_STURDY_LIMBS))
		limb_flags |= CANNOT_DISMEMBER

	if(HAS_TRAIT(owner, TRAIT_BURN_WOUND_IMMUNE))
		limb_flags |= CANNOT_BURN
	if(HAS_TRAIT(owner, TRAIT_IB_IMMUNE))
		limb_flags |= CANNOT_INT_BLEED

/obj/item/organ/external/proc/remove_limb_flags()
	if(!HAS_TRAIT(owner, TRAIT_NO_BONES))
		limb_flags &= ~CANNOT_BREAK
		encased = initial(encased)

	if(!HAS_TRAIT(owner, TRAIT_STURDY_LIMBS))
		limb_flags &= ~CANNOT_DISMEMBER

	if(!HAS_TRAIT(owner, TRAIT_BURN_WOUND_IMMUNE))
		limb_flags &= ~CANNOT_BURN
	if(!HAS_TRAIT(owner, TRAIT_IB_IMMUNE))
		limb_flags &= ~CANNOT_INT_BLEED

/obj/item/organ/external/replaced(mob/living/carbon/human/target)
	owner = target
	loc = null
	if(iscarbon(owner))
		SEND_SIGNAL(owner, COMSIG_CARBON_GAIN_ORGAN, src)
	if(istype(owner))
		if(!isnull(owner.bodyparts_by_name[limb_name]))
			log_debug("Duplicate organ in slot \"[limb_name]\", mob '[target]'")
		owner.bodyparts_by_name[limb_name] = src
		owner.bodyparts |= src
		for(var/atom/movable/stuff in src)
			stuff.attempt_become_organ(src, owner)

	if(parent_organ)
		parent = owner.bodyparts_by_name[src.parent_organ]
		if(parent)
			if(!parent.children)
				parent.children = list()
			parent.children.Add(src)

	if(owner.has_embedded_objects())
		owner.throw_alert("embeddedobject", /obj/screen/alert/embeddedobject)

/obj/item/organ/external/attempt_become_organ(obj/item/organ/external/parent,mob/living/carbon/human/H)
	if(parent_organ != parent.limb_name)
		return FALSE
	replaced(H)
	return TRUE

/****************************************************
			DAMAGE PROCS
****************************************************/

/obj/item/organ/external/receive_damage(brute, burn, sharp, used_weapon = null, list/forbidden_limbs = list(), ignore_resists = FALSE, updating_health = TRUE)
	if(tough && !ignore_resists)
		brute = max(0, brute - 5)
		burn = max(0, burn - 4)

	if((brute <= 0) && (burn <= 0))
		return 0

	if(!ignore_resists && !ismachineperson(owner)) //Machine people can't have augmented limbs, and this lets us give them no strange damage issues from countering the 33% resist
		brute *= brute_mod
		burn *= burn_mod

	//I would move the delimb check below fractures and burn wounds, but it would cause issues. As such we save the incoming damage here.
	var/original_brute = brute
	var/original_burn = burn
	var/limb_brute = brute_dam
	var/limb_burn = burn_dam

	// See if bones need to break
	check_fracture(brute)
	// See if we need to inflict severe burns
	check_for_burn_wound(burn)
	// Threshold needed to have a chance of hurting internal bits with something sharp
#define LIMB_SHARP_THRESH_INT_DMG 5
	// Threshold needed to have a chance of hurting internal bits
#define LIMB_THRESH_INT_DMG 10
	// Probability of taking internal damage from sufficient force, while otherwise healthy
#define LIMB_DMG_PROB 5
	// High brute damage or sharp objects may damage internal organs
	if(internal_organs && (brute_dam >= max_damage || (((sharp && brute >= LIMB_SHARP_THRESH_INT_DMG) || brute >= LIMB_THRESH_INT_DMG) && prob(LIMB_DMG_PROB))))
		// Damage an internal organ
		if(internal_organs && internal_organs.len)
			var/obj/item/organ/internal/I = pick(internal_organs)
			I.receive_damage(brute * 0.5)

	if(status & ORGAN_BROKEN && prob(40) && brute && !owner.stat)
		owner.emote("scream")	//getting hit on broken hand hurts
	if(status & ORGAN_SPLINTED && prob((brute + burn)*4)) //taking damage to splinted limbs removes the splints
		status &= ~ORGAN_SPLINTED
		owner.visible_message("<span class='danger'>The splint on [owner]'s left arm unravels from [owner.p_their()] [name]!</span>","<span class='userdanger'>The splint on your [name] unravels!</span>")
		owner.handle_splints()
	if(used_weapon)
		add_autopsy_data("[used_weapon]", brute + burn)
	else
		add_autopsy_data(null, brute + burn)

	// Make sure we don't exceed the maximum damage a limb can take before dismembering
	if((brute_dam + burn_dam + brute + burn) < max_damage)
		brute_dam += brute
		burn_dam += burn
		check_for_internal_bleeding(brute)
	else
		//If we can't inflict the full amount of damage, spread the damage in other ways
		//How much damage can we actually cause?
		var/can_inflict = max_damage - (brute_dam + burn_dam)
		if(can_inflict)
			if(brute > 0)
				//Inflict all burte damage we can
				brute_dam = min(brute_dam + brute, brute_dam + can_inflict)
				var/temp = can_inflict
				//How much mroe damage can we inflict
				can_inflict = max(0, can_inflict - brute)
				//How much brute damage is left to inflict
				brute = max(0, brute - temp)
				check_for_internal_bleeding(brute)

			if(burn > 0 && can_inflict)
				//Inflict all burn damage we can
				burn_dam = min(burn_dam + burn, burn_dam + can_inflict)
				//How much burn damage is left to inflict
				burn = max(0, burn - can_inflict)
		//If there are still hurties to dispense
		if(burn || brute)
			//List organs we can pass it to
			var/list/obj/item/organ/external/possible_points = list()
			if(parent)
				possible_points += parent
			if(children)
				for(var/organ in children)
					if(organ)
						possible_points += organ
			if(forbidden_limbs.len)
				possible_points -= forbidden_limbs
			if(possible_points.len)
				//And pass the pain around
				var/obj/item/organ/external/target = pick(possible_points)
				target.receive_damage(brute, burn, sharp, used_weapon, forbidden_limbs + src, ignore_resists = TRUE) //If the damage was reduced before, don't reduce it again

			if(dismember_at_max_damage && body_part != UPPER_TORSO && body_part != LOWER_TORSO) // We've ensured all damage to the mob is retained, now let's drop it, if necessary.
				droplimb(1) //Clean loss, just drop the limb and be done

	var/mob/living/carbon/owner_old = owner //Need to update health, but need a reference in case the below check cuts off a limb.
	//If limb took enough damage, try to cut or tear it off
	if(owner)
		if(sharp && !(limb_flags & CANNOT_DISMEMBER))
			if(limb_brute >= max_damage && prob(original_brute / 2))
				droplimb(0, DROPLIMB_SHARP)
			if(limb_burn >= max_damage && prob(original_burn / 2))
				droplimb(0, DROPLIMB_BURN)

	if(owner_old)
		owner_old.updatehealth("limb receive damage")
	return update_state()

#undef LIMB_SHARP_THRESH_INT_DMG
#undef LIMB_THRESH_INT_DMG
#undef LIMB_DMG_PROB

/obj/item/organ/external/proc/heal_damage(brute, burn, internal = 0, robo_repair = 0, updating_health = TRUE)
	if(is_robotic() && !robo_repair)
		return

	brute_dam = max(brute_dam - brute, 0)
	burn_dam  = max(burn_dam - burn, 0)

	if(internal)
		status &= ~ORGAN_BROKEN
		perma_injury = 0

	if(updating_health)
		owner.updatehealth("limb heal damage")

	return update_state()

/obj/item/organ/external/emp_act(severity)
	if(!is_robotic() || emp_proof)
		return
	if(tough) // Augmented limbs (remember they take -5 brute/-4 burn damage flat so any value below is compensated)
		switch(severity)
			if(1)
				// 44 total burn damage with 11 augmented limbs
				receive_damage(0, 8)
			if(2)
				// 22 total burn damage with 11 augmented limbs
				receive_damage(0, 6)
	else if(emp_resistant) // IPC limbs
		switch(severity)
			if(1)
				// 5.28 (9 * 0.66 burn_mod) burn damage, 65.34 damage with 11 limbs.
				receive_damage(0, 9)
			if(2)
				// 3.63 (5 * 0.66 burn_mod) burn damage, 39.93 damage with 11 limbs.
				receive_damage(0, 5.5)
	else // Basic prosthetic limbs
		switch(severity)
			if(1)
				receive_damage(0, 20)
			if(2)
				receive_damage(0, 7)

/*
This function completely restores a damaged organ to perfect condition.
*/
/obj/item/organ/external/rejuvenate()
	damage_state = "00"
	surgeryize()
	if(is_robotic())	//Robotic organs stay robotic.
		status = ORGAN_ROBOT
	else
		status = 0
	germ_level = 0
	perma_injury = 0
	brute_dam = 0
	burn_dam = 0
	open = ORGAN_CLOSED //Closing all wounds.

	// handle internal organs
	for(var/obj/item/organ/internal/current_organ in internal_organs)
		current_organ.rejuvenate()

	for(var/obj/item/organ/external/EO in contents)
		EO.rejuvenate()

	if(owner)
		owner.updatehealth("limb rejuvenate")
	update_state()
	if(!owner)
		START_PROCESSING(SSobj, src)

/****************************************************
			PROCESSING & UPDATING
****************************************************/

//Determines if we even need to process this organ.

/obj/item/organ/external/process()
	if(owner)
		//Chem traces slowly vanish
		if(owner.life_tick % 10 == 0)
			for(var/chemID in trace_chemicals)
				trace_chemicals[chemID] = trace_chemicals[chemID] - 1
				if(trace_chemicals[chemID] <= 0)
					trace_chemicals.Remove(chemID)

	if(..())
		if(owner.germ_level > germ_level && infection_check())
			//Open wounds can become infected
			germ_level++

//Updating germ levels. Handles organ germ levels and necrosis.
/*
The INFECTION_LEVEL values defined in setup.dm control the time it takes to reach the different
infection levels. Since infection growth is exponential, you can adjust the time it takes to get
from one germ_level to another using the rough formula:

desired_germ_level = initial_germ_level*e^(desired_time_in_seconds/1000)

So if I wanted it to take an average of 15 minutes to get from level one (100) to level two
I would set INFECTION_LEVEL_TWO to 100*e^(15*60/1000) = 245. Note that this is the average time,
the actual time is dependent on RNG.

INFECTION_LEVEL_ONE		below this germ level nothing happens, and the infection doesn't grow
INFECTION_LEVEL_TWO		above this germ level the infection will start to spread to internal and adjacent organs
INFECTION_LEVEL_THREE	above this germ level the player will take additional toxin damage per second, and will die in minutes without
						antitox..

Note that amputating the affected organ does in fact remove the infection from the player's body.
*/

/obj/item/organ/external/handle_germs()

	if(germ_level < INFECTION_LEVEL_TWO)
		return ..()

	if(germ_level >= INFECTION_LEVEL_TWO)
		//spread the infection to internal organs
		var/obj/item/organ/internal/target_organ = null	//make internal organs become infected one at a time instead of all at once
		for(var/obj/item/organ/internal/I in internal_organs)
			if(I.germ_level > 0 && I.germ_level < min(germ_level, INFECTION_LEVEL_TWO))	//once the organ reaches whatever we can give it, or level two, switch to a different one
				if(!target_organ || I.germ_level > target_organ.germ_level)	//choose the organ with the highest germ_level
					target_organ = I

		if(!target_organ)
			//figure out which organs we can spread germs to and pick one at random
			var/list/candidate_organs = list()
			for(var/obj/item/organ/internal/I in internal_organs)
				if(I.germ_level < germ_level)
					candidate_organs |= I
			if(candidate_organs.len)
				target_organ = pick(candidate_organs)

		if(target_organ)
			target_organ.germ_level++

		//spread the infection to child and parent organs
		if(children)
			for(var/obj/item/organ/external/child in children)
				if(child.germ_level < germ_level && !child.is_robotic())
					if(child.germ_level < INFECTION_LEVEL_ONE * 2 || prob(30))
						child.germ_level++

		if(parent)
			if(parent.germ_level < germ_level && !parent.is_robotic())
				if(parent.germ_level < INFECTION_LEVEL_ONE * 2 || prob(30))
					parent.germ_level++

	if(germ_level >= INFECTION_LEVEL_THREE)
		necrotize()
		germ_level++
		owner.adjustToxLoss(1)

//Updates brute_damn and burn_damn from wound damages. Updates BLEEDING status.
/obj/item/organ/external/proc/check_fracture(damage_inflicted)
	if(GLOB.configuration.general.breakable_bones && brute_dam > min_broken_damage && !is_robotic())
		if(prob(damage_inflicted))
			fracture()

/obj/item/organ/external/proc/check_for_internal_bleeding(damage)
	if(owner && (NO_BLOOD in owner.dna.species.species_traits))
		return
	var/local_damage = brute_dam + damage
	if(damage > 15 && local_damage > 30 && prob(damage))
		cause_internal_bleeding()

/obj/item/organ/external/proc/check_for_burn_wound(damage, update_health = TRUE)
	if(is_robotic())
		return
	if(burn_dam >= min_broken_damage && prob(damage * max(owner.bodytemperature / BODYTEMP_HEAT_DAMAGE_LIMIT, 1)))
		cause_burn_wound(update_health)

// new damage icon system
// returns just the brute/burn damage code
/obj/item/organ/external/proc/damage_state_text()
	var/tburn = 0
	var/tbrute = 0

	if(burn_dam == 0)
		tburn = 0
	else if(burn_dam < (max_damage * 0.25 / 2))
		tburn = 1
	else if(burn_dam < (max_damage * 0.75 / 2))
		tburn = 2
	else
		tburn = 3

	if(brute_dam == 0)
		tbrute = 0
	else if(brute_dam < (max_damage * 0.25 / 2))
		tbrute = 1
	else if(brute_dam < (max_damage * 0.75 / 2))
		tbrute = 2
	else
		tbrute = 3
	return "[tbrute][tburn]"

/obj/item/organ/external/proc/update_splints()
	if(!(status & ORGAN_SPLINTED))
		owner.splinted_limbs -= src
		return
	if(owner.step_count >= splinted_count + SPLINT_LIFE)
		status &= ~ORGAN_SPLINTED // Oh no, we actually need surgery now!
		owner.handle_splints()
		if(!(status & ORGAN_BROKEN))
			to_chat(owner, "<span class='notice'>Your splint harmlessly pops off your [name].</span>") // If we fixed our bones, a splint popping off shouldn't be painful and stun us.
			return
		owner.visible_message("<span class='danger'>[owner] screams in pain as [owner.p_their()] splint pops off [owner.p_their()] [name]!</span>","<span class='userdanger'>You scream in pain as your splint pops off your [name]!</span>")
		owner.emote("scream")
		owner.Weaken(4 SECONDS) // Better feedback compared to stun() - We won't be just standing there menancingly

/****************************************************
			DISMEMBERMENT
****************************************************/

//Handles dismemberment
/obj/item/organ/external/proc/droplimb(clean, disintegrate, ignore_children, nodamage)

	if(limb_flags & CANNOT_DISMEMBER || !owner)
		return

	if(!disintegrate)
		disintegrate = DROPLIMB_SHARP
	if(disintegrate == DROPLIMB_BURN && istype(src, /obj/item/organ/external/head))
		disintegrate = DROPLIMB_SHARP //Lets not make sharp burn weapons delete brains.

	switch(disintegrate)
		if(DROPLIMB_SHARP)
			if(!clean)
				var/gore_sound = "[is_robotic() ? "tortured metal" : "ripping tendons and flesh"]"
				owner.visible_message(
					"<span class='danger'>\The [owner]'s [name] flies off in an arc!</span>",\
					"<span class='moderate'><b>Your [name] goes flying off!</b></span>",\
					"<span class='danger'>You hear a terrible sound of [gore_sound].</span>")
		if(DROPLIMB_BURN)
			var/gore = "[is_robotic() ? "" : " of burning flesh"]"
			owner.visible_message(
				"<span class='danger'>\The [owner]'s [name] flashes away into ashes!</span>",\
				"<span class='moderate'><b>Your [name] flashes away into ashes!</b></span>",\
				"<span class='danger'>You hear a crackling sound[gore].</span>")
		if(DROPLIMB_BLUNT)
			var/gore = "[is_robotic() ? "": " in shower of gore"]"
			var/gore_sound = "[is_robotic() ? "rending sound of tortured metal" : "sickening splatter of gore"]"
			owner.visible_message(
				"<span class='danger'>\The [owner]'s [name] explodes[gore]!</span>",\
				"<span class='moderate'><b>Your [name] explodes[gore]!</b></span>",\
				"<span class='danger'>You hear the [gore_sound].</span>")
			disembowel(limb_name)

	var/mob/living/carbon/human/victim = owner //Keep a reference for post-removed().
	// Let people make limbs become fun things when removed
	var/atom/movable/dropped_part = remove(null, ignore_children)

	if(parent)
		parent.children -= src
		if(!nodamage)
			var/total_brute = brute_dam
			var/total_burn = burn_dam
			for(var/obj/item/organ/external/E in children) //Factor in the children's brute and burn into how much will transfer
				total_brute += E.brute_dam
				total_burn += E.burn_dam
			parent.receive_damage(total_brute, total_burn, ignore_resists = TRUE) //Transfer the full damage to the parent, bypass limb damage reduction.
		parent = null

		dir = 2

	if(victim)
		victim.updatehealth("droplimb")
		victim.UpdateDamageIcon()
		victim.regenerate_icons()

	switch(disintegrate)
		if(DROPLIMB_SHARP)
			compile_icon()
			add_blood(victim.blood_DNA, victim.dna.species.blood_color)
			var/matrix/M = matrix()
			M.Turn(rand(180))
			src.transform = M
			if(!clean)
				// Throw limb around.
				if(src && isturf(loc))
					dropped_part.throw_at(get_edge_target_turf(src,pick(GLOB.alldirs)),rand(1,3),30)
				dir = 2
			brute_dam = 0
			burn_dam = 0  //Reset the damage on the limb; the damage should have transferred to the parent; we don't want extra damage being re-applied when then limb is re-attached
			return dropped_part
		else
			qdel(src) // If you flashed away to ashes, YOU FLASHED AWAY TO ASHES
			return null

/obj/item/organ/external/proc/disembowel(spillage_zone = "chest")
	if(!owner)
		return

	var/mob/living/carbon/C = owner

	if(!hasorgans(C))
		return

	var/organ_spilled = FALSE
	var/turf/T = get_turf(C)
	C.add_splatter_floor(T)
	playsound(get_turf(C), 'sound/effects/splat.ogg', 25, 1)
	for(var/X in C.internal_organs)
		var/obj/item/organ/O = X
		var/org_zone = check_zone(O.parent_organ)
		if(org_zone == spillage_zone)
			O.remove(C)
			O.forceMove(T)
			organ_spilled = TRUE

	if(organ_spilled)
		C.visible_message("<span class='danger'><B>[C]'s internal organs spill out onto the floor!</B></span>")
	return TRUE

/obj/item/organ/external/chest/droplimb()
	if(disembowel())
		return TRUE

/obj/item/organ/external/groin/droplimb()
	if(disembowel("groin"))
		return TRUE



/obj/item/organ/external/attackby(obj/item/I, mob/user, params)
	if(I.sharp)
		add_fingerprint(user)
		if(!length(contents))
			to_chat(user, "<span class='warning'>There is nothing left inside [src]!</span>")
			return
		playsound(loc, 'sound/weapons/slice.ogg', 50, 1, -1)
		user.visible_message("<span class='warning'>[user] begins to cut open [src].</span>",\
			"<span class='notice'>You begin to cut open [src]...</span>")
		if(do_after(user, 54, target = src))
			drop_organs(user)
			drop_embedded_objects()
	else
		return ..()

//empties the bodypart from its organs and other things inside it
/obj/item/organ/external/proc/drop_organs(mob/user)
	var/turf/T = get_turf(src)
	if(!is_robotic())
		playsound(T, 'sound/effects/splat.ogg', 25, 1)
	for(var/obj/item/I in src)
		I.forceMove(T)

/****************************************************
			HELPERS
****************************************************/
/obj/item/organ/external/proc/release_restraints(mob/living/carbon/human/holder)
	if(!holder)
		holder = owner
	if(!holder)
		return
	if(holder.handcuffed && (body_part in list(ARM_LEFT, ARM_RIGHT, HAND_LEFT, HAND_RIGHT)))
		holder.visible_message(\
			"\The [holder.handcuffed.name] falls off of [holder.name].",\
			"\The [holder.handcuffed.name] falls off you.")
		holder.unEquip(holder.handcuffed)
	if(holder.legcuffed && (body_part in list(FOOT_LEFT, FOOT_RIGHT, LEG_LEFT, LEG_RIGHT)))
		holder.visible_message(\
			"\The [holder.legcuffed.name] falls off of [holder.name].",\
			"\The [holder.legcuffed.name] falls off you.")
		holder.unEquip(holder.legcuffed)

/obj/item/organ/external/proc/fracture(silent = FALSE)
	if(is_robotic())
		return	//ORGAN_BROKEN doesn't have the same meaning for robot limbs

	if((status & ORGAN_BROKEN) || (limb_flags & CANNOT_BREAK))
		return
	if(owner && !silent)
		owner.audible_message(
			"<span class='warning'>You hear a sickening crack coming from \the [owner].</span>",
			"<span class='danger'>[owner]'s [name] appears to buckle unnaturally!</span>"
		)
		to_chat(owner, "<span class='userdanger'>Something feels like it shattered in your [name]!</span>")
		playsound(owner, "bonebreak", 150, 1)
		if(owner.can_feel_pain())
			owner.emote("scream")

	status |= ORGAN_BROKEN
	broken_description = pick("broken", "fracture", "hairline fracture")

	// Fractures have a chance of getting you out of restraints
	if(prob(25))
		release_restraints()

/obj/item/organ/external/proc/mend_fracture()
	if(is_robotic())
		return FALSE	//ORGAN_BROKEN doesn't have the same meaning for robot limbs

	if(!(status & ORGAN_BROKEN))
		return FALSE

	status &= ~ORGAN_BROKEN
	status &= ~ORGAN_SPLINTED
	if(owner)
		owner.handle_splints()
	return TRUE

/obj/item/organ/external/proc/cause_internal_bleeding()
	if(is_robotic())
		return
	if(NO_BLOOD in owner.dna.species.species_traits)
		return
	if(limb_flags & CANNOT_INT_BLEED)
		return
	status |= ORGAN_INT_BLEEDING
	custom_pain("You feel something rip in your [name]!")

/obj/item/organ/external/proc/fix_internal_bleeding()
	if(is_robotic())
		return
	status &= ~ORGAN_INT_BLEEDING

/obj/item/organ/external/proc/cause_burn_wound(update_health = TRUE)
	if(is_robotic() || (limb_flags & CANNOT_BURN) || (status & ORGAN_BURNT))
		return
	status |= ORGAN_BURNT
	perma_injury = min_broken_damage
	if(update_health)
		owner.updatehealth("burn wound inflicted")

/obj/item/organ/external/proc/fix_burn_wound(update_health = TRUE)
	status &= ~ORGAN_BURNT
	perma_injury = max(perma_injury - min_broken_damage, 0)
	if(update_health)
		owner.updatehealth("burn wound fixed")

/obj/item/organ/external/robotize(company, make_tough = FALSE, convert_all = TRUE)
	..()
	//robot limbs take reduced damage
	if(!make_tough)
		brute_mod = 0.66
		burn_mod = 0.66
		dismember_at_max_damage = TRUE
	else
		tough = TRUE
	// Robot parts also lack bones
	// This is so surgery isn't kaput, let's see how this does
	encased = null

	// override the existing initiator
	AddComponent(/datum/component/surgery_initiator/limb, forced_surgery = /datum/surgery/reattach_synth)

	if(company && istext(company))
		set_company(company)

	limb_flags |= CANNOT_BREAK
	get_icon()
	for(var/obj/item/organ/external/T in children)
		if((convert_all) || (T.type in convertable_children))
			T.robotize(company, make_tough, convert_all)



/obj/item/organ/external/proc/set_company(company)
	model = company
	var/datum/robolimb/R = GLOB.all_robolimbs[company]
	if(R)
		force_icon = R.icon
		name = "[R.company] [initial(name)]"
		desc = "[R.desc]"

/obj/item/organ/external/proc/mutate()
	status |= ORGAN_MUTATED

/obj/item/organ/external/proc/unmutate()
	status &= ~ORGAN_MUTATED

/obj/item/organ/external/proc/get_damage()	//returns total damage
	return max(brute_dam + burn_dam, perma_injury)

/obj/item/organ/external/proc/has_infected_wound()
	if(germ_level > INFECTION_LEVEL_ONE)
		return TRUE
	return FALSE

/obj/item/organ/external/proc/is_usable()
	if((is_robotic() && get_damage() >= max_damage) && !tough) //robot limbs just become inoperable at max damage
		return
	return !(status & (ORGAN_MUTATED|ORGAN_DEAD))

/obj/item/organ/external/proc/is_malfunctioning()
	return (is_robotic() && (brute_dam + burn_dam) >= 10 && prob(brute_dam + burn_dam) && !tough)

/obj/item/organ/external/remove(mob/living/user, ignore_children)

	if(!owner)
		return

	SEND_SIGNAL(owner, COMSIG_CARBON_LOSE_ORGAN, src)
	var/mob/living/carbon/human/victim = owner

	if(status & ORGAN_SPLINTED)
		victim.splinted_limbs -= src

	for(var/obj/item/I in embedded_objects)
		UnregisterSignal(I, COMSIG_MOVABLE_MOVED) // Else it gets removed from the embedded list
		I.forceMove(src)
		RegisterSignal(I, COMSIG_MOVABLE_MOVED, PROC_REF(remove_embedded_object))

	. = ..()

	if(!victim.has_embedded_objects())
		victim.clear_alert("embeddedobject")

	// Attached organs also fly off.
	if(!ignore_children)
		for(var/obj/item/organ/external/O in children)
			var/atom/movable/thing = O.remove(victim)
			if(thing)
				thing.forceMove(src)
		victim.updatehealth("limb remove")

	// Grab all the internal giblets too.
	for(var/obj/item/organ/internal/organ in internal_organs)
		var/atom/movable/thing = organ.remove(victim)
		if(thing) // Nodrop organs exist
			thing.forceMove(src)

	release_restraints(victim)
	victim.bodyparts -= src
	if(is_primary_organ(victim))
		victim.bodyparts_by_name[limb_name] = null	// Remove from owner's vars.

	//Robotic limbs explode if sabotaged.
	if(is_robotic() && sabotaged)
		victim.visible_message(
			"<span class='danger'>\The [victim]'s [name] explodes violently!</span>",\
			"<span class='userdanger'>Your [name] explodes!</span>",\
			"<span class='danger'>You hear an explosion!</span>")
		explosion(get_turf(owner),-1,-1,2,3)
		do_sparks(5, 0, victim)
		qdel(src)

/obj/item/organ/external/proc/disfigure()
	if(status & ORGAN_DISFIGURED)
		return
	if(owner)
		owner.visible_message("<span class='warning'>\The [owner]'s [name] turns into a mangled mess!</span>",	\
							"<span class='userdanger'>Your [name] becomes a mangled mess!</span>",	\
							"<span class='warning'>You hear a sickening sound.</span>")

	status |= ORGAN_DISFIGURED

/obj/item/organ/external/is_primary_organ(mob/living/carbon/human/O = null)
	if(isnull(O))
		O = owner
	if(!istype(O)) // You're not the primary organ of ANYTHING, bucko
		return FALSE
	return src == O.bodyparts_by_name[limb_name]

/obj/item/organ/external/proc/infection_check()
	var/total_damage = brute_dam + burn_dam
	if(total_damage)
		if(total_damage < 10) //small amounts of damage aren't infectable
			return FALSE

		if(owner && owner.bleedsuppress && total_damage < 25)
			return FALSE

		var/dam_coef = round(total_damage / 10)
		return prob(dam_coef * 10)
	return FALSE

/obj/item/organ/external/serialize()
	var/list/data = ..()
	if(is_robotic())
		data["company"] = model
	// If we wanted to store wound information, here is where it would go
	return data

/obj/item/organ/external/deserialize(list/data)
	var/company = data["company"]
	if(company && istext(company))
		set_company(company)
	..() // Parent call loads in the DNA
	if(data["dna"])
		sync_colour_to_dna()

/obj/item/organ/external/proc/remove_embedded_object(obj/item/I)
	embedded_objects -= I
	UnregisterSignal(I, COMSIG_MOVABLE_MOVED)

/obj/item/organ/external/proc/drop_embedded_objects()
	var/turf/T = get_turf(src)
	for(var/obj/item/I in embedded_objects)
		remove_embedded_object(I)
		forceMove(T)

/obj/item/organ/external/proc/add_embedded_object(obj/item/I)
	owner.throw_alert("embeddedobject", /obj/screen/alert/embeddedobject)
	embedded_objects += I
	I.forceMove(owner)
	RegisterSignal(I, COMSIG_MOVABLE_MOVED, PROC_REF(remove_embedded_object))

//Remove all embedded objects from all limbs on the carbon mob
/mob/living/carbon/human/proc/remove_all_embedded_objects()
	var/turf/T = get_turf(src)

	for(var/X in bodyparts)
		var/obj/item/organ/external/L = X
		for(var/obj/item/I in L.embedded_objects)
			L.remove_embedded_object(I)
			I.forceMove(T)

	clear_alert("embeddedobject")

/mob/living/carbon/human/proc/has_embedded_objects()
	. = 0
	for(var/X in bodyparts)
		var/obj/item/organ/external/L = X
		for(var/obj/item/I in L.embedded_objects)
			return 1
