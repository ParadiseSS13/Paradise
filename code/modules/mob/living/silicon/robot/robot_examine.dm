/mob/living/silicon/robot/examine(mob/user)
	. = ..()

	// this is not necessarily the best way to organize information but since
	// most of the proc already worked in this order this is what i'm doing
	var/list/notice_block = list()
	var/list/warning_block = list()
	var/list/deadsay_block = list()

	if(module)
		notice_block += "It has loaded a [module.name]."
	var/obj/act_module = get_active_hand()
	if(act_module)
		notice_block += "It is holding [bicon(act_module)] \a [act_module]."


	if(getBruteLoss())
		if(getBruteLoss() < maxHealth*0.5)
			warning_block += "It looks slightly dented."
		else
			warning_block += "<B>It looks severely dented!</B>"
	if(getFireLoss())
		if(getFireLoss() < maxHealth*0.5)
			warning_block += "It looks slightly charred."
		else
			warning_block += "<B>It looks severely burnt and heat-warped!</B>"
	if(health < -maxHealth*0.5)
		warning_block += "It looks barely operational."
	if(fire_stacks < 0)
		warning_block += "It's covered in water."
	else if(fire_stacks > 0)
		warning_block += "It's coated in something flammable."

	if(opened)
		warning_block += "Its cover is open and the power cell is [cell ? "installed" : "missing"]."
	else
		notice_block += "Its cover is closed[locked ? "" : ", and looks unlocked"]."

	if(cell && cell.charge <= 0)
		warning_block += "Its battery indicator is blinking red!"

	switch(stat)
		if(CONSCIOUS)
			if(!client)
				notice_block += "It appears to be in stand-by mode." //afk
		if(UNCONSCIOUS)
			warning_block += "It doesn't seem to be responding."
		if(DEAD)
			if(!suiciding)
				deadsay_block += "It looks like its internal subsystems are beyond repair and require replacing."
			else
				warning_block += "It looks like its system is corrupted beyond repair. There is no hope of recovery."

	if(length(notice_block))
		. += "<span class='notice'>[notice_block.Join("<br>")]</span>"

	if(length(deadsay_block))
		. += "<span class='deadsay'>[deadsay_block.Join("<br>")]</span>"

	if(length(warning_block))
		. += "<span class='warning'>[warning_block.Join("<br>")]</span>"

	if(print_flavor_text())
		. += print_flavor_text()

	// pose always seems to go at the end so that's what we're doing here
	if(pose)
		if(findtext(pose,".",length(pose)) == 0 && findtext(pose,"!",length(pose)) == 0 && findtext(pose,"?",length(pose)) == 0)
			pose = addtext(pose,".") //Makes sure all emotes end with a period.
		. += "<span class='notice'>It [pose]</span>"

	user.showLaws(src)
