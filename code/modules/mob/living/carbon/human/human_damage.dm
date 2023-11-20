//Updates the mob's health from organs and mob damage variables
/mob/living/carbon/human/updatehealth(reason = "none given")
	if(status_flags & GODMODE)
		health = maxHealth
		set_stat(CONSCIOUS)
		return

	var/total_limb_damage = 0

	for(var/obj/item/organ/external/O in bodyparts) /// sums up all the damage of all the limbs
		total_limb_damage += O.get_damage()

	health = maxHealth - getOxyLoss() - getToxLoss() - getCloneLoss() - total_limb_damage

	update_stat("updatehealth([reason])")
	med_hud_set_health()

/mob/living/carbon/human/adjustBrainLoss(amount, updating = TRUE, use_brain_mod = TRUE)
	if(status_flags & GODMODE)
		return STATUS_UPDATE_NONE	//godmode

	if(dna.species && dna.species.has_organ["brain"])
		var/obj/item/organ/internal/brain/sponge = get_int_organ(/obj/item/organ/internal/brain)
		if(sponge)
			if(dna.species && amount > 0)
				if(use_brain_mod)
					amount *= dna.species.brain_mod
			sponge.damage = clamp(sponge.damage + amount, 0, 120)
			if(sponge.damage >= 120)
				death()
	if(updating)
		update_stat("adjustBrainLoss")
	return STATUS_UPDATE_STAT

/mob/living/carbon/human/setBrainLoss(amount, updating = TRUE, use_brain_mod = TRUE)
	if(status_flags & GODMODE)
		return STATUS_UPDATE_NONE	//godmode

	if(dna.species && dna.species.has_organ["brain"])
		var/obj/item/organ/internal/brain/sponge = get_int_organ(/obj/item/organ/internal/brain)
		if(sponge)
			if(dna.species && amount > 0)
				if(use_brain_mod)
					amount *= dna.species.brain_mod
			sponge.damage = clamp(amount, 0, 120)
			if(sponge.damage >= 120)
				death()
	if(updating)
		update_stat("setBrainLoss")
	return STATUS_UPDATE_STAT

/mob/living/carbon/human/getBrainLoss()
	if(status_flags & GODMODE)
		return 0	//godmode

	if(dna.species && dna.species.has_organ["brain"])
		var/obj/item/organ/internal/brain/sponge = get_int_organ(/obj/item/organ/internal/brain)
		if(sponge)
			return min(sponge.damage,maxHealth*2)
		else
			if(ischangeling(src))
				// if a changeling has no brain, they have no brain damage.
				return 0

			return 200
	else
		return 0

//These procs fetch a cumulative total damage from all organs
/mob/living/carbon/human/getBruteLoss()
	var/amount = 0
	for(var/obj/item/organ/external/O in bodyparts)
		amount += O.brute_dam
	return amount

/mob/living/carbon/human/getFireLoss()
	var/amount = 0
	for(var/obj/item/organ/external/O in bodyparts)
		amount += O.burn_dam
	return amount

/mob/living/carbon/human/adjustBruteLoss(amount, updating_health = TRUE, damage_source = null, robotic = FALSE)
	if(amount > 0)
		if(dna.species)
			amount *= dna.species.brute_mod
		take_overall_damage(amount, 0, updating_health, used_weapon = damage_source)
	else
		heal_overall_damage(-amount, 0, updating_health, FALSE, robotic)
	// brainless default for now
	return STATUS_UPDATE_HEALTH

/mob/living/carbon/human/adjustFireLoss(amount, updating_health = TRUE, damage_source = null, robotic = FALSE)
	if(amount > 0)
		if(dna.species)
			amount *= dna.species.burn_mod
		take_overall_damage(0, amount, updating_health, used_weapon = damage_source)
	else
		heal_overall_damage(0, -amount, updating_health, FALSE, robotic)

	if(((maxHealth - getFireLoss()) < HEALTH_THRESHOLD_DEAD * 2) && stat == DEAD)
		become_husk(BURN)
	// brainless default for now
	return STATUS_UPDATE_HEALTH

