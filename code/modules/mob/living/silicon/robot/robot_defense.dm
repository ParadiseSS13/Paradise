/mob/living/silicon/robot/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(M.a_intent == INTENT_DISARM)
		if(!lying)
			M.do_attack_animation(src, ATTACK_EFFECT_DISARM)
			var/obj/item/I = get_active_hand()
			if(I)
				uneq_active()
				visible_message("<span class='danger'>[M] disarmed [src]!</span>", "<span class='userdanger'>[M] has disabled [src]'s active module!</span>")
				add_attack_logs(M, src, "alien disarmed")
			else
				Stun(2)
				step(src, get_dir(M,src))
				add_attack_logs(M, src, "Alien pushed over")
				visible_message("<span class='danger'>[M] forces back [src]!</span>", "<span class='userdanger'>[M] forces back [src]!</span>")
			playsound(loc, 'sound/weapons/pierce.ogg', 50, TRUE, -1)
	else
		..()
	return

/mob/living/silicon/robot/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime shock
		flash_eyes(affect_silicon = 1)
		var/stunprob = M.powerlevel * 7 + 10
		if(prob(stunprob) && M.powerlevel >= 8)
			adjustBruteLoss(M.powerlevel * rand(6,10))

	var/damage = rand(1, 3)

	if(M.age_state.age != SLIME_BABY)
		damage = rand(20 + M.age_state.damage, 40 + M.age_state.damage)
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
			var/datum/robot_component/C = components["power cell"]
			C.installed = 0
			C.uninstall()
			diag_hud_set_borgcell()

	if(!opened)
		if(..()) // hulk attack
			spark_system.start()
			spawn(0)
				step_away(src, user, 15)
				sleep(3)
				step_away(src, user, 15)
