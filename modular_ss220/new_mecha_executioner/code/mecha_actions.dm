/obj/mecha
	var/datum/action/innate/mecha/flash/flash_action = new
/datum/action/innate/mecha/flash
	name = "Святой огонь"
	desc = "Очистите оскверненных тварей с помощью святого света!"
	icon_icon = 'modular_ss220/new_mecha_executioner/icons/actions_mecha.dmi'
	button_icon_state = "holyflash"

/datum/action/innate/mecha/flash/proc/flash_carbon(mob/living/carbon/M, mob/user = null, power = 5)
	if(user)
		add_attack_logs(user, M, "Flashed with [chassis]")
		if(M.flash_eyes(1, 1))
			M.AdjustConfused(power)
			M.Stun(5)
			M.Weaken(10)
			to_chat(user, "<span class='danger'>Вы ослепили [M] священным светом!</span>")
			to_chat(M, "<span class='userdanger'>[chassis] ослепил Вас с помощью священного света!</span>")
		else
			to_chat(user, "<span class='warning'>Вам не удалось ослепить [M] священным светом!</span>")
			to_chat(M, "<span class='danger'>[chassis] не смог ослепить вас с помощью священного света!</span>")
		return

/datum/action/innate/mecha/flash/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	if(chassis.flash_ready)
		chassis.visible_message("<span class='disarm'>[chassis] испускает ослепляющий святой свет!</span>", "<span class='danger'>Твой [chassis] испускает ослепляющий святой свет!</span>")
		for(var/mob/living/carbon/M in oview(3, chassis))
			flash_carbon(M, chassis.occupant, 3, FALSE)
		chassis.flash_ready = FALSE
		spawn(chassis.flash_cooldown)
			chassis.flash_ready = TRUE
	else
		chassis.occupant_message("<span class='warning'>Святой свет ещё не готов!</span>")
