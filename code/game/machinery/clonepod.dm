/// Reagents that can be inserted into the cloning pod (and not deleted by it).
#define VALID_REAGENTS list("sanguine_reagent", "osseous_reagent")

/// Meats that can be used as biomass for the cloner.
#define VALID_BIOMASSABLES list(/obj/item/food/meat, \
								/obj/item/food/monstermeat, \
								/obj/item/food/carpmeat, \
								/obj/item/food/salmonmeat, \
								/obj/item/food/catfishmeat, \
								/obj/item/food/tofurkey)

/// Internal organs the cloner will *never* accept for insertion.
#define FORBIDDEN_INTERNAL_ORGANS list(/obj/item/organ/internal/regenerative_core, \
									/obj/item/organ/internal/alien, \
									/obj/item/organ/internal/body_egg, \
									/obj/item/organ/internal/adamantine_resonator, \
									/obj/item/organ/internal/vocal_cords/colossus, \
									/obj/item/organ/internal/cyberimp, \
									/obj/item/organ/internal/brain, \
									/obj/item/organ/internal/cell, \
									/obj/item/organ/internal/eyes/optical_sensor, \
									/obj/item/organ/internal/ears/microphone)

/// Internal organs the cloner will only accept when fully upgraded.
#define UPGRADE_LOCKED_ORGANS list(/obj/item/organ/internal/heart/gland, \
								/obj/item/organ/internal/heart/demon, \
								/obj/item/organ/internal/heart/cursed, \
								/obj/item/organ/internal/eyes/cybernetic/eyesofgod)

/// Limbs that the cloner won't accept.
#define FORBIDDEN_LIMBS list(/obj/item/organ/external/head, \
							/obj/item/organ/external/chest, \
							/obj/item/organ/external/groin) //you can't even get chests and groins normally

/// A list of robot parts for use later, so that you can put them straight into the cloner from the exosuit fabricator.
#define ALLOWED_ROBOT_PARTS list(/obj/item/robot_parts/r_arm, \
								/obj/item/robot_parts/l_arm, \
								/obj/item/robot_parts/r_leg, \
								/obj/item/robot_parts/l_leg)


//Balance tweaks go here vv
#define BIOMASS_BASE_COST 250
#define MEAT_BIOMASS_VALUE 50
//These ones are also used for dead limbs/organs
#define BIOMASS_NEW_LIMB_COST 100
#define BIOMASS_NEW_ORGAN_COST 100
#define BIOMASS_BURN_WOUND_COST 25
//These next 3 are for every point of the respective damage type
#define BIOMASS_BRUTE_COST 0.5
#define BIOMASS_BURN_COST 0.5
#define BIOMASS_ORGAN_DAMAGE_COST 1
#define SANGUINE_IB_COST 5
#define OSSEOUS_BONE_COST 5


/obj/machinery/clonepod
	anchored = TRUE
	name = "cloning pod"
	desc = "A pod for growing organic tissue."
	density = TRUE
	icon = 'icons/obj/cloning.dmi'
	icon_state = "pod_idle"
	req_access = list(ACCESS_MEDICAL)
	//So that chemicals can be loaded into the pod.
	container_type = OPENCONTAINER
	/// The linked cloning console.
	var/obj/machinery/computer/cloning/console

	/// Whether or not we're cloning someone.
	var/currently_cloning = FALSE
	/// The progress on the current clone.
	/// Measured from 0-100, where 0-20 has no body, and 21-100 gradually builds on limbs every 10. (r_arm, r_hand, l_arm, l_hand, r_leg, r_foot, l_leg, l_foot)
	var/clone_progress = 0
	/// A list of limbs which have not yet been grown by the cloner.
	var/list/limbs_to_grow = list()
	/// The limb we're currently growing.
	var/current_limb
	/// Flavor text to show on examine.
	var/desc_flavor = "It doesn't seem to be doing anything right now."
	/// The countdown.
	var/obj/effect/countdown/clonepod/countdown

	/// The speed at which we clone. Each processing cycle will advance clone_progress by this amount.
	var/speed_modifier = 1
	/// Our price modifier, multiplied with the base cost to get the true cost.
	var/price_modifier = 1.1
	/// Our storage modifier, which is used in calculating organ and biomass storage.
	var/storage_modifier = 1
	/// How resistant the cloner is to being emp'd. Equal to the average level of all the stock parts
	var/emp_resistance = 1

	/// The cloner's biomass count.
	var/biomass = 0
	/// How many organs we can store. This is calculated with the storage modifier in RefreshParts().
	var/organ_storage_capacity
	/// How much biomass we can store. This is calculated at the same time as organ_storage_capacity.
	var/biomass_storage_capacity

	/// The cloning_data datum which shows the patient's current status.
	var/datum/cloning_data/patient_data
	/// The cloning_data datum which shows the status we want the patient to be in.
	var/datum/cloning_data/desired_data
	/// Our patient.
	var/mob/living/carbon/human/clone

