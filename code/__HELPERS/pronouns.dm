//pronoun procs, for getting pronouns without using the text macros that only work in certain positions
//datums don't have gender, but most of their subtypes do!
/datum/proc/p_they(capitalized, temp_gender)
	. = "it"
	if(capitalized)
		. = capitalize(.)

/datum/proc/p_their(capitalized, temp_gender)
	. = "its"
	if(capitalized)
		. = capitalize(.)

/datum/proc/p_them(capitalized, temp_gender)
	. = "it"
	if(capitalized)
		. = capitalize(.)

/datum/proc/p_have(temp_gender)
	. = "has"

/datum/proc/p_are(temp_gender)
	. = "is"

/datum/proc/p_were(temp_gender)
	. = "was"

/datum/proc/p_do(temp_gender)
	. = "does"

/datum/proc/p_theyve(capitalized, temp_gender)
	. = p_they(capitalized, temp_gender) + "'" + copytext(p_have(temp_gender), 3)

/datum/proc/p_theyre(capitalized, temp_gender)
	. = p_they(capitalized, temp_gender) + "'" + copytext(p_are(temp_gender), 2)

/datum/proc/p_themselves(capitalized, temp_gender)
	. = "itself"

// For help conjugating verbs, eg they look, but she looks
/datum/proc/p_s(temp_gender)
	. = "s"

/datum/proc/p_es(temp_gender)
	. = p_s(temp_gender)
	if(.)
		. = "e[.]"

// Functionally the \a macro, for the cases where you put a bicon between "some [bicon] pop corn"
/datum/proc/p_a(temp_gender)
	var/backslash_a = "\a [src]"
	backslash_a = splittext_char(backslash_a, " ")
	if(length(backslash_a) >= 2) // ["some", "pop", "corn"], but we dont want "\a ["Thing"]" which is just ["Thing"]
		. = backslash_a[1]

//like clients, which do have gender.
/client/p_they(capitalized, temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = "they"
	switch(temp_gender)
		if(FEMALE)
			. = "she"
		if(MALE)
			. = "he"
	if(capitalized)
		. = capitalize(.)

/client/p_their(capitalized, temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = "their"
	switch(temp_gender)
		if(FEMALE)
			. = "her"
		if(MALE)
			. = "his"
	if(capitalized)
		. = capitalize(.)

/client/p_them(capitalized, temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = "them"
	switch(temp_gender)
		if(FEMALE)
			. = "her"
		if(MALE)
			. = "him"
	if(capitalized)
		. = capitalize(.)

/client/p_themselves(capitalized, temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = p_them(capitalized, temp_gender)
	switch(temp_gender)
		if(MALE, FEMALE)
			. += "self"
		if(NEUTER, PLURAL)
			. += "selves"
	if(capitalized)
		. = capitalize(.)

/client/p_have(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = "has"
	if(temp_gender == PLURAL || temp_gender == NEUTER)
		. = "have"

/client/p_are(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = "is"
	if(temp_gender == PLURAL || temp_gender == NEUTER)
		. = "are"

/client/p_were(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = "was"
	if(temp_gender == PLURAL || temp_gender == NEUTER)
		. = "were"

/client/p_do(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = "does"
	if(temp_gender == PLURAL || temp_gender == NEUTER)
		. = "do"

/client/p_s(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	if(temp_gender != PLURAL && temp_gender != NEUTER)
		. = "s"

//mobs(and atoms but atoms don't really matter write your own proc overrides) also have gender!
/mob/p_they(capitalized, temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = "it"
	switch(temp_gender)
		if(FEMALE)
			. = "she"
		if(MALE)
			. = "he"
		if(PLURAL)
			. = "they"
	if(capitalized)
		. = capitalize(.)

/mob/p_their(capitalized, temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = "its"
	switch(temp_gender)
		if(FEMALE)
			. = "her"
		if(MALE)
			. = "his"
		if(PLURAL)
			. = "their"
	if(capitalized)
		. = capitalize(.)

/mob/p_them(capitalized, temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = "it"
	switch(temp_gender)
		if(FEMALE)
			. = "her"
		if(MALE)
			. = "him"
		if(PLURAL)
			. = "them"
	if(capitalized)
		. = capitalize(.)

/mob/p_themselves(capitalized, temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = p_them(capitalized, temp_gender)
	switch(temp_gender)
		if(MALE, FEMALE, NEUTER)
			. += "self"
		if(PLURAL)
			. += "selves"
	if(capitalized)
		. = capitalize(.)

/mob/p_have(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = "has"
	if(temp_gender == PLURAL)
		. = "have"

/mob/p_are(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = "is"
	if(temp_gender == PLURAL)
		. = "are"

/mob/p_were(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = "was"
	if(temp_gender == PLURAL)
		. = "were"

/mob/p_do(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = "does"
	if(temp_gender == PLURAL)
		. = "do"

/mob/p_s(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	if(temp_gender != PLURAL)
		. = "s"

//humans need special handling, because they can have their gender hidden
/mob/living/carbon/human/p_they(capitalized, temp_gender)
	temp_gender = get_visible_gender()
	return ..()

/mob/living/carbon/human/p_their(capitalized, temp_gender)
	temp_gender = get_visible_gender()
	return ..()

/mob/living/carbon/human/p_them(capitalized, temp_gender)
	temp_gender = get_visible_gender()
	return ..()

/mob/living/carbon/human/p_themselves(capitalized, temp_gender)
	temp_gender = get_visible_gender()
	return ..()

/mob/living/carbon/human/p_have(temp_gender)
	temp_gender = get_visible_gender()
	return ..()

/mob/living/carbon/human/p_are(temp_gender)
	temp_gender = get_visible_gender()
	return ..()

/mob/living/carbon/human/p_were(temp_gender)
	temp_gender = get_visible_gender()
	return ..()

/mob/living/carbon/human/p_do(temp_gender)
	temp_gender = get_visible_gender()
	return ..()

/mob/living/carbon/human/p_s(temp_gender)
	temp_gender = get_visible_gender()
	return ..()
