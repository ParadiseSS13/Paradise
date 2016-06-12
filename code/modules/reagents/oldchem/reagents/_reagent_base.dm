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
	var/can_grow_in_plants = 1	//Determines if the reagent can be grown in plants, 0 means it cannot be grown
	//Processing flags, defines the type of mobs the reagent will affect
	//By default, all reagents will ONLY affect organics, not synthetics. Re-define in the reagent's definition if the reagent is meant to affect synths
	var/process_flags = ORGANIC
	var/admin_only = 0

/datum/reagent/proc/reaction_mob(var/mob/M, var/method=TOUCH, var/volume) //Some reagents transfer on touch, others don't; dependent on if they penetrate the skin or not.
	if(!istype(M, /mob/living))	return 0
	var/datum/reagent/self = src
	src = null

	if(self.holder)		//for catching rare runtimes
		if(method == TOUCH && self.penetrates_skin)
			if(isliving(M))
				var/mob/living/L = M
				var/block  = L.get_permeability_protection()
				var/amount = round(self.volume * (1.0 - block), 0.1)
				if(L.reagents)
					if(amount >= 1)
						L.reagents.add_reagent(self.id,amount)


		if(method == INGEST) //Yes, even Xenos can get addicted to drugs.
			var/can_become_addicted = M.reagents.reaction_check(M, self)

			if(can_become_addicted)
				if(prob(self.addiction_chance) && !is_type_in_list(self, M.reagents.addiction_list))
					to_chat(M, "<span class='danger'>You suddenly feel invigorated and guilty...</span>")
					var/datum/reagent/new_reagent = new self.type()
					new_reagent.last_addiction_dose = world.timeofday
					M.reagents.addiction_list.Add(new_reagent)
				else if(is_type_in_list(self, M.reagents.addiction_list))
					to_chat(M, "<span class='notice'>You feel slightly better, but for how long?</span>")
					for(var/A in M.reagents.addiction_list)
						var/datum/reagent/AD = A
						if(AD && istype(AD, self))
							AD.last_addiction_dose = world.timeofday
							AD.addiction_stage = 1
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
	if(!istype(M))
		return
	if(holder)
		holder.remove_reagent(id, metabolization_rate) //By default it slowly disappears.
		current_cycle++

// Called when two reagents of the same are mixing.
/datum/reagent/proc/on_merge(var/data)
	return

/datum/reagent/proc/on_move(var/mob/M)
	return

/datum/reagent/proc/on_update(var/atom/A)
	return

// Called after add_reagents creates a new reagent.
/datum/reagent/proc/on_new(data)
	return

/datum/reagent/Destroy()
	. = ..()
	holder = null