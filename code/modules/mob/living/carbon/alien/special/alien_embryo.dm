// This is to replace the previous datum/disease/alien_embryo for slightly improved handling and maintainability
// It functions almost identically (see code/datums/diseases/alien_embryo.dm)

/obj/item/organ/internal/body_egg/alien_embryo
	name = "alien embryo"
	icon = 'icons/mob/alien.dmi'
	icon_state = "larva0_dead"
	var/stage = 0
	var/polling = 0

/obj/item/organ/internal/body_egg/alien_embryo/on_find(mob/living/finder)
	..()
	if(stage < 4)
		to_chat(finder, "It's small and weak, barely the size of a fetus.")
	else
		to_chat(finder, "It's grown quite large, and writhes slightly as you look at it.")
		if(prob(10))
			AttemptGrow(0)

/obj/item/organ/internal/body_egg/alien_embryo/prepare_eat()
	var/obj/S = ..()
	S.reagents.add_reagent("sacid", 10)
	return S

/obj/item/organ/internal/body_egg/alien_embryo/on_life()
	if(owner.stat == DEAD && stage < 5) //If larva is below stage 5, and host is dead, the larva also "dies"
		return

	switch(stage)
		if(2, 3)
			if(prob(2))
				owner.emote("sneeze")
			if(prob(2))
				owner.emote("cough")
			if(prob(2))
				to_chat(owner, "<span class='danger'>Your throat feels sore.</span>")
			if(prob(2))
				to_chat(owner, "<span class='danger'>Mucous runs down the back of your throat.</span>")
		if(4)
			if(prob(2))
				owner.emote("sneeze")
			if(prob(2))
				owner.emote("cough")
			if(prob(4))
				to_chat(owner, "<span class='danger'>Your muscles ache.</span>")
				if(prob(20))
					owner.take_organ_damage(1)
			if(prob(4))
				to_chat(owner, "<span class='danger'>Your stomach hurts.</span>")
				if(prob(20))
					owner.adjustToxLoss(1)
		if(5)
			owner.visible_message("<span class='danger'>[owner]'s stomach begins to distend in a unnatural way!", \
						"<span class='userdanger'>You feel something tearing its way out of your stomach...</span>")
			owner.adjustToxLoss(10)

/obj/item/organ/internal/body_egg/alien_embryo/egg_process()
	if(owner.stat == DEAD && stage < 5) //If larva is below stage 5, and host is dead, the larva also "dies"
		return

	if(stage < 5 && prob(3))
		stage++
		spawn(0)
			RefreshInfectionImage()

	if(stage == 5 && prob(50))
		for(var/datum/surgery/S in owner.surgeries)
			if(S.location == "chest" && istype(S.get_surgery_step(), /datum/surgery_step/internal/manipulate_organs))
				AttemptGrow(TRUE)
				return
		AttemptGrow()



/obj/item/organ/internal/body_egg/alien_embryo/proc/AttemptGrow(var/chest_not_open = TRUE)
	if(!owner || polling)
		return
	polling = 1
	spawn()
		var/list/candidates = pollCandidates("Do you want to play as an alien?", ROLE_ALIEN, 0)
		var/mob/C = null

		// To stop clientless larva, we will check that our host has a client
		// if we find no ghosts to become the alien. If the host has a client
		// he will become the alien but if he doesn't then we will set the stage
		// to 2, so we don't do a process heavy check everytime.

		if(candidates.len)
			C = pick(candidates)
		else if(owner.client)
			C = owner.client
		else
			stage = 2 // Let's try again later.
			polling = 0
			return

		var/overlay = image('icons/mob/alien.dmi', loc = owner, icon_state = "burst_lie")
		owner.overlays += overlay

		spawn(6)
			var/mob/living/carbon/alien/larva/new_xeno = new(owner.drop_location())
			new_xeno.key = C.key
			if(SSticker && SSticker.mode)
				SSticker.mode.xenos += new_xeno.mind
			new_xeno.mind.name = new_xeno.name
			new_xeno.mind.assigned_role = SPECIAL_ROLE_XENOMORPH
			new_xeno.mind.special_role = SPECIAL_ROLE_XENOMORPH
			new_xeno << sound('sound/voice/hiss5.ogg',0,0,0,100)//To get the player's attention

			var/list/organs = owner.get_organs_zone("chest")

			if(chest_not_open) //Whether or not the patient's chest is open, if not, massive internal trauma
				for(var/obj/item/organ/internal/O in organs) //Slightly low chance for organs to get heavily damaged, otherwise, are destroyed
					if(prob(60))
						qdel(O)
					else
						O.receive_damage(rand(70, 90),0)

				owner.adjustBruteLoss(rand(90, 140))
				playsound(src.loc, 'sound/goonstation/effects/gib.ogg', 50, 1)

			else
				owner.adjustBruteLoss(40)

			owner.overlays -= overlay
			RemoveInfectionImages(owner)
			qdel(src)

/*----------------------------------------
Proc: AddInfectionImages(C)
Des: Adds the infection image to all aliens for this embryo
----------------------------------------*/
/obj/item/organ/internal/body_egg/alien_embryo/AddInfectionImages()
	for(var/mob/living/carbon/alien/alien in GLOB.player_list)
		if(alien.client)
			var/I = image('icons/mob/alien.dmi', loc = owner, icon_state = "infected[stage]")
			alien.client.images += I

/*----------------------------------------
Proc: RemoveInfectionImage(C)
Des: Removes all images from the mob infected by this embryo
----------------------------------------*/
/obj/item/organ/internal/body_egg/alien_embryo/RemoveInfectionImages()
	for(var/mob/living/carbon/alien/alien in GLOB.player_list)
		if(alien.client)
			for(var/image/I in alien.client.images)
				if(dd_hasprefix_case(I.icon_state, "infected") && I.loc == owner)
					qdel(I)
