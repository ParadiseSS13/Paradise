/mob/living/carbon/human// all the vars
	var/strength = 5
	var/intelligence = 5
	var/agility = 1
	var/weakness = 1
	var/wisdom = 5
	//damage calc
	var/meleedamlow
	var/meleedamhigh

//strength procs
/mob/living/carbon/human/proc/adjust_strength(amount)
	strength += amount

/mob/living/carbon/human/proc/set_strength(amount)
	strength = amount

//agility procs
/mob/living/carbon/human/proc/adjust_agility(amount)
	agility += amount
	move_speed += amount

/mob/living/carbon/human/proc/set_agility(amount)
	agility = amount
	move_speed += amount

/mob/living/carbon/human/breathe()
	. = ..()
