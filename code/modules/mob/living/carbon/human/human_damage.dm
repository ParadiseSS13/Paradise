//Updates the mob's health from organs and mob damage variables
/mob/living/carbon/human/updatehealth()
	if(status_flags & GODMODE)
		health = maxHealth
		stat = CONSCIOUS
		return

	var/total_burn  = 0
	var/total_brute = 0

	for(var/obj/item/organ/external/O in organs)	//hardcoded to streamline things a bit
		total_brute += O.brute_dam //calculates health based on organ brute and burn
		total_burn += O.burn_dam

	health = maxHealth - getOxyLoss() - getToxLoss() - getCloneLoss() - total_burn - total_brute

	//TODO: fix husking
	if(((maxHealth - total_burn) < config.health_threshold_dead) && stat == DEAD)
		ChangeToHusk()
	if(species.can_revive_by_healing)
		var/obj/item/organ/internal/brain/B = get_int_organ(/obj/item/organ/internal/brain)
		if(B)
			if((health >= (config.health_threshold_dead + config.health_threshold_crit) * 0.5) && stat == DEAD && getBrainLoss()<120)
				update_revive()
	if(stat == CONSCIOUS && (src in dead_mob_list)) //Defib fix
		update_revive()
	med_hud_set_health()
	med_hud_set_status()
	handle_hud_icons()

/mob/living/carbon/human/adjustBrainLoss(var/amount)
	if(status_flags & GODMODE)
		return 0	//godmode

	if(species && species.has_organ["brain"])
		var/obj/item/organ/internal/brain/sponge = get_int_organ(/obj/item/organ/internal/brain)
		if(sponge)
			sponge.take_damage(amount, 1)
			brainloss = sponge.damage
		else
			brainloss = 200
	else
		brainloss = 0

/mob/living/carbon/human/setBrainLoss(var/amount)
	if(status_flags & GODMODE)
		return 0	//godmode

	if(species && species.has_organ["brain"])
		var/obj/item/organ/internal/brain/sponge = get_int_organ(/obj/item/organ/internal/brain)
		if(sponge)
			sponge.damage = min(max(amount, 0),(maxHealth*2))
			brainloss = sponge.damage
		else
			brainloss = 200
	else
		brainloss = 0

/mob/living/carbon/human/getBrainLoss()
	if(status_flags & GODMODE)
		return 0	//godmode

	if(species && species.has_organ["brain"])
		var/obj/item/organ/internal/brain/sponge = get_int_organ(/obj/item/organ/internal/brain)
		if(sponge)
			brainloss = min(sponge.damage,maxHealth*2)
		else
			brainloss = 200
	else
		brainloss = 0
	return brainloss

//These procs fetch a cumulative total damage from all organs
/mob/living/carbon/human/getBruteLoss()
	var/amount = 0
	for(var/obj/item/organ/external/O in organs)
		amount += O.brute_dam
	return amount

/mob/living/carbon/human/getFireLoss()
	var/amount = 0
	for(var/obj/item/organ/external/O in organs)
		amount += O.burn_dam
	return amount


/mob/living/carbon/human/adjustBruteLoss(var/amount)
	if(species && species.brute_mod)
		amount = amount*species.brute_mod
	if(amount > 0)
		take_overall_damage(amount, 0)
	else
		heal_overall_damage(-amount, 0)

/mob/living/carbon/human/adjustFireLoss(var/amount)
	if(species && species.burn_mod)
		amount = amount*species.burn_mod
	if(amount > 0)
		take_overall_damage(0, amount)
	else
		heal_overall_damage(0, -amount)

/mob/living/carbon/human/proc/adjustBruteLossByPart(var/amount, var/organ_name, var/obj/damage_source = null)
	if(species && species.brute_mod)
		amount = amount*species.brute_mod

	if(organ_name in organs_by_name)
		var/obj/item/organ/external/O = get_organ(organ_name)

		if(amount > 0)
			O.take_damage(amount, 0, sharp=is_sharp(damage_source), edge=has_edge(damage_source), used_weapon=damage_source)
		else
			//if you don't want to heal robot organs, they you will have to check that yourself before using this proc.
			O.heal_damage(-amount, 0, internal=0, robo_repair=(O.status & ORGAN_ROBOT))


/mob/living/carbon/human/proc/adjustFireLossByPart(var/amount, var/organ_name, var/obj/damage_source = null)
	if(species && species.burn_mod)
		amount = amount*species.burn_mod

	if(organ_name in organs_by_name)
		var/obj/item/organ/external/O = get_organ(organ_name)

		if(amount > 0)
			O.take_damage(0, amount, sharp=is_sharp(damage_source), edge=has_edge(damage_source), used_weapon=damage_source)
		else
			//if you don't want to heal robot organs, they you will have to check that yourself before using this proc.
			O.heal_damage(0, -amount, internal=0, robo_repair=(O.status & ORGAN_ROBOT))


