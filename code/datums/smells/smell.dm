/datum/smell
	var/concentration //how much of the smell is in the turf
	var/name
	var/badness //how good or bad the smell is
	var/description

/datum/smell/New(var/smell_concentration)
	concentration=smell_concentration

//outputs a string that fully describes a smell
/mob/living/proc/eval_smell(var/datum/smell/S)
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if((H.species.flags & NO_BREATHE) || (NO_BREATHE in H.mutations) || wear_mask)//can't breathe can't smell, masks block smells
			return
	if(!S || smell_breathing_obstructed)//if there's no smell at all OR if your nose is constipated
		src << "<span class='notice'>You can't smell anything!</span>"
		return

	var/badness = null
	var/span_class = null
	var/concentration = null

	var/sensed_concentration =  get_species_coef(src) * S.concentration

	if(sensed_concentration <= SMELL_TRACE)
		concentration = " trace,"
	else if(sensed_concentration <= SMELL_FAINT)
		concentration = " faint,"
	else if(sensed_concentration <= SMELL_NORMAL)
		concentration = ""
	else if(sensed_concentration <= SMELL_INTENSE)
		concentration = "n intense,"

	switch(S.badness)
		if(SMELL_HORRIBLE)
			badness = "indescribably disgusting"
			span_class = "warning"
		if(SMELL_FOUL)
			badness = "incredibly foul"
			span_class = "warning"
		if(SMELL_NEUTRAL)
			badness =""
			span_class = "notice"
		if(SMELL_PLEASANT)
			badness = "pleasant"
			span_class = "notice"
		if(SMELL_NICE)
			badness = "really nice"
			span_class = "notice"

	var/data = "<span class='[span_class]'>There's a[concentration] [badness] smell of [S.description].</span>"
	src << data

//returns the smell coeffiect for the species, higher means able to smell tracer ammounts
//HACKY SNOWFLAKE, THE PROC
mob/living/proc/get_species_coef(var/mob/living/M)
	switch(get_species(M))
		if("Human" || "Grey" || "Diona")
			return 1
		if("Unathi" || "Skrell" || "Vox" || "Vox Armalis")
			return 0.5
		if("Tajaran" || "Kidan" || "Wrynn")
			return 2
		if("Vulpkanin")
			return 3

	if(iscorgi(M) || isalienadult(M) || isalien(M))
		return 3 //ian is a god and pretty sure xenos can smell fear
	else if(iscat(M) || isbear(M) ||ismouse(M))
		return 2 //runtime is ok too

	return 1 //in case I forget someone

/datum/smell/vomit
	name = "vomit"
	badness = 1
	description = "vomit"