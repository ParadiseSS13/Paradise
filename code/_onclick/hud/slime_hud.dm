/datum/hud/slime/New(mob/living/simple_animal/slime/owner, ui_style = 'icons/mob/screen_slime.dmi')
	..()
	mymob.healths = new /obj/screen/healths/slime()
	infodisplay += mymob.healths

/mob/living/simple_animal/slime/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/slime(src)
