#define STAGE_HAUNT 1
#define STAGE_SPOOK 2
#define STAGE_TORMENT 3
#define STAGE_ATTACK 4
#define MANIFEST_DELAY 9

/mob/living/simple_animal/hostile/floor_cluwne
	name = "???"
	desc = "...."
	icon = 'icons/goonstation/objects/clothing/mask.dmi'
	icon_state = "cursedclown"
	icon_living = "cursedclown"
	icon_gib = "clown_gib"
	maxHealth = 200
	health = 200
	speed = -1
	attacktext = "attacks"
	attack_sound = 'sound/items/bikehorn.ogg'
	del_on_death = TRUE
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB | LETPASSTHROW | PASSGLASS | PASSBLOB//it's practically a ghost when unmanifested (under the floor)
	loot = list(/obj/item/clothing/mask/cursedclown)
	a_intent = INTENT_HARM
	wander = FALSE
	minimum_distance = 2
	move_to_delay = 1
	environment_smash = FALSE
	pixel_y = 8
	pressure_resistance = 200
	minbodytemp = 0
	maxbodytemp = 1500
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	var/mob/living/carbon/human/current_victim
	var/manifested = FALSE
	var/switch_stage = 60
	var/stage = STAGE_HAUNT
	var/interest = 0
	var/target_area
	var/invalid_area_typecache = list(/area/space, /area/centcom)
	var/eating = FALSE
	var/smiting = FALSE
	var/admincluwne = FALSE


/mob/living/simple_animal/hostile/floor_cluwne/New()
	. = ..()
	remove_from_all_data_huds()
	var/obj/item/card/id/access_card = new (src)
	access_card.access = get_all_accesses()//THERE IS NO ESCAPE
	access_card.flags |= NODROP
	invalid_area_typecache = typecacheof(invalid_area_typecache)
	Manifest()
	if(!current_victim)
		var/turf/current_location = get_turf(src)
		if(!is_admin_level(current_location.z))//admin spawned off station Z for some reason do not trigger anything else
			admincluwne = TRUE
			return
		Acquire_Victim()


/mob/living/simple_animal/hostile/floor_cluwne/Destroy()
	return ..()


/mob/living/simple_animal/hostile/floor_cluwne/attack_hand(mob/living/carbon/human/M)
	..()
	playsound(src.loc, 'sound/items/bikehorn.ogg', 50, 1)


/mob/living/simple_animal/hostile/floor_cluwne/CanPass(atom/A, turf/target)
	return TRUE


/mob/living/simple_animal/hostile/floor_cluwne/Life(seconds, times_fired)
	if(current_victim && !ishuman(current_victim)) //Just in case a nonhuman is accidentally chosen. A human will then be chosen later on in Acquire_Victim()
		current_victim = null

	do_jitter_animation(1000)
	pixel_y = 8

	if(is_type_in_typecache(get_area(loc), invalid_area_typecache))
		var/area = pick(GLOB.teleportlocs)
		var/area/tp = GLOB.teleportlocs[area]
		forceMove(pick(get_area_turfs(tp.type)))

	if((!current_victim && !admincluwne) || QDELETED(current_victim))
		Acquire_Victim()

	if(stage && !manifested)
		On_Stage()

	if(stage == STAGE_ATTACK)
		playsound(src, 'sound/spookoween/ghost_whisper.ogg', 75, 1)

	if(eating)
		return

	var/turf/T = get_turf(current_victim)
	if(prob(5))//checks roughly every 20 ticks
		if(!admincluwne)
			if(current_victim.stat == DEAD || current_victim.get_int_organ(/obj/item/organ/internal/honktumor/cursed) || is_type_in_typecache(get_area(T), invalid_area_typecache))
				Acquire_Victim()

	if(get_dist(src, current_victim) > 9 && !manifested &&  !is_type_in_typecache(get_area(T), invalid_area_typecache))//if cluwne gets stuck he just teleports
		do_teleport(src, T)

	interest++
	if(interest >= switch_stage * 4)
		stage = STAGE_ATTACK

	else if(interest >= switch_stage * 2)
		stage = STAGE_TORMENT

	else if(interest >= switch_stage)
		stage = STAGE_SPOOK

	else if(interest < switch_stage)
		stage = STAGE_HAUNT

	..()


