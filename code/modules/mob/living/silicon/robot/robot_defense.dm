/mob/living/silicon/robot/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(M.a_intent == INTENT_DISARM)
		if(!lying)
			M.do_attack_animation(src, ATTACK_EFFECT_DISARM)
			if(prob(85))
				Stun(7)
				step(src, get_dir(M,src))
				spawn(5)
					step(src, get_dir(M,src))
				add_attack_logs(M, src, "Alien pushed over")
				playsound(loc, 'sound/weapons/pierce.ogg', 50, 1, -1)
				visible_message("<span class='danger'>[M] has forced back [src]!</span>",\
								"<span class='userdanger'>[M] has forced back [src]!</span>")
			else
				playsound(loc, 'sound/weapons/slashmiss.ogg', 25, 1, -1)
				visible_message("<span class='danger'>[M] took a swipe at [src]!</span>",\
								"<span class='userdanger'>[M] took a swipe at [src]!</span>")
	else
		..()
	return

/mob/living/silicon/robot/attack_slime(mob/living/carbon/slime/M)
	if(..()) //successful slime shock
		flash_eyes(affect_silicon = 1)
		var/stunprob = M.powerlevel * 7 + 10
		if(prob(stunprob) && M.powerlevel >= 8)
			adjustBruteLoss(M.powerlevel * rand(6,10))

	var/damage = rand(1, 3)

	if(M.is_adult)
		damage = rand(20, 40)
	else
		damage = rand(5, 35)
	damage = round(damage / 2) // borgs recieve half damage
	adjustBruteLoss(damage)
	return

/mob/living/silicon/robot/attack_hand(mob/living/carbon/human/user)
	add_fingerprint(user)

	if(opened && !wiresexposed && !issilicon(user))
		if(cell)
			cell.update_icon()
			cell.add_fingerprint(user)
			user.put_in_active_hand(cell)
			to_chat(user, "<span class='notice'>You remove \the [cell].</span>")
			cell = null
			update_stat()
			diag_hud_set_borgcell()

	if(!opened)
		if(..()) // hulk attack
			spark_system.start()
			spawn(0)
				step_away(src, user, 15)
				sleep(3)
				step_away(src, user, 15)
