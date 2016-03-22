#define SMELL_HORRIBLE 0
#define SMELL_FOUL 1
#define SMELL_NEUTRAL 2
#define SMELL_PLEASANT 3
#define SMELL_NICE 4

#define SMELL_TRACE 2
#define SMELL_FAINT 4
#define SMELL_NORMAL 8
#define SMELL_INTENSE 16

/datum/smell
	var/qty
	var/name
	var/intensity
	var/description

/datum/smell/New(var/q)
	qty=q
	return src


//outputs a string that fully describes a smell
/mob/living/proc/eval_smell(var/datum/smell/S)
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if((H.species.flags & NO_BREATHE) || (NO_BREATHE in H.mutations) || wear_mask)//can't breathe can't smell, masks block smells
			return
	if(!S || constipated)//if there's no smell at all OR if your nose is constipated
		src << "<span class='notice'>You can't smell anything!</span>"
		return

	var/int = null
	var/class = null
	var/qty = null

	var/actual_qty =  get_species_coef(src) * S.qty

	if(actual_qty<=SMELL_TRACE)
		qty = " trace,"
	else if(actual_qty<=SMELL_FAINT)
		qty = " faint,"
	else if(actual_qty<=SMELL_NORMAL)
		qty = ""
	else if(actual_qty<=SMELL_INTENSE)
		qty = "n intense,"

	switch(S.intensity)
		if(SMELL_HORRIBLE)
			int = "indescribably disgusting"
			class = "'warning'"
		if(SMELL_FOUL)
			int = "incredibly foul"
			class = "'warning'"
		if(SMELL_NEUTRAL)
			int =""
			class = "'notice'"
		if(SMELL_PLEASANT)
			int ="pleasant"
			class = "'notice'"
		if(SMELL_NICE)
			int = "really nice"
			class = "'notice'"

	var/data = "<span class=[class]>There's a[qty] [int] smell of [S.description].</span>"
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
	else if(iscarp(M) || iscrab(M))
		return 0 //not entirely sure how you might end up in a carp, maybe xenobio, so just in case

	return 1 //in case I forget someone