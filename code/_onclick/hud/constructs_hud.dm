/mob/living/simple_animal/hostile/construct/armoured/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/construct/armoured(src)

/mob/living/simple_animal/hostile/construct/behemoth/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/construct/armoured(src)

/datum/hud/construct/armoured/New(mob/owner)
	..()
	mymob.healths = new /atom/movable/screen()
	mymob.healths.icon = 'icons/mob/screen_construct.dmi'
	mymob.healths.icon_state = "juggernaut_health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_construct_health
	infodisplay += mymob.healths

/mob/living/simple_animal/hostile/construct/builder/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/construct/builder(src)

/datum/hud/construct/builder/New(mob/owner)
	..()
	mymob.healths = new /atom/movable/screen()
	mymob.healths.icon = 'icons/mob/screen_construct.dmi'
	mymob.healths.icon_state = "artificer_health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_construct_health
	infodisplay += mymob.healths

/mob/living/simple_animal/hostile/construct/wraith/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/construct/wraith(src)

/datum/hud/construct/wraith/New(mob/owner)
	..()
	mymob.healths = new /atom/movable/screen()
	mymob.healths.icon = 'icons/mob/screen_construct.dmi'
	mymob.healths.icon_state = "wraith_health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_construct_health
	infodisplay += mymob.healths

/mob/living/simple_animal/hostile/construct/harvester/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/construct/harvester(src)

/datum/hud/construct/harvester/New(mob/owner)
	..()
	mymob.healths = new /atom/movable/screen()
	mymob.healths.icon = 'icons/mob/screen_construct.dmi'
	mymob.healths.icon_state = "harvester_health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_construct_health
	infodisplay += mymob.healths

/datum/hud/construct/New(mob/owner)
	..()
	mymob.pullin = new /atom/movable/screen/pull()
	mymob.pullin.icon = 'icons/mob/screen_construct.dmi'
	mymob.pullin.icon_state = "pull0"
	mymob.pullin.name = "pull"
	mymob.pullin.screen_loc = ui_construct_pull
	var/atom/movable/screen/using
	using = new /atom/movable/screen/act_intent/simple_animal()
	using.icon_state = mymob.a_intent
	static_inventory += using
	action_intent = using
