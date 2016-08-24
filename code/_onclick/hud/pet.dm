/mob/living/simple_animal/pet/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/corgi(src)

/datum/hud/corgi/New(mob/user)
	..()

	healths = new /obj/screen/healths/corgi()
	infodisplay += healths

	pull_icon = new /obj/screen/pull()
	pull_icon = 'icons/mob/screen_corgi.dmi'
	pull_icon.update_icon(mymob)
	pull_icon.screen_loc = ui_construct_pull
	static_inventory += pull_icon