/mob/living/simple_animal/hostile/floor_cluwne/Goto(target, delay, minimum_distance)
	if(!manifested && !is_type_in_typecache(get_area(current_victim.loc), invalid_area_typecache))
		walk_to(src, target, minimum_distance, delay)
	else
		walk_to(src,0)


/mob/living/simple_animal/hostile/floor_cluwne/FindTarget()
	return current_victim


/mob/living/simple_animal/hostile/floor_cluwne/CanAttack(atom/the_target)//you will not escape
	return TRUE


/mob/living/simple_animal/hostile/floor_cluwne/AttackingTarget()
	return


/mob/living/simple_animal/hostile/floor_cluwne/LoseTarget()
	return


/mob/living/simple_animal/hostile/floor_cluwne/electrocute_act(shock_damage, obj/source, siemens_coeff = 1, safety = FALSE, override = FALSE, tesla_shock = FALSE, illusion = FALSE, stun = TRUE) //prevents runtimes with machine fuckery
	return FALSE


/mob/living/simple_animal/hostile/floor_cluwne/proc/Acquire_Victim(specific)
	var/list/players_copy = GLOB.player_list.Copy()
	while(players_copy.len)
		var/mob/living/carbon/human/H = pick_n_take(players_copy)
		if(!ishuman(H))
			continue

		if(specific)
			H = specific
			if((!H || H.stat == DEAD) && smiting)//safety check, target somehow DIED after we sent a smite
				message_admins("Smiting floor cluwne was deleted due to a lack of valid target. Someone killed them first, or they ceased to exist.")
				qdel(src)
				return
			if(H.stat != DEAD && !isLivingSSD(H) &&  H.client && !H.get_int_organ(/obj/item/organ/internal/honktumor/cursed) && !is_type_in_typecache(get_area(H.loc), invalid_area_typecache))
				current_victim = H
				return target = current_victim

		if(H && H.stat != DEAD && H != current_victim && !isLivingSSD(H) &&  H.client && !H.get_int_organ(/obj/item/organ/internal/honktumor/cursed) && !is_type_in_typecache(get_area(H.loc), invalid_area_typecache))
			current_victim = H
			interest = 0
			return target = current_victim

	message_admins("Floor cluwne was deleted due to a lack of valid targets[specific ? ", if you spawned this with a specific target please choose another person" : null].")
	qdel(src)

/mob/living/simple_animal/hostile/floor_cluwne/proc/Manifest()//handles disappearing and appearance anim
	if(manifested)
		new /obj/effect/temp_visual/fcluwne_manifest(loc)
		addtimer(CALLBACK(src, /mob/living/simple_animal/hostile/floor_cluwne/.proc/Appear), MANIFEST_DELAY)

	else
		layer = GAME_PLANE
		invisibility = INVISIBILITY_MAXIMUM
		mouse_opacity = 0
		density = FALSE

/mob/living/simple_animal/hostile/floor_cluwne/proc/Appear()//handled in a seperate proc so floor cluwne doesn't appear before the animation finishes
	layer = MOB_LAYER
	invisibility = FALSE
	mouse_opacity = 1
	density = TRUE


/mob/living/simple_animal/hostile/floor_cluwne/proc/Reset_View(screens, color, mob/living/carbon/human/H)
	if(screens)
		for(var/whole_screen in screens)
			animate(whole_screen, transform = matrix(), time = 5, easing = QUAD_EASING)
	if(color && H)
		animate(H.client, color = color, time = 5)


/mob/living/simple_animal/hostile/floor_cluwne/proc/On_Stage()
	var/mob/living/carbon/human/H = current_victim
	if(!H)
		Acquire_Victim()
	switch(stage)

		if(STAGE_HAUNT)

			if(prob(5))
				H.AdjustEyeBlurry(1)

			if(prob(5))
				H.playsound_local(src,'sound/spookoween/insane_low_laugh.ogg', 1)

			if(prob(8))
				H.playsound_local(src,'sound/spookoween/ghost_whisper.ogg', 5)

			if(prob(5))
				var/obj/item/I = locate() in orange(H, 8)
				if(I && !I.anchored)
					I.throw_at(H, 4, 3)
					to_chat(H, "<span class='warning'>What threw that?</span>")

		if(STAGE_SPOOK)

			if(prob(4))
				H.slip("???", 5, 2)
				to_chat(H, "<span class='warning'>The floor shifts underneath you!</span>")

			if(prob(3))
				H.playsound_local(src,'sound/spookoween/scary_horn.ogg', 2)

			if(prob(8))
				H.playsound_local(src,'sound/spookoween/scary_horn2.ogg', 2)

			if(prob(5))
				H.playsound_local(src,'sound/hallucinations/growl1.ogg', 10)
				to_chat(H, "<font face='Comic Sans MS'><i>knoh</i></font>")

			if(prob(5))
				var/obj/item/I = locate() in orange(H, 8)
				if(I && !I.anchored)
					I.throw_at(H, 4, 3)
					to_chat(H, "<span class='warning'>What threw that?</span>")

			if(prob(4))
				to_chat(H, "<font face='Comic Sans MS'><i>yalp ot tnaw I</i></font>")
				Appear()
				manifested = FALSE
				addtimer(CALLBACK(src, /mob/living/simple_animal/hostile/floor_cluwne/.proc/Manifest), 1)

		if(STAGE_TORMENT)

			if(prob(5))
				H.slip("???", 5, 2)
				to_chat(H, "<span class='warning'>The floor shifts underneath you!</span>")

			if(prob(5))
				playsound(src, pick('sound/spookoween/scary_horn.ogg', 'sound/spookoween/scary_horn2.ogg', 'sound/spookoween/scary_horn3.ogg'), 30, 1)

			if(prob(3))
				playsound(src, pick('sound/hallucinations/growl1.ogg', 'sound/hallucinations/growl2.ogg') , 30, 1)


			if(prob(4))
				for(var/obj/item/I in orange(H, 5))
					if(I && !I.anchored)
						I.throw_at(H, 4, 3)
				to_chat(H, "<span class='warning'>What the hell?!</span>")

			if(prob(5))
				to_chat(H, "<span class='warning'>Something feels very wrong...</span>")
				H.playsound_local(src,'sound/hallucinations/behind_you1.ogg', 25)
				H.flash_eyes()

			if(prob(5))
				to_chat(H, "<font face='Comic Sans MS'><i>!?REHTOMKNOH eht esiarp uoy oD</i></font>")
				to_chat(H, "<span class='warning'>Something grabs your foot!</span>")
				H.playsound_local(src,'sound/hallucinations/i_see_you1.ogg', 25)
				H.Stun(10)

			if(prob(5))
				to_chat(H, "<font face='Comic Sans MS'><i>!KNOH ?od nottub siht seod tahW</i></font>")
				for(var/obj/machinery/M in range(H, 6))
					M.attack_hand(src)

			if(prob(6))
				for(var/turf/simulated/floor/O in range(src, 6))
					O.MakeSlippery(TURF_WET_WATER, 10)
					playsound(src, 'sound/effects/clownstep1.ogg', 30, 1)

			if(prob(5))
				to_chat(H, "<span class='userdanger'>WHAT THE FUCK IS THAT?!</span>")
				to_chat(H, "<font face='Comic Sans MS'><i>.KNOH !nuf hcum os si uoy htiw gniyalP .KNOH KNOH KNOH</i></font>")
				H.playsound_local(src,'sound/hallucinations/im_here1.ogg', 25)
				H.reagents.add_reagent("lsd", 3)
				Appear()
				manifested = FALSE
				addtimer(CALLBACK(src, /mob/living/simple_animal/hostile/floor_cluwne/.proc/Manifest), 2)
				for(var/obj/machinery/light/L in range(H, 8))
					L.flicker()

		if(STAGE_ATTACK)

			if(!eating)
				for(var/I in getline(src,H))
					var/turf/T = I
					for(var/obj/structure/O in T)
						if(istype(O, /obj/structure/closet))
							var/obj/structure/closet/locker = O
							locker.dump_contents()
						if(O.density || istype(O, /obj/machinery/door/airlock))
							forceMove(H.loc)
					if(T.density)
						forceMove(H.loc)
					if(H.buckled)
						H.buckled.unbuckle_mob(H, force = TRUE)
				manifested = TRUE
				Manifest()
				to_chat(H, "<span class='userdanger'>You feel the floor closing in on your feet!</span>")
				H.Weaken(30)
				H.emote("scream")
				H.adjustBruteLoss(10)
				if(!eating)
					addtimer(CALLBACK(src, /mob/living/simple_animal/hostile/floor_cluwne/.proc/Grab, H), 70)
					for(var/turf/simulated/floor/O in range(src, 6))
						O.MakeSlippery(TURF_WET_LUBE, 20)
						playsound(src, 'sound/effects/meteorimpact.ogg', 30, 1)

				eating = TRUE


