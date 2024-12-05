/datum/component/spooky
	var/too_spooky = TRUE //will it spawn a new instrument?

/datum/component/spooky/Initialize()
	RegisterSignal(parent, COMSIG_ATTACK, PROC_REF(spectral_attack))

/datum/component/spooky/proc/spectral_attack(datum/source, mob/living/carbon/C, mob/user)
	if(ishuman(user)) //this weapon wasn't meant for mortals.
		var/mob/living/carbon/human/U = user
		if(!istype(U.dna.species, /datum/species/skeleton))
			U.apply_damage(35, STAMINA) //Extra Damage
			U.Jitter(70 SECONDS)
			U.SetStuttering(40 SECONDS)
			if(U.getStaminaLoss() > 95)
				to_chat(U, "<font color='red' size='4'><b>Your ears weren't meant for this spectral sound.</b></font>")
				spectral_change(U)
			return

	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(istype(H.dna.species, /datum/species/skeleton))
			return //undeads are unaffected by the spook-pocalypse.
		C.Jitter(70 SECONDS)
		C.SetStuttering(40 SECONDS)
		if(!istype(H.dna.species, /datum/species/diona) && !istype(H.dna.species, /datum/species/machine) && !istype(H.dna.species, /datum/species/slime) && !istype(H.dna.species, /datum/species/golem) && !istype(H.dna.species, /datum/species/plasmaman))
			C.apply_damage(25, STAMINA) //boneless humanoids don't lose the will to live
		to_chat(C, "<font color='red' size='4'><B>DOOT</B></font>")
		spectral_change(H)

	else //the sound will spook monkeys.
		C.Jitter(30 SECONDS)
		C.SetStuttering(40 SECONDS)

/datum/component/spooky/proc/spectral_change(mob/living/carbon/human/H, mob/user)
	if((H.getStaminaLoss() > 95) && (!istype(H.dna.species, /datum/species/diona) && !istype(H.dna.species, /datum/species/machine) && !istype(H.dna.species, /datum/species/slime) && !istype(H.dna.species, /datum/species/golem) && !istype(H.dna.species, /datum/species/plasmaman) && !istype(H.dna.species, /datum/species/skeleton)))
		H.Stun(40 SECONDS)
		H.set_species(/datum/species/skeleton) // Makes the OP skelly
		H.visible_message("<span class='warning'>[H] has given up on life as a mortal.</span>")
		var/T = get_turf(H)
		if(too_spooky)
			if(prob(30))
				new/obj/item/instrument/saxophone/spectral(T)
			else if(prob(30))
				new/obj/item/instrument/trumpet/spectral(T)
			else if(prob(30))
				new/obj/item/instrument/trombone/spectral(T)
			else
				to_chat(H, "<span class='boldwarning'>The spooky gods forgot to ship your instrument. Better luck next unlife.</span>")
		to_chat(H, "<span class='boldnotice'>You are the spooky skeleton!</span>")
		to_chat(H, "<span class='boldnotice'>A new life and identity has begun. Help your fellow skeletons into bringing out the spooky-pocalypse. You haven't forgotten your past life, and are still beholden to past loyalties.</span>")
		change_name(H)	//time for a new name!

/datum/component/spooky/proc/change_name(mob/living/carbon/human/H)
	var/t = tgui_input_text(H, "Enter your new skeleton name", H.real_name, max_length = MAX_NAME_LEN)
	if(!t)
		t = "spooky skeleton"
	H.real_name = t
	H.name = t
