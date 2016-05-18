/mob/living/simple_animal/hostile/construct/create_mob_hud()
    if(client && !hud_used)
        hud_used = new /datum/hud/construct(src)

/datum/hud/construct/New(mob/owner)
	..()

	var/constructtype

	if(istype(mymob,/mob/living/simple_animal/hostile/construct/armoured) || istype(mymob,/mob/living/simple_animal/hostile/construct/behemoth))
		constructtype = "juggernaut"
	else if(istype(mymob,/mob/living/simple_animal/hostile/construct/builder))
		constructtype = "artificer"
	else if(istype(mymob,/mob/living/simple_animal/hostile/construct/wraith))
		constructtype = "wraith"
	else if(istype(mymob,/mob/living/simple_animal/hostile/construct/harvester))
		constructtype = "harvester"


	if(constructtype)
		mymob.healths = new /obj/screen()
		mymob.healths.icon = 'icons/mob/screen_construct.dmi'
		mymob.healths.icon_state = "[constructtype]_health0"
		mymob.healths.name = "health"
		mymob.healths.screen_loc = ui_construct_health
		infodisplay += mymob.healths

		mymob.pullin = new /obj/screen()
		mymob.pullin.icon = 'icons/mob/screen_construct.dmi'
		mymob.pullin.icon_state = "pull0"
		mymob.pullin.name = "pull"
		mymob.pullin.screen_loc = ui_construct_pull