/datum/reagent
	var/name = "Reagent"
	var/id = "reagent"
	var/description = ""
	var/datum/reagents/holder = null
	var/reagent_state = SOLID
	var/list/data = null
	var/volume = 0
	var/nutriment_factor = 0
	var/metabolization_rate = REAGENTS_METABOLISM
	//var/list/viruses = list()
	var/color = "#000000" // rgb: 0, 0, 0 (does not support alpha channels - yet!)
	var/shock_reduction = 0
	var/penetrates_skin = 0 //Whether or not a reagent penetrates the skin
	//Processing flags, defines the type of mobs the reagent will affect
	//By default, all reagents will ONLY affect organics, not synthetics. Re-define in the reagent's definition if the reagent is meant to affect synths
	var/process_flags = ORGANIC


/datum/reagent/proc/reaction_mob(var/mob/M, var/method=TOUCH, var/volume) //Some reagents transfer on touch, others don't; dependent on if they penetrate the skin or not.
	if(!istype(M, /mob/living))	return 0
	var/datum/reagent/self = src
	src = null

	if(self.holder)		//for catching rare runtimes
		if(method == TOUCH && self.penetrates_skin)
			var/block  = 0
			for(var/obj/item/clothing/C in M.get_equipped_items())
				if(istype(C, /obj/item/clothing/suit/bio_suit))
					block += 1
				if(istype(C, /obj/item/clothing/head/bio_hood))
					block += 1
			if(block < 2)
				if(M.reagents)
					M.reagents.add_reagent(self.id,self.volume)

/*
		if(method == INGEST && istype(M, /mob/living/carbon))
			if(prob(1 * self.addictiveness))
				if(prob(5 * volume))
					var/datum/disease/addiction/A = new /datum/disease/addiction
					A.addicted_to = self
					A.name = "[self.name] Addiction"
					A.addiction ="[self.name]"
					A.cure = self.id
					M.viruses += A
					A.affected_mob = M
					A.holder = M
*/
		return 1

/datum/reagent/proc/reaction_obj(var/obj/O, var/volume) //By default we transfer a small part of the reagent to the object
	src = null						//if it can hold reagents. nope!
	//if(O.reagents)
	//	O.reagents.add_reagent(id,volume/3)
	return

/datum/reagent/proc/reaction_turf(var/turf/T, var/volume)
	src = null
	return

/datum/reagent/proc/on_mob_life(var/mob/living/M as mob, var/alien)
	if(!istype(M, /mob/living)) // YOU'RE A FUCKING RETARD NEO WHY CAN'T YOU JUST FIX THE PROBLEM ON THE REAGENT - Iamgoofball
		return //Noticed runtime errors from facid trying to damage ghosts, this should fix. --NEO
				// Certain elements in too large amounts cause side-effects
	holder.remove_reagent(src.id, metabolization_rate) //By default it slowly disappears.
	current_cycle++
	return

// Called when two reagents of the same are mixing.
/datum/reagent/proc/on_merge(var/data)
	return

/datum/reagent/proc/on_move(var/mob/M)
	return

/datum/reagent/proc/on_update(var/atom/A)
	return

/datum/reagent/Destroy()
	holder = null
	return ..()