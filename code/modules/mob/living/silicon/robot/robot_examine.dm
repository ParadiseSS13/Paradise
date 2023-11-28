/mob/living/silicon/robot/examine(mob/user)
	. = ..()

	var/msg = "<span class='info'>"
	if(module)
		msg += "It has loaded a [module.name].\n"
	var/obj/act_module = get_active_hand()
	if(act_module)
		msg += "It is holding [bicon(act_module)] \a [act_module].\n"
	msg += "<span class='warning'>"
	if(getBruteLoss())
		if(getBruteLoss() < maxHealth*0.5)
			msg += "It looks slightly dented.\n"
		else
			msg += "<B>It looks severely dented!</B>\n"
	if(getFireLoss())
		if(getFireLoss() < maxHealth*0.5)
			msg += "It looks slightly charred.\n"
		else
			msg += "<B>It looks severely burnt and heat-warped!</B>\n"
	if(health < -maxHealth*0.5)
		msg += "It looks barely operational.\n"
	if(fire_stacks < 0)
		msg += "It's covered in water.\n"
	else if(fire_stacks > 0)
		msg += "It's coated in something flammable.\n"
	msg += "</span>"

	if(opened)
		msg += "<span class='warning'>Its cover is open and the power cell is [cell ? "installed" : "missing"].</span>\n"
	else
		msg += "Its cover is closed[locked ? "" : ", and looks unlocked"].\n"

	if(cell && cell.charge <= 0)
		msg += "<span class='warning'>Its battery indicator is blinking red!</span>\n"

	switch(stat)
		if(CONSCIOUS)
			if(!client)
				msg += "It appears to be in stand-by mode.\n" //afk
		if(UNCONSCIOUS)
			msg += "<span class='warning'>It doesn't seem to be responding.</span>\n"
		if(DEAD)
			if(!suiciding)
				msg += "<span class='deadsay'>It looks like its internal subsystems are beyond repair and require replacing.</span>\n"
			else
				msg += "<span class='warning'>It looks like its system is corrupted beyond repair. There is no hope of recovery.</span>\n"
	msg += "</span>"

	if(print_flavor_text())
		msg += "\n[print_flavor_text()]\n"

	if(pose)
		if(findtext(pose,".",length(pose)) == 0 && findtext(pose,"!",length(pose)) == 0 && findtext(pose,"?",length(pose)) == 0)
			pose = addtext(pose,".") //Makes sure all emotes end with a period.
		msg += "\nIt [pose]"

	. += msg
	user.showLaws(src)