/mob/living/carbon/human/Paralyse(amount)
	// Notify our AI if they can now control the suit.
	if(wearing_rig && !stat && paralysis < amount) //We are passing out right this second.
		wearing_rig.notify_ai("<span class='danger'>Warning: user consciousness failure. Mobility control passed to integrated intelligence system.</span>")
	..()

/mob/living/carbon/human/adjustCloneLoss(var/amount)
	..()

	if(species.flags & (NO_DNA))
		cloneloss = 0
		return

	var/heal_prob = max(0, 80 - getCloneLoss())
	var/mut_prob = min(80, getCloneLoss() + 10)
	if(amount > 0) //cloneloss is being added
		if(prob(mut_prob))
			var/list/obj/item/organ/external/candidates = list() //TYPECASTED LISTS ARE NOT A FUCKING THING WHAT THE FUCK
			for(var/obj/item/organ/external/O in organs)
				if(O.status & ORGAN_ROBOT)
					continue
				if(!(O.status & ORGAN_MUTATED))
					candidates |= O

			if(candidates.len)
				var/obj/item/organ/external/O = pick(candidates)
				O.mutate()
				to_chat(src, "<span class='notice'>Something is not right with your [O.name]...</span>")
				O.add_autopsy_data("Mutation", amount)
				return

	else //cloneloss is being subtracted
		if(prob(heal_prob))
			for(var/obj/item/organ/external/O in organs)
				if(O.status & ORGAN_MUTATED)
					O.unmutate()
					to_chat(src, "<span class='notice'>Your [O.name] is shaped normally again.</span>")
					return


	if(getCloneLoss() < 1) //no cloneloss, fixes organs
		for(var/obj/item/organ/external/O in organs)
			if(O.status & ORGAN_MUTATED)
				O.unmutate()
				to_chat(src, "<span class='notice'>Your [O.name] is shaped normally again.</span>")


// Defined here solely to take species flags into account without having to recast at mob/living level.
/mob/living/carbon/human/getOxyLoss()
	if(species.flags & NO_BREATHE)
		oxyloss = 0
	return ..()

/mob/living/carbon/human/adjustOxyLoss(var/amount)
	if(species.flags & NO_BREATHE)
		oxyloss = 0
	else
		..()

/mob/living/carbon/human/setOxyLoss(var/amount)
	if(species.flags & NO_BREATHE)
		oxyloss = 0 //this literally overrides three procs, excessive much?
	else
		..()

/mob/living/carbon/human/getToxLoss()
	if(species.flags & NO_POISON)
		toxloss = 0
	return ..()

/mob/living/carbon/human/adjustToxLoss(var/amount)
	if(species.flags & NO_POISON)
		toxloss = 0
	else
		..()

/mob/living/carbon/human/setToxLoss(var/amount)
	if(species.flags & NO_POISON)
		toxloss = 0 //this *also* overrides three procs, definately excessive
	else
		..()

////////////////////////////////////////////

//Returns a list of damaged organs
/mob/living/carbon/human/proc/get_damaged_organs(var/brute, var/burn, var/flags = AFFECT_ALL_ORGANS)
	var/list/obj/item/organ/external/parts = list()
	for(var/obj/item/organ/external/O in organs)
		if((brute && O.brute_dam) || (burn && O.burn_dam))
			if(!(flags & AFFECT_ROBOTIC_ORGAN) && O.status & ORGAN_ROBOT)
				continue
			if(!(flags & AFFECT_ORGANIC_ORGAN) && !(O.status & ORGAN_ROBOT))
				continue
			parts += O
	return parts

//Returns a list of damageable organs
/mob/living/carbon/human/proc/get_damageable_organs()
	var/list/obj/item/organ/external/parts = list()
	for(var/obj/item/organ/external/O in organs)
		if(O.brute_dam + O.burn_dam < O.max_damage)
			parts += O
	return parts

//Heals ONE external organ, organ gets randomly selected from damaged ones.
//It automatically updates damage overlays if necesary
//It automatically updates health status
/mob/living/carbon/human/heal_organ_damage(var/brute, var/burn)
	var/list/obj/item/organ/external/parts = get_damaged_organs(brute,burn)
	if(!parts.len)
		return
	var/obj/item/organ/external/picked = pick(parts)
	if(picked.heal_damage(brute,burn))
		UpdateDamageIcon()
	updatehealth()

//Damages ONE external organ, organ gets randomly selected from damagable ones.
//It automatically updates damage overlays if necesary
//It automatically updates health status
/mob/living/carbon/human/take_organ_damage(var/brute, var/burn, var/sharp = 0, var/edge = 0)
	var/list/obj/item/organ/external/parts = get_damageable_organs()
	if(!parts.len)
		return
	var/obj/item/organ/external/picked = pick(parts)
	if(picked.take_damage(brute,burn,sharp,edge))
		UpdateDamageIcon()
	updatehealth()
	speech_problem_flag = 1


