//Defines are in _defines_gurps.dm

/mob/living/proc/Roll3d6display(var/gurps, var/rollamount)
	if(src?.client?.DisplayingRolls)
		var/FailureText = ""
		var/crit = ""
		switch(gurps)
			if(GP_FAIL)
				FailureText = "Failure!"
			if(GP_CRITFAIL)
				FailureText = "Critical Failure!"
				crit = "☠️"
			if(GP_SUCC)
				FailureText = "Success!"
			if(GP_CRITSUCC)
				FailureText = "Critical Success!"
				crit = "💡"
		to_chat(src, "<i><span class='jogtowalk'>[crit]🎲[rollamount] [FailureText]</span></i>")

//default human roll mods, applied to every skill roll.
proc/human_roll_mods(var/mob/living/carbon/human/H)
	var/BaseMath = 0
	if(H.handcuffed)
		BaseMath -= rand(0,2)
	if(H.legcuffed)
		BaseMath -= rand(0,2)
	if(H.intent)
		BaseMath += rand(1,3)
	if(H.IsStunned())
		BaseMath -= rand(4,2)
	switch(H.nutrition)
		if(400 to 550)
			BaseMath += pick(0,1)
		if(220 to 275)
			BaseMath += pick(-1,0)
		if(150 to 220)
			BaseMath += pick(-1,0)
		if(100 to 150)
			BaseMath += pick(-2,-0)
		if(1 to 100)
			BaseMath += pick(-3,-2)
		if(-INFINITY to 1)
			BaseMath += pick(-4, -3)
	switch(H.hidration)
		if(THIRST_LEVEL_THIRSTY to THIRST_LEVEL_MEDIUM)
			BaseMath += pick(-1,0)
		if(150 to THIRST_LEVEL_THIRSTY)
			BaseMath += rand(-2,0)
		if(150 to THIRST_LEVEL_DEHYDRATED)
			BaseMath += rand(-3,-1)
		if(THIRST_LEVEL_DEHYDRATED to -INFINITY)
			BaseMath += rand(-4,-2)
	switch(H.happiness)
		if(MOOD_LEVEL_HAPPY1 to INFINITY)
			BaseMath += pick(0,1)
		if(MOOD_LEVEL_SAD2 to MOOD_LEVEL_SAD1)
			BaseMath += pick(-1,0)
		if(MOOD_LEVEL_SAD3 to MOOD_LEVEL_SAD2)
			BaseMath += pick(-2,1)
		if(MOOD_LEVEL_SAD4 to MOOD_LEVEL_SAD3)
			BaseMath += pick(-3,-2)
		if(-5000000 to MOOD_LEVEL_SAD4)
			BaseMath += pick(-4,-3)

	return BaseMath

proc/roll3d6(var/mob/living/carbon/human/H, var/base, var/mod, var/hide_roll = FALSE, var/using_stat = FALSE)
	if(!H)
		throw EXCEPTION("roll3d6 called without human!")
		return

	var/BaseMath = 0 //target that is being rolled against.
	if(!using_stat) //hack. But I didn't want to copy the proc for a slight change.
		var/datum/skill/S = get_skill_data(base,H.my_skills) //grab our skill
		var/skill_value = get_skill_value(base,H.my_skills) //grab our value
		if(!S.spec) //if our skill is not a specialization, our default is a stat.
			if(!S.no_default || skill_value > 0)
				var/default
				default = H.my_stats.get_stat(S.base_stat)
				skill_value += default
				skill_value += S.base_mod
			//	to_chat(world,"STAT:[default] STAT_MOD:[S.base_mod]")
		else//our skill is a specialization, which means our default is another skill
			var/base_value
			if(!S.no_default || skill_value > 0)
				base_value = get_skill_value(S.base_stat,H.my_skills)//use the default value
				skill_value += base_value
				skill_value += S.base_mod
			//	to_chat(world,"SKILL:[base_value] SKILL_MOD:[S.base_mod]")
				if(S.combat_skill) // if our skill is a combat skill. We also get its defaults default.
					var/datum/skill/combat_default = get_skill_data(S.base_stat,H.my_skills)
					var/default2 = H.my_stats.get_stat(combat_default.base_stat)
					skill_value += default2
				//	to_chat(world,"SKILL:[default2]")

		BaseMath += skill_value //add our skill value to our roll target.
		BaseMath += human_roll_mods(H) //get human roll mods
	else //we're just using a stat. No skill modifiers needed
		BaseMath += base // add the stat to our roll target.

	if(mod) //add the modifer if we got sent one
		BaseMath += mod
	BaseMath = round(BaseMath)

	var/result
	var/CritSuccAmount = 4
	var/CritFailAmount = 17
	var/dice = roll("3d6")
	if(BaseMath >= 15)
		CritSuccAmount = 5
		if(BaseMath >= 16)
			CritSuccAmount= 6

	if(dice >= CritFailAmount)
		result = GP_CRITFAIL
		if(BaseMath >= 15 && dice == 17)
			result = GP_FAIL
	else if(dice <= CritSuccAmount)
		result = GP_CRITSUCC
	else
		if(dice <= BaseMath)
			result = GP_SUCC
		else
			result = GP_FAIL

	if(dice - 10 >= BaseMath)
		result = GP_CRITFAIL

//	to_chat(world,"ROLL:[dice], BASEMATH:[BaseMath]")

	if(!using_stat)
		switch(result)
			if(GP_CRITFAIL)
				H.learn_skill(base, null, -2)
			if(GP_FAIL)
				H.learn_skill(base, null, -2)
			if(GP_SUCC)
				H.learn_skill(base, null, -2)
			if(GP_CRITSUCC)
				H.learn_skill(base, null, -2)

	var/margin = round(BaseMath - dice)
	if(H && !hide_roll)
		H.Roll3d6display(result, dice)
	var/return_list[4]
	return_list[GP_RESULT] = result
	return_list[GP_MARGIN] = margin
	return_list[GP_DICE] = dice
	return_list[GP_CHANCE] = gurps_chance(BaseMath)

	return return_list

/proc/gurps_chance(var/target) //the chance of getting within target
	var/message = "Success chance: "
	switch(target)
		if(16 to INFINITY)
			message += "<B>\>95%</B>"
		if(14 to 15)
			message += "<B>\>90%</B>"
		if(13)
			message += "<B>\>80%</B>"
		if(11 to 12)
			message += "<B>\>65%</B>"
		if(10)
			message += "<B>50%</B>"
		if(9 to 8)
			message += "<B>\<35%</B>"
		if(7)
			message += "<B>\<20%</B>"
		if(6)
			message += "<B>\<10%</B>"
		if(5 to -INFINITY)
			message += "<B>\<5%</B>"
	return message

/proc/max_dice(var/dice) //returns the maximum roll of a given dice string. ex: "2d6" returns 12
	var/mod = copytext(dice, findtext(dice, regex(@"(?=[\+\-]).")),0)
	var/amt = copytext(dice, 1, findtext(dice, "d"))
	var/dnum = copytext(dice, findtext(dice, "d")+1, findtext(dice, regex(@"[\+\-]")))
	return text2num(amt) * text2num(dnum) + text2num(mod)

/proc/min_dice(var/dice) //returns the minimum roll of a given dice string. ex: "2d6" returns 2
	var/amt = copytext(dice, 1, findtext(dice, "d"))
	var/mod = copytext(dice, findtext(dice, regex(@"(?=[\+\-]).")),0)
	return text2num(amt) + text2num(mod)
