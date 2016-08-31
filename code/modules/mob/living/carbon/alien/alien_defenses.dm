/mob/living/carbon/alien/hitby(atom/movable/AM)
	..(AM, 1)

/*Code for aliens attacking aliens. Because aliens act on a hivemind, I don't see them as very aggressive with each other.
As such, they can either help or harm other aliens. Help works like the human help command while harm is a simple nibble.
In all, this is a lot like the monkey code. /N
*/
/mob/living/carbon/alien/attack_alien(mob/living/carbon/alien/M as mob)
	if(!ticker)
		to_chat(M, "You cannot attack people before the game has started.")
		return

	if(istype(loc, /turf) && istype(loc.loc, /area/start))
		to_chat(M, "No attacking people at spawn, you jackass.")
		return

	switch(M.a_intent)

		if(I_HELP)
			sleeping = max(0,sleeping-5)
			resting = 0
			AdjustParalysis(-3)
			AdjustStunned(-3)
			AdjustWeakened(-3)
			visible_message("<span class='notice'>[M.name] nuzzles [src] trying to wake it up!</span>")

		if(I_GRAB)
			src.grabbedby(M)
			return 1

		else
			if(health > 0)
				playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
				var/damage = 1
				visible_message("<span class='danger'>[M.name] bites [src]!</span>", \
						"<span class='userdanger'>[M.name] bites [src]!</span>")
				adjustBruteLoss(damage)
				add_logs(M, src, "attacked", admin=0)
				updatehealth()
			else
				to_chat(M, "<span class='warning'>[name] is too injured for that.</span>")
	return


/mob/living/carbon/alien/attack_larva(mob/living/carbon/alien/larva/L as mob)
	return attack_alien(L)


/mob/living/carbon/alien/attack_hand(mob/living/carbon/human/M as mob)
	if(..())	//to allow surgery to return properly.
		return 0
	if(istype(src,/mob/living/carbon/alien/humanoid))
		return 0 //this is horrible but 100% necessary

	switch(M.a_intent)
		if(I_HELP)
			help_shake_act(M)
		if(I_GRAB)
			src.grabbedby(M)
		if(I_HARM, I_DISARM)
			return 1
	return 0



/mob/living/carbon/alien/attack_animal(mob/living/simple_animal/M as mob)
	if(..())
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		switch(M.melee_damage_type)
			if(BRUTE)
				adjustBruteLoss(damage)
			if(BURN)
				adjustFireLoss(damage)
			if(TOX)
				adjustToxLoss(damage)
			if(OXY)
				adjustOxyLoss(damage)
			if(CLONE)
				adjustCloneLoss(damage)
			if(STAMINA)
				adjustStaminaLoss(damage)
		updatehealth()