//Heal MANY external organs, in random order
/mob/living/carbon/human/heal_overall_damage(var/brute, var/burn, var/internal=0, var/robotic=0)
	var/list/obj/item/organ/external/parts = get_damaged_organs(brute,burn)

	var/update = 0
	while(parts.len && ( brute > 0 || burn > 0) )
		var/obj/item/organ/external/picked = pick(parts)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam

		update |= picked.heal_damage(brute,burn, internal, robotic)

		brute -= (brute_was-picked.brute_dam)
		burn -= (burn_was-picked.burn_dam)

		parts -= picked

	updatehealth()
	speech_problem_flag = 1
	if(update)
		UpdateDamageIcon()

// damage MANY external organs, in random order
/mob/living/carbon/human/take_overall_damage(var/brute, var/burn, var/sharp = 0, var/edge = 0, var/used_weapon = null)
	if(status_flags & GODMODE)
		return	//godmode
	var/list/obj/item/organ/external/parts = get_damageable_organs()

	var/update = 0
	while(parts.len && (brute>0 || burn>0) )
		var/obj/item/organ/external/picked = pick(parts)
		var/brute_per_part = brute/parts.len
		var/burn_per_part = burn/parts.len

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam


		update |= picked.take_damage(brute_per_part,burn_per_part,sharp,edge,used_weapon)

		brute	-= (picked.brute_dam - brute_was)
		burn	-= (picked.burn_dam - burn_was)

		parts -= picked

	updatehealth()

	if(update)
		UpdateDamageIcon()


////////////////////////////////////////////

/*
This function restores the subjects blood to max.
*/
/mob/living/carbon/human/proc/restore_blood()
	if(!(species.flags & NO_BLOOD))
		var/blood_type = get_blood_name()
		var/blood_volume = vessel.get_reagent_amount(blood_type)
		vessel.add_reagent(blood_type, BLOOD_VOLUME_NORMAL - blood_volume)

/*
This function restores all organs.
*/
/mob/living/carbon/human/restore_all_organs()
	for(var/obj/item/organ/external/current_organ in organs)
		current_organ.rejuvenate()

/mob/living/carbon/human/proc/HealDamage(zone, brute, burn)
	var/obj/item/organ/external/E = get_organ(zone)
	if(istype(E, /obj/item/organ/external))
		if(E.heal_damage(brute, burn))
			UpdateDamageIcon()
	else
		return 0


/mob/living/carbon/human/proc/get_organ(var/zone)
	if(!zone)
		zone = "chest"
	if(zone in list("eyes", "mouth"))
		zone = "head"

	return organs_by_name[zone]

/mob/living/carbon/human/apply_damage(var/damage = 0, var/damagetype = BRUTE, var/def_zone = null, var/blocked = 0, var/sharp = 0, var/edge = 0, var/obj/used_weapon = null)
	//Handle other types of damage
	if((damagetype != BRUTE) && (damagetype != BURN))
		..(damage, damagetype, def_zone, blocked)
		return 1

	//Handle BRUTE and BURN damage
	handle_suit_punctures(damagetype, damage)

	blocked = (100 - blocked) / 100
	if(blocked <= 0)
		return 0

	var/obj/item/organ/external/organ = null
	if(isorgan(def_zone))
		organ = def_zone
	else
		if(!def_zone)
			def_zone = ran_zone(def_zone)
		organ = get_organ(check_zone(def_zone))
	if(!organ)
		return 0

	damage = damage * blocked

	switch(damagetype)
		if(BRUTE)
			damageoverlaytemp = 20
			if(species && species.brute_mod)
				damage = damage * species.brute_mod

			if(organ.take_damage(damage, 0, sharp, edge, used_weapon))
				UpdateDamageIcon()

			if(LAssailant && ishuman(LAssailant)) //superheros still get the comical hit markers
				var/mob/living/carbon/human/H = LAssailant
				if(H.mind && H.mind in (ticker.mode.superheroes || ticker.mode.supervillains || ticker.mode.greyshirts))
					var/list/attack_bubble_recipients = list()
					var/mob/living/user
					for(var/mob/O in viewers(user, src))
						if(O.client && !(O.blinded))
							attack_bubble_recipients.Add(O.client)
					spawn(0)
						var/image/dmgIcon = image('icons/effects/hit_blips.dmi', src, "dmg[rand(1,2)]",MOB_LAYER+1)
						dmgIcon.pixel_x = (!lying) ? rand(-3,3) : rand(-11,12)
						dmgIcon.pixel_y = (!lying) ? rand(-11,9) : rand(-10,1)
						flick_overlay(dmgIcon, attack_bubble_recipients, 9)

			receive_damage()

		if(BURN)
			damageoverlaytemp = 20

			if(species && species.burn_mod)
				damage = damage * species.burn_mod

			if(organ.take_damage(0, damage, sharp, edge, used_weapon))
				UpdateDamageIcon()

	// Will set our damageoverlay icon to the next level, which will then be set back to the normal level the next mob.Life().
	updatehealth()
	return 1
