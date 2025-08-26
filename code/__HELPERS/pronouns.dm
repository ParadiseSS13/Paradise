//pronoun procs, for getting pronouns without using the text macros that only work in certain positions
//datums don't have gender, but most of their subtypes do!

//////////////////////////////
// MARK: Pronouns
//////////////////////////////
/// Applies one of "they", "it", "he", or "she" as appropriate. Set to TRUE to capitalise.
/datum/proc/p_they(capitalized, temp_gender)
	. = "it"
	if(capitalized)
		. = capitalize(.)

/// Applies one of "their", "its", "his", or "her" as appropriate. Set to TRUE to capitalise.
/datum/proc/p_their(capitalized, temp_gender)
	. = "its"
	if(capitalized)
		. = capitalize(.)

/// Applies one of "them", "it", "him", or "her" as appropriate. Set to TRUE to capitalise.
/datum/proc/p_them(capitalized, temp_gender)
	. = "it"
	if(capitalized)
		. = capitalize(.)

/// Applies "has" for singular genders, or "have" for plural ones (e.g. "she has eaten" Vs. "they have eaten").
/datum/proc/p_have(temp_gender)
	. = "has"

/// Applies "is" for singular genders, or "are" for plural ones (e.g. "he is here" Vs. "they are here").
/datum/proc/p_are(temp_gender)
	. = "is"

/// Applies "was" for singular genders, or "were" for plural ones (e.g. "it was huge" Vs. "they were huge").
/datum/proc/p_were(temp_gender)
	. = "was"

/// Applies "does" for singular genders, or "do" for plural ones (e.g. "she does stuff" Vs. "they do stuff").
/datum/proc/p_do(temp_gender)
	. = "does"

/// Applies one of "they've", "it's", "he's", or "she's" as appropriate. Set to TRUE to capitalise.
/datum/proc/p_theyve(capitalized, temp_gender)
	. = p_they(capitalized, temp_gender) + "'" + copytext(p_have(temp_gender), 3)

/// Applies one of "they're", "it's", "he's", or "she's" as appropriate. Set to TRUE to capitalise.
/datum/proc/p_theyre(capitalized, temp_gender)
	. = p_they(capitalized, temp_gender) + "'" + copytext(p_are(temp_gender), 2)

/// Applies one of "themselves", "itself", "himself", or "herself" as appropriate. Set to TRUE to capitalise.
/datum/proc/p_themselves(capitalized, temp_gender)
	. = "itself"

//////////////////////////////
// MARK: Other grammar
//////////////////////////////
/// Used to add an "s" to the end of a word as appropriate for a particular gender (e.g. "she looks" and "they look"). For verb conjugation.
/datum/proc/p_s(temp_gender)
	. = "s"

/// Adds an "es" to the end of a word as appropriate for a particular gender (e.g. "he screeches" and "they screech"). For verb conjugation.
/datum/proc/p_es(temp_gender)
	. = p_s(temp_gender)
	if(.)
		. = "e[.]"

/// Functionally the \a macro, for the cases where you put a bicon between "some [bicon] pop corn"
/datum/proc/p_a(temp_gender)
	var/backslash_a = "\a [src]"
	backslash_a = splittext_char(backslash_a, " ")
	if(length(backslash_a) >= 2) // ["some", "pop", "corn"], but we dont want "\a ["Thing"]" which is just ["Thing"]
		. = backslash_a[1]

//////////////////////////////
// MARK: Client procs
//////////////////////////////
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

//////////////////////////////
// MARK: Mob procs
//////////////////////////////
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

// Internal dialogue pronouns. This allow replacements of "their" with "your", if the user and target are the same. Src should always be considered the "target".
/mob/proc/i_you(user, capitalized)
	ASSERT(user)
	if(src != user)
		return p_they(capitalized)
	. = "you"
	if(capitalized)
		. = capitalize(.)

/mob/proc/i_your(user, capitalized)
	ASSERT(user)
	if(src != user)
		return p_their(capitalized)
	. = "your"
	if(capitalized)
		. = capitalize(.)

/mob/proc/i_yourself(user, capitalized)
	ASSERT(user)
	if(src != user)
		return src // don't say "himself", just refer to them by name
	. = "yourself"
	if(capitalized)
		. = capitalize(.)

/mob/proc/i_do(user)
	ASSERT(user)
	if(src != user)
		return p_do()
	. = "do"

// External dialogue pronouns, similar to internal dialogue pronouns but for when the observer is a 3rd party. These should only really be used in visible_message()
/mob/proc/e_themselves(user, capitalized)
	ASSERT(user)
	if(src != user)
		return src // refer to them by name, since its user acting on src
	return p_themselves(capitalized)

//////////////////////////////
// MARK: Human procs
//////////////////////////////
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
