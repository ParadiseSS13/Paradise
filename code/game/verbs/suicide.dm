/mob/var/suiciding = 0

/mob/living/carbon/human/proc/do_suicide(damagetype, byitem)
	var/threshold = check_death_method() ? ((HEALTH_THRESHOLD_CRIT + HEALTH_THRESHOLD_DEAD) / 2) : (HEALTH_THRESHOLD_DEAD - 50)
	var/dmgamt = maxHealth - threshold

	var/damage_mod = 1
	switch(damagetype) //Sorry about the magic numbers.
					   //brute = 1, burn = 2, tox = 4, oxy = 8
		if(15) //4 damage types
			damage_mod = 4

		if(6, 11, 13, 14) //3 damage types
			damage_mod = 3

		if(3, 5, 7, 9, 10, 12) //2 damage types
			damage_mod = 2

		if(1, 2, 4, 8) //1 damage type
			damage_mod = 1

		else //This should not happen, but if it does, everything should still work
			damage_mod = 1

	//Do dmgamt damage divided by the number of damage types applied.
	if(damagetype & BRUTELOSS)
		adjustBruteLoss(dmgamt / damage_mod, FALSE)

	if(damagetype & FIRELOSS)
		adjustFireLoss(dmgamt / damage_mod, FALSE)

	if(damagetype & TOXLOSS)
		adjustToxLoss(dmgamt / damage_mod, FALSE)

	if(damagetype & OXYLOSS)
		adjustOxyLoss(dmgamt / damage_mod, FALSE)

	// Failing that...
	if(!(damagetype & BRUTELOSS) && !(damagetype & FIRELOSS) && !(damagetype & TOXLOSS) && !(damagetype & OXYLOSS))
		if(NO_BREATHE in dna.species.species_traits)
			// the ultimate fallback
			take_overall_damage(max(dmgamt - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0), 0, updating_health = FALSE)
		else
			adjustOxyLoss(max(dmgamt - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0), FALSE)

	var/obj/item/organ/external/affected = get_organ("head")
	if(affected)
		affected.add_autopsy_data(byitem ? "Suicide by [byitem]" : "Suicide", dmgamt)

	updatehealth()

/mob/living/carbon/human/verb/suicide()
	set hidden = 1

	be_suicidal()

/mob/living/carbon/human/proc/be_suicidal(forced = FALSE)
	if(stat == DEAD)
		to_chat(src, "You're already dead!")
		return

	if(!SSticker)
		to_chat(src, "You can't commit suicide before the game starts!")
		return

	// No more borergrief, one way or the other
	if(has_brain_worms())
		to_chat(src, "You try to bring yourself to commit suicide, but - something prevents you!")
		return

	if(suiciding)
		to_chat(src, "You're already committing suicide! Be patient!")
		return


	var/confirm = null
	if(!forced)
		confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(forced || (confirm == "Yes"))
		suiciding = TRUE
		var/obj/item/held_item = get_active_hand()
		if(held_item)
			var/damagetype = held_item.suicide_act(src)
			if(damagetype)
				if(damagetype & SHAME)
					adjustStaminaLoss(200)
					suiciding = FALSE
					return
				if(damagetype & OBLITERATION) // Does it gib or something? Don't deal damage
					return
				do_suicide(damagetype, held_item)
				return
		else
			for(var/obj/O in orange(1, src))
				if(O.suicidal_hands)
					continue
				var/damagetype = O.suicide_act(src)
				if(damagetype)
					if(damagetype & SHAME)
						adjustStaminaLoss(200)
						suiciding = FALSE
						return
					if(damagetype & OBLITERATION)
						return
					do_suicide(damagetype, O)
					return

		to_chat(viewers(src), "<span class='danger'>[src] [replacetext(pick(dna.species.suicide_messages), "their", p_their())] It looks like [p_theyre()] trying to commit suicide.</span>")
		do_suicide(0)

