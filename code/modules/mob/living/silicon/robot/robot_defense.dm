/mob/living/silicon/robot/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(M.a_intent == INTENT_DISARM)
		if(mobility_flags & MOBILITY_MOVE)
			M.do_attack_animation(src, ATTACK_EFFECT_DISARM)
			var/obj/item/I = get_active_hand()
			if(I)
				uneq_active()
				visible_message(SPAN_DANGER("[M] disarmed [src]!"), SPAN_USERDANGER("[M] has disabled [src]'s active module!"))
				add_attack_logs(M, src, "alien disarmed")
			else
				adjustStaminaLoss(30) //Same as carbons, I guess?
				step(src, get_dir(M,src))
				add_attack_logs(M, src, "Alien pushed over")
				visible_message(SPAN_DANGER("[M] forces back [src]!"), SPAN_USERDANGER("[M] forces back [src]!"))
			playsound(loc, 'sound/weapons/pierce.ogg', 50, TRUE, -1)
	else
		..()
	return

/mob/living/silicon/robot/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime shock
		var/stunprob = M.powerlevel * 7 + 10
		if(prob(stunprob) && M.powerlevel >= 8)
			adjustBruteLoss(M.powerlevel * rand(6,10))

	var/damage = rand(1, 3)

	if(M.is_adult)
		damage = rand(20, 40)
	else
		damage = rand(5, 35)
	damage = round(damage / 2) // borgs receive half damage
	adjustBruteLoss(damage)
	return

/mob/living/silicon/robot/attack_ai(mob/user)
	if(user.a_intent == INTENT_HELP && is_ai(user))
		to_chat(src, SPAN_ROBOTEMOTE("[user] gives you a digital headpat."))
		to_chat(user, SPAN_ROBOTEMOTE("You give [src] a digital headpat."))

/mob/living/silicon/robot/attack_hand(mob/living/carbon/human/user)
	add_fingerprint(user)

	if(opened && !wiresexposed && !issilicon(user))
		if(cell)
			cell.update_icon()
			cell.add_fingerprint(user)
			user.put_in_active_hand(cell)
			to_chat(user, SPAN_NOTICE("You remove \the [cell]."))
			var/datum/robot_component/C = components["power cell"]
			C.uninstall()
			module?.update_cells(TRUE)
			diag_hud_set_borgcell()

	if(!opened)
		if(..()) // hulk attack
			spark_system.start()
			spawn(0)
				step_away(src, user, 15)
				sleep(3)
				step_away(src, user, 15)

/mob/living/silicon/robot/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, laser_pointer = FALSE, flash_type = /atom/movable/screen/fullscreen/stretch/flash/noise)
	if(!affect_silicon || !can_be_flashed())
		return
	Confused(intensity * 4 SECONDS)
	var/software_damage = (intensity * 40)
	adjustStaminaLoss(software_damage)
	to_chat(src, SPAN_WARNING("Error: Optical sensors overstimulated."))
	..()
