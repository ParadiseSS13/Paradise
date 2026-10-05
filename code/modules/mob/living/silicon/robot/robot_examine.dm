/mob/living/silicon/robot/examine(mob/user)
	. = ..()

	var/msg = "<span class='notice'>"
	if(module)
		msg += "[p_they(TRUE)] [p_have()] loaded a [module.name].\n"
	var/obj/act_module = get_active_hand()
	if(act_module)
		msg += "[p_they(TRUE)] [p_are()] holding [bicon(act_module)] \a [act_module].\n"
	msg += "<span class='warning'>"
	if(getBruteLoss())
		if(getBruteLoss() < maxHealth*0.5)
			msg += "[p_they(TRUE)] look[p_s()] slightly dented.\n"
		else
			msg += "<b>[p_they(TRUE)] look[p_s()] severely dented!</b>\n"
	if(getFireLoss())
		if(getFireLoss() < maxHealth*0.5)
			msg += "[p_they(TRUE)] look[p_s()] slightly charred.\n"
		else
			msg += "<b>[p_they(TRUE)] look[p_s()] severely burnt and heat-warped!</b>\n"
	if(health < -maxHealth*0.5)
		msg += "[p_they(TRUE)] look[p_s()] barely operational.\n"
	if(fire_stacks < 0)
		msg += "[p_theyre(TRUE)] covered in water.\n"
	else if(fire_stacks > 0)
		msg += "[p_theyre(TRUE)] coated in something flammable.\n"
	msg += "</span>"

	if(opened)
		msg += "[SPAN_WARNING("[p_their(TRUE)] cover is open and [p_their()] power cell is [cell ? "installed" : "missing"].")]\n"
	else
		msg += "[p_their(TRUE)] cover is closed[locked ? "" : ", and looks unlocked"].\n"

	if(cell && cell.charge <= 0)
		msg += "[SPAN_WARNING("[p_their(TRUE)] battery indicator is blinking red!")]\n"

	if(shell)
		msg += "It appears to be an [deployed ? "active" : "empty"] AI shell.\n"
	else
		switch(stat)
			if(CONSCIOUS)
				if(!client)
					msg += "[p_they(TRUE)] appear[p_s()] to be in stand-by mode.\n" //afk
			if(UNCONSCIOUS)
				msg += "[SPAN_WARNING("[p_they(TRUE)] [p_do()]n't seem to be responding.")]\n"
			if(DEAD)
				if(!suiciding)
					msg += "[SPAN_DEADSAY("It looks like [p_their()] internal subsystems are beyond repair and require replacing.")]\n"
				else
					msg += "[SPAN_WARNING("It looks like [p_their()] system is corrupted beyond repair. There is no hope of recovery.")]\n"
	msg += "</span>"

	if(print_flavor_text())
		msg += "\n[print_flavor_text()]\n"

	if(pose)
		if(findtext(pose,".",length(pose)) == 0 && findtext(pose,"!",length(pose)) == 0 && findtext(pose,"?",length(pose)) == 0)
			pose = addtext(pose,".") //Makes sure all emotes end with a period.
		msg += "\nIt [pose]"

	. += msg
	user.showLaws(src)
