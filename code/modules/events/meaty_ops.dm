/datum/event/dust/goreop/announce()
	var/meteor_declaration = "MeteorOps have declared thier intent to utterly destroy [station_name()] with thier own bodies, and dares the crew to try and stop them."
	command_announcement.Announce(meteor_declaration, "Declaration of 'War'", 'sound/effects/siren.ogg')

/datum/event/dust/goreop/setup()
	qnty = rand(45,125)

/datum/event/dust/goreop/start()
	while(qnty-- > 0)
		new /obj/effect/space_dust/gore()
		if(prob(10))
			sleep(rand(10,15))

/obj/effect/space_dust/goreop
	icon = 'icons/mob/animal.dmi'
	icon_state = "syndicaterangedpsace"

	strength = 1
	life = 1

/obj/effect/space_dust/goreop/Bump(atom/A)
	if(prob(20))
		spawn(1)
			for(var/mob/M in range(10, src))
				if(!M.stat && !istype(M, /mob/living/silicon/ai))
					shake_camera(M, 3, 1)
	if (A)
		playsound(src.loc, 'sound/effects/meteorimpact.ogg', 40, 1)
		walk(src,0)
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
					new /obj/item/weapon/reagent_containers/food/snacks/meat(loc)
					new /obj/effect/decal/cleanable/blood/gibs(loc)

			qdel(src)