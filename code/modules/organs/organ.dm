var/list/organ_cache = list()

/obj/item/organ
	name = "organ"
	icon = 'icons/obj/surgery.dmi'
	var/dead_icon
	var/mob/living/carbon/human/owner = null
	var/status = 0
	var/vital //Lose a vital limb, die immediately.
	var/damage = 0 // amount of damage to the organ

	var/min_bruised_damage = 10
	var/min_broken_damage = 30
	var/max_damage
	var/organ_tag = "organ"

	var/parent_organ = "chest"
	var/robotic = 0 //For being a robot

	var/list/datum/autopsy_data/autopsy_data = list()
	var/list/trace_chemicals = list() // traces of chemicals in the organ,
									  // links chemical IDs to number of ticks for which they'll stay in the blood
	germ_level = 0
	var/datum/dna/dna
	var/datum/species/species

/obj/item/organ/Destroy()
	if(!owner)
		return ..()

	if(istype(owner, /mob/living/carbon))
		if((owner.internal_organs) && (src in owner.internal_organs))
			owner.internal_organs -= src
		if(istype(owner, /mob/living/carbon/human))
			if((owner.internal_organs_by_name) && (src in owner.internal_organs_by_name))
				owner.internal_organs_by_name -= src
			if((owner.organs) && (src in owner.organs))
				owner.organs -= src
			if((owner.organs_by_name) && (src in owner.organs_by_name))
				owner.organs_by_name -= src
	if(src in owner.contents)
		owner.contents -= src

	return ..()

/obj/item/organ/attack_self(mob/user as mob)

	// Convert it to an edible form, yum yum.
	if(!robotic && user.a_intent == I_HARM)
		bitten(user)
		return

/obj/item/organ/proc/update_health()
	return

/obj/item/organ/New(var/mob/living/carbon/holder, var/internal)
	..(holder)
	create_reagents(5)
	if(!max_damage)
		max_damage = min_broken_damage * 2
	if(istype(holder))
		src.owner = holder
		species = all_species["Human"]
		if(holder.dna)
			dna = holder.dna.Clone()
			species = all_species[dna.species]
		else
			log_to_dd("[src] at [loc] spawned without a proper DNA.")
		var/mob/living/carbon/human/H = holder
		if(istype(H))
			if(internal)
				var/obj/item/organ/external/E = H.organs_by_name[src.parent_organ]
				if(E)
					if(E.internal_organs == null)
						E.internal_organs = list()
					E.internal_organs |= src
			if(dna)
				if(!blood_DNA)
					blood_DNA = list()
				blood_DNA[dna.unique_enzymes] = dna.b_type
		if(internal)
			holder.internal_organs |= src

/obj/item/organ/proc/set_dna(var/datum/dna/new_dna)
	if(new_dna)
		dna = new_dna.Clone()
		blood_DNA.Cut()
		blood_DNA[dna.unique_enzymes] = dna.b_type

/obj/item/organ/proc/die()
	if(status & ORGAN_ROBOT)
		return
	damage = max_damage
	status |= ORGAN_DEAD
	processing_objects -= src
	if(dead_icon)
		icon_state = dead_icon
	if(owner && vital)
		owner.death()

/obj/item/organ/process()
	if(loc != owner)
		owner = null

	//dead already, no need for more processing
	if(status & ORGAN_DEAD)
		return

	// Don't process if we're in a freezer, an MMI or a stasis bag. //TODO: ambient temperature?
	if(istype(loc,/obj/item/device/mmi) || istype(loc,/obj/item/bodybag/cryobag) || istype(loc,/obj/structure/closet/crate/freezer))
		return

	//Process infections
	if ((status & ORGAN_ROBOT) || (owner && owner.species && (owner.species.flags & IS_PLANT)))
		germ_level = 0
		return

	if(!owner)
		if(reagents)
			var/datum/reagent/blood/B = locate(/datum/reagent/blood) in reagents.reagent_list
			if(B && prob(40))
				reagents.remove_reagent("blood",0.1)
				blood_splatter(src,B,1)

		germ_level += rand(2,6)
		if(germ_level >= INFECTION_LEVEL_TWO)
			germ_level += rand(2,6)
		if(germ_level >= INFECTION_LEVEL_THREE)
			die()

		if(damage >= max_damage)
			die()

	else if(owner.bodytemperature >= 170)	//cryo stops germs from moving and doing their bad stuffs
		//** Handle antibiotics and curing infections
		handle_antibiotics()
		handle_germ_effects()

	//check if we've hit max_damage
	if(damage >= max_damage)
		die()

