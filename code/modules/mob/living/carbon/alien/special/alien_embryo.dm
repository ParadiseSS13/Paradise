// This is to replace the previous datum/disease/alien_embryo for slightly improved handling and maintainability
// It functions almost identically (see code/datums/diseases/alien_embryo.dm)
var/const/ALIEN_AFK_BRACKET = 450 // 45 seconds

/obj/item/organ/internal/body_egg/alien_embryo
	name = "alien embryo"
	desc = "All slimy and yuck."
	icon = 'icons/mob/alien.dmi'
	icon_state = "larva0_dead"
	var/mob/living/affected_mob
	var/stage = 0

/obj/item/organ/internal/body_egg/alien_embryo/on_find(mob/living/finder)
	..()
	if(stage < 4)
		finder << "It's small and weak, barely the size of a foetus."
	else
		finder << "It's grown quite large, and writhes slightly as you look at it."
		if(prob(10))
			AttemptGrow(0)

/obj/item/organ/internal/body_egg/alien_embryo/prepare_eat()
	var/obj/S = ..()
	S.reagents.add_reagent("sacid", 10)
	return S

/obj/item/organ/internal/body_egg/alien_embryo/on_life()
	switch(stage)
		if(2, 3)
			if(prob(2))
				owner.emote("sneeze")
			if(prob(2))
				owner.emote("cough")
			if(prob(2))
				owner << "<span class='danger'>Your throat feels sore.</span>"
			if(prob(2))
				owner << "<span class='danger'>Mucous runs down the back of your throat.</span>"
		if(4)
			if(prob(2))
				owner.emote("sneeze")
			if(prob(2))
				owner.emote("cough")
			if(prob(4))
				owner << "<span class='danger'>Your muscles ache.</span>"
				if(prob(20))
					owner.take_organ_damage(1)
			if(prob(4))
				owner << "<span class='danger'>Your stomach hurts.</span>"
				if(prob(20))
					owner.adjustToxLoss(1)
		if(5)
			owner << "<span class='danger'>You feel something tearing its way out of your stomach...</span>"
			owner.adjustToxLoss(10)

/obj/item/organ/internal/body_egg/alien_embryo/egg_process()
	if(!affected_mob)	return
	if(loc != affected_mob)
		affected_mob.status_flags &= ~(XENO_HOST)
		if(istype(affected_mob,/mob/living/carbon))
			var/mob/living/carbon/H = affected_mob
			H.med_hud_set_status()
		processing_objects.Remove(src)
		spawn(0)
			RemoveInfectionImages(affected_mob)
			affected_mob = null
		return

	if(stage < 5 && prob(3))
		stage++
		spawn(0)
			RefreshInfectionImage()


	if(stage == 5 && prob(50))
		//for(var/datum/surgery/S in owner.surgeries)
		//	if(S.location == "chest" && istype(S.get_surgery_step(), /datum/surgery_step/manipulate_organs))
		//		AttemptGrow(0)
		//		return
		AttemptGrow()

/obj/item/organ/internal/body_egg/alien_embryo/proc/AttemptGrow(var/gib_on_success = 1)
	var/list/candidates = get_candidates(BE_ALIEN,ALIEN_AFK_BRACKET,1)
	var/client/C = null

	// To stop clientless larva, we will check that our host has a client
	// if we find no ghosts to become the alien. If the host has a client
	// he will become the alien but if he doesn't then we will set the stage
	// to 2, so we don't do a process heavy check everytime.

	if(candidates.len)
		C = pick(candidates)
	else if(affected_mob.client)
		C = affected_mob.client
	else
		stage = 4 // Let's try again later.
		return

	if(affected_mob.lying)
		affected_mob.overlays += image('icons/mob/alien.dmi', loc = affected_mob, icon_state = "burst_lie")
	else
		affected_mob.overlays += image('icons/mob/alien.dmi', loc = affected_mob, icon_state = "burst_stand")
	spawn(6)
		var/mob/living/carbon/alien/larva/new_xeno = new(affected_mob.loc)
		new_xeno.key = C.key
		if(ticker && ticker.mode)
			ticker.mode.xenos += new_xeno.mind
		new_xeno.mind.name = new_xeno.name
		new_xeno.mind.assigned_role = "MODE"
		new_xeno.mind.special_role = "Alien"
		new_xeno << sound('sound/voice/hiss5.ogg',0,0,0,100)	//To get the player's attention
		if(gib_on_success)
			affected_mob.gib()
		if(istype(new_xeno.loc,/mob/living/carbon))
			var/mob/living/carbon/digester = new_xeno.loc
			digester.stomach_contents += new_xeno
		qdel(src)

/*----------------------------------------
Proc: RefreshInfectionImage()
Des: Removes the current icons located in the infected mob adds the current stage
----------------------------------------*/
/obj/item/organ/internal/body_egg/alien_embryo/RefreshInfectionImage()
	RemoveInfectionImages()
	AddInfectionImages()

/*----------------------------------------
Proc: AddInfectionImages(C)
Des: Adds the infection image to all aliens for this embryo
----------------------------------------*/
/obj/item/organ/internal/body_egg/alien_embryo/AddInfectionImages()
	for(var/mob/living/carbon/alien/alien in player_list)
		if(alien.client)
			var/I = image('icons/mob/alien.dmi', loc = affected_mob, icon_state = "infected[stage]")
			alien.client.images += I

/*----------------------------------------
Proc: RemoveInfectionImage(C)
Des: Removes all images from the mob infected by this embryo
----------------------------------------*/
/obj/item/organ/internal/body_egg/alien_embryo/RemoveInfectionImages()
	for(var/mob/living/carbon/alien/alien in player_list)
		if(alien.client)
			for(var/image/I in alien.client.images)
				if(dd_hasprefix_case(I.icon_state, "infected") && I.loc == affected_mob)
					qdel(I)