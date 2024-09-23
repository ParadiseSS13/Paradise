/mob/living/simple_animal/hostile/illusion
	name = "illusion"
	desc = "It's a fake!"
	icon = 'icons/effects/effects.dmi'
	icon_state = "static"
	icon_living = "static"
	icon_dead = "null"
	mob_biotypes = NONE
	melee_damage_lower = 5
	melee_damage_upper = 5
	a_intent = INTENT_HARM
	attacktext = "gores"
	maxHealth = 100
	health = 100
	speed = 0
	faction = list("illusion")
	var/life_span = INFINITY //how long until they despawn
	var/mob/living/parent_mob
	var/multiply_chance = 0 //if we multiply on hit
	deathmessage = "vanishes into thin air! It was a fake!"
	del_on_death = TRUE
	hud_possible = list(
		HEALTH_HUD, STATUS_HUD, SPECIALROLE_HUD, // from /mob/living
		ID_HUD, WANTED_HUD, IMPMINDSHIELD_HUD, IMPCHEM_HUD, IMPTRACK_HUD
	)

/mob/living/simple_animal/hostile/illusion/Life()
	..()
	if(world.time > life_span)
		death()

/mob/living/simple_animal/hostile/illusion/proc/Copy_Parent(mob/living/original, life = 50, health = 100, damage = 0, replicate = 0 )
	appearance = original.appearance
	parent_mob = original
	dir = original.dir
	life_span = world.time+life
	melee_damage_lower = damage
	melee_damage_upper = damage
	multiply_chance = replicate
	faction -= "neutral"
	transform = initial(transform)
	pixel_y = initial(pixel_y)
	pixel_x = initial(pixel_x)
	fake_huds()
	add_to_all_human_data_huds()

/mob/living/simple_animal/hostile/illusion/examine(mob/user)
	if(parent_mob)
		. = parent_mob.examine(user)
	else
		. = ..()

/mob/living/simple_animal/hostile/illusion/proc/fake_huds()
	if(SSticker.current_state != GAME_STATE_PLAYING)
		return
	if(!ishuman(parent_mob))
		return
	var/mob/living/carbon/human/H = parent_mob
	var/image/holder = hud_list[ID_HUD]
	holder.icon_state = "hudunknown"
	if(H.wear_id)
		holder.icon_state = "hud[ckey(H.wear_id.get_job_name())]"
	var/image/holder2
	for(var/i in list(IMPTRACK_HUD, IMPMINDSHIELD_HUD, IMPCHEM_HUD))
		holder2 = hud_list[i]
		holder2.icon_state = null
	for(var/obj/item/bio_chip/I in H)
		if(I.implanted)
			if(istype(I, /obj/item/bio_chip/tracking))
				holder2 = hud_list[IMPTRACK_HUD]
				holder2.icon_state = "hud_imp_tracking"
			else if(istype(I, /obj/item/bio_chip/mindshield))
				holder2 = hud_list[IMPMINDSHIELD_HUD]
				holder2.icon_state = "hud_imp_loyal"
			else if(istype(I, /obj/item/bio_chip/chem))
				holder2 = hud_list[IMPCHEM_HUD]
				holder2.icon_state = "hud_imp_chem"
	var/image/holder3 = hud_list[WANTED_HUD]
	var/perpname = H.get_visible_name(TRUE) //gets the name of the perp, works if they have an id or if their face is uncovered
	if(perpname)
		var/datum/data/record/R = find_record("name", perpname, GLOB.data_core.security)
		if(R)
			switch(R.fields["criminal"])
				if(SEC_RECORD_STATUS_EXECUTE)
					holder3.icon_state = "hudexecute"
					return
				if(SEC_RECORD_STATUS_ARREST)
					holder3.icon_state = "hudwanted"
					return
				if(SEC_RECORD_STATUS_SEARCH)
					holder3.icon_state = "hudsearch"
					return
				if(SEC_RECORD_STATUS_MONITOR)
					holder3.icon_state = "hudmonitor"
					return
				if(SEC_RECORD_STATUS_DEMOTE)
					holder3.icon_state = "huddemote"
					return
				if(SEC_RECORD_STATUS_INCARCERATED)
					holder3.icon_state = "hudincarcerated"
					return
				if(SEC_RECORD_STATUS_PAROLLED)
					holder3.icon_state = "hudparolled"
					return
				if(SEC_RECORD_STATUS_RELEASED)
					holder3.icon_state = "hudreleased"
					return
	holder3.icon_state = null

/mob/living/simple_animal/hostile/illusion/AttackingTarget()
	. = ..()
	if(. && isliving(target) && prob(multiply_chance))
		var/mob/living/L = target
		if(L.stat == DEAD)
			return
		var/mob/living/simple_animal/hostile/illusion/M = new(loc)
		M.faction = faction.Copy()
		M.attack_sound = attack_sound
		M.Copy_Parent(parent_mob, 80, health/2, melee_damage_upper, multiply_chance/2)
		M.GiveTarget(L)

///////Actual Types/////////

/mob/living/simple_animal/hostile/illusion/escape
	retreat_distance = 10
	minimum_distance = 10
	melee_damage_lower = 0
	melee_damage_upper = 0
	speed = -1
	obj_damage = 0
	environment_smash = 0


/mob/living/simple_animal/hostile/illusion/escape/AttackingTarget()
	return

///////Cult Illusions/////////
/mob/living/simple_animal/hostile/illusion/cult
	loot = list(/obj/effect/temp_visual/cult/sparks) // So that they SPARKLE on death

/mob/living/simple_animal/hostile/illusion/escape/cult
	loot = list(/obj/effect/temp_visual/cult/sparks)

/mob/living/simple_animal/hostile/illusion/escape/stealth
	maxHealth = 20
	health = 20