/mob/living/carbon/human/proc/adjustBruteLossByPart(amount, organ_name, obj/damage_source = null, updating_health = TRUE)
	if(dna.species && amount > 0)
		amount *= dna.species.brute_mod

	if(organ_name in bodyparts_by_name)
		var/obj/item/organ/external/O = get_organ(organ_name)

		if(amount > 0)
			O.receive_damage(amount, 0, sharp=is_sharp(damage_source), used_weapon=damage_source, forbidden_limbs = list(), ignore_resists=FALSE, updating_health=updating_health)
		else
			//if you don't want to heal robot organs, they you will have to check that yourself before using this proc.
			O.heal_damage(-amount, 0, internal = 0, robo_repair = O.is_robotic(), updating_health = updating_health)
	return STATUS_UPDATE_HEALTH

/mob/living/carbon/human/proc/adjustFireLossByPart(amount, organ_name, obj/damage_source = null, updating_health = TRUE)
	if(dna.species && amount > 0)
		amount *= dna.species.burn_mod

	if(organ_name in bodyparts_by_name)
		var/obj/item/organ/external/O = get_organ(organ_name)

		if(amount > 0)
			O.receive_damage(0, amount, sharp=is_sharp(damage_source), used_weapon=damage_source, forbidden_limbs = list(), ignore_resists = FALSE, updating_health = updating_health)
		else
			//if you don't want to heal robot organs, they you will have to check that yourself before using this proc.
			O.heal_damage(0, -amount, internal = 0, robo_repair = O.is_robotic(), updating_health = updating_health)
	return STATUS_UPDATE_HEALTH

/mob/living/carbon/human/proc/unmutateAllBodyparts()
	for(var/obj/item/organ/external/O in bodyparts)
		if(O.status & ORGAN_MUTATED)
			O.unmutate()
			to_chat(src, "<span class='notice'>Your [O.name] is shaped normally again.</span>")

/mob/living/carbon/human/adjustCloneLoss(amount)
	if(dna.species && amount > 0)
		amount *= dna.species.clone_mod
	. = ..()

	if(!amount)
		return

	var/mut_prob = min(80, getCloneLoss() + 10)
	var/heal_prob = max(0, 80 - getCloneLoss())

	if(!getCloneLoss()) // All cloneloss was purged - fix all organs
		unmutateAllBodyparts()
		return

	if(amount > 0) // Cloneloss was inflicted - chance to mutate an organ
		if(!prob(mut_prob))
			return

		var/list/candidates = list()
		for(var/obj/item/organ/external/O in bodyparts)
			if(!O.is_robotic() && !(O.status & ORGAN_MUTATED))
				candidates |= O

		if(length(candidates))
			var/obj/item/organ/external/O = pick(candidates)
			O.mutate()
			to_chat(src, "<span class='notice'>Something is not right with your [O.name]...</span>")
			O.add_autopsy_data("Mutation", amount)
	else // Cloneloss was partially healed - chance to unmutate an organ
		if(!prob(heal_prob))
			return

		for(var/obj/item/organ/external/O in bodyparts)
			if(O.status & ORGAN_MUTATED)
				O.unmutate()
				to_chat(src, "<span class='notice'>Your [O.name] is shaped normally again.</span>")
				return

/mob/living/carbon/human/setCloneLoss(amount)
	if(dna.species && amount > 0)
		amount *= dna.species.clone_mod
	. = ..()

	if(!amount) // Cloneloss was set to 0 - fix all organs
		unmutateAllBodyparts()

// Defined here solely to take species flags into account without having to recast at mob/living level.
/mob/living/carbon/human/adjustOxyLoss(amount)
	if(dna.species && amount > 0)
		amount *= dna.species.oxy_mod
	. = ..()

/mob/living/carbon/human/setOxyLoss(amount)
	if(dna.species && amount > 0)
		amount *= dna.species.oxy_mod
	. = ..()

/mob/living/carbon/human/adjustToxLoss(amount)
	if(dna.species && amount > 0)
		amount *= dna.species.tox_mod
	. = ..()

/mob/living/carbon/human/setToxLoss(amount)
	if(dna.species && amount > 0)
		amount *= dna.species.tox_mod
	. = ..()

/mob/living/carbon/human/adjustStaminaLoss(amount, updating = TRUE)
	if(dna.species && amount > 0)
		amount *= dna.species.stamina_mod
	. = ..()

/mob/living/carbon/human/setStaminaLoss(amount, updating = TRUE)
	if(dna.species && amount > 0)
		amount *= dna.species.stamina_mod
	. = ..()

////////////////////////////////////////////

