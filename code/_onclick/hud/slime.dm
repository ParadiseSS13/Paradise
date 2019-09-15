/mob/living/carbon/slime/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/slime(src)

/mob/living/simple_animal/slime/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/slime(src)

/datum/hud/slime/New(mob/owner)
	..()
	mymob.healths = new /obj/screen/healths/slime()
	infodisplay += mymob.healths

	mymob.pullin = new /obj/screen/pull()
	mymob.pullin.icon = 'icons/mob/screen_slime.dmi'
	mymob.pullin.update_icon(mymob)
	mymob.pullin.screen_loc = ui_construct_pull
	hotkeybuttons += mymob.pullin
