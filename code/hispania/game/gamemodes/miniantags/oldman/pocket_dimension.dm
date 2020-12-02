/mob/living/simple_animal/hostile/oldman/proc/indimension(turf/simulated/wall/T)
	to_chat(viewers(T), "<span class='warning'>[src] starts walking into [T]...</span>")
	if(!do_after(src, 20, target = T))
		return
	forceMove(get_turf(T))
	notransform = TRUE
	incorporeal_move = 3
	density = FALSE
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	dimension = TRUE
	visible_message("<span class='danger'>[src] sinks into [T]!</span>")
	playsound(get_turf(T), 'sound/hispania/effects/oldman/phasing.ogg', 100, 1, -1)
	rust(T)
	icon_state = "entering"
	var/mob/living/kidnapped

	if(pulling && isliving(pulling))
		var/mob/living/victim = pulling
		if(victim.stat == CONSCIOUS)
			visible_message("<span class='warning'>[victim] kicks free of [src] just before entering it!</span>")
		else
			victim.forceMove(src)
			victim.emote("scream")
			visible_message("<span class='warning'><b>[src] drags [victim] into [T]!</b></span>")
			kidnapped = victim
		stop_pulling()

	if(kidnapped)
		to_chat(src, "<B>You begin to feast on [kidnapped]. You can not move while you are doing this.</B>")
		visible_message("<span class='warning'><B>A horrible melting sound comes from [T]...</B></span>")
		playsound(get_turf(T), 'sound/hispania/effects/oldman/victim.ogg', 100, 1, -1)
		spawn(75)
			if(kidnapped)
				to_chat(src, "<B>You feed on [kidnapped]. Your health is restored.</B>")
				adjustBruteLoss(-kidnapped.maxHealth*2.5)
				last_meal = world.time

				to_chat(kidnapped, "<span class='userdanger'>You feel your flesh melting away...</span>")
				kidnapped.adjustFireLoss(1000)
				kidnapped.death()//por si aun vive, el hijo de fruta
				consumed_mobs.Add(kidnapped)
			else
				to_chat(src, "<span class='danger'>You happily devour... nothing? Your meal vanished at some point!</span>")
	spawn(30)//para que quede mas o menos igual que con los sleeps
		notransform = FALSE
		invisibility = INVISIBILITY_REVENANT
		icon_state = "idle"


/mob/living/simple_animal/hostile/oldman/proc/outdimension(turf/simulated/wall/T)
	if(notransform)
		to_chat(src, "<span class='warning'>You have to finish first!</span>")
		return
	playsound(get_turf(T), 'sound/weapons/sear.ogg', 100, 1, -1)
	to_chat(viewers(T), "<span class='warning'>[T] starts to melt away...</span>")
	notransform = TRUE
	if(!do_after(src, 10, target = T))
		notransform = FALSE
		return
	forceMove(get_turf(T))
	rust(T)
	playsound(get_turf(T), 'sound/hispania/effects/oldman/phasing.ogg', 100, 1, -1)
	invisibility = 0
	client.eye = src
	icon_state = "emergence"
	spawn(20)
		icon_state = "oldman"
	incorporeal_move = 0
	speed = 7
	density = TRUE
	pass_flags = 0
	dimension = FALSE

	var/list/voices = list('sound/hispania/effects/oldman/oldlaugh2.ogg','sound/hispania/effects/oldman/oldgrowl.ogg')
	playsound(get_turf(src), pick(voices),50, 1, -1)
	visible_message("<span class='warning'><B>\The [src] emerges out of \the [T]!</B>")

/mob/living/simple_animal/hostile/oldman/proc/rust(turf/simulated/wall/T)
	if(!istype(T, /turf/simulated/shuttle) && !istype(T, /turf/simulated/wall/rust) && !istype(T, /turf/simulated/wall/r_wall) && istype(T, /turf/simulated/wall))
		T.ChangeTurf(/turf/simulated/wall/rust)
	if(!istype(T, /turf/simulated/wall/r_wall/rust) && istype(T, /turf/simulated/wall/r_wall))
		T.ChangeTurf(/turf/simulated/wall/r_wall/rust)
