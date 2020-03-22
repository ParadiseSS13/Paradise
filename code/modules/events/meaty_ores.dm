/datum/event/dust/meaty/announce()
	if(prob(16))
		GLOB.event_announcement.Announce("Unknown biological entities have been detected near [station_name()], please stand-by.", "Lifesign Alert")
	else
		GLOB.event_announcement.Announce("Meaty ores have been detected on collision course with the station.", "Meaty Ore Alert", new_sound = 'sound/AI/meteors.ogg')

/datum/event/dust/meaty/setup()
	qnty = rand(45,125)

/datum/event/dust/meaty/start()
	while(qnty-- > 0)
		new /obj/effect/space_dust/meaty()
		if(prob(10))
			sleep(rand(10,15))

/obj/effect/space_dust/meaty
	icon = 'icons/mob/animal.dmi'
	icon_state = "cow"

	strength = 1
	life = 3

/obj/effect/space_dust/meaty/Bump(atom/A)
	if(prob(20))
		spawn(1)
			for(var/mob/M in range(10, src))
				if(!M.stat && !istype(M, /mob/living/silicon/ai))
					shake_camera(M, 3, 1)
	if(A)
		playsound(src.loc, 'sound/effects/meteorimpact.ogg', 40, 1)
		walk(src,0)
		invisibility = 101
		new /obj/effect/decal/cleanable/blood(get_turf(A))
		if(ismob(A))
			A.ex_act(strength)
		else
			spawn(0)
				if(A)
					A.ex_act(strength)
				if(src)
					walk_towards(src,goal,1)
		life--
		if(!life)
			if(prob(80))
				gibs(loc)
				if(prob(45))
					new /obj/item/reagent_containers/food/snacks/meat(loc)
				else if(prob(10))
					explosion(get_turf(loc), 0, pick(0,1), pick(2,3), 0)
			else
				new /mob/living/simple_animal/cow(loc)

			qdel(src)
