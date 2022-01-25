/mob/living/simple_animal/friendly/owl
	name = "Garronte"
	desc = "When you sleep, he is awake!. In the eyes you can look the future."
	gender = MALE
	health = 25
	maxHealth = 25
	density = TRUE
	icon = 'icons/hispania/mob/animals.dmi'
	icon_state = "owl"
	icon_living = "owl"
	icon_dead = "owl_dead"
	speak = list("Hoot.","Hoot?","Hoot!","Cough.")
	speak_emote = list("hoot")
	emote_hear = list("hoot")
	emote_see = list("hoot")
	var/owl_sound = 'sound/hispania/mob/owl_hoot.ogg'	//Used in emote.
	speak_chance = 1
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 3)
	turns_per_move = 10
	can_collar = FALSE
	unique_pet = TRUE
	melee_damage_lower = 0
	melee_damage_upper = 2
	attacktext = "scratch"
	attack_sound = 'sound/weapons/pierce.ogg'

/mob/living/simple_animal/friendly/owl/emote(act, m_type = 1, message = null, force)
	if(stat != CONSCIOUS)
		return
	var/on_CD = 0
	act = lowertext(act)
	switch(act)
		if("hoot")
			on_CD = handle_emote_CD()
		else
			on_CD = 0
	if(!force && on_CD == 1)
		return
	switch(act)
		if("hoot")
			message = "<B>[src]</B> [pick(emote_hear)]!"
			m_type = 2 //audible
			playsound(src, owl_sound, 50, 0.75)
		if("help")
			to_chat(src, "scream, hoot")
