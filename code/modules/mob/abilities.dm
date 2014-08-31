/*
Creature-level abilities.
*/

/var/global/list/ability_verbs = list(	)


/mob/living/carbon/human/slime/proc/slimepeople_ventcrawl()

	set category = "Abilities"
	set name = "Ventcrawl (Slime People)"
	set desc = "The ability to crawl through vents if naked and not holding anything."


	if(istype(usr,/mob/living/carbon/human/slime))
		var/mob/living/carbon/human/slime/M = usr
		// Check if the client has a mob and if the mob is valid and alive.
		if(M.stat==2)
			M << "\red You must be corporeal and alive to do that."
			return 0

		//Handcuff check.
		if(M.restrained())
			M << "\red You cannot do this while restrained."
			return 0

		if(M.handcuffed)
			M << "\red You cannot do this while cuffed."
			return 0

		if(M.contents.len != 0)
			M << "\red You need to be naked and have nothing in your hands to ventcrawl."
			return 0

		M.handle_ventcrawl()
	else
		src << "This should not be happening. At all."