/obj/item/organ/examine(mob/user)
	..(user)
	if(status & ORGAN_DEAD)
		user << "<span class='notice'>The decay has set in.</span>"

/obj/item/organ/proc/handle_germ_effects()
	//** Handle the effects of infections
	var/antibiotics = owner.reagents.get_reagent_amount("spaceacillin")

	if (germ_level > 0 && germ_level < INFECTION_LEVEL_ONE/2 && prob(30))
		germ_level--

	if (germ_level >= INFECTION_LEVEL_ONE/2)
		//aiming for germ level to go from ambient to INFECTION_LEVEL_TWO in an average of 15 minutes
		if(antibiotics < 5 && prob(round(germ_level/6)))
			germ_level++

	if(germ_level >= INFECTION_LEVEL_ONE)
		var/fever_temperature = (owner.species.heat_level_1 - owner.species.body_temperature - 5)* min(germ_level/INFECTION_LEVEL_TWO, 1) + owner.species.body_temperature
		owner.bodytemperature += between(0, (fever_temperature - T20C)/BODYTEMP_COLD_DIVISOR + 1, fever_temperature - owner.bodytemperature)

	if (germ_level >= INFECTION_LEVEL_TWO)
		var/obj/item/organ/external/parent = owner.get_organ(parent_organ)
		//spread germs
		if (antibiotics < 5 && parent.germ_level < germ_level && ( parent.germ_level < INFECTION_LEVEL_ONE*2 || prob(30) ))
			parent.germ_level++

		if (prob(3))	//about once every 30 seconds
			take_damage(1,silent=prob(30))

/obj/item/organ/proc/receive_chem(chemical as obj)
	return 0

/obj/item/organ/proc/rejuvenate()
	damage = 0

/obj/item/organ/proc/is_damaged()
	return damage > 0

/obj/item/organ/proc/is_bruised()
	return damage >= min_bruised_damage

/obj/item/organ/proc/is_broken()
	return (damage >= min_broken_damage || (status & ORGAN_CUT_AWAY) || ((status & ORGAN_BROKEN) && !(status & ORGAN_SPLINTED)))

//Germs
/obj/item/organ/proc/handle_antibiotics()
	var/antibiotics = owner.reagents.get_reagent_amount("spaceacillin")

	if (!germ_level || antibiotics < 5)
		return

	if (germ_level < INFECTION_LEVEL_ONE)
		germ_level = 0	//cure instantly
	else if (germ_level < INFECTION_LEVEL_TWO)
		germ_level -= 6	//at germ_level == 500, this should cure the infection in a minute
	else
		germ_level -= 2 //at germ_level == 1000, this will cure the infection in 5 minutes

//Adds autopsy data for used_weapon.
/obj/item/organ/proc/add_autopsy_data(var/used_weapon, var/damage)
	var/datum/autopsy_data/W = autopsy_data[used_weapon]
	if(!W)
		W = new()
		W.weapon = used_weapon
		autopsy_data[used_weapon] = W

	W.hits += 1
	W.damage += damage
	W.time_inflicted = world.time

//Note: external organs have their own version of this proc
/obj/item/organ/proc/take_damage(amount, var/silent=0)
	if(src.status & ORGAN_ROBOT)
		src.damage = between(0, src.damage + (amount * 0.8), max_damage)
	else
		src.damage = between(0, src.damage + amount, max_damage)

		//only show this if the organ is not robotic
		if(owner && parent_organ && amount > 0)
			var/obj/item/organ/external/parent = owner.get_organ(parent_organ)
			if(parent && !silent)
				owner.custom_pain("Something inside your [parent.name] hurts a lot.", 1)

/obj/item/organ/proc/robotize() //Being used to make robutt hearts, etc
	robotic = 2
	src.status &= ~ORGAN_BROKEN
	src.status &= ~ORGAN_BLEEDING
	src.status &= ~ORGAN_SPLINTED
	src.status &= ~ORGAN_CUT_AWAY
	src.status &= ~ORGAN_ATTACHABLE
	src.status &= ~ORGAN_DESTROYED
	src.status |= ORGAN_ROBOT
	src.status |= ORGAN_ASSISTED

/obj/item/organ/proc/mechassist() //Used to add things like pacemakers, etc
	robotize()
	src.status &= ~ORGAN_ROBOT
	robotic = 1
	min_bruised_damage = 15
	min_broken_damage = 35

/obj/item/organ/emp_act(severity)
	if(!(status & ORGAN_ROBOT))
		return
	switch (severity)
		if (1.0)
			take_damage(0,20)
			return
		if (2.0)
			take_damage(0,7)
			return
		if(3.0)
			take_damage(0,3)

/obj/item/organ/proc/removed(var/mob/living/user)

	if(!istype(owner))
		return

	owner.internal_organs_by_name[organ_tag] = null
	owner.internal_organs_by_name -= organ_tag
	owner.internal_organs_by_name -= null
	owner.internal_organs -= src

	var/obj/item/organ/external/affected = owner.get_organ(parent_organ)
	if(affected) affected.internal_organs -= src

	loc = get_turf(owner)
	processing_objects |= src
	var/datum/reagent/blood/organ_blood
	if(reagents) organ_blood = locate(/datum/reagent/blood) in reagents.reagent_list
	if(!organ_blood || !organ_blood.data["blood_DNA"])
		owner.vessel.trans_to(src, 5, 1, 1)

	if(owner && vital)
		if(user)
			user.attack_log += "\[[time_stamp()]\]<font color='red'> removed a vital organ ([src]) from [key_name(owner)] (INTENT: [uppertext(user.a_intent)])</font>"
			owner.attack_log += "\[[time_stamp()]\]<font color='orange'> had a vital organ ([src]) removed by [key_name(user)] (INTENT: [uppertext(user.a_intent)])</font>"
			msg_admin_attack("[key_name_admin(user)] removed a vital organ ([src]) from [key_name_admin(owner)]")
		owner.death()
	owner = null

/obj/item/organ/proc/replaced(var/mob/living/carbon/human/target,var/obj/item/organ/external/affected)

	if(!istype(target)) return

	owner = target
	processing_objects -= src
	target.internal_organs |= src
	affected.internal_organs |= src
	target.internal_organs_by_name[organ_tag] = src
	src.loc = target
	if(robotic)
		status |= ORGAN_ROBOT

/obj/item/organ/eyes/replaced(var/mob/living/carbon/human/target)

	// Apply our eye colour to the target.
	if(istype(target) && eye_colour)
		target.r_eyes = eye_colour[1]
		target.g_eyes = eye_colour[2]
		target.b_eyes = eye_colour[3]
		target.update_eyes()
	..()

/obj/item/organ/proc/bitten(mob/user)

	if(robotic)
		return

	user << "\blue You take a bite out of \the [src]."

	user.unEquip(src)
	var/obj/item/weapon/reagent_containers/food/snacks/organ/O = new(get_turf(src))
	O.name = name
	O.icon_state = dead_icon ? dead_icon : icon_state

	if(fingerprints) O.fingerprints = fingerprints.Copy()
	if(fingerprintshidden) O.fingerprintshidden = fingerprintshidden.Copy()
	if(fingerprintslast) O.fingerprintslast = fingerprintslast

	user.put_in_active_hand(O)
	qdel(src)