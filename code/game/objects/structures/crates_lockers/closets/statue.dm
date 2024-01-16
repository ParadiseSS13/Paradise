/obj/structure/closet/statue //this type path is a crime, ponies what the fuck
	name = "statue"
	desc = "An incredibly lifelike marble carving"
	icon = 'icons/obj/statue.dmi'
	icon_state = "human_male"
	density = TRUE
	anchored = TRUE
	max_integrity = 0 //destroying the statue kills the mob within
	var/intialTox = 0 	//these are here to keep the mob from taking damage from things that logically wouldn't affect a rock
	var/intialFire = 0	//it's a little sloppy I know but it was this or the GODMODE flag. Lesser of two evils.
	var/intialBrute = 0
	var/intialOxy = 0
	var/timer = 240 // timer counts down durring process, eventually the person will be freed

/obj/structure/closet/statue/Initialize(mapload, mob/living/L)
	. = ..()
	if(ishuman(L) || iscorgi(L))
		if(L.buckled)
			L.unbuckle_mob()
		L.forceMove(src)
		ADD_TRAIT(L, TRAIT_MUTE, STATUE_MUTE)
		max_integrity = max(L.health + 100, 100) //stoning damaged mobs will result in easier to shatter statues
		intialTox = L.getToxLoss()
		intialFire = L.getFireLoss()
		intialBrute = L.getBruteLoss()
		intialOxy = L.getOxyLoss()
		if(issmall(L))
			name = "statue of a monkey"
			icon_state = "monkey"
		else if(ishuman(L))
			name = "statue of [L.name]"
			if(L.gender == "female")
				icon_state = "human_female"
		else if(iscorgi(L))
			name = "statue of a corgi"
			icon_state = "corgi"
			desc = "If it takes forever, I will wait for you..."

	if(max_integrity == 0) //meaning if the statue didn't find a valid target
		qdel(src)
		return

	START_PROCESSING(SSobj, src)

/obj/structure/closet/statue/process()
	timer--
	for(var/mob/living/M in src) //Go-go gadget stasis field
		M.setToxLoss(intialTox)
		M.adjustFireLoss(intialFire - M.getFireLoss())
		M.adjustBruteLoss(intialBrute - M.getBruteLoss())
		M.setOxyLoss(intialOxy)
	if(timer <= 0)
		dump_contents()
		STOP_PROCESSING(SSobj, src)
		qdel(src)

/obj/structure/closet/statue/dump_contents()
	if(istype(loc, /mob/living/simple_animal/hostile/statue))
		var/mob/living/simple_animal/hostile/statue/S = loc
		forceMove(S.loc)
		if(S.mind)
			for(var/mob/M in contents)
				S.mind.transfer_to(M)
				to_chat(M, "As the animating magic wears off you feel yourself coming back to your senses. You are yourself again!")
				break
		qdel(S)

	for(var/mob/living/M in src)
		M.forceMove(loc)
		REMOVE_TRAIT(M, TRAIT_MUTE, STATUE_MUTE)
		M.take_overall_damage((M.health - obj_integrity - 100),0) //any new damage the statue incurred is transfered to the mob

	..()

/obj/structure/closet/statue/shove_impact(mob/living/target, mob/living/attacker)
	return FALSE

/obj/structure/closet/statue/open()
	return

/obj/structure/closet/statue/open()
	return


/obj/structure/closet/statue/close()
	return

/obj/structure/closet/statue/toggle()
	return

/obj/structure/closet/statue/obj_destruction(damage_flag)
	for(var/mob/M in src)
		shatter(M)
	..()

/obj/structure/closet/statue/welder_act()
	return

/obj/structure/closet/statue/MouseDrop_T()
	return

/obj/structure/closet/statue/relaymove()
	return

/obj/structure/closet/statue/attack_hand()
	return

/obj/structure/closet/statue/update_icon_state()
	return

/obj/structure/closet/statue/update_overlays()
	return list()

/obj/structure/closet/statue/proc/shatter(mob/user)
	if(user)
		user.dust()
	dump_contents()
	visible_message("<span class='warning'>[src] shatters!. </span>")
