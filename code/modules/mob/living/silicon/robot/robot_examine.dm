/mob/living/silicon/robot/examine(mob/user)
	. = ..()

	var/msg = "<span class='notice'>"
	if(module)
		msg += "[src.p_they(TRUE)] has loaded a [module.name].\n"
	var/obj/act_module = get_active_hand()
	if(act_module)
		msg += "[src.p_they(TRUE)] [src.p_are()] holding [bicon(act_module)] \a [act_module].\n"
	msg += "<span class='warning'>"
	if(getBruteLoss())
		if(getBruteLoss() < maxHealth*0.5)
			msg += "[src.p_they(TRUE)] look[src.p_s()] slightly dented.\n"
		else
			msg += "<b>[src.p_they(TRUE)] look[src.p_s()] severely dented!</b>\n"
	if(getFireLoss())
		if(getFireLoss() < maxHealth*0.5)
			msg += "[src.p_they(TRUE)] look[src.p_s()] slightly charred.\n"
		else
			msg += "<b>[src.p_they(TRUE)] look[src.p_s()] severely burnt and heat-warped!</b>\n"
	if(health < -maxHealth*0.5)
		msg += "[src.p_they(TRUE)] look[src.p_s()] barely operational.\n"
	if(fire_stacks < 0)
		msg += "[src.p_theyre(TRUE)] covered in water.\n"
	else if(fire_stacks > 0)
		msg += "[src.p_theyre(TRUE)] coated in something flammable.\n"
	msg += "</span>"

	if(opened)
		msg += "[SPAN_WARNING("[src.p_their(TRUE)] cover is open and the power cell is [cell ? "installed" : "missing"].")]\n"
	else
		msg += "[src.p_their(TRUE)] cover is closed[locked ? "" : ", and looks unlocked"].\n"

	if(cell && cell.charge <= 0)
		msg += "[SPAN_WARNING("[src.p_their(TRUE)] battery indicator is blinking red!")]\n"

	switch(stat)
		if(CONSCIOUS)
			if(!client)
				msg += "[src.p_they(TRUE)] appear[src.p_s()] to be in stand-by mode.\n" //afk
		if(UNCONSCIOUS)
			msg += "[SPAN_WARNING("[src.p_they(TRUE)] [src.p_do()]n't seem to be responding.")]\n"
		if(DEAD)
			if(!suiciding)
				msg += "[SPAN_DEADSAY("It looks like [src.p_their()] internal subsystems are beyond repair and require replacing.")]\n"
			else
				msg += "[SPAN_WARNING("It looks like [src.p_their()] system is corrupted beyond repair. There is no hope of recovery.")]\n"
	msg += "</span>"

	if(print_flavor_text())
		msg += "\n[print_flavor_text()]\n"

	if(pose)
		if(findtext(pose,".",length(pose)) == 0 && findtext(pose,"!",length(pose)) == 0 && findtext(pose,"?",length(pose)) == 0)
			pose = addtext(pose,".") //Makes sure all emotes end with a period.
		msg += "\nIt [pose]"

	. += msg
	user.showLaws(src)