/mob/living/carbon/brain/verb/suicide()
	set hidden = 1

	if(stat == 2)
		to_chat(src, "You're already dead!")
		return

	if(!SSticker)
		to_chat(src, "You can't commit suicide before the game starts!")
		return

	if(suiciding)
		to_chat(src, "You're already committing suicide! Be patient!")
		return

	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		suiciding = 1
		to_chat(viewers(loc), "<span class='danger'>[src]'s brain is growing dull and lifeless. It looks like it's lost the will to live.</span>")
		spawn(50)
			death(0)
			suiciding = 0


/mob/living/silicon/ai/verb/suicide()
	set hidden = 1

	if(stat == 2)
		to_chat(src, "You're already dead!")
		return

	if(suiciding)
		to_chat(src, "You're already committing suicide! Be patient!")
		return

	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		suiciding = 1
		to_chat(viewers(src), "<span class='danger'>[src] is powering down. It looks like [p_theyre()] trying to commit suicide.</span>")
		//put em at -175
		adjustOxyLoss(max(maxHealth * 2 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))

/mob/living/silicon/robot/verb/suicide()
	set hidden = 1

	if(stat == 2)
		to_chat(src, "You're already dead!")
		return

	if(suiciding)
		to_chat(src, "You're already committing suicide! Be patient!")
		return

	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		suiciding = 1
		to_chat(viewers(src), "<span class='danger'>[src] is powering down. It looks like [p_theyre()] trying to commit suicide.</span>")
		//put em at -175
		adjustOxyLoss(max(maxHealth * 2 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))

/mob/living/silicon/pai/verb/suicide()
	set category = "pAI Commands"
	set desc = "Kill yourself and become a ghost (You will receive a confirmation prompt)"
	set name = "pAI Suicide"
	var/answer = input("REALLY kill yourself? This action can't be undone.", "Suicide", "No") in list ("Yes", "No")
	if(answer == "Yes")
		if(canmove || resting)
			close_up()
		var/obj/item/paicard/card = loc
		card.removePersonality()
		var/turf/T = get_turf_or_move(card.loc)
		for(var/mob/M in viewers(T))
			M.show_message("<span class='notice'>[src] flashes a message across its screen, \"Wiping core files. Please acquire a new personality to continue using pAI device functions.\"</span>", 3, "<span class='notice'>[src] bleeps electronically.</span>", 2)
		death(0, 1)
	else
		to_chat(src, "Aborting suicide attempt.")

/mob/living/carbon/alien/humanoid/verb/suicide()
	set hidden = 1

	if(stat == 2)
		to_chat(src, "You're already dead!")
		return

	if(suiciding)
		to_chat(src, "You're already committing suicide! Be patient!")
		return

	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		suiciding = 1
		to_chat(viewers(src), "<span class='danger'>[src] is thrashing wildly! It looks like [p_theyre()] trying to commit suicide.</span>")
		//put em at -175
		adjustOxyLoss(max(175 - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))


/mob/living/simple_animal/slime/verb/suicide()
	set hidden = 1
	if(stat == 2)
		to_chat(src, "You're already dead!")
		return

	if(suiciding)
		to_chat(src, "You're already committing suicide! Be patient!")
		return

	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		suiciding = 1
		setOxyLoss(100, FALSE)
		adjustBruteLoss(100 - getBruteLoss(), FALSE)
		setToxLoss(100, FALSE)
		setCloneLoss(100, FALSE)

		updatehealth()

/mob/living/simple_animal/mouse/verb/suicide()
	set hidden = 1
	if(stat == DEAD)
		to_chat(src, "You're already dead!")
		return
	if(suiciding)
		to_chat(src, "You're already committing suicide! Be patient!")
		return

	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		suiciding = TRUE
		visible_message("<span class='danger'>[src] is playing dead permanently! It looks like [p_theyre()] trying to commit suicide.</span>")
		adjustOxyLoss(max(100 - getBruteLoss(100), 0))
