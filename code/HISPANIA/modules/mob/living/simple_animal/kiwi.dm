
/mob/living/simple_animal/kiwi
	name = "kiwi"
	desc = "It's a real kiwi... maybe?"
	icon = 'icons/hispania/mob/animals.dmi'
	icon_state = "kiwi"
	icon_dead = "kiwi_dead"
	speak = list("Cherp.","Cherp?","Chirrup.","Cheep!")
	speak_emote = list("cheeps")
	emote_hear = list("cheeps")
	emote_see = list("pecks at the ground","flaps its tiny wings")
	speak_chance = 2
	turns_per_move = 1
	maxHealth = 20
	health = 20
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 1)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "whacks"
	harm_intent_damage = 5
	obj_damage = 0
	melee_damage_lower = 1
	melee_damage_upper = 1
	attacktext = "chomps"
	attack_sound = 'sound/weapons/bite.ogg'
	faction = list("mushroom")
	environment_smash = 0
	speed = 1
	ventcrawler = 2
	speak_emote = list("squeaks")
	deathmessage = "fainted"
	stop_automated_movement_when_pulled = 1
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	can_hide = 1
	can_collar = 1
	gold_core_spawnable = CHEM_MOB_SPAWN_FRIENDLY

/mob/living/simple_animal/kiwi/handle_automated_movement()
	..()
	if(!pulledby)
		for(var/direction in shuffle(list(1,2,4,8,5,6,9,10)))
			var/step = get_step(src, direction)
			if(step)
				if(locate(/obj/structure/spacevine) in step)
					Move(step, get_dir(src, step))
					sleep 10

/mob/living/simple_animal/kiwi/process_ai()
	if(prob(10))
		src.visible_message("<span class='notice'>[src] thinks about flying through the sky...</span>")
		icon_state = "kiwi_fly"
		sleep(6)
		icon_state = "kiwi"
	else
		if(prob(35))
			src.visible_message("<span class='notice'>[src] jumps!</span>")
			icon_state = "kiwi_jump"
			sleep(6)
			icon_state = "kiwi"
		else
			if(prob(35))
				src.visible_message("<span class='notice'>[src] dances.</span>")
				icon_state = "kiwi_dance"
				sleep(12)
				icon_state = "kiwi"
			else
				..()
	sleep(150)


/mob/living/simple_animal/kiwi/emote(act, m_type=1, message = null)
	if(stat != CONSCIOUS)
		return

	var/on_CD = 0
	act = lowertext(act)
	switch(act)
		if("chirp")
			on_CD = handle_emote_CD()
		else
			on_CD = 0

	if(on_CD == 1)
		return

	switch(act) //IMPORTANT: Emotes MUST NOT CONFLICT anywhere along the chain.
		if("dance")
			message = "<B>\The [src]</B> dances!"
			m_type = 2 //audible
			icon_state = "kiwi_dance"
			sleep(12)
			icon_state = "kiwi"
		if("jump")
			message = "<B>\The [src]</B> jumps!"
			m_type = 2 //audible
			icon_state = "kiwi_jump"
			sleep(6)
			icon_state = "kiwi"
		if("fly")
			message = "<B>\The [src]</B> thinks about flying through the sky...!"
			m_type = 2 //audible
			icon_state = "kiwi_fly"
			sleep(6)
			icon_state = "kiwi"
		if("help")
			var/emotelist = "Emotes: dance, jump, fly."
			to_chat(src, emotelist)

	..(act, m_type, message)