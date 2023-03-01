/datum/event/dust/meaty/announce()
	if(prob(16))
		GLOB.event_announcement.Announce("Неизвестные биологические объекты были обнаружены рядом с [station_name()], пожалуйста, будьте наготове.", "ВНИМАНИЕ: НЕОПОЗНАННЫЕ ФОРМЫ ЖИЗНИ.")
	else
		GLOB.event_announcement.Announce("На пути станции были обнаружены мясориты.", "ВНИМАНИЕ: МЯСОРИТЫ.", new_sound = 'sound/AI/meteors.ogg')

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
	shake_chance = 20

/obj/effect/space_dust/meaty/impact_meteor(atom/A)
	new /obj/effect/decal/cleanable/blood(get_turf(A))
	..()

/obj/effect/space_dust/meaty/on_shatter(turf/where)
	if(prob(80))
		gibs(where)
		if(prob(45))
			new /obj/item/reagent_containers/food/snacks/meat(where)
		else if(prob(10))
			explosion(where, 0, pick(0,1), pick(2,3), 0, cause = src)
	else
		new /mob/living/simple_animal/cow(where)
