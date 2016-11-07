/datum/objective/devil

/datum/objective/devil/soulquantity
	explanation_text = "You shouldn't see this text.  Error:DEVIL1"
	target_amount = 4

/datum/objective/devil/soulquantity/New()
	target_amount = pick(6,7,8)
	update_explanation_text()

/datum/objective/devil/proc/update_explanation_text()
	//Intentionally empty

/datum/objective/devil/soulquantity/update_explanation_text()
	explanation_text = "Purchase, and retain control over at least [target_amount] souls."

/datum/objective/devil/soulquantity/check_completion()
	var/count = 0
	for(var/S in owner.devilinfo.soulsOwned)
		var/datum/mind/L = S
		if(L.soulOwner == owner)
			count++
	return count >= target_amount



/datum/objective/devil/soulquality
	explanation_text = "You shouldn't see this text.  Error:DEVIL2"
	var/contractType
	var/contractName

/datum/objective/devil/soulquality/New()
	contractType = pick(CONTRACT_POWER, CONTRACT_WEALTH, CONTRACT_PRESTIGE, CONTRACT_MAGIC, CONTRACT_REVIVE, CONTRACT_KNOWLEDGE)
	target_amount = pick(1,2)
	switch(contractType)
		if(CONTRACT_POWER)
			contractName = "for power"
		if(CONTRACT_WEALTH)
			contractName = "for wealth"
		if(CONTRACT_PRESTIGE)
			contractName = "for prestige"
		if(CONTRACT_MAGIC)
			contractName = "for magic"
		if(CONTRACT_REVIVE)
			contractName = "of revival"
		if(CONTRACT_KNOWLEDGE)
			contractName = "for knowledge"
	update_explanation_text()

/datum/objective/devil/soulquality/update_explanation_text()
	explanation_text = "Have mortals sign at least [target_amount] contracts [contractName]"

/datum/objective/devil/soulquality/check_completion()
	var/count = 0
	for(var/S in owner.devilinfo.soulsOwned)
		var/datum/mind/L = S
		if(L.soulOwner != L && L.damnation_type == contractType)
			count++
	return count>=target_amount



/datum/objective/devil/sintouch
	explanation_text = "You shouldn't see this text.  Error:DEVIL3"

/datum/objective/devil/sintouch/New()
	target_amount = pick(4,5)
	explanation_text = "Ensure at least [target_amount] mortals are sintouched."

/datum/objective/devil/sintouch/check_completion()
	return target_amount<=ticker.mode.sintouched.len



/datum/objective/devil/buy_target
	explanation_text = "You shouldn't see this text.  Error:DEVIL4"

/datum/objective/devil/buy_target/New()
	find_target()
	update_explanation_text()

/datum/objective/devil/buy_target/update_explanation_text()
	if(target)
		explanation_text = "Purchase and retain the soul of [target.name], the [target.assigned_role]."
	else
		explanation_text = "Free objective."

/datum/objective/devil/buy_target/check_completion()
	return target.soulOwner == owner


/datum/objective/devil/outsell
	explanation_text = "You shouldn't see this text.  Error:DEVIL5"

/datum/objective/devil/outsell/update_explanation_text()
	explanation_text = "Purchase and retain control over more souls than [target.devilinfo.truename], known to mortals as [target.name], the [target.assigned_role]."

/datum/objective/devil/outsell/check_completion()
	var/selfcount = 0
	for(var/S in owner.devilinfo.soulsOwned)
		var/datum/mind/L = S
		if(L.soulOwner == owner)
			selfcount++
	var/targetcount = 0
	for(var/S in target.devilinfo.soulsOwned)
		var/datum/mind/L = S
		if(L.soulOwner == target)
			targetcount++
	return selfcount > targetcount
