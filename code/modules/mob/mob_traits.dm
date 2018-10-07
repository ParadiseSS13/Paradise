//
//		TRAITS. Unlike tg's current implementation it is declared at mob instead of mob/living level
//      Since traits should be a wholesale replacement of the mutation list system, mob is the correct
//      level to declare it on

/mob/proc/add_trait(trait, source)
	if(!status_traits[trait])
		status_traits[trait] = list(source)
	else
		status_traits[trait] |= list(source)

/mob/proc/remove_trait(trait, list/sources)
	if(!status_traits[trait])
		return

	if(!sources) // No defined source cures the trait entirely.
		status_traits -= trait
		return

	if(!islist(sources))
		sources = list(sources)

	if(LAZYLEN(sources))
		for(var/S in sources)
			if(S in status_traits[trait])
				status_traits[trait] -= S
	else
		status_traits[trait] = list()

	if(!LAZYLEN(status_traits[trait]))
		status_traits -= trait

/mob/proc/has_trait(trait, list/sources)
	if(!status_traits[trait])
		return FALSE

	. = FALSE

	if(LAZYLEN(sources))
		for(var/S in sources)
			if(S in status_traits[trait])
				return TRUE
	else
		if(LAZYLEN(status_traits[trait]))
			return TRUE

/mob/proc/remove_all_traits()
	status_traits = list()

// Trait Procs

 // Proc shared with tg here
/mob/proc/become_blind(source)
	if(!has_trait(TRAIT_BLIND))
		EyeBlind(1)
	add_trait(TRAIT_BLIND, source)

/mob/proc/cure_blind(list/sources)
	if(!has_trait(TRAIT_BLIND))
		EyeBlind(1)
	remove_trait(TRAIT_BLIND, sources)

/mob/proc/cure_nearsighted(list/sources)
	remove_trait(TRAIT_NEARSIGHT, sources)
	if(!has_trait(TRAIT_NEARSIGHT))
		clear_fullscreen("nearsighted")

/mob/proc/become_nearsighted(source)
	if(!has_trait(TRAIT_NEARSIGHT))
		overlay_fullscreen("nearsighted", /obj/screen/fullscreen/impaired, 1)
	add_trait(TRAIT_NEARSIGHT, source)

/mob/proc/fakedeath(source)
	if(stat == DEAD)
		return
	add_trait(TRAIT_FAKEDEATH, source)
	timeofdeath = worldtime2text()
	update_stat() 
	
/mob/proc/cure_fakedeath(list/sources) 
	remove_trait(TRAIT_FAKEDEATH, sources)
	if(stat != DEAD)
		timeofdeath = null
	update_stat()

// Procs not shared with tg begin here

/mob/proc/become_nervous(source)
	add_trait(TRAIT_NERVOUS, source)

/mob/proc/cure_nervous(list/sources)
	remove_trait(TRAIT_NERVOUS, sources)

/mob/proc/become_tourettes(source)
	add_trait(TRAIT_TOURETTES, source)

/mob/proc/cure_tourettes(list/sources)
	remove_trait(TRAIT_TOURETTES, sources)

/mob/proc/become_coughing(source)
	add_trait(TRAIT_COUGHING, source)

/mob/proc/cure_coughing(list/sources)
	remove_trait(TRAIT_COUGHING, sources)

/mob/proc/become_deaf(source)
	add_trait(TRAIT_DEAF, source)

/mob/proc/cure_deaf(list/sources)
	remove_trait(TRAIT_DEAF, sources)

/mob/proc/become_epilepsy(source)
	add_trait(TRAIT_EPILEPSY, source)

/mob/proc/cure_epilepsy(list/sources)
	remove_trait(TRAIT_EPILEPSY, sources)

/mob/proc/become_mute(source)
	add_trait(TRAIT_MUTE, source)

/mob/proc/cure_mute(list/sources)
	remove_trait(TRAIT_MUTE, sources)