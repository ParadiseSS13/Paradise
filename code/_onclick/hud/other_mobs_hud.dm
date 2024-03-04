/mob/living/simple_animal/create_mob_hud()
	hud_used = new /datum/hud/simple_animal(src)

/datum/hud/simple_animal/New(mob/user)
	..()

	mymob.healths = new /atom/movable/screen/healths()
	infodisplay += mymob.healths

	var/atom/movable/screen/using
	using = new /atom/movable/screen/act_intent/simple_animal()
	using.icon_state = mymob.a_intent
	static_inventory += using
	action_intent = using


/mob/living/simple_animal/pet/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/corgi(src)

/datum/hud/corgi/New(mob/user)
	..()

	mymob.healths = new /atom/movable/screen/healths/corgi()
	infodisplay += mymob.healths

	mymob.pullin = new /atom/movable/screen/pull()
	mymob.pullin.icon = 'icons/mob/screen_corgi.dmi'
	mymob.pullin.hud = src
	mymob.pullin.update_icon(UPDATE_ICON_STATE)
	mymob.pullin.screen_loc = ui_construct_pull
	static_inventory += mymob.pullin
