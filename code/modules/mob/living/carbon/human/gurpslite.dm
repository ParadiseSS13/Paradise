
proc/human_roll_mods(var/mob/living/carbon/human/H)
	var/BaseMath = 0
	if(H.handcuffed)
		BaseMath -= rand(0,2)
	if(H.legcuffed)
		BaseMath -= rand(0,2)
	if(H.intent == INTENT_HARM)
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
	return BaseMath

proc/roll_dice(sides, successcheck = FALSE, crit_successcheck = FALSE, amount = 1, mod = 0)
	var/result = 0
	var/highest = 0
	var/slice = highest % 2
	highest = amount * sides
	result = rand(amount, highest)
	var/dice_result = 0
	dice_result = result
	result += mod
	if(successcheck)
		if(result > slice)
			return TRUE
		else
			return FALSE
	if(crit_successcheck)
		return check_crittable(sides, amount, result, mod)
	else
		return result

proc/check_crittable(sides, amount, result, mod)
	if(sides == 20 && amount == 1)
		switch(mod)
			if(1 to 15)
				if(result >= 20)
					return TRUE
			if(16 to INFINITY)
				if(result >= 19)
					return TRUE
		switch(mod)
			if(1 to 3)
				if(result <= 4)
					return FALSE
			if(4)
				if(result <= 3)
					return FALSE
			if(5)
				if(result <= 2)
					return FALSE
			if(6 to INFINITY)
				if(result <= 1)
					return FALSE
	if(sides == 6 && amount == 3)
		switch(mod)
			if(3 to 14)
				if(result <= 4)
					return TRUE
			if(15)
				if(result <= 5)
					return TRUE
			if(16 to INFINITY)
				if(result <= 6)
					return TRUE
		switch(mod)
			if(3)
				if(result >= 13)
					return FALSE
			if(4)
				if(result >= 14)
					return FALSE
			if(5)
				if(result >= 15)
					return FALSE
			if(6)
				if(result >= 16)
					return FALSE
			if(7 to 15)
				if(result >= 17)
					return FALSE
			if(16 to INFINITY)
				if(result >= 18)
					return FALSE

proc/skillcheck(var/mob/living/carbon/human/H, skilltocheck)


proc/prob2()
	var/value1 = 0
	var/result = 0
	value1 = rand(0,100)
	result = prob(value1)
	return result

/datum/skills
	var/wisdom = 0
	var/strength = 0
	var/intelligence = 0
	var/perception = 12

/mob/living/Carbon/human/verb/teach(/mob/living/Carbon/human/H)
	set category = null
	set name = "Teach skill"
	set desc = "Teach someone your skills."
	set src in view(1)

/mob/living/Carbon/human
	var/skills