/obj/machinery/clonepod/Initialize(mapload)
	. = ..()

	countdown = new(src)

	if(!console && mapload)
		console = pick(locate(/obj/machinery/computer/cloning, orange(5, src))) //again, there shouldn't be multiple consoles, mappers

	component_parts = list()
	component_parts += new /obj/item/circuitboard/clonepod(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/reagent_containers/glass/beaker/large(null)
	create_reagents(100)
	update_icon()
	RefreshParts()

/obj/machinery/clonepod/biomass/Initialize(mapload)
	. = ..()
	biomass = biomass_storage_capacity

/obj/machinery/clonepod/upgraded/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/clonepod(null)
	component_parts += new /obj/item/stock_parts/scanning_module/triphasic(null)
	component_parts += new /obj/item/stock_parts/matter_bin/bluespace(null)
	component_parts += new /obj/item/stock_parts/manipulator/femto(null)
	component_parts += new /obj/item/stock_parts/manipulator/femto(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/reagent_containers/glass/beaker/bluespace(null)

	update_icon()
	RefreshParts()

	biomass = biomass_storage_capacity
	reagents.add_reagent("sanguine_reagent", 150)
	reagents.add_reagent("osseous_reagent", 150)

/obj/machinery/clonepod/Destroy()
	if(console)
		console.pods -= src
		if(console.selected_pod == src && length(console.pods) > 0)
			console.selected_pod = pick(console.pods)
		else
			console.selected_pod = null

	QDEL_NULL(countdown)
	return ..()

/obj/machinery/clonepod/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[desc_flavor]</span>"

/obj/machinery/clonepod/RefreshParts()
	speed_modifier = 0 // Since we have multiple manipulators, which affect this modifier, we reset here so we can just use += later
	emp_resistance = 0
	for(var/obj/item/stock_parts/SP as anything in component_parts)
		if(istype(SP, /obj/item/stock_parts/matter_bin)) // Matter bins for storage modifier
			storage_modifier = round(10 * (SP.rating / 2)) // 5 at tier 1, 10 at tier 2, 15 at tier 3, 20 at tier 4
			emp_resistance += SP.rating
		else if(istype(SP, /obj/item/stock_parts/scanning_module)) //Scanning modules for price modifier (more accurate scans = more efficient)
			price_modifier = -(SP.rating / 10) + 1.2 // 1.1 at tier 1, 1 at tier 2, 0.9 at tier 3, 0.8 at tier 4
			emp_resistance += SP.rating
		else if(istype(SP, /obj/item/stock_parts/manipulator)) //Manipulators for speed modifier
			speed_modifier += SP.rating / 2 // 1 at tier 1, 2 at tier 2, et cetera
			emp_resistance += SP.rating
	emp_resistance /= 4 // 4 stock parts, this brings us to a value between 1 to 4. Decimals can happen and are fine.
	for(var/obj/item/reagent_containers/glass/beaker/B in component_parts)
		if(istype(B))
			reagents.maximum_volume = B.volume //The default cloning pod has a large beaker in it, so 100u.

	organ_storage_capacity = storage_modifier
	biomass_storage_capacity = storage_modifier * 400

// Process
/obj/machinery/clonepod/process()

	//Basically just isolate_reagent() with extra functionality.
	for(var/datum/reagent/R as anything in reagents.reagent_list)
		if(!(R.id in VALID_REAGENTS))
			reagents.del_reagent(R.id)
			reagents.update_total()
			atom_say("Purged contaminant from chemical storage.")

	//Take in biomass. Mostly copied from the old cloning code
	var/show_message = FALSE
	for(var/obj/item/item in range(1, src))
		if(is_type_in_list(item, VALID_BIOMASSABLES) && (biomass + MEAT_BIOMASS_VALUE <= biomass_storage_capacity))
			qdel(item)
			biomass += MEAT_BIOMASS_VALUE
			show_message = TRUE
	if(show_message)
		visible_message("<span class='notice'>[src] sucks in nearby biomass.</span>")

	//If we're cloning someone, we haven't generated a list of limbs to grow, and we're before any possibility of not having any limbs left to grow.
	if(currently_cloning && !length(limbs_to_grow) && clone_progress < 20)
		for(var/limb in desired_data.limbs)
			if(desired_data.limbs[limb][4])
				continue //We're not growing this limb, since in the desired state it's missing.

			var/obj/item/organ/external/limb_typepath = patient_data.genetic_info.species.has_limbs[limb]["path"]
			if(initial(limb_typepath.vital)) //I hate everything about this check, but it sees if the current organ is vital..
				continue //and continues if it is, since the proc that creates the clone mob will make these all at once.
			var/parent_organ_is_limb = FALSE
			for(var/organ in desired_data.organs)
				var/obj/item/organ/external/organ_typepath = patient_data.genetic_info.species.has_organ[organ]
				if(!initial(organ_typepath.vital)) //I hate this check too. We loop through all the organs the cloned species should have.
					continue //If it's not a vital organ, continue looping through the organs.
				if(initial(organ_typepath.parent_organ) == limb)
					parent_organ_is_limb = TRUE //If it's a vital organ, and belongs to the current limb, we don't want this limb.
					break
			if(parent_organ_is_limb)
				continue
			limbs_to_grow += limb //It's not supposed to be missing and it's not vital - so we'll be growing it.
		limbs_to_grow = shuffle(limbs_to_grow)

	if(clone)
		clone.Weaken(4 SECONDS) //make sure they stay in the pod
		clone.setOxyLoss(0) //..and alive

	//Actually grow clones (this is the fun part of the proc!)
	if(currently_cloning)
		switch(clone_progress)
			if(0 to 10)
				desc_flavor = "You see muscle quickly growing on a ribcage and skull inside [src]."
				clone_progress += speed_modifier
				return
			if(10 to 90)
				clone_progress += speed_modifier
				if(!clone)
					create_clone()
					return

				if(clone.getCloneLoss() >= 25)
					clone.adjustCloneLoss(-2)
					return

				if(!current_limb)
					if(!length(limbs_to_grow)) //if we meet all of the conditions to get here, there's nothing left to do in this section
						desc_flavor = "You see muscle and fat filling out on [clone]'s body."
						return
					for(var/limb_candidate in limbs_to_grow)
						var/obj/item/organ/external/LC = clone.dna.species.has_limbs[limb_candidate]["path"]
						if(initial(LC.parent_organ) in limbs_to_grow)
							continue //If we haven't grown this limb's parent organ yet, we don't want to grow it now.
						current_limb = limb_candidate //If we have grown it, then we're good to grow it now.
						limbs_to_grow -= limb_candidate
						return

				if(!(current_limb in clone.bodyparts))
					if(get_stored_organ(current_limb))
						var/obj/item/organ/external/EO = get_stored_organ(current_limb)
						desc_flavor = "You see [src] attaching \a [EO.name] to [clone]."
						EO.replaced(clone)
						current_limb = null
						clone.adjustCloneLoss(4 / speed_modifier)
						clone.regenerate_icons()
						return

					var/list/EO_path = clone.dna.species.has_limbs[current_limb]["path"]
					var/obj/item/organ/external/EO = new EO_path(clone) //Passing a human to a limb's New() proc automatically attaches it
					desc_flavor = "You see \a [EO.name] growing from [clone]'[clone.p_s()] [EO.amputation_point]."
					current_limb = null
					EO.brute_dam = desired_data.limbs[EO.limb_name][1]
					EO.burn_dam = desired_data.limbs[EO.limb_name][2]
					EO.status = desired_data.limbs[EO.limb_name][3]
					clone.adjustCloneLoss(4 / speed_modifier)
					clone.regenerate_icons()
					return

			if(90 to 100)
				if(length(limbs_to_grow) || current_limb) //This shouldn't happen, but just in case.. (no more feetless clones)
					clone_progress -= 5
				if(eject_clone())
					return
				clone.adjustCloneLoss(-5 * speed_modifier) //rapidly heal clone damage
				desc_flavor = "You see [src] finalizing the cloning process."
				clone_progress += speed_modifier
				return
			if(100 to INFINITY) //this state can be reached with an upgraded cloner
				if(eject_clone())
					return
				clone.setCloneLoss(0) //get out of the pod!!
				return

			else
				clone_progress += 1 // I don't know how we got here but we just keep incrementing

//Clonepod-specific procs
//This just begins the cloning process. Called by the cloning console.
/obj/machinery/clonepod/proc/start_cloning(datum/cloning_data/_patient_data, datum/cloning_data/_desired_data)
	currently_cloning = TRUE
	patient_data = _patient_data
	desired_data = _desired_data

	var/cost = get_cloning_cost(patient_data, desired_data)
	biomass -= cost[BIOMASS_COST]
	reagents.remove_reagent("sanguine_reagent", cost[SANGUINE_COST])
	reagents.remove_reagent("osseous_reagent", cost[OSSEOUS_COST])

	countdown.start()
	update_icon(UPDATE_ICON_STATE)

//Creates the clone! Used once the cloning pod reaches ~10% completion.
/obj/machinery/clonepod/proc/create_clone()
	clone = new /mob/living/carbon/human(src, patient_data.genetic_info.species.type)

	clone.change_dna(patient_data.genetic_info, FALSE)

	for(var/obj/item/organ/external/limb in clone.bodyparts)
		if(!(limb.limb_name in limbs_to_grow)) //if the limb was determined to be vital
			var/active_limb_name = limb.limb_name
			limb.brute_dam = desired_data.limbs[active_limb_name][1]
			limb.burn_dam = desired_data.limbs[active_limb_name][2]
			limb.status = desired_data.limbs[active_limb_name][3]
			continue
		if(length(limb.children)) //This doesn't support having a vital organ inside a child of a limb that itself isn't vital.
			for(var/obj/item/organ/external/child in limb.children) //Future coders, if you want to add a species with its brain in its hand or something, change this
				child.remove(null, TRUE)
				qdel(child)
		limb.remove(null, TRUE)
		qdel(limb)

	for(var/candidate_for_insertion in desired_data.organs)
		var/obj/item/organ/internal/organ = clone.get_int_organ(clone.dna.species.has_organ[candidate_for_insertion])

		if(desired_data.organs[candidate_for_insertion][3]) //if it's desired for the organ to be missing..
			qdel(organ) //make it so
			continue

		if(get_stored_organ(candidate_for_insertion))
			var/obj/item/organ/internal/IO = get_stored_organ(candidate_for_insertion)
			qdel(organ)
			IO.insert(clone) //hotswap
			continue

		if(candidate_for_insertion == "heart")
			continue //The heart is always cloned or replaced, remember? If we're not inserting a new one, we don't need to touch it.

		organ.damage = desired_data.organs[candidate_for_insertion][1]
		organ.status = desired_data.organs[candidate_for_insertion][2]

	clone.updatehealth("droplimb")
	clone.regenerate_icons()

	clone.set_heartattack(FALSE) //you are not allowed to die
	clone.adjustCloneLoss(25) //to punish early ejects
	clone.Weaken(4 SECONDS)
	ADD_TRAIT(clone, TRAIT_NOFIRE, "cloning") // Plasmamen shouldn't catch fire while cloning

//Ejects a clone. The force var ejects even if there's still clone damage.
/obj/machinery/clonepod/proc/eject_clone(force = FALSE)
	if(!currently_cloning)
		return FALSE

	if(!clone && force)
		new /obj/effect/gibspawner/generic(get_turf(src), desired_data.genetic_info)
		playsound(loc, 'sound/effects/splat.ogg', 50, TRUE)
		reset_cloning()
		return TRUE

	if(!clone.getCloneLoss())
		clone.forceMove(loc)
		var/datum/mind/patient_mind = locateUID(patient_data.mindUID)
		patient_mind.transfer_to(clone)
		clone.grab_ghost()
		clone.update_revive()
		REMOVE_TRAIT(clone, TRAIT_NOFIRE, "cloning")
		to_chat(clone, "<span class='userdanger'>You remember nothing from the time that you were dead!</span>")
		to_chat(clone, "<span class='notice'>There's a bright flash of light, and you take your first breath once more.</span>")

		reset_cloning()
		return TRUE

	if(!force)
		return FALSE

	clone.forceMove(loc)
	new /obj/effect/gibspawner/generic(get_turf(src), clone.dna)
	playsound(loc, 'sound/effects/splat.ogg', 50, TRUE)

	var/datum/mind/patient_mind = locateUID(patient_data.mindUID)
	patient_mind.transfer_to(clone)
	clone.grab_ghost()
	clone.update_revive()
	REMOVE_TRAIT(clone, TRAIT_NOFIRE, "cloning")
	to_chat(clone, "<span class='userdanger'>You remember nothing from the time that you were dead!</span>")
	to_chat(clone, "<span class='danger'>You're ripped out of blissful oblivion! You feel like shit.</span>")

	reset_cloning()
	return TRUE

//Helper proc for the above
/obj/machinery/clonepod/proc/reset_cloning()
	currently_cloning = FALSE
	clone = null
	patient_data = null
	desired_data = null
	clone_progress = 0
	desc_flavor = initial(desc_flavor)
	update_icon(UPDATE_ICON_STATE)
	countdown.stop()

//This gets the cost of cloning, in a list with the form (biomass, sanguine reagent, osseous reagent).
/obj/machinery/clonepod/proc/get_cloning_cost(datum/cloning_data/_patient_data, datum/cloning_data/_desired_data)
	var/datum/cloning_data/p_data = _patient_data
	var/datum/cloning_data/d_data = _desired_data
	//Biomass, sanguine reagent, osseous reagent
	var/list/cloning_cost = list((price_modifier * BIOMASS_BASE_COST), 0, 0)

	if(!istype(p_data) || !istype(d_data))
		return //this shouldn't happen but whatever

	for(var/limb in p_data.limbs)

		if(get_stored_organ(limb))
			continue //if we have a stored organ, we'll be replacing it - so no biomass or sanguine/osseous cost

		var/list/patient_limb_info = p_data.limbs[limb]
		var/patient_limb_status = patient_limb_info[3]

		var/list/desired_limb_info = d_data.limbs[limb]
		var/desired_limb_status = desired_limb_info[3]

		if(p_data.limbs[limb][4] && !d_data.limbs[limb][4]) //if the limb is missing on the patient and we want it to not be
			cloning_cost[1] += BIOMASS_NEW_LIMB_COST * price_modifier
			continue //then continue - since we're replacing the limb, we don't need to fix its damages

		if((patient_limb_status & ORGAN_DEAD) && !(desired_limb_status & ORGAN_DEAD)) //if the patient's limb is dead and we don't want it to be
			cloning_cost[1] += BIOMASS_NEW_LIMB_COST * price_modifier
			continue //as above

		var/brute_damage_diff = patient_limb_info[1] - desired_limb_info[1]
		cloning_cost[1] += BIOMASS_BRUTE_COST * brute_damage_diff * price_modifier

		var/burn_damage_diff = patient_limb_info[2] - desired_limb_info[2]
		cloning_cost[1] += BIOMASS_BURN_COST * burn_damage_diff * price_modifier

		if((patient_limb_status & ORGAN_BURNT) && !(desired_limb_status & ORGAN_BURNT)) //if the patient's limb has a burn wound and we don't want it to
			cloning_cost[1] += BIOMASS_BURN_WOUND_COST * price_modifier

		if((patient_limb_status & ORGAN_INT_BLEEDING) && !(desired_limb_status & ORGAN_INT_BLEEDING)) //if the patient's limb has IB and we want it to not be
			cloning_cost[2] += SANGUINE_IB_COST * price_modifier

		if((patient_limb_status & ORGAN_BROKEN) && !(desired_limb_status & ORGAN_BROKEN)) //if the patient's limb is broken and we want it to not be
			cloning_cost[3] += OSSEOUS_BONE_COST * price_modifier

	for(var/organ in p_data.organs)

		if(organ == "heart") //The heart is always replaced in cloning. This is factored into the base biomass cost, so we don't add more here.
			if(get_stored_organ(organ))
				cloning_cost[1] -= BIOMASS_NEW_ORGAN_COST //the cost of a new organ should ALWAYS be below the base cloning cost
			continue

		if(get_stored_organ(organ))
			continue //if we can replace it, we will, so no need to do the rest of the loop

		var/list/patient_organ_info = p_data.organs[organ]
		var/patient_organ_status = patient_organ_info[2]

		var/list/desired_organ_info = d_data.organs[organ]
		var/desired_organ_status = desired_organ_info[2]

		if(patient_organ_info[3] && !desired_organ_info[3]) //If it's missing, and we don't want it to be, replace the organ
			cloning_cost[1] += BIOMASS_NEW_ORGAN_COST * price_modifier
			continue

		if((desired_organ_status & ORGAN_DEAD) && !(patient_organ_status & ORGAN_DEAD)) //if the patient's organ is dead and we want it to not be
			cloning_cost[1] += BIOMASS_NEW_ORGAN_COST * price_modifier
			continue //.. then continue, because if we replace the organ we don't need to fix its damages

		var/organ_damage_diff = patient_organ_info[1] - desired_organ_info[1]
		cloning_cost[1] += BIOMASS_ORGAN_DAMAGE_COST * organ_damage_diff * price_modifier

	cloning_cost[1] = round(cloning_cost[1]) //no decimal-point amounts of biomass!

	return cloning_cost

//insert an organ into storage
/obj/machinery/clonepod/proc/insert_organ(obj/item/organ/inserted, mob/inserter)
	var/has_children = FALSE //Used for arms and legs
	var/stored_organs
	for(var/obj/item/organ/O in contents)
		stored_organs++
	for(var/obj/item/robot_parts/R in contents)
		stored_organs++

	if(stored_organs >= organ_storage_capacity)
		to_chat(inserter, "<span class='warning'>[src]'s organ storage is full!</span>")
		return

	if(is_internal_organ(inserted))
		if(is_type_in_list(inserted, FORBIDDEN_INTERNAL_ORGANS))
			to_chat(inserter, "<span class='warning'>[src] refuses [inserted].</span>")
			return
		if(is_type_in_list(inserted, UPGRADE_LOCKED_ORGANS) && speed_modifier < 4) //if our manipulators aren't fully upgraded
			to_chat(inserter, "<span class='warning'>[src] refuses [inserted].</span>")
			return
		if(inserted.status & ORGAN_ROBOT && speed_modifier == 1) //if our manipulators aren't upgraded at all
			to_chat(inserter, "<span class='warning'>[src] refuses [inserted].</span>")
			return

	if(is_external_organ(inserted))
		if(is_type_in_list(inserted, FORBIDDEN_LIMBS))
			to_chat(inserter, "<span class='warning'>[src] refuses [inserted].</span>")
			return
		var/obj/item/organ/external/EO = inserted
		if(length(EO.children))
			if((stored_organs + 1 + length(EO.children)) > organ_storage_capacity)
				to_chat(inserter, "<span class='warning'>You can't fit all of [inserted] into [src]'s organ storage!</span>")
				return
			has_children = TRUE
			for(var/obj/item/organ/external/child in EO.children)
				child.forceMove(src)
				child.parent = null
				EO.children -= child
				EO.compile_icon()

	if(is_type_in_list(inserted, ALLOWED_ROBOT_PARTS) && speed_modifier == 1) //if our manipulators aren't upgraded at all
		to_chat(inserter, "<span class='warning'>[src] refuses [inserted].</span>")
		return

	if(ismob(inserted.loc))
		var/mob/M = inserted.loc
		if(!M.get_active_hand() == inserted)
			return //not sure how this would happen, but smartfridges check for it so
		if(!M.unequip(inserted))
			to_chat(inserter, "<span class='warning'>[inserted] is stuck to you!</span>")
			return

	inserted.forceMove(src)
	to_chat(inserter, "<span class='notice'>You insert [inserted] into [src]'s organ storage.</span>")
	SStgui.try_update_ui(inserter, src)
	if(has_children)
		visible_message("<span class='notice'>There's a crunching sound as [src] breaks down [inserted] into discrete parts.</span>", "You hear a loud crunch.")

/obj/machinery/clonepod/proc/get_stored_organ(organ)
	for(var/obj/item/organ/external/EO in contents)
		if(EO.limb_name == organ)
			return EO
	for(var/obj/item/organ/internal/IO in contents)
		if(IO.organ_tag == organ)
			return IO
	for(var/obj/item/robot_parts/RP in contents)
		if(organ in RP.part)
			return RP
	return FALSE

/obj/machinery/clonepod/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(used.is_open_container())
		return ..()

	if(istype(used, /obj/item/card/id) || istype(used, /obj/item/pda))
		if(!allowed(user))
			to_chat(user, "<span class='warning'>Access denied.</span>")
			return ITEM_INTERACT_COMPLETE

		switch(tgui_alert(user, "Perform an emergency ejection of [src]?", "Cloning pod", list("Yes", "No")))
			if("Yes")
				eject_clone(TRUE) // GET OUT
				to_chat(user, "<span class='warning'>You force [src] to eject its clone!</span>")
				log_admin("[key_name(user)] has activated a cloning pod's emergency eject at [COORD(src)] (clone: [key_name(clone)])")
		return ITEM_INTERACT_COMPLETE

	if(is_organ(used) || is_type_in_list(used, ALLOWED_ROBOT_PARTS)) //fun fact, robot parts aren't organs!
		insert_organ(used, user)
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/clonepod/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	default_deconstruction_crowbar(user, I)

/obj/machinery/clonepod/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!I.multitool_check_buffer(user))
		return
	var/obj/item/multitool/M = I
	M.set_multitool_buffer(user, src)

/obj/machinery/clonepod/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	default_deconstruction_screwdriver(user, null, null, I)
	update_icon()

/obj/machinery/clonepod/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(anchored)
		WRENCH_UNANCHOR_MESSAGE
		anchored = FALSE
	else
		WRENCH_ANCHOR_MESSAGE
		anchored = TRUE

/obj/machinery/clonepod/attack_hand(mob/user)
	. = ..()
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return

	ui_interact(user)

/obj/machinery/clonepod/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/clonepod/attack_ghost(mob/user)
	return attack_hand(user)

/obj/machinery/clonepod/emag_act(user)
	. = ..()
	malfunction()
	return TRUE

/obj/machinery/clonepod/emp_act(severity)
	if(prob(100 / (severity * emp_resistance)))
		malfunction()
	return ..()

/obj/machinery/clonepod/proc/malfunction()
	if(clone)
		var/datum/mind/patient_mind = locateUID(patient_data.mindUID)
		if(istype(patient_mind, /datum/mind))
			patient_mind.transfer_to(clone)
			clone.grab_ghost()
			to_chat(clone, "<span class='warning'><b>Agony blazes across your consciousness as your body is torn apart.</b>\
			<br><i>Is this what dying is like? Yes it is.</i></span>")
			SEND_SOUND(clone, sound('sound/hallucinations/veryfar_noise.ogg', 0, TRUE, 50))
		sleep(40)
		new /obj/effect/gibspawner/generic(get_turf(src), clone.dna)
		new /obj/effect/gibspawner/generic(get_turf(src), clone.dna)
		new /obj/effect/gibspawner/generic(get_turf(src), clone.dna)
		playsound(loc, 'sound/effects/splat.ogg', 50, TRUE)
		qdel(clone)
		reset_cloning()

	playsound(loc, 'sound/machines/warning-buzzer.ogg', 50, FALSE)
	update_icon()


//TGUI
/obj/machinery/clonepod/ui_interact(mob/user, datum/tgui/ui = null)
	if(stat & (NOPOWER|BROKEN))
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CloningPod", "Cloning Pod")
		ui.open()

/obj/machinery/clonepod/ui_data(mob/user)
	var/list/data = list()
	data["biomass"] = biomass
	data["biomass_storage_capacity"] = biomass_storage_capacity
	data["sanguine_reagent"] = reagents.get_reagent_amount("sanguine_reagent")
	data["osseous_reagent"] = reagents.get_reagent_amount("osseous_reagent")

	var/list/organs_list
	for(var/obj/item/organ/O in contents)
		organs_list += list(list("name" = O.name, "ref" = O.UID()))

	for(var/obj/item/robot_parts/RP in contents)
		organs_list += list(list("name" = RP.name, "ref" = RP.UID()))

	data["organs"] = organs_list
	data["currently_cloning"] = currently_cloning

	return data

/obj/machinery/clonepod/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	switch(action)
		if("eject_organ")
			var/obj/item/organ/O = locateUID(params["organ_ref"])
			if(!istype(O) || !O.in_contents_of(src)) //This shouldn't happen BUT JUST IN CASE
				return FALSE
			if(!ui.user.put_in_hands(O))
				O.forceMove(loc)
			return TRUE
		if("purge_reagent")
			if(params["reagent"])
				reagents.del_reagent(params["reagent"])
			return TRUE
		if("remove_reagent")
			if(params["reagent"])
				reagents.remove_reagent(params["reagent"], params["amount"])
			return TRUE

	update_icon()

//Icon stuff
/obj/machinery/clonepod/update_icon_state()
	if(currently_cloning && !(stat & NOPOWER))
		icon_state = "pod_cloning"
	else
		icon_state = "pod_idle"

/obj/machinery/clonepod/update_overlays()
	. = ..()
	if(panel_open)
		. += "panel_open"

#undef VALID_REAGENTS
#undef VALID_BIOMASSABLES
#undef FORBIDDEN_INTERNAL_ORGANS
#undef UPGRADE_LOCKED_ORGANS
#undef FORBIDDEN_LIMBS
#undef ALLOWED_ROBOT_PARTS

#undef BIOMASS_BASE_COST
#undef MEAT_BIOMASS_VALUE
#undef BIOMASS_NEW_LIMB_COST
#undef BIOMASS_NEW_ORGAN_COST
#undef BIOMASS_BURN_WOUND_COST
#undef BIOMASS_BRUTE_COST
#undef BIOMASS_BURN_COST
#undef BIOMASS_ORGAN_DAMAGE_COST
#undef SANGUINE_IB_COST
#undef OSSEOUS_BONE_COST