//Returns a list of damaged organs
/mob/living/carbon/human/proc/get_damaged_organs(brute, burn, flags = AFFECT_ALL_ORGANS)
	var/list/obj/item/organ/external/parts = list()
	for(var/obj/item/organ/external/O in bodyparts)
		if((brute && O.brute_dam) || (burn && O.burn_dam))
			if(!(flags & AFFECT_ROBOTIC_ORGAN) && O.is_robotic())
				continue
			if(!(flags & AFFECT_ORGANIC_ORGAN) && !O.is_robotic())
				continue
			parts += O
	return parts

//Returns a list of damageable organs
/mob/living/carbon/human/proc/get_damageable_organs()
	var/list/obj/item/organ/external/parts = list()
	for(var/obj/item/organ/external/O in bodyparts)
		if(O.brute_dam + O.burn_dam < O.max_damage)
			parts += O
	return parts

//Heals ONE external organ, organ gets randomly selected from damaged ones.
//It automatically updates damage overlays if necesary
//It automatically updates health status
/mob/living/carbon/human/heal_organ_damage(brute, burn, updating_health = TRUE)
	var/list/obj/item/organ/external/parts = get_damaged_organs(brute,burn)
	if(!parts.len)
		return
	var/obj/item/organ/external/picked = pick(parts)
	if(picked.heal_damage(brute,burn, updating_health))
		UpdateDamageIcon()

//Damages ONE external organ, organ gets randomly selected from damagable ones.
//It automatically updates damage overlays if necesary
//It automatically updates health status
/mob/living/carbon/human/take_organ_damage(brute, burn, updating_health = TRUE, sharp = FALSE, edge = 0)
	var/list/obj/item/organ/external/parts = get_damageable_organs()
	if(!parts.len)
		return
	var/obj/item/organ/external/picked = pick(parts)
	if(picked.receive_damage(brute, burn, sharp, updating_health))
		UpdateDamageIcon()


//Heal MANY external organs, in random order
/mob/living/carbon/human/heal_overall_damage(brute, burn, updating_health = TRUE, internal=0, robotic=0)
	var/list/obj/item/organ/external/parts = get_damaged_organs(brute,burn)

	var/update = 0
	while(parts.len && ( brute > 0 || burn > 0))
		var/obj/item/organ/external/picked = pick(parts)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam

		update |= picked.heal_damage(brute,burn, internal, robotic, updating_health = FALSE)

		brute -= (brute_was-picked.brute_dam)
		burn -= (burn_was-picked.burn_dam)

		parts -= picked

	if(updating_health)
		updatehealth("heal overall damage")
	if(update)
		UpdateDamageIcon()

// damage MANY external organs, in random order
/mob/living/carbon/human/take_overall_damage(brute, burn, updating_health = TRUE, used_weapon = null, sharp = FALSE, edge = 0)
	if(status_flags & GODMODE)
		return	//godmode
	var/list/obj/item/organ/external/parts = get_damageable_organs()

	var/update = 0
	while(parts.len && (brute>0 || burn>0))
		var/obj/item/organ/external/picked = pick(parts)
		var/brute_per_part = brute/parts.len
		var/burn_per_part = burn/parts.len

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam


		update |= picked.receive_damage(brute_per_part, burn_per_part, sharp, used_weapon, list(), FALSE, FALSE)

		brute	-= (picked.brute_dam - brute_was)
		burn	-= (picked.burn_dam - burn_was)

		parts -= picked

	if(updating_health)
		updatehealth("take overall damage")

	if(update)
		UpdateDamageIcon()


////////////////////////////////////////////

/*
This function restores all organs.
*/
/mob/living/carbon/human/restore_all_organs()
	for(var/obj/item/organ/external/current_organ in bodyparts)
		current_organ.rejuvenate()
		current_organ.add_limb_flags()

/mob/living/carbon/human/proc/HealDamage(zone, brute, burn)
	var/obj/item/organ/external/E = get_organ(zone)
	if(isorgan(E))
		if(E.heal_damage(brute, burn))
			UpdateDamageIcon()
	else
		return 0


/mob/living/carbon/human/get_organ(zone)
	if(!zone)
		zone = "chest"
	if(zone in list("eyes", "mouth"))
		zone = "head"

	return bodyparts_by_name[zone]

/mob/living/carbon/human/apply_damage(damage = 0, damagetype = BRUTE, def_zone, blocked = 0, sharp = FALSE, obj/used_weapon, spread_damage = FALSE)
	return dna.species.apply_damage(damage, damagetype, def_zone, blocked, src, sharp, used_weapon, spread_damage)