/mob/living/simple_animal/hostile/floor_cluwne/proc/Grab(mob/living/carbon/human/H)
	to_chat(H, "<span class='userdanger'>You feel a cold, gloved hand clamp down on your ankle!</span>")
	for(var/I in 1 to get_dist(src, H))

		if(do_after(src, 10, target = H))
			step_towards(H, src)
			playsound(H, pick('sound/effects/bodyscrape-01.ogg', 'sound/effects/bodyscrape-02.ogg'), 20, 1, -4)
			H.emote("scream")
			if(prob(25))
				playsound(src, pick('sound/hallucinations/growl1.ogg', 'sound/hallucinations/growl2.ogg', 'sound/items/bikehorn.ogg'), 50, 1)

	if(get_dist(src,H) <= 1)
		visible_message("<span class='danger'>[src] begins dragging [H] under the floor!</span>")

		if(do_after(src, 50, target = H) && eating)
			H.BecomeBlind()
			H.layer = GAME_PLANE
			H.invisibility = INVISIBILITY_MAXIMUM
			H.mouse_opacity = 0
			H.density = FALSE
			H.anchored = TRUE
			addtimer(CALLBACK(src, /mob/living/simple_animal/hostile/floor_cluwne/.proc/Kill, H), 100)
			H.visible_message("<span class='userdanger'>[src] pulls [H] under the floor!</span>")
		else//some fuck pulled away our food
			stage = STAGE_TORMENT
			eating = FALSE

	else//STOP PULLING AWAY THE FOOD
		eating = FALSE
		stage = STAGE_TORMENT

	manifested = FALSE
	Manifest()


/mob/living/simple_animal/hostile/floor_cluwne/proc/Kill(mob/living/carbon/human/H)
	playsound(H, 'sound/spookoween/scary_horn2.ogg', 100, 0)
	var/old_color = H.client.color
	var/red_splash = list(1,0,0,0.8,0.2,0, 0.8,0,0.2,0.1,0,0)
	var/pure_red = list(0,0,0,0,0,0,0,0,0,1,0,0)
	H.client.color = pure_red

	animate(H.client, color = red_splash, time = 10, easing = SINE_EASING|EASE_OUT)
	for(var/turf/T in orange(H, 4))
		H.add_splatter_floor(T)
	if(do_after(src, 50, target = H))


		if(prob(50) || smiting)
			H.makeCluwne()

		H.adjustBruteLoss(30)
		H.adjustBrainLoss(100)
		for(var/I in H.bodyparts)
			var/obj/item/organ/external/O = I
			if(O.name == "head")//irksome runtimes
				O.droplimb()
				continue
			O.drop_organs()
			O.droplimb()

	Reset_View(FALSE, old_color, H)
	H.CureBlind()
	H.layer = initial(H.layer)
	H.invisibility = initial(H.invisibility)
	H.mouse_opacity = initial(H.mouse_opacity)
	H.density = initial(H.density)
	H.anchored = initial(H.anchored)

	eating = FALSE
	if(prob(2))
		switch_stage = switch_stage * 0.75 //he gets a chance to be faster after each feast
	if(smiting)
		playsound(loc, 'sound/spookoween/scary_horn2.ogg', 100, 0, -4)
		qdel(src)
	else
		Acquire_Victim()

		interest = 0

//manifestation animation
/obj/effect/temp_visual/fcluwne_manifest
	icon = 'icons/turf/floors.dmi'
	icon_state = "fcluwne_manifest"
	layer = TURF_LAYER
	duration = 150
	randomdir = FALSE


/obj/effect/temp_visual/fcluwne_manifest/New()
	. = ..()
	playsound(src, 'sound/spookoween/scary_clown_appear.ogg', 100, 1)

#undef STAGE_HAUNT
#undef STAGE_SPOOK
#undef STAGE_TORMENT
#undef STAGE_ATTACK
#undef MANIFEST_DELAY